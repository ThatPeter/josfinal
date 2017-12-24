
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
  800051:	68 a0 1e 80 00       	push   $0x801ea0
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 0b 02 00 00       	call   800269 <strcmp>
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
  80008a:	68 a3 1e 80 00       	push   $0x801ea3
  80008f:	6a 01                	push   $0x1
  800091:	e8 d3 0a 00 00       	call   800b69 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 e2 00 00 00       	call   800186 <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 b7 0a 00 00       	call   800b69 <write>
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
  8000c7:	68 b3 1f 80 00       	push   $0x801fb3
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 96 0a 00 00       	call   800b69 <write>
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
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e7:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  8000ee:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  8000f1:	e8 8e 04 00 00       	call   800584 <sys_getenvid>
  8000f6:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  8000fc:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800101:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800106:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  80010b:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80010e:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800114:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800117:	39 c8                	cmp    %ecx,%eax
  800119:	0f 44 fb             	cmove  %ebx,%edi
  80011c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800121:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800124:	83 c2 01             	add    $0x1,%edx
  800127:	83 c3 7c             	add    $0x7c,%ebx
  80012a:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800130:	75 d9                	jne    80010b <libmain+0x2d>
  800132:	89 f0                	mov    %esi,%eax
  800134:	84 c0                	test   %al,%al
  800136:	74 06                	je     80013e <libmain+0x60>
  800138:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800142:	7e 0a                	jle    80014e <libmain+0x70>
		binaryname = argv[0];
  800144:	8b 45 0c             	mov    0xc(%ebp),%eax
  800147:	8b 00                	mov    (%eax),%eax
  800149:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	ff 75 0c             	pushl  0xc(%ebp)
  800154:	ff 75 08             	pushl  0x8(%ebp)
  800157:	e8 d7 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80015c:	e8 0b 00 00 00       	call   80016c <exit>
}
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800172:	e8 07 08 00 00       	call   80097e <close_all>
	sys_env_destroy(0);
  800177:	83 ec 0c             	sub    $0xc,%esp
  80017a:	6a 00                	push   $0x0
  80017c:	e8 c2 03 00 00       	call   800543 <sys_env_destroy>
}
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	c9                   	leave  
  800185:	c3                   	ret    

00800186 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80018c:	b8 00 00 00 00       	mov    $0x0,%eax
  800191:	eb 03                	jmp    800196 <strlen+0x10>
		n++;
  800193:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800196:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80019a:	75 f7                	jne    800193 <strlen+0xd>
		n++;
	return n;
}
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8001a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ac:	eb 03                	jmp    8001b1 <strnlen+0x13>
		n++;
  8001ae:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8001b1:	39 c2                	cmp    %eax,%edx
  8001b3:	74 08                	je     8001bd <strnlen+0x1f>
  8001b5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8001b9:	75 f3                	jne    8001ae <strnlen+0x10>
  8001bb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    

008001bf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	53                   	push   %ebx
  8001c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001c9:	89 c2                	mov    %eax,%edx
  8001cb:	83 c2 01             	add    $0x1,%edx
  8001ce:	83 c1 01             	add    $0x1,%ecx
  8001d1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8001d5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8001d8:	84 db                	test   %bl,%bl
  8001da:	75 ef                	jne    8001cb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8001dc:	5b                   	pop    %ebx
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	53                   	push   %ebx
  8001e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001e6:	53                   	push   %ebx
  8001e7:	e8 9a ff ff ff       	call   800186 <strlen>
  8001ec:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	01 d8                	add    %ebx,%eax
  8001f4:	50                   	push   %eax
  8001f5:	e8 c5 ff ff ff       	call   8001bf <strcpy>
	return dst;
}
  8001fa:	89 d8                	mov    %ebx,%eax
  8001fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    

00800201 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	8b 75 08             	mov    0x8(%ebp),%esi
  800209:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020c:	89 f3                	mov    %esi,%ebx
  80020e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800211:	89 f2                	mov    %esi,%edx
  800213:	eb 0f                	jmp    800224 <strncpy+0x23>
		*dst++ = *src;
  800215:	83 c2 01             	add    $0x1,%edx
  800218:	0f b6 01             	movzbl (%ecx),%eax
  80021b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80021e:	80 39 01             	cmpb   $0x1,(%ecx)
  800221:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800224:	39 da                	cmp    %ebx,%edx
  800226:	75 ed                	jne    800215 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800228:	89 f0                	mov    %esi,%eax
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	8b 75 08             	mov    0x8(%ebp),%esi
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	8b 55 10             	mov    0x10(%ebp),%edx
  80023c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80023e:	85 d2                	test   %edx,%edx
  800240:	74 21                	je     800263 <strlcpy+0x35>
  800242:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800246:	89 f2                	mov    %esi,%edx
  800248:	eb 09                	jmp    800253 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80024a:	83 c2 01             	add    $0x1,%edx
  80024d:	83 c1 01             	add    $0x1,%ecx
  800250:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800253:	39 c2                	cmp    %eax,%edx
  800255:	74 09                	je     800260 <strlcpy+0x32>
  800257:	0f b6 19             	movzbl (%ecx),%ebx
  80025a:	84 db                	test   %bl,%bl
  80025c:	75 ec                	jne    80024a <strlcpy+0x1c>
  80025e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800260:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800263:	29 f0                	sub    %esi,%eax
}
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800272:	eb 06                	jmp    80027a <strcmp+0x11>
		p++, q++;
  800274:	83 c1 01             	add    $0x1,%ecx
  800277:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80027a:	0f b6 01             	movzbl (%ecx),%eax
  80027d:	84 c0                	test   %al,%al
  80027f:	74 04                	je     800285 <strcmp+0x1c>
  800281:	3a 02                	cmp    (%edx),%al
  800283:	74 ef                	je     800274 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800285:	0f b6 c0             	movzbl %al,%eax
  800288:	0f b6 12             	movzbl (%edx),%edx
  80028b:	29 d0                	sub    %edx,%eax
}
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	53                   	push   %ebx
  800293:	8b 45 08             	mov    0x8(%ebp),%eax
  800296:	8b 55 0c             	mov    0xc(%ebp),%edx
  800299:	89 c3                	mov    %eax,%ebx
  80029b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80029e:	eb 06                	jmp    8002a6 <strncmp+0x17>
		n--, p++, q++;
  8002a0:	83 c0 01             	add    $0x1,%eax
  8002a3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8002a6:	39 d8                	cmp    %ebx,%eax
  8002a8:	74 15                	je     8002bf <strncmp+0x30>
  8002aa:	0f b6 08             	movzbl (%eax),%ecx
  8002ad:	84 c9                	test   %cl,%cl
  8002af:	74 04                	je     8002b5 <strncmp+0x26>
  8002b1:	3a 0a                	cmp    (%edx),%cl
  8002b3:	74 eb                	je     8002a0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8002b5:	0f b6 00             	movzbl (%eax),%eax
  8002b8:	0f b6 12             	movzbl (%edx),%edx
  8002bb:	29 d0                	sub    %edx,%eax
  8002bd:	eb 05                	jmp    8002c4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8002bf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8002c4:	5b                   	pop    %ebx
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    

008002c7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8002c7:	55                   	push   %ebp
  8002c8:	89 e5                	mov    %esp,%ebp
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002d1:	eb 07                	jmp    8002da <strchr+0x13>
		if (*s == c)
  8002d3:	38 ca                	cmp    %cl,%dl
  8002d5:	74 0f                	je     8002e6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002d7:	83 c0 01             	add    $0x1,%eax
  8002da:	0f b6 10             	movzbl (%eax),%edx
  8002dd:	84 d2                	test   %dl,%dl
  8002df:	75 f2                	jne    8002d3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8002e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    

008002e8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002f2:	eb 03                	jmp    8002f7 <strfind+0xf>
  8002f4:	83 c0 01             	add    $0x1,%eax
  8002f7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002fa:	38 ca                	cmp    %cl,%dl
  8002fc:	74 04                	je     800302 <strfind+0x1a>
  8002fe:	84 d2                	test   %dl,%dl
  800300:	75 f2                	jne    8002f4 <strfind+0xc>
			break;
	return (char *) s;
}
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	57                   	push   %edi
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
  80030a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80030d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800310:	85 c9                	test   %ecx,%ecx
  800312:	74 36                	je     80034a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800314:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80031a:	75 28                	jne    800344 <memset+0x40>
  80031c:	f6 c1 03             	test   $0x3,%cl
  80031f:	75 23                	jne    800344 <memset+0x40>
		c &= 0xFF;
  800321:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800325:	89 d3                	mov    %edx,%ebx
  800327:	c1 e3 08             	shl    $0x8,%ebx
  80032a:	89 d6                	mov    %edx,%esi
  80032c:	c1 e6 18             	shl    $0x18,%esi
  80032f:	89 d0                	mov    %edx,%eax
  800331:	c1 e0 10             	shl    $0x10,%eax
  800334:	09 f0                	or     %esi,%eax
  800336:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800338:	89 d8                	mov    %ebx,%eax
  80033a:	09 d0                	or     %edx,%eax
  80033c:	c1 e9 02             	shr    $0x2,%ecx
  80033f:	fc                   	cld    
  800340:	f3 ab                	rep stos %eax,%es:(%edi)
  800342:	eb 06                	jmp    80034a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800344:	8b 45 0c             	mov    0xc(%ebp),%eax
  800347:	fc                   	cld    
  800348:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80034a:	89 f8                	mov    %edi,%eax
  80034c:	5b                   	pop    %ebx
  80034d:	5e                   	pop    %esi
  80034e:	5f                   	pop    %edi
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	57                   	push   %edi
  800355:	56                   	push   %esi
  800356:	8b 45 08             	mov    0x8(%ebp),%eax
  800359:	8b 75 0c             	mov    0xc(%ebp),%esi
  80035c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80035f:	39 c6                	cmp    %eax,%esi
  800361:	73 35                	jae    800398 <memmove+0x47>
  800363:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800366:	39 d0                	cmp    %edx,%eax
  800368:	73 2e                	jae    800398 <memmove+0x47>
		s += n;
		d += n;
  80036a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	09 fe                	or     %edi,%esi
  800371:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800377:	75 13                	jne    80038c <memmove+0x3b>
  800379:	f6 c1 03             	test   $0x3,%cl
  80037c:	75 0e                	jne    80038c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80037e:	83 ef 04             	sub    $0x4,%edi
  800381:	8d 72 fc             	lea    -0x4(%edx),%esi
  800384:	c1 e9 02             	shr    $0x2,%ecx
  800387:	fd                   	std    
  800388:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80038a:	eb 09                	jmp    800395 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80038c:	83 ef 01             	sub    $0x1,%edi
  80038f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800392:	fd                   	std    
  800393:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800395:	fc                   	cld    
  800396:	eb 1d                	jmp    8003b5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800398:	89 f2                	mov    %esi,%edx
  80039a:	09 c2                	or     %eax,%edx
  80039c:	f6 c2 03             	test   $0x3,%dl
  80039f:	75 0f                	jne    8003b0 <memmove+0x5f>
  8003a1:	f6 c1 03             	test   $0x3,%cl
  8003a4:	75 0a                	jne    8003b0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8003a6:	c1 e9 02             	shr    $0x2,%ecx
  8003a9:	89 c7                	mov    %eax,%edi
  8003ab:	fc                   	cld    
  8003ac:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8003ae:	eb 05                	jmp    8003b5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8003b0:	89 c7                	mov    %eax,%edi
  8003b2:	fc                   	cld    
  8003b3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8003b5:	5e                   	pop    %esi
  8003b6:	5f                   	pop    %edi
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8003bc:	ff 75 10             	pushl  0x10(%ebp)
  8003bf:	ff 75 0c             	pushl  0xc(%ebp)
  8003c2:	ff 75 08             	pushl  0x8(%ebp)
  8003c5:	e8 87 ff ff ff       	call   800351 <memmove>
}
  8003ca:	c9                   	leave  
  8003cb:	c3                   	ret    

008003cc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d7:	89 c6                	mov    %eax,%esi
  8003d9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003dc:	eb 1a                	jmp    8003f8 <memcmp+0x2c>
		if (*s1 != *s2)
  8003de:	0f b6 08             	movzbl (%eax),%ecx
  8003e1:	0f b6 1a             	movzbl (%edx),%ebx
  8003e4:	38 d9                	cmp    %bl,%cl
  8003e6:	74 0a                	je     8003f2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003e8:	0f b6 c1             	movzbl %cl,%eax
  8003eb:	0f b6 db             	movzbl %bl,%ebx
  8003ee:	29 d8                	sub    %ebx,%eax
  8003f0:	eb 0f                	jmp    800401 <memcmp+0x35>
		s1++, s2++;
  8003f2:	83 c0 01             	add    $0x1,%eax
  8003f5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003f8:	39 f0                	cmp    %esi,%eax
  8003fa:	75 e2                	jne    8003de <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800401:	5b                   	pop    %ebx
  800402:	5e                   	pop    %esi
  800403:	5d                   	pop    %ebp
  800404:	c3                   	ret    

00800405 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	53                   	push   %ebx
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80040c:	89 c1                	mov    %eax,%ecx
  80040e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800411:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800415:	eb 0a                	jmp    800421 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800417:	0f b6 10             	movzbl (%eax),%edx
  80041a:	39 da                	cmp    %ebx,%edx
  80041c:	74 07                	je     800425 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80041e:	83 c0 01             	add    $0x1,%eax
  800421:	39 c8                	cmp    %ecx,%eax
  800423:	72 f2                	jb     800417 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800425:	5b                   	pop    %ebx
  800426:	5d                   	pop    %ebp
  800427:	c3                   	ret    

