
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
  800059:	e8 e7 01 00 00       	call   800245 <strcmp>
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
  800091:	e8 e1 0d 00 00       	call   800e77 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 be 00 00 00       	call   800162 <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 c5 0d 00 00       	call   800e77 <write>
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
  8000ce:	e8 a4 0d 00 00       	call   800e77 <write>
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
  8000e9:	e8 72 04 00 00       	call   800560 <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	89 c2                	mov    %eax,%edx
  8000f5:	c1 e2 07             	shl    $0x7,%edx
  8000f8:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8000ff:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800104:	85 db                	test   %ebx,%ebx
  800106:	7e 07                	jle    80010f <libmain+0x31>
		binaryname = argv[0];
  800108:	8b 06                	mov    (%esi),%eax
  80010a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010f:	83 ec 08             	sub    $0x8,%esp
  800112:	56                   	push   %esi
  800113:	53                   	push   %ebx
  800114:	e8 1a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800119:	e8 2a 00 00 00       	call   800148 <exit>
}
  80011e:	83 c4 10             	add    $0x10,%esp
  800121:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800124:	5b                   	pop    %ebx
  800125:	5e                   	pop    %esi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80012e:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800133:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800135:	e8 26 04 00 00       	call   800560 <sys_getenvid>
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	50                   	push   %eax
  80013e:	e8 6c 06 00 00       	call   8007af <sys_thread_free>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014e:	e8 39 0b 00 00       	call   800c8c <close_all>
	sys_env_destroy(0);
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	6a 00                	push   $0x0
  800158:	e8 c2 03 00 00       	call   80051f <sys_env_destroy>
}
  80015d:	83 c4 10             	add    $0x10,%esp
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800168:	b8 00 00 00 00       	mov    $0x0,%eax
  80016d:	eb 03                	jmp    800172 <strlen+0x10>
		n++;
  80016f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800172:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800176:	75 f7                	jne    80016f <strlen+0xd>
		n++;
	return n;
}
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800180:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800183:	ba 00 00 00 00       	mov    $0x0,%edx
  800188:	eb 03                	jmp    80018d <strnlen+0x13>
		n++;
  80018a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80018d:	39 c2                	cmp    %eax,%edx
  80018f:	74 08                	je     800199 <strnlen+0x1f>
  800191:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800195:	75 f3                	jne    80018a <strnlen+0x10>
  800197:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001a5:	89 c2                	mov    %eax,%edx
  8001a7:	83 c2 01             	add    $0x1,%edx
  8001aa:	83 c1 01             	add    $0x1,%ecx
  8001ad:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8001b1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8001b4:	84 db                	test   %bl,%bl
  8001b6:	75 ef                	jne    8001a7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8001b8:	5b                   	pop    %ebx
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    

008001bb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	53                   	push   %ebx
  8001bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001c2:	53                   	push   %ebx
  8001c3:	e8 9a ff ff ff       	call   800162 <strlen>
  8001c8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001cb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ce:	01 d8                	add    %ebx,%eax
  8001d0:	50                   	push   %eax
  8001d1:	e8 c5 ff ff ff       	call   80019b <strcpy>
	return dst;
}
  8001d6:	89 d8                	mov    %ebx,%eax
  8001d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    

008001dd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	56                   	push   %esi
  8001e1:	53                   	push   %ebx
  8001e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8001e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e8:	89 f3                	mov    %esi,%ebx
  8001ea:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001ed:	89 f2                	mov    %esi,%edx
  8001ef:	eb 0f                	jmp    800200 <strncpy+0x23>
		*dst++ = *src;
  8001f1:	83 c2 01             	add    $0x1,%edx
  8001f4:	0f b6 01             	movzbl (%ecx),%eax
  8001f7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001fa:	80 39 01             	cmpb   $0x1,(%ecx)
  8001fd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800200:	39 da                	cmp    %ebx,%edx
  800202:	75 ed                	jne    8001f1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800204:	89 f0                	mov    %esi,%eax
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    

0080020a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80020a:	55                   	push   %ebp
  80020b:	89 e5                	mov    %esp,%ebp
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	8b 75 08             	mov    0x8(%ebp),%esi
  800212:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800215:	8b 55 10             	mov    0x10(%ebp),%edx
  800218:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80021a:	85 d2                	test   %edx,%edx
  80021c:	74 21                	je     80023f <strlcpy+0x35>
  80021e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800222:	89 f2                	mov    %esi,%edx
  800224:	eb 09                	jmp    80022f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800226:	83 c2 01             	add    $0x1,%edx
  800229:	83 c1 01             	add    $0x1,%ecx
  80022c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80022f:	39 c2                	cmp    %eax,%edx
  800231:	74 09                	je     80023c <strlcpy+0x32>
  800233:	0f b6 19             	movzbl (%ecx),%ebx
  800236:	84 db                	test   %bl,%bl
  800238:	75 ec                	jne    800226 <strlcpy+0x1c>
  80023a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80023c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80023f:	29 f0                	sub    %esi,%eax
}
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    

00800245 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80024b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80024e:	eb 06                	jmp    800256 <strcmp+0x11>
		p++, q++;
  800250:	83 c1 01             	add    $0x1,%ecx
  800253:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800256:	0f b6 01             	movzbl (%ecx),%eax
  800259:	84 c0                	test   %al,%al
  80025b:	74 04                	je     800261 <strcmp+0x1c>
  80025d:	3a 02                	cmp    (%edx),%al
  80025f:	74 ef                	je     800250 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800261:	0f b6 c0             	movzbl %al,%eax
  800264:	0f b6 12             	movzbl (%edx),%edx
  800267:	29 d0                	sub    %edx,%eax
}
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	53                   	push   %ebx
  80026f:	8b 45 08             	mov    0x8(%ebp),%eax
  800272:	8b 55 0c             	mov    0xc(%ebp),%edx
  800275:	89 c3                	mov    %eax,%ebx
  800277:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80027a:	eb 06                	jmp    800282 <strncmp+0x17>
		n--, p++, q++;
  80027c:	83 c0 01             	add    $0x1,%eax
  80027f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800282:	39 d8                	cmp    %ebx,%eax
  800284:	74 15                	je     80029b <strncmp+0x30>
  800286:	0f b6 08             	movzbl (%eax),%ecx
  800289:	84 c9                	test   %cl,%cl
  80028b:	74 04                	je     800291 <strncmp+0x26>
  80028d:	3a 0a                	cmp    (%edx),%cl
  80028f:	74 eb                	je     80027c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800291:	0f b6 00             	movzbl (%eax),%eax
  800294:	0f b6 12             	movzbl (%edx),%edx
  800297:	29 d0                	sub    %edx,%eax
  800299:	eb 05                	jmp    8002a0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80029b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8002a0:	5b                   	pop    %ebx
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002ad:	eb 07                	jmp    8002b6 <strchr+0x13>
		if (*s == c)
  8002af:	38 ca                	cmp    %cl,%dl
  8002b1:	74 0f                	je     8002c2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002b3:	83 c0 01             	add    $0x1,%eax
  8002b6:	0f b6 10             	movzbl (%eax),%edx
  8002b9:	84 d2                	test   %dl,%dl
  8002bb:	75 f2                	jne    8002af <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8002bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002ce:	eb 03                	jmp    8002d3 <strfind+0xf>
  8002d0:	83 c0 01             	add    $0x1,%eax
  8002d3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002d6:	38 ca                	cmp    %cl,%dl
  8002d8:	74 04                	je     8002de <strfind+0x1a>
  8002da:	84 d2                	test   %dl,%dl
  8002dc:	75 f2                	jne    8002d0 <strfind+0xc>
			break;
	return (char *) s;
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002ec:	85 c9                	test   %ecx,%ecx
  8002ee:	74 36                	je     800326 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002f0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002f6:	75 28                	jne    800320 <memset+0x40>
  8002f8:	f6 c1 03             	test   $0x3,%cl
  8002fb:	75 23                	jne    800320 <memset+0x40>
		c &= 0xFF;
  8002fd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800301:	89 d3                	mov    %edx,%ebx
  800303:	c1 e3 08             	shl    $0x8,%ebx
  800306:	89 d6                	mov    %edx,%esi
  800308:	c1 e6 18             	shl    $0x18,%esi
  80030b:	89 d0                	mov    %edx,%eax
  80030d:	c1 e0 10             	shl    $0x10,%eax
  800310:	09 f0                	or     %esi,%eax
  800312:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800314:	89 d8                	mov    %ebx,%eax
  800316:	09 d0                	or     %edx,%eax
  800318:	c1 e9 02             	shr    $0x2,%ecx
  80031b:	fc                   	cld    
  80031c:	f3 ab                	rep stos %eax,%es:(%edi)
  80031e:	eb 06                	jmp    800326 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
  800323:	fc                   	cld    
  800324:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800326:	89 f8                	mov    %edi,%eax
  800328:	5b                   	pop    %ebx
  800329:	5e                   	pop    %esi
  80032a:	5f                   	pop    %edi
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	8b 45 08             	mov    0x8(%ebp),%eax
  800335:	8b 75 0c             	mov    0xc(%ebp),%esi
  800338:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80033b:	39 c6                	cmp    %eax,%esi
  80033d:	73 35                	jae    800374 <memmove+0x47>
  80033f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800342:	39 d0                	cmp    %edx,%eax
  800344:	73 2e                	jae    800374 <memmove+0x47>
		s += n;
		d += n;
  800346:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800349:	89 d6                	mov    %edx,%esi
  80034b:	09 fe                	or     %edi,%esi
  80034d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800353:	75 13                	jne    800368 <memmove+0x3b>
  800355:	f6 c1 03             	test   $0x3,%cl
  800358:	75 0e                	jne    800368 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80035a:	83 ef 04             	sub    $0x4,%edi
  80035d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800360:	c1 e9 02             	shr    $0x2,%ecx
  800363:	fd                   	std    
  800364:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800366:	eb 09                	jmp    800371 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800368:	83 ef 01             	sub    $0x1,%edi
  80036b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80036e:	fd                   	std    
  80036f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800371:	fc                   	cld    
  800372:	eb 1d                	jmp    800391 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800374:	89 f2                	mov    %esi,%edx
  800376:	09 c2                	or     %eax,%edx
  800378:	f6 c2 03             	test   $0x3,%dl
  80037b:	75 0f                	jne    80038c <memmove+0x5f>
  80037d:	f6 c1 03             	test   $0x3,%cl
  800380:	75 0a                	jne    80038c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800382:	c1 e9 02             	shr    $0x2,%ecx
  800385:	89 c7                	mov    %eax,%edi
  800387:	fc                   	cld    
  800388:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80038a:	eb 05                	jmp    800391 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80038c:	89 c7                	mov    %eax,%edi
  80038e:	fc                   	cld    
  80038f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800398:	ff 75 10             	pushl  0x10(%ebp)
  80039b:	ff 75 0c             	pushl  0xc(%ebp)
  80039e:	ff 75 08             	pushl  0x8(%ebp)
  8003a1:	e8 87 ff ff ff       	call   80032d <memmove>
}
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    

008003a8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	56                   	push   %esi
  8003ac:	53                   	push   %ebx
  8003ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b3:	89 c6                	mov    %eax,%esi
  8003b5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b8:	eb 1a                	jmp    8003d4 <memcmp+0x2c>
		if (*s1 != *s2)
  8003ba:	0f b6 08             	movzbl (%eax),%ecx
  8003bd:	0f b6 1a             	movzbl (%edx),%ebx
  8003c0:	38 d9                	cmp    %bl,%cl
  8003c2:	74 0a                	je     8003ce <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003c4:	0f b6 c1             	movzbl %cl,%eax
  8003c7:	0f b6 db             	movzbl %bl,%ebx
  8003ca:	29 d8                	sub    %ebx,%eax
  8003cc:	eb 0f                	jmp    8003dd <memcmp+0x35>
		s1++, s2++;
  8003ce:	83 c0 01             	add    $0x1,%eax
  8003d1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003d4:	39 f0                	cmp    %esi,%eax
  8003d6:	75 e2                	jne    8003ba <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003dd:	5b                   	pop    %ebx
  8003de:	5e                   	pop    %esi
  8003df:	5d                   	pop    %ebp
  8003e0:	c3                   	ret    

