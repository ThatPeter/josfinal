
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
  800051:	68 60 22 80 00       	push   $0x802260
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
  80008a:	68 63 22 80 00       	push   $0x802263
  80008f:	6a 01                	push   $0x1
  800091:	e8 e2 0d 00 00       	call   800e78 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 bd 00 00 00       	call   800161 <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 c6 0d 00 00       	call   800e78 <write>
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
  8000c7:	68 ef 23 80 00       	push   $0x8023ef
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 a5 0d 00 00       	call   800e78 <write>
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
  8000f3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  80014d:	e8 3b 0b 00 00       	call   800c8d <close_all>
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
  800546:	68 6f 22 80 00       	push   $0x80226f
  80054b:	6a 23                	push   $0x23
  80054d:	68 8c 22 80 00       	push   $0x80228c
  800552:	e8 5e 12 00 00       	call   8017b5 <_panic>

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
  8005c7:	68 6f 22 80 00       	push   $0x80226f
  8005cc:	6a 23                	push   $0x23
  8005ce:	68 8c 22 80 00       	push   $0x80228c
  8005d3:	e8 dd 11 00 00       	call   8017b5 <_panic>

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
  800609:	68 6f 22 80 00       	push   $0x80226f
  80060e:	6a 23                	push   $0x23
  800610:	68 8c 22 80 00       	push   $0x80228c
  800615:	e8 9b 11 00 00       	call   8017b5 <_panic>

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
  80064b:	68 6f 22 80 00       	push   $0x80226f
  800650:	6a 23                	push   $0x23
  800652:	68 8c 22 80 00       	push   $0x80228c
  800657:	e8 59 11 00 00       	call   8017b5 <_panic>

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
  80068d:	68 6f 22 80 00       	push   $0x80226f
  800692:	6a 23                	push   $0x23
  800694:	68 8c 22 80 00       	push   $0x80228c
  800699:	e8 17 11 00 00       	call   8017b5 <_panic>

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
  8006cf:	68 6f 22 80 00       	push   $0x80226f
  8006d4:	6a 23                	push   $0x23
  8006d6:	68 8c 22 80 00       	push   $0x80228c
  8006db:	e8 d5 10 00 00       	call   8017b5 <_panic>
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
  800711:	68 6f 22 80 00       	push   $0x80226f
  800716:	6a 23                	push   $0x23
  800718:	68 8c 22 80 00       	push   $0x80228c
  80071d:	e8 93 10 00 00       	call   8017b5 <_panic>

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
  800775:	68 6f 22 80 00       	push   $0x80226f
  80077a:	6a 23                	push   $0x23
  80077c:	68 8c 22 80 00       	push   $0x80228c
  800781:	e8 2f 10 00 00       	call   8017b5 <_panic>

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