00800428 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800431:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800434:	eb 03                	jmp    800439 <strtol+0x11>
		s++;
  800436:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800439:	0f b6 01             	movzbl (%ecx),%eax
  80043c:	3c 20                	cmp    $0x20,%al
  80043e:	74 f6                	je     800436 <strtol+0xe>
  800440:	3c 09                	cmp    $0x9,%al
  800442:	74 f2                	je     800436 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800444:	3c 2b                	cmp    $0x2b,%al
  800446:	75 0a                	jne    800452 <strtol+0x2a>
		s++;
  800448:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80044b:	bf 00 00 00 00       	mov    $0x0,%edi
  800450:	eb 11                	jmp    800463 <strtol+0x3b>
  800452:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800457:	3c 2d                	cmp    $0x2d,%al
  800459:	75 08                	jne    800463 <strtol+0x3b>
		s++, neg = 1;
  80045b:	83 c1 01             	add    $0x1,%ecx
  80045e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800463:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800469:	75 15                	jne    800480 <strtol+0x58>
  80046b:	80 39 30             	cmpb   $0x30,(%ecx)
  80046e:	75 10                	jne    800480 <strtol+0x58>
  800470:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800474:	75 7c                	jne    8004f2 <strtol+0xca>
		s += 2, base = 16;
  800476:	83 c1 02             	add    $0x2,%ecx
  800479:	bb 10 00 00 00       	mov    $0x10,%ebx
  80047e:	eb 16                	jmp    800496 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800480:	85 db                	test   %ebx,%ebx
  800482:	75 12                	jne    800496 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800484:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800489:	80 39 30             	cmpb   $0x30,(%ecx)
  80048c:	75 08                	jne    800496 <strtol+0x6e>
		s++, base = 8;
  80048e:	83 c1 01             	add    $0x1,%ecx
  800491:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800496:	b8 00 00 00 00       	mov    $0x0,%eax
  80049b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80049e:	0f b6 11             	movzbl (%ecx),%edx
  8004a1:	8d 72 d0             	lea    -0x30(%edx),%esi
  8004a4:	89 f3                	mov    %esi,%ebx
  8004a6:	80 fb 09             	cmp    $0x9,%bl
  8004a9:	77 08                	ja     8004b3 <strtol+0x8b>
			dig = *s - '0';
  8004ab:	0f be d2             	movsbl %dl,%edx
  8004ae:	83 ea 30             	sub    $0x30,%edx
  8004b1:	eb 22                	jmp    8004d5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8004b3:	8d 72 9f             	lea    -0x61(%edx),%esi
  8004b6:	89 f3                	mov    %esi,%ebx
  8004b8:	80 fb 19             	cmp    $0x19,%bl
  8004bb:	77 08                	ja     8004c5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8004bd:	0f be d2             	movsbl %dl,%edx
  8004c0:	83 ea 57             	sub    $0x57,%edx
  8004c3:	eb 10                	jmp    8004d5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8004c5:	8d 72 bf             	lea    -0x41(%edx),%esi
  8004c8:	89 f3                	mov    %esi,%ebx
  8004ca:	80 fb 19             	cmp    $0x19,%bl
  8004cd:	77 16                	ja     8004e5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8004cf:	0f be d2             	movsbl %dl,%edx
  8004d2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8004d5:	3b 55 10             	cmp    0x10(%ebp),%edx
  8004d8:	7d 0b                	jge    8004e5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8004da:	83 c1 01             	add    $0x1,%ecx
  8004dd:	0f af 45 10          	imul   0x10(%ebp),%eax
  8004e1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8004e3:	eb b9                	jmp    80049e <strtol+0x76>

	if (endptr)
  8004e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004e9:	74 0d                	je     8004f8 <strtol+0xd0>
		*endptr = (char *) s;
  8004eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004ee:	89 0e                	mov    %ecx,(%esi)
  8004f0:	eb 06                	jmp    8004f8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004f2:	85 db                	test   %ebx,%ebx
  8004f4:	74 98                	je     80048e <strtol+0x66>
  8004f6:	eb 9e                	jmp    800496 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  8004f8:	89 c2                	mov    %eax,%edx
  8004fa:	f7 da                	neg    %edx
  8004fc:	85 ff                	test   %edi,%edi
  8004fe:	0f 45 c2             	cmovne %edx,%eax
}
  800501:	5b                   	pop    %ebx
  800502:	5e                   	pop    %esi
  800503:	5f                   	pop    %edi
  800504:	5d                   	pop    %ebp
  800505:	c3                   	ret    

00800506 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	57                   	push   %edi
  80050a:	56                   	push   %esi
  80050b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80050c:	b8 00 00 00 00       	mov    $0x0,%eax
  800511:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800514:	8b 55 08             	mov    0x8(%ebp),%edx
  800517:	89 c3                	mov    %eax,%ebx
  800519:	89 c7                	mov    %eax,%edi
  80051b:	89 c6                	mov    %eax,%esi
  80051d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80051f:	5b                   	pop    %ebx
  800520:	5e                   	pop    %esi
  800521:	5f                   	pop    %edi
  800522:	5d                   	pop    %ebp
  800523:	c3                   	ret    

00800524 <sys_cgetc>:

int
sys_cgetc(void)
{
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	57                   	push   %edi
  800528:	56                   	push   %esi
  800529:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80052a:	ba 00 00 00 00       	mov    $0x0,%edx
  80052f:	b8 01 00 00 00       	mov    $0x1,%eax
  800534:	89 d1                	mov    %edx,%ecx
  800536:	89 d3                	mov    %edx,%ebx
  800538:	89 d7                	mov    %edx,%edi
  80053a:	89 d6                	mov    %edx,%esi
  80053c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80053e:	5b                   	pop    %ebx
  80053f:	5e                   	pop    %esi
  800540:	5f                   	pop    %edi
  800541:	5d                   	pop    %ebp
  800542:	c3                   	ret    

00800543 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800543:	55                   	push   %ebp
  800544:	89 e5                	mov    %esp,%ebp
  800546:	57                   	push   %edi
  800547:	56                   	push   %esi
  800548:	53                   	push   %ebx
  800549:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80054c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800551:	b8 03 00 00 00       	mov    $0x3,%eax
  800556:	8b 55 08             	mov    0x8(%ebp),%edx
  800559:	89 cb                	mov    %ecx,%ebx
  80055b:	89 cf                	mov    %ecx,%edi
  80055d:	89 ce                	mov    %ecx,%esi
  80055f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800561:	85 c0                	test   %eax,%eax
  800563:	7e 17                	jle    80057c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800565:	83 ec 0c             	sub    $0xc,%esp
  800568:	50                   	push   %eax
  800569:	6a 03                	push   $0x3
  80056b:	68 af 1e 80 00       	push   $0x801eaf
  800570:	6a 23                	push   $0x23
  800572:	68 cc 1e 80 00       	push   $0x801ecc
  800577:	e8 21 0f 00 00       	call   80149d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80057c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80057f:	5b                   	pop    %ebx
  800580:	5e                   	pop    %esi
  800581:	5f                   	pop    %edi
  800582:	5d                   	pop    %ebp
  800583:	c3                   	ret    

00800584 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	57                   	push   %edi
  800588:	56                   	push   %esi
  800589:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80058a:	ba 00 00 00 00       	mov    $0x0,%edx
  80058f:	b8 02 00 00 00       	mov    $0x2,%eax
  800594:	89 d1                	mov    %edx,%ecx
  800596:	89 d3                	mov    %edx,%ebx
  800598:	89 d7                	mov    %edx,%edi
  80059a:	89 d6                	mov    %edx,%esi
  80059c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80059e:	5b                   	pop    %ebx
  80059f:	5e                   	pop    %esi
  8005a0:	5f                   	pop    %edi
  8005a1:	5d                   	pop    %ebp
  8005a2:	c3                   	ret    

008005a3 <sys_yield>:

void
sys_yield(void)
{
  8005a3:	55                   	push   %ebp
  8005a4:	89 e5                	mov    %esp,%ebp
  8005a6:	57                   	push   %edi
  8005a7:	56                   	push   %esi
  8005a8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ae:	b8 0b 00 00 00       	mov    $0xb,%eax
  8005b3:	89 d1                	mov    %edx,%ecx
  8005b5:	89 d3                	mov    %edx,%ebx
  8005b7:	89 d7                	mov    %edx,%edi
  8005b9:	89 d6                	mov    %edx,%esi
  8005bb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8005bd:	5b                   	pop    %ebx
  8005be:	5e                   	pop    %esi
  8005bf:	5f                   	pop    %edi
  8005c0:	5d                   	pop    %ebp
  8005c1:	c3                   	ret    

008005c2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8005c2:	55                   	push   %ebp
  8005c3:	89 e5                	mov    %esp,%ebp
  8005c5:	57                   	push   %edi
  8005c6:	56                   	push   %esi
  8005c7:	53                   	push   %ebx
  8005c8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005cb:	be 00 00 00 00       	mov    $0x0,%esi
  8005d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8005d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005de:	89 f7                	mov    %esi,%edi
  8005e0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	7e 17                	jle    8005fd <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e6:	83 ec 0c             	sub    $0xc,%esp
  8005e9:	50                   	push   %eax
  8005ea:	6a 04                	push   $0x4
  8005ec:	68 af 1e 80 00       	push   $0x801eaf
  8005f1:	6a 23                	push   $0x23
  8005f3:	68 cc 1e 80 00       	push   $0x801ecc
  8005f8:	e8 a0 0e 00 00       	call   80149d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800600:	5b                   	pop    %ebx
  800601:	5e                   	pop    %esi
  800602:	5f                   	pop    %edi
  800603:	5d                   	pop    %ebp
  800604:	c3                   	ret    

00800605 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	57                   	push   %edi
  800609:	56                   	push   %esi
  80060a:	53                   	push   %ebx
  80060b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80060e:	b8 05 00 00 00       	mov    $0x5,%eax
  800613:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800616:	8b 55 08             	mov    0x8(%ebp),%edx
  800619:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80061c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80061f:	8b 75 18             	mov    0x18(%ebp),%esi
  800622:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800624:	85 c0                	test   %eax,%eax
  800626:	7e 17                	jle    80063f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800628:	83 ec 0c             	sub    $0xc,%esp
  80062b:	50                   	push   %eax
  80062c:	6a 05                	push   $0x5
  80062e:	68 af 1e 80 00       	push   $0x801eaf
  800633:	6a 23                	push   $0x23
  800635:	68 cc 1e 80 00       	push   $0x801ecc
  80063a:	e8 5e 0e 00 00       	call   80149d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80063f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800642:	5b                   	pop    %ebx
  800643:	5e                   	pop    %esi
  800644:	5f                   	pop    %edi
  800645:	5d                   	pop    %ebp
  800646:	c3                   	ret    

00800647 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800647:	55                   	push   %ebp
  800648:	89 e5                	mov    %esp,%ebp
  80064a:	57                   	push   %edi
  80064b:	56                   	push   %esi
  80064c:	53                   	push   %ebx
  80064d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800650:	bb 00 00 00 00       	mov    $0x0,%ebx
  800655:	b8 06 00 00 00       	mov    $0x6,%eax
  80065a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80065d:	8b 55 08             	mov    0x8(%ebp),%edx
  800660:	89 df                	mov    %ebx,%edi
  800662:	89 de                	mov    %ebx,%esi
  800664:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800666:	85 c0                	test   %eax,%eax
  800668:	7e 17                	jle    800681 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80066a:	83 ec 0c             	sub    $0xc,%esp
  80066d:	50                   	push   %eax
  80066e:	6a 06                	push   $0x6
  800670:	68 af 1e 80 00       	push   $0x801eaf
  800675:	6a 23                	push   $0x23
  800677:	68 cc 1e 80 00       	push   $0x801ecc
  80067c:	e8 1c 0e 00 00       	call   80149d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800681:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800684:	5b                   	pop    %ebx
  800685:	5e                   	pop    %esi
  800686:	5f                   	pop    %edi
  800687:	5d                   	pop    %ebp
  800688:	c3                   	ret    

00800689 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800689:	55                   	push   %ebp
  80068a:	89 e5                	mov    %esp,%ebp
  80068c:	57                   	push   %edi
  80068d:	56                   	push   %esi
  80068e:	53                   	push   %ebx
  80068f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800692:	bb 00 00 00 00       	mov    $0x0,%ebx
  800697:	b8 08 00 00 00       	mov    $0x8,%eax
  80069c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80069f:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a2:	89 df                	mov    %ebx,%edi
  8006a4:	89 de                	mov    %ebx,%esi
  8006a6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006a8:	85 c0                	test   %eax,%eax
  8006aa:	7e 17                	jle    8006c3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ac:	83 ec 0c             	sub    $0xc,%esp
  8006af:	50                   	push   %eax
  8006b0:	6a 08                	push   $0x8
  8006b2:	68 af 1e 80 00       	push   $0x801eaf
  8006b7:	6a 23                	push   $0x23
  8006b9:	68 cc 1e 80 00       	push   $0x801ecc
  8006be:	e8 da 0d 00 00       	call   80149d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8006c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c6:	5b                   	pop    %ebx
  8006c7:	5e                   	pop    %esi
  8006c8:	5f                   	pop    %edi
  8006c9:	5d                   	pop    %ebp
  8006ca:	c3                   	ret    

008006cb <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	57                   	push   %edi
  8006cf:	56                   	push   %esi
  8006d0:	53                   	push   %ebx
  8006d1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d9:	b8 09 00 00 00       	mov    $0x9,%eax
  8006de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e4:	89 df                	mov    %ebx,%edi
  8006e6:	89 de                	mov    %ebx,%esi
  8006e8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	7e 17                	jle    800705 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ee:	83 ec 0c             	sub    $0xc,%esp
  8006f1:	50                   	push   %eax
  8006f2:	6a 09                	push   $0x9
  8006f4:	68 af 1e 80 00       	push   $0x801eaf
  8006f9:	6a 23                	push   $0x23
  8006fb:	68 cc 1e 80 00       	push   $0x801ecc
  800700:	e8 98 0d 00 00       	call   80149d <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	57                   	push   %edi
  800711:	56                   	push   %esi
  800712:	53                   	push   %ebx
  800713:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800716:	bb 00 00 00 00       	mov    $0x0,%ebx
  80071b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800723:	8b 55 08             	mov    0x8(%ebp),%edx
  800726:	89 df                	mov    %ebx,%edi
  800728:	89 de                	mov    %ebx,%esi
  80072a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80072c:	85 c0                	test   %eax,%eax
  80072e:	7e 17                	jle    800747 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800730:	83 ec 0c             	sub    $0xc,%esp
  800733:	50                   	push   %eax
  800734:	6a 0a                	push   $0xa
  800736:	68 af 1e 80 00       	push   $0x801eaf
  80073b:	6a 23                	push   $0x23
  80073d:	68 cc 1e 80 00       	push   $0x801ecc
  800742:	e8 56 0d 00 00       	call   80149d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800747:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074a:	5b                   	pop    %ebx
  80074b:	5e                   	pop    %esi
  80074c:	5f                   	pop    %edi
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	57                   	push   %edi
  800753:	56                   	push   %esi
  800754:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800755:	be 00 00 00 00       	mov    $0x0,%esi
  80075a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80075f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800762:	8b 55 08             	mov    0x8(%ebp),%edx
  800765:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800768:	8b 7d 14             	mov    0x14(%ebp),%edi
  80076b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	5f                   	pop    %edi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	57                   	push   %edi
  800776:	56                   	push   %esi
  800777:	53                   	push   %ebx
  800778:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80077b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800780:	b8 0d 00 00 00       	mov    $0xd,%eax
  800785:	8b 55 08             	mov    0x8(%ebp),%edx
  800788:	89 cb                	mov    %ecx,%ebx
  80078a:	89 cf                	mov    %ecx,%edi
  80078c:	89 ce                	mov    %ecx,%esi
  80078e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800790:	85 c0                	test   %eax,%eax
  800792:	7e 17                	jle    8007ab <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800794:	83 ec 0c             	sub    $0xc,%esp
  800797:	50                   	push   %eax
  800798:	6a 0d                	push   $0xd
  80079a:	68 af 1e 80 00       	push   $0x801eaf
  80079f:	6a 23                	push   $0x23
  8007a1:	68 cc 1e 80 00       	push   $0x801ecc
  8007a6:	e8 f2 0c 00 00       	call   80149d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8007ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ae:	5b                   	pop    %ebx
  8007af:	5e                   	pop    %esi
  8007b0:	5f                   	pop    %edi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	05 00 00 00 30       	add    $0x30000000,%eax
  8007be:	c1 e8 0c             	shr    $0xc,%eax
}
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8007c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c9:	05 00 00 00 30       	add    $0x30000000,%eax
  8007ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8007d3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	c1 ea 16             	shr    $0x16,%edx
  8007ea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007f1:	f6 c2 01             	test   $0x1,%dl
  8007f4:	74 11                	je     800807 <fd_alloc+0x2d>
  8007f6:	89 c2                	mov    %eax,%edx
  8007f8:	c1 ea 0c             	shr    $0xc,%edx
  8007fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800802:	f6 c2 01             	test   $0x1,%dl
  800805:	75 09                	jne    800810 <fd_alloc+0x36>
			*fd_store = fd;
  800807:	89 01                	mov    %eax,(%ecx)
			return 0;
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
  80080e:	eb 17                	jmp    800827 <fd_alloc+0x4d>
  800810:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800815:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80081a:	75 c9                	jne    8007e5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80081c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800822:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80082f:	83 f8 1f             	cmp    $0x1f,%eax
  800832:	77 36                	ja     80086a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800834:	c1 e0 0c             	shl    $0xc,%eax
  800837:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80083c:	89 c2                	mov    %eax,%edx
  80083e:	c1 ea 16             	shr    $0x16,%edx
  800841:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800848:	f6 c2 01             	test   $0x1,%dl
  80084b:	74 24                	je     800871 <fd_lookup+0x48>
  80084d:	89 c2                	mov    %eax,%edx
  80084f:	c1 ea 0c             	shr    $0xc,%edx
  800852:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800859:	f6 c2 01             	test   $0x1,%dl
  80085c:	74 1a                	je     800878 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	89 02                	mov    %eax,(%edx)
	return 0;
  800863:	b8 00 00 00 00       	mov    $0x0,%eax
  800868:	eb 13                	jmp    80087d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80086a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086f:	eb 0c                	jmp    80087d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800871:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800876:	eb 05                	jmp    80087d <fd_lookup+0x54>
  800878:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	ba 58 1f 80 00       	mov    $0x801f58,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80088d:	eb 13                	jmp    8008a2 <dev_lookup+0x23>
  80088f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800892:	39 08                	cmp    %ecx,(%eax)
  800894:	75 0c                	jne    8008a2 <dev_lookup+0x23>
			*dev = devtab[i];
  800896:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800899:	89 01                	mov    %eax,(%ecx)
			return 0;
  80089b:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a0:	eb 2e                	jmp    8008d0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008a2:	8b 02                	mov    (%edx),%eax
  8008a4:	85 c0                	test   %eax,%eax
  8008a6:	75 e7                	jne    80088f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8008a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8008ad:	8b 40 48             	mov    0x48(%eax),%eax
  8008b0:	83 ec 04             	sub    $0x4,%esp
  8008b3:	51                   	push   %ecx
  8008b4:	50                   	push   %eax
  8008b5:	68 dc 1e 80 00       	push   $0x801edc
  8008ba:	e8 b7 0c 00 00       	call   801576 <cprintf>
	*dev = 0;
  8008bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8008c8:	83 c4 10             	add    $0x10,%esp
  8008cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008d0:	c9                   	leave  
  8008d1:	c3                   	ret    

008008d2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	83 ec 10             	sub    $0x10,%esp
  8008da:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008e3:	50                   	push   %eax
  8008e4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008ea:	c1 e8 0c             	shr    $0xc,%eax
  8008ed:	50                   	push   %eax
  8008ee:	e8 36 ff ff ff       	call   800829 <fd_lookup>
  8008f3:	83 c4 08             	add    $0x8,%esp
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	78 05                	js     8008ff <fd_close+0x2d>
	    || fd != fd2)
  8008fa:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008fd:	74 0c                	je     80090b <fd_close+0x39>
		return (must_exist ? r : 0);
  8008ff:	84 db                	test   %bl,%bl
  800901:	ba 00 00 00 00       	mov    $0x0,%edx
  800906:	0f 44 c2             	cmove  %edx,%eax
  800909:	eb 41                	jmp    80094c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800911:	50                   	push   %eax
  800912:	ff 36                	pushl  (%esi)
  800914:	e8 66 ff ff ff       	call   80087f <dev_lookup>
  800919:	89 c3                	mov    %eax,%ebx
  80091b:	83 c4 10             	add    $0x10,%esp
  80091e:	85 c0                	test   %eax,%eax
  800920:	78 1a                	js     80093c <fd_close+0x6a>
		if (dev->dev_close)
  800922:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800925:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800928:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80092d:	85 c0                	test   %eax,%eax
  80092f:	74 0b                	je     80093c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800931:	83 ec 0c             	sub    $0xc,%esp
  800934:	56                   	push   %esi
  800935:	ff d0                	call   *%eax
  800937:	89 c3                	mov    %eax,%ebx
  800939:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80093c:	83 ec 08             	sub    $0x8,%esp
  80093f:	56                   	push   %esi
  800940:	6a 00                	push   $0x0
  800942:	e8 00 fd ff ff       	call   800647 <sys_page_unmap>
	return r;
  800947:	83 c4 10             	add    $0x10,%esp
  80094a:	89 d8                	mov    %ebx,%eax
}
  80094c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800959:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80095c:	50                   	push   %eax
  80095d:	ff 75 08             	pushl  0x8(%ebp)
  800960:	e8 c4 fe ff ff       	call   800829 <fd_lookup>
  800965:	83 c4 08             	add    $0x8,%esp
  800968:	85 c0                	test   %eax,%eax
  80096a:	78 10                	js     80097c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80096c:	83 ec 08             	sub    $0x8,%esp
  80096f:	6a 01                	push   $0x1
  800971:	ff 75 f4             	pushl  -0xc(%ebp)
  800974:	e8 59 ff ff ff       	call   8008d2 <fd_close>
  800979:	83 c4 10             	add    $0x10,%esp
}
  80097c:	c9                   	leave  
  80097d:	c3                   	ret    