008003e1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	53                   	push   %ebx
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8003e8:	89 c1                	mov    %eax,%ecx
  8003ea:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8003ed:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003f1:	eb 0a                	jmp    8003fd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003f3:	0f b6 10             	movzbl (%eax),%edx
  8003f6:	39 da                	cmp    %ebx,%edx
  8003f8:	74 07                	je     800401 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003fa:	83 c0 01             	add    $0x1,%eax
  8003fd:	39 c8                	cmp    %ecx,%eax
  8003ff:	72 f2                	jb     8003f3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800401:	5b                   	pop    %ebx
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80040d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800410:	eb 03                	jmp    800415 <strtol+0x11>
		s++;
  800412:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800415:	0f b6 01             	movzbl (%ecx),%eax
  800418:	3c 20                	cmp    $0x20,%al
  80041a:	74 f6                	je     800412 <strtol+0xe>
  80041c:	3c 09                	cmp    $0x9,%al
  80041e:	74 f2                	je     800412 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800420:	3c 2b                	cmp    $0x2b,%al
  800422:	75 0a                	jne    80042e <strtol+0x2a>
		s++;
  800424:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800427:	bf 00 00 00 00       	mov    $0x0,%edi
  80042c:	eb 11                	jmp    80043f <strtol+0x3b>
  80042e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800433:	3c 2d                	cmp    $0x2d,%al
  800435:	75 08                	jne    80043f <strtol+0x3b>
		s++, neg = 1;
  800437:	83 c1 01             	add    $0x1,%ecx
  80043a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80043f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800445:	75 15                	jne    80045c <strtol+0x58>
  800447:	80 39 30             	cmpb   $0x30,(%ecx)
  80044a:	75 10                	jne    80045c <strtol+0x58>
  80044c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800450:	75 7c                	jne    8004ce <strtol+0xca>
		s += 2, base = 16;
  800452:	83 c1 02             	add    $0x2,%ecx
  800455:	bb 10 00 00 00       	mov    $0x10,%ebx
  80045a:	eb 16                	jmp    800472 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80045c:	85 db                	test   %ebx,%ebx
  80045e:	75 12                	jne    800472 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800460:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800465:	80 39 30             	cmpb   $0x30,(%ecx)
  800468:	75 08                	jne    800472 <strtol+0x6e>
		s++, base = 8;
  80046a:	83 c1 01             	add    $0x1,%ecx
  80046d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80047a:	0f b6 11             	movzbl (%ecx),%edx
  80047d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800480:	89 f3                	mov    %esi,%ebx
  800482:	80 fb 09             	cmp    $0x9,%bl
  800485:	77 08                	ja     80048f <strtol+0x8b>
			dig = *s - '0';
  800487:	0f be d2             	movsbl %dl,%edx
  80048a:	83 ea 30             	sub    $0x30,%edx
  80048d:	eb 22                	jmp    8004b1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80048f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800492:	89 f3                	mov    %esi,%ebx
  800494:	80 fb 19             	cmp    $0x19,%bl
  800497:	77 08                	ja     8004a1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800499:	0f be d2             	movsbl %dl,%edx
  80049c:	83 ea 57             	sub    $0x57,%edx
  80049f:	eb 10                	jmp    8004b1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8004a1:	8d 72 bf             	lea    -0x41(%edx),%esi
  8004a4:	89 f3                	mov    %esi,%ebx
  8004a6:	80 fb 19             	cmp    $0x19,%bl
  8004a9:	77 16                	ja     8004c1 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8004ab:	0f be d2             	movsbl %dl,%edx
  8004ae:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8004b1:	3b 55 10             	cmp    0x10(%ebp),%edx
  8004b4:	7d 0b                	jge    8004c1 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8004b6:	83 c1 01             	add    $0x1,%ecx
  8004b9:	0f af 45 10          	imul   0x10(%ebp),%eax
  8004bd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8004bf:	eb b9                	jmp    80047a <strtol+0x76>

	if (endptr)
  8004c1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004c5:	74 0d                	je     8004d4 <strtol+0xd0>
		*endptr = (char *) s;
  8004c7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004ca:	89 0e                	mov    %ecx,(%esi)
  8004cc:	eb 06                	jmp    8004d4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004ce:	85 db                	test   %ebx,%ebx
  8004d0:	74 98                	je     80046a <strtol+0x66>
  8004d2:	eb 9e                	jmp    800472 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004d4:	89 c2                	mov    %eax,%edx
  8004d6:	f7 da                	neg    %edx
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	0f 45 c2             	cmovne %edx,%eax
}
  8004dd:	5b                   	pop    %ebx
  8004de:	5e                   	pop    %esi
  8004df:	5f                   	pop    %edi
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	57                   	push   %edi
  8004e6:	56                   	push   %esi
  8004e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f3:	89 c3                	mov    %eax,%ebx
  8004f5:	89 c7                	mov    %eax,%edi
  8004f7:	89 c6                	mov    %eax,%esi
  8004f9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004fb:	5b                   	pop    %ebx
  8004fc:	5e                   	pop    %esi
  8004fd:	5f                   	pop    %edi
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <sys_cgetc>:

int
sys_cgetc(void)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	57                   	push   %edi
  800504:	56                   	push   %esi
  800505:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800506:	ba 00 00 00 00       	mov    $0x0,%edx
  80050b:	b8 01 00 00 00       	mov    $0x1,%eax
  800510:	89 d1                	mov    %edx,%ecx
  800512:	89 d3                	mov    %edx,%ebx
  800514:	89 d7                	mov    %edx,%edi
  800516:	89 d6                	mov    %edx,%esi
  800518:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80051a:	5b                   	pop    %ebx
  80051b:	5e                   	pop    %esi
  80051c:	5f                   	pop    %edi
  80051d:	5d                   	pop    %ebp
  80051e:	c3                   	ret    

0080051f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	57                   	push   %edi
  800523:	56                   	push   %esi
  800524:	53                   	push   %ebx
  800525:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800528:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052d:	b8 03 00 00 00       	mov    $0x3,%eax
  800532:	8b 55 08             	mov    0x8(%ebp),%edx
  800535:	89 cb                	mov    %ecx,%ebx
  800537:	89 cf                	mov    %ecx,%edi
  800539:	89 ce                	mov    %ecx,%esi
  80053b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80053d:	85 c0                	test   %eax,%eax
  80053f:	7e 17                	jle    800558 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800541:	83 ec 0c             	sub    $0xc,%esp
  800544:	50                   	push   %eax
  800545:	6a 03                	push   $0x3
  800547:	68 6f 22 80 00       	push   $0x80226f
  80054c:	6a 23                	push   $0x23
  80054e:	68 8c 22 80 00       	push   $0x80228c
  800553:	e8 53 12 00 00       	call   8017ab <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800558:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80055b:	5b                   	pop    %ebx
  80055c:	5e                   	pop    %esi
  80055d:	5f                   	pop    %edi
  80055e:	5d                   	pop    %ebp
  80055f:	c3                   	ret    

00800560 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	57                   	push   %edi
  800564:	56                   	push   %esi
  800565:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800566:	ba 00 00 00 00       	mov    $0x0,%edx
  80056b:	b8 02 00 00 00       	mov    $0x2,%eax
  800570:	89 d1                	mov    %edx,%ecx
  800572:	89 d3                	mov    %edx,%ebx
  800574:	89 d7                	mov    %edx,%edi
  800576:	89 d6                	mov    %edx,%esi
  800578:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80057a:	5b                   	pop    %ebx
  80057b:	5e                   	pop    %esi
  80057c:	5f                   	pop    %edi
  80057d:	5d                   	pop    %ebp
  80057e:	c3                   	ret    

0080057f <sys_yield>:

void
sys_yield(void)
{
  80057f:	55                   	push   %ebp
  800580:	89 e5                	mov    %esp,%ebp
  800582:	57                   	push   %edi
  800583:	56                   	push   %esi
  800584:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800585:	ba 00 00 00 00       	mov    $0x0,%edx
  80058a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80058f:	89 d1                	mov    %edx,%ecx
  800591:	89 d3                	mov    %edx,%ebx
  800593:	89 d7                	mov    %edx,%edi
  800595:	89 d6                	mov    %edx,%esi
  800597:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800599:	5b                   	pop    %ebx
  80059a:	5e                   	pop    %esi
  80059b:	5f                   	pop    %edi
  80059c:	5d                   	pop    %ebp
  80059d:	c3                   	ret    

0080059e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
  8005a1:	57                   	push   %edi
  8005a2:	56                   	push   %esi
  8005a3:	53                   	push   %ebx
  8005a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005a7:	be 00 00 00 00       	mov    $0x0,%esi
  8005ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8005b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8005b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005ba:	89 f7                	mov    %esi,%edi
  8005bc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005be:	85 c0                	test   %eax,%eax
  8005c0:	7e 17                	jle    8005d9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005c2:	83 ec 0c             	sub    $0xc,%esp
  8005c5:	50                   	push   %eax
  8005c6:	6a 04                	push   $0x4
  8005c8:	68 6f 22 80 00       	push   $0x80226f
  8005cd:	6a 23                	push   $0x23
  8005cf:	68 8c 22 80 00       	push   $0x80228c
  8005d4:	e8 d2 11 00 00       	call   8017ab <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005dc:	5b                   	pop    %ebx
  8005dd:	5e                   	pop    %esi
  8005de:	5f                   	pop    %edi
  8005df:	5d                   	pop    %ebp
  8005e0:	c3                   	ret    

008005e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	57                   	push   %edi
  8005e5:	56                   	push   %esi
  8005e6:	53                   	push   %ebx
  8005e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8005ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005f8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005fb:	8b 75 18             	mov    0x18(%ebp),%esi
  8005fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800600:	85 c0                	test   %eax,%eax
  800602:	7e 17                	jle    80061b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	50                   	push   %eax
  800608:	6a 05                	push   $0x5
  80060a:	68 6f 22 80 00       	push   $0x80226f
  80060f:	6a 23                	push   $0x23
  800611:	68 8c 22 80 00       	push   $0x80228c
  800616:	e8 90 11 00 00       	call   8017ab <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061e:	5b                   	pop    %ebx
  80061f:	5e                   	pop    %esi
  800620:	5f                   	pop    %edi
  800621:	5d                   	pop    %ebp
  800622:	c3                   	ret    

00800623 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	57                   	push   %edi
  800627:	56                   	push   %esi
  800628:	53                   	push   %ebx
  800629:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80062c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800631:	b8 06 00 00 00       	mov    $0x6,%eax
  800636:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800639:	8b 55 08             	mov    0x8(%ebp),%edx
  80063c:	89 df                	mov    %ebx,%edi
  80063e:	89 de                	mov    %ebx,%esi
  800640:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800642:	85 c0                	test   %eax,%eax
  800644:	7e 17                	jle    80065d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800646:	83 ec 0c             	sub    $0xc,%esp
  800649:	50                   	push   %eax
  80064a:	6a 06                	push   $0x6
  80064c:	68 6f 22 80 00       	push   $0x80226f
  800651:	6a 23                	push   $0x23
  800653:	68 8c 22 80 00       	push   $0x80228c
  800658:	e8 4e 11 00 00       	call   8017ab <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80065d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800660:	5b                   	pop    %ebx
  800661:	5e                   	pop    %esi
  800662:	5f                   	pop    %edi
  800663:	5d                   	pop    %ebp
  800664:	c3                   	ret    

00800665 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	57                   	push   %edi
  800669:	56                   	push   %esi
  80066a:	53                   	push   %ebx
  80066b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80066e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800673:	b8 08 00 00 00       	mov    $0x8,%eax
  800678:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80067b:	8b 55 08             	mov    0x8(%ebp),%edx
  80067e:	89 df                	mov    %ebx,%edi
  800680:	89 de                	mov    %ebx,%esi
  800682:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800684:	85 c0                	test   %eax,%eax
  800686:	7e 17                	jle    80069f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800688:	83 ec 0c             	sub    $0xc,%esp
  80068b:	50                   	push   %eax
  80068c:	6a 08                	push   $0x8
  80068e:	68 6f 22 80 00       	push   $0x80226f
  800693:	6a 23                	push   $0x23
  800695:	68 8c 22 80 00       	push   $0x80228c
  80069a:	e8 0c 11 00 00       	call   8017ab <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80069f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a2:	5b                   	pop    %ebx
  8006a3:	5e                   	pop    %esi
  8006a4:	5f                   	pop    %edi
  8006a5:	5d                   	pop    %ebp
  8006a6:	c3                   	ret    

008006a7 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006a7:	55                   	push   %ebp
  8006a8:	89 e5                	mov    %esp,%ebp
  8006aa:	57                   	push   %edi
  8006ab:	56                   	push   %esi
  8006ac:	53                   	push   %ebx
  8006ad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b5:	b8 09 00 00 00       	mov    $0x9,%eax
  8006ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c0:	89 df                	mov    %ebx,%edi
  8006c2:	89 de                	mov    %ebx,%esi
  8006c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006c6:	85 c0                	test   %eax,%eax
  8006c8:	7e 17                	jle    8006e1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	50                   	push   %eax
  8006ce:	6a 09                	push   $0x9
  8006d0:	68 6f 22 80 00       	push   $0x80226f
  8006d5:	6a 23                	push   $0x23
  8006d7:	68 8c 22 80 00       	push   $0x80228c
  8006dc:	e8 ca 10 00 00       	call   8017ab <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e4:	5b                   	pop    %ebx
  8006e5:	5e                   	pop    %esi
  8006e6:	5f                   	pop    %edi
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	57                   	push   %edi
  8006ed:	56                   	push   %esi
  8006ee:	53                   	push   %ebx
  8006ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800702:	89 df                	mov    %ebx,%edi
  800704:	89 de                	mov    %ebx,%esi
  800706:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800708:	85 c0                	test   %eax,%eax
  80070a:	7e 17                	jle    800723 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80070c:	83 ec 0c             	sub    $0xc,%esp
  80070f:	50                   	push   %eax
  800710:	6a 0a                	push   $0xa
  800712:	68 6f 22 80 00       	push   $0x80226f
  800717:	6a 23                	push   $0x23
  800719:	68 8c 22 80 00       	push   $0x80228c
  80071e:	e8 88 10 00 00       	call   8017ab <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800723:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5f                   	pop    %edi
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	57                   	push   %edi
  80072f:	56                   	push   %esi
  800730:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800731:	be 00 00 00 00       	mov    $0x0,%esi
  800736:	b8 0c 00 00 00       	mov    $0xc,%eax
  80073b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073e:	8b 55 08             	mov    0x8(%ebp),%edx
  800741:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800744:	8b 7d 14             	mov    0x14(%ebp),%edi
  800747:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800749:	5b                   	pop    %ebx
  80074a:	5e                   	pop    %esi
  80074b:	5f                   	pop    %edi
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	57                   	push   %edi
  800752:	56                   	push   %esi
  800753:	53                   	push   %ebx
  800754:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800757:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800761:	8b 55 08             	mov    0x8(%ebp),%edx
  800764:	89 cb                	mov    %ecx,%ebx
  800766:	89 cf                	mov    %ecx,%edi
  800768:	89 ce                	mov    %ecx,%esi
  80076a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80076c:	85 c0                	test   %eax,%eax
  80076e:	7e 17                	jle    800787 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800770:	83 ec 0c             	sub    $0xc,%esp
  800773:	50                   	push   %eax
  800774:	6a 0d                	push   $0xd
  800776:	68 6f 22 80 00       	push   $0x80226f
  80077b:	6a 23                	push   $0x23
  80077d:	68 8c 22 80 00       	push   $0x80228c
  800782:	e8 24 10 00 00       	call   8017ab <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800787:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078a:	5b                   	pop    %ebx
  80078b:	5e                   	pop    %esi
  80078c:	5f                   	pop    %edi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	57                   	push   %edi
  800793:	56                   	push   %esi
  800794:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800795:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80079f:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a2:	89 cb                	mov    %ecx,%ebx
  8007a4:	89 cf                	mov    %ecx,%edi
  8007a6:	89 ce                	mov    %ecx,%esi
  8007a8:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5f                   	pop    %edi
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	57                   	push   %edi
  8007b3:	56                   	push   %esi
  8007b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ba:	b8 0f 00 00 00       	mov    $0xf,%eax
  8007bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8007c2:	89 cb                	mov    %ecx,%ebx
  8007c4:	89 cf                	mov    %ecx,%edi
  8007c6:	89 ce                	mov    %ecx,%esi
  8007c8:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8007ca:	5b                   	pop    %ebx
  8007cb:	5e                   	pop    %esi
  8007cc:	5f                   	pop    %edi
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	83 ec 04             	sub    $0x4,%esp
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8007d9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8007db:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8007df:	74 11                	je     8007f2 <pgfault+0x23>
  8007e1:	89 d8                	mov    %ebx,%eax
  8007e3:	c1 e8 0c             	shr    $0xc,%eax
  8007e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8007ed:	f6 c4 08             	test   $0x8,%ah
  8007f0:	75 14                	jne    800806 <pgfault+0x37>
		panic("faulting access");
  8007f2:	83 ec 04             	sub    $0x4,%esp
  8007f5:	68 9a 22 80 00       	push   $0x80229a
  8007fa:	6a 1e                	push   $0x1e
  8007fc:	68 aa 22 80 00       	push   $0x8022aa
  800801:	e8 a5 0f 00 00       	call   8017ab <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800806:	83 ec 04             	sub    $0x4,%esp
  800809:	6a 07                	push   $0x7
  80080b:	68 00 f0 7f 00       	push   $0x7ff000
  800810:	6a 00                	push   $0x0
  800812:	e8 87 fd ff ff       	call   80059e <sys_page_alloc>
	if (r < 0) {
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	85 c0                	test   %eax,%eax
  80081c:	79 12                	jns    800830 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  80081e:	50                   	push   %eax
  80081f:	68 b5 22 80 00       	push   $0x8022b5
  800824:	6a 2c                	push   $0x2c
  800826:	68 aa 22 80 00       	push   $0x8022aa
  80082b:	e8 7b 0f 00 00       	call   8017ab <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800830:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800836:	83 ec 04             	sub    $0x4,%esp
  800839:	68 00 10 00 00       	push   $0x1000
  80083e:	53                   	push   %ebx
  80083f:	68 00 f0 7f 00       	push   $0x7ff000
  800844:	e8 4c fb ff ff       	call   800395 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800849:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800850:	53                   	push   %ebx
  800851:	6a 00                	push   $0x0
  800853:	68 00 f0 7f 00       	push   $0x7ff000
  800858:	6a 00                	push   $0x0
  80085a:	e8 82 fd ff ff       	call   8005e1 <sys_page_map>
	if (r < 0) {
  80085f:	83 c4 20             	add    $0x20,%esp
  800862:	85 c0                	test   %eax,%eax
  800864:	79 12                	jns    800878 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800866:	50                   	push   %eax
  800867:	68 b5 22 80 00       	push   $0x8022b5
  80086c:	6a 33                	push   $0x33
  80086e:	68 aa 22 80 00       	push   $0x8022aa
  800873:	e8 33 0f 00 00       	call   8017ab <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	68 00 f0 7f 00       	push   $0x7ff000
  800880:	6a 00                	push   $0x0
  800882:	e8 9c fd ff ff       	call   800623 <sys_page_unmap>
	if (r < 0) {
  800887:	83 c4 10             	add    $0x10,%esp
  80088a:	85 c0                	test   %eax,%eax
  80088c:	79 12                	jns    8008a0 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80088e:	50                   	push   %eax
  80088f:	68 b5 22 80 00       	push   $0x8022b5
  800894:	6a 37                	push   $0x37
  800896:	68 aa 22 80 00       	push   $0x8022aa
  80089b:	e8 0b 0f 00 00       	call   8017ab <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8008a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8008ae:	68 cf 07 80 00       	push   $0x8007cf
  8008b3:	e8 18 15 00 00       	call   801dd0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8008b8:	b8 07 00 00 00       	mov    $0x7,%eax
  8008bd:	cd 30                	int    $0x30
  8008bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	79 17                	jns    8008e0 <fork+0x3b>
		panic("fork fault %e");
  8008c9:	83 ec 04             	sub    $0x4,%esp
  8008cc:	68 ce 22 80 00       	push   $0x8022ce
  8008d1:	68 84 00 00 00       	push   $0x84
  8008d6:	68 aa 22 80 00       	push   $0x8022aa
  8008db:	e8 cb 0e 00 00       	call   8017ab <_panic>
  8008e0:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8008e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008e6:	75 25                	jne    80090d <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8008e8:	e8 73 fc ff ff       	call   800560 <sys_getenvid>
  8008ed:	25 ff 03 00 00       	and    $0x3ff,%eax
  8008f2:	89 c2                	mov    %eax,%edx
  8008f4:	c1 e2 07             	shl    $0x7,%edx
  8008f7:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8008fe:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
  800908:	e9 61 01 00 00       	jmp    800a6e <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  80090d:	83 ec 04             	sub    $0x4,%esp
  800910:	6a 07                	push   $0x7
  800912:	68 00 f0 bf ee       	push   $0xeebff000
  800917:	ff 75 e4             	pushl  -0x1c(%ebp)
  80091a:	e8 7f fc ff ff       	call   80059e <sys_page_alloc>
  80091f:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800922:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800927:	89 d8                	mov    %ebx,%eax
  800929:	c1 e8 16             	shr    $0x16,%eax
  80092c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800933:	a8 01                	test   $0x1,%al
  800935:	0f 84 fc 00 00 00    	je     800a37 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80093b:	89 d8                	mov    %ebx,%eax
  80093d:	c1 e8 0c             	shr    $0xc,%eax
  800940:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800947:	f6 c2 01             	test   $0x1,%dl
  80094a:	0f 84 e7 00 00 00    	je     800a37 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800950:	89 c6                	mov    %eax,%esi
  800952:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800955:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80095c:	f6 c6 04             	test   $0x4,%dh
  80095f:	74 39                	je     80099a <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800961:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800968:	83 ec 0c             	sub    $0xc,%esp
  80096b:	25 07 0e 00 00       	and    $0xe07,%eax
  800970:	50                   	push   %eax
  800971:	56                   	push   %esi
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	6a 00                	push   $0x0
  800976:	e8 66 fc ff ff       	call   8005e1 <sys_page_map>
		if (r < 0) {
  80097b:	83 c4 20             	add    $0x20,%esp
  80097e:	85 c0                	test   %eax,%eax
  800980:	0f 89 b1 00 00 00    	jns    800a37 <fork+0x192>
		    	panic("sys page map fault %e");
  800986:	83 ec 04             	sub    $0x4,%esp
  800989:	68 dc 22 80 00       	push   $0x8022dc
  80098e:	6a 54                	push   $0x54
  800990:	68 aa 22 80 00       	push   $0x8022aa
  800995:	e8 11 0e 00 00       	call   8017ab <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80099a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009a1:	f6 c2 02             	test   $0x2,%dl
  8009a4:	75 0c                	jne    8009b2 <fork+0x10d>
  8009a6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009ad:	f6 c4 08             	test   $0x8,%ah
  8009b0:	74 5b                	je     800a0d <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8009b2:	83 ec 0c             	sub    $0xc,%esp
  8009b5:	68 05 08 00 00       	push   $0x805
  8009ba:	56                   	push   %esi
  8009bb:	57                   	push   %edi
  8009bc:	56                   	push   %esi
  8009bd:	6a 00                	push   $0x0
  8009bf:	e8 1d fc ff ff       	call   8005e1 <sys_page_map>
		if (r < 0) {
  8009c4:	83 c4 20             	add    $0x20,%esp
  8009c7:	85 c0                	test   %eax,%eax
  8009c9:	79 14                	jns    8009df <fork+0x13a>
		    	panic("sys page map fault %e");
  8009cb:	83 ec 04             	sub    $0x4,%esp
  8009ce:	68 dc 22 80 00       	push   $0x8022dc
  8009d3:	6a 5b                	push   $0x5b
  8009d5:	68 aa 22 80 00       	push   $0x8022aa
  8009da:	e8 cc 0d 00 00       	call   8017ab <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8009df:	83 ec 0c             	sub    $0xc,%esp
  8009e2:	68 05 08 00 00       	push   $0x805
  8009e7:	56                   	push   %esi
  8009e8:	6a 00                	push   $0x0
  8009ea:	56                   	push   %esi
  8009eb:	6a 00                	push   $0x0
  8009ed:	e8 ef fb ff ff       	call   8005e1 <sys_page_map>
		if (r < 0) {
  8009f2:	83 c4 20             	add    $0x20,%esp
  8009f5:	85 c0                	test   %eax,%eax
  8009f7:	79 3e                	jns    800a37 <fork+0x192>
		    	panic("sys page map fault %e");
  8009f9:	83 ec 04             	sub    $0x4,%esp
  8009fc:	68 dc 22 80 00       	push   $0x8022dc
  800a01:	6a 5f                	push   $0x5f
  800a03:	68 aa 22 80 00       	push   $0x8022aa
  800a08:	e8 9e 0d 00 00       	call   8017ab <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800a0d:	83 ec 0c             	sub    $0xc,%esp
  800a10:	6a 05                	push   $0x5
  800a12:	56                   	push   %esi
  800a13:	57                   	push   %edi
  800a14:	56                   	push   %esi
  800a15:	6a 00                	push   $0x0
  800a17:	e8 c5 fb ff ff       	call   8005e1 <sys_page_map>
		if (r < 0) {
  800a1c:	83 c4 20             	add    $0x20,%esp
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	79 14                	jns    800a37 <fork+0x192>
		    	panic("sys page map fault %e");
  800a23:	83 ec 04             	sub    $0x4,%esp
  800a26:	68 dc 22 80 00       	push   $0x8022dc
  800a2b:	6a 64                	push   $0x64
  800a2d:	68 aa 22 80 00       	push   $0x8022aa
  800a32:	e8 74 0d 00 00       	call   8017ab <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800a37:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800a3d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800a43:	0f 85 de fe ff ff    	jne    800927 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800a49:	a1 04 40 80 00       	mov    0x804004,%eax
  800a4e:	8b 40 70             	mov    0x70(%eax),%eax
  800a51:	83 ec 08             	sub    $0x8,%esp
  800a54:	50                   	push   %eax
  800a55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a58:	57                   	push   %edi
  800a59:	e8 8b fc ff ff       	call   8006e9 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800a5e:	83 c4 08             	add    $0x8,%esp
  800a61:	6a 02                	push   $0x2
  800a63:	57                   	push   %edi
  800a64:	e8 fc fb ff ff       	call   800665 <sys_env_set_status>
	
	return envid;
  800a69:	83 c4 10             	add    $0x10,%esp
  800a6c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800a6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <sfork>:

envid_t
sfork(void)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800a79:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800a88:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800a8e:	83 ec 08             	sub    $0x8,%esp
  800a91:	53                   	push   %ebx
  800a92:	68 f4 22 80 00       	push   $0x8022f4
  800a97:	e8 e8 0d 00 00       	call   801884 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800a9c:	c7 04 24 28 01 80 00 	movl   $0x800128,(%esp)
  800aa3:	e8 e7 fc ff ff       	call   80078f <sys_thread_create>
  800aa8:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800aaa:	83 c4 08             	add    $0x8,%esp
  800aad:	53                   	push   %ebx
  800aae:	68 f4 22 80 00       	push   $0x8022f4
  800ab3:	e8 cc 0d 00 00       	call   801884 <cprintf>
	return id;
	//return 0;
}
  800ab8:	89 f0                	mov    %esi,%eax
  800aba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abd:	5b                   	pop    %ebx
  800abe:	5e                   	pop    %esi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	05 00 00 00 30       	add    $0x30000000,%eax
  800acc:	c1 e8 0c             	shr    $0xc,%eax
}
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800ad4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad7:	05 00 00 00 30       	add    $0x30000000,%eax
  800adc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800ae1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aee:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	c1 ea 16             	shr    $0x16,%edx
  800af8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800aff:	f6 c2 01             	test   $0x1,%dl
  800b02:	74 11                	je     800b15 <fd_alloc+0x2d>
  800b04:	89 c2                	mov    %eax,%edx
  800b06:	c1 ea 0c             	shr    $0xc,%edx
  800b09:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800b10:	f6 c2 01             	test   $0x1,%dl
  800b13:	75 09                	jne    800b1e <fd_alloc+0x36>
			*fd_store = fd;
  800b15:	89 01                	mov    %eax,(%ecx)
			return 0;
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1c:	eb 17                	jmp    800b35 <fd_alloc+0x4d>
  800b1e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800b23:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800b28:	75 c9                	jne    800af3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800b2a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800b30:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800b3d:	83 f8 1f             	cmp    $0x1f,%eax
  800b40:	77 36                	ja     800b78 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800b42:	c1 e0 0c             	shl    $0xc,%eax
  800b45:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	c1 ea 16             	shr    $0x16,%edx
  800b4f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800b56:	f6 c2 01             	test   $0x1,%dl
  800b59:	74 24                	je     800b7f <fd_lookup+0x48>
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	c1 ea 0c             	shr    $0xc,%edx
  800b60:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800b67:	f6 c2 01             	test   $0x1,%dl
  800b6a:	74 1a                	je     800b86 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6f:	89 02                	mov    %eax,(%edx)
	return 0;
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	eb 13                	jmp    800b8b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800b78:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b7d:	eb 0c                	jmp    800b8b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800b7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b84:	eb 05                	jmp    800b8b <fd_lookup+0x54>
  800b86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 08             	sub    $0x8,%esp
  800b93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b96:	ba 94 23 80 00       	mov    $0x802394,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800b9b:	eb 13                	jmp    800bb0 <dev_lookup+0x23>
  800b9d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ba0:	39 08                	cmp    %ecx,(%eax)
  800ba2:	75 0c                	jne    800bb0 <dev_lookup+0x23>
			*dev = devtab[i];
  800ba4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba7:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bae:	eb 2e                	jmp    800bde <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800bb0:	8b 02                	mov    (%edx),%eax
  800bb2:	85 c0                	test   %eax,%eax
  800bb4:	75 e7                	jne    800b9d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800bb6:	a1 04 40 80 00       	mov    0x804004,%eax
  800bbb:	8b 40 54             	mov    0x54(%eax),%eax
  800bbe:	83 ec 04             	sub    $0x4,%esp
  800bc1:	51                   	push   %ecx
  800bc2:	50                   	push   %eax
  800bc3:	68 18 23 80 00       	push   $0x802318
  800bc8:	e8 b7 0c 00 00       	call   801884 <cprintf>
	*dev = 0;
  800bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800bd6:	83 c4 10             	add    $0x10,%esp
  800bd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800bde:	c9                   	leave  
  800bdf:	c3                   	ret    

00800be0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 10             	sub    $0x10,%esp
  800be8:	8b 75 08             	mov    0x8(%ebp),%esi
  800beb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800bee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf1:	50                   	push   %eax
  800bf2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800bf8:	c1 e8 0c             	shr    $0xc,%eax
  800bfb:	50                   	push   %eax
  800bfc:	e8 36 ff ff ff       	call   800b37 <fd_lookup>
  800c01:	83 c4 08             	add    $0x8,%esp
  800c04:	85 c0                	test   %eax,%eax
  800c06:	78 05                	js     800c0d <fd_close+0x2d>
	    || fd != fd2)
  800c08:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800c0b:	74 0c                	je     800c19 <fd_close+0x39>
		return (must_exist ? r : 0);
  800c0d:	84 db                	test   %bl,%bl
  800c0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c14:	0f 44 c2             	cmove  %edx,%eax
  800c17:	eb 41                	jmp    800c5a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800c19:	83 ec 08             	sub    $0x8,%esp
  800c1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c1f:	50                   	push   %eax
  800c20:	ff 36                	pushl  (%esi)
  800c22:	e8 66 ff ff ff       	call   800b8d <dev_lookup>
  800c27:	89 c3                	mov    %eax,%ebx
  800c29:	83 c4 10             	add    $0x10,%esp
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	78 1a                	js     800c4a <fd_close+0x6a>
		if (dev->dev_close)
  800c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c33:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800c36:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	74 0b                	je     800c4a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	56                   	push   %esi
  800c43:	ff d0                	call   *%eax
  800c45:	89 c3                	mov    %eax,%ebx
  800c47:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800c4a:	83 ec 08             	sub    $0x8,%esp
  800c4d:	56                   	push   %esi
  800c4e:	6a 00                	push   $0x0
  800c50:	e8 ce f9 ff ff       	call   800623 <sys_page_unmap>
	return r;
  800c55:	83 c4 10             	add    $0x10,%esp
  800c58:	89 d8                	mov    %ebx,%eax
}
  800c5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c6a:	50                   	push   %eax
  800c6b:	ff 75 08             	pushl  0x8(%ebp)
  800c6e:	e8 c4 fe ff ff       	call   800b37 <fd_lookup>
  800c73:	83 c4 08             	add    $0x8,%esp
  800c76:	85 c0                	test   %eax,%eax
  800c78:	78 10                	js     800c8a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800c7a:	83 ec 08             	sub    $0x8,%esp
  800c7d:	6a 01                	push   $0x1
  800c7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800c82:	e8 59 ff ff ff       	call   800be0 <fd_close>
  800c87:	83 c4 10             	add    $0x10,%esp
}
  800c8a:	c9                   	leave  
  800c8b:	c3                   	ret    

00800c8c <close_all>:

void
close_all(void)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800c93:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	53                   	push   %ebx
  800c9c:	e8 c0 ff ff ff       	call   800c61 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ca1:	83 c3 01             	add    $0x1,%ebx
  800ca4:	83 c4 10             	add    $0x10,%esp
  800ca7:	83 fb 20             	cmp    $0x20,%ebx
  800caa:	75 ec                	jne    800c98 <close_all+0xc>
		close(i);
}
  800cac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    

00800cb1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 2c             	sub    $0x2c,%esp
  800cba:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800cbd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800cc0:	50                   	push   %eax
  800cc1:	ff 75 08             	pushl  0x8(%ebp)
  800cc4:	e8 6e fe ff ff       	call   800b37 <fd_lookup>
  800cc9:	83 c4 08             	add    $0x8,%esp
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	0f 88 c1 00 00 00    	js     800d95 <dup+0xe4>
		return r;
	close(newfdnum);
  800cd4:	83 ec 0c             	sub    $0xc,%esp
  800cd7:	56                   	push   %esi
  800cd8:	e8 84 ff ff ff       	call   800c61 <close>

	newfd = INDEX2FD(newfdnum);
  800cdd:	89 f3                	mov    %esi,%ebx
  800cdf:	c1 e3 0c             	shl    $0xc,%ebx
  800ce2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ce8:	83 c4 04             	add    $0x4,%esp
  800ceb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800cee:	e8 de fd ff ff       	call   800ad1 <fd2data>
  800cf3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800cf5:	89 1c 24             	mov    %ebx,(%esp)
  800cf8:	e8 d4 fd ff ff       	call   800ad1 <fd2data>
  800cfd:	83 c4 10             	add    $0x10,%esp
  800d00:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800d03:	89 f8                	mov    %edi,%eax
  800d05:	c1 e8 16             	shr    $0x16,%eax
  800d08:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800d0f:	a8 01                	test   $0x1,%al
  800d11:	74 37                	je     800d4a <dup+0x99>
  800d13:	89 f8                	mov    %edi,%eax
  800d15:	c1 e8 0c             	shr    $0xc,%eax
  800d18:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800d1f:	f6 c2 01             	test   $0x1,%dl
  800d22:	74 26                	je     800d4a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800d24:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d2b:	83 ec 0c             	sub    $0xc,%esp
  800d2e:	25 07 0e 00 00       	and    $0xe07,%eax
  800d33:	50                   	push   %eax
  800d34:	ff 75 d4             	pushl  -0x2c(%ebp)
  800d37:	6a 00                	push   $0x0
  800d39:	57                   	push   %edi
  800d3a:	6a 00                	push   $0x0
  800d3c:	e8 a0 f8 ff ff       	call   8005e1 <sys_page_map>
  800d41:	89 c7                	mov    %eax,%edi
  800d43:	83 c4 20             	add    $0x20,%esp
  800d46:	85 c0                	test   %eax,%eax
  800d48:	78 2e                	js     800d78 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800d4a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d4d:	89 d0                	mov    %edx,%eax
  800d4f:	c1 e8 0c             	shr    $0xc,%eax
  800d52:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	25 07 0e 00 00       	and    $0xe07,%eax
  800d61:	50                   	push   %eax
  800d62:	53                   	push   %ebx
  800d63:	6a 00                	push   $0x0
  800d65:	52                   	push   %edx
  800d66:	6a 00                	push   $0x0
  800d68:	e8 74 f8 ff ff       	call   8005e1 <sys_page_map>
  800d6d:	89 c7                	mov    %eax,%edi
  800d6f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800d72:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800d74:	85 ff                	test   %edi,%edi
  800d76:	79 1d                	jns    800d95 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800d78:	83 ec 08             	sub    $0x8,%esp
  800d7b:	53                   	push   %ebx
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 a0 f8 ff ff       	call   800623 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800d83:	83 c4 08             	add    $0x8,%esp
  800d86:	ff 75 d4             	pushl  -0x2c(%ebp)
  800d89:	6a 00                	push   $0x0
  800d8b:	e8 93 f8 ff ff       	call   800623 <sys_page_unmap>
	return r;
  800d90:	83 c4 10             	add    $0x10,%esp
  800d93:	89 f8                	mov    %edi,%eax
}
  800d95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	53                   	push   %ebx
  800da1:	83 ec 14             	sub    $0x14,%esp
  800da4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800da7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800daa:	50                   	push   %eax
  800dab:	53                   	push   %ebx
  800dac:	e8 86 fd ff ff       	call   800b37 <fd_lookup>
  800db1:	83 c4 08             	add    $0x8,%esp
  800db4:	89 c2                	mov    %eax,%edx
  800db6:	85 c0                	test   %eax,%eax
  800db8:	78 6d                	js     800e27 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dba:	83 ec 08             	sub    $0x8,%esp
  800dbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dc0:	50                   	push   %eax
  800dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dc4:	ff 30                	pushl  (%eax)
  800dc6:	e8 c2 fd ff ff       	call   800b8d <dev_lookup>
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	78 4c                	js     800e1e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800dd2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dd5:	8b 42 08             	mov    0x8(%edx),%eax
  800dd8:	83 e0 03             	and    $0x3,%eax
  800ddb:	83 f8 01             	cmp    $0x1,%eax
  800dde:	75 21                	jne    800e01 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800de0:	a1 04 40 80 00       	mov    0x804004,%eax
  800de5:	8b 40 54             	mov    0x54(%eax),%eax
  800de8:	83 ec 04             	sub    $0x4,%esp
  800deb:	53                   	push   %ebx
  800dec:	50                   	push   %eax
  800ded:	68 59 23 80 00       	push   $0x802359
  800df2:	e8 8d 0a 00 00       	call   801884 <cprintf>
		return -E_INVAL;
  800df7:	83 c4 10             	add    $0x10,%esp
  800dfa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800dff:	eb 26                	jmp    800e27 <read+0x8a>
	}
	if (!dev->dev_read)
  800e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e04:	8b 40 08             	mov    0x8(%eax),%eax
  800e07:	85 c0                	test   %eax,%eax
  800e09:	74 17                	je     800e22 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	ff 75 10             	pushl  0x10(%ebp)
  800e11:	ff 75 0c             	pushl  0xc(%ebp)
  800e14:	52                   	push   %edx
  800e15:	ff d0                	call   *%eax
  800e17:	89 c2                	mov    %eax,%edx
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	eb 09                	jmp    800e27 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e1e:	89 c2                	mov    %eax,%edx
  800e20:	eb 05                	jmp    800e27 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800e22:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800e27:	89 d0                	mov    %edx,%eax
  800e29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2c:	c9                   	leave  
  800e2d:	c3                   	ret    