008007ce <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	83 ec 04             	sub    $0x4,%esp
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8007d8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8007da:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8007de:	74 11                	je     8007f1 <pgfault+0x23>
  8007e0:	89 d8                	mov    %ebx,%eax
  8007e2:	c1 e8 0c             	shr    $0xc,%eax
  8007e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8007ec:	f6 c4 08             	test   $0x8,%ah
  8007ef:	75 14                	jne    800805 <pgfault+0x37>
		panic("faulting access");
  8007f1:	83 ec 04             	sub    $0x4,%esp
  8007f4:	68 9a 22 80 00       	push   $0x80229a
  8007f9:	6a 1e                	push   $0x1e
  8007fb:	68 aa 22 80 00       	push   $0x8022aa
  800800:	e8 b0 0f 00 00       	call   8017b5 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	6a 07                	push   $0x7
  80080a:	68 00 f0 7f 00       	push   $0x7ff000
  80080f:	6a 00                	push   $0x0
  800811:	e8 87 fd ff ff       	call   80059d <sys_page_alloc>
	if (r < 0) {
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	85 c0                	test   %eax,%eax
  80081b:	79 12                	jns    80082f <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80081d:	50                   	push   %eax
  80081e:	68 b5 22 80 00       	push   $0x8022b5
  800823:	6a 2c                	push   $0x2c
  800825:	68 aa 22 80 00       	push   $0x8022aa
  80082a:	e8 86 0f 00 00       	call   8017b5 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80082f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800835:	83 ec 04             	sub    $0x4,%esp
  800838:	68 00 10 00 00       	push   $0x1000
  80083d:	53                   	push   %ebx
  80083e:	68 00 f0 7f 00       	push   $0x7ff000
  800843:	e8 4c fb ff ff       	call   800394 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800848:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80084f:	53                   	push   %ebx
  800850:	6a 00                	push   $0x0
  800852:	68 00 f0 7f 00       	push   $0x7ff000
  800857:	6a 00                	push   $0x0
  800859:	e8 82 fd ff ff       	call   8005e0 <sys_page_map>
	if (r < 0) {
  80085e:	83 c4 20             	add    $0x20,%esp
  800861:	85 c0                	test   %eax,%eax
  800863:	79 12                	jns    800877 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800865:	50                   	push   %eax
  800866:	68 b5 22 80 00       	push   $0x8022b5
  80086b:	6a 33                	push   $0x33
  80086d:	68 aa 22 80 00       	push   $0x8022aa
  800872:	e8 3e 0f 00 00       	call   8017b5 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800877:	83 ec 08             	sub    $0x8,%esp
  80087a:	68 00 f0 7f 00       	push   $0x7ff000
  80087f:	6a 00                	push   $0x0
  800881:	e8 9c fd ff ff       	call   800622 <sys_page_unmap>
	if (r < 0) {
  800886:	83 c4 10             	add    $0x10,%esp
  800889:	85 c0                	test   %eax,%eax
  80088b:	79 12                	jns    80089f <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80088d:	50                   	push   %eax
  80088e:	68 b5 22 80 00       	push   $0x8022b5
  800893:	6a 37                	push   $0x37
  800895:	68 aa 22 80 00       	push   $0x8022aa
  80089a:	e8 16 0f 00 00       	call   8017b5 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80089f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	57                   	push   %edi
  8008a8:	56                   	push   %esi
  8008a9:	53                   	push   %ebx
  8008aa:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8008ad:	68 ce 07 80 00       	push   $0x8007ce
  8008b2:	e8 23 15 00 00       	call   801dda <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8008b7:	b8 07 00 00 00       	mov    $0x7,%eax
  8008bc:	cd 30                	int    $0x30
  8008be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8008c1:	83 c4 10             	add    $0x10,%esp
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	79 17                	jns    8008df <fork+0x3b>
		panic("fork fault %e");
  8008c8:	83 ec 04             	sub    $0x4,%esp
  8008cb:	68 ce 22 80 00       	push   $0x8022ce
  8008d0:	68 84 00 00 00       	push   $0x84
  8008d5:	68 aa 22 80 00       	push   $0x8022aa
  8008da:	e8 d6 0e 00 00       	call   8017b5 <_panic>
  8008df:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8008e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008e5:	75 24                	jne    80090b <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8008e7:	e8 73 fc ff ff       	call   80055f <sys_getenvid>
  8008ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8008f1:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8008f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8008fc:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800901:	b8 00 00 00 00       	mov    $0x0,%eax
  800906:	e9 64 01 00 00       	jmp    800a6f <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80090b:	83 ec 04             	sub    $0x4,%esp
  80090e:	6a 07                	push   $0x7
  800910:	68 00 f0 bf ee       	push   $0xeebff000
  800915:	ff 75 e4             	pushl  -0x1c(%ebp)
  800918:	e8 80 fc ff ff       	call   80059d <sys_page_alloc>
  80091d:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800920:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800925:	89 d8                	mov    %ebx,%eax
  800927:	c1 e8 16             	shr    $0x16,%eax
  80092a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800931:	a8 01                	test   $0x1,%al
  800933:	0f 84 fc 00 00 00    	je     800a35 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800939:	89 d8                	mov    %ebx,%eax
  80093b:	c1 e8 0c             	shr    $0xc,%eax
  80093e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800945:	f6 c2 01             	test   $0x1,%dl
  800948:	0f 84 e7 00 00 00    	je     800a35 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80094e:	89 c6                	mov    %eax,%esi
  800950:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800953:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80095a:	f6 c6 04             	test   $0x4,%dh
  80095d:	74 39                	je     800998 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80095f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800966:	83 ec 0c             	sub    $0xc,%esp
  800969:	25 07 0e 00 00       	and    $0xe07,%eax
  80096e:	50                   	push   %eax
  80096f:	56                   	push   %esi
  800970:	57                   	push   %edi
  800971:	56                   	push   %esi
  800972:	6a 00                	push   $0x0
  800974:	e8 67 fc ff ff       	call   8005e0 <sys_page_map>
		if (r < 0) {
  800979:	83 c4 20             	add    $0x20,%esp
  80097c:	85 c0                	test   %eax,%eax
  80097e:	0f 89 b1 00 00 00    	jns    800a35 <fork+0x191>
		    	panic("sys page map fault %e");
  800984:	83 ec 04             	sub    $0x4,%esp
  800987:	68 dc 22 80 00       	push   $0x8022dc
  80098c:	6a 54                	push   $0x54
  80098e:	68 aa 22 80 00       	push   $0x8022aa
  800993:	e8 1d 0e 00 00       	call   8017b5 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800998:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80099f:	f6 c2 02             	test   $0x2,%dl
  8009a2:	75 0c                	jne    8009b0 <fork+0x10c>
  8009a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009ab:	f6 c4 08             	test   $0x8,%ah
  8009ae:	74 5b                	je     800a0b <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8009b0:	83 ec 0c             	sub    $0xc,%esp
  8009b3:	68 05 08 00 00       	push   $0x805
  8009b8:	56                   	push   %esi
  8009b9:	57                   	push   %edi
  8009ba:	56                   	push   %esi
  8009bb:	6a 00                	push   $0x0
  8009bd:	e8 1e fc ff ff       	call   8005e0 <sys_page_map>
		if (r < 0) {
  8009c2:	83 c4 20             	add    $0x20,%esp
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	79 14                	jns    8009dd <fork+0x139>
		    	panic("sys page map fault %e");
  8009c9:	83 ec 04             	sub    $0x4,%esp
  8009cc:	68 dc 22 80 00       	push   $0x8022dc
  8009d1:	6a 5b                	push   $0x5b
  8009d3:	68 aa 22 80 00       	push   $0x8022aa
  8009d8:	e8 d8 0d 00 00       	call   8017b5 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8009dd:	83 ec 0c             	sub    $0xc,%esp
  8009e0:	68 05 08 00 00       	push   $0x805
  8009e5:	56                   	push   %esi
  8009e6:	6a 00                	push   $0x0
  8009e8:	56                   	push   %esi
  8009e9:	6a 00                	push   $0x0
  8009eb:	e8 f0 fb ff ff       	call   8005e0 <sys_page_map>
		if (r < 0) {
  8009f0:	83 c4 20             	add    $0x20,%esp
  8009f3:	85 c0                	test   %eax,%eax
  8009f5:	79 3e                	jns    800a35 <fork+0x191>
		    	panic("sys page map fault %e");
  8009f7:	83 ec 04             	sub    $0x4,%esp
  8009fa:	68 dc 22 80 00       	push   $0x8022dc
  8009ff:	6a 5f                	push   $0x5f
  800a01:	68 aa 22 80 00       	push   $0x8022aa
  800a06:	e8 aa 0d 00 00       	call   8017b5 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800a0b:	83 ec 0c             	sub    $0xc,%esp
  800a0e:	6a 05                	push   $0x5
  800a10:	56                   	push   %esi
  800a11:	57                   	push   %edi
  800a12:	56                   	push   %esi
  800a13:	6a 00                	push   $0x0
  800a15:	e8 c6 fb ff ff       	call   8005e0 <sys_page_map>
		if (r < 0) {
  800a1a:	83 c4 20             	add    $0x20,%esp
  800a1d:	85 c0                	test   %eax,%eax
  800a1f:	79 14                	jns    800a35 <fork+0x191>
		    	panic("sys page map fault %e");
  800a21:	83 ec 04             	sub    $0x4,%esp
  800a24:	68 dc 22 80 00       	push   $0x8022dc
  800a29:	6a 64                	push   $0x64
  800a2b:	68 aa 22 80 00       	push   $0x8022aa
  800a30:	e8 80 0d 00 00       	call   8017b5 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800a35:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800a3b:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800a41:	0f 85 de fe ff ff    	jne    800925 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800a47:	a1 04 40 80 00       	mov    0x804004,%eax
  800a4c:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800a52:	83 ec 08             	sub    $0x8,%esp
  800a55:	50                   	push   %eax
  800a56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a59:	57                   	push   %edi
  800a5a:	e8 89 fc ff ff       	call   8006e8 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800a5f:	83 c4 08             	add    $0x8,%esp
  800a62:	6a 02                	push   $0x2
  800a64:	57                   	push   %edi
  800a65:	e8 fa fb ff ff       	call   800664 <sys_env_set_status>
	
	return envid;
  800a6a:	83 c4 10             	add    $0x10,%esp
  800a6d:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800a6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5f                   	pop    %edi
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <sfork>:

envid_t
sfork(void)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800a89:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800a8f:	83 ec 08             	sub    $0x8,%esp
  800a92:	53                   	push   %ebx
  800a93:	68 f4 22 80 00       	push   $0x8022f4
  800a98:	e8 f1 0d 00 00       	call   80188e <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800a9d:	c7 04 24 27 01 80 00 	movl   $0x800127,(%esp)
  800aa4:	e8 e5 fc ff ff       	call   80078e <sys_thread_create>
  800aa9:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800aab:	83 c4 08             	add    $0x8,%esp
  800aae:	53                   	push   %ebx
  800aaf:	68 f4 22 80 00       	push   $0x8022f4
  800ab4:	e8 d5 0d 00 00       	call   80188e <cprintf>
	return id;
}
  800ab9:	89 f0                	mov    %esi,%eax
  800abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	05 00 00 00 30       	add    $0x30000000,%eax
  800acd:	c1 e8 0c             	shr    $0xc,%eax
}
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	05 00 00 00 30       	add    $0x30000000,%eax
  800add:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ae2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aef:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800af4:	89 c2                	mov    %eax,%edx
  800af6:	c1 ea 16             	shr    $0x16,%edx
  800af9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800b00:	f6 c2 01             	test   $0x1,%dl
  800b03:	74 11                	je     800b16 <fd_alloc+0x2d>
  800b05:	89 c2                	mov    %eax,%edx
  800b07:	c1 ea 0c             	shr    $0xc,%edx
  800b0a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800b11:	f6 c2 01             	test   $0x1,%dl
  800b14:	75 09                	jne    800b1f <fd_alloc+0x36>
			*fd_store = fd;
  800b16:	89 01                	mov    %eax,(%ecx)
			return 0;
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1d:	eb 17                	jmp    800b36 <fd_alloc+0x4d>
  800b1f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800b24:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800b29:	75 c9                	jne    800af4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800b2b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800b31:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800b3e:	83 f8 1f             	cmp    $0x1f,%eax
  800b41:	77 36                	ja     800b79 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800b43:	c1 e0 0c             	shl    $0xc,%eax
  800b46:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	c1 ea 16             	shr    $0x16,%edx
  800b50:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800b57:	f6 c2 01             	test   $0x1,%dl
  800b5a:	74 24                	je     800b80 <fd_lookup+0x48>
  800b5c:	89 c2                	mov    %eax,%edx
  800b5e:	c1 ea 0c             	shr    $0xc,%edx
  800b61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800b68:	f6 c2 01             	test   $0x1,%dl
  800b6b:	74 1a                	je     800b87 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800b6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b70:	89 02                	mov    %eax,(%edx)
	return 0;
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
  800b77:	eb 13                	jmp    800b8c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800b79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b7e:	eb 0c                	jmp    800b8c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800b80:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b85:	eb 05                	jmp    800b8c <fd_lookup+0x54>
  800b87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 08             	sub    $0x8,%esp
  800b94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b97:	ba 94 23 80 00       	mov    $0x802394,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800b9c:	eb 13                	jmp    800bb1 <dev_lookup+0x23>
  800b9e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ba1:	39 08                	cmp    %ecx,(%eax)
  800ba3:	75 0c                	jne    800bb1 <dev_lookup+0x23>
			*dev = devtab[i];
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800baa:	b8 00 00 00 00       	mov    $0x0,%eax
  800baf:	eb 2e                	jmp    800bdf <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800bb1:	8b 02                	mov    (%edx),%eax
  800bb3:	85 c0                	test   %eax,%eax
  800bb5:	75 e7                	jne    800b9e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800bb7:	a1 04 40 80 00       	mov    0x804004,%eax
  800bbc:	8b 40 7c             	mov    0x7c(%eax),%eax
  800bbf:	83 ec 04             	sub    $0x4,%esp
  800bc2:	51                   	push   %ecx
  800bc3:	50                   	push   %eax
  800bc4:	68 18 23 80 00       	push   $0x802318
  800bc9:	e8 c0 0c 00 00       	call   80188e <cprintf>
	*dev = 0;
  800bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
  800be6:	83 ec 10             	sub    $0x10,%esp
  800be9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800bef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf2:	50                   	push   %eax
  800bf3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800bf9:	c1 e8 0c             	shr    $0xc,%eax
  800bfc:	50                   	push   %eax
  800bfd:	e8 36 ff ff ff       	call   800b38 <fd_lookup>
  800c02:	83 c4 08             	add    $0x8,%esp
  800c05:	85 c0                	test   %eax,%eax
  800c07:	78 05                	js     800c0e <fd_close+0x2d>
	    || fd != fd2)
  800c09:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800c0c:	74 0c                	je     800c1a <fd_close+0x39>
		return (must_exist ? r : 0);
  800c0e:	84 db                	test   %bl,%bl
  800c10:	ba 00 00 00 00       	mov    $0x0,%edx
  800c15:	0f 44 c2             	cmove  %edx,%eax
  800c18:	eb 41                	jmp    800c5b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800c1a:	83 ec 08             	sub    $0x8,%esp
  800c1d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c20:	50                   	push   %eax
  800c21:	ff 36                	pushl  (%esi)
  800c23:	e8 66 ff ff ff       	call   800b8e <dev_lookup>
  800c28:	89 c3                	mov    %eax,%ebx
  800c2a:	83 c4 10             	add    $0x10,%esp
  800c2d:	85 c0                	test   %eax,%eax
  800c2f:	78 1a                	js     800c4b <fd_close+0x6a>
		if (dev->dev_close)
  800c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c34:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800c37:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	74 0b                	je     800c4b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	56                   	push   %esi
  800c44:	ff d0                	call   *%eax
  800c46:	89 c3                	mov    %eax,%ebx
  800c48:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800c4b:	83 ec 08             	sub    $0x8,%esp
  800c4e:	56                   	push   %esi
  800c4f:	6a 00                	push   $0x0
  800c51:	e8 cc f9 ff ff       	call   800622 <sys_page_unmap>
	return r;
  800c56:	83 c4 10             	add    $0x10,%esp
  800c59:	89 d8                	mov    %ebx,%eax
}
  800c5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c6b:	50                   	push   %eax
  800c6c:	ff 75 08             	pushl  0x8(%ebp)
  800c6f:	e8 c4 fe ff ff       	call   800b38 <fd_lookup>
  800c74:	83 c4 08             	add    $0x8,%esp
  800c77:	85 c0                	test   %eax,%eax
  800c79:	78 10                	js     800c8b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800c7b:	83 ec 08             	sub    $0x8,%esp
  800c7e:	6a 01                	push   $0x1
  800c80:	ff 75 f4             	pushl  -0xc(%ebp)
  800c83:	e8 59 ff ff ff       	call   800be1 <fd_close>
  800c88:	83 c4 10             	add    $0x10,%esp
}
  800c8b:	c9                   	leave  
  800c8c:	c3                   	ret    

00800c8d <close_all>:

void
close_all(void)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	53                   	push   %ebx
  800c91:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800c94:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	53                   	push   %ebx
  800c9d:	e8 c0 ff ff ff       	call   800c62 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ca2:	83 c3 01             	add    $0x1,%ebx
  800ca5:	83 c4 10             	add    $0x10,%esp
  800ca8:	83 fb 20             	cmp    $0x20,%ebx
  800cab:	75 ec                	jne    800c99 <close_all+0xc>
		close(i);
}
  800cad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cb0:	c9                   	leave  
  800cb1:	c3                   	ret    

00800cb2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 2c             	sub    $0x2c,%esp
  800cbb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800cbe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cc1:	50                   	push   %eax
  800cc2:	ff 75 08             	pushl  0x8(%ebp)
  800cc5:	e8 6e fe ff ff       	call   800b38 <fd_lookup>
  800cca:	83 c4 08             	add    $0x8,%esp
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	0f 88 c1 00 00 00    	js     800d96 <dup+0xe4>
		return r;
	close(newfdnum);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	56                   	push   %esi
  800cd9:	e8 84 ff ff ff       	call   800c62 <close>

	newfd = INDEX2FD(newfdnum);
  800cde:	89 f3                	mov    %esi,%ebx
  800ce0:	c1 e3 0c             	shl    $0xc,%ebx
  800ce3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ce9:	83 c4 04             	add    $0x4,%esp
  800cec:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cef:	e8 de fd ff ff       	call   800ad2 <fd2data>
  800cf4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800cf6:	89 1c 24             	mov    %ebx,(%esp)
  800cf9:	e8 d4 fd ff ff       	call   800ad2 <fd2data>
  800cfe:	83 c4 10             	add    $0x10,%esp
  800d01:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800d04:	89 f8                	mov    %edi,%eax
  800d06:	c1 e8 16             	shr    $0x16,%eax
  800d09:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d10:	a8 01                	test   $0x1,%al
  800d12:	74 37                	je     800d4b <dup+0x99>
  800d14:	89 f8                	mov    %edi,%eax
  800d16:	c1 e8 0c             	shr    $0xc,%eax
  800d19:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800d20:	f6 c2 01             	test   $0x1,%dl
  800d23:	74 26                	je     800d4b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800d25:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	25 07 0e 00 00       	and    $0xe07,%eax
  800d34:	50                   	push   %eax
  800d35:	ff 75 d4             	pushl  -0x2c(%ebp)
  800d38:	6a 00                	push   $0x0
  800d3a:	57                   	push   %edi
  800d3b:	6a 00                	push   $0x0
  800d3d:	e8 9e f8 ff ff       	call   8005e0 <sys_page_map>
  800d42:	89 c7                	mov    %eax,%edi
  800d44:	83 c4 20             	add    $0x20,%esp
  800d47:	85 c0                	test   %eax,%eax
  800d49:	78 2e                	js     800d79 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800d4b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d4e:	89 d0                	mov    %edx,%eax
  800d50:	c1 e8 0c             	shr    $0xc,%eax
  800d53:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d5a:	83 ec 0c             	sub    $0xc,%esp
  800d5d:	25 07 0e 00 00       	and    $0xe07,%eax
  800d62:	50                   	push   %eax
  800d63:	53                   	push   %ebx
  800d64:	6a 00                	push   $0x0
  800d66:	52                   	push   %edx
  800d67:	6a 00                	push   $0x0
  800d69:	e8 72 f8 ff ff       	call   8005e0 <sys_page_map>
  800d6e:	89 c7                	mov    %eax,%edi
  800d70:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800d73:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800d75:	85 ff                	test   %edi,%edi
  800d77:	79 1d                	jns    800d96 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800d79:	83 ec 08             	sub    $0x8,%esp
  800d7c:	53                   	push   %ebx
  800d7d:	6a 00                	push   $0x0
  800d7f:	e8 9e f8 ff ff       	call   800622 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800d84:	83 c4 08             	add    $0x8,%esp
  800d87:	ff 75 d4             	pushl  -0x2c(%ebp)
  800d8a:	6a 00                	push   $0x0
  800d8c:	e8 91 f8 ff ff       	call   800622 <sys_page_unmap>
	return r;
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	89 f8                	mov    %edi,%eax
}
  800d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	53                   	push   %ebx
  800da2:	83 ec 14             	sub    $0x14,%esp
  800da5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800da8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dab:	50                   	push   %eax
  800dac:	53                   	push   %ebx
  800dad:	e8 86 fd ff ff       	call   800b38 <fd_lookup>
  800db2:	83 c4 08             	add    $0x8,%esp
  800db5:	89 c2                	mov    %eax,%edx
  800db7:	85 c0                	test   %eax,%eax
  800db9:	78 6d                	js     800e28 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dbb:	83 ec 08             	sub    $0x8,%esp
  800dbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dc1:	50                   	push   %eax
  800dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc5:	ff 30                	pushl  (%eax)
  800dc7:	e8 c2 fd ff ff       	call   800b8e <dev_lookup>
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	78 4c                	js     800e1f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800dd3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dd6:	8b 42 08             	mov    0x8(%edx),%eax
  800dd9:	83 e0 03             	and    $0x3,%eax
  800ddc:	83 f8 01             	cmp    $0x1,%eax
  800ddf:	75 21                	jne    800e02 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800de1:	a1 04 40 80 00       	mov    0x804004,%eax
  800de6:	8b 40 7c             	mov    0x7c(%eax),%eax
  800de9:	83 ec 04             	sub    $0x4,%esp
  800dec:	53                   	push   %ebx
  800ded:	50                   	push   %eax
  800dee:	68 59 23 80 00       	push   $0x802359
  800df3:	e8 96 0a 00 00       	call   80188e <cprintf>
		return -E_INVAL;
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e00:	eb 26                	jmp    800e28 <read+0x8a>
	}
	if (!dev->dev_read)
  800e02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e05:	8b 40 08             	mov    0x8(%eax),%eax
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	74 17                	je     800e23 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800e0c:	83 ec 04             	sub    $0x4,%esp
  800e0f:	ff 75 10             	pushl  0x10(%ebp)
  800e12:	ff 75 0c             	pushl  0xc(%ebp)
  800e15:	52                   	push   %edx
  800e16:	ff d0                	call   *%eax
  800e18:	89 c2                	mov    %eax,%edx
  800e1a:	83 c4 10             	add    $0x10,%esp
  800e1d:	eb 09                	jmp    800e28 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e1f:	89 c2                	mov    %eax,%edx
  800e21:	eb 05                	jmp    800e28 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800e23:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800e28:	89 d0                	mov    %edx,%eax
  800e2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2d:	c9                   	leave  
  800e2e:	c3                   	ret    