0080097e <close_all>:

void
close_all(void)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	53                   	push   %ebx
  800982:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800985:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80098a:	83 ec 0c             	sub    $0xc,%esp
  80098d:	53                   	push   %ebx
  80098e:	e8 c0 ff ff ff       	call   800953 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800993:	83 c3 01             	add    $0x1,%ebx
  800996:	83 c4 10             	add    $0x10,%esp
  800999:	83 fb 20             	cmp    $0x20,%ebx
  80099c:	75 ec                	jne    80098a <close_all+0xc>
		close(i);
}
  80099e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    

008009a3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	57                   	push   %edi
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	83 ec 2c             	sub    $0x2c,%esp
  8009ac:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009af:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009b2:	50                   	push   %eax
  8009b3:	ff 75 08             	pushl  0x8(%ebp)
  8009b6:	e8 6e fe ff ff       	call   800829 <fd_lookup>
  8009bb:	83 c4 08             	add    $0x8,%esp
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	0f 88 c1 00 00 00    	js     800a87 <dup+0xe4>
		return r;
	close(newfdnum);
  8009c6:	83 ec 0c             	sub    $0xc,%esp
  8009c9:	56                   	push   %esi
  8009ca:	e8 84 ff ff ff       	call   800953 <close>

	newfd = INDEX2FD(newfdnum);
  8009cf:	89 f3                	mov    %esi,%ebx
  8009d1:	c1 e3 0c             	shl    $0xc,%ebx
  8009d4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8009da:	83 c4 04             	add    $0x4,%esp
  8009dd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009e0:	e8 de fd ff ff       	call   8007c3 <fd2data>
  8009e5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8009e7:	89 1c 24             	mov    %ebx,(%esp)
  8009ea:	e8 d4 fd ff ff       	call   8007c3 <fd2data>
  8009ef:	83 c4 10             	add    $0x10,%esp
  8009f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009f5:	89 f8                	mov    %edi,%eax
  8009f7:	c1 e8 16             	shr    $0x16,%eax
  8009fa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a01:	a8 01                	test   $0x1,%al
  800a03:	74 37                	je     800a3c <dup+0x99>
  800a05:	89 f8                	mov    %edi,%eax
  800a07:	c1 e8 0c             	shr    $0xc,%eax
  800a0a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a11:	f6 c2 01             	test   $0x1,%dl
  800a14:	74 26                	je     800a3c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a16:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a1d:	83 ec 0c             	sub    $0xc,%esp
  800a20:	25 07 0e 00 00       	and    $0xe07,%eax
  800a25:	50                   	push   %eax
  800a26:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a29:	6a 00                	push   $0x0
  800a2b:	57                   	push   %edi
  800a2c:	6a 00                	push   $0x0
  800a2e:	e8 d2 fb ff ff       	call   800605 <sys_page_map>
  800a33:	89 c7                	mov    %eax,%edi
  800a35:	83 c4 20             	add    $0x20,%esp
  800a38:	85 c0                	test   %eax,%eax
  800a3a:	78 2e                	js     800a6a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a3c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a3f:	89 d0                	mov    %edx,%eax
  800a41:	c1 e8 0c             	shr    $0xc,%eax
  800a44:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a4b:	83 ec 0c             	sub    $0xc,%esp
  800a4e:	25 07 0e 00 00       	and    $0xe07,%eax
  800a53:	50                   	push   %eax
  800a54:	53                   	push   %ebx
  800a55:	6a 00                	push   $0x0
  800a57:	52                   	push   %edx
  800a58:	6a 00                	push   $0x0
  800a5a:	e8 a6 fb ff ff       	call   800605 <sys_page_map>
  800a5f:	89 c7                	mov    %eax,%edi
  800a61:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a64:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a66:	85 ff                	test   %edi,%edi
  800a68:	79 1d                	jns    800a87 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a6a:	83 ec 08             	sub    $0x8,%esp
  800a6d:	53                   	push   %ebx
  800a6e:	6a 00                	push   $0x0
  800a70:	e8 d2 fb ff ff       	call   800647 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a75:	83 c4 08             	add    $0x8,%esp
  800a78:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a7b:	6a 00                	push   $0x0
  800a7d:	e8 c5 fb ff ff       	call   800647 <sys_page_unmap>
	return r;
  800a82:	83 c4 10             	add    $0x10,%esp
  800a85:	89 f8                	mov    %edi,%eax
}
  800a87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5f                   	pop    %edi
  800a8d:	5d                   	pop    %ebp
  800a8e:	c3                   	ret    

00800a8f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	53                   	push   %ebx
  800a93:	83 ec 14             	sub    $0x14,%esp
  800a96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a9c:	50                   	push   %eax
  800a9d:	53                   	push   %ebx
  800a9e:	e8 86 fd ff ff       	call   800829 <fd_lookup>
  800aa3:	83 c4 08             	add    $0x8,%esp
  800aa6:	89 c2                	mov    %eax,%edx
  800aa8:	85 c0                	test   %eax,%eax
  800aaa:	78 6d                	js     800b19 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800aac:	83 ec 08             	sub    $0x8,%esp
  800aaf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab2:	50                   	push   %eax
  800ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab6:	ff 30                	pushl  (%eax)
  800ab8:	e8 c2 fd ff ff       	call   80087f <dev_lookup>
  800abd:	83 c4 10             	add    $0x10,%esp
  800ac0:	85 c0                	test   %eax,%eax
  800ac2:	78 4c                	js     800b10 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ac4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ac7:	8b 42 08             	mov    0x8(%edx),%eax
  800aca:	83 e0 03             	and    $0x3,%eax
  800acd:	83 f8 01             	cmp    $0x1,%eax
  800ad0:	75 21                	jne    800af3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ad2:	a1 04 40 80 00       	mov    0x804004,%eax
  800ad7:	8b 40 48             	mov    0x48(%eax),%eax
  800ada:	83 ec 04             	sub    $0x4,%esp
  800add:	53                   	push   %ebx
  800ade:	50                   	push   %eax
  800adf:	68 1d 1f 80 00       	push   $0x801f1d
  800ae4:	e8 8d 0a 00 00       	call   801576 <cprintf>
		return -E_INVAL;
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800af1:	eb 26                	jmp    800b19 <read+0x8a>
	}
	if (!dev->dev_read)
  800af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800af6:	8b 40 08             	mov    0x8(%eax),%eax
  800af9:	85 c0                	test   %eax,%eax
  800afb:	74 17                	je     800b14 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800afd:	83 ec 04             	sub    $0x4,%esp
  800b00:	ff 75 10             	pushl  0x10(%ebp)
  800b03:	ff 75 0c             	pushl  0xc(%ebp)
  800b06:	52                   	push   %edx
  800b07:	ff d0                	call   *%eax
  800b09:	89 c2                	mov    %eax,%edx
  800b0b:	83 c4 10             	add    $0x10,%esp
  800b0e:	eb 09                	jmp    800b19 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b10:	89 c2                	mov    %eax,%edx
  800b12:	eb 05                	jmp    800b19 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b14:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800b19:	89 d0                	mov    %edx,%eax
  800b1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