00800e2e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e3a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800e3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e42:	eb 21                	jmp    800e65 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800e44:	83 ec 04             	sub    $0x4,%esp
  800e47:	89 f0                	mov    %esi,%eax
  800e49:	29 d8                	sub    %ebx,%eax
  800e4b:	50                   	push   %eax
  800e4c:	89 d8                	mov    %ebx,%eax
  800e4e:	03 45 0c             	add    0xc(%ebp),%eax
  800e51:	50                   	push   %eax
  800e52:	57                   	push   %edi
  800e53:	e8 45 ff ff ff       	call   800d9d <read>
		if (m < 0)
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	78 10                	js     800e6f <readn+0x41>
			return m;
		if (m == 0)
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	74 0a                	je     800e6d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800e63:	01 c3                	add    %eax,%ebx
  800e65:	39 f3                	cmp    %esi,%ebx
  800e67:	72 db                	jb     800e44 <readn+0x16>
  800e69:	89 d8                	mov    %ebx,%eax
  800e6b:	eb 02                	jmp    800e6f <readn+0x41>
  800e6d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800e6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	53                   	push   %ebx
  800e7b:	83 ec 14             	sub    $0x14,%esp
  800e7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e84:	50                   	push   %eax
  800e85:	53                   	push   %ebx
  800e86:	e8 ac fc ff ff       	call   800b37 <fd_lookup>
  800e8b:	83 c4 08             	add    $0x8,%esp
  800e8e:	89 c2                	mov    %eax,%edx
  800e90:	85 c0                	test   %eax,%eax
  800e92:	78 68                	js     800efc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e94:	83 ec 08             	sub    $0x8,%esp
  800e97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9a:	50                   	push   %eax
  800e9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9e:	ff 30                	pushl  (%eax)
  800ea0:	e8 e8 fc ff ff       	call   800b8d <dev_lookup>
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	78 47                	js     800ef3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800eac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eaf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800eb3:	75 21                	jne    800ed6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800eb5:	a1 04 40 80 00       	mov    0x804004,%eax
  800eba:	8b 40 54             	mov    0x54(%eax),%eax
  800ebd:	83 ec 04             	sub    $0x4,%esp
  800ec0:	53                   	push   %ebx
  800ec1:	50                   	push   %eax
  800ec2:	68 75 23 80 00       	push   $0x802375
  800ec7:	e8 b8 09 00 00       	call   801884 <cprintf>
		return -E_INVAL;
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ed4:	eb 26                	jmp    800efc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ed6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ed9:	8b 52 0c             	mov    0xc(%edx),%edx
  800edc:	85 d2                	test   %edx,%edx
  800ede:	74 17                	je     800ef7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ee0:	83 ec 04             	sub    $0x4,%esp
  800ee3:	ff 75 10             	pushl  0x10(%ebp)
  800ee6:	ff 75 0c             	pushl  0xc(%ebp)
  800ee9:	50                   	push   %eax
  800eea:	ff d2                	call   *%edx
  800eec:	89 c2                	mov    %eax,%edx
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	eb 09                	jmp    800efc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ef3:	89 c2                	mov    %eax,%edx
  800ef5:	eb 05                	jmp    800efc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ef7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800efc:	89 d0                	mov    %edx,%eax
  800efe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <seek>:

int
seek(int fdnum, off_t offset)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f09:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800f0c:	50                   	push   %eax
  800f0d:	ff 75 08             	pushl  0x8(%ebp)
  800f10:	e8 22 fc ff ff       	call   800b37 <fd_lookup>
  800f15:	83 c4 08             	add    $0x8,%esp
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 0e                	js     800f2a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800f1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800f1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f22:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    