00800e2f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
  800e33:	56                   	push   %esi
  800e34:	53                   	push   %ebx
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e3b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800e3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e43:	eb 21                	jmp    800e66 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	89 f0                	mov    %esi,%eax
  800e4a:	29 d8                	sub    %ebx,%eax
  800e4c:	50                   	push   %eax
  800e4d:	89 d8                	mov    %ebx,%eax
  800e4f:	03 45 0c             	add    0xc(%ebp),%eax
  800e52:	50                   	push   %eax
  800e53:	57                   	push   %edi
  800e54:	e8 45 ff ff ff       	call   800d9e <read>
		if (m < 0)
  800e59:	83 c4 10             	add    $0x10,%esp
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	78 10                	js     800e70 <readn+0x41>
			return m;
		if (m == 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	74 0a                	je     800e6e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800e64:	01 c3                	add    %eax,%ebx
  800e66:	39 f3                	cmp    %esi,%ebx
  800e68:	72 db                	jb     800e45 <readn+0x16>
  800e6a:	89 d8                	mov    %ebx,%eax
  800e6c:	eb 02                	jmp    800e70 <readn+0x41>
  800e6e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	53                   	push   %ebx
  800e7c:	83 ec 14             	sub    $0x14,%esp
  800e7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e85:	50                   	push   %eax
  800e86:	53                   	push   %ebx
  800e87:	e8 ac fc ff ff       	call   800b38 <fd_lookup>
  800e8c:	83 c4 08             	add    $0x8,%esp
  800e8f:	89 c2                	mov    %eax,%edx
  800e91:	85 c0                	test   %eax,%eax
  800e93:	78 68                	js     800efd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e95:	83 ec 08             	sub    $0x8,%esp
  800e98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9b:	50                   	push   %eax
  800e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9f:	ff 30                	pushl  (%eax)
  800ea1:	e8 e8 fc ff ff       	call   800b8e <dev_lookup>
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	78 47                	js     800ef4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800eb4:	75 21                	jne    800ed7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800eb6:	a1 04 40 80 00       	mov    0x804004,%eax
  800ebb:	8b 40 7c             	mov    0x7c(%eax),%eax
  800ebe:	83 ec 04             	sub    $0x4,%esp
  800ec1:	53                   	push   %ebx
  800ec2:	50                   	push   %eax
  800ec3:	68 75 23 80 00       	push   $0x802375
  800ec8:	e8 c1 09 00 00       	call   80188e <cprintf>
		return -E_INVAL;
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ed5:	eb 26                	jmp    800efd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ed7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eda:	8b 52 0c             	mov    0xc(%edx),%edx
  800edd:	85 d2                	test   %edx,%edx
  800edf:	74 17                	je     800ef8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ee1:	83 ec 04             	sub    $0x4,%esp
  800ee4:	ff 75 10             	pushl  0x10(%ebp)
  800ee7:	ff 75 0c             	pushl  0xc(%ebp)
  800eea:	50                   	push   %eax
  800eeb:	ff d2                	call   *%edx
  800eed:	89 c2                	mov    %eax,%edx
  800eef:	83 c4 10             	add    $0x10,%esp
  800ef2:	eb 09                	jmp    800efd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ef4:	89 c2                	mov    %eax,%edx
  800ef6:	eb 05                	jmp    800efd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ef8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800efd:	89 d0                	mov    %edx,%eax
  800eff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <seek>:

int
seek(int fdnum, off_t offset)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f0a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800f0d:	50                   	push   %eax
  800f0e:	ff 75 08             	pushl  0x8(%ebp)
  800f11:	e8 22 fc ff ff       	call   800b38 <fd_lookup>
  800f16:	83 c4 08             	add    $0x8,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 0e                	js     800f2b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800f1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f20:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f23:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	53                   	push   %ebx
  800f31:	83 ec 14             	sub    $0x14,%esp
  800f34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800f37:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f3a:	50                   	push   %eax
  800f3b:	53                   	push   %ebx
  800f3c:	e8 f7 fb ff ff       	call   800b38 <fd_lookup>
  800f41:	83 c4 08             	add    $0x8,%esp
  800f44:	89 c2                	mov    %eax,%edx
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 65                	js     800faf <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800f4a:	83 ec 08             	sub    $0x8,%esp
  800f4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f50:	50                   	push   %eax
  800f51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f54:	ff 30                	pushl  (%eax)
  800f56:	e8 33 fc ff ff       	call   800b8e <dev_lookup>
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	78 44                	js     800fa6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800f62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f65:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800f69:	75 21                	jne    800f8c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800f6b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800f70:	8b 40 7c             	mov    0x7c(%eax),%eax
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	53                   	push   %ebx
  800f77:	50                   	push   %eax
  800f78:	68 38 23 80 00       	push   $0x802338
  800f7d:	e8 0c 09 00 00       	call   80188e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800f8a:	eb 23                	jmp    800faf <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800f8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f8f:	8b 52 18             	mov    0x18(%edx),%edx
  800f92:	85 d2                	test   %edx,%edx
  800f94:	74 14                	je     800faa <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800f96:	83 ec 08             	sub    $0x8,%esp
  800f99:	ff 75 0c             	pushl  0xc(%ebp)
  800f9c:	50                   	push   %eax
  800f9d:	ff d2                	call   *%edx
  800f9f:	89 c2                	mov    %eax,%edx
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	eb 09                	jmp    800faf <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	eb 05                	jmp    800faf <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800faa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800faf:	89 d0                	mov    %edx,%eax
  800fb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb4:	c9                   	leave  
  800fb5:	c3                   	ret    

00800fb6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	53                   	push   %ebx
  800fba:	83 ec 14             	sub    $0x14,%esp
  800fbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fc0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc3:	50                   	push   %eax
  800fc4:	ff 75 08             	pushl  0x8(%ebp)
  800fc7:	e8 6c fb ff ff       	call   800b38 <fd_lookup>
  800fcc:	83 c4 08             	add    $0x8,%esp
  800fcf:	89 c2                	mov    %eax,%edx
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	78 58                	js     80102d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fd5:	83 ec 08             	sub    $0x8,%esp
  800fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fdf:	ff 30                	pushl  (%eax)
  800fe1:	e8 a8 fb ff ff       	call   800b8e <dev_lookup>
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 37                	js     801024 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ff4:	74 32                	je     801028 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ff6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800ff9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801000:	00 00 00 
	stat->st_isdir = 0;
  801003:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80100a:	00 00 00 
	stat->st_dev = dev;
  80100d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801013:	83 ec 08             	sub    $0x8,%esp
  801016:	53                   	push   %ebx
  801017:	ff 75 f0             	pushl  -0x10(%ebp)
  80101a:	ff 50 14             	call   *0x14(%eax)
  80101d:	89 c2                	mov    %eax,%edx
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	eb 09                	jmp    80102d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801024:	89 c2                	mov    %eax,%edx
  801026:	eb 05                	jmp    80102d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801028:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80102d:	89 d0                	mov    %edx,%eax
  80102f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	56                   	push   %esi
  801038:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801039:	83 ec 08             	sub    $0x8,%esp
  80103c:	6a 00                	push   $0x0
  80103e:	ff 75 08             	pushl  0x8(%ebp)
  801041:	e8 e3 01 00 00       	call   801229 <open>
  801046:	89 c3                	mov    %eax,%ebx
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	78 1b                	js     80106a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80104f:	83 ec 08             	sub    $0x8,%esp
  801052:	ff 75 0c             	pushl  0xc(%ebp)
  801055:	50                   	push   %eax
  801056:	e8 5b ff ff ff       	call   800fb6 <fstat>
  80105b:	89 c6                	mov    %eax,%esi
	close(fd);
  80105d:	89 1c 24             	mov    %ebx,(%esp)
  801060:	e8 fd fb ff ff       	call   800c62 <close>
	return r;
  801065:	83 c4 10             	add    $0x10,%esp
  801068:	89 f0                	mov    %esi,%eax
}
  80106a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80106d:	5b                   	pop    %ebx
  80106e:	5e                   	pop    %esi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	89 c6                	mov    %eax,%esi
  801078:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80107a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801081:	75 12                	jne    801095 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	6a 01                	push   $0x1
  801088:	e8 b9 0e 00 00       	call   801f46 <ipc_find_env>
  80108d:	a3 00 40 80 00       	mov    %eax,0x804000
  801092:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801095:	6a 07                	push   $0x7
  801097:	68 00 50 80 00       	push   $0x805000
  80109c:	56                   	push   %esi
  80109d:	ff 35 00 40 80 00    	pushl  0x804000
  8010a3:	e8 3c 0e 00 00       	call   801ee4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8010a8:	83 c4 0c             	add    $0xc,%esp
  8010ab:	6a 00                	push   $0x0
  8010ad:	53                   	push   %ebx
  8010ae:	6a 00                	push   $0x0
  8010b0:	e8 b4 0d 00 00       	call   801e69 <ipc_recv>
}
  8010b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    

008010bc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8010c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8010cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8010d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010da:	b8 02 00 00 00       	mov    $0x2,%eax
  8010df:	e8 8d ff ff ff       	call   801071 <fsipc>
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8010f2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8010f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fc:	b8 06 00 00 00       	mov    $0x6,%eax
  801101:	e8 6b ff ff ff       	call   801071 <fsipc>
}
  801106:	c9                   	leave  
  801107:	c3                   	ret    

00801108 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	53                   	push   %ebx
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
  801115:	8b 40 0c             	mov    0xc(%eax),%eax
  801118:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80111d:	ba 00 00 00 00       	mov    $0x0,%edx
  801122:	b8 05 00 00 00       	mov    $0x5,%eax
  801127:	e8 45 ff ff ff       	call   801071 <fsipc>
  80112c:	85 c0                	test   %eax,%eax
  80112e:	78 2c                	js     80115c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801130:	83 ec 08             	sub    $0x8,%esp
  801133:	68 00 50 80 00       	push   $0x805000
  801138:	53                   	push   %ebx
  801139:	e8 5c f0 ff ff       	call   80019a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80113e:	a1 80 50 80 00       	mov    0x805080,%eax
  801143:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801149:	a1 84 50 80 00       	mov    0x805084,%eax
  80114e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80115c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115f:	c9                   	leave  
  801160:	c3                   	ret    