00800b20 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	83 ec 0c             	sub    $0xc,%esp
  800b29:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b34:	eb 21                	jmp    800b57 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b36:	83 ec 04             	sub    $0x4,%esp
  800b39:	89 f0                	mov    %esi,%eax
  800b3b:	29 d8                	sub    %ebx,%eax
  800b3d:	50                   	push   %eax
  800b3e:	89 d8                	mov    %ebx,%eax
  800b40:	03 45 0c             	add    0xc(%ebp),%eax
  800b43:	50                   	push   %eax
  800b44:	57                   	push   %edi
  800b45:	e8 45 ff ff ff       	call   800a8f <read>
		if (m < 0)
  800b4a:	83 c4 10             	add    $0x10,%esp
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	78 10                	js     800b61 <readn+0x41>
			return m;
		if (m == 0)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	74 0a                	je     800b5f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b55:	01 c3                	add    %eax,%ebx
  800b57:	39 f3                	cmp    %esi,%ebx
  800b59:	72 db                	jb     800b36 <readn+0x16>
  800b5b:	89 d8                	mov    %ebx,%eax
  800b5d:	eb 02                	jmp    800b61 <readn+0x41>
  800b5f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	53                   	push   %ebx
  800b6d:	83 ec 14             	sub    $0x14,%esp
  800b70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b76:	50                   	push   %eax
  800b77:	53                   	push   %ebx
  800b78:	e8 ac fc ff ff       	call   800829 <fd_lookup>
  800b7d:	83 c4 08             	add    $0x8,%esp
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	85 c0                	test   %eax,%eax
  800b84:	78 68                	js     800bee <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b86:	83 ec 08             	sub    $0x8,%esp
  800b89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b8c:	50                   	push   %eax
  800b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b90:	ff 30                	pushl  (%eax)
  800b92:	e8 e8 fc ff ff       	call   80087f <dev_lookup>
  800b97:	83 c4 10             	add    $0x10,%esp
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	78 47                	js     800be5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ba1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ba5:	75 21                	jne    800bc8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800ba7:	a1 04 40 80 00       	mov    0x804004,%eax
  800bac:	8b 40 48             	mov    0x48(%eax),%eax
  800baf:	83 ec 04             	sub    $0x4,%esp
  800bb2:	53                   	push   %ebx
  800bb3:	50                   	push   %eax
  800bb4:	68 39 1f 80 00       	push   $0x801f39
  800bb9:	e8 b8 09 00 00       	call   801576 <cprintf>
		return -E_INVAL;
  800bbe:	83 c4 10             	add    $0x10,%esp
  800bc1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bc6:	eb 26                	jmp    800bee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800bc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bcb:	8b 52 0c             	mov    0xc(%edx),%edx
  800bce:	85 d2                	test   %edx,%edx
  800bd0:	74 17                	je     800be9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800bd2:	83 ec 04             	sub    $0x4,%esp
  800bd5:	ff 75 10             	pushl  0x10(%ebp)
  800bd8:	ff 75 0c             	pushl  0xc(%ebp)
  800bdb:	50                   	push   %eax
  800bdc:	ff d2                	call   *%edx
  800bde:	89 c2                	mov    %eax,%edx
  800be0:	83 c4 10             	add    $0x10,%esp
  800be3:	eb 09                	jmp    800bee <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800be5:	89 c2                	mov    %eax,%edx
  800be7:	eb 05                	jmp    800bee <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800be9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800bee:	89 d0                	mov    %edx,%eax
  800bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <seek>:

int
seek(int fdnum, off_t offset)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bfb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800bfe:	50                   	push   %eax
  800bff:	ff 75 08             	pushl  0x8(%ebp)
  800c02:	e8 22 fc ff ff       	call   800829 <fd_lookup>
  800c07:	83 c4 08             	add    $0x8,%esp
  800c0a:	85 c0                	test   %eax,%eax
  800c0c:	78 0e                	js     800c1c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800c0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c14:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800c17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c1c:	c9                   	leave  
  800c1d:	c3                   	ret    

00800c1e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	53                   	push   %ebx
  800c22:	83 ec 14             	sub    $0x14,%esp
  800c25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c28:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c2b:	50                   	push   %eax
  800c2c:	53                   	push   %ebx
  800c2d:	e8 f7 fb ff ff       	call   800829 <fd_lookup>
  800c32:	83 c4 08             	add    $0x8,%esp
  800c35:	89 c2                	mov    %eax,%edx
  800c37:	85 c0                	test   %eax,%eax
  800c39:	78 65                	js     800ca0 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c3b:	83 ec 08             	sub    $0x8,%esp
  800c3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c41:	50                   	push   %eax
  800c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c45:	ff 30                	pushl  (%eax)
  800c47:	e8 33 fc ff ff       	call   80087f <dev_lookup>
  800c4c:	83 c4 10             	add    $0x10,%esp
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	78 44                	js     800c97 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c56:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c5a:	75 21                	jne    800c7d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c5c:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c61:	8b 40 48             	mov    0x48(%eax),%eax
  800c64:	83 ec 04             	sub    $0x4,%esp
  800c67:	53                   	push   %ebx
  800c68:	50                   	push   %eax
  800c69:	68 fc 1e 80 00       	push   $0x801efc
  800c6e:	e8 03 09 00 00       	call   801576 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c7b:	eb 23                	jmp    800ca0 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c80:	8b 52 18             	mov    0x18(%edx),%edx
  800c83:	85 d2                	test   %edx,%edx
  800c85:	74 14                	je     800c9b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c87:	83 ec 08             	sub    $0x8,%esp
  800c8a:	ff 75 0c             	pushl  0xc(%ebp)
  800c8d:	50                   	push   %eax
  800c8e:	ff d2                	call   *%edx
  800c90:	89 c2                	mov    %eax,%edx
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	eb 09                	jmp    800ca0 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c97:	89 c2                	mov    %eax,%edx
  800c99:	eb 05                	jmp    800ca0 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c9b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800ca0:	89 d0                	mov    %edx,%eax
  800ca2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ca5:	c9                   	leave  
  800ca6:	c3                   	ret    

00800ca7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	53                   	push   %ebx
  800cab:	83 ec 14             	sub    $0x14,%esp
  800cae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cb1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cb4:	50                   	push   %eax
  800cb5:	ff 75 08             	pushl  0x8(%ebp)
  800cb8:	e8 6c fb ff ff       	call   800829 <fd_lookup>
  800cbd:	83 c4 08             	add    $0x8,%esp
  800cc0:	89 c2                	mov    %eax,%edx
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	78 58                	js     800d1e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cc6:	83 ec 08             	sub    $0x8,%esp
  800cc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ccc:	50                   	push   %eax
  800ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd0:	ff 30                	pushl  (%eax)
  800cd2:	e8 a8 fb ff ff       	call   80087f <dev_lookup>
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	78 37                	js     800d15 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ce5:	74 32                	je     800d19 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ce7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800cea:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cf1:	00 00 00 
	stat->st_isdir = 0;
  800cf4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cfb:	00 00 00 
	stat->st_dev = dev;
  800cfe:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d04:	83 ec 08             	sub    $0x8,%esp
  800d07:	53                   	push   %ebx
  800d08:	ff 75 f0             	pushl  -0x10(%ebp)
  800d0b:	ff 50 14             	call   *0x14(%eax)
  800d0e:	89 c2                	mov    %eax,%edx
  800d10:	83 c4 10             	add    $0x10,%esp
  800d13:	eb 09                	jmp    800d1e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d15:	89 c2                	mov    %eax,%edx
  800d17:	eb 05                	jmp    800d1e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800d19:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800d1e:	89 d0                	mov    %edx,%eax
  800d20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d23:	c9                   	leave  
  800d24:	c3                   	ret    

00800d25 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d2a:	83 ec 08             	sub    $0x8,%esp
  800d2d:	6a 00                	push   $0x0
  800d2f:	ff 75 08             	pushl  0x8(%ebp)
  800d32:	e8 e3 01 00 00       	call   800f1a <open>
  800d37:	89 c3                	mov    %eax,%ebx
  800d39:	83 c4 10             	add    $0x10,%esp
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	78 1b                	js     800d5b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d40:	83 ec 08             	sub    $0x8,%esp
  800d43:	ff 75 0c             	pushl  0xc(%ebp)
  800d46:	50                   	push   %eax
  800d47:	e8 5b ff ff ff       	call   800ca7 <fstat>
  800d4c:	89 c6                	mov    %eax,%esi
	close(fd);
  800d4e:	89 1c 24             	mov    %ebx,(%esp)
  800d51:	e8 fd fb ff ff       	call   800953 <close>
	return r;
  800d56:	83 c4 10             	add    $0x10,%esp
  800d59:	89 f0                	mov    %esi,%eax
}
  800d5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	89 c6                	mov    %eax,%esi
  800d69:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d6b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d72:	75 12                	jne    800d86 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d74:	83 ec 0c             	sub    $0xc,%esp
  800d77:	6a 01                	push   $0x1
  800d79:	e8 18 0e 00 00       	call   801b96 <ipc_find_env>
  800d7e:	a3 00 40 80 00       	mov    %eax,0x804000
  800d83:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d86:	6a 07                	push   $0x7
  800d88:	68 00 50 80 00       	push   $0x805000
  800d8d:	56                   	push   %esi
  800d8e:	ff 35 00 40 80 00    	pushl  0x804000
  800d94:	e8 9b 0d 00 00       	call   801b34 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d99:	83 c4 0c             	add    $0xc,%esp
  800d9c:	6a 00                	push   $0x0
  800d9e:	53                   	push   %ebx
  800d9f:	6a 00                	push   $0x0
  800da1:	e8 1c 0d 00 00       	call   801ac2 <ipc_recv>
}
  800da6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    

00800dad <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	8b 40 0c             	mov    0xc(%eax),%eax
  800db9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800dc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcb:	b8 02 00 00 00       	mov    $0x2,%eax
  800dd0:	e8 8d ff ff ff       	call   800d62 <fsipc>
}
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	8b 40 0c             	mov    0xc(%eax),%eax
  800de3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800de8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ded:	b8 06 00 00 00       	mov    $0x6,%eax
  800df2:	e8 6b ff ff ff       	call   800d62 <fsipc>
}
  800df7:	c9                   	leave  
  800df8:	c3                   	ret    

00800df9 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	8b 40 0c             	mov    0xc(%eax),%eax
  800e09:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800e0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e13:	b8 05 00 00 00       	mov    $0x5,%eax
  800e18:	e8 45 ff ff ff       	call   800d62 <fsipc>
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	78 2c                	js     800e4d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e21:	83 ec 08             	sub    $0x8,%esp
  800e24:	68 00 50 80 00       	push   $0x805000
  800e29:	53                   	push   %ebx
  800e2a:	e8 90 f3 ff ff       	call   8001bf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e2f:	a1 80 50 80 00       	mov    0x805080,%eax
  800e34:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e3a:	a1 84 50 80 00       	mov    0x805084,%eax
  800e3f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e50:	c9                   	leave  
  800e51:	c3                   	ret    

00800e52 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800e5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5e:	8b 52 0c             	mov    0xc(%edx),%edx
  800e61:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800e67:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800e6c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800e71:	0f 47 c2             	cmova  %edx,%eax
  800e74:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800e79:	50                   	push   %eax
  800e7a:	ff 75 0c             	pushl  0xc(%ebp)
  800e7d:	68 08 50 80 00       	push   $0x805008
  800e82:	e8 ca f4 ff ff       	call   800351 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800e87:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800e91:	e8 cc fe ff ff       	call   800d62 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800e96:	c9                   	leave  
  800e97:	c3                   	ret    