00800f2c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	83 ec 14             	sub    $0x14,%esp
  800f33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800f36:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f39:	50                   	push   %eax
  800f3a:	53                   	push   %ebx
  800f3b:	e8 f7 fb ff ff       	call   800b37 <fd_lookup>
  800f40:	83 c4 08             	add    $0x8,%esp
  800f43:	89 c2                	mov    %eax,%edx
  800f45:	85 c0                	test   %eax,%eax
  800f47:	78 65                	js     800fae <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800f49:	83 ec 08             	sub    $0x8,%esp
  800f4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f4f:	50                   	push   %eax
  800f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f53:	ff 30                	pushl  (%eax)
  800f55:	e8 33 fc ff ff       	call   800b8d <dev_lookup>
  800f5a:	83 c4 10             	add    $0x10,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 44                	js     800fa5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f64:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800f68:	75 21                	jne    800f8b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800f6a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800f6f:	8b 40 54             	mov    0x54(%eax),%eax
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	53                   	push   %ebx
  800f76:	50                   	push   %eax
  800f77:	68 38 23 80 00       	push   $0x802338
  800f7c:	e8 03 09 00 00       	call   801884 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800f89:	eb 23                	jmp    800fae <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800f8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f8e:	8b 52 18             	mov    0x18(%edx),%edx
  800f91:	85 d2                	test   %edx,%edx
  800f93:	74 14                	je     800fa9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800f95:	83 ec 08             	sub    $0x8,%esp
  800f98:	ff 75 0c             	pushl  0xc(%ebp)
  800f9b:	50                   	push   %eax
  800f9c:	ff d2                	call   *%edx
  800f9e:	89 c2                	mov    %eax,%edx
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	eb 09                	jmp    800fae <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fa5:	89 c2                	mov    %eax,%edx
  800fa7:	eb 05                	jmp    800fae <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800fa9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800fae:	89 d0                	mov    %edx,%eax
  800fb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 14             	sub    $0x14,%esp
  800fbc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc2:	50                   	push   %eax
  800fc3:	ff 75 08             	pushl  0x8(%ebp)
  800fc6:	e8 6c fb ff ff       	call   800b37 <fd_lookup>
  800fcb:	83 c4 08             	add    $0x8,%esp
  800fce:	89 c2                	mov    %eax,%edx
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 58                	js     80102c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fd4:	83 ec 08             	sub    $0x8,%esp
  800fd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fda:	50                   	push   %eax
  800fdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fde:	ff 30                	pushl  (%eax)
  800fe0:	e8 a8 fb ff ff       	call   800b8d <dev_lookup>
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 37                	js     801023 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800fec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ff3:	74 32                	je     801027 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ff5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800ff8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800fff:	00 00 00 
	stat->st_isdir = 0;
  801002:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801009:	00 00 00 
	stat->st_dev = dev;
  80100c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801012:	83 ec 08             	sub    $0x8,%esp
  801015:	53                   	push   %ebx
  801016:	ff 75 f0             	pushl  -0x10(%ebp)
  801019:	ff 50 14             	call   *0x14(%eax)
  80101c:	89 c2                	mov    %eax,%edx
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	eb 09                	jmp    80102c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801023:	89 c2                	mov    %eax,%edx
  801025:	eb 05                	jmp    80102c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801027:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80102c:	89 d0                	mov    %edx,%eax
  80102e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	56                   	push   %esi
  801037:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801038:	83 ec 08             	sub    $0x8,%esp
  80103b:	6a 00                	push   $0x0
  80103d:	ff 75 08             	pushl  0x8(%ebp)
  801040:	e8 e3 01 00 00       	call   801228 <open>
  801045:	89 c3                	mov    %eax,%ebx
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	78 1b                	js     801069 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80104e:	83 ec 08             	sub    $0x8,%esp
  801051:	ff 75 0c             	pushl  0xc(%ebp)
  801054:	50                   	push   %eax
  801055:	e8 5b ff ff ff       	call   800fb5 <fstat>
  80105a:	89 c6                	mov    %eax,%esi
	close(fd);
  80105c:	89 1c 24             	mov    %ebx,(%esp)
  80105f:	e8 fd fb ff ff       	call   800c61 <close>
	return r;
  801064:	83 c4 10             	add    $0x10,%esp
  801067:	89 f0                	mov    %esi,%eax
}
  801069:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	56                   	push   %esi
  801074:	53                   	push   %ebx
  801075:	89 c6                	mov    %eax,%esi
  801077:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801079:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801080:	75 12                	jne    801094 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	6a 01                	push   $0x1
  801087:	e8 ad 0e 00 00       	call   801f39 <ipc_find_env>
  80108c:	a3 00 40 80 00       	mov    %eax,0x804000
  801091:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801094:	6a 07                	push   $0x7
  801096:	68 00 50 80 00       	push   $0x805000
  80109b:	56                   	push   %esi
  80109c:	ff 35 00 40 80 00    	pushl  0x804000
  8010a2:	e8 30 0e 00 00       	call   801ed7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8010a7:	83 c4 0c             	add    $0xc,%esp
  8010aa:	6a 00                	push   $0x0
  8010ac:	53                   	push   %ebx
  8010ad:	6a 00                	push   $0x0
  8010af:	e8 ab 0d 00 00       	call   801e5f <ipc_recv>
}
  8010b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b7:	5b                   	pop    %ebx
  8010b8:	5e                   	pop    %esi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8010c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8010c7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8010cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010cf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8010d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8010de:	e8 8d ff ff ff       	call   801070 <fsipc>
}
  8010e3:	c9                   	leave  
  8010e4:	c3                   	ret    

008010e5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8010eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8010f1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8010f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fb:	b8 06 00 00 00       	mov    $0x6,%eax
  801100:	e8 6b ff ff ff       	call   801070 <fsipc>
}
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	53                   	push   %ebx
  80110b:	83 ec 04             	sub    $0x4,%esp
  80110e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	8b 40 0c             	mov    0xc(%eax),%eax
  801117:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80111c:	ba 00 00 00 00       	mov    $0x0,%edx
  801121:	b8 05 00 00 00       	mov    $0x5,%eax
  801126:	e8 45 ff ff ff       	call   801070 <fsipc>
  80112b:	85 c0                	test   %eax,%eax
  80112d:	78 2c                	js     80115b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80112f:	83 ec 08             	sub    $0x8,%esp
  801132:	68 00 50 80 00       	push   $0x805000
  801137:	53                   	push   %ebx
  801138:	e8 5e f0 ff ff       	call   80019b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80113d:	a1 80 50 80 00       	mov    0x805080,%eax
  801142:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801148:	a1 84 50 80 00       	mov    0x805084,%eax
  80114d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80115b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801169:	8b 55 08             	mov    0x8(%ebp),%edx
  80116c:	8b 52 0c             	mov    0xc(%edx),%edx
  80116f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801175:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80117a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80117f:	0f 47 c2             	cmova  %edx,%eax
  801182:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801187:	50                   	push   %eax
  801188:	ff 75 0c             	pushl  0xc(%ebp)
  80118b:	68 08 50 80 00       	push   $0x805008
  801190:	e8 98 f1 ff ff       	call   80032d <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801195:	ba 00 00 00 00       	mov    $0x0,%edx
  80119a:	b8 04 00 00 00       	mov    $0x4,%eax
  80119f:	e8 cc fe ff ff       	call   801070 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  8011a4:	c9                   	leave  
  8011a5:	c3                   	ret    

008011a6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	56                   	push   %esi
  8011aa:	53                   	push   %ebx
  8011ab:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8011ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b1:	8b 40 0c             	mov    0xc(%eax),%eax
  8011b4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8011b9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8011bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c4:	b8 03 00 00 00       	mov    $0x3,%eax
  8011c9:	e8 a2 fe ff ff       	call   801070 <fsipc>
  8011ce:	89 c3                	mov    %eax,%ebx
  8011d0:	85 c0                	test   %eax,%eax
  8011d2:	78 4b                	js     80121f <devfile_read+0x79>
		return r;
	assert(r <= n);
  8011d4:	39 c6                	cmp    %eax,%esi
  8011d6:	73 16                	jae    8011ee <devfile_read+0x48>
  8011d8:	68 a4 23 80 00       	push   $0x8023a4
  8011dd:	68 ab 23 80 00       	push   $0x8023ab
  8011e2:	6a 7c                	push   $0x7c
  8011e4:	68 c0 23 80 00       	push   $0x8023c0
  8011e9:	e8 bd 05 00 00       	call   8017ab <_panic>
	assert(r <= PGSIZE);
  8011ee:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8011f3:	7e 16                	jle    80120b <devfile_read+0x65>
  8011f5:	68 cb 23 80 00       	push   $0x8023cb
  8011fa:	68 ab 23 80 00       	push   $0x8023ab
  8011ff:	6a 7d                	push   $0x7d
  801201:	68 c0 23 80 00       	push   $0x8023c0
  801206:	e8 a0 05 00 00       	call   8017ab <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80120b:	83 ec 04             	sub    $0x4,%esp
  80120e:	50                   	push   %eax
  80120f:	68 00 50 80 00       	push   $0x805000
  801214:	ff 75 0c             	pushl  0xc(%ebp)
  801217:	e8 11 f1 ff ff       	call   80032d <memmove>
	return r;
  80121c:	83 c4 10             	add    $0x10,%esp
}
  80121f:	89 d8                	mov    %ebx,%eax
  801221:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 20             	sub    $0x20,%esp
  80122f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801232:	53                   	push   %ebx
  801233:	e8 2a ef ff ff       	call   800162 <strlen>
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801240:	7f 67                	jg     8012a9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801242:	83 ec 0c             	sub    $0xc,%esp
  801245:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801248:	50                   	push   %eax
  801249:	e8 9a f8 ff ff       	call   800ae8 <fd_alloc>
  80124e:	83 c4 10             	add    $0x10,%esp
		return r;
  801251:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801253:	85 c0                	test   %eax,%eax
  801255:	78 57                	js     8012ae <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801257:	83 ec 08             	sub    $0x8,%esp
  80125a:	53                   	push   %ebx
  80125b:	68 00 50 80 00       	push   $0x805000
  801260:	e8 36 ef ff ff       	call   80019b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801265:	8b 45 0c             	mov    0xc(%ebp),%eax
  801268:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80126d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801270:	b8 01 00 00 00       	mov    $0x1,%eax
  801275:	e8 f6 fd ff ff       	call   801070 <fsipc>
  80127a:	89 c3                	mov    %eax,%ebx
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	79 14                	jns    801297 <open+0x6f>
		fd_close(fd, 0);
  801283:	83 ec 08             	sub    $0x8,%esp
  801286:	6a 00                	push   $0x0
  801288:	ff 75 f4             	pushl  -0xc(%ebp)
  80128b:	e8 50 f9 ff ff       	call   800be0 <fd_close>
		return r;
  801290:	83 c4 10             	add    $0x10,%esp
  801293:	89 da                	mov    %ebx,%edx
  801295:	eb 17                	jmp    8012ae <open+0x86>
	}

	return fd2num(fd);
  801297:	83 ec 0c             	sub    $0xc,%esp
  80129a:	ff 75 f4             	pushl  -0xc(%ebp)
  80129d:	e8 1f f8 ff ff       	call   800ac1 <fd2num>
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	eb 05                	jmp    8012ae <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8012a9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8012ae:	89 d0                	mov    %edx,%eax
  8012b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b3:	c9                   	leave  
  8012b4:	c3                   	ret    

008012b5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8012bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c0:	b8 08 00 00 00       	mov    $0x8,%eax
  8012c5:	e8 a6 fd ff ff       	call   801070 <fsipc>
}
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    

008012cc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	56                   	push   %esi
  8012d0:	53                   	push   %ebx
  8012d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8012d4:	83 ec 0c             	sub    $0xc,%esp
  8012d7:	ff 75 08             	pushl  0x8(%ebp)
  8012da:	e8 f2 f7 ff ff       	call   800ad1 <fd2data>
  8012df:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	68 d7 23 80 00       	push   $0x8023d7
  8012e9:	53                   	push   %ebx
  8012ea:	e8 ac ee ff ff       	call   80019b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8012ef:	8b 46 04             	mov    0x4(%esi),%eax
  8012f2:	2b 06                	sub    (%esi),%eax
  8012f4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8012fa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801301:	00 00 00 
	stat->st_dev = &devpipe;
  801304:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80130b:	30 80 00 
	return 0;
}
  80130e:	b8 00 00 00 00       	mov    $0x0,%eax
  801313:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801316:	5b                   	pop    %ebx
  801317:	5e                   	pop    %esi
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
  80131d:	53                   	push   %ebx
  80131e:	83 ec 0c             	sub    $0xc,%esp
  801321:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801324:	53                   	push   %ebx
  801325:	6a 00                	push   $0x0
  801327:	e8 f7 f2 ff ff       	call   800623 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80132c:	89 1c 24             	mov    %ebx,(%esp)
  80132f:	e8 9d f7 ff ff       	call   800ad1 <fd2data>
  801334:	83 c4 08             	add    $0x8,%esp
  801337:	50                   	push   %eax
  801338:	6a 00                	push   $0x0
  80133a:	e8 e4 f2 ff ff       	call   800623 <sys_page_unmap>
}
  80133f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801342:	c9                   	leave  
  801343:	c3                   	ret    

00801344 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	57                   	push   %edi
  801348:	56                   	push   %esi
  801349:	53                   	push   %ebx
  80134a:	83 ec 1c             	sub    $0x1c,%esp
  80134d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801350:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801352:	a1 04 40 80 00       	mov    0x804004,%eax
  801357:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	ff 75 e0             	pushl  -0x20(%ebp)
  801360:	e8 14 0c 00 00       	call   801f79 <pageref>
  801365:	89 c3                	mov    %eax,%ebx
  801367:	89 3c 24             	mov    %edi,(%esp)
  80136a:	e8 0a 0c 00 00       	call   801f79 <pageref>
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	39 c3                	cmp    %eax,%ebx
  801374:	0f 94 c1             	sete   %cl
  801377:	0f b6 c9             	movzbl %cl,%ecx
  80137a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80137d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801383:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  801386:	39 ce                	cmp    %ecx,%esi
  801388:	74 1b                	je     8013a5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80138a:	39 c3                	cmp    %eax,%ebx
  80138c:	75 c4                	jne    801352 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80138e:	8b 42 64             	mov    0x64(%edx),%eax
  801391:	ff 75 e4             	pushl  -0x1c(%ebp)
  801394:	50                   	push   %eax
  801395:	56                   	push   %esi
  801396:	68 de 23 80 00       	push   $0x8023de
  80139b:	e8 e4 04 00 00       	call   801884 <cprintf>
  8013a0:	83 c4 10             	add    $0x10,%esp
  8013a3:	eb ad                	jmp    801352 <_pipeisclosed+0xe>
	}
}
  8013a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ab:	5b                   	pop    %ebx
  8013ac:	5e                   	pop    %esi
  8013ad:	5f                   	pop    %edi
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    