00801161 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	83 ec 0c             	sub    $0xc,%esp
  801167:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80116a:	8b 55 08             	mov    0x8(%ebp),%edx
  80116d:	8b 52 0c             	mov    0xc(%edx),%edx
  801170:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801176:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80117b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801180:	0f 47 c2             	cmova  %edx,%eax
  801183:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801188:	50                   	push   %eax
  801189:	ff 75 0c             	pushl  0xc(%ebp)
  80118c:	68 08 50 80 00       	push   $0x805008
  801191:	e8 96 f1 ff ff       	call   80032c <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801196:	ba 00 00 00 00       	mov    $0x0,%edx
  80119b:	b8 04 00 00 00       	mov    $0x4,%eax
  8011a0:	e8 cc fe ff ff       	call   801071 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8011a5:	c9                   	leave  
  8011a6:	c3                   	ret    

008011a7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	56                   	push   %esi
  8011ab:	53                   	push   %ebx
  8011ac:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8011af:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8011b5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8011ba:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8011c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c5:	b8 03 00 00 00       	mov    $0x3,%eax
  8011ca:	e8 a2 fe ff ff       	call   801071 <fsipc>
  8011cf:	89 c3                	mov    %eax,%ebx
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	78 4b                	js     801220 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8011d5:	39 c6                	cmp    %eax,%esi
  8011d7:	73 16                	jae    8011ef <devfile_read+0x48>
  8011d9:	68 a4 23 80 00       	push   $0x8023a4
  8011de:	68 ab 23 80 00       	push   $0x8023ab
  8011e3:	6a 7c                	push   $0x7c
  8011e5:	68 c0 23 80 00       	push   $0x8023c0
  8011ea:	e8 c6 05 00 00       	call   8017b5 <_panic>
	assert(r <= PGSIZE);
  8011ef:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8011f4:	7e 16                	jle    80120c <devfile_read+0x65>
  8011f6:	68 cb 23 80 00       	push   $0x8023cb
  8011fb:	68 ab 23 80 00       	push   $0x8023ab
  801200:	6a 7d                	push   $0x7d
  801202:	68 c0 23 80 00       	push   $0x8023c0
  801207:	e8 a9 05 00 00       	call   8017b5 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80120c:	83 ec 04             	sub    $0x4,%esp
  80120f:	50                   	push   %eax
  801210:	68 00 50 80 00       	push   $0x805000
  801215:	ff 75 0c             	pushl  0xc(%ebp)
  801218:	e8 0f f1 ff ff       	call   80032c <memmove>
	return r;
  80121d:	83 c4 10             	add    $0x10,%esp
}
  801220:	89 d8                	mov    %ebx,%eax
  801222:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801225:	5b                   	pop    %ebx
  801226:	5e                   	pop    %esi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	53                   	push   %ebx
  80122d:	83 ec 20             	sub    $0x20,%esp
  801230:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801233:	53                   	push   %ebx
  801234:	e8 28 ef ff ff       	call   800161 <strlen>
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801241:	7f 67                	jg     8012aa <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801249:	50                   	push   %eax
  80124a:	e8 9a f8 ff ff       	call   800ae9 <fd_alloc>
  80124f:	83 c4 10             	add    $0x10,%esp
		return r;
  801252:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801254:	85 c0                	test   %eax,%eax
  801256:	78 57                	js     8012af <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801258:	83 ec 08             	sub    $0x8,%esp
  80125b:	53                   	push   %ebx
  80125c:	68 00 50 80 00       	push   $0x805000
  801261:	e8 34 ef ff ff       	call   80019a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801266:	8b 45 0c             	mov    0xc(%ebp),%eax
  801269:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80126e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801271:	b8 01 00 00 00       	mov    $0x1,%eax
  801276:	e8 f6 fd ff ff       	call   801071 <fsipc>
  80127b:	89 c3                	mov    %eax,%ebx
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	85 c0                	test   %eax,%eax
  801282:	79 14                	jns    801298 <open+0x6f>
		fd_close(fd, 0);
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	6a 00                	push   $0x0
  801289:	ff 75 f4             	pushl  -0xc(%ebp)
  80128c:	e8 50 f9 ff ff       	call   800be1 <fd_close>
		return r;
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	89 da                	mov    %ebx,%edx
  801296:	eb 17                	jmp    8012af <open+0x86>
	}

	return fd2num(fd);
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	ff 75 f4             	pushl  -0xc(%ebp)
  80129e:	e8 1f f8 ff ff       	call   800ac2 <fd2num>
  8012a3:	89 c2                	mov    %eax,%edx
  8012a5:	83 c4 10             	add    $0x10,%esp
  8012a8:	eb 05                	jmp    8012af <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8012aa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8012af:	89 d0                	mov    %edx,%eax
  8012b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b4:	c9                   	leave  
  8012b5:	c3                   	ret    

008012b6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8012bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8012c6:	e8 a6 fd ff ff       	call   801071 <fsipc>
}
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	56                   	push   %esi
  8012d1:	53                   	push   %ebx
  8012d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8012d5:	83 ec 0c             	sub    $0xc,%esp
  8012d8:	ff 75 08             	pushl  0x8(%ebp)
  8012db:	e8 f2 f7 ff ff       	call   800ad2 <fd2data>
  8012e0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8012e2:	83 c4 08             	add    $0x8,%esp
  8012e5:	68 d7 23 80 00       	push   $0x8023d7
  8012ea:	53                   	push   %ebx
  8012eb:	e8 aa ee ff ff       	call   80019a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8012f0:	8b 46 04             	mov    0x4(%esi),%eax
  8012f3:	2b 06                	sub    (%esi),%eax
  8012f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8012fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801302:	00 00 00 
	stat->st_dev = &devpipe;
  801305:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80130c:	30 80 00 
	return 0;
}
  80130f:	b8 00 00 00 00       	mov    $0x0,%eax
  801314:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5d                   	pop    %ebp
  80131a:	c3                   	ret    

0080131b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	53                   	push   %ebx
  80131f:	83 ec 0c             	sub    $0xc,%esp
  801322:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801325:	53                   	push   %ebx
  801326:	6a 00                	push   $0x0
  801328:	e8 f5 f2 ff ff       	call   800622 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80132d:	89 1c 24             	mov    %ebx,(%esp)
  801330:	e8 9d f7 ff ff       	call   800ad2 <fd2data>
  801335:	83 c4 08             	add    $0x8,%esp
  801338:	50                   	push   %eax
  801339:	6a 00                	push   $0x0
  80133b:	e8 e2 f2 ff ff       	call   800622 <sys_page_unmap>
}
  801340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	57                   	push   %edi
  801349:	56                   	push   %esi
  80134a:	53                   	push   %ebx
  80134b:	83 ec 1c             	sub    $0x1c,%esp
  80134e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801351:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801353:	a1 04 40 80 00       	mov    0x804004,%eax
  801358:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80135e:	83 ec 0c             	sub    $0xc,%esp
  801361:	ff 75 e0             	pushl  -0x20(%ebp)
  801364:	e8 1f 0c 00 00       	call   801f88 <pageref>
  801369:	89 c3                	mov    %eax,%ebx
  80136b:	89 3c 24             	mov    %edi,(%esp)
  80136e:	e8 15 0c 00 00       	call   801f88 <pageref>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	39 c3                	cmp    %eax,%ebx
  801378:	0f 94 c1             	sete   %cl
  80137b:	0f b6 c9             	movzbl %cl,%ecx
  80137e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801381:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801387:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  80138d:	39 ce                	cmp    %ecx,%esi
  80138f:	74 1e                	je     8013af <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801391:	39 c3                	cmp    %eax,%ebx
  801393:	75 be                	jne    801353 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801395:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  80139b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80139e:	50                   	push   %eax
  80139f:	56                   	push   %esi
  8013a0:	68 de 23 80 00       	push   $0x8023de
  8013a5:	e8 e4 04 00 00       	call   80188e <cprintf>
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	eb a4                	jmp    801353 <_pipeisclosed+0xe>
	}
}
  8013af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b5:	5b                   	pop    %ebx
  8013b6:	5e                   	pop    %esi
  8013b7:	5f                   	pop    %edi
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	57                   	push   %edi
  8013be:	56                   	push   %esi
  8013bf:	53                   	push   %ebx
  8013c0:	83 ec 28             	sub    $0x28,%esp
  8013c3:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8013c6:	56                   	push   %esi
  8013c7:	e8 06 f7 ff ff       	call   800ad2 <fd2data>
  8013cc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8013d6:	eb 4b                	jmp    801423 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8013d8:	89 da                	mov    %ebx,%edx
  8013da:	89 f0                	mov    %esi,%eax
  8013dc:	e8 64 ff ff ff       	call   801345 <_pipeisclosed>
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	75 48                	jne    80142d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8013e5:	e8 94 f1 ff ff       	call   80057e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8013ea:	8b 43 04             	mov    0x4(%ebx),%eax
  8013ed:	8b 0b                	mov    (%ebx),%ecx
  8013ef:	8d 51 20             	lea    0x20(%ecx),%edx
  8013f2:	39 d0                	cmp    %edx,%eax
  8013f4:	73 e2                	jae    8013d8 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8013f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8013fd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801400:	89 c2                	mov    %eax,%edx
  801402:	c1 fa 1f             	sar    $0x1f,%edx
  801405:	89 d1                	mov    %edx,%ecx
  801407:	c1 e9 1b             	shr    $0x1b,%ecx
  80140a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80140d:	83 e2 1f             	and    $0x1f,%edx
  801410:	29 ca                	sub    %ecx,%edx
  801412:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801416:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80141a:	83 c0 01             	add    $0x1,%eax
  80141d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801420:	83 c7 01             	add    $0x1,%edi
  801423:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801426:	75 c2                	jne    8013ea <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801428:	8b 45 10             	mov    0x10(%ebp),%eax
  80142b:	eb 05                	jmp    801432 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80142d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801432:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801435:	5b                   	pop    %ebx
  801436:	5e                   	pop    %esi
  801437:	5f                   	pop    %edi
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	57                   	push   %edi
  80143e:	56                   	push   %esi
  80143f:	53                   	push   %ebx
  801440:	83 ec 18             	sub    $0x18,%esp
  801443:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801446:	57                   	push   %edi
  801447:	e8 86 f6 ff ff       	call   800ad2 <fd2data>
  80144c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	bb 00 00 00 00       	mov    $0x0,%ebx
  801456:	eb 3d                	jmp    801495 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801458:	85 db                	test   %ebx,%ebx
  80145a:	74 04                	je     801460 <devpipe_read+0x26>
				return i;
  80145c:	89 d8                	mov    %ebx,%eax
  80145e:	eb 44                	jmp    8014a4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801460:	89 f2                	mov    %esi,%edx
  801462:	89 f8                	mov    %edi,%eax
  801464:	e8 dc fe ff ff       	call   801345 <_pipeisclosed>
  801469:	85 c0                	test   %eax,%eax
  80146b:	75 32                	jne    80149f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80146d:	e8 0c f1 ff ff       	call   80057e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801472:	8b 06                	mov    (%esi),%eax
  801474:	3b 46 04             	cmp    0x4(%esi),%eax
  801477:	74 df                	je     801458 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801479:	99                   	cltd   
  80147a:	c1 ea 1b             	shr    $0x1b,%edx
  80147d:	01 d0                	add    %edx,%eax
  80147f:	83 e0 1f             	and    $0x1f,%eax
  801482:	29 d0                	sub    %edx,%eax
  801484:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801489:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80148f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801492:	83 c3 01             	add    $0x1,%ebx
  801495:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801498:	75 d8                	jne    801472 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80149a:	8b 45 10             	mov    0x10(%ebp),%eax
  80149d:	eb 05                	jmp    8014a4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80149f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8014a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014a7:	5b                   	pop    %ebx
  8014a8:	5e                   	pop    %esi
  8014a9:	5f                   	pop    %edi
  8014aa:	5d                   	pop    %ebp
  8014ab:	c3                   	ret    