00800e98 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	56                   	push   %esi
  800e9c:	53                   	push   %ebx
  800e9d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea3:	8b 40 0c             	mov    0xc(%eax),%eax
  800ea6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800eab:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800eb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb6:	b8 03 00 00 00       	mov    $0x3,%eax
  800ebb:	e8 a2 fe ff ff       	call   800d62 <fsipc>
  800ec0:	89 c3                	mov    %eax,%ebx
  800ec2:	85 c0                	test   %eax,%eax
  800ec4:	78 4b                	js     800f11 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ec6:	39 c6                	cmp    %eax,%esi
  800ec8:	73 16                	jae    800ee0 <devfile_read+0x48>
  800eca:	68 68 1f 80 00       	push   $0x801f68
  800ecf:	68 6f 1f 80 00       	push   $0x801f6f
  800ed4:	6a 7c                	push   $0x7c
  800ed6:	68 84 1f 80 00       	push   $0x801f84
  800edb:	e8 bd 05 00 00       	call   80149d <_panic>
	assert(r <= PGSIZE);
  800ee0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ee5:	7e 16                	jle    800efd <devfile_read+0x65>
  800ee7:	68 8f 1f 80 00       	push   $0x801f8f
  800eec:	68 6f 1f 80 00       	push   $0x801f6f
  800ef1:	6a 7d                	push   $0x7d
  800ef3:	68 84 1f 80 00       	push   $0x801f84
  800ef8:	e8 a0 05 00 00       	call   80149d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800efd:	83 ec 04             	sub    $0x4,%esp
  800f00:	50                   	push   %eax
  800f01:	68 00 50 80 00       	push   $0x805000
  800f06:	ff 75 0c             	pushl  0xc(%ebp)
  800f09:	e8 43 f4 ff ff       	call   800351 <memmove>
	return r;
  800f0e:	83 c4 10             	add    $0x10,%esp
}
  800f11:	89 d8                	mov    %ebx,%eax
  800f13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	53                   	push   %ebx
  800f1e:	83 ec 20             	sub    $0x20,%esp
  800f21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800f24:	53                   	push   %ebx
  800f25:	e8 5c f2 ff ff       	call   800186 <strlen>
  800f2a:	83 c4 10             	add    $0x10,%esp
  800f2d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f32:	7f 67                	jg     800f9b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f34:	83 ec 0c             	sub    $0xc,%esp
  800f37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f3a:	50                   	push   %eax
  800f3b:	e8 9a f8 ff ff       	call   8007da <fd_alloc>
  800f40:	83 c4 10             	add    $0x10,%esp
		return r;
  800f43:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f45:	85 c0                	test   %eax,%eax
  800f47:	78 57                	js     800fa0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f49:	83 ec 08             	sub    $0x8,%esp
  800f4c:	53                   	push   %ebx
  800f4d:	68 00 50 80 00       	push   $0x805000
  800f52:	e8 68 f2 ff ff       	call   8001bf <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f62:	b8 01 00 00 00       	mov    $0x1,%eax
  800f67:	e8 f6 fd ff ff       	call   800d62 <fsipc>
  800f6c:	89 c3                	mov    %eax,%ebx
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	79 14                	jns    800f89 <open+0x6f>
		fd_close(fd, 0);
  800f75:	83 ec 08             	sub    $0x8,%esp
  800f78:	6a 00                	push   $0x0
  800f7a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f7d:	e8 50 f9 ff ff       	call   8008d2 <fd_close>
		return r;
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	89 da                	mov    %ebx,%edx
  800f87:	eb 17                	jmp    800fa0 <open+0x86>
	}

	return fd2num(fd);
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800f8f:	e8 1f f8 ff ff       	call   8007b3 <fd2num>
  800f94:	89 c2                	mov    %eax,%edx
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	eb 05                	jmp    800fa0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f9b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800fa0:	89 d0                	mov    %edx,%eax
  800fa2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800fad:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb2:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb7:	e8 a6 fd ff ff       	call   800d62 <fsipc>
}
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    

00800fbe <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	56                   	push   %esi
  800fc2:	53                   	push   %ebx
  800fc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fc6:	83 ec 0c             	sub    $0xc,%esp
  800fc9:	ff 75 08             	pushl  0x8(%ebp)
  800fcc:	e8 f2 f7 ff ff       	call   8007c3 <fd2data>
  800fd1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800fd3:	83 c4 08             	add    $0x8,%esp
  800fd6:	68 9b 1f 80 00       	push   $0x801f9b
  800fdb:	53                   	push   %ebx
  800fdc:	e8 de f1 ff ff       	call   8001bf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800fe1:	8b 46 04             	mov    0x4(%esi),%eax
  800fe4:	2b 06                	sub    (%esi),%eax
  800fe6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800fec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ff3:	00 00 00 
	stat->st_dev = &devpipe;
  800ff6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ffd:	30 80 00 
	return 0;
}
  801000:	b8 00 00 00 00       	mov    $0x0,%eax
  801005:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	53                   	push   %ebx
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801016:	53                   	push   %ebx
  801017:	6a 00                	push   $0x0
  801019:	e8 29 f6 ff ff       	call   800647 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80101e:	89 1c 24             	mov    %ebx,(%esp)
  801021:	e8 9d f7 ff ff       	call   8007c3 <fd2data>
  801026:	83 c4 08             	add    $0x8,%esp
  801029:	50                   	push   %eax
  80102a:	6a 00                	push   $0x0
  80102c:	e8 16 f6 ff ff       	call   800647 <sys_page_unmap>
}
  801031:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
  80103c:	83 ec 1c             	sub    $0x1c,%esp
  80103f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801042:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801044:	a1 04 40 80 00       	mov    0x804004,%eax
  801049:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	ff 75 e0             	pushl  -0x20(%ebp)
  801052:	e8 78 0b 00 00       	call   801bcf <pageref>
  801057:	89 c3                	mov    %eax,%ebx
  801059:	89 3c 24             	mov    %edi,(%esp)
  80105c:	e8 6e 0b 00 00       	call   801bcf <pageref>
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	39 c3                	cmp    %eax,%ebx
  801066:	0f 94 c1             	sete   %cl
  801069:	0f b6 c9             	movzbl %cl,%ecx
  80106c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80106f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801075:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801078:	39 ce                	cmp    %ecx,%esi
  80107a:	74 1b                	je     801097 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80107c:	39 c3                	cmp    %eax,%ebx
  80107e:	75 c4                	jne    801044 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801080:	8b 42 58             	mov    0x58(%edx),%eax
  801083:	ff 75 e4             	pushl  -0x1c(%ebp)
  801086:	50                   	push   %eax
  801087:	56                   	push   %esi
  801088:	68 a2 1f 80 00       	push   $0x801fa2
  80108d:	e8 e4 04 00 00       	call   801576 <cprintf>
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	eb ad                	jmp    801044 <_pipeisclosed+0xe>
	}
}
  801097:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80109a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5f                   	pop    %edi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 28             	sub    $0x28,%esp
  8010ab:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010ae:	56                   	push   %esi
  8010af:	e8 0f f7 ff ff       	call   8007c3 <fd2data>
  8010b4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	bf 00 00 00 00       	mov    $0x0,%edi
  8010be:	eb 4b                	jmp    80110b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010c0:	89 da                	mov    %ebx,%edx
  8010c2:	89 f0                	mov    %esi,%eax
  8010c4:	e8 6d ff ff ff       	call   801036 <_pipeisclosed>
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	75 48                	jne    801115 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8010cd:	e8 d1 f4 ff ff       	call   8005a3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010d2:	8b 43 04             	mov    0x4(%ebx),%eax
  8010d5:	8b 0b                	mov    (%ebx),%ecx
  8010d7:	8d 51 20             	lea    0x20(%ecx),%edx
  8010da:	39 d0                	cmp    %edx,%eax
  8010dc:	73 e2                	jae    8010c0 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010e5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010e8:	89 c2                	mov    %eax,%edx
  8010ea:	c1 fa 1f             	sar    $0x1f,%edx
  8010ed:	89 d1                	mov    %edx,%ecx
  8010ef:	c1 e9 1b             	shr    $0x1b,%ecx
  8010f2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8010f5:	83 e2 1f             	and    $0x1f,%edx
  8010f8:	29 ca                	sub    %ecx,%edx
  8010fa:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8010fe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801102:	83 c0 01             	add    $0x1,%eax
  801105:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801108:	83 c7 01             	add    $0x1,%edi
  80110b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80110e:	75 c2                	jne    8010d2 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801110:	8b 45 10             	mov    0x10(%ebp),%eax
  801113:	eb 05                	jmp    80111a <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801115:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80111a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111d:	5b                   	pop    %ebx
  80111e:	5e                   	pop    %esi
  80111f:	5f                   	pop    %edi
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	57                   	push   %edi
  801126:	56                   	push   %esi
  801127:	53                   	push   %ebx
  801128:	83 ec 18             	sub    $0x18,%esp
  80112b:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80112e:	57                   	push   %edi
  80112f:	e8 8f f6 ff ff       	call   8007c3 <fd2data>
  801134:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113e:	eb 3d                	jmp    80117d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801140:	85 db                	test   %ebx,%ebx
  801142:	74 04                	je     801148 <devpipe_read+0x26>
				return i;
  801144:	89 d8                	mov    %ebx,%eax
  801146:	eb 44                	jmp    80118c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801148:	89 f2                	mov    %esi,%edx
  80114a:	89 f8                	mov    %edi,%eax
  80114c:	e8 e5 fe ff ff       	call   801036 <_pipeisclosed>
  801151:	85 c0                	test   %eax,%eax
  801153:	75 32                	jne    801187 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801155:	e8 49 f4 ff ff       	call   8005a3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80115a:	8b 06                	mov    (%esi),%eax
  80115c:	3b 46 04             	cmp    0x4(%esi),%eax
  80115f:	74 df                	je     801140 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801161:	99                   	cltd   
  801162:	c1 ea 1b             	shr    $0x1b,%edx
  801165:	01 d0                	add    %edx,%eax
  801167:	83 e0 1f             	and    $0x1f,%eax
  80116a:	29 d0                	sub    %edx,%eax
  80116c:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801174:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801177:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80117a:	83 c3 01             	add    $0x1,%ebx
  80117d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801180:	75 d8                	jne    80115a <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801182:	8b 45 10             	mov    0x10(%ebp),%eax
  801185:	eb 05                	jmp    80118c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801187:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80118c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80119c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119f:	50                   	push   %eax
  8011a0:	e8 35 f6 ff ff       	call   8007da <fd_alloc>
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	89 c2                	mov    %eax,%edx
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	0f 88 2c 01 00 00    	js     8012de <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011b2:	83 ec 04             	sub    $0x4,%esp
  8011b5:	68 07 04 00 00       	push   $0x407
  8011ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8011bd:	6a 00                	push   $0x0
  8011bf:	e8 fe f3 ff ff       	call   8005c2 <sys_page_alloc>
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	0f 88 0d 01 00 00    	js     8012de <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011d1:	83 ec 0c             	sub    $0xc,%esp
  8011d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d7:	50                   	push   %eax
  8011d8:	e8 fd f5 ff ff       	call   8007da <fd_alloc>
  8011dd:	89 c3                	mov    %eax,%ebx
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	0f 88 e2 00 00 00    	js     8012cc <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	68 07 04 00 00       	push   $0x407
  8011f2:	ff 75 f0             	pushl  -0x10(%ebp)
  8011f5:	6a 00                	push   $0x0
  8011f7:	e8 c6 f3 ff ff       	call   8005c2 <sys_page_alloc>
  8011fc:	89 c3                	mov    %eax,%ebx
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	85 c0                	test   %eax,%eax
  801203:	0f 88 c3 00 00 00    	js     8012cc <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	ff 75 f4             	pushl  -0xc(%ebp)
  80120f:	e8 af f5 ff ff       	call   8007c3 <fd2data>
  801214:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801216:	83 c4 0c             	add    $0xc,%esp
  801219:	68 07 04 00 00       	push   $0x407
  80121e:	50                   	push   %eax
  80121f:	6a 00                	push   $0x0
  801221:	e8 9c f3 ff ff       	call   8005c2 <sys_page_alloc>
  801226:	89 c3                	mov    %eax,%ebx
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	0f 88 89 00 00 00    	js     8012bc <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	ff 75 f0             	pushl  -0x10(%ebp)
  801239:	e8 85 f5 ff ff       	call   8007c3 <fd2data>
  80123e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801245:	50                   	push   %eax
  801246:	6a 00                	push   $0x0
  801248:	56                   	push   %esi
  801249:	6a 00                	push   $0x0
  80124b:	e8 b5 f3 ff ff       	call   800605 <sys_page_map>
  801250:	89 c3                	mov    %eax,%ebx
  801252:	83 c4 20             	add    $0x20,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	78 55                	js     8012ae <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801259:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80125f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801262:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801264:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801267:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80126e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801274:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801277:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801279:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801283:	83 ec 0c             	sub    $0xc,%esp
  801286:	ff 75 f4             	pushl  -0xc(%ebp)
  801289:	e8 25 f5 ff ff       	call   8007b3 <fd2num>
  80128e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801291:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801293:	83 c4 04             	add    $0x4,%esp
  801296:	ff 75 f0             	pushl  -0x10(%ebp)
  801299:	e8 15 f5 ff ff       	call   8007b3 <fd2num>
  80129e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a1:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8012a4:	83 c4 10             	add    $0x10,%esp
  8012a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ac:	eb 30                	jmp    8012de <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012ae:	83 ec 08             	sub    $0x8,%esp
  8012b1:	56                   	push   %esi
  8012b2:	6a 00                	push   $0x0
  8012b4:	e8 8e f3 ff ff       	call   800647 <sys_page_unmap>
  8012b9:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012bc:	83 ec 08             	sub    $0x8,%esp
  8012bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8012c2:	6a 00                	push   $0x0
  8012c4:	e8 7e f3 ff ff       	call   800647 <sys_page_unmap>
  8012c9:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012cc:	83 ec 08             	sub    $0x8,%esp
  8012cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d2:	6a 00                	push   $0x0
  8012d4:	e8 6e f3 ff ff       	call   800647 <sys_page_unmap>
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8012de:	89 d0                	mov    %edx,%eax
  8012e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e3:	5b                   	pop    %ebx
  8012e4:	5e                   	pop    %esi
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	ff 75 08             	pushl  0x8(%ebp)
  8012f4:	e8 30 f5 ff ff       	call   800829 <fd_lookup>
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 18                	js     801318 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801300:	83 ec 0c             	sub    $0xc,%esp
  801303:	ff 75 f4             	pushl  -0xc(%ebp)
  801306:	e8 b8 f4 ff ff       	call   8007c3 <fd2data>
	return _pipeisclosed(fd, p);
  80130b:	89 c2                	mov    %eax,%edx
  80130d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801310:	e8 21 fd ff ff       	call   801036 <_pipeisclosed>
  801315:	83 c4 10             	add    $0x10,%esp
}
  801318:	c9                   	leave  
  801319:	c3                   	ret    