008013b0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	57                   	push   %edi
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 28             	sub    $0x28,%esp
  8013b9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8013bc:	56                   	push   %esi
  8013bd:	e8 0f f7 ff ff       	call   800ad1 <fd2data>
  8013c2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	bf 00 00 00 00       	mov    $0x0,%edi
  8013cc:	eb 4b                	jmp    801419 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8013ce:	89 da                	mov    %ebx,%edx
  8013d0:	89 f0                	mov    %esi,%eax
  8013d2:	e8 6d ff ff ff       	call   801344 <_pipeisclosed>
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	75 48                	jne    801423 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8013db:	e8 9f f1 ff ff       	call   80057f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8013e0:	8b 43 04             	mov    0x4(%ebx),%eax
  8013e3:	8b 0b                	mov    (%ebx),%ecx
  8013e5:	8d 51 20             	lea    0x20(%ecx),%edx
  8013e8:	39 d0                	cmp    %edx,%eax
  8013ea:	73 e2                	jae    8013ce <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8013ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ef:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8013f3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	c1 fa 1f             	sar    $0x1f,%edx
  8013fb:	89 d1                	mov    %edx,%ecx
  8013fd:	c1 e9 1b             	shr    $0x1b,%ecx
  801400:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801403:	83 e2 1f             	and    $0x1f,%edx
  801406:	29 ca                	sub    %ecx,%edx
  801408:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80140c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801410:	83 c0 01             	add    $0x1,%eax
  801413:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801416:	83 c7 01             	add    $0x1,%edi
  801419:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80141c:	75 c2                	jne    8013e0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80141e:	8b 45 10             	mov    0x10(%ebp),%eax
  801421:	eb 05                	jmp    801428 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801423:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801428:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5e                   	pop    %esi
  80142d:	5f                   	pop    %edi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	57                   	push   %edi
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	83 ec 18             	sub    $0x18,%esp
  801439:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80143c:	57                   	push   %edi
  80143d:	e8 8f f6 ff ff       	call   800ad1 <fd2data>
  801442:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	bb 00 00 00 00       	mov    $0x0,%ebx
  80144c:	eb 3d                	jmp    80148b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80144e:	85 db                	test   %ebx,%ebx
  801450:	74 04                	je     801456 <devpipe_read+0x26>
				return i;
  801452:	89 d8                	mov    %ebx,%eax
  801454:	eb 44                	jmp    80149a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801456:	89 f2                	mov    %esi,%edx
  801458:	89 f8                	mov    %edi,%eax
  80145a:	e8 e5 fe ff ff       	call   801344 <_pipeisclosed>
  80145f:	85 c0                	test   %eax,%eax
  801461:	75 32                	jne    801495 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801463:	e8 17 f1 ff ff       	call   80057f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801468:	8b 06                	mov    (%esi),%eax
  80146a:	3b 46 04             	cmp    0x4(%esi),%eax
  80146d:	74 df                	je     80144e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80146f:	99                   	cltd   
  801470:	c1 ea 1b             	shr    $0x1b,%edx
  801473:	01 d0                	add    %edx,%eax
  801475:	83 e0 1f             	and    $0x1f,%eax
  801478:	29 d0                	sub    %edx,%eax
  80147a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80147f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801482:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801485:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801488:	83 c3 01             	add    $0x1,%ebx
  80148b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80148e:	75 d8                	jne    801468 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801490:	8b 45 10             	mov    0x10(%ebp),%eax
  801493:	eb 05                	jmp    80149a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801495:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80149a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149d:	5b                   	pop    %ebx
  80149e:	5e                   	pop    %esi
  80149f:	5f                   	pop    %edi
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	56                   	push   %esi
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8014aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	e8 35 f6 ff ff       	call   800ae8 <fd_alloc>
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	89 c2                	mov    %eax,%edx
  8014b8:	85 c0                	test   %eax,%eax
  8014ba:	0f 88 2c 01 00 00    	js     8015ec <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	68 07 04 00 00       	push   $0x407
  8014c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cb:	6a 00                	push   $0x0
  8014cd:	e8 cc f0 ff ff       	call   80059e <sys_page_alloc>
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	89 c2                	mov    %eax,%edx
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	0f 88 0d 01 00 00    	js     8015ec <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8014df:	83 ec 0c             	sub    $0xc,%esp
  8014e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e5:	50                   	push   %eax
  8014e6:	e8 fd f5 ff ff       	call   800ae8 <fd_alloc>
  8014eb:	89 c3                	mov    %eax,%ebx
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	0f 88 e2 00 00 00    	js     8015da <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8014f8:	83 ec 04             	sub    $0x4,%esp
  8014fb:	68 07 04 00 00       	push   $0x407
  801500:	ff 75 f0             	pushl  -0x10(%ebp)
  801503:	6a 00                	push   $0x0
  801505:	e8 94 f0 ff ff       	call   80059e <sys_page_alloc>
  80150a:	89 c3                	mov    %eax,%ebx
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	85 c0                	test   %eax,%eax
  801511:	0f 88 c3 00 00 00    	js     8015da <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801517:	83 ec 0c             	sub    $0xc,%esp
  80151a:	ff 75 f4             	pushl  -0xc(%ebp)
  80151d:	e8 af f5 ff ff       	call   800ad1 <fd2data>
  801522:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801524:	83 c4 0c             	add    $0xc,%esp
  801527:	68 07 04 00 00       	push   $0x407
  80152c:	50                   	push   %eax
  80152d:	6a 00                	push   $0x0
  80152f:	e8 6a f0 ff ff       	call   80059e <sys_page_alloc>
  801534:	89 c3                	mov    %eax,%ebx
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	0f 88 89 00 00 00    	js     8015ca <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801541:	83 ec 0c             	sub    $0xc,%esp
  801544:	ff 75 f0             	pushl  -0x10(%ebp)
  801547:	e8 85 f5 ff ff       	call   800ad1 <fd2data>
  80154c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801553:	50                   	push   %eax
  801554:	6a 00                	push   $0x0
  801556:	56                   	push   %esi
  801557:	6a 00                	push   $0x0
  801559:	e8 83 f0 ff ff       	call   8005e1 <sys_page_map>
  80155e:	89 c3                	mov    %eax,%ebx
  801560:	83 c4 20             	add    $0x20,%esp
  801563:	85 c0                	test   %eax,%eax
  801565:	78 55                	js     8015bc <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801567:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80156d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801570:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801572:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801575:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80157c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	ff 75 f4             	pushl  -0xc(%ebp)
  801597:	e8 25 f5 ff ff       	call   800ac1 <fd2num>
  80159c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80159f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8015a1:	83 c4 04             	add    $0x4,%esp
  8015a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8015a7:	e8 15 f5 ff ff       	call   800ac1 <fd2num>
  8015ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015af:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ba:	eb 30                	jmp    8015ec <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	56                   	push   %esi
  8015c0:	6a 00                	push   $0x0
  8015c2:	e8 5c f0 ff ff       	call   800623 <sys_page_unmap>
  8015c7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8015d0:	6a 00                	push   $0x0
  8015d2:	e8 4c f0 ff ff       	call   800623 <sys_page_unmap>
  8015d7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e0:	6a 00                	push   $0x0
  8015e2:	e8 3c f0 ff ff       	call   800623 <sys_page_unmap>
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8015ec:	89 d0                	mov    %edx,%eax
  8015ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f1:	5b                   	pop    %ebx
  8015f2:	5e                   	pop    %esi
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    

008015f5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fe:	50                   	push   %eax
  8015ff:	ff 75 08             	pushl  0x8(%ebp)
  801602:	e8 30 f5 ff ff       	call   800b37 <fd_lookup>
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 18                	js     801626 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80160e:	83 ec 0c             	sub    $0xc,%esp
  801611:	ff 75 f4             	pushl  -0xc(%ebp)
  801614:	e8 b8 f4 ff ff       	call   800ad1 <fd2data>
	return _pipeisclosed(fd, p);
  801619:	89 c2                	mov    %eax,%edx
  80161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161e:	e8 21 fd ff ff       	call   801344 <_pipeisclosed>
  801623:	83 c4 10             	add    $0x10,%esp
}
  801626:	c9                   	leave  
  801627:	c3                   	ret    

00801628 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80162b:	b8 00 00 00 00       	mov    $0x0,%eax
  801630:	5d                   	pop    %ebp
  801631:	c3                   	ret    

00801632 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801638:	68 f6 23 80 00       	push   $0x8023f6
  80163d:	ff 75 0c             	pushl  0xc(%ebp)
  801640:	e8 56 eb ff ff       	call   80019b <strcpy>
	return 0;
}
  801645:	b8 00 00 00 00       	mov    $0x0,%eax
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	57                   	push   %edi
  801650:	56                   	push   %esi
  801651:	53                   	push   %ebx
  801652:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801658:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80165d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801663:	eb 2d                	jmp    801692 <devcons_write+0x46>
		m = n - tot;
  801665:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801668:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80166a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80166d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801672:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801675:	83 ec 04             	sub    $0x4,%esp
  801678:	53                   	push   %ebx
  801679:	03 45 0c             	add    0xc(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	57                   	push   %edi
  80167e:	e8 aa ec ff ff       	call   80032d <memmove>
		sys_cputs(buf, m);
  801683:	83 c4 08             	add    $0x8,%esp
  801686:	53                   	push   %ebx
  801687:	57                   	push   %edi
  801688:	e8 55 ee ff ff       	call   8004e2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80168d:	01 de                	add    %ebx,%esi
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	89 f0                	mov    %esi,%eax
  801694:	3b 75 10             	cmp    0x10(%ebp),%esi
  801697:	72 cc                	jb     801665 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801699:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80169c:	5b                   	pop    %ebx
  80169d:	5e                   	pop    %esi
  80169e:	5f                   	pop    %edi
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 08             	sub    $0x8,%esp
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8016ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8016b0:	74 2a                	je     8016dc <devcons_read+0x3b>
  8016b2:	eb 05                	jmp    8016b9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8016b4:	e8 c6 ee ff ff       	call   80057f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8016b9:	e8 42 ee ff ff       	call   800500 <sys_cgetc>
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	74 f2                	je     8016b4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	78 16                	js     8016dc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8016c6:	83 f8 04             	cmp    $0x4,%eax
  8016c9:	74 0c                	je     8016d7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8016cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ce:	88 02                	mov    %al,(%edx)
	return 1;
  8016d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d5:	eb 05                	jmp    8016dc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8016d7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8016e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8016ea:	6a 01                	push   $0x1
  8016ec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8016ef:	50                   	push   %eax
  8016f0:	e8 ed ed ff ff       	call   8004e2 <sys_cputs>
}
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <getchar>:

int
getchar(void)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801700:	6a 01                	push   $0x1
  801702:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801705:	50                   	push   %eax
  801706:	6a 00                	push   $0x0
  801708:	e8 90 f6 ff ff       	call   800d9d <read>
	if (r < 0)
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	85 c0                	test   %eax,%eax
  801712:	78 0f                	js     801723 <getchar+0x29>
		return r;
	if (r < 1)
  801714:	85 c0                	test   %eax,%eax
  801716:	7e 06                	jle    80171e <getchar+0x24>
		return -E_EOF;
	return c;
  801718:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80171c:	eb 05                	jmp    801723 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80171e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80172b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172e:	50                   	push   %eax
  80172f:	ff 75 08             	pushl  0x8(%ebp)
  801732:	e8 00 f4 ff ff       	call   800b37 <fd_lookup>
  801737:	83 c4 10             	add    $0x10,%esp
  80173a:	85 c0                	test   %eax,%eax
  80173c:	78 11                	js     80174f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80173e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801741:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801747:	39 10                	cmp    %edx,(%eax)
  801749:	0f 94 c0             	sete   %al
  80174c:	0f b6 c0             	movzbl %al,%eax
}
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <opencons>:

int
opencons(void)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801757:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175a:	50                   	push   %eax
  80175b:	e8 88 f3 ff ff       	call   800ae8 <fd_alloc>
  801760:	83 c4 10             	add    $0x10,%esp
		return r;
  801763:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801765:	85 c0                	test   %eax,%eax
  801767:	78 3e                	js     8017a7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801769:	83 ec 04             	sub    $0x4,%esp
  80176c:	68 07 04 00 00       	push   $0x407
  801771:	ff 75 f4             	pushl  -0xc(%ebp)
  801774:	6a 00                	push   $0x0
  801776:	e8 23 ee ff ff       	call   80059e <sys_page_alloc>
  80177b:	83 c4 10             	add    $0x10,%esp
		return r;
  80177e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801780:	85 c0                	test   %eax,%eax
  801782:	78 23                	js     8017a7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801784:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80178a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80178d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80178f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801792:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801799:	83 ec 0c             	sub    $0xc,%esp
  80179c:	50                   	push   %eax
  80179d:	e8 1f f3 ff ff       	call   800ac1 <fd2num>
  8017a2:	89 c2                	mov    %eax,%edx
  8017a4:	83 c4 10             	add    $0x10,%esp
}
  8017a7:	89 d0                	mov    %edx,%eax
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	56                   	push   %esi
  8017af:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8017b0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8017b3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8017b9:	e8 a2 ed ff ff       	call   800560 <sys_getenvid>
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	ff 75 0c             	pushl  0xc(%ebp)
  8017c4:	ff 75 08             	pushl  0x8(%ebp)
  8017c7:	56                   	push   %esi
  8017c8:	50                   	push   %eax
  8017c9:	68 04 24 80 00       	push   $0x802404
  8017ce:	e8 b1 00 00 00       	call   801884 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8017d3:	83 c4 18             	add    $0x18,%esp
  8017d6:	53                   	push   %ebx
  8017d7:	ff 75 10             	pushl  0x10(%ebp)
  8017da:	e8 54 00 00 00       	call   801833 <vcprintf>
	cprintf("\n");
  8017df:	c7 04 24 ef 23 80 00 	movl   $0x8023ef,(%esp)
  8017e6:	e8 99 00 00 00       	call   801884 <cprintf>
  8017eb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8017ee:	cc                   	int3   
  8017ef:	eb fd                	jmp    8017ee <_panic+0x43>

008017f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	53                   	push   %ebx
  8017f5:	83 ec 04             	sub    $0x4,%esp
  8017f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8017fb:	8b 13                	mov    (%ebx),%edx
  8017fd:	8d 42 01             	lea    0x1(%edx),%eax
  801800:	89 03                	mov    %eax,(%ebx)
  801802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801805:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801809:	3d ff 00 00 00       	cmp    $0xff,%eax
  80180e:	75 1a                	jne    80182a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	68 ff 00 00 00       	push   $0xff
  801818:	8d 43 08             	lea    0x8(%ebx),%eax
  80181b:	50                   	push   %eax
  80181c:	e8 c1 ec ff ff       	call   8004e2 <sys_cputs>
		b->idx = 0;
  801821:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801827:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80182a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80182e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80183c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801843:	00 00 00 
	b.cnt = 0;
  801846:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80184d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801850:	ff 75 0c             	pushl  0xc(%ebp)
  801853:	ff 75 08             	pushl  0x8(%ebp)
  801856:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80185c:	50                   	push   %eax
  80185d:	68 f1 17 80 00       	push   $0x8017f1
  801862:	e8 54 01 00 00       	call   8019bb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801867:	83 c4 08             	add    $0x8,%esp
  80186a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801870:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801876:	50                   	push   %eax
  801877:	e8 66 ec ff ff       	call   8004e2 <sys_cputs>

	return b.cnt;
}
  80187c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801882:	c9                   	leave  
  801883:	c3                   	ret    