008014ac <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	56                   	push   %esi
  8014b0:	53                   	push   %ebx
  8014b1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8014b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	e8 2c f6 ff ff       	call   800ae9 <fd_alloc>
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	89 c2                	mov    %eax,%edx
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	0f 88 2c 01 00 00    	js     8015f6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014ca:	83 ec 04             	sub    $0x4,%esp
  8014cd:	68 07 04 00 00       	push   $0x407
  8014d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d5:	6a 00                	push   $0x0
  8014d7:	e8 c1 f0 ff ff       	call   80059d <sys_page_alloc>
  8014dc:	83 c4 10             	add    $0x10,%esp
  8014df:	89 c2                	mov    %eax,%edx
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	0f 88 0d 01 00 00    	js     8015f6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8014e9:	83 ec 0c             	sub    $0xc,%esp
  8014ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	e8 f4 f5 ff ff       	call   800ae9 <fd_alloc>
  8014f5:	89 c3                	mov    %eax,%ebx
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	0f 88 e2 00 00 00    	js     8015e4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801502:	83 ec 04             	sub    $0x4,%esp
  801505:	68 07 04 00 00       	push   $0x407
  80150a:	ff 75 f0             	pushl  -0x10(%ebp)
  80150d:	6a 00                	push   $0x0
  80150f:	e8 89 f0 ff ff       	call   80059d <sys_page_alloc>
  801514:	89 c3                	mov    %eax,%ebx
  801516:	83 c4 10             	add    $0x10,%esp
  801519:	85 c0                	test   %eax,%eax
  80151b:	0f 88 c3 00 00 00    	js     8015e4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	ff 75 f4             	pushl  -0xc(%ebp)
  801527:	e8 a6 f5 ff ff       	call   800ad2 <fd2data>
  80152c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80152e:	83 c4 0c             	add    $0xc,%esp
  801531:	68 07 04 00 00       	push   $0x407
  801536:	50                   	push   %eax
  801537:	6a 00                	push   $0x0
  801539:	e8 5f f0 ff ff       	call   80059d <sys_page_alloc>
  80153e:	89 c3                	mov    %eax,%ebx
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	85 c0                	test   %eax,%eax
  801545:	0f 88 89 00 00 00    	js     8015d4 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80154b:	83 ec 0c             	sub    $0xc,%esp
  80154e:	ff 75 f0             	pushl  -0x10(%ebp)
  801551:	e8 7c f5 ff ff       	call   800ad2 <fd2data>
  801556:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80155d:	50                   	push   %eax
  80155e:	6a 00                	push   $0x0
  801560:	56                   	push   %esi
  801561:	6a 00                	push   $0x0
  801563:	e8 78 f0 ff ff       	call   8005e0 <sys_page_map>
  801568:	89 c3                	mov    %eax,%ebx
  80156a:	83 c4 20             	add    $0x20,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 55                	js     8015c6 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801571:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801577:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80157c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801586:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80158c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801591:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801594:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80159b:	83 ec 0c             	sub    $0xc,%esp
  80159e:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a1:	e8 1c f5 ff ff       	call   800ac2 <fd2num>
  8015a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015a9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8015ab:	83 c4 04             	add    $0x4,%esp
  8015ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8015b1:	e8 0c f5 ff ff       	call   800ac2 <fd2num>
  8015b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015b9:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c4:	eb 30                	jmp    8015f6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8015c6:	83 ec 08             	sub    $0x8,%esp
  8015c9:	56                   	push   %esi
  8015ca:	6a 00                	push   $0x0
  8015cc:	e8 51 f0 ff ff       	call   800622 <sys_page_unmap>
  8015d1:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8015da:	6a 00                	push   $0x0
  8015dc:	e8 41 f0 ff ff       	call   800622 <sys_page_unmap>
  8015e1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ea:	6a 00                	push   $0x0
  8015ec:	e8 31 f0 ff ff       	call   800622 <sys_page_unmap>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8015f6:	89 d0                	mov    %edx,%eax
  8015f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fb:	5b                   	pop    %ebx
  8015fc:	5e                   	pop    %esi
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    

008015ff <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801605:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801608:	50                   	push   %eax
  801609:	ff 75 08             	pushl  0x8(%ebp)
  80160c:	e8 27 f5 ff ff       	call   800b38 <fd_lookup>
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 18                	js     801630 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801618:	83 ec 0c             	sub    $0xc,%esp
  80161b:	ff 75 f4             	pushl  -0xc(%ebp)
  80161e:	e8 af f4 ff ff       	call   800ad2 <fd2data>
	return _pipeisclosed(fd, p);
  801623:	89 c2                	mov    %eax,%edx
  801625:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801628:	e8 18 fd ff ff       	call   801345 <_pipeisclosed>
  80162d:	83 c4 10             	add    $0x10,%esp
}
  801630:	c9                   	leave  
  801631:	c3                   	ret    

00801632 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801635:	b8 00 00 00 00       	mov    $0x0,%eax
  80163a:	5d                   	pop    %ebp
  80163b:	c3                   	ret    

0080163c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801642:	68 f6 23 80 00       	push   $0x8023f6
  801647:	ff 75 0c             	pushl  0xc(%ebp)
  80164a:	e8 4b eb ff ff       	call   80019a <strcpy>
	return 0;
}
  80164f:	b8 00 00 00 00       	mov    $0x0,%eax
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	57                   	push   %edi
  80165a:	56                   	push   %esi
  80165b:	53                   	push   %ebx
  80165c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801662:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801667:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80166d:	eb 2d                	jmp    80169c <devcons_write+0x46>
		m = n - tot;
  80166f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801672:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801674:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801677:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80167c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80167f:	83 ec 04             	sub    $0x4,%esp
  801682:	53                   	push   %ebx
  801683:	03 45 0c             	add    0xc(%ebp),%eax
  801686:	50                   	push   %eax
  801687:	57                   	push   %edi
  801688:	e8 9f ec ff ff       	call   80032c <memmove>
		sys_cputs(buf, m);
  80168d:	83 c4 08             	add    $0x8,%esp
  801690:	53                   	push   %ebx
  801691:	57                   	push   %edi
  801692:	e8 4a ee ff ff       	call   8004e1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801697:	01 de                	add    %ebx,%esi
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	89 f0                	mov    %esi,%eax
  80169e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8016a1:	72 cc                	jb     80166f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8016a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5f                   	pop    %edi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 08             	sub    $0x8,%esp
  8016b1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8016b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016ba:	74 2a                	je     8016e6 <devcons_read+0x3b>
  8016bc:	eb 05                	jmp    8016c3 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8016be:	e8 bb ee ff ff       	call   80057e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8016c3:	e8 37 ee ff ff       	call   8004ff <sys_cgetc>
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	74 f2                	je     8016be <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 16                	js     8016e6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8016d0:	83 f8 04             	cmp    $0x4,%eax
  8016d3:	74 0c                	je     8016e1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8016d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d8:	88 02                	mov    %al,(%edx)
	return 1;
  8016da:	b8 01 00 00 00       	mov    $0x1,%eax
  8016df:	eb 05                	jmp    8016e6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8016e1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8016f4:	6a 01                	push   $0x1
  8016f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8016f9:	50                   	push   %eax
  8016fa:	e8 e2 ed ff ff       	call   8004e1 <sys_cputs>
}
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	c9                   	leave  
  801703:	c3                   	ret    

00801704 <getchar>:

int
getchar(void)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80170a:	6a 01                	push   $0x1
  80170c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	6a 00                	push   $0x0
  801712:	e8 87 f6 ff ff       	call   800d9e <read>
	if (r < 0)
  801717:	83 c4 10             	add    $0x10,%esp
  80171a:	85 c0                	test   %eax,%eax
  80171c:	78 0f                	js     80172d <getchar+0x29>
		return r;
	if (r < 1)
  80171e:	85 c0                	test   %eax,%eax
  801720:	7e 06                	jle    801728 <getchar+0x24>
		return -E_EOF;
	return c;
  801722:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801726:	eb 05                	jmp    80172d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801728:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801735:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801738:	50                   	push   %eax
  801739:	ff 75 08             	pushl  0x8(%ebp)
  80173c:	e8 f7 f3 ff ff       	call   800b38 <fd_lookup>
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	85 c0                	test   %eax,%eax
  801746:	78 11                	js     801759 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801748:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801751:	39 10                	cmp    %edx,(%eax)
  801753:	0f 94 c0             	sete   %al
  801756:	0f b6 c0             	movzbl %al,%eax
}
  801759:	c9                   	leave  
  80175a:	c3                   	ret    

0080175b <opencons>:

int
opencons(void)
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801761:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801764:	50                   	push   %eax
  801765:	e8 7f f3 ff ff       	call   800ae9 <fd_alloc>
  80176a:	83 c4 10             	add    $0x10,%esp
		return r;
  80176d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 3e                	js     8017b1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801773:	83 ec 04             	sub    $0x4,%esp
  801776:	68 07 04 00 00       	push   $0x407
  80177b:	ff 75 f4             	pushl  -0xc(%ebp)
  80177e:	6a 00                	push   $0x0
  801780:	e8 18 ee ff ff       	call   80059d <sys_page_alloc>
  801785:	83 c4 10             	add    $0x10,%esp
		return r;
  801788:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 23                	js     8017b1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80178e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801794:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801797:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801799:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8017a3:	83 ec 0c             	sub    $0xc,%esp
  8017a6:	50                   	push   %eax
  8017a7:	e8 16 f3 ff ff       	call   800ac2 <fd2num>
  8017ac:	89 c2                	mov    %eax,%edx
  8017ae:	83 c4 10             	add    $0x10,%esp
}
  8017b1:	89 d0                	mov    %edx,%eax
  8017b3:	c9                   	leave  
  8017b4:	c3                   	ret    

008017b5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	56                   	push   %esi
  8017b9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8017ba:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8017bd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8017c3:	e8 97 ed ff ff       	call   80055f <sys_getenvid>
  8017c8:	83 ec 0c             	sub    $0xc,%esp
  8017cb:	ff 75 0c             	pushl  0xc(%ebp)
  8017ce:	ff 75 08             	pushl  0x8(%ebp)
  8017d1:	56                   	push   %esi
  8017d2:	50                   	push   %eax
  8017d3:	68 04 24 80 00       	push   $0x802404
  8017d8:	e8 b1 00 00 00       	call   80188e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8017dd:	83 c4 18             	add    $0x18,%esp
  8017e0:	53                   	push   %ebx
  8017e1:	ff 75 10             	pushl  0x10(%ebp)
  8017e4:	e8 54 00 00 00       	call   80183d <vcprintf>
	cprintf("\n");
  8017e9:	c7 04 24 ef 23 80 00 	movl   $0x8023ef,(%esp)
  8017f0:	e8 99 00 00 00       	call   80188e <cprintf>
  8017f5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8017f8:	cc                   	int3   
  8017f9:	eb fd                	jmp    8017f8 <_panic+0x43>

008017fb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 04             	sub    $0x4,%esp
  801802:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801805:	8b 13                	mov    (%ebx),%edx
  801807:	8d 42 01             	lea    0x1(%edx),%eax
  80180a:	89 03                	mov    %eax,(%ebx)
  80180c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80180f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801813:	3d ff 00 00 00       	cmp    $0xff,%eax
  801818:	75 1a                	jne    801834 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	68 ff 00 00 00       	push   $0xff
  801822:	8d 43 08             	lea    0x8(%ebx),%eax
  801825:	50                   	push   %eax
  801826:	e8 b6 ec ff ff       	call   8004e1 <sys_cputs>
		b->idx = 0;
  80182b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801831:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801834:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183b:	c9                   	leave  
  80183c:	c3                   	ret    

0080183d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801846:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80184d:	00 00 00 
	b.cnt = 0;
  801850:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801857:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80185a:	ff 75 0c             	pushl  0xc(%ebp)
  80185d:	ff 75 08             	pushl  0x8(%ebp)
  801860:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801866:	50                   	push   %eax
  801867:	68 fb 17 80 00       	push   $0x8017fb
  80186c:	e8 54 01 00 00       	call   8019c5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801871:	83 c4 08             	add    $0x8,%esp
  801874:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80187a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801880:	50                   	push   %eax
  801881:	e8 5b ec ff ff       	call   8004e1 <sys_cputs>

	return b.cnt;
}
  801886:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80188c:	c9                   	leave  
  80188d:	c3                   	ret    

0080188e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80188e:	55                   	push   %ebp
  80188f:	89 e5                	mov    %esp,%ebp
  801891:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801894:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801897:	50                   	push   %eax
  801898:	ff 75 08             	pushl  0x8(%ebp)
  80189b:	e8 9d ff ff ff       	call   80183d <vcprintf>
	va_end(ap);

	return cnt;
}
  8018a0:	c9                   	leave  
  8018a1:	c3                   	ret    