0080131a <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80132a:	68 ba 1f 80 00       	push   $0x801fba
  80132f:	ff 75 0c             	pushl  0xc(%ebp)
  801332:	e8 88 ee ff ff       	call   8001bf <strcpy>
	return 0;
}
  801337:	b8 00 00 00 00       	mov    $0x0,%eax
  80133c:	c9                   	leave  
  80133d:	c3                   	ret    

0080133e <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80133e:	55                   	push   %ebp
  80133f:	89 e5                	mov    %esp,%ebp
  801341:	57                   	push   %edi
  801342:	56                   	push   %esi
  801343:	53                   	push   %ebx
  801344:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80134a:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80134f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801355:	eb 2d                	jmp    801384 <devcons_write+0x46>
		m = n - tot;
  801357:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80135a:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80135c:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80135f:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801364:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801367:	83 ec 04             	sub    $0x4,%esp
  80136a:	53                   	push   %ebx
  80136b:	03 45 0c             	add    0xc(%ebp),%eax
  80136e:	50                   	push   %eax
  80136f:	57                   	push   %edi
  801370:	e8 dc ef ff ff       	call   800351 <memmove>
		sys_cputs(buf, m);
  801375:	83 c4 08             	add    $0x8,%esp
  801378:	53                   	push   %ebx
  801379:	57                   	push   %edi
  80137a:	e8 87 f1 ff ff       	call   800506 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80137f:	01 de                	add    %ebx,%esi
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	89 f0                	mov    %esi,%eax
  801386:	3b 75 10             	cmp    0x10(%ebp),%esi
  801389:	72 cc                	jb     801357 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80138b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80138e:	5b                   	pop    %ebx
  80138f:	5e                   	pop    %esi
  801390:	5f                   	pop    %edi
  801391:	5d                   	pop    %ebp
  801392:	c3                   	ret    

00801393 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801393:	55                   	push   %ebp
  801394:	89 e5                	mov    %esp,%ebp
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80139e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013a2:	74 2a                	je     8013ce <devcons_read+0x3b>
  8013a4:	eb 05                	jmp    8013ab <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013a6:	e8 f8 f1 ff ff       	call   8005a3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013ab:	e8 74 f1 ff ff       	call   800524 <sys_cgetc>
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	74 f2                	je     8013a6 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 16                	js     8013ce <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013b8:	83 f8 04             	cmp    $0x4,%eax
  8013bb:	74 0c                	je     8013c9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c0:	88 02                	mov    %al,(%edx)
	return 1;
  8013c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8013c7:	eb 05                	jmp    8013ce <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013c9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013dc:	6a 01                	push   $0x1
  8013de:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	e8 1f f1 ff ff       	call   800506 <sys_cputs>
}
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <getchar>:

int
getchar(void)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8013f2:	6a 01                	push   $0x1
  8013f4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013f7:	50                   	push   %eax
  8013f8:	6a 00                	push   $0x0
  8013fa:	e8 90 f6 ff ff       	call   800a8f <read>
	if (r < 0)
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	85 c0                	test   %eax,%eax
  801404:	78 0f                	js     801415 <getchar+0x29>
		return r;
	if (r < 1)
  801406:	85 c0                	test   %eax,%eax
  801408:	7e 06                	jle    801410 <getchar+0x24>
		return -E_EOF;
	return c;
  80140a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80140e:	eb 05                	jmp    801415 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801410:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80141d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801420:	50                   	push   %eax
  801421:	ff 75 08             	pushl  0x8(%ebp)
  801424:	e8 00 f4 ff ff       	call   800829 <fd_lookup>
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 11                	js     801441 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801430:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801433:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801439:	39 10                	cmp    %edx,(%eax)
  80143b:	0f 94 c0             	sete   %al
  80143e:	0f b6 c0             	movzbl %al,%eax
}
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <opencons>:

int
opencons(void)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801449:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144c:	50                   	push   %eax
  80144d:	e8 88 f3 ff ff       	call   8007da <fd_alloc>
  801452:	83 c4 10             	add    $0x10,%esp
		return r;
  801455:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801457:	85 c0                	test   %eax,%eax
  801459:	78 3e                	js     801499 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80145b:	83 ec 04             	sub    $0x4,%esp
  80145e:	68 07 04 00 00       	push   $0x407
  801463:	ff 75 f4             	pushl  -0xc(%ebp)
  801466:	6a 00                	push   $0x0
  801468:	e8 55 f1 ff ff       	call   8005c2 <sys_page_alloc>
  80146d:	83 c4 10             	add    $0x10,%esp
		return r;
  801470:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801472:	85 c0                	test   %eax,%eax
  801474:	78 23                	js     801499 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801476:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801481:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801484:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80148b:	83 ec 0c             	sub    $0xc,%esp
  80148e:	50                   	push   %eax
  80148f:	e8 1f f3 ff ff       	call   8007b3 <fd2num>
  801494:	89 c2                	mov    %eax,%edx
  801496:	83 c4 10             	add    $0x10,%esp
}
  801499:	89 d0                	mov    %edx,%eax
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	56                   	push   %esi
  8014a1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014a2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014a5:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014ab:	e8 d4 f0 ff ff       	call   800584 <sys_getenvid>
  8014b0:	83 ec 0c             	sub    $0xc,%esp
  8014b3:	ff 75 0c             	pushl  0xc(%ebp)
  8014b6:	ff 75 08             	pushl  0x8(%ebp)
  8014b9:	56                   	push   %esi
  8014ba:	50                   	push   %eax
  8014bb:	68 c8 1f 80 00       	push   $0x801fc8
  8014c0:	e8 b1 00 00 00       	call   801576 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014c5:	83 c4 18             	add    $0x18,%esp
  8014c8:	53                   	push   %ebx
  8014c9:	ff 75 10             	pushl  0x10(%ebp)
  8014cc:	e8 54 00 00 00       	call   801525 <vcprintf>
	cprintf("\n");
  8014d1:	c7 04 24 b3 1f 80 00 	movl   $0x801fb3,(%esp)
  8014d8:	e8 99 00 00 00       	call   801576 <cprintf>
  8014dd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014e0:	cc                   	int3   
  8014e1:	eb fd                	jmp    8014e0 <_panic+0x43>

008014e3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 04             	sub    $0x4,%esp
  8014ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014ed:	8b 13                	mov    (%ebx),%edx
  8014ef:	8d 42 01             	lea    0x1(%edx),%eax
  8014f2:	89 03                	mov    %eax,(%ebx)
  8014f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8014fb:	3d ff 00 00 00       	cmp    $0xff,%eax
  801500:	75 1a                	jne    80151c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801502:	83 ec 08             	sub    $0x8,%esp
  801505:	68 ff 00 00 00       	push   $0xff
  80150a:	8d 43 08             	lea    0x8(%ebx),%eax
  80150d:	50                   	push   %eax
  80150e:	e8 f3 ef ff ff       	call   800506 <sys_cputs>
		b->idx = 0;
  801513:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801519:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80151c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801520:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801523:	c9                   	leave  
  801524:	c3                   	ret    

00801525 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80152e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801535:	00 00 00 
	b.cnt = 0;
  801538:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80153f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801542:	ff 75 0c             	pushl  0xc(%ebp)
  801545:	ff 75 08             	pushl  0x8(%ebp)
  801548:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	68 e3 14 80 00       	push   $0x8014e3
  801554:	e8 54 01 00 00       	call   8016ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801559:	83 c4 08             	add    $0x8,%esp
  80155c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801562:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801568:	50                   	push   %eax
  801569:	e8 98 ef ff ff       	call   800506 <sys_cputs>

	return b.cnt;
}
  80156e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80157c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80157f:	50                   	push   %eax
  801580:	ff 75 08             	pushl  0x8(%ebp)
  801583:	e8 9d ff ff ff       	call   801525 <vcprintf>
	va_end(ap);

	return cnt;
}
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	57                   	push   %edi
  80158e:	56                   	push   %esi
  80158f:	53                   	push   %ebx
  801590:	83 ec 1c             	sub    $0x1c,%esp
  801593:	89 c7                	mov    %eax,%edi
  801595:	89 d6                	mov    %edx,%esi
  801597:	8b 45 08             	mov    0x8(%ebp),%eax
  80159a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015ae:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015b1:	39 d3                	cmp    %edx,%ebx
  8015b3:	72 05                	jb     8015ba <printnum+0x30>
  8015b5:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015b8:	77 45                	ja     8015ff <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015ba:	83 ec 0c             	sub    $0xc,%esp
  8015bd:	ff 75 18             	pushl  0x18(%ebp)
  8015c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015c6:	53                   	push   %ebx
  8015c7:	ff 75 10             	pushl  0x10(%ebp)
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8015d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8015d9:	e8 32 06 00 00       	call   801c10 <__udivdi3>
  8015de:	83 c4 18             	add    $0x18,%esp
  8015e1:	52                   	push   %edx
  8015e2:	50                   	push   %eax
  8015e3:	89 f2                	mov    %esi,%edx
  8015e5:	89 f8                	mov    %edi,%eax
  8015e7:	e8 9e ff ff ff       	call   80158a <printnum>
  8015ec:	83 c4 20             	add    $0x20,%esp
  8015ef:	eb 18                	jmp    801609 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	56                   	push   %esi
  8015f5:	ff 75 18             	pushl  0x18(%ebp)
  8015f8:	ff d7                	call   *%edi
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	eb 03                	jmp    801602 <printnum+0x78>
  8015ff:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801602:	83 eb 01             	sub    $0x1,%ebx
  801605:	85 db                	test   %ebx,%ebx
  801607:	7f e8                	jg     8015f1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	56                   	push   %esi
  80160d:	83 ec 04             	sub    $0x4,%esp
  801610:	ff 75 e4             	pushl  -0x1c(%ebp)
  801613:	ff 75 e0             	pushl  -0x20(%ebp)
  801616:	ff 75 dc             	pushl  -0x24(%ebp)
  801619:	ff 75 d8             	pushl  -0x28(%ebp)
  80161c:	e8 1f 07 00 00       	call   801d40 <__umoddi3>
  801621:	83 c4 14             	add    $0x14,%esp
  801624:	0f be 80 eb 1f 80 00 	movsbl 0x801feb(%eax),%eax
  80162b:	50                   	push   %eax
  80162c:	ff d7                	call   *%edi
}
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801634:	5b                   	pop    %ebx
  801635:	5e                   	pop    %esi
  801636:	5f                   	pop    %edi
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    