00801884 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80188a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80188d:	50                   	push   %eax
  80188e:	ff 75 08             	pushl  0x8(%ebp)
  801891:	e8 9d ff ff ff       	call   801833 <vcprintf>
	va_end(ap);

	return cnt;
}
  801896:	c9                   	leave  
  801897:	c3                   	ret    

00801898 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	57                   	push   %edi
  80189c:	56                   	push   %esi
  80189d:	53                   	push   %ebx
  80189e:	83 ec 1c             	sub    $0x1c,%esp
  8018a1:	89 c7                	mov    %eax,%edi
  8018a3:	89 d6                	mov    %edx,%esi
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018ae:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8018b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8018b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018b9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8018bc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8018bf:	39 d3                	cmp    %edx,%ebx
  8018c1:	72 05                	jb     8018c8 <printnum+0x30>
  8018c3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8018c6:	77 45                	ja     80190d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8018c8:	83 ec 0c             	sub    $0xc,%esp
  8018cb:	ff 75 18             	pushl  0x18(%ebp)
  8018ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8018d4:	53                   	push   %ebx
  8018d5:	ff 75 10             	pushl  0x10(%ebp)
  8018d8:	83 ec 08             	sub    $0x8,%esp
  8018db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018de:	ff 75 e0             	pushl  -0x20(%ebp)
  8018e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8018e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8018e7:	e8 d4 06 00 00       	call   801fc0 <__udivdi3>
  8018ec:	83 c4 18             	add    $0x18,%esp
  8018ef:	52                   	push   %edx
  8018f0:	50                   	push   %eax
  8018f1:	89 f2                	mov    %esi,%edx
  8018f3:	89 f8                	mov    %edi,%eax
  8018f5:	e8 9e ff ff ff       	call   801898 <printnum>
  8018fa:	83 c4 20             	add    $0x20,%esp
  8018fd:	eb 18                	jmp    801917 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	56                   	push   %esi
  801903:	ff 75 18             	pushl  0x18(%ebp)
  801906:	ff d7                	call   *%edi
  801908:	83 c4 10             	add    $0x10,%esp
  80190b:	eb 03                	jmp    801910 <printnum+0x78>
  80190d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801910:	83 eb 01             	sub    $0x1,%ebx
  801913:	85 db                	test   %ebx,%ebx
  801915:	7f e8                	jg     8018ff <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801917:	83 ec 08             	sub    $0x8,%esp
  80191a:	56                   	push   %esi
  80191b:	83 ec 04             	sub    $0x4,%esp
  80191e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801921:	ff 75 e0             	pushl  -0x20(%ebp)
  801924:	ff 75 dc             	pushl  -0x24(%ebp)
  801927:	ff 75 d8             	pushl  -0x28(%ebp)
  80192a:	e8 c1 07 00 00       	call   8020f0 <__umoddi3>
  80192f:	83 c4 14             	add    $0x14,%esp
  801932:	0f be 80 27 24 80 00 	movsbl 0x802427(%eax),%eax
  801939:	50                   	push   %eax
  80193a:	ff d7                	call   *%edi
}
  80193c:	83 c4 10             	add    $0x10,%esp
  80193f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801942:	5b                   	pop    %ebx
  801943:	5e                   	pop    %esi
  801944:	5f                   	pop    %edi
  801945:	5d                   	pop    %ebp
  801946:	c3                   	ret    

00801947 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80194a:	83 fa 01             	cmp    $0x1,%edx
  80194d:	7e 0e                	jle    80195d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80194f:	8b 10                	mov    (%eax),%edx
  801951:	8d 4a 08             	lea    0x8(%edx),%ecx
  801954:	89 08                	mov    %ecx,(%eax)
  801956:	8b 02                	mov    (%edx),%eax
  801958:	8b 52 04             	mov    0x4(%edx),%edx
  80195b:	eb 22                	jmp    80197f <getuint+0x38>
	else if (lflag)
  80195d:	85 d2                	test   %edx,%edx
  80195f:	74 10                	je     801971 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801961:	8b 10                	mov    (%eax),%edx
  801963:	8d 4a 04             	lea    0x4(%edx),%ecx
  801966:	89 08                	mov    %ecx,(%eax)
  801968:	8b 02                	mov    (%edx),%eax
  80196a:	ba 00 00 00 00       	mov    $0x0,%edx
  80196f:	eb 0e                	jmp    80197f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801971:	8b 10                	mov    (%eax),%edx
  801973:	8d 4a 04             	lea    0x4(%edx),%ecx
  801976:	89 08                	mov    %ecx,(%eax)
  801978:	8b 02                	mov    (%edx),%eax
  80197a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801987:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80198b:	8b 10                	mov    (%eax),%edx
  80198d:	3b 50 04             	cmp    0x4(%eax),%edx
  801990:	73 0a                	jae    80199c <sprintputch+0x1b>
		*b->buf++ = ch;
  801992:	8d 4a 01             	lea    0x1(%edx),%ecx
  801995:	89 08                	mov    %ecx,(%eax)
  801997:	8b 45 08             	mov    0x8(%ebp),%eax
  80199a:	88 02                	mov    %al,(%edx)
}
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8019a4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8019a7:	50                   	push   %eax
  8019a8:	ff 75 10             	pushl  0x10(%ebp)
  8019ab:	ff 75 0c             	pushl  0xc(%ebp)
  8019ae:	ff 75 08             	pushl  0x8(%ebp)
  8019b1:	e8 05 00 00 00       	call   8019bb <vprintfmt>
	va_end(ap);
}
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	57                   	push   %edi
  8019bf:	56                   	push   %esi
  8019c0:	53                   	push   %ebx
  8019c1:	83 ec 2c             	sub    $0x2c,%esp
  8019c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8019c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019ca:	8b 7d 10             	mov    0x10(%ebp),%edi
  8019cd:	eb 12                	jmp    8019e1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	0f 84 89 03 00 00    	je     801d60 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	53                   	push   %ebx
  8019db:	50                   	push   %eax
  8019dc:	ff d6                	call   *%esi
  8019de:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8019e1:	83 c7 01             	add    $0x1,%edi
  8019e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019e8:	83 f8 25             	cmp    $0x25,%eax
  8019eb:	75 e2                	jne    8019cf <vprintfmt+0x14>
  8019ed:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8019f1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8019f8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8019ff:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801a06:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0b:	eb 07                	jmp    801a14 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801a10:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a14:	8d 47 01             	lea    0x1(%edi),%eax
  801a17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a1a:	0f b6 07             	movzbl (%edi),%eax
  801a1d:	0f b6 c8             	movzbl %al,%ecx
  801a20:	83 e8 23             	sub    $0x23,%eax
  801a23:	3c 55                	cmp    $0x55,%al
  801a25:	0f 87 1a 03 00 00    	ja     801d45 <vprintfmt+0x38a>
  801a2b:	0f b6 c0             	movzbl %al,%eax
  801a2e:	ff 24 85 60 25 80 00 	jmp    *0x802560(,%eax,4)
  801a35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801a38:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801a3c:	eb d6                	jmp    801a14 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a41:	b8 00 00 00 00       	mov    $0x0,%eax
  801a46:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801a49:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801a4c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801a50:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801a53:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801a56:	83 fa 09             	cmp    $0x9,%edx
  801a59:	77 39                	ja     801a94 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801a5b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801a5e:	eb e9                	jmp    801a49 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801a60:	8b 45 14             	mov    0x14(%ebp),%eax
  801a63:	8d 48 04             	lea    0x4(%eax),%ecx
  801a66:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801a69:	8b 00                	mov    (%eax),%eax
  801a6b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a71:	eb 27                	jmp    801a9a <vprintfmt+0xdf>
  801a73:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a76:	85 c0                	test   %eax,%eax
  801a78:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a7d:	0f 49 c8             	cmovns %eax,%ecx
  801a80:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a83:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a86:	eb 8c                	jmp    801a14 <vprintfmt+0x59>
  801a88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a8b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801a92:	eb 80                	jmp    801a14 <vprintfmt+0x59>
  801a94:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801a97:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801a9a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801a9e:	0f 89 70 ff ff ff    	jns    801a14 <vprintfmt+0x59>
				width = precision, precision = -1;
  801aa4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801aa7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aaa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801ab1:	e9 5e ff ff ff       	jmp    801a14 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801ab6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ab9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801abc:	e9 53 ff ff ff       	jmp    801a14 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801ac1:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac4:	8d 50 04             	lea    0x4(%eax),%edx
  801ac7:	89 55 14             	mov    %edx,0x14(%ebp)
  801aca:	83 ec 08             	sub    $0x8,%esp
  801acd:	53                   	push   %ebx
  801ace:	ff 30                	pushl  (%eax)
  801ad0:	ff d6                	call   *%esi
			break;
  801ad2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ad5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801ad8:	e9 04 ff ff ff       	jmp    8019e1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801add:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae0:	8d 50 04             	lea    0x4(%eax),%edx
  801ae3:	89 55 14             	mov    %edx,0x14(%ebp)
  801ae6:	8b 00                	mov    (%eax),%eax
  801ae8:	99                   	cltd   
  801ae9:	31 d0                	xor    %edx,%eax
  801aeb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801aed:	83 f8 0f             	cmp    $0xf,%eax
  801af0:	7f 0b                	jg     801afd <vprintfmt+0x142>
  801af2:	8b 14 85 c0 26 80 00 	mov    0x8026c0(,%eax,4),%edx
  801af9:	85 d2                	test   %edx,%edx
  801afb:	75 18                	jne    801b15 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801afd:	50                   	push   %eax
  801afe:	68 3f 24 80 00       	push   $0x80243f
  801b03:	53                   	push   %ebx
  801b04:	56                   	push   %esi
  801b05:	e8 94 fe ff ff       	call   80199e <printfmt>
  801b0a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801b10:	e9 cc fe ff ff       	jmp    8019e1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801b15:	52                   	push   %edx
  801b16:	68 bd 23 80 00       	push   $0x8023bd
  801b1b:	53                   	push   %ebx
  801b1c:	56                   	push   %esi
  801b1d:	e8 7c fe ff ff       	call   80199e <printfmt>
  801b22:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b28:	e9 b4 fe ff ff       	jmp    8019e1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801b2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801b30:	8d 50 04             	lea    0x4(%eax),%edx
  801b33:	89 55 14             	mov    %edx,0x14(%ebp)
  801b36:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801b38:	85 ff                	test   %edi,%edi
  801b3a:	b8 38 24 80 00       	mov    $0x802438,%eax
  801b3f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801b42:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801b46:	0f 8e 94 00 00 00    	jle    801be0 <vprintfmt+0x225>
  801b4c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801b50:	0f 84 98 00 00 00    	je     801bee <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801b56:	83 ec 08             	sub    $0x8,%esp
  801b59:	ff 75 d0             	pushl  -0x30(%ebp)
  801b5c:	57                   	push   %edi
  801b5d:	e8 18 e6 ff ff       	call   80017a <strnlen>
  801b62:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801b65:	29 c1                	sub    %eax,%ecx
  801b67:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801b6a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801b6d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801b71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b74:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801b77:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b79:	eb 0f                	jmp    801b8a <vprintfmt+0x1cf>
					putch(padc, putdat);
  801b7b:	83 ec 08             	sub    $0x8,%esp
  801b7e:	53                   	push   %ebx
  801b7f:	ff 75 e0             	pushl  -0x20(%ebp)
  801b82:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b84:	83 ef 01             	sub    $0x1,%edi
  801b87:	83 c4 10             	add    $0x10,%esp
  801b8a:	85 ff                	test   %edi,%edi
  801b8c:	7f ed                	jg     801b7b <vprintfmt+0x1c0>
  801b8e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801b91:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801b94:	85 c9                	test   %ecx,%ecx
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9b:	0f 49 c1             	cmovns %ecx,%eax
  801b9e:	29 c1                	sub    %eax,%ecx
  801ba0:	89 75 08             	mov    %esi,0x8(%ebp)
  801ba3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ba6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ba9:	89 cb                	mov    %ecx,%ebx
  801bab:	eb 4d                	jmp    801bfa <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801bad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801bb1:	74 1b                	je     801bce <vprintfmt+0x213>
  801bb3:	0f be c0             	movsbl %al,%eax
  801bb6:	83 e8 20             	sub    $0x20,%eax
  801bb9:	83 f8 5e             	cmp    $0x5e,%eax
  801bbc:	76 10                	jbe    801bce <vprintfmt+0x213>
					putch('?', putdat);
  801bbe:	83 ec 08             	sub    $0x8,%esp
  801bc1:	ff 75 0c             	pushl  0xc(%ebp)
  801bc4:	6a 3f                	push   $0x3f
  801bc6:	ff 55 08             	call   *0x8(%ebp)
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	eb 0d                	jmp    801bdb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801bce:	83 ec 08             	sub    $0x8,%esp
  801bd1:	ff 75 0c             	pushl  0xc(%ebp)
  801bd4:	52                   	push   %edx
  801bd5:	ff 55 08             	call   *0x8(%ebp)
  801bd8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801bdb:	83 eb 01             	sub    $0x1,%ebx
  801bde:	eb 1a                	jmp    801bfa <vprintfmt+0x23f>
  801be0:	89 75 08             	mov    %esi,0x8(%ebp)
  801be3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801be6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801be9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801bec:	eb 0c                	jmp    801bfa <vprintfmt+0x23f>
  801bee:	89 75 08             	mov    %esi,0x8(%ebp)
  801bf1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801bf4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801bf7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801bfa:	83 c7 01             	add    $0x1,%edi
  801bfd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801c01:	0f be d0             	movsbl %al,%edx
  801c04:	85 d2                	test   %edx,%edx
  801c06:	74 23                	je     801c2b <vprintfmt+0x270>
  801c08:	85 f6                	test   %esi,%esi
  801c0a:	78 a1                	js     801bad <vprintfmt+0x1f2>
  801c0c:	83 ee 01             	sub    $0x1,%esi
  801c0f:	79 9c                	jns    801bad <vprintfmt+0x1f2>
  801c11:	89 df                	mov    %ebx,%edi
  801c13:	8b 75 08             	mov    0x8(%ebp),%esi
  801c16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c19:	eb 18                	jmp    801c33 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801c1b:	83 ec 08             	sub    $0x8,%esp
  801c1e:	53                   	push   %ebx
  801c1f:	6a 20                	push   $0x20
  801c21:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801c23:	83 ef 01             	sub    $0x1,%edi
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	eb 08                	jmp    801c33 <vprintfmt+0x278>
  801c2b:	89 df                	mov    %ebx,%edi
  801c2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801c30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801c33:	85 ff                	test   %edi,%edi
  801c35:	7f e4                	jg     801c1b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c3a:	e9 a2 fd ff ff       	jmp    8019e1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801c3f:	83 fa 01             	cmp    $0x1,%edx
  801c42:	7e 16                	jle    801c5a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801c44:	8b 45 14             	mov    0x14(%ebp),%eax
  801c47:	8d 50 08             	lea    0x8(%eax),%edx
  801c4a:	89 55 14             	mov    %edx,0x14(%ebp)
  801c4d:	8b 50 04             	mov    0x4(%eax),%edx
  801c50:	8b 00                	mov    (%eax),%eax
  801c52:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c55:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801c58:	eb 32                	jmp    801c8c <vprintfmt+0x2d1>
	else if (lflag)
  801c5a:	85 d2                	test   %edx,%edx
  801c5c:	74 18                	je     801c76 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801c5e:	8b 45 14             	mov    0x14(%ebp),%eax
  801c61:	8d 50 04             	lea    0x4(%eax),%edx
  801c64:	89 55 14             	mov    %edx,0x14(%ebp)
  801c67:	8b 00                	mov    (%eax),%eax
  801c69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c6c:	89 c1                	mov    %eax,%ecx
  801c6e:	c1 f9 1f             	sar    $0x1f,%ecx
  801c71:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801c74:	eb 16                	jmp    801c8c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801c76:	8b 45 14             	mov    0x14(%ebp),%eax
  801c79:	8d 50 04             	lea    0x4(%eax),%edx
  801c7c:	89 55 14             	mov    %edx,0x14(%ebp)
  801c7f:	8b 00                	mov    (%eax),%eax
  801c81:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801c84:	89 c1                	mov    %eax,%ecx
  801c86:	c1 f9 1f             	sar    $0x1f,%ecx
  801c89:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801c8c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801c8f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801c92:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801c97:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801c9b:	79 74                	jns    801d11 <vprintfmt+0x356>
				putch('-', putdat);
  801c9d:	83 ec 08             	sub    $0x8,%esp
  801ca0:	53                   	push   %ebx
  801ca1:	6a 2d                	push   $0x2d
  801ca3:	ff d6                	call   *%esi
				num = -(long long) num;
  801ca5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ca8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801cab:	f7 d8                	neg    %eax
  801cad:	83 d2 00             	adc    $0x0,%edx
  801cb0:	f7 da                	neg    %edx
  801cb2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801cb5:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801cba:	eb 55                	jmp    801d11 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801cbc:	8d 45 14             	lea    0x14(%ebp),%eax
  801cbf:	e8 83 fc ff ff       	call   801947 <getuint>
			base = 10;
  801cc4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801cc9:	eb 46                	jmp    801d11 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ccb:	8d 45 14             	lea    0x14(%ebp),%eax
  801cce:	e8 74 fc ff ff       	call   801947 <getuint>
			base = 8;
  801cd3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801cd8:	eb 37                	jmp    801d11 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	53                   	push   %ebx
  801cde:	6a 30                	push   $0x30
  801ce0:	ff d6                	call   *%esi
			putch('x', putdat);
  801ce2:	83 c4 08             	add    $0x8,%esp
  801ce5:	53                   	push   %ebx
  801ce6:	6a 78                	push   $0x78
  801ce8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801cea:	8b 45 14             	mov    0x14(%ebp),%eax
  801ced:	8d 50 04             	lea    0x4(%eax),%edx
  801cf0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801cf3:	8b 00                	mov    (%eax),%eax
  801cf5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801cfa:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801cfd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801d02:	eb 0d                	jmp    801d11 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801d04:	8d 45 14             	lea    0x14(%ebp),%eax
  801d07:	e8 3b fc ff ff       	call   801947 <getuint>
			base = 16;
  801d0c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801d11:	83 ec 0c             	sub    $0xc,%esp
  801d14:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801d18:	57                   	push   %edi
  801d19:	ff 75 e0             	pushl  -0x20(%ebp)
  801d1c:	51                   	push   %ecx
  801d1d:	52                   	push   %edx
  801d1e:	50                   	push   %eax
  801d1f:	89 da                	mov    %ebx,%edx
  801d21:	89 f0                	mov    %esi,%eax
  801d23:	e8 70 fb ff ff       	call   801898 <printnum>
			break;
  801d28:	83 c4 20             	add    $0x20,%esp
  801d2b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d2e:	e9 ae fc ff ff       	jmp    8019e1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801d33:	83 ec 08             	sub    $0x8,%esp
  801d36:	53                   	push   %ebx
  801d37:	51                   	push   %ecx
  801d38:	ff d6                	call   *%esi
			break;
  801d3a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801d40:	e9 9c fc ff ff       	jmp    8019e1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801d45:	83 ec 08             	sub    $0x8,%esp
  801d48:	53                   	push   %ebx
  801d49:	6a 25                	push   $0x25
  801d4b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	eb 03                	jmp    801d55 <vprintfmt+0x39a>
  801d52:	83 ef 01             	sub    $0x1,%edi
  801d55:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801d59:	75 f7                	jne    801d52 <vprintfmt+0x397>
  801d5b:	e9 81 fc ff ff       	jmp    8019e1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    