008018a2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
  8018a5:	57                   	push   %edi
  8018a6:	56                   	push   %esi
  8018a7:	53                   	push   %ebx
  8018a8:	83 ec 1c             	sub    $0x1c,%esp
  8018ab:	89 c7                	mov    %eax,%edi
  8018ad:	89 d6                	mov    %edx,%esi
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8018bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018c3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8018c6:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8018c9:	39 d3                	cmp    %edx,%ebx
  8018cb:	72 05                	jb     8018d2 <printnum+0x30>
  8018cd:	39 45 10             	cmp    %eax,0x10(%ebp)
  8018d0:	77 45                	ja     801917 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	ff 75 18             	pushl  0x18(%ebp)
  8018d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018db:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8018de:	53                   	push   %ebx
  8018df:	ff 75 10             	pushl  0x10(%ebp)
  8018e2:	83 ec 08             	sub    $0x8,%esp
  8018e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8018ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8018f1:	e8 da 06 00 00       	call   801fd0 <__udivdi3>
  8018f6:	83 c4 18             	add    $0x18,%esp
  8018f9:	52                   	push   %edx
  8018fa:	50                   	push   %eax
  8018fb:	89 f2                	mov    %esi,%edx
  8018fd:	89 f8                	mov    %edi,%eax
  8018ff:	e8 9e ff ff ff       	call   8018a2 <printnum>
  801904:	83 c4 20             	add    $0x20,%esp
  801907:	eb 18                	jmp    801921 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	56                   	push   %esi
  80190d:	ff 75 18             	pushl  0x18(%ebp)
  801910:	ff d7                	call   *%edi
  801912:	83 c4 10             	add    $0x10,%esp
  801915:	eb 03                	jmp    80191a <printnum+0x78>
  801917:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80191a:	83 eb 01             	sub    $0x1,%ebx
  80191d:	85 db                	test   %ebx,%ebx
  80191f:	7f e8                	jg     801909 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801921:	83 ec 08             	sub    $0x8,%esp
  801924:	56                   	push   %esi
  801925:	83 ec 04             	sub    $0x4,%esp
  801928:	ff 75 e4             	pushl  -0x1c(%ebp)
  80192b:	ff 75 e0             	pushl  -0x20(%ebp)
  80192e:	ff 75 dc             	pushl  -0x24(%ebp)
  801931:	ff 75 d8             	pushl  -0x28(%ebp)
  801934:	e8 c7 07 00 00       	call   802100 <__umoddi3>
  801939:	83 c4 14             	add    $0x14,%esp
  80193c:	0f be 80 27 24 80 00 	movsbl 0x802427(%eax),%eax
  801943:	50                   	push   %eax
  801944:	ff d7                	call   *%edi
}
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80194c:	5b                   	pop    %ebx
  80194d:	5e                   	pop    %esi
  80194e:	5f                   	pop    %edi
  80194f:	5d                   	pop    %ebp
  801950:	c3                   	ret    

00801951 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801954:	83 fa 01             	cmp    $0x1,%edx
  801957:	7e 0e                	jle    801967 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801959:	8b 10                	mov    (%eax),%edx
  80195b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80195e:	89 08                	mov    %ecx,(%eax)
  801960:	8b 02                	mov    (%edx),%eax
  801962:	8b 52 04             	mov    0x4(%edx),%edx
  801965:	eb 22                	jmp    801989 <getuint+0x38>
	else if (lflag)
  801967:	85 d2                	test   %edx,%edx
  801969:	74 10                	je     80197b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80196b:	8b 10                	mov    (%eax),%edx
  80196d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801970:	89 08                	mov    %ecx,(%eax)
  801972:	8b 02                	mov    (%edx),%eax
  801974:	ba 00 00 00 00       	mov    $0x0,%edx
  801979:	eb 0e                	jmp    801989 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80197b:	8b 10                	mov    (%eax),%edx
  80197d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801980:	89 08                	mov    %ecx,(%eax)
  801982:	8b 02                	mov    (%edx),%eax
  801984:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    

0080198b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801991:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801995:	8b 10                	mov    (%eax),%edx
  801997:	3b 50 04             	cmp    0x4(%eax),%edx
  80199a:	73 0a                	jae    8019a6 <sprintputch+0x1b>
		*b->buf++ = ch;
  80199c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80199f:	89 08                	mov    %ecx,(%eax)
  8019a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a4:	88 02                	mov    %al,(%edx)
}
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8019ae:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8019b1:	50                   	push   %eax
  8019b2:	ff 75 10             	pushl  0x10(%ebp)
  8019b5:	ff 75 0c             	pushl  0xc(%ebp)
  8019b8:	ff 75 08             	pushl  0x8(%ebp)
  8019bb:	e8 05 00 00 00       	call   8019c5 <vprintfmt>
	va_end(ap);
}
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	c9                   	leave  
  8019c4:	c3                   	ret    

008019c5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	57                   	push   %edi
  8019c9:	56                   	push   %esi
  8019ca:	53                   	push   %ebx
  8019cb:	83 ec 2c             	sub    $0x2c,%esp
  8019ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019d4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8019d7:	eb 12                	jmp    8019eb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	0f 84 89 03 00 00    	je     801d6a <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	53                   	push   %ebx
  8019e5:	50                   	push   %eax
  8019e6:	ff d6                	call   *%esi
  8019e8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8019eb:	83 c7 01             	add    $0x1,%edi
  8019ee:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019f2:	83 f8 25             	cmp    $0x25,%eax
  8019f5:	75 e2                	jne    8019d9 <vprintfmt+0x14>
  8019f7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8019fb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801a02:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801a09:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801a10:	ba 00 00 00 00       	mov    $0x0,%edx
  801a15:	eb 07                	jmp    801a1e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a17:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801a1a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a1e:	8d 47 01             	lea    0x1(%edi),%eax
  801a21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a24:	0f b6 07             	movzbl (%edi),%eax
  801a27:	0f b6 c8             	movzbl %al,%ecx
  801a2a:	83 e8 23             	sub    $0x23,%eax
  801a2d:	3c 55                	cmp    $0x55,%al
  801a2f:	0f 87 1a 03 00 00    	ja     801d4f <vprintfmt+0x38a>
  801a35:	0f b6 c0             	movzbl %al,%eax
  801a38:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  801a3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801a42:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801a46:	eb d6                	jmp    801a1e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a50:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801a53:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801a56:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801a5a:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801a5d:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801a60:	83 fa 09             	cmp    $0x9,%edx
  801a63:	77 39                	ja     801a9e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801a65:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801a68:	eb e9                	jmp    801a53 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801a6a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6d:	8d 48 04             	lea    0x4(%eax),%ecx
  801a70:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801a73:	8b 00                	mov    (%eax),%eax
  801a75:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a7b:	eb 27                	jmp    801aa4 <vprintfmt+0xdf>
  801a7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a80:	85 c0                	test   %eax,%eax
  801a82:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a87:	0f 49 c8             	cmovns %eax,%ecx
  801a8a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a90:	eb 8c                	jmp    801a1e <vprintfmt+0x59>
  801a92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a95:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801a9c:	eb 80                	jmp    801a1e <vprintfmt+0x59>
  801a9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801aa1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801aa4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801aa8:	0f 89 70 ff ff ff    	jns    801a1e <vprintfmt+0x59>
				width = precision, precision = -1;
  801aae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801ab1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ab4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801abb:	e9 5e ff ff ff       	jmp    801a1e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801ac0:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ac3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801ac6:	e9 53 ff ff ff       	jmp    801a1e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801acb:	8b 45 14             	mov    0x14(%ebp),%eax
  801ace:	8d 50 04             	lea    0x4(%eax),%edx
  801ad1:	89 55 14             	mov    %edx,0x14(%ebp)
  801ad4:	83 ec 08             	sub    $0x8,%esp
  801ad7:	53                   	push   %ebx
  801ad8:	ff 30                	pushl  (%eax)
  801ada:	ff d6                	call   *%esi
			break;
  801adc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801adf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801ae2:	e9 04 ff ff ff       	jmp    8019eb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801ae7:	8b 45 14             	mov    0x14(%ebp),%eax
  801aea:	8d 50 04             	lea    0x4(%eax),%edx
  801aed:	89 55 14             	mov    %edx,0x14(%ebp)
  801af0:	8b 00                	mov    (%eax),%eax
  801af2:	99                   	cltd   
  801af3:	31 d0                	xor    %edx,%eax
  801af5:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801af7:	83 f8 0f             	cmp    $0xf,%eax
  801afa:	7f 0b                	jg     801b07 <vprintfmt+0x142>
  801afc:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  801b03:	85 d2                	test   %edx,%edx
  801b05:	75 18                	jne    801b1f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801b07:	50                   	push   %eax
  801b08:	68 3f 24 80 00       	push   $0x80243f
  801b0d:	53                   	push   %ebx
  801b0e:	56                   	push   %esi
  801b0f:	e8 94 fe ff ff       	call   8019a8 <printfmt>
  801b14:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b17:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801b1a:	e9 cc fe ff ff       	jmp    8019eb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801b1f:	52                   	push   %edx
  801b20:	68 bd 23 80 00       	push   $0x8023bd
  801b25:	53                   	push   %ebx
  801b26:	56                   	push   %esi
  801b27:	e8 7c fe ff ff       	call   8019a8 <printfmt>
  801b2c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b32:	e9 b4 fe ff ff       	jmp    8019eb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801b37:	8b 45 14             	mov    0x14(%ebp),%eax
  801b3a:	8d 50 04             	lea    0x4(%eax),%edx
  801b3d:	89 55 14             	mov    %edx,0x14(%ebp)
  801b40:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801b42:	85 ff                	test   %edi,%edi
  801b44:	b8 38 24 80 00       	mov    $0x802438,%eax
  801b49:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801b4c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801b50:	0f 8e 94 00 00 00    	jle    801bea <vprintfmt+0x225>
  801b56:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801b5a:	0f 84 98 00 00 00    	je     801bf8 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801b60:	83 ec 08             	sub    $0x8,%esp
  801b63:	ff 75 d0             	pushl  -0x30(%ebp)
  801b66:	57                   	push   %edi
  801b67:	e8 0d e6 ff ff       	call   800179 <strnlen>
  801b6c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801b6f:	29 c1                	sub    %eax,%ecx
  801b71:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801b74:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801b77:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801b7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b7e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801b81:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b83:	eb 0f                	jmp    801b94 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801b85:	83 ec 08             	sub    $0x8,%esp
  801b88:	53                   	push   %ebx
  801b89:	ff 75 e0             	pushl  -0x20(%ebp)
  801b8c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b8e:	83 ef 01             	sub    $0x1,%edi
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	85 ff                	test   %edi,%edi
  801b96:	7f ed                	jg     801b85 <vprintfmt+0x1c0>
  801b98:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801b9b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801b9e:	85 c9                	test   %ecx,%ecx
  801ba0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba5:	0f 49 c1             	cmovns %ecx,%eax
  801ba8:	29 c1                	sub    %eax,%ecx
  801baa:	89 75 08             	mov    %esi,0x8(%ebp)
  801bad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801bb0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801bb3:	89 cb                	mov    %ecx,%ebx
  801bb5:	eb 4d                	jmp    801c04 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801bb7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801bbb:	74 1b                	je     801bd8 <vprintfmt+0x213>
  801bbd:	0f be c0             	movsbl %al,%eax
  801bc0:	83 e8 20             	sub    $0x20,%eax
  801bc3:	83 f8 5e             	cmp    $0x5e,%eax
  801bc6:	76 10                	jbe    801bd8 <vprintfmt+0x213>
					putch('?', putdat);
  801bc8:	83 ec 08             	sub    $0x8,%esp
  801bcb:	ff 75 0c             	pushl  0xc(%ebp)
  801bce:	6a 3f                	push   $0x3f
  801bd0:	ff 55 08             	call   *0x8(%ebp)
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	eb 0d                	jmp    801be5 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801bd8:	83 ec 08             	sub    $0x8,%esp
  801bdb:	ff 75 0c             	pushl  0xc(%ebp)
  801bde:	52                   	push   %edx
  801bdf:	ff 55 08             	call   *0x8(%ebp)
  801be2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801be5:	83 eb 01             	sub    $0x1,%ebx
  801be8:	eb 1a                	jmp    801c04 <vprintfmt+0x23f>
  801bea:	89 75 08             	mov    %esi,0x8(%ebp)
  801bed:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801bf0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801bf3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801bf6:	eb 0c                	jmp    801c04 <vprintfmt+0x23f>
  801bf8:	89 75 08             	mov    %esi,0x8(%ebp)
  801bfb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801bfe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801c01:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801c04:	83 c7 01             	add    $0x1,%edi
  801c07:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801c0b:	0f be d0             	movsbl %al,%edx
  801c0e:	85 d2                	test   %edx,%edx
  801c10:	74 23                	je     801c35 <vprintfmt+0x270>
  801c12:	85 f6                	test   %esi,%esi
  801c14:	78 a1                	js     801bb7 <vprintfmt+0x1f2>
  801c16:	83 ee 01             	sub    $0x1,%esi
  801c19:	79 9c                	jns    801bb7 <vprintfmt+0x1f2>
  801c1b:	89 df                	mov    %ebx,%edi
  801c1d:	8b 75 08             	mov    0x8(%ebp),%esi
  801c20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c23:	eb 18                	jmp    801c3d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801c25:	83 ec 08             	sub    $0x8,%esp
  801c28:	53                   	push   %ebx
  801c29:	6a 20                	push   $0x20
  801c2b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801c2d:	83 ef 01             	sub    $0x1,%edi
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	eb 08                	jmp    801c3d <vprintfmt+0x278>
  801c35:	89 df                	mov    %ebx,%edi
  801c37:	8b 75 08             	mov    0x8(%ebp),%esi
  801c3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c3d:	85 ff                	test   %edi,%edi
  801c3f:	7f e4                	jg     801c25 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c44:	e9 a2 fd ff ff       	jmp    8019eb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801c49:	83 fa 01             	cmp    $0x1,%edx
  801c4c:	7e 16                	jle    801c64 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801c4e:	8b 45 14             	mov    0x14(%ebp),%eax
  801c51:	8d 50 08             	lea    0x8(%eax),%edx
  801c54:	89 55 14             	mov    %edx,0x14(%ebp)
  801c57:	8b 50 04             	mov    0x4(%eax),%edx
  801c5a:	8b 00                	mov    (%eax),%eax
  801c5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c5f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801c62:	eb 32                	jmp    801c96 <vprintfmt+0x2d1>
	else if (lflag)
  801c64:	85 d2                	test   %edx,%edx
  801c66:	74 18                	je     801c80 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801c68:	8b 45 14             	mov    0x14(%ebp),%eax
  801c6b:	8d 50 04             	lea    0x4(%eax),%edx
  801c6e:	89 55 14             	mov    %edx,0x14(%ebp)
  801c71:	8b 00                	mov    (%eax),%eax
  801c73:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c76:	89 c1                	mov    %eax,%ecx
  801c78:	c1 f9 1f             	sar    $0x1f,%ecx
  801c7b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801c7e:	eb 16                	jmp    801c96 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801c80:	8b 45 14             	mov    0x14(%ebp),%eax
  801c83:	8d 50 04             	lea    0x4(%eax),%edx
  801c86:	89 55 14             	mov    %edx,0x14(%ebp)
  801c89:	8b 00                	mov    (%eax),%eax
  801c8b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c8e:	89 c1                	mov    %eax,%ecx
  801c90:	c1 f9 1f             	sar    $0x1f,%ecx
  801c93:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801c96:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801c99:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801c9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ca1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ca5:	79 74                	jns    801d1b <vprintfmt+0x356>
				putch('-', putdat);
  801ca7:	83 ec 08             	sub    $0x8,%esp
  801caa:	53                   	push   %ebx
  801cab:	6a 2d                	push   $0x2d
  801cad:	ff d6                	call   *%esi
				num = -(long long) num;
  801caf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801cb2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801cb5:	f7 d8                	neg    %eax
  801cb7:	83 d2 00             	adc    $0x0,%edx
  801cba:	f7 da                	neg    %edx
  801cbc:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801cbf:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801cc4:	eb 55                	jmp    801d1b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801cc6:	8d 45 14             	lea    0x14(%ebp),%eax
  801cc9:	e8 83 fc ff ff       	call   801951 <getuint>
			base = 10;
  801cce:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801cd3:	eb 46                	jmp    801d1b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801cd5:	8d 45 14             	lea    0x14(%ebp),%eax
  801cd8:	e8 74 fc ff ff       	call   801951 <getuint>
			base = 8;
  801cdd:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801ce2:	eb 37                	jmp    801d1b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801ce4:	83 ec 08             	sub    $0x8,%esp
  801ce7:	53                   	push   %ebx
  801ce8:	6a 30                	push   $0x30
  801cea:	ff d6                	call   *%esi
			putch('x', putdat);
  801cec:	83 c4 08             	add    $0x8,%esp
  801cef:	53                   	push   %ebx
  801cf0:	6a 78                	push   $0x78
  801cf2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801cf4:	8b 45 14             	mov    0x14(%ebp),%eax
  801cf7:	8d 50 04             	lea    0x4(%eax),%edx
  801cfa:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801cfd:	8b 00                	mov    (%eax),%eax
  801cff:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801d04:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801d07:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801d0c:	eb 0d                	jmp    801d1b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801d0e:	8d 45 14             	lea    0x14(%ebp),%eax
  801d11:	e8 3b fc ff ff       	call   801951 <getuint>
			base = 16;
  801d16:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801d1b:	83 ec 0c             	sub    $0xc,%esp
  801d1e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801d22:	57                   	push   %edi
  801d23:	ff 75 e0             	pushl  -0x20(%ebp)
  801d26:	51                   	push   %ecx
  801d27:	52                   	push   %edx
  801d28:	50                   	push   %eax
  801d29:	89 da                	mov    %ebx,%edx
  801d2b:	89 f0                	mov    %esi,%eax
  801d2d:	e8 70 fb ff ff       	call   8018a2 <printnum>
			break;
  801d32:	83 c4 20             	add    $0x20,%esp
  801d35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d38:	e9 ae fc ff ff       	jmp    8019eb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801d3d:	83 ec 08             	sub    $0x8,%esp
  801d40:	53                   	push   %ebx
  801d41:	51                   	push   %ecx
  801d42:	ff d6                	call   *%esi
			break;
  801d44:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801d4a:	e9 9c fc ff ff       	jmp    8019eb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801d4f:	83 ec 08             	sub    $0x8,%esp
  801d52:	53                   	push   %ebx
  801d53:	6a 25                	push   $0x25
  801d55:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	eb 03                	jmp    801d5f <vprintfmt+0x39a>
  801d5c:	83 ef 01             	sub    $0x1,%edi
  801d5f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801d63:	75 f7                	jne    801d5c <vprintfmt+0x397>
  801d65:	e9 81 fc ff ff       	jmp    8019eb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5f                   	pop    %edi
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    