00801639 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80163c:	83 fa 01             	cmp    $0x1,%edx
  80163f:	7e 0e                	jle    80164f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801641:	8b 10                	mov    (%eax),%edx
  801643:	8d 4a 08             	lea    0x8(%edx),%ecx
  801646:	89 08                	mov    %ecx,(%eax)
  801648:	8b 02                	mov    (%edx),%eax
  80164a:	8b 52 04             	mov    0x4(%edx),%edx
  80164d:	eb 22                	jmp    801671 <getuint+0x38>
	else if (lflag)
  80164f:	85 d2                	test   %edx,%edx
  801651:	74 10                	je     801663 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801653:	8b 10                	mov    (%eax),%edx
  801655:	8d 4a 04             	lea    0x4(%edx),%ecx
  801658:	89 08                	mov    %ecx,(%eax)
  80165a:	8b 02                	mov    (%edx),%eax
  80165c:	ba 00 00 00 00       	mov    $0x0,%edx
  801661:	eb 0e                	jmp    801671 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801663:	8b 10                	mov    (%eax),%edx
  801665:	8d 4a 04             	lea    0x4(%edx),%ecx
  801668:	89 08                	mov    %ecx,(%eax)
  80166a:	8b 02                	mov    (%edx),%eax
  80166c:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801679:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80167d:	8b 10                	mov    (%eax),%edx
  80167f:	3b 50 04             	cmp    0x4(%eax),%edx
  801682:	73 0a                	jae    80168e <sprintputch+0x1b>
		*b->buf++ = ch;
  801684:	8d 4a 01             	lea    0x1(%edx),%ecx
  801687:	89 08                	mov    %ecx,(%eax)
  801689:	8b 45 08             	mov    0x8(%ebp),%eax
  80168c:	88 02                	mov    %al,(%edx)
}
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801696:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801699:	50                   	push   %eax
  80169a:	ff 75 10             	pushl  0x10(%ebp)
  80169d:	ff 75 0c             	pushl  0xc(%ebp)
  8016a0:	ff 75 08             	pushl  0x8(%ebp)
  8016a3:	e8 05 00 00 00       	call   8016ad <vprintfmt>
	va_end(ap);
}
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	57                   	push   %edi
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 2c             	sub    $0x2c,%esp
  8016b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8016b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016bf:	eb 12                	jmp    8016d3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	0f 84 89 03 00 00    	je     801a52 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	53                   	push   %ebx
  8016cd:	50                   	push   %eax
  8016ce:	ff d6                	call   *%esi
  8016d0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016d3:	83 c7 01             	add    $0x1,%edi
  8016d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016da:	83 f8 25             	cmp    $0x25,%eax
  8016dd:	75 e2                	jne    8016c1 <vprintfmt+0x14>
  8016df:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8016f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fd:	eb 07                	jmp    801706 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801702:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801706:	8d 47 01             	lea    0x1(%edi),%eax
  801709:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80170c:	0f b6 07             	movzbl (%edi),%eax
  80170f:	0f b6 c8             	movzbl %al,%ecx
  801712:	83 e8 23             	sub    $0x23,%eax
  801715:	3c 55                	cmp    $0x55,%al
  801717:	0f 87 1a 03 00 00    	ja     801a37 <vprintfmt+0x38a>
  80171d:	0f b6 c0             	movzbl %al,%eax
  801720:	ff 24 85 20 21 80 00 	jmp    *0x802120(,%eax,4)
  801727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80172a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80172e:	eb d6                	jmp    801706 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801730:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801733:	b8 00 00 00 00       	mov    $0x0,%eax
  801738:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80173b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80173e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801742:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801745:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801748:	83 fa 09             	cmp    $0x9,%edx
  80174b:	77 39                	ja     801786 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80174d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801750:	eb e9                	jmp    80173b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801752:	8b 45 14             	mov    0x14(%ebp),%eax
  801755:	8d 48 04             	lea    0x4(%eax),%ecx
  801758:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80175b:	8b 00                	mov    (%eax),%eax
  80175d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801760:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801763:	eb 27                	jmp    80178c <vprintfmt+0xdf>
  801765:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801768:	85 c0                	test   %eax,%eax
  80176a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80176f:	0f 49 c8             	cmovns %eax,%ecx
  801772:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801778:	eb 8c                	jmp    801706 <vprintfmt+0x59>
  80177a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80177d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801784:	eb 80                	jmp    801706 <vprintfmt+0x59>
  801786:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801789:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80178c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801790:	0f 89 70 ff ff ff    	jns    801706 <vprintfmt+0x59>
				width = precision, precision = -1;
  801796:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801799:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80179c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017a3:	e9 5e ff ff ff       	jmp    801706 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017a8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017ae:	e9 53 ff ff ff       	jmp    801706 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b6:	8d 50 04             	lea    0x4(%eax),%edx
  8017b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8017bc:	83 ec 08             	sub    $0x8,%esp
  8017bf:	53                   	push   %ebx
  8017c0:	ff 30                	pushl  (%eax)
  8017c2:	ff d6                	call   *%esi
			break;
  8017c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017ca:	e9 04 ff ff ff       	jmp    8016d3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d2:	8d 50 04             	lea    0x4(%eax),%edx
  8017d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8017d8:	8b 00                	mov    (%eax),%eax
  8017da:	99                   	cltd   
  8017db:	31 d0                	xor    %edx,%eax
  8017dd:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017df:	83 f8 0f             	cmp    $0xf,%eax
  8017e2:	7f 0b                	jg     8017ef <vprintfmt+0x142>
  8017e4:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  8017eb:	85 d2                	test   %edx,%edx
  8017ed:	75 18                	jne    801807 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8017ef:	50                   	push   %eax
  8017f0:	68 03 20 80 00       	push   $0x802003
  8017f5:	53                   	push   %ebx
  8017f6:	56                   	push   %esi
  8017f7:	e8 94 fe ff ff       	call   801690 <printfmt>
  8017fc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801802:	e9 cc fe ff ff       	jmp    8016d3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801807:	52                   	push   %edx
  801808:	68 81 1f 80 00       	push   $0x801f81
  80180d:	53                   	push   %ebx
  80180e:	56                   	push   %esi
  80180f:	e8 7c fe ff ff       	call   801690 <printfmt>
  801814:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801817:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80181a:	e9 b4 fe ff ff       	jmp    8016d3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80181f:	8b 45 14             	mov    0x14(%ebp),%eax
  801822:	8d 50 04             	lea    0x4(%eax),%edx
  801825:	89 55 14             	mov    %edx,0x14(%ebp)
  801828:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80182a:	85 ff                	test   %edi,%edi
  80182c:	b8 fc 1f 80 00       	mov    $0x801ffc,%eax
  801831:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801834:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801838:	0f 8e 94 00 00 00    	jle    8018d2 <vprintfmt+0x225>
  80183e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801842:	0f 84 98 00 00 00    	je     8018e0 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	ff 75 d0             	pushl  -0x30(%ebp)
  80184e:	57                   	push   %edi
  80184f:	e8 4a e9 ff ff       	call   80019e <strnlen>
  801854:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801857:	29 c1                	sub    %eax,%ecx
  801859:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80185c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80185f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801863:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801866:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801869:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80186b:	eb 0f                	jmp    80187c <vprintfmt+0x1cf>
					putch(padc, putdat);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	53                   	push   %ebx
  801871:	ff 75 e0             	pushl  -0x20(%ebp)
  801874:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801876:	83 ef 01             	sub    $0x1,%edi
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	85 ff                	test   %edi,%edi
  80187e:	7f ed                	jg     80186d <vprintfmt+0x1c0>
  801880:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801883:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801886:	85 c9                	test   %ecx,%ecx
  801888:	b8 00 00 00 00       	mov    $0x0,%eax
  80188d:	0f 49 c1             	cmovns %ecx,%eax
  801890:	29 c1                	sub    %eax,%ecx
  801892:	89 75 08             	mov    %esi,0x8(%ebp)
  801895:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801898:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80189b:	89 cb                	mov    %ecx,%ebx
  80189d:	eb 4d                	jmp    8018ec <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80189f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018a3:	74 1b                	je     8018c0 <vprintfmt+0x213>
  8018a5:	0f be c0             	movsbl %al,%eax
  8018a8:	83 e8 20             	sub    $0x20,%eax
  8018ab:	83 f8 5e             	cmp    $0x5e,%eax
  8018ae:	76 10                	jbe    8018c0 <vprintfmt+0x213>
					putch('?', putdat);
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	ff 75 0c             	pushl  0xc(%ebp)
  8018b6:	6a 3f                	push   $0x3f
  8018b8:	ff 55 08             	call   *0x8(%ebp)
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	eb 0d                	jmp    8018cd <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	52                   	push   %edx
  8018c7:	ff 55 08             	call   *0x8(%ebp)
  8018ca:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018cd:	83 eb 01             	sub    $0x1,%ebx
  8018d0:	eb 1a                	jmp    8018ec <vprintfmt+0x23f>
  8018d2:	89 75 08             	mov    %esi,0x8(%ebp)
  8018d5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018db:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018de:	eb 0c                	jmp    8018ec <vprintfmt+0x23f>
  8018e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018ec:	83 c7 01             	add    $0x1,%edi
  8018ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018f3:	0f be d0             	movsbl %al,%edx
  8018f6:	85 d2                	test   %edx,%edx
  8018f8:	74 23                	je     80191d <vprintfmt+0x270>
  8018fa:	85 f6                	test   %esi,%esi
  8018fc:	78 a1                	js     80189f <vprintfmt+0x1f2>
  8018fe:	83 ee 01             	sub    $0x1,%esi
  801901:	79 9c                	jns    80189f <vprintfmt+0x1f2>
  801903:	89 df                	mov    %ebx,%edi
  801905:	8b 75 08             	mov    0x8(%ebp),%esi
  801908:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80190b:	eb 18                	jmp    801925 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	53                   	push   %ebx
  801911:	6a 20                	push   $0x20
  801913:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801915:	83 ef 01             	sub    $0x1,%edi
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	eb 08                	jmp    801925 <vprintfmt+0x278>
  80191d:	89 df                	mov    %ebx,%edi
  80191f:	8b 75 08             	mov    0x8(%ebp),%esi
  801922:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801925:	85 ff                	test   %edi,%edi
  801927:	7f e4                	jg     80190d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80192c:	e9 a2 fd ff ff       	jmp    8016d3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801931:	83 fa 01             	cmp    $0x1,%edx
  801934:	7e 16                	jle    80194c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801936:	8b 45 14             	mov    0x14(%ebp),%eax
  801939:	8d 50 08             	lea    0x8(%eax),%edx
  80193c:	89 55 14             	mov    %edx,0x14(%ebp)
  80193f:	8b 50 04             	mov    0x4(%eax),%edx
  801942:	8b 00                	mov    (%eax),%eax
  801944:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801947:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80194a:	eb 32                	jmp    80197e <vprintfmt+0x2d1>
	else if (lflag)
  80194c:	85 d2                	test   %edx,%edx
  80194e:	74 18                	je     801968 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801950:	8b 45 14             	mov    0x14(%ebp),%eax
  801953:	8d 50 04             	lea    0x4(%eax),%edx
  801956:	89 55 14             	mov    %edx,0x14(%ebp)
  801959:	8b 00                	mov    (%eax),%eax
  80195b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80195e:	89 c1                	mov    %eax,%ecx
  801960:	c1 f9 1f             	sar    $0x1f,%ecx
  801963:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801966:	eb 16                	jmp    80197e <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801968:	8b 45 14             	mov    0x14(%ebp),%eax
  80196b:	8d 50 04             	lea    0x4(%eax),%edx
  80196e:	89 55 14             	mov    %edx,0x14(%ebp)
  801971:	8b 00                	mov    (%eax),%eax
  801973:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801976:	89 c1                	mov    %eax,%ecx
  801978:	c1 f9 1f             	sar    $0x1f,%ecx
  80197b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80197e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801981:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801984:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801989:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80198d:	79 74                	jns    801a03 <vprintfmt+0x356>
				putch('-', putdat);
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	53                   	push   %ebx
  801993:	6a 2d                	push   $0x2d
  801995:	ff d6                	call   *%esi
				num = -(long long) num;
  801997:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80199a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80199d:	f7 d8                	neg    %eax
  80199f:	83 d2 00             	adc    $0x0,%edx
  8019a2:	f7 da                	neg    %edx
  8019a4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019a7:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8019ac:	eb 55                	jmp    801a03 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8019ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8019b1:	e8 83 fc ff ff       	call   801639 <getuint>
			base = 10;
  8019b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8019bb:	eb 46                	jmp    801a03 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8019bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8019c0:	e8 74 fc ff ff       	call   801639 <getuint>
			base = 8;
  8019c5:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019ca:	eb 37                	jmp    801a03 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8019cc:	83 ec 08             	sub    $0x8,%esp
  8019cf:	53                   	push   %ebx
  8019d0:	6a 30                	push   $0x30
  8019d2:	ff d6                	call   *%esi
			putch('x', putdat);
  8019d4:	83 c4 08             	add    $0x8,%esp
  8019d7:	53                   	push   %ebx
  8019d8:	6a 78                	push   $0x78
  8019da:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019df:	8d 50 04             	lea    0x4(%eax),%edx
  8019e2:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019e5:	8b 00                	mov    (%eax),%eax
  8019e7:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019ec:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019ef:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8019f4:	eb 0d                	jmp    801a03 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8019f9:	e8 3b fc ff ff       	call   801639 <getuint>
			base = 16;
  8019fe:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801a0a:	57                   	push   %edi
  801a0b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a0e:	51                   	push   %ecx
  801a0f:	52                   	push   %edx
  801a10:	50                   	push   %eax
  801a11:	89 da                	mov    %ebx,%edx
  801a13:	89 f0                	mov    %esi,%eax
  801a15:	e8 70 fb ff ff       	call   80158a <printnum>
			break;
  801a1a:	83 c4 20             	add    $0x20,%esp
  801a1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a20:	e9 ae fc ff ff       	jmp    8016d3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a25:	83 ec 08             	sub    $0x8,%esp
  801a28:	53                   	push   %ebx
  801a29:	51                   	push   %ecx
  801a2a:	ff d6                	call   *%esi
			break;
  801a2c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a32:	e9 9c fc ff ff       	jmp    8016d3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a37:	83 ec 08             	sub    $0x8,%esp
  801a3a:	53                   	push   %ebx
  801a3b:	6a 25                	push   $0x25
  801a3d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	eb 03                	jmp    801a47 <vprintfmt+0x39a>
  801a44:	83 ef 01             	sub    $0x1,%edi
  801a47:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a4b:	75 f7                	jne    801a44 <vprintfmt+0x397>
  801a4d:	e9 81 fc ff ff       	jmp    8016d3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a55:	5b                   	pop    %ebx
  801a56:	5e                   	pop    %esi
  801a57:	5f                   	pop    %edi
  801a58:	5d                   	pop    %ebp
  801a59:	c3                   	ret    