00801d68 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	83 ec 18             	sub    $0x18,%esp
  801d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d71:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801d74:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d77:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801d7b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801d7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801d85:	85 c0                	test   %eax,%eax
  801d87:	74 26                	je     801daf <vsnprintf+0x47>
  801d89:	85 d2                	test   %edx,%edx
  801d8b:	7e 22                	jle    801daf <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801d8d:	ff 75 14             	pushl  0x14(%ebp)
  801d90:	ff 75 10             	pushl  0x10(%ebp)
  801d93:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d96:	50                   	push   %eax
  801d97:	68 81 19 80 00       	push   $0x801981
  801d9c:	e8 1a fc ff ff       	call   8019bb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801da1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801da4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	eb 05                	jmp    801db4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801daf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801dbc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801dbf:	50                   	push   %eax
  801dc0:	ff 75 10             	pushl  0x10(%ebp)
  801dc3:	ff 75 0c             	pushl  0xc(%ebp)
  801dc6:	ff 75 08             	pushl  0x8(%ebp)
  801dc9:	e8 9a ff ff ff       	call   801d68 <vsnprintf>
	va_end(ap);

	return rc;
}
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    

00801dd0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dd6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ddd:	75 2a                	jne    801e09 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ddf:	83 ec 04             	sub    $0x4,%esp
  801de2:	6a 07                	push   $0x7
  801de4:	68 00 f0 bf ee       	push   $0xeebff000
  801de9:	6a 00                	push   $0x0
  801deb:	e8 ae e7 ff ff       	call   80059e <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	85 c0                	test   %eax,%eax
  801df5:	79 12                	jns    801e09 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801df7:	50                   	push   %eax
  801df8:	68 20 27 80 00       	push   $0x802720
  801dfd:	6a 23                	push   $0x23
  801dff:	68 24 27 80 00       	push   $0x802724
  801e04:	e8 a2 f9 ff ff       	call   8017ab <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e09:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0c:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e11:	83 ec 08             	sub    $0x8,%esp
  801e14:	68 3b 1e 80 00       	push   $0x801e3b
  801e19:	6a 00                	push   $0x0
  801e1b:	e8 c9 e8 ff ff       	call   8006e9 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e20:	83 c4 10             	add    $0x10,%esp
  801e23:	85 c0                	test   %eax,%eax
  801e25:	79 12                	jns    801e39 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e27:	50                   	push   %eax
  801e28:	68 20 27 80 00       	push   $0x802720
  801e2d:	6a 2c                	push   $0x2c
  801e2f:	68 24 27 80 00       	push   $0x802724
  801e34:	e8 72 f9 ff ff       	call   8017ab <_panic>
	}
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e3b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e3c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e41:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e43:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e46:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e4a:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e4f:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e53:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e55:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e58:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e59:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e5c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e5d:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e5e:	c3                   	ret    

00801e5f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	8b 75 08             	mov    0x8(%ebp),%esi
  801e67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e6d:	85 c0                	test   %eax,%eax
  801e6f:	75 12                	jne    801e83 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	68 00 00 c0 ee       	push   $0xeec00000
  801e79:	e8 d0 e8 ff ff       	call   80074e <sys_ipc_recv>
  801e7e:	83 c4 10             	add    $0x10,%esp
  801e81:	eb 0c                	jmp    801e8f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e83:	83 ec 0c             	sub    $0xc,%esp
  801e86:	50                   	push   %eax
  801e87:	e8 c2 e8 ff ff       	call   80074e <sys_ipc_recv>
  801e8c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e8f:	85 f6                	test   %esi,%esi
  801e91:	0f 95 c1             	setne  %cl
  801e94:	85 db                	test   %ebx,%ebx
  801e96:	0f 95 c2             	setne  %dl
  801e99:	84 d1                	test   %dl,%cl
  801e9b:	74 09                	je     801ea6 <ipc_recv+0x47>
  801e9d:	89 c2                	mov    %eax,%edx
  801e9f:	c1 ea 1f             	shr    $0x1f,%edx
  801ea2:	84 d2                	test   %dl,%dl
  801ea4:	75 2a                	jne    801ed0 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801ea6:	85 f6                	test   %esi,%esi
  801ea8:	74 0d                	je     801eb7 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801eaa:	a1 04 40 80 00       	mov    0x804004,%eax
  801eaf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801eb5:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801eb7:	85 db                	test   %ebx,%ebx
  801eb9:	74 0d                	je     801ec8 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801ebb:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec0:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801ec6:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ec8:	a1 04 40 80 00       	mov    0x804004,%eax
  801ecd:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801ed0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed3:	5b                   	pop    %ebx
  801ed4:	5e                   	pop    %esi
  801ed5:	5d                   	pop    %ebp
  801ed6:	c3                   	ret    

00801ed7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ed7:	55                   	push   %ebp
  801ed8:	89 e5                	mov    %esp,%ebp
  801eda:	57                   	push   %edi
  801edb:	56                   	push   %esi
  801edc:	53                   	push   %ebx
  801edd:	83 ec 0c             	sub    $0xc,%esp
  801ee0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ee3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ee9:	85 db                	test   %ebx,%ebx
  801eeb:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ef0:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ef3:	ff 75 14             	pushl  0x14(%ebp)
  801ef6:	53                   	push   %ebx
  801ef7:	56                   	push   %esi
  801ef8:	57                   	push   %edi
  801ef9:	e8 2d e8 ff ff       	call   80072b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801efe:	89 c2                	mov    %eax,%edx
  801f00:	c1 ea 1f             	shr    $0x1f,%edx
  801f03:	83 c4 10             	add    $0x10,%esp
  801f06:	84 d2                	test   %dl,%dl
  801f08:	74 17                	je     801f21 <ipc_send+0x4a>
  801f0a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f0d:	74 12                	je     801f21 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801f0f:	50                   	push   %eax
  801f10:	68 32 27 80 00       	push   $0x802732
  801f15:	6a 47                	push   $0x47
  801f17:	68 40 27 80 00       	push   $0x802740
  801f1c:	e8 8a f8 ff ff       	call   8017ab <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f21:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f24:	75 07                	jne    801f2d <ipc_send+0x56>
			sys_yield();
  801f26:	e8 54 e6 ff ff       	call   80057f <sys_yield>
  801f2b:	eb c6                	jmp    801ef3 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	75 c2                	jne    801ef3 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f34:	5b                   	pop    %ebx
  801f35:	5e                   	pop    %esi
  801f36:	5f                   	pop    %edi
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    

00801f39 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f39:	55                   	push   %ebp
  801f3a:	89 e5                	mov    %esp,%ebp
  801f3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f3f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f44:	89 c2                	mov    %eax,%edx
  801f46:	c1 e2 07             	shl    $0x7,%edx
  801f49:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801f50:	8b 52 5c             	mov    0x5c(%edx),%edx
  801f53:	39 ca                	cmp    %ecx,%edx
  801f55:	75 11                	jne    801f68 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801f57:	89 c2                	mov    %eax,%edx
  801f59:	c1 e2 07             	shl    $0x7,%edx
  801f5c:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801f63:	8b 40 54             	mov    0x54(%eax),%eax
  801f66:	eb 0f                	jmp    801f77 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f68:	83 c0 01             	add    $0x1,%eax
  801f6b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f70:	75 d2                	jne    801f44 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    

00801f79 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7f:	89 d0                	mov    %edx,%eax
  801f81:	c1 e8 16             	shr    $0x16,%eax
  801f84:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f90:	f6 c1 01             	test   $0x1,%cl
  801f93:	74 1d                	je     801fb2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f95:	c1 ea 0c             	shr    $0xc,%edx
  801f98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f9f:	f6 c2 01             	test   $0x1,%dl
  801fa2:	74 0e                	je     801fb2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa4:	c1 ea 0c             	shr    $0xc,%edx
  801fa7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fae:	ef 
  801faf:	0f b7 c0             	movzwl %ax,%eax
}
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    
  801fb4:	66 90                	xchg   %ax,%ax
  801fb6:	66 90                	xchg   %ax,%ax
  801fb8:	66 90                	xchg   %ax,%ax
  801fba:	66 90                	xchg   %ax,%ax
  801fbc:	66 90                	xchg   %ax,%ax
  801fbe:	66 90                	xchg   %ax,%ax

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