00801d72 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	83 ec 18             	sub    $0x18,%esp
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801d7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d81:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801d85:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801d88:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801d8f:	85 c0                	test   %eax,%eax
  801d91:	74 26                	je     801db9 <vsnprintf+0x47>
  801d93:	85 d2                	test   %edx,%edx
  801d95:	7e 22                	jle    801db9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801d97:	ff 75 14             	pushl  0x14(%ebp)
  801d9a:	ff 75 10             	pushl  0x10(%ebp)
  801d9d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801da0:	50                   	push   %eax
  801da1:	68 8b 19 80 00       	push   $0x80198b
  801da6:	e8 1a fc ff ff       	call   8019c5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801dab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801dae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	eb 05                	jmp    801dbe <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801db9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801dc6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801dc9:	50                   	push   %eax
  801dca:	ff 75 10             	pushl  0x10(%ebp)
  801dcd:	ff 75 0c             	pushl  0xc(%ebp)
  801dd0:	ff 75 08             	pushl  0x8(%ebp)
  801dd3:	e8 9a ff ff ff       	call   801d72 <vsnprintf>
	va_end(ap);

	return rc;
}
  801dd8:	c9                   	leave  
  801dd9:	c3                   	ret    

00801dda <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dda:	55                   	push   %ebp
  801ddb:	89 e5                	mov    %esp,%ebp
  801ddd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801de0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801de7:	75 2a                	jne    801e13 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801de9:	83 ec 04             	sub    $0x4,%esp
  801dec:	6a 07                	push   $0x7
  801dee:	68 00 f0 bf ee       	push   $0xeebff000
  801df3:	6a 00                	push   $0x0
  801df5:	e8 a3 e7 ff ff       	call   80059d <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	79 12                	jns    801e13 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801e01:	50                   	push   %eax
  801e02:	68 20 27 80 00       	push   $0x802720
  801e07:	6a 23                	push   $0x23
  801e09:	68 24 27 80 00       	push   $0x802724
  801e0e:	e8 a2 f9 ff ff       	call   8017b5 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e13:	8b 45 08             	mov    0x8(%ebp),%eax
  801e16:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e1b:	83 ec 08             	sub    $0x8,%esp
  801e1e:	68 45 1e 80 00       	push   $0x801e45
  801e23:	6a 00                	push   $0x0
  801e25:	e8 be e8 ff ff       	call   8006e8 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	79 12                	jns    801e43 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e31:	50                   	push   %eax
  801e32:	68 20 27 80 00       	push   $0x802720
  801e37:	6a 2c                	push   $0x2c
  801e39:	68 24 27 80 00       	push   $0x802724
  801e3e:	e8 72 f9 ff ff       	call   8017b5 <_panic>
	}
}
  801e43:	c9                   	leave  
  801e44:	c3                   	ret    

00801e45 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e45:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e46:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e4b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e4d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e50:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e54:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e59:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e5d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e5f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e62:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e63:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e66:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e67:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e68:	c3                   	ret    

00801e69 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	56                   	push   %esi
  801e6d:	53                   	push   %ebx
  801e6e:	8b 75 08             	mov    0x8(%ebp),%esi
  801e71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e77:	85 c0                	test   %eax,%eax
  801e79:	75 12                	jne    801e8d <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e7b:	83 ec 0c             	sub    $0xc,%esp
  801e7e:	68 00 00 c0 ee       	push   $0xeec00000
  801e83:	e8 c5 e8 ff ff       	call   80074d <sys_ipc_recv>
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	eb 0c                	jmp    801e99 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e8d:	83 ec 0c             	sub    $0xc,%esp
  801e90:	50                   	push   %eax
  801e91:	e8 b7 e8 ff ff       	call   80074d <sys_ipc_recv>
  801e96:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e99:	85 f6                	test   %esi,%esi
  801e9b:	0f 95 c1             	setne  %cl
  801e9e:	85 db                	test   %ebx,%ebx
  801ea0:	0f 95 c2             	setne  %dl
  801ea3:	84 d1                	test   %dl,%cl
  801ea5:	74 09                	je     801eb0 <ipc_recv+0x47>
  801ea7:	89 c2                	mov    %eax,%edx
  801ea9:	c1 ea 1f             	shr    $0x1f,%edx
  801eac:	84 d2                	test   %dl,%dl
  801eae:	75 2d                	jne    801edd <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801eb0:	85 f6                	test   %esi,%esi
  801eb2:	74 0d                	je     801ec1 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801eb4:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb9:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801ebf:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801ec1:	85 db                	test   %ebx,%ebx
  801ec3:	74 0d                	je     801ed2 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801ec5:	a1 04 40 80 00       	mov    0x804004,%eax
  801eca:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801ed0:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ed2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ed7:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801edd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee0:	5b                   	pop    %ebx
  801ee1:	5e                   	pop    %esi
  801ee2:	5d                   	pop    %ebp
  801ee3:	c3                   	ret    