00801a5a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a5a:	55                   	push   %ebp
  801a5b:	89 e5                	mov    %esp,%ebp
  801a5d:	83 ec 18             	sub    $0x18,%esp
  801a60:	8b 45 08             	mov    0x8(%ebp),%eax
  801a63:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a66:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a69:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a6d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a77:	85 c0                	test   %eax,%eax
  801a79:	74 26                	je     801aa1 <vsnprintf+0x47>
  801a7b:	85 d2                	test   %edx,%edx
  801a7d:	7e 22                	jle    801aa1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a7f:	ff 75 14             	pushl  0x14(%ebp)
  801a82:	ff 75 10             	pushl  0x10(%ebp)
  801a85:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a88:	50                   	push   %eax
  801a89:	68 73 16 80 00       	push   $0x801673
  801a8e:	e8 1a fc ff ff       	call   8016ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a93:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a96:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	eb 05                	jmp    801aa6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801aa1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801aae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ab1:	50                   	push   %eax
  801ab2:	ff 75 10             	pushl  0x10(%ebp)
  801ab5:	ff 75 0c             	pushl  0xc(%ebp)
  801ab8:	ff 75 08             	pushl  0x8(%ebp)
  801abb:	e8 9a ff ff ff       	call   801a5a <vsnprintf>
	va_end(ap);

	return rc;
}
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	56                   	push   %esi
  801ac6:	53                   	push   %ebx
  801ac7:	8b 75 08             	mov    0x8(%ebp),%esi
  801aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	75 12                	jne    801ae6 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	68 00 00 c0 ee       	push   $0xeec00000
  801adc:	e8 91 ec ff ff       	call   800772 <sys_ipc_recv>
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	eb 0c                	jmp    801af2 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801ae6:	83 ec 0c             	sub    $0xc,%esp
  801ae9:	50                   	push   %eax
  801aea:	e8 83 ec ff ff       	call   800772 <sys_ipc_recv>
  801aef:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801af2:	85 f6                	test   %esi,%esi
  801af4:	0f 95 c1             	setne  %cl
  801af7:	85 db                	test   %ebx,%ebx
  801af9:	0f 95 c2             	setne  %dl
  801afc:	84 d1                	test   %dl,%cl
  801afe:	74 09                	je     801b09 <ipc_recv+0x47>
  801b00:	89 c2                	mov    %eax,%edx
  801b02:	c1 ea 1f             	shr    $0x1f,%edx
  801b05:	84 d2                	test   %dl,%dl
  801b07:	75 24                	jne    801b2d <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801b09:	85 f6                	test   %esi,%esi
  801b0b:	74 0a                	je     801b17 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b0d:	a1 04 40 80 00       	mov    0x804004,%eax
  801b12:	8b 40 74             	mov    0x74(%eax),%eax
  801b15:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b17:	85 db                	test   %ebx,%ebx
  801b19:	74 0a                	je     801b25 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801b1b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b20:	8b 40 78             	mov    0x78(%eax),%eax
  801b23:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b25:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	57                   	push   %edi
  801b38:	56                   	push   %esi
  801b39:	53                   	push   %ebx
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b40:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b46:	85 db                	test   %ebx,%ebx
  801b48:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b4d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b50:	ff 75 14             	pushl  0x14(%ebp)
  801b53:	53                   	push   %ebx
  801b54:	56                   	push   %esi
  801b55:	57                   	push   %edi
  801b56:	e8 f4 eb ff ff       	call   80074f <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b5b:	89 c2                	mov    %eax,%edx
  801b5d:	c1 ea 1f             	shr    $0x1f,%edx
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	84 d2                	test   %dl,%dl
  801b65:	74 17                	je     801b7e <ipc_send+0x4a>
  801b67:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b6a:	74 12                	je     801b7e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b6c:	50                   	push   %eax
  801b6d:	68 e0 22 80 00       	push   $0x8022e0
  801b72:	6a 47                	push   $0x47
  801b74:	68 ee 22 80 00       	push   $0x8022ee
  801b79:	e8 1f f9 ff ff       	call   80149d <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b7e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b81:	75 07                	jne    801b8a <ipc_send+0x56>
			sys_yield();
  801b83:	e8 1b ea ff ff       	call   8005a3 <sys_yield>
  801b88:	eb c6                	jmp    801b50 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	75 c2                	jne    801b50 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b9c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ba1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ba4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801baa:	8b 52 50             	mov    0x50(%edx),%edx
  801bad:	39 ca                	cmp    %ecx,%edx
  801baf:	75 0d                	jne    801bbe <ipc_find_env+0x28>
			return envs[i].env_id;
  801bb1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bb4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bb9:	8b 40 48             	mov    0x48(%eax),%eax
  801bbc:	eb 0f                	jmp    801bcd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bbe:	83 c0 01             	add    $0x1,%eax
  801bc1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bc6:	75 d9                	jne    801ba1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd5:	89 d0                	mov    %edx,%eax
  801bd7:	c1 e8 16             	shr    $0x16,%eax
  801bda:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801be6:	f6 c1 01             	test   $0x1,%cl
  801be9:	74 1d                	je     801c08 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801beb:	c1 ea 0c             	shr    $0xc,%edx
  801bee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf5:	f6 c2 01             	test   $0x1,%dl
  801bf8:	74 0e                	je     801c08 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bfa:	c1 ea 0c             	shr    $0xc,%edx
  801bfd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c04:	ef 
  801c05:	0f b7 c0             	movzwl %ax,%eax
}
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    
  801c0a:	66 90                	xchg   %ax,%ax
  801c0c:	66 90                	xchg   %ax,%ax
  801c0e:	66 90                	xchg   %ax,%ax

00801c10 <__udivdi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 1c             	sub    $0x1c,%esp
  801c17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c27:	85 f6                	test   %esi,%esi
  801c29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c2d:	89 ca                	mov    %ecx,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	75 3d                	jne    801c70 <__udivdi3+0x60>
  801c33:	39 cf                	cmp    %ecx,%edi
  801c35:	0f 87 c5 00 00 00    	ja     801d00 <__udivdi3+0xf0>
  801c3b:	85 ff                	test   %edi,%edi
  801c3d:	89 fd                	mov    %edi,%ebp
  801c3f:	75 0b                	jne    801c4c <__udivdi3+0x3c>
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	31 d2                	xor    %edx,%edx
  801c48:	f7 f7                	div    %edi
  801c4a:	89 c5                	mov    %eax,%ebp
  801c4c:	89 c8                	mov    %ecx,%eax
  801c4e:	31 d2                	xor    %edx,%edx
  801c50:	f7 f5                	div    %ebp
  801c52:	89 c1                	mov    %eax,%ecx
  801c54:	89 d8                	mov    %ebx,%eax
  801c56:	89 cf                	mov    %ecx,%edi
  801c58:	f7 f5                	div    %ebp
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	89 fa                	mov    %edi,%edx
  801c60:	83 c4 1c             	add    $0x1c,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
  801c68:	90                   	nop
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	39 ce                	cmp    %ecx,%esi
  801c72:	77 74                	ja     801ce8 <__udivdi3+0xd8>
  801c74:	0f bd fe             	bsr    %esi,%edi
  801c77:	83 f7 1f             	xor    $0x1f,%edi
  801c7a:	0f 84 98 00 00 00    	je     801d18 <__udivdi3+0x108>
  801c80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	89 c5                	mov    %eax,%ebp
  801c89:	29 fb                	sub    %edi,%ebx
  801c8b:	d3 e6                	shl    %cl,%esi
  801c8d:	89 d9                	mov    %ebx,%ecx
  801c8f:	d3 ed                	shr    %cl,%ebp
  801c91:	89 f9                	mov    %edi,%ecx
  801c93:	d3 e0                	shl    %cl,%eax
  801c95:	09 ee                	or     %ebp,%esi
  801c97:	89 d9                	mov    %ebx,%ecx
  801c99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c9d:	89 d5                	mov    %edx,%ebp
  801c9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ca3:	d3 ed                	shr    %cl,%ebp
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	d3 e2                	shl    %cl,%edx
  801ca9:	89 d9                	mov    %ebx,%ecx
  801cab:	d3 e8                	shr    %cl,%eax
  801cad:	09 c2                	or     %eax,%edx
  801caf:	89 d0                	mov    %edx,%eax
  801cb1:	89 ea                	mov    %ebp,%edx
  801cb3:	f7 f6                	div    %esi
  801cb5:	89 d5                	mov    %edx,%ebp
  801cb7:	89 c3                	mov    %eax,%ebx
  801cb9:	f7 64 24 0c          	mull   0xc(%esp)
  801cbd:	39 d5                	cmp    %edx,%ebp
  801cbf:	72 10                	jb     801cd1 <__udivdi3+0xc1>
  801cc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e6                	shl    %cl,%esi
  801cc9:	39 c6                	cmp    %eax,%esi
  801ccb:	73 07                	jae    801cd4 <__udivdi3+0xc4>
  801ccd:	39 d5                	cmp    %edx,%ebp
  801ccf:	75 03                	jne    801cd4 <__udivdi3+0xc4>
  801cd1:	83 eb 01             	sub    $0x1,%ebx
  801cd4:	31 ff                	xor    %edi,%edi
  801cd6:	89 d8                	mov    %ebx,%eax
  801cd8:	89 fa                	mov    %edi,%edx
  801cda:	83 c4 1c             	add    $0x1c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce8:	31 ff                	xor    %edi,%edi
  801cea:	31 db                	xor    %ebx,%ebx
  801cec:	89 d8                	mov    %ebx,%eax
  801cee:	89 fa                	mov    %edi,%edx
  801cf0:	83 c4 1c             	add    $0x1c,%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
  801cf8:	90                   	nop
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 d8                	mov    %ebx,%eax
  801d02:	f7 f7                	div    %edi
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 c3                	mov    %eax,%ebx
  801d08:	89 d8                	mov    %ebx,%eax
  801d0a:	89 fa                	mov    %edi,%edx
  801d0c:	83 c4 1c             	add    $0x1c,%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5f                   	pop    %edi
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    
  801d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d18:	39 ce                	cmp    %ecx,%esi
  801d1a:	72 0c                	jb     801d28 <__udivdi3+0x118>
  801d1c:	31 db                	xor    %ebx,%ebx
  801d1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d22:	0f 87 34 ff ff ff    	ja     801c5c <__udivdi3+0x4c>
  801d28:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d2d:	e9 2a ff ff ff       	jmp    801c5c <__udivdi3+0x4c>
  801d32:	66 90                	xchg   %ax,%ax
  801d34:	66 90                	xchg   %ax,%ax
  801d36:	66 90                	xchg   %ax,%ax
  801d38:	66 90                	xchg   %ax,%ax
  801d3a:	66 90                	xchg   %ax,%ax
  801d3c:	66 90                	xchg   %ax,%ax
  801d3e:	66 90                	xchg   %ax,%ax

00801d40 <__umoddi3>:
  801d40:	55                   	push   %ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 1c             	sub    $0x1c,%esp
  801d47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d57:	85 d2                	test   %edx,%edx
  801d59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f3                	mov    %esi,%ebx
  801d63:	89 3c 24             	mov    %edi,(%esp)
  801d66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d6a:	75 1c                	jne    801d88 <__umoddi3+0x48>
  801d6c:	39 f7                	cmp    %esi,%edi
  801d6e:	76 50                	jbe    801dc0 <__umoddi3+0x80>
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	f7 f7                	div    %edi
  801d76:	89 d0                	mov    %edx,%eax
  801d78:	31 d2                	xor    %edx,%edx
  801d7a:	83 c4 1c             	add    $0x1c,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5f                   	pop    %edi
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    
  801d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d88:	39 f2                	cmp    %esi,%edx
  801d8a:	89 d0                	mov    %edx,%eax
  801d8c:	77 52                	ja     801de0 <__umoddi3+0xa0>
  801d8e:	0f bd ea             	bsr    %edx,%ebp
  801d91:	83 f5 1f             	xor    $0x1f,%ebp
  801d94:	75 5a                	jne    801df0 <__umoddi3+0xb0>
  801d96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d9a:	0f 82 e0 00 00 00    	jb     801e80 <__umoddi3+0x140>
  801da0:	39 0c 24             	cmp    %ecx,(%esp)
  801da3:	0f 86 d7 00 00 00    	jbe    801e80 <__umoddi3+0x140>
  801da9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dad:	8b 54 24 04          	mov    0x4(%esp),%edx
  801db1:	83 c4 1c             	add    $0x1c,%esp
  801db4:	5b                   	pop    %ebx
  801db5:	5e                   	pop    %esi
  801db6:	5f                   	pop    %edi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	85 ff                	test   %edi,%edi
  801dc2:	89 fd                	mov    %edi,%ebp
  801dc4:	75 0b                	jne    801dd1 <__umoddi3+0x91>
  801dc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dcb:	31 d2                	xor    %edx,%edx
  801dcd:	f7 f7                	div    %edi
  801dcf:	89 c5                	mov    %eax,%ebp
  801dd1:	89 f0                	mov    %esi,%eax
  801dd3:	31 d2                	xor    %edx,%edx
  801dd5:	f7 f5                	div    %ebp
  801dd7:	89 c8                	mov    %ecx,%eax
  801dd9:	f7 f5                	div    %ebp
  801ddb:	89 d0                	mov    %edx,%eax
  801ddd:	eb 99                	jmp    801d78 <__umoddi3+0x38>
  801ddf:	90                   	nop
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	83 c4 1c             	add    $0x1c,%esp
  801de7:	5b                   	pop    %ebx
  801de8:	5e                   	pop    %esi
  801de9:	5f                   	pop    %edi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    
  801dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801df0:	8b 34 24             	mov    (%esp),%esi
  801df3:	bf 20 00 00 00       	mov    $0x20,%edi
  801df8:	89 e9                	mov    %ebp,%ecx
  801dfa:	29 ef                	sub    %ebp,%edi
  801dfc:	d3 e0                	shl    %cl,%eax
  801dfe:	89 f9                	mov    %edi,%ecx
  801e00:	89 f2                	mov    %esi,%edx
  801e02:	d3 ea                	shr    %cl,%edx
  801e04:	89 e9                	mov    %ebp,%ecx
  801e06:	09 c2                	or     %eax,%edx
  801e08:	89 d8                	mov    %ebx,%eax
  801e0a:	89 14 24             	mov    %edx,(%esp)
  801e0d:	89 f2                	mov    %esi,%edx
  801e0f:	d3 e2                	shl    %cl,%edx
  801e11:	89 f9                	mov    %edi,%ecx
  801e13:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e1b:	d3 e8                	shr    %cl,%eax
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	89 c6                	mov    %eax,%esi
  801e21:	d3 e3                	shl    %cl,%ebx
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 d0                	mov    %edx,%eax
  801e27:	d3 e8                	shr    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	09 d8                	or     %ebx,%eax
  801e2d:	89 d3                	mov    %edx,%ebx
  801e2f:	89 f2                	mov    %esi,%edx
  801e31:	f7 34 24             	divl   (%esp)
  801e34:	89 d6                	mov    %edx,%esi
  801e36:	d3 e3                	shl    %cl,%ebx
  801e38:	f7 64 24 04          	mull   0x4(%esp)
  801e3c:	39 d6                	cmp    %edx,%esi
  801e3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e42:	89 d1                	mov    %edx,%ecx
  801e44:	89 c3                	mov    %eax,%ebx
  801e46:	72 08                	jb     801e50 <__umoddi3+0x110>
  801e48:	75 11                	jne    801e5b <__umoddi3+0x11b>
  801e4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e4e:	73 0b                	jae    801e5b <__umoddi3+0x11b>
  801e50:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e54:	1b 14 24             	sbb    (%esp),%edx
  801e57:	89 d1                	mov    %edx,%ecx
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e5f:	29 da                	sub    %ebx,%edx
  801e61:	19 ce                	sbb    %ecx,%esi
  801e63:	89 f9                	mov    %edi,%ecx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	d3 e0                	shl    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	d3 ea                	shr    %cl,%edx
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	d3 ee                	shr    %cl,%esi
  801e71:	09 d0                	or     %edx,%eax
  801e73:	89 f2                	mov    %esi,%edx
  801e75:	83 c4 1c             	add    $0x1c,%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5f                   	pop    %edi
  801e7b:	5d                   	pop    %ebp
  801e7c:	c3                   	ret    
  801e7d:	8d 76 00             	lea    0x0(%esi),%esi
  801e80:	29 f9                	sub    %edi,%ecx
  801e82:	19 d6                	sbb    %edx,%esi
  801e84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e8c:	e9 18 ff ff ff       	jmp    801da9 <__umoddi3+0x69>