00801ee4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	57                   	push   %edi
  801ee8:	56                   	push   %esi
  801ee9:	53                   	push   %ebx
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ef6:	85 db                	test   %ebx,%ebx
  801ef8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801efd:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f00:	ff 75 14             	pushl  0x14(%ebp)
  801f03:	53                   	push   %ebx
  801f04:	56                   	push   %esi
  801f05:	57                   	push   %edi
  801f06:	e8 1f e8 ff ff       	call   80072a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801f0b:	89 c2                	mov    %eax,%edx
  801f0d:	c1 ea 1f             	shr    $0x1f,%edx
  801f10:	83 c4 10             	add    $0x10,%esp
  801f13:	84 d2                	test   %dl,%dl
  801f15:	74 17                	je     801f2e <ipc_send+0x4a>
  801f17:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1a:	74 12                	je     801f2e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f1c:	50                   	push   %eax
  801f1d:	68 32 27 80 00       	push   $0x802732
  801f22:	6a 47                	push   $0x47
  801f24:	68 40 27 80 00       	push   $0x802740
  801f29:	e8 87 f8 ff ff       	call   8017b5 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f2e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f31:	75 07                	jne    801f3a <ipc_send+0x56>
			sys_yield();
  801f33:	e8 46 e6 ff ff       	call   80057e <sys_yield>
  801f38:	eb c6                	jmp    801f00 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	75 c2                	jne    801f00 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f41:	5b                   	pop    %ebx
  801f42:	5e                   	pop    %esi
  801f43:	5f                   	pop    %edi
  801f44:	5d                   	pop    %ebp
  801f45:	c3                   	ret    

00801f46 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f4c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f51:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801f57:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f5d:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f63:	39 ca                	cmp    %ecx,%edx
  801f65:	75 10                	jne    801f77 <ipc_find_env+0x31>
			return envs[i].env_id;
  801f67:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801f6d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f72:	8b 40 7c             	mov    0x7c(%eax),%eax
  801f75:	eb 0f                	jmp    801f86 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f77:	83 c0 01             	add    $0x1,%eax
  801f7a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f7f:	75 d0                	jne    801f51 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8e:	89 d0                	mov    %edx,%eax
  801f90:	c1 e8 16             	shr    $0x16,%eax
  801f93:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f9a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f9f:	f6 c1 01             	test   $0x1,%cl
  801fa2:	74 1d                	je     801fc1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fa4:	c1 ea 0c             	shr    $0xc,%edx
  801fa7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fae:	f6 c2 01             	test   $0x1,%dl
  801fb1:	74 0e                	je     801fc1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fb3:	c1 ea 0c             	shr    $0xc,%edx
  801fb6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fbd:	ef 
  801fbe:	0f b7 c0             	movzwl %ax,%eax
}
  801fc1:	5d                   	pop    %ebp
  801fc2:	c3                   	ret    
  801fc3:	66 90                	xchg   %ax,%ax
  801fc5:	66 90                	xchg   %ax,%ax
  801fc7:	66 90                	xchg   %ax,%ax
  801fc9:	66 90                	xchg   %ax,%ax
  801fcb:	66 90                	xchg   %ax,%ax
  801fcd:	66 90                	xchg   %ax,%ax
  801fcf:	90                   	nop

00801fd0 <__udivdi3>:
  801fd0:	55                   	push   %ebp
  801fd1:	57                   	push   %edi
  801fd2:	56                   	push   %esi
  801fd3:	53                   	push   %ebx
  801fd4:	83 ec 1c             	sub    $0x1c,%esp
  801fd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fe3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fe7:	85 f6                	test   %esi,%esi
  801fe9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fed:	89 ca                	mov    %ecx,%edx
  801fef:	89 f8                	mov    %edi,%eax
  801ff1:	75 3d                	jne    802030 <__udivdi3+0x60>
  801ff3:	39 cf                	cmp    %ecx,%edi
  801ff5:	0f 87 c5 00 00 00    	ja     8020c0 <__udivdi3+0xf0>
  801ffb:	85 ff                	test   %edi,%edi
  801ffd:	89 fd                	mov    %edi,%ebp
  801fff:	75 0b                	jne    80200c <__udivdi3+0x3c>
  802001:	b8 01 00 00 00       	mov    $0x1,%eax
  802006:	31 d2                	xor    %edx,%edx
  802008:	f7 f7                	div    %edi
  80200a:	89 c5                	mov    %eax,%ebp
  80200c:	89 c8                	mov    %ecx,%eax
  80200e:	31 d2                	xor    %edx,%edx
  802010:	f7 f5                	div    %ebp
  802012:	89 c1                	mov    %eax,%ecx
  802014:	89 d8                	mov    %ebx,%eax
  802016:	89 cf                	mov    %ecx,%edi
  802018:	f7 f5                	div    %ebp
  80201a:	89 c3                	mov    %eax,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	39 ce                	cmp    %ecx,%esi
  802032:	77 74                	ja     8020a8 <__udivdi3+0xd8>
  802034:	0f bd fe             	bsr    %esi,%edi
  802037:	83 f7 1f             	xor    $0x1f,%edi
  80203a:	0f 84 98 00 00 00    	je     8020d8 <__udivdi3+0x108>
  802040:	bb 20 00 00 00       	mov    $0x20,%ebx
  802045:	89 f9                	mov    %edi,%ecx
  802047:	89 c5                	mov    %eax,%ebp
  802049:	29 fb                	sub    %edi,%ebx
  80204b:	d3 e6                	shl    %cl,%esi
  80204d:	89 d9                	mov    %ebx,%ecx
  80204f:	d3 ed                	shr    %cl,%ebp
  802051:	89 f9                	mov    %edi,%ecx
  802053:	d3 e0                	shl    %cl,%eax
  802055:	09 ee                	or     %ebp,%esi
  802057:	89 d9                	mov    %ebx,%ecx
  802059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80205d:	89 d5                	mov    %edx,%ebp
  80205f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802063:	d3 ed                	shr    %cl,%ebp
  802065:	89 f9                	mov    %edi,%ecx
  802067:	d3 e2                	shl    %cl,%edx
  802069:	89 d9                	mov    %ebx,%ecx
  80206b:	d3 e8                	shr    %cl,%eax
  80206d:	09 c2                	or     %eax,%edx
  80206f:	89 d0                	mov    %edx,%eax
  802071:	89 ea                	mov    %ebp,%edx
  802073:	f7 f6                	div    %esi
  802075:	89 d5                	mov    %edx,%ebp
  802077:	89 c3                	mov    %eax,%ebx
  802079:	f7 64 24 0c          	mull   0xc(%esp)
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	72 10                	jb     802091 <__udivdi3+0xc1>
  802081:	8b 74 24 08          	mov    0x8(%esp),%esi
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e6                	shl    %cl,%esi
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	73 07                	jae    802094 <__udivdi3+0xc4>
  80208d:	39 d5                	cmp    %edx,%ebp
  80208f:	75 03                	jne    802094 <__udivdi3+0xc4>
  802091:	83 eb 01             	sub    $0x1,%ebx
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 d8                	mov    %ebx,%eax
  802098:	89 fa                	mov    %edi,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	31 ff                	xor    %edi,%edi
  8020aa:	31 db                	xor    %ebx,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 d8                	mov    %ebx,%eax
  8020c2:	f7 f7                	div    %edi
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 fa                	mov    %edi,%edx
  8020cc:	83 c4 1c             	add    $0x1c,%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    
  8020d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020d8:	39 ce                	cmp    %ecx,%esi
  8020da:	72 0c                	jb     8020e8 <__udivdi3+0x118>
  8020dc:	31 db                	xor    %ebx,%ebx
  8020de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020e2:	0f 87 34 ff ff ff    	ja     80201c <__udivdi3+0x4c>
  8020e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ed:	e9 2a ff ff ff       	jmp    80201c <__udivdi3+0x4c>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80210b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80210f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 d2                	test   %edx,%edx
  802119:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f3                	mov    %esi,%ebx
  802123:	89 3c 24             	mov    %edi,(%esp)
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	75 1c                	jne    802148 <__umoddi3+0x48>
  80212c:	39 f7                	cmp    %esi,%edi
  80212e:	76 50                	jbe    802180 <__umoddi3+0x80>
  802130:	89 c8                	mov    %ecx,%eax
  802132:	89 f2                	mov    %esi,%edx
  802134:	f7 f7                	div    %edi
  802136:	89 d0                	mov    %edx,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	77 52                	ja     8021a0 <__umoddi3+0xa0>
  80214e:	0f bd ea             	bsr    %edx,%ebp
  802151:	83 f5 1f             	xor    $0x1f,%ebp
  802154:	75 5a                	jne    8021b0 <__umoddi3+0xb0>
  802156:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80215a:	0f 82 e0 00 00 00    	jb     802240 <__umoddi3+0x140>
  802160:	39 0c 24             	cmp    %ecx,(%esp)
  802163:	0f 86 d7 00 00 00    	jbe    802240 <__umoddi3+0x140>
  802169:	8b 44 24 08          	mov    0x8(%esp),%eax
  80216d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802171:	83 c4 1c             	add    $0x1c,%esp
  802174:	5b                   	pop    %ebx
  802175:	5e                   	pop    %esi
  802176:	5f                   	pop    %edi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	85 ff                	test   %edi,%edi
  802182:	89 fd                	mov    %edi,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x91>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f7                	div    %edi
  80218f:	89 c5                	mov    %eax,%ebp
  802191:	89 f0                	mov    %esi,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f5                	div    %ebp
  802197:	89 c8                	mov    %ecx,%eax
  802199:	f7 f5                	div    %ebp
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	eb 99                	jmp    802138 <__umoddi3+0x38>
  80219f:	90                   	nop
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 1c             	add    $0x1c,%esp
  8021a7:	5b                   	pop    %ebx
  8021a8:	5e                   	pop    %esi
  8021a9:	5f                   	pop    %edi
  8021aa:	5d                   	pop    %ebp
  8021ab:	c3                   	ret    
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	8b 34 24             	mov    (%esp),%esi
  8021b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021b8:	89 e9                	mov    %ebp,%ecx
  8021ba:	29 ef                	sub    %ebp,%edi
  8021bc:	d3 e0                	shl    %cl,%eax
  8021be:	89 f9                	mov    %edi,%ecx
  8021c0:	89 f2                	mov    %esi,%edx
  8021c2:	d3 ea                	shr    %cl,%edx
  8021c4:	89 e9                	mov    %ebp,%ecx
  8021c6:	09 c2                	or     %eax,%edx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 14 24             	mov    %edx,(%esp)
  8021cd:	89 f2                	mov    %esi,%edx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021db:	d3 e8                	shr    %cl,%eax
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	89 c6                	mov    %eax,%esi
  8021e1:	d3 e3                	shl    %cl,%ebx
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	d3 e8                	shr    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	09 d8                	or     %ebx,%eax
  8021ed:	89 d3                	mov    %edx,%ebx
  8021ef:	89 f2                	mov    %esi,%edx
  8021f1:	f7 34 24             	divl   (%esp)
  8021f4:	89 d6                	mov    %edx,%esi
  8021f6:	d3 e3                	shl    %cl,%ebx
  8021f8:	f7 64 24 04          	mull   0x4(%esp)
  8021fc:	39 d6                	cmp    %edx,%esi
  8021fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802202:	89 d1                	mov    %edx,%ecx
  802204:	89 c3                	mov    %eax,%ebx
  802206:	72 08                	jb     802210 <__umoddi3+0x110>
  802208:	75 11                	jne    80221b <__umoddi3+0x11b>
  80220a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80220e:	73 0b                	jae    80221b <__umoddi3+0x11b>
  802210:	2b 44 24 04          	sub    0x4(%esp),%eax
  802214:	1b 14 24             	sbb    (%esp),%edx
  802217:	89 d1                	mov    %edx,%ecx
  802219:	89 c3                	mov    %eax,%ebx
  80221b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80221f:	29 da                	sub    %ebx,%edx
  802221:	19 ce                	sbb    %ecx,%esi
  802223:	89 f9                	mov    %edi,%ecx
  802225:	89 f0                	mov    %esi,%eax
  802227:	d3 e0                	shl    %cl,%eax
  802229:	89 e9                	mov    %ebp,%ecx
  80222b:	d3 ea                	shr    %cl,%edx
  80222d:	89 e9                	mov    %ebp,%ecx
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	09 d0                	or     %edx,%eax
  802233:	89 f2                	mov    %esi,%edx
  802235:	83 c4 1c             	add    $0x1c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    
  80223d:	8d 76 00             	lea    0x0(%esi),%esi
  802240:	29 f9                	sub    %edi,%ecx
  802242:	19 d6                	sbb    %edx,%esi
  802244:	89 74 24 04          	mov    %esi,0x4(%esp)
  802248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80224c:	e9 18 ff ff ff       	jmp    802169 <__umoddi3+0x69>
