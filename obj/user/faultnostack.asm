
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 a9 03 80 00       	push   $0x8003a9
  80003e:	6a 00                	push   $0x0
  800040:	e8 be 02 00 00       	call   800303 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	57                   	push   %edi
  800058:	56                   	push   %esi
  800059:	53                   	push   %ebx
  80005a:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80005d:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800064:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800067:	e8 0e 01 00 00       	call   80017a <sys_getenvid>
  80006c:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800072:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800077:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80007c:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800081:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800084:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80008a:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  80008d:	39 c8                	cmp    %ecx,%eax
  80008f:	0f 44 fb             	cmove  %ebx,%edi
  800092:	b9 01 00 00 00       	mov    $0x1,%ecx
  800097:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  80009a:	83 c2 01             	add    $0x1,%edx
  80009d:	83 c3 7c             	add    $0x7c,%ebx
  8000a0:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000a6:	75 d9                	jne    800081 <libmain+0x2d>
  8000a8:	89 f0                	mov    %esi,%eax
  8000aa:	84 c0                	test   %al,%al
  8000ac:	74 06                	je     8000b4 <libmain+0x60>
  8000ae:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000b8:	7e 0a                	jle    8000c4 <libmain+0x70>
		binaryname = argv[0];
  8000ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000bd:	8b 00                	mov    (%eax),%eax
  8000bf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c4:	83 ec 08             	sub    $0x8,%esp
  8000c7:	ff 75 0c             	pushl  0xc(%ebp)
  8000ca:	ff 75 08             	pushl  0x8(%ebp)
  8000cd:	e8 61 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d2:	e8 0b 00 00 00       	call   8000e2 <exit>
}
  8000d7:	83 c4 10             	add    $0x10,%esp
  8000da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000e8:	e8 ab 04 00 00       	call   800598 <close_all>
	sys_env_destroy(0);
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	6a 00                	push   $0x0
  8000f2:	e8 42 00 00 00       	call   800139 <sys_env_destroy>
}
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800102:	b8 00 00 00 00       	mov    $0x0,%eax
  800107:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80010a:	8b 55 08             	mov    0x8(%ebp),%edx
  80010d:	89 c3                	mov    %eax,%ebx
  80010f:	89 c7                	mov    %eax,%edi
  800111:	89 c6                	mov    %eax,%esi
  800113:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5f                   	pop    %edi
  800118:	5d                   	pop    %ebp
  800119:	c3                   	ret    

0080011a <sys_cgetc>:

int
sys_cgetc(void)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	57                   	push   %edi
  80011e:	56                   	push   %esi
  80011f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800120:	ba 00 00 00 00       	mov    $0x0,%edx
  800125:	b8 01 00 00 00       	mov    $0x1,%eax
  80012a:	89 d1                	mov    %edx,%ecx
  80012c:	89 d3                	mov    %edx,%ebx
  80012e:	89 d7                	mov    %edx,%edi
  800130:	89 d6                	mov    %edx,%esi
  800132:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800134:	5b                   	pop    %ebx
  800135:	5e                   	pop    %esi
  800136:	5f                   	pop    %edi
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    

00800139 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	57                   	push   %edi
  80013d:	56                   	push   %esi
  80013e:	53                   	push   %ebx
  80013f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800142:	b9 00 00 00 00       	mov    $0x0,%ecx
  800147:	b8 03 00 00 00       	mov    $0x3,%eax
  80014c:	8b 55 08             	mov    0x8(%ebp),%edx
  80014f:	89 cb                	mov    %ecx,%ebx
  800151:	89 cf                	mov    %ecx,%edi
  800153:	89 ce                	mov    %ecx,%esi
  800155:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800157:	85 c0                	test   %eax,%eax
  800159:	7e 17                	jle    800172 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	50                   	push   %eax
  80015f:	6a 03                	push   $0x3
  800161:	68 aa 1e 80 00       	push   $0x801eaa
  800166:	6a 23                	push   $0x23
  800168:	68 c7 1e 80 00       	push   $0x801ec7
  80016d:	e8 45 0f 00 00       	call   8010b7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800172:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 02 00 00 00       	mov    $0x2,%eax
  80018a:	89 d1                	mov    %edx,%ecx
  80018c:	89 d3                	mov    %edx,%ebx
  80018e:	89 d7                	mov    %edx,%edi
  800190:	89 d6                	mov    %edx,%esi
  800192:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_yield>:

void
sys_yield(void)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019f:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001a9:	89 d1                	mov    %edx,%ecx
  8001ab:	89 d3                	mov    %edx,%ebx
  8001ad:	89 d7                	mov    %edx,%edi
  8001af:	89 d6                	mov    %edx,%esi
  8001b1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	57                   	push   %edi
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c1:	be 00 00 00 00       	mov    $0x0,%esi
  8001c6:	b8 04 00 00 00       	mov    $0x4,%eax
  8001cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d4:	89 f7                	mov    %esi,%edi
  8001d6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d8:	85 c0                	test   %eax,%eax
  8001da:	7e 17                	jle    8001f3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001dc:	83 ec 0c             	sub    $0xc,%esp
  8001df:	50                   	push   %eax
  8001e0:	6a 04                	push   $0x4
  8001e2:	68 aa 1e 80 00       	push   $0x801eaa
  8001e7:	6a 23                	push   $0x23
  8001e9:	68 c7 1e 80 00       	push   $0x801ec7
  8001ee:	e8 c4 0e 00 00       	call   8010b7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f6:	5b                   	pop    %ebx
  8001f7:	5e                   	pop    %esi
  8001f8:	5f                   	pop    %edi
  8001f9:	5d                   	pop    %ebp
  8001fa:	c3                   	ret    

008001fb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	57                   	push   %edi
  8001ff:	56                   	push   %esi
  800200:	53                   	push   %ebx
  800201:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800204:	b8 05 00 00 00       	mov    $0x5,%eax
  800209:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020c:	8b 55 08             	mov    0x8(%ebp),%edx
  80020f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800212:	8b 7d 14             	mov    0x14(%ebp),%edi
  800215:	8b 75 18             	mov    0x18(%ebp),%esi
  800218:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80021a:	85 c0                	test   %eax,%eax
  80021c:	7e 17                	jle    800235 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	50                   	push   %eax
  800222:	6a 05                	push   $0x5
  800224:	68 aa 1e 80 00       	push   $0x801eaa
  800229:	6a 23                	push   $0x23
  80022b:	68 c7 1e 80 00       	push   $0x801ec7
  800230:	e8 82 0e 00 00       	call   8010b7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800235:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800238:	5b                   	pop    %ebx
  800239:	5e                   	pop    %esi
  80023a:	5f                   	pop    %edi
  80023b:	5d                   	pop    %ebp
  80023c:	c3                   	ret    

0080023d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800246:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024b:	b8 06 00 00 00       	mov    $0x6,%eax
  800250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800253:	8b 55 08             	mov    0x8(%ebp),%edx
  800256:	89 df                	mov    %ebx,%edi
  800258:	89 de                	mov    %ebx,%esi
  80025a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80025c:	85 c0                	test   %eax,%eax
  80025e:	7e 17                	jle    800277 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800260:	83 ec 0c             	sub    $0xc,%esp
  800263:	50                   	push   %eax
  800264:	6a 06                	push   $0x6
  800266:	68 aa 1e 80 00       	push   $0x801eaa
  80026b:	6a 23                	push   $0x23
  80026d:	68 c7 1e 80 00       	push   $0x801ec7
  800272:	e8 40 0e 00 00       	call   8010b7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800277:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028d:	b8 08 00 00 00       	mov    $0x8,%eax
  800292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	89 df                	mov    %ebx,%edi
  80029a:	89 de                	mov    %ebx,%esi
  80029c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	7e 17                	jle    8002b9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a2:	83 ec 0c             	sub    $0xc,%esp
  8002a5:	50                   	push   %eax
  8002a6:	6a 08                	push   $0x8
  8002a8:	68 aa 1e 80 00       	push   $0x801eaa
  8002ad:	6a 23                	push   $0x23
  8002af:	68 c7 1e 80 00       	push   $0x801ec7
  8002b4:	e8 fe 0d 00 00       	call   8010b7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bc:	5b                   	pop    %ebx
  8002bd:	5e                   	pop    %esi
  8002be:	5f                   	pop    %edi
  8002bf:	5d                   	pop    %ebp
  8002c0:	c3                   	ret    

008002c1 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	57                   	push   %edi
  8002c5:	56                   	push   %esi
  8002c6:	53                   	push   %ebx
  8002c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ca:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cf:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	89 df                	mov    %ebx,%edi
  8002dc:	89 de                	mov    %ebx,%esi
  8002de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e0:	85 c0                	test   %eax,%eax
  8002e2:	7e 17                	jle    8002fb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e4:	83 ec 0c             	sub    $0xc,%esp
  8002e7:	50                   	push   %eax
  8002e8:	6a 09                	push   $0x9
  8002ea:	68 aa 1e 80 00       	push   $0x801eaa
  8002ef:	6a 23                	push   $0x23
  8002f1:	68 c7 1e 80 00       	push   $0x801ec7
  8002f6:	e8 bc 0d 00 00       	call   8010b7 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fe:	5b                   	pop    %ebx
  8002ff:	5e                   	pop    %esi
  800300:	5f                   	pop    %edi
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800311:	b8 0a 00 00 00       	mov    $0xa,%eax
  800316:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 df                	mov    %ebx,%edi
  80031e:	89 de                	mov    %ebx,%esi
  800320:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800322:	85 c0                	test   %eax,%eax
  800324:	7e 17                	jle    80033d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800326:	83 ec 0c             	sub    $0xc,%esp
  800329:	50                   	push   %eax
  80032a:	6a 0a                	push   $0xa
  80032c:	68 aa 1e 80 00       	push   $0x801eaa
  800331:	6a 23                	push   $0x23
  800333:	68 c7 1e 80 00       	push   $0x801ec7
  800338:	e8 7a 0d 00 00       	call   8010b7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80033d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800340:	5b                   	pop    %ebx
  800341:	5e                   	pop    %esi
  800342:	5f                   	pop    %edi
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	57                   	push   %edi
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034b:	be 00 00 00 00       	mov    $0x0,%esi
  800350:	b8 0c 00 00 00       	mov    $0xc,%eax
  800355:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800358:	8b 55 08             	mov    0x8(%ebp),%edx
  80035b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80035e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800361:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800363:	5b                   	pop    %ebx
  800364:	5e                   	pop    %esi
  800365:	5f                   	pop    %edi
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	57                   	push   %edi
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
  80036e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800371:	b9 00 00 00 00       	mov    $0x0,%ecx
  800376:	b8 0d 00 00 00       	mov    $0xd,%eax
  80037b:	8b 55 08             	mov    0x8(%ebp),%edx
  80037e:	89 cb                	mov    %ecx,%ebx
  800380:	89 cf                	mov    %ecx,%edi
  800382:	89 ce                	mov    %ecx,%esi
  800384:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800386:	85 c0                	test   %eax,%eax
  800388:	7e 17                	jle    8003a1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80038a:	83 ec 0c             	sub    $0xc,%esp
  80038d:	50                   	push   %eax
  80038e:	6a 0d                	push   $0xd
  800390:	68 aa 1e 80 00       	push   $0x801eaa
  800395:	6a 23                	push   $0x23
  800397:	68 c7 1e 80 00       	push   $0x801ec7
  80039c:	e8 16 0d 00 00       	call   8010b7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003a4:	5b                   	pop    %ebx
  8003a5:	5e                   	pop    %esi
  8003a6:	5f                   	pop    %edi
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003a9:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003aa:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8003af:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003b1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8003b4:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8003b8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8003bd:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8003c1:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8003c3:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8003c6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8003c7:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8003ca:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8003cb:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8003cc:	c3                   	ret    

008003cd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8003d8:	c1 e8 0c             	shr    $0xc,%eax
}
  8003db:	5d                   	pop    %ebp
  8003dc:	c3                   	ret    

008003dd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	05 00 00 00 30       	add    $0x30000000,%eax
  8003e8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003ed:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003fa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 16             	shr    $0x16,%edx
  800404:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 11                	je     800421 <fd_alloc+0x2d>
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 0c             	shr    $0xc,%edx
  800415:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	75 09                	jne    80042a <fd_alloc+0x36>
			*fd_store = fd;
  800421:	89 01                	mov    %eax,(%ecx)
			return 0;
  800423:	b8 00 00 00 00       	mov    $0x0,%eax
  800428:	eb 17                	jmp    800441 <fd_alloc+0x4d>
  80042a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80042f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800434:	75 c9                	jne    8003ff <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800436:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80043c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800441:	5d                   	pop    %ebp
  800442:	c3                   	ret    

00800443 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800443:	55                   	push   %ebp
  800444:	89 e5                	mov    %esp,%ebp
  800446:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800449:	83 f8 1f             	cmp    $0x1f,%eax
  80044c:	77 36                	ja     800484 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80044e:	c1 e0 0c             	shl    $0xc,%eax
  800451:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800456:	89 c2                	mov    %eax,%edx
  800458:	c1 ea 16             	shr    $0x16,%edx
  80045b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800462:	f6 c2 01             	test   $0x1,%dl
  800465:	74 24                	je     80048b <fd_lookup+0x48>
  800467:	89 c2                	mov    %eax,%edx
  800469:	c1 ea 0c             	shr    $0xc,%edx
  80046c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800473:	f6 c2 01             	test   $0x1,%dl
  800476:	74 1a                	je     800492 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800478:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047b:	89 02                	mov    %eax,(%edx)
	return 0;
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	eb 13                	jmp    800497 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800484:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800489:	eb 0c                	jmp    800497 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80048b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800490:	eb 05                	jmp    800497 <fd_lookup+0x54>
  800492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800497:	5d                   	pop    %ebp
  800498:	c3                   	ret    

00800499 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004a2:	ba 54 1f 80 00       	mov    $0x801f54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004a7:	eb 13                	jmp    8004bc <dev_lookup+0x23>
  8004a9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004ac:	39 08                	cmp    %ecx,(%eax)
  8004ae:	75 0c                	jne    8004bc <dev_lookup+0x23>
			*dev = devtab[i];
  8004b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004b3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ba:	eb 2e                	jmp    8004ea <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004bc:	8b 02                	mov    (%edx),%eax
  8004be:	85 c0                	test   %eax,%eax
  8004c0:	75 e7                	jne    8004a9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8004c7:	8b 40 48             	mov    0x48(%eax),%eax
  8004ca:	83 ec 04             	sub    $0x4,%esp
  8004cd:	51                   	push   %ecx
  8004ce:	50                   	push   %eax
  8004cf:	68 d8 1e 80 00       	push   $0x801ed8
  8004d4:	e8 b7 0c 00 00       	call   801190 <cprintf>
	*dev = 0;
  8004d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004dc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004e2:	83 c4 10             	add    $0x10,%esp
  8004e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    

008004ec <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	56                   	push   %esi
  8004f0:	53                   	push   %ebx
  8004f1:	83 ec 10             	sub    $0x10,%esp
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800504:	c1 e8 0c             	shr    $0xc,%eax
  800507:	50                   	push   %eax
  800508:	e8 36 ff ff ff       	call   800443 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 05                	js     800519 <fd_close+0x2d>
	    || fd != fd2)
  800514:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800517:	74 0c                	je     800525 <fd_close+0x39>
		return (must_exist ? r : 0);
  800519:	84 db                	test   %bl,%bl
  80051b:	ba 00 00 00 00       	mov    $0x0,%edx
  800520:	0f 44 c2             	cmove  %edx,%eax
  800523:	eb 41                	jmp    800566 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80052b:	50                   	push   %eax
  80052c:	ff 36                	pushl  (%esi)
  80052e:	e8 66 ff ff ff       	call   800499 <dev_lookup>
  800533:	89 c3                	mov    %eax,%ebx
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	85 c0                	test   %eax,%eax
  80053a:	78 1a                	js     800556 <fd_close+0x6a>
		if (dev->dev_close)
  80053c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80053f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800542:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800547:	85 c0                	test   %eax,%eax
  800549:	74 0b                	je     800556 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80054b:	83 ec 0c             	sub    $0xc,%esp
  80054e:	56                   	push   %esi
  80054f:	ff d0                	call   *%eax
  800551:	89 c3                	mov    %eax,%ebx
  800553:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	56                   	push   %esi
  80055a:	6a 00                	push   $0x0
  80055c:	e8 dc fc ff ff       	call   80023d <sys_page_unmap>
	return r;
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	89 d8                	mov    %ebx,%eax
}
  800566:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800569:	5b                   	pop    %ebx
  80056a:	5e                   	pop    %esi
  80056b:	5d                   	pop    %ebp
  80056c:	c3                   	ret    

0080056d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800573:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800576:	50                   	push   %eax
  800577:	ff 75 08             	pushl  0x8(%ebp)
  80057a:	e8 c4 fe ff ff       	call   800443 <fd_lookup>
  80057f:	83 c4 08             	add    $0x8,%esp
  800582:	85 c0                	test   %eax,%eax
  800584:	78 10                	js     800596 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800586:	83 ec 08             	sub    $0x8,%esp
  800589:	6a 01                	push   $0x1
  80058b:	ff 75 f4             	pushl  -0xc(%ebp)
  80058e:	e8 59 ff ff ff       	call   8004ec <fd_close>
  800593:	83 c4 10             	add    $0x10,%esp
}
  800596:	c9                   	leave  
  800597:	c3                   	ret    

00800598 <close_all>:

void
close_all(void)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	53                   	push   %ebx
  80059c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80059f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	53                   	push   %ebx
  8005a8:	e8 c0 ff ff ff       	call   80056d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ad:	83 c3 01             	add    $0x1,%ebx
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	83 fb 20             	cmp    $0x20,%ebx
  8005b6:	75 ec                	jne    8005a4 <close_all+0xc>
		close(i);
}
  8005b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005bb:	c9                   	leave  
  8005bc:	c3                   	ret    

008005bd <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
  8005c0:	57                   	push   %edi
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	83 ec 2c             	sub    $0x2c,%esp
  8005c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005cc:	50                   	push   %eax
  8005cd:	ff 75 08             	pushl  0x8(%ebp)
  8005d0:	e8 6e fe ff ff       	call   800443 <fd_lookup>
  8005d5:	83 c4 08             	add    $0x8,%esp
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	0f 88 c1 00 00 00    	js     8006a1 <dup+0xe4>
		return r;
	close(newfdnum);
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	56                   	push   %esi
  8005e4:	e8 84 ff ff ff       	call   80056d <close>

	newfd = INDEX2FD(newfdnum);
  8005e9:	89 f3                	mov    %esi,%ebx
  8005eb:	c1 e3 0c             	shl    $0xc,%ebx
  8005ee:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005f4:	83 c4 04             	add    $0x4,%esp
  8005f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005fa:	e8 de fd ff ff       	call   8003dd <fd2data>
  8005ff:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800601:	89 1c 24             	mov    %ebx,(%esp)
  800604:	e8 d4 fd ff ff       	call   8003dd <fd2data>
  800609:	83 c4 10             	add    $0x10,%esp
  80060c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80060f:	89 f8                	mov    %edi,%eax
  800611:	c1 e8 16             	shr    $0x16,%eax
  800614:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80061b:	a8 01                	test   $0x1,%al
  80061d:	74 37                	je     800656 <dup+0x99>
  80061f:	89 f8                	mov    %edi,%eax
  800621:	c1 e8 0c             	shr    $0xc,%eax
  800624:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80062b:	f6 c2 01             	test   $0x1,%dl
  80062e:	74 26                	je     800656 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800630:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800637:	83 ec 0c             	sub    $0xc,%esp
  80063a:	25 07 0e 00 00       	and    $0xe07,%eax
  80063f:	50                   	push   %eax
  800640:	ff 75 d4             	pushl  -0x2c(%ebp)
  800643:	6a 00                	push   $0x0
  800645:	57                   	push   %edi
  800646:	6a 00                	push   $0x0
  800648:	e8 ae fb ff ff       	call   8001fb <sys_page_map>
  80064d:	89 c7                	mov    %eax,%edi
  80064f:	83 c4 20             	add    $0x20,%esp
  800652:	85 c0                	test   %eax,%eax
  800654:	78 2e                	js     800684 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800656:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800659:	89 d0                	mov    %edx,%eax
  80065b:	c1 e8 0c             	shr    $0xc,%eax
  80065e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800665:	83 ec 0c             	sub    $0xc,%esp
  800668:	25 07 0e 00 00       	and    $0xe07,%eax
  80066d:	50                   	push   %eax
  80066e:	53                   	push   %ebx
  80066f:	6a 00                	push   $0x0
  800671:	52                   	push   %edx
  800672:	6a 00                	push   $0x0
  800674:	e8 82 fb ff ff       	call   8001fb <sys_page_map>
  800679:	89 c7                	mov    %eax,%edi
  80067b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80067e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800680:	85 ff                	test   %edi,%edi
  800682:	79 1d                	jns    8006a1 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	53                   	push   %ebx
  800688:	6a 00                	push   $0x0
  80068a:	e8 ae fb ff ff       	call   80023d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	ff 75 d4             	pushl  -0x2c(%ebp)
  800695:	6a 00                	push   $0x0
  800697:	e8 a1 fb ff ff       	call   80023d <sys_page_unmap>
	return r;
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	89 f8                	mov    %edi,%eax
}
  8006a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a4:	5b                   	pop    %ebx
  8006a5:	5e                   	pop    %esi
  8006a6:	5f                   	pop    %edi
  8006a7:	5d                   	pop    %ebp
  8006a8:	c3                   	ret    

008006a9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	53                   	push   %ebx
  8006ad:	83 ec 14             	sub    $0x14,%esp
  8006b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006b6:	50                   	push   %eax
  8006b7:	53                   	push   %ebx
  8006b8:	e8 86 fd ff ff       	call   800443 <fd_lookup>
  8006bd:	83 c4 08             	add    $0x8,%esp
  8006c0:	89 c2                	mov    %eax,%edx
  8006c2:	85 c0                	test   %eax,%eax
  8006c4:	78 6d                	js     800733 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006cc:	50                   	push   %eax
  8006cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006d0:	ff 30                	pushl  (%eax)
  8006d2:	e8 c2 fd ff ff       	call   800499 <dev_lookup>
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	85 c0                	test   %eax,%eax
  8006dc:	78 4c                	js     80072a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006e1:	8b 42 08             	mov    0x8(%edx),%eax
  8006e4:	83 e0 03             	and    $0x3,%eax
  8006e7:	83 f8 01             	cmp    $0x1,%eax
  8006ea:	75 21                	jne    80070d <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8006f1:	8b 40 48             	mov    0x48(%eax),%eax
  8006f4:	83 ec 04             	sub    $0x4,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	50                   	push   %eax
  8006f9:	68 19 1f 80 00       	push   $0x801f19
  8006fe:	e8 8d 0a 00 00       	call   801190 <cprintf>
		return -E_INVAL;
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80070b:	eb 26                	jmp    800733 <read+0x8a>
	}
	if (!dev->dev_read)
  80070d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800710:	8b 40 08             	mov    0x8(%eax),%eax
  800713:	85 c0                	test   %eax,%eax
  800715:	74 17                	je     80072e <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800717:	83 ec 04             	sub    $0x4,%esp
  80071a:	ff 75 10             	pushl  0x10(%ebp)
  80071d:	ff 75 0c             	pushl  0xc(%ebp)
  800720:	52                   	push   %edx
  800721:	ff d0                	call   *%eax
  800723:	89 c2                	mov    %eax,%edx
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	eb 09                	jmp    800733 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	89 c2                	mov    %eax,%edx
  80072c:	eb 05                	jmp    800733 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80072e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800733:	89 d0                	mov    %edx,%eax
  800735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800738:	c9                   	leave  
  800739:	c3                   	ret    

0080073a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	57                   	push   %edi
  80073e:	56                   	push   %esi
  80073f:	53                   	push   %ebx
  800740:	83 ec 0c             	sub    $0xc,%esp
  800743:	8b 7d 08             	mov    0x8(%ebp),%edi
  800746:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800749:	bb 00 00 00 00       	mov    $0x0,%ebx
  80074e:	eb 21                	jmp    800771 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	89 f0                	mov    %esi,%eax
  800755:	29 d8                	sub    %ebx,%eax
  800757:	50                   	push   %eax
  800758:	89 d8                	mov    %ebx,%eax
  80075a:	03 45 0c             	add    0xc(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	57                   	push   %edi
  80075f:	e8 45 ff ff ff       	call   8006a9 <read>
		if (m < 0)
  800764:	83 c4 10             	add    $0x10,%esp
  800767:	85 c0                	test   %eax,%eax
  800769:	78 10                	js     80077b <readn+0x41>
			return m;
		if (m == 0)
  80076b:	85 c0                	test   %eax,%eax
  80076d:	74 0a                	je     800779 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80076f:	01 c3                	add    %eax,%ebx
  800771:	39 f3                	cmp    %esi,%ebx
  800773:	72 db                	jb     800750 <readn+0x16>
  800775:	89 d8                	mov    %ebx,%eax
  800777:	eb 02                	jmp    80077b <readn+0x41>
  800779:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80077b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077e:	5b                   	pop    %ebx
  80077f:	5e                   	pop    %esi
  800780:	5f                   	pop    %edi
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	83 ec 14             	sub    $0x14,%esp
  80078a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80078d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800790:	50                   	push   %eax
  800791:	53                   	push   %ebx
  800792:	e8 ac fc ff ff       	call   800443 <fd_lookup>
  800797:	83 c4 08             	add    $0x8,%esp
  80079a:	89 c2                	mov    %eax,%edx
  80079c:	85 c0                	test   %eax,%eax
  80079e:	78 68                	js     800808 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007aa:	ff 30                	pushl  (%eax)
  8007ac:	e8 e8 fc ff ff       	call   800499 <dev_lookup>
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	85 c0                	test   %eax,%eax
  8007b6:	78 47                	js     8007ff <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007bf:	75 21                	jne    8007e2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8007c6:	8b 40 48             	mov    0x48(%eax),%eax
  8007c9:	83 ec 04             	sub    $0x4,%esp
  8007cc:	53                   	push   %ebx
  8007cd:	50                   	push   %eax
  8007ce:	68 35 1f 80 00       	push   $0x801f35
  8007d3:	e8 b8 09 00 00       	call   801190 <cprintf>
		return -E_INVAL;
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007e0:	eb 26                	jmp    800808 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e5:	8b 52 0c             	mov    0xc(%edx),%edx
  8007e8:	85 d2                	test   %edx,%edx
  8007ea:	74 17                	je     800803 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ec:	83 ec 04             	sub    $0x4,%esp
  8007ef:	ff 75 10             	pushl  0x10(%ebp)
  8007f2:	ff 75 0c             	pushl  0xc(%ebp)
  8007f5:	50                   	push   %eax
  8007f6:	ff d2                	call   *%edx
  8007f8:	89 c2                	mov    %eax,%edx
  8007fa:	83 c4 10             	add    $0x10,%esp
  8007fd:	eb 09                	jmp    800808 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ff:	89 c2                	mov    %eax,%edx
  800801:	eb 05                	jmp    800808 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800803:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800808:	89 d0                	mov    %edx,%eax
  80080a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <seek>:

int
seek(int fdnum, off_t offset)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800815:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800818:	50                   	push   %eax
  800819:	ff 75 08             	pushl  0x8(%ebp)
  80081c:	e8 22 fc ff ff       	call   800443 <fd_lookup>
  800821:	83 c4 08             	add    $0x8,%esp
  800824:	85 c0                	test   %eax,%eax
  800826:	78 0e                	js     800836 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800828:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800831:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	83 ec 14             	sub    $0x14,%esp
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800842:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800845:	50                   	push   %eax
  800846:	53                   	push   %ebx
  800847:	e8 f7 fb ff ff       	call   800443 <fd_lookup>
  80084c:	83 c4 08             	add    $0x8,%esp
  80084f:	89 c2                	mov    %eax,%edx
  800851:	85 c0                	test   %eax,%eax
  800853:	78 65                	js     8008ba <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085b:	50                   	push   %eax
  80085c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085f:	ff 30                	pushl  (%eax)
  800861:	e8 33 fc ff ff       	call   800499 <dev_lookup>
  800866:	83 c4 10             	add    $0x10,%esp
  800869:	85 c0                	test   %eax,%eax
  80086b:	78 44                	js     8008b1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80086d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800870:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800874:	75 21                	jne    800897 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800876:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80087b:	8b 40 48             	mov    0x48(%eax),%eax
  80087e:	83 ec 04             	sub    $0x4,%esp
  800881:	53                   	push   %ebx
  800882:	50                   	push   %eax
  800883:	68 f8 1e 80 00       	push   $0x801ef8
  800888:	e8 03 09 00 00       	call   801190 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80088d:	83 c4 10             	add    $0x10,%esp
  800890:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800895:	eb 23                	jmp    8008ba <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800897:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80089a:	8b 52 18             	mov    0x18(%edx),%edx
  80089d:	85 d2                	test   %edx,%edx
  80089f:	74 14                	je     8008b5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	ff 75 0c             	pushl  0xc(%ebp)
  8008a7:	50                   	push   %eax
  8008a8:	ff d2                	call   *%edx
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 09                	jmp    8008ba <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	eb 05                	jmp    8008ba <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	53                   	push   %ebx
  8008c5:	83 ec 14             	sub    $0x14,%esp
  8008c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ce:	50                   	push   %eax
  8008cf:	ff 75 08             	pushl  0x8(%ebp)
  8008d2:	e8 6c fb ff ff       	call   800443 <fd_lookup>
  8008d7:	83 c4 08             	add    $0x8,%esp
  8008da:	89 c2                	mov    %eax,%edx
  8008dc:	85 c0                	test   %eax,%eax
  8008de:	78 58                	js     800938 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008e6:	50                   	push   %eax
  8008e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ea:	ff 30                	pushl  (%eax)
  8008ec:	e8 a8 fb ff ff       	call   800499 <dev_lookup>
  8008f1:	83 c4 10             	add    $0x10,%esp
  8008f4:	85 c0                	test   %eax,%eax
  8008f6:	78 37                	js     80092f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ff:	74 32                	je     800933 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800901:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800904:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80090b:	00 00 00 
	stat->st_isdir = 0;
  80090e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800915:	00 00 00 
	stat->st_dev = dev;
  800918:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	53                   	push   %ebx
  800922:	ff 75 f0             	pushl  -0x10(%ebp)
  800925:	ff 50 14             	call   *0x14(%eax)
  800928:	89 c2                	mov    %eax,%edx
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	eb 09                	jmp    800938 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80092f:	89 c2                	mov    %eax,%edx
  800931:	eb 05                	jmp    800938 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800933:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800938:	89 d0                	mov    %edx,%eax
  80093a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800944:	83 ec 08             	sub    $0x8,%esp
  800947:	6a 00                	push   $0x0
  800949:	ff 75 08             	pushl  0x8(%ebp)
  80094c:	e8 e3 01 00 00       	call   800b34 <open>
  800951:	89 c3                	mov    %eax,%ebx
  800953:	83 c4 10             	add    $0x10,%esp
  800956:	85 c0                	test   %eax,%eax
  800958:	78 1b                	js     800975 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80095a:	83 ec 08             	sub    $0x8,%esp
  80095d:	ff 75 0c             	pushl  0xc(%ebp)
  800960:	50                   	push   %eax
  800961:	e8 5b ff ff ff       	call   8008c1 <fstat>
  800966:	89 c6                	mov    %eax,%esi
	close(fd);
  800968:	89 1c 24             	mov    %ebx,(%esp)
  80096b:	e8 fd fb ff ff       	call   80056d <close>
	return r;
  800970:	83 c4 10             	add    $0x10,%esp
  800973:	89 f0                	mov    %esi,%eax
}
  800975:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	89 c6                	mov    %eax,%esi
  800983:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800985:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80098c:	75 12                	jne    8009a0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80098e:	83 ec 0c             	sub    $0xc,%esp
  800991:	6a 01                	push   $0x1
  800993:	e8 03 12 00 00       	call   801b9b <ipc_find_env>
  800998:	a3 00 40 80 00       	mov    %eax,0x804000
  80099d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8009a0:	6a 07                	push   $0x7
  8009a2:	68 00 50 80 00       	push   $0x805000
  8009a7:	56                   	push   %esi
  8009a8:	ff 35 00 40 80 00    	pushl  0x804000
  8009ae:	e8 86 11 00 00       	call   801b39 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009b3:	83 c4 0c             	add    $0xc,%esp
  8009b6:	6a 00                	push   $0x0
  8009b8:	53                   	push   %ebx
  8009b9:	6a 00                	push   $0x0
  8009bb:	e8 07 11 00 00       	call   801ac7 <ipc_recv>
}
  8009c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009c3:	5b                   	pop    %ebx
  8009c4:	5e                   	pop    %esi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009db:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e5:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ea:	e8 8d ff ff ff       	call   80097c <fsipc>
}
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800a02:	ba 00 00 00 00       	mov    $0x0,%edx
  800a07:	b8 06 00 00 00       	mov    $0x6,%eax
  800a0c:	e8 6b ff ff ff       	call   80097c <fsipc>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	53                   	push   %ebx
  800a17:	83 ec 04             	sub    $0x4,%esp
  800a1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 40 0c             	mov    0xc(%eax),%eax
  800a23:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a28:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2d:	b8 05 00 00 00       	mov    $0x5,%eax
  800a32:	e8 45 ff ff ff       	call   80097c <fsipc>
  800a37:	85 c0                	test   %eax,%eax
  800a39:	78 2c                	js     800a67 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a3b:	83 ec 08             	sub    $0x8,%esp
  800a3e:	68 00 50 80 00       	push   $0x805000
  800a43:	53                   	push   %ebx
  800a44:	e8 cc 0c 00 00       	call   801715 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a49:	a1 80 50 80 00       	mov    0x805080,%eax
  800a4e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a54:	a1 84 50 80 00       	mov    0x805084,%eax
  800a59:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a5f:	83 c4 10             	add    $0x10,%esp
  800a62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 0c             	sub    $0xc,%esp
  800a72:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a75:	8b 55 08             	mov    0x8(%ebp),%edx
  800a78:	8b 52 0c             	mov    0xc(%edx),%edx
  800a7b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a81:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a86:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a8b:	0f 47 c2             	cmova  %edx,%eax
  800a8e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a93:	50                   	push   %eax
  800a94:	ff 75 0c             	pushl  0xc(%ebp)
  800a97:	68 08 50 80 00       	push   $0x805008
  800a9c:	e8 06 0e 00 00       	call   8018a7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa6:	b8 04 00 00 00       	mov    $0x4,%eax
  800aab:	e8 cc fe ff ff       	call   80097c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800ab0:	c9                   	leave  
  800ab1:	c3                   	ret    

00800ab2 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	56                   	push   %esi
  800ab6:	53                   	push   %ebx
  800ab7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	8b 40 0c             	mov    0xc(%eax),%eax
  800ac0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ac5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800acb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ad5:	e8 a2 fe ff ff       	call   80097c <fsipc>
  800ada:	89 c3                	mov    %eax,%ebx
  800adc:	85 c0                	test   %eax,%eax
  800ade:	78 4b                	js     800b2b <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ae0:	39 c6                	cmp    %eax,%esi
  800ae2:	73 16                	jae    800afa <devfile_read+0x48>
  800ae4:	68 64 1f 80 00       	push   $0x801f64
  800ae9:	68 6b 1f 80 00       	push   $0x801f6b
  800aee:	6a 7c                	push   $0x7c
  800af0:	68 80 1f 80 00       	push   $0x801f80
  800af5:	e8 bd 05 00 00       	call   8010b7 <_panic>
	assert(r <= PGSIZE);
  800afa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aff:	7e 16                	jle    800b17 <devfile_read+0x65>
  800b01:	68 8b 1f 80 00       	push   $0x801f8b
  800b06:	68 6b 1f 80 00       	push   $0x801f6b
  800b0b:	6a 7d                	push   $0x7d
  800b0d:	68 80 1f 80 00       	push   $0x801f80
  800b12:	e8 a0 05 00 00       	call   8010b7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b17:	83 ec 04             	sub    $0x4,%esp
  800b1a:	50                   	push   %eax
  800b1b:	68 00 50 80 00       	push   $0x805000
  800b20:	ff 75 0c             	pushl  0xc(%ebp)
  800b23:	e8 7f 0d 00 00       	call   8018a7 <memmove>
	return r;
  800b28:	83 c4 10             	add    $0x10,%esp
}
  800b2b:	89 d8                	mov    %ebx,%eax
  800b2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	53                   	push   %ebx
  800b38:	83 ec 20             	sub    $0x20,%esp
  800b3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b3e:	53                   	push   %ebx
  800b3f:	e8 98 0b 00 00       	call   8016dc <strlen>
  800b44:	83 c4 10             	add    $0x10,%esp
  800b47:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b4c:	7f 67                	jg     800bb5 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b4e:	83 ec 0c             	sub    $0xc,%esp
  800b51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b54:	50                   	push   %eax
  800b55:	e8 9a f8 ff ff       	call   8003f4 <fd_alloc>
  800b5a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b5d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	78 57                	js     800bba <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b63:	83 ec 08             	sub    $0x8,%esp
  800b66:	53                   	push   %ebx
  800b67:	68 00 50 80 00       	push   $0x805000
  800b6c:	e8 a4 0b 00 00       	call   801715 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b74:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b79:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b81:	e8 f6 fd ff ff       	call   80097c <fsipc>
  800b86:	89 c3                	mov    %eax,%ebx
  800b88:	83 c4 10             	add    $0x10,%esp
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	79 14                	jns    800ba3 <open+0x6f>
		fd_close(fd, 0);
  800b8f:	83 ec 08             	sub    $0x8,%esp
  800b92:	6a 00                	push   $0x0
  800b94:	ff 75 f4             	pushl  -0xc(%ebp)
  800b97:	e8 50 f9 ff ff       	call   8004ec <fd_close>
		return r;
  800b9c:	83 c4 10             	add    $0x10,%esp
  800b9f:	89 da                	mov    %ebx,%edx
  800ba1:	eb 17                	jmp    800bba <open+0x86>
	}

	return fd2num(fd);
  800ba3:	83 ec 0c             	sub    $0xc,%esp
  800ba6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba9:	e8 1f f8 ff ff       	call   8003cd <fd2num>
  800bae:	89 c2                	mov    %eax,%edx
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	eb 05                	jmp    800bba <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bb5:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bba:	89 d0                	mov    %edx,%eax
  800bbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    

00800bc1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcc:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd1:	e8 a6 fd ff ff       	call   80097c <fsipc>
}
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	ff 75 08             	pushl  0x8(%ebp)
  800be6:	e8 f2 f7 ff ff       	call   8003dd <fd2data>
  800beb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bed:	83 c4 08             	add    $0x8,%esp
  800bf0:	68 97 1f 80 00       	push   $0x801f97
  800bf5:	53                   	push   %ebx
  800bf6:	e8 1a 0b 00 00       	call   801715 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bfb:	8b 46 04             	mov    0x4(%esi),%eax
  800bfe:	2b 06                	sub    (%esi),%eax
  800c00:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800c06:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c0d:	00 00 00 
	stat->st_dev = &devpipe;
  800c10:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c17:	30 80 00 
	return 0;
}
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
  800c2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c30:	53                   	push   %ebx
  800c31:	6a 00                	push   $0x0
  800c33:	e8 05 f6 ff ff       	call   80023d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c38:	89 1c 24             	mov    %ebx,(%esp)
  800c3b:	e8 9d f7 ff ff       	call   8003dd <fd2data>
  800c40:	83 c4 08             	add    $0x8,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 00                	push   $0x0
  800c46:	e8 f2 f5 ff ff       	call   80023d <sys_page_unmap>
}
  800c4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c4e:	c9                   	leave  
  800c4f:	c3                   	ret    

00800c50 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	83 ec 1c             	sub    $0x1c,%esp
  800c59:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c5c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c5e:	a1 04 40 80 00       	mov    0x804004,%eax
  800c63:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c66:	83 ec 0c             	sub    $0xc,%esp
  800c69:	ff 75 e0             	pushl  -0x20(%ebp)
  800c6c:	e8 63 0f 00 00       	call   801bd4 <pageref>
  800c71:	89 c3                	mov    %eax,%ebx
  800c73:	89 3c 24             	mov    %edi,(%esp)
  800c76:	e8 59 0f 00 00       	call   801bd4 <pageref>
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	39 c3                	cmp    %eax,%ebx
  800c80:	0f 94 c1             	sete   %cl
  800c83:	0f b6 c9             	movzbl %cl,%ecx
  800c86:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c89:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c8f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c92:	39 ce                	cmp    %ecx,%esi
  800c94:	74 1b                	je     800cb1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c96:	39 c3                	cmp    %eax,%ebx
  800c98:	75 c4                	jne    800c5e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c9a:	8b 42 58             	mov    0x58(%edx),%eax
  800c9d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ca0:	50                   	push   %eax
  800ca1:	56                   	push   %esi
  800ca2:	68 9e 1f 80 00       	push   $0x801f9e
  800ca7:	e8 e4 04 00 00       	call   801190 <cprintf>
  800cac:	83 c4 10             	add    $0x10,%esp
  800caf:	eb ad                	jmp    800c5e <_pipeisclosed+0xe>
	}
}
  800cb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 28             	sub    $0x28,%esp
  800cc5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800cc8:	56                   	push   %esi
  800cc9:	e8 0f f7 ff ff       	call   8003dd <fd2data>
  800cce:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd0:	83 c4 10             	add    $0x10,%esp
  800cd3:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd8:	eb 4b                	jmp    800d25 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cda:	89 da                	mov    %ebx,%edx
  800cdc:	89 f0                	mov    %esi,%eax
  800cde:	e8 6d ff ff ff       	call   800c50 <_pipeisclosed>
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	75 48                	jne    800d2f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ce7:	e8 ad f4 ff ff       	call   800199 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cec:	8b 43 04             	mov    0x4(%ebx),%eax
  800cef:	8b 0b                	mov    (%ebx),%ecx
  800cf1:	8d 51 20             	lea    0x20(%ecx),%edx
  800cf4:	39 d0                	cmp    %edx,%eax
  800cf6:	73 e2                	jae    800cda <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cff:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800d02:	89 c2                	mov    %eax,%edx
  800d04:	c1 fa 1f             	sar    $0x1f,%edx
  800d07:	89 d1                	mov    %edx,%ecx
  800d09:	c1 e9 1b             	shr    $0x1b,%ecx
  800d0c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800d0f:	83 e2 1f             	and    $0x1f,%edx
  800d12:	29 ca                	sub    %ecx,%edx
  800d14:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d18:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d1c:	83 c0 01             	add    $0x1,%eax
  800d1f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d22:	83 c7 01             	add    $0x1,%edi
  800d25:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d28:	75 c2                	jne    800cec <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2d:	eb 05                	jmp    800d34 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 18             	sub    $0x18,%esp
  800d45:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d48:	57                   	push   %edi
  800d49:	e8 8f f6 ff ff       	call   8003dd <fd2data>
  800d4e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d50:	83 c4 10             	add    $0x10,%esp
  800d53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d58:	eb 3d                	jmp    800d97 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d5a:	85 db                	test   %ebx,%ebx
  800d5c:	74 04                	je     800d62 <devpipe_read+0x26>
				return i;
  800d5e:	89 d8                	mov    %ebx,%eax
  800d60:	eb 44                	jmp    800da6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d62:	89 f2                	mov    %esi,%edx
  800d64:	89 f8                	mov    %edi,%eax
  800d66:	e8 e5 fe ff ff       	call   800c50 <_pipeisclosed>
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	75 32                	jne    800da1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d6f:	e8 25 f4 ff ff       	call   800199 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d74:	8b 06                	mov    (%esi),%eax
  800d76:	3b 46 04             	cmp    0x4(%esi),%eax
  800d79:	74 df                	je     800d5a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d7b:	99                   	cltd   
  800d7c:	c1 ea 1b             	shr    $0x1b,%edx
  800d7f:	01 d0                	add    %edx,%eax
  800d81:	83 e0 1f             	and    $0x1f,%eax
  800d84:	29 d0                	sub    %edx,%eax
  800d86:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d91:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d94:	83 c3 01             	add    $0x1,%ebx
  800d97:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d9a:	75 d8                	jne    800d74 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d9f:	eb 05                	jmp    800da6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800da1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800db6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800db9:	50                   	push   %eax
  800dba:	e8 35 f6 ff ff       	call   8003f4 <fd_alloc>
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	89 c2                	mov    %eax,%edx
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	0f 88 2c 01 00 00    	js     800ef8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	68 07 04 00 00       	push   $0x407
  800dd4:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 da f3 ff ff       	call   8001b8 <sys_page_alloc>
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	85 c0                	test   %eax,%eax
  800de5:	0f 88 0d 01 00 00    	js     800ef8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800df1:	50                   	push   %eax
  800df2:	e8 fd f5 ff ff       	call   8003f4 <fd_alloc>
  800df7:	89 c3                	mov    %eax,%ebx
  800df9:	83 c4 10             	add    $0x10,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	0f 88 e2 00 00 00    	js     800ee6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e04:	83 ec 04             	sub    $0x4,%esp
  800e07:	68 07 04 00 00       	push   $0x407
  800e0c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0f:	6a 00                	push   $0x0
  800e11:	e8 a2 f3 ff ff       	call   8001b8 <sys_page_alloc>
  800e16:	89 c3                	mov    %eax,%ebx
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	0f 88 c3 00 00 00    	js     800ee6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	ff 75 f4             	pushl  -0xc(%ebp)
  800e29:	e8 af f5 ff ff       	call   8003dd <fd2data>
  800e2e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e30:	83 c4 0c             	add    $0xc,%esp
  800e33:	68 07 04 00 00       	push   $0x407
  800e38:	50                   	push   %eax
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 78 f3 ff ff       	call   8001b8 <sys_page_alloc>
  800e40:	89 c3                	mov    %eax,%ebx
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	0f 88 89 00 00 00    	js     800ed6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	ff 75 f0             	pushl  -0x10(%ebp)
  800e53:	e8 85 f5 ff ff       	call   8003dd <fd2data>
  800e58:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e5f:	50                   	push   %eax
  800e60:	6a 00                	push   $0x0
  800e62:	56                   	push   %esi
  800e63:	6a 00                	push   $0x0
  800e65:	e8 91 f3 ff ff       	call   8001fb <sys_page_map>
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	83 c4 20             	add    $0x20,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	78 55                	js     800ec8 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e73:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e81:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e88:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e91:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e96:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e9d:	83 ec 0c             	sub    $0xc,%esp
  800ea0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea3:	e8 25 f5 ff ff       	call   8003cd <fd2num>
  800ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eab:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800ead:	83 c4 04             	add    $0x4,%esp
  800eb0:	ff 75 f0             	pushl  -0x10(%ebp)
  800eb3:	e8 15 f5 ff ff       	call   8003cd <fd2num>
  800eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebb:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec6:	eb 30                	jmp    800ef8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800ec8:	83 ec 08             	sub    $0x8,%esp
  800ecb:	56                   	push   %esi
  800ecc:	6a 00                	push   $0x0
  800ece:	e8 6a f3 ff ff       	call   80023d <sys_page_unmap>
  800ed3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ed6:	83 ec 08             	sub    $0x8,%esp
  800ed9:	ff 75 f0             	pushl  -0x10(%ebp)
  800edc:	6a 00                	push   $0x0
  800ede:	e8 5a f3 ff ff       	call   80023d <sys_page_unmap>
  800ee3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ee6:	83 ec 08             	sub    $0x8,%esp
  800ee9:	ff 75 f4             	pushl  -0xc(%ebp)
  800eec:	6a 00                	push   $0x0
  800eee:	e8 4a f3 ff ff       	call   80023d <sys_page_unmap>
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ef8:	89 d0                	mov    %edx,%eax
  800efa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	ff 75 08             	pushl  0x8(%ebp)
  800f0e:	e8 30 f5 ff ff       	call   800443 <fd_lookup>
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	78 18                	js     800f32 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800f1a:	83 ec 0c             	sub    $0xc,%esp
  800f1d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f20:	e8 b8 f4 ff ff       	call   8003dd <fd2data>
	return _pipeisclosed(fd, p);
  800f25:	89 c2                	mov    %eax,%edx
  800f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f2a:	e8 21 fd ff ff       	call   800c50 <_pipeisclosed>
  800f2f:	83 c4 10             	add    $0x10,%esp
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f37:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    

00800f3e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
  800f41:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f44:	68 b6 1f 80 00       	push   $0x801fb6
  800f49:	ff 75 0c             	pushl  0xc(%ebp)
  800f4c:	e8 c4 07 00 00       	call   801715 <strcpy>
	return 0;
}
  800f51:	b8 00 00 00 00       	mov    $0x0,%eax
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
  800f5e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f64:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f69:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f6f:	eb 2d                	jmp    800f9e <devcons_write+0x46>
		m = n - tot;
  800f71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f74:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f76:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f79:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f7e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	53                   	push   %ebx
  800f85:	03 45 0c             	add    0xc(%ebp),%eax
  800f88:	50                   	push   %eax
  800f89:	57                   	push   %edi
  800f8a:	e8 18 09 00 00       	call   8018a7 <memmove>
		sys_cputs(buf, m);
  800f8f:	83 c4 08             	add    $0x8,%esp
  800f92:	53                   	push   %ebx
  800f93:	57                   	push   %edi
  800f94:	e8 63 f1 ff ff       	call   8000fc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f99:	01 de                	add    %ebx,%esi
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800fa3:	72 cc                	jb     800f71 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800fa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 08             	sub    $0x8,%esp
  800fb3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800fb8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fbc:	74 2a                	je     800fe8 <devcons_read+0x3b>
  800fbe:	eb 05                	jmp    800fc5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800fc0:	e8 d4 f1 ff ff       	call   800199 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800fc5:	e8 50 f1 ff ff       	call   80011a <sys_cgetc>
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	74 f2                	je     800fc0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 16                	js     800fe8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fd2:	83 f8 04             	cmp    $0x4,%eax
  800fd5:	74 0c                	je     800fe3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fda:	88 02                	mov    %al,(%edx)
	return 1;
  800fdc:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe1:	eb 05                	jmp    800fe8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fe8:	c9                   	leave  
  800fe9:	c3                   	ret    

00800fea <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800ff6:	6a 01                	push   $0x1
  800ff8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	e8 fb f0 ff ff       	call   8000fc <sys_cputs>
}
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	c9                   	leave  
  801005:	c3                   	ret    

00801006 <getchar>:

int
getchar(void)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80100c:	6a 01                	push   $0x1
  80100e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801011:	50                   	push   %eax
  801012:	6a 00                	push   $0x0
  801014:	e8 90 f6 ff ff       	call   8006a9 <read>
	if (r < 0)
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 0f                	js     80102f <getchar+0x29>
		return r;
	if (r < 1)
  801020:	85 c0                	test   %eax,%eax
  801022:	7e 06                	jle    80102a <getchar+0x24>
		return -E_EOF;
	return c;
  801024:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801028:	eb 05                	jmp    80102f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80102a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801037:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103a:	50                   	push   %eax
  80103b:	ff 75 08             	pushl  0x8(%ebp)
  80103e:	e8 00 f4 ff ff       	call   800443 <fd_lookup>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 11                	js     80105b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80104a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801053:	39 10                	cmp    %edx,(%eax)
  801055:	0f 94 c0             	sete   %al
  801058:	0f b6 c0             	movzbl %al,%eax
}
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    

0080105d <opencons>:

int
opencons(void)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801063:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801066:	50                   	push   %eax
  801067:	e8 88 f3 ff ff       	call   8003f4 <fd_alloc>
  80106c:	83 c4 10             	add    $0x10,%esp
		return r;
  80106f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801071:	85 c0                	test   %eax,%eax
  801073:	78 3e                	js     8010b3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	68 07 04 00 00       	push   $0x407
  80107d:	ff 75 f4             	pushl  -0xc(%ebp)
  801080:	6a 00                	push   $0x0
  801082:	e8 31 f1 ff ff       	call   8001b8 <sys_page_alloc>
  801087:	83 c4 10             	add    $0x10,%esp
		return r;
  80108a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 23                	js     8010b3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801090:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801096:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801099:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80109b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	50                   	push   %eax
  8010a9:	e8 1f f3 ff ff       	call   8003cd <fd2num>
  8010ae:	89 c2                	mov    %eax,%edx
  8010b0:	83 c4 10             	add    $0x10,%esp
}
  8010b3:	89 d0                	mov    %edx,%eax
  8010b5:	c9                   	leave  
  8010b6:	c3                   	ret    

008010b7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	56                   	push   %esi
  8010bb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010bc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010bf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010c5:	e8 b0 f0 ff ff       	call   80017a <sys_getenvid>
  8010ca:	83 ec 0c             	sub    $0xc,%esp
  8010cd:	ff 75 0c             	pushl  0xc(%ebp)
  8010d0:	ff 75 08             	pushl  0x8(%ebp)
  8010d3:	56                   	push   %esi
  8010d4:	50                   	push   %eax
  8010d5:	68 c4 1f 80 00       	push   $0x801fc4
  8010da:	e8 b1 00 00 00       	call   801190 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010df:	83 c4 18             	add    $0x18,%esp
  8010e2:	53                   	push   %ebx
  8010e3:	ff 75 10             	pushl  0x10(%ebp)
  8010e6:	e8 54 00 00 00       	call   80113f <vcprintf>
	cprintf("\n");
  8010eb:	c7 04 24 af 1f 80 00 	movl   $0x801faf,(%esp)
  8010f2:	e8 99 00 00 00       	call   801190 <cprintf>
  8010f7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010fa:	cc                   	int3   
  8010fb:	eb fd                	jmp    8010fa <_panic+0x43>

008010fd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	53                   	push   %ebx
  801101:	83 ec 04             	sub    $0x4,%esp
  801104:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801107:	8b 13                	mov    (%ebx),%edx
  801109:	8d 42 01             	lea    0x1(%edx),%eax
  80110c:	89 03                	mov    %eax,(%ebx)
  80110e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801111:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801115:	3d ff 00 00 00       	cmp    $0xff,%eax
  80111a:	75 1a                	jne    801136 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	68 ff 00 00 00       	push   $0xff
  801124:	8d 43 08             	lea    0x8(%ebx),%eax
  801127:	50                   	push   %eax
  801128:	e8 cf ef ff ff       	call   8000fc <sys_cputs>
		b->idx = 0;
  80112d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801133:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801136:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80113a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801148:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80114f:	00 00 00 
	b.cnt = 0;
  801152:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801159:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80115c:	ff 75 0c             	pushl  0xc(%ebp)
  80115f:	ff 75 08             	pushl  0x8(%ebp)
  801162:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801168:	50                   	push   %eax
  801169:	68 fd 10 80 00       	push   $0x8010fd
  80116e:	e8 54 01 00 00       	call   8012c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801173:	83 c4 08             	add    $0x8,%esp
  801176:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80117c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801182:	50                   	push   %eax
  801183:	e8 74 ef ff ff       	call   8000fc <sys_cputs>

	return b.cnt;
}
  801188:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80118e:	c9                   	leave  
  80118f:	c3                   	ret    

00801190 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801196:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801199:	50                   	push   %eax
  80119a:	ff 75 08             	pushl  0x8(%ebp)
  80119d:	e8 9d ff ff ff       	call   80113f <vcprintf>
	va_end(ap);

	return cnt;
}
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	57                   	push   %edi
  8011a8:	56                   	push   %esi
  8011a9:	53                   	push   %ebx
  8011aa:	83 ec 1c             	sub    $0x1c,%esp
  8011ad:	89 c7                	mov    %eax,%edi
  8011af:	89 d6                	mov    %edx,%esi
  8011b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8011c8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8011cb:	39 d3                	cmp    %edx,%ebx
  8011cd:	72 05                	jb     8011d4 <printnum+0x30>
  8011cf:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011d2:	77 45                	ja     801219 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011d4:	83 ec 0c             	sub    $0xc,%esp
  8011d7:	ff 75 18             	pushl  0x18(%ebp)
  8011da:	8b 45 14             	mov    0x14(%ebp),%eax
  8011dd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011e0:	53                   	push   %ebx
  8011e1:	ff 75 10             	pushl  0x10(%ebp)
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ed:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f3:	e8 18 0a 00 00       	call   801c10 <__udivdi3>
  8011f8:	83 c4 18             	add    $0x18,%esp
  8011fb:	52                   	push   %edx
  8011fc:	50                   	push   %eax
  8011fd:	89 f2                	mov    %esi,%edx
  8011ff:	89 f8                	mov    %edi,%eax
  801201:	e8 9e ff ff ff       	call   8011a4 <printnum>
  801206:	83 c4 20             	add    $0x20,%esp
  801209:	eb 18                	jmp    801223 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80120b:	83 ec 08             	sub    $0x8,%esp
  80120e:	56                   	push   %esi
  80120f:	ff 75 18             	pushl  0x18(%ebp)
  801212:	ff d7                	call   *%edi
  801214:	83 c4 10             	add    $0x10,%esp
  801217:	eb 03                	jmp    80121c <printnum+0x78>
  801219:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80121c:	83 eb 01             	sub    $0x1,%ebx
  80121f:	85 db                	test   %ebx,%ebx
  801221:	7f e8                	jg     80120b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	56                   	push   %esi
  801227:	83 ec 04             	sub    $0x4,%esp
  80122a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122d:	ff 75 e0             	pushl  -0x20(%ebp)
  801230:	ff 75 dc             	pushl  -0x24(%ebp)
  801233:	ff 75 d8             	pushl  -0x28(%ebp)
  801236:	e8 05 0b 00 00       	call   801d40 <__umoddi3>
  80123b:	83 c4 14             	add    $0x14,%esp
  80123e:	0f be 80 e7 1f 80 00 	movsbl 0x801fe7(%eax),%eax
  801245:	50                   	push   %eax
  801246:	ff d7                	call   *%edi
}
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80124e:	5b                   	pop    %ebx
  80124f:	5e                   	pop    %esi
  801250:	5f                   	pop    %edi
  801251:	5d                   	pop    %ebp
  801252:	c3                   	ret    

00801253 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801256:	83 fa 01             	cmp    $0x1,%edx
  801259:	7e 0e                	jle    801269 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80125b:	8b 10                	mov    (%eax),%edx
  80125d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801260:	89 08                	mov    %ecx,(%eax)
  801262:	8b 02                	mov    (%edx),%eax
  801264:	8b 52 04             	mov    0x4(%edx),%edx
  801267:	eb 22                	jmp    80128b <getuint+0x38>
	else if (lflag)
  801269:	85 d2                	test   %edx,%edx
  80126b:	74 10                	je     80127d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80126d:	8b 10                	mov    (%eax),%edx
  80126f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801272:	89 08                	mov    %ecx,(%eax)
  801274:	8b 02                	mov    (%edx),%eax
  801276:	ba 00 00 00 00       	mov    $0x0,%edx
  80127b:	eb 0e                	jmp    80128b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80127d:	8b 10                	mov    (%eax),%edx
  80127f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801282:	89 08                	mov    %ecx,(%eax)
  801284:	8b 02                	mov    (%edx),%eax
  801286:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801293:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801297:	8b 10                	mov    (%eax),%edx
  801299:	3b 50 04             	cmp    0x4(%eax),%edx
  80129c:	73 0a                	jae    8012a8 <sprintputch+0x1b>
		*b->buf++ = ch;
  80129e:	8d 4a 01             	lea    0x1(%edx),%ecx
  8012a1:	89 08                	mov    %ecx,(%eax)
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a6:	88 02                	mov    %al,(%edx)
}
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8012b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012b3:	50                   	push   %eax
  8012b4:	ff 75 10             	pushl  0x10(%ebp)
  8012b7:	ff 75 0c             	pushl  0xc(%ebp)
  8012ba:	ff 75 08             	pushl  0x8(%ebp)
  8012bd:	e8 05 00 00 00       	call   8012c7 <vprintfmt>
	va_end(ap);
}
  8012c2:	83 c4 10             	add    $0x10,%esp
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    

008012c7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	57                   	push   %edi
  8012cb:	56                   	push   %esi
  8012cc:	53                   	push   %ebx
  8012cd:	83 ec 2c             	sub    $0x2c,%esp
  8012d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012d9:	eb 12                	jmp    8012ed <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	0f 84 89 03 00 00    	je     80166c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012e3:	83 ec 08             	sub    $0x8,%esp
  8012e6:	53                   	push   %ebx
  8012e7:	50                   	push   %eax
  8012e8:	ff d6                	call   *%esi
  8012ea:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012ed:	83 c7 01             	add    $0x1,%edi
  8012f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012f4:	83 f8 25             	cmp    $0x25,%eax
  8012f7:	75 e2                	jne    8012db <vprintfmt+0x14>
  8012f9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012fd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801304:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80130b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801312:	ba 00 00 00 00       	mov    $0x0,%edx
  801317:	eb 07                	jmp    801320 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801319:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80131c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801320:	8d 47 01             	lea    0x1(%edi),%eax
  801323:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801326:	0f b6 07             	movzbl (%edi),%eax
  801329:	0f b6 c8             	movzbl %al,%ecx
  80132c:	83 e8 23             	sub    $0x23,%eax
  80132f:	3c 55                	cmp    $0x55,%al
  801331:	0f 87 1a 03 00 00    	ja     801651 <vprintfmt+0x38a>
  801337:	0f b6 c0             	movzbl %al,%eax
  80133a:	ff 24 85 20 21 80 00 	jmp    *0x802120(,%eax,4)
  801341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801344:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801348:	eb d6                	jmp    801320 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80134d:	b8 00 00 00 00       	mov    $0x0,%eax
  801352:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801355:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801358:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80135c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80135f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801362:	83 fa 09             	cmp    $0x9,%edx
  801365:	77 39                	ja     8013a0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801367:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80136a:	eb e9                	jmp    801355 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80136c:	8b 45 14             	mov    0x14(%ebp),%eax
  80136f:	8d 48 04             	lea    0x4(%eax),%ecx
  801372:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801375:	8b 00                	mov    (%eax),%eax
  801377:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80137d:	eb 27                	jmp    8013a6 <vprintfmt+0xdf>
  80137f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801382:	85 c0                	test   %eax,%eax
  801384:	b9 00 00 00 00       	mov    $0x0,%ecx
  801389:	0f 49 c8             	cmovns %eax,%ecx
  80138c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801392:	eb 8c                	jmp    801320 <vprintfmt+0x59>
  801394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801397:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80139e:	eb 80                	jmp    801320 <vprintfmt+0x59>
  8013a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013a3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8013a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013aa:	0f 89 70 ff ff ff    	jns    801320 <vprintfmt+0x59>
				width = precision, precision = -1;
  8013b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8013b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8013bd:	e9 5e ff ff ff       	jmp    801320 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8013c2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8013c8:	e9 53 ff ff ff       	jmp    801320 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8013cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d0:	8d 50 04             	lea    0x4(%eax),%edx
  8013d3:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d6:	83 ec 08             	sub    $0x8,%esp
  8013d9:	53                   	push   %ebx
  8013da:	ff 30                	pushl  (%eax)
  8013dc:	ff d6                	call   *%esi
			break;
  8013de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013e4:	e9 04 ff ff ff       	jmp    8012ed <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ec:	8d 50 04             	lea    0x4(%eax),%edx
  8013ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f2:	8b 00                	mov    (%eax),%eax
  8013f4:	99                   	cltd   
  8013f5:	31 d0                	xor    %edx,%eax
  8013f7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013f9:	83 f8 0f             	cmp    $0xf,%eax
  8013fc:	7f 0b                	jg     801409 <vprintfmt+0x142>
  8013fe:	8b 14 85 80 22 80 00 	mov    0x802280(,%eax,4),%edx
  801405:	85 d2                	test   %edx,%edx
  801407:	75 18                	jne    801421 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801409:	50                   	push   %eax
  80140a:	68 ff 1f 80 00       	push   $0x801fff
  80140f:	53                   	push   %ebx
  801410:	56                   	push   %esi
  801411:	e8 94 fe ff ff       	call   8012aa <printfmt>
  801416:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80141c:	e9 cc fe ff ff       	jmp    8012ed <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801421:	52                   	push   %edx
  801422:	68 7d 1f 80 00       	push   $0x801f7d
  801427:	53                   	push   %ebx
  801428:	56                   	push   %esi
  801429:	e8 7c fe ff ff       	call   8012aa <printfmt>
  80142e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801434:	e9 b4 fe ff ff       	jmp    8012ed <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801439:	8b 45 14             	mov    0x14(%ebp),%eax
  80143c:	8d 50 04             	lea    0x4(%eax),%edx
  80143f:	89 55 14             	mov    %edx,0x14(%ebp)
  801442:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801444:	85 ff                	test   %edi,%edi
  801446:	b8 f8 1f 80 00       	mov    $0x801ff8,%eax
  80144b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80144e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801452:	0f 8e 94 00 00 00    	jle    8014ec <vprintfmt+0x225>
  801458:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80145c:	0f 84 98 00 00 00    	je     8014fa <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	ff 75 d0             	pushl  -0x30(%ebp)
  801468:	57                   	push   %edi
  801469:	e8 86 02 00 00       	call   8016f4 <strnlen>
  80146e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801471:	29 c1                	sub    %eax,%ecx
  801473:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801476:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801479:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80147d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801480:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801483:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801485:	eb 0f                	jmp    801496 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	53                   	push   %ebx
  80148b:	ff 75 e0             	pushl  -0x20(%ebp)
  80148e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801490:	83 ef 01             	sub    $0x1,%edi
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	85 ff                	test   %edi,%edi
  801498:	7f ed                	jg     801487 <vprintfmt+0x1c0>
  80149a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80149d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8014a0:	85 c9                	test   %ecx,%ecx
  8014a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a7:	0f 49 c1             	cmovns %ecx,%eax
  8014aa:	29 c1                	sub    %eax,%ecx
  8014ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8014af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b5:	89 cb                	mov    %ecx,%ebx
  8014b7:	eb 4d                	jmp    801506 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8014b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014bd:	74 1b                	je     8014da <vprintfmt+0x213>
  8014bf:	0f be c0             	movsbl %al,%eax
  8014c2:	83 e8 20             	sub    $0x20,%eax
  8014c5:	83 f8 5e             	cmp    $0x5e,%eax
  8014c8:	76 10                	jbe    8014da <vprintfmt+0x213>
					putch('?', putdat);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	ff 75 0c             	pushl  0xc(%ebp)
  8014d0:	6a 3f                	push   $0x3f
  8014d2:	ff 55 08             	call   *0x8(%ebp)
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb 0d                	jmp    8014e7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	ff 75 0c             	pushl  0xc(%ebp)
  8014e0:	52                   	push   %edx
  8014e1:	ff 55 08             	call   *0x8(%ebp)
  8014e4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014e7:	83 eb 01             	sub    $0x1,%ebx
  8014ea:	eb 1a                	jmp    801506 <vprintfmt+0x23f>
  8014ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8014ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014f8:	eb 0c                	jmp    801506 <vprintfmt+0x23f>
  8014fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8014fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801500:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801503:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801506:	83 c7 01             	add    $0x1,%edi
  801509:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80150d:	0f be d0             	movsbl %al,%edx
  801510:	85 d2                	test   %edx,%edx
  801512:	74 23                	je     801537 <vprintfmt+0x270>
  801514:	85 f6                	test   %esi,%esi
  801516:	78 a1                	js     8014b9 <vprintfmt+0x1f2>
  801518:	83 ee 01             	sub    $0x1,%esi
  80151b:	79 9c                	jns    8014b9 <vprintfmt+0x1f2>
  80151d:	89 df                	mov    %ebx,%edi
  80151f:	8b 75 08             	mov    0x8(%ebp),%esi
  801522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801525:	eb 18                	jmp    80153f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801527:	83 ec 08             	sub    $0x8,%esp
  80152a:	53                   	push   %ebx
  80152b:	6a 20                	push   $0x20
  80152d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80152f:	83 ef 01             	sub    $0x1,%edi
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	eb 08                	jmp    80153f <vprintfmt+0x278>
  801537:	89 df                	mov    %ebx,%edi
  801539:	8b 75 08             	mov    0x8(%ebp),%esi
  80153c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80153f:	85 ff                	test   %edi,%edi
  801541:	7f e4                	jg     801527 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801543:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801546:	e9 a2 fd ff ff       	jmp    8012ed <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80154b:	83 fa 01             	cmp    $0x1,%edx
  80154e:	7e 16                	jle    801566 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801550:	8b 45 14             	mov    0x14(%ebp),%eax
  801553:	8d 50 08             	lea    0x8(%eax),%edx
  801556:	89 55 14             	mov    %edx,0x14(%ebp)
  801559:	8b 50 04             	mov    0x4(%eax),%edx
  80155c:	8b 00                	mov    (%eax),%eax
  80155e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801561:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801564:	eb 32                	jmp    801598 <vprintfmt+0x2d1>
	else if (lflag)
  801566:	85 d2                	test   %edx,%edx
  801568:	74 18                	je     801582 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80156a:	8b 45 14             	mov    0x14(%ebp),%eax
  80156d:	8d 50 04             	lea    0x4(%eax),%edx
  801570:	89 55 14             	mov    %edx,0x14(%ebp)
  801573:	8b 00                	mov    (%eax),%eax
  801575:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801578:	89 c1                	mov    %eax,%ecx
  80157a:	c1 f9 1f             	sar    $0x1f,%ecx
  80157d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801580:	eb 16                	jmp    801598 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801582:	8b 45 14             	mov    0x14(%ebp),%eax
  801585:	8d 50 04             	lea    0x4(%eax),%edx
  801588:	89 55 14             	mov    %edx,0x14(%ebp)
  80158b:	8b 00                	mov    (%eax),%eax
  80158d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801590:	89 c1                	mov    %eax,%ecx
  801592:	c1 f9 1f             	sar    $0x1f,%ecx
  801595:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801598:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80159b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80159e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8015a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8015a7:	79 74                	jns    80161d <vprintfmt+0x356>
				putch('-', putdat);
  8015a9:	83 ec 08             	sub    $0x8,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	6a 2d                	push   $0x2d
  8015af:	ff d6                	call   *%esi
				num = -(long long) num;
  8015b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8015b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8015b7:	f7 d8                	neg    %eax
  8015b9:	83 d2 00             	adc    $0x0,%edx
  8015bc:	f7 da                	neg    %edx
  8015be:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8015c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8015c6:	eb 55                	jmp    80161d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8015c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8015cb:	e8 83 fc ff ff       	call   801253 <getuint>
			base = 10;
  8015d0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015d5:	eb 46                	jmp    80161d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015da:	e8 74 fc ff ff       	call   801253 <getuint>
			base = 8;
  8015df:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015e4:	eb 37                	jmp    80161d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	53                   	push   %ebx
  8015ea:	6a 30                	push   $0x30
  8015ec:	ff d6                	call   *%esi
			putch('x', putdat);
  8015ee:	83 c4 08             	add    $0x8,%esp
  8015f1:	53                   	push   %ebx
  8015f2:	6a 78                	push   $0x78
  8015f4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f9:	8d 50 04             	lea    0x4(%eax),%edx
  8015fc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015ff:	8b 00                	mov    (%eax),%eax
  801601:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801606:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801609:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80160e:	eb 0d                	jmp    80161d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801610:	8d 45 14             	lea    0x14(%ebp),%eax
  801613:	e8 3b fc ff ff       	call   801253 <getuint>
			base = 16;
  801618:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80161d:	83 ec 0c             	sub    $0xc,%esp
  801620:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801624:	57                   	push   %edi
  801625:	ff 75 e0             	pushl  -0x20(%ebp)
  801628:	51                   	push   %ecx
  801629:	52                   	push   %edx
  80162a:	50                   	push   %eax
  80162b:	89 da                	mov    %ebx,%edx
  80162d:	89 f0                	mov    %esi,%eax
  80162f:	e8 70 fb ff ff       	call   8011a4 <printnum>
			break;
  801634:	83 c4 20             	add    $0x20,%esp
  801637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80163a:	e9 ae fc ff ff       	jmp    8012ed <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	53                   	push   %ebx
  801643:	51                   	push   %ecx
  801644:	ff d6                	call   *%esi
			break;
  801646:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80164c:	e9 9c fc ff ff       	jmp    8012ed <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	53                   	push   %ebx
  801655:	6a 25                	push   $0x25
  801657:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 03                	jmp    801661 <vprintfmt+0x39a>
  80165e:	83 ef 01             	sub    $0x1,%edi
  801661:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801665:	75 f7                	jne    80165e <vprintfmt+0x397>
  801667:	e9 81 fc ff ff       	jmp    8012ed <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80166c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166f:	5b                   	pop    %ebx
  801670:	5e                   	pop    %esi
  801671:	5f                   	pop    %edi
  801672:	5d                   	pop    %ebp
  801673:	c3                   	ret    

00801674 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	83 ec 18             	sub    $0x18,%esp
  80167a:	8b 45 08             	mov    0x8(%ebp),%eax
  80167d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801680:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801683:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801687:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80168a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801691:	85 c0                	test   %eax,%eax
  801693:	74 26                	je     8016bb <vsnprintf+0x47>
  801695:	85 d2                	test   %edx,%edx
  801697:	7e 22                	jle    8016bb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801699:	ff 75 14             	pushl  0x14(%ebp)
  80169c:	ff 75 10             	pushl  0x10(%ebp)
  80169f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a2:	50                   	push   %eax
  8016a3:	68 8d 12 80 00       	push   $0x80128d
  8016a8:	e8 1a fc ff ff       	call   8012c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	eb 05                	jmp    8016c0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    

008016c2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c2:	55                   	push   %ebp
  8016c3:	89 e5                	mov    %esp,%ebp
  8016c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016c8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016cb:	50                   	push   %eax
  8016cc:	ff 75 10             	pushl  0x10(%ebp)
  8016cf:	ff 75 0c             	pushl  0xc(%ebp)
  8016d2:	ff 75 08             	pushl  0x8(%ebp)
  8016d5:	e8 9a ff ff ff       	call   801674 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e7:	eb 03                	jmp    8016ec <strlen+0x10>
		n++;
  8016e9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ec:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f0:	75 f7                	jne    8016e9 <strlen+0xd>
		n++;
	return n;
}
  8016f2:	5d                   	pop    %ebp
  8016f3:	c3                   	ret    

008016f4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801702:	eb 03                	jmp    801707 <strnlen+0x13>
		n++;
  801704:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801707:	39 c2                	cmp    %eax,%edx
  801709:	74 08                	je     801713 <strnlen+0x1f>
  80170b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80170f:	75 f3                	jne    801704 <strnlen+0x10>
  801711:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	53                   	push   %ebx
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80171f:	89 c2                	mov    %eax,%edx
  801721:	83 c2 01             	add    $0x1,%edx
  801724:	83 c1 01             	add    $0x1,%ecx
  801727:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80172b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80172e:	84 db                	test   %bl,%bl
  801730:	75 ef                	jne    801721 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801732:	5b                   	pop    %ebx
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    

00801735 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	53                   	push   %ebx
  801739:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80173c:	53                   	push   %ebx
  80173d:	e8 9a ff ff ff       	call   8016dc <strlen>
  801742:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801745:	ff 75 0c             	pushl  0xc(%ebp)
  801748:	01 d8                	add    %ebx,%eax
  80174a:	50                   	push   %eax
  80174b:	e8 c5 ff ff ff       	call   801715 <strcpy>
	return dst;
}
  801750:	89 d8                	mov    %ebx,%eax
  801752:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801755:	c9                   	leave  
  801756:	c3                   	ret    

00801757 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801757:	55                   	push   %ebp
  801758:	89 e5                	mov    %esp,%ebp
  80175a:	56                   	push   %esi
  80175b:	53                   	push   %ebx
  80175c:	8b 75 08             	mov    0x8(%ebp),%esi
  80175f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801762:	89 f3                	mov    %esi,%ebx
  801764:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801767:	89 f2                	mov    %esi,%edx
  801769:	eb 0f                	jmp    80177a <strncpy+0x23>
		*dst++ = *src;
  80176b:	83 c2 01             	add    $0x1,%edx
  80176e:	0f b6 01             	movzbl (%ecx),%eax
  801771:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801774:	80 39 01             	cmpb   $0x1,(%ecx)
  801777:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80177a:	39 da                	cmp    %ebx,%edx
  80177c:	75 ed                	jne    80176b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80177e:	89 f0                	mov    %esi,%eax
  801780:	5b                   	pop    %ebx
  801781:	5e                   	pop    %esi
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	56                   	push   %esi
  801788:	53                   	push   %ebx
  801789:	8b 75 08             	mov    0x8(%ebp),%esi
  80178c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80178f:	8b 55 10             	mov    0x10(%ebp),%edx
  801792:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801794:	85 d2                	test   %edx,%edx
  801796:	74 21                	je     8017b9 <strlcpy+0x35>
  801798:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80179c:	89 f2                	mov    %esi,%edx
  80179e:	eb 09                	jmp    8017a9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a0:	83 c2 01             	add    $0x1,%edx
  8017a3:	83 c1 01             	add    $0x1,%ecx
  8017a6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017a9:	39 c2                	cmp    %eax,%edx
  8017ab:	74 09                	je     8017b6 <strlcpy+0x32>
  8017ad:	0f b6 19             	movzbl (%ecx),%ebx
  8017b0:	84 db                	test   %bl,%bl
  8017b2:	75 ec                	jne    8017a0 <strlcpy+0x1c>
  8017b4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017b6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017b9:	29 f0                	sub    %esi,%eax
}
  8017bb:	5b                   	pop    %ebx
  8017bc:	5e                   	pop    %esi
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017c8:	eb 06                	jmp    8017d0 <strcmp+0x11>
		p++, q++;
  8017ca:	83 c1 01             	add    $0x1,%ecx
  8017cd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017d0:	0f b6 01             	movzbl (%ecx),%eax
  8017d3:	84 c0                	test   %al,%al
  8017d5:	74 04                	je     8017db <strcmp+0x1c>
  8017d7:	3a 02                	cmp    (%edx),%al
  8017d9:	74 ef                	je     8017ca <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017db:	0f b6 c0             	movzbl %al,%eax
  8017de:	0f b6 12             	movzbl (%edx),%edx
  8017e1:	29 d0                	sub    %edx,%eax
}
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	53                   	push   %ebx
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ef:	89 c3                	mov    %eax,%ebx
  8017f1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017f4:	eb 06                	jmp    8017fc <strncmp+0x17>
		n--, p++, q++;
  8017f6:	83 c0 01             	add    $0x1,%eax
  8017f9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017fc:	39 d8                	cmp    %ebx,%eax
  8017fe:	74 15                	je     801815 <strncmp+0x30>
  801800:	0f b6 08             	movzbl (%eax),%ecx
  801803:	84 c9                	test   %cl,%cl
  801805:	74 04                	je     80180b <strncmp+0x26>
  801807:	3a 0a                	cmp    (%edx),%cl
  801809:	74 eb                	je     8017f6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80180b:	0f b6 00             	movzbl (%eax),%eax
  80180e:	0f b6 12             	movzbl (%edx),%edx
  801811:	29 d0                	sub    %edx,%eax
  801813:	eb 05                	jmp    80181a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801815:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80181a:	5b                   	pop    %ebx
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801827:	eb 07                	jmp    801830 <strchr+0x13>
		if (*s == c)
  801829:	38 ca                	cmp    %cl,%dl
  80182b:	74 0f                	je     80183c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80182d:	83 c0 01             	add    $0x1,%eax
  801830:	0f b6 10             	movzbl (%eax),%edx
  801833:	84 d2                	test   %dl,%dl
  801835:	75 f2                	jne    801829 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801837:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	8b 45 08             	mov    0x8(%ebp),%eax
  801844:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801848:	eb 03                	jmp    80184d <strfind+0xf>
  80184a:	83 c0 01             	add    $0x1,%eax
  80184d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801850:	38 ca                	cmp    %cl,%dl
  801852:	74 04                	je     801858 <strfind+0x1a>
  801854:	84 d2                	test   %dl,%dl
  801856:	75 f2                	jne    80184a <strfind+0xc>
			break;
	return (char *) s;
}
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	57                   	push   %edi
  80185e:	56                   	push   %esi
  80185f:	53                   	push   %ebx
  801860:	8b 7d 08             	mov    0x8(%ebp),%edi
  801863:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801866:	85 c9                	test   %ecx,%ecx
  801868:	74 36                	je     8018a0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80186a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801870:	75 28                	jne    80189a <memset+0x40>
  801872:	f6 c1 03             	test   $0x3,%cl
  801875:	75 23                	jne    80189a <memset+0x40>
		c &= 0xFF;
  801877:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80187b:	89 d3                	mov    %edx,%ebx
  80187d:	c1 e3 08             	shl    $0x8,%ebx
  801880:	89 d6                	mov    %edx,%esi
  801882:	c1 e6 18             	shl    $0x18,%esi
  801885:	89 d0                	mov    %edx,%eax
  801887:	c1 e0 10             	shl    $0x10,%eax
  80188a:	09 f0                	or     %esi,%eax
  80188c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80188e:	89 d8                	mov    %ebx,%eax
  801890:	09 d0                	or     %edx,%eax
  801892:	c1 e9 02             	shr    $0x2,%ecx
  801895:	fc                   	cld    
  801896:	f3 ab                	rep stos %eax,%es:(%edi)
  801898:	eb 06                	jmp    8018a0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80189a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189d:	fc                   	cld    
  80189e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a0:	89 f8                	mov    %edi,%eax
  8018a2:	5b                   	pop    %ebx
  8018a3:	5e                   	pop    %esi
  8018a4:	5f                   	pop    %edi
  8018a5:	5d                   	pop    %ebp
  8018a6:	c3                   	ret    

008018a7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	57                   	push   %edi
  8018ab:	56                   	push   %esi
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8018af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018b5:	39 c6                	cmp    %eax,%esi
  8018b7:	73 35                	jae    8018ee <memmove+0x47>
  8018b9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018bc:	39 d0                	cmp    %edx,%eax
  8018be:	73 2e                	jae    8018ee <memmove+0x47>
		s += n;
		d += n;
  8018c0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c3:	89 d6                	mov    %edx,%esi
  8018c5:	09 fe                	or     %edi,%esi
  8018c7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018cd:	75 13                	jne    8018e2 <memmove+0x3b>
  8018cf:	f6 c1 03             	test   $0x3,%cl
  8018d2:	75 0e                	jne    8018e2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018d4:	83 ef 04             	sub    $0x4,%edi
  8018d7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018da:	c1 e9 02             	shr    $0x2,%ecx
  8018dd:	fd                   	std    
  8018de:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e0:	eb 09                	jmp    8018eb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018e2:	83 ef 01             	sub    $0x1,%edi
  8018e5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018e8:	fd                   	std    
  8018e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018eb:	fc                   	cld    
  8018ec:	eb 1d                	jmp    80190b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ee:	89 f2                	mov    %esi,%edx
  8018f0:	09 c2                	or     %eax,%edx
  8018f2:	f6 c2 03             	test   $0x3,%dl
  8018f5:	75 0f                	jne    801906 <memmove+0x5f>
  8018f7:	f6 c1 03             	test   $0x3,%cl
  8018fa:	75 0a                	jne    801906 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018fc:	c1 e9 02             	shr    $0x2,%ecx
  8018ff:	89 c7                	mov    %eax,%edi
  801901:	fc                   	cld    
  801902:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801904:	eb 05                	jmp    80190b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801906:	89 c7                	mov    %eax,%edi
  801908:	fc                   	cld    
  801909:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80190b:	5e                   	pop    %esi
  80190c:	5f                   	pop    %edi
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801912:	ff 75 10             	pushl  0x10(%ebp)
  801915:	ff 75 0c             	pushl  0xc(%ebp)
  801918:	ff 75 08             	pushl  0x8(%ebp)
  80191b:	e8 87 ff ff ff       	call   8018a7 <memmove>
}
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	56                   	push   %esi
  801926:	53                   	push   %ebx
  801927:	8b 45 08             	mov    0x8(%ebp),%eax
  80192a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192d:	89 c6                	mov    %eax,%esi
  80192f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801932:	eb 1a                	jmp    80194e <memcmp+0x2c>
		if (*s1 != *s2)
  801934:	0f b6 08             	movzbl (%eax),%ecx
  801937:	0f b6 1a             	movzbl (%edx),%ebx
  80193a:	38 d9                	cmp    %bl,%cl
  80193c:	74 0a                	je     801948 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80193e:	0f b6 c1             	movzbl %cl,%eax
  801941:	0f b6 db             	movzbl %bl,%ebx
  801944:	29 d8                	sub    %ebx,%eax
  801946:	eb 0f                	jmp    801957 <memcmp+0x35>
		s1++, s2++;
  801948:	83 c0 01             	add    $0x1,%eax
  80194b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80194e:	39 f0                	cmp    %esi,%eax
  801950:	75 e2                	jne    801934 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801952:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801957:	5b                   	pop    %ebx
  801958:	5e                   	pop    %esi
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	53                   	push   %ebx
  80195f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801962:	89 c1                	mov    %eax,%ecx
  801964:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801967:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196b:	eb 0a                	jmp    801977 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80196d:	0f b6 10             	movzbl (%eax),%edx
  801970:	39 da                	cmp    %ebx,%edx
  801972:	74 07                	je     80197b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801974:	83 c0 01             	add    $0x1,%eax
  801977:	39 c8                	cmp    %ecx,%eax
  801979:	72 f2                	jb     80196d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80197b:	5b                   	pop    %ebx
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    

0080197e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	57                   	push   %edi
  801982:	56                   	push   %esi
  801983:	53                   	push   %ebx
  801984:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801987:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198a:	eb 03                	jmp    80198f <strtol+0x11>
		s++;
  80198c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198f:	0f b6 01             	movzbl (%ecx),%eax
  801992:	3c 20                	cmp    $0x20,%al
  801994:	74 f6                	je     80198c <strtol+0xe>
  801996:	3c 09                	cmp    $0x9,%al
  801998:	74 f2                	je     80198c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80199a:	3c 2b                	cmp    $0x2b,%al
  80199c:	75 0a                	jne    8019a8 <strtol+0x2a>
		s++;
  80199e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a1:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a6:	eb 11                	jmp    8019b9 <strtol+0x3b>
  8019a8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019ad:	3c 2d                	cmp    $0x2d,%al
  8019af:	75 08                	jne    8019b9 <strtol+0x3b>
		s++, neg = 1;
  8019b1:	83 c1 01             	add    $0x1,%ecx
  8019b4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019bf:	75 15                	jne    8019d6 <strtol+0x58>
  8019c1:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c4:	75 10                	jne    8019d6 <strtol+0x58>
  8019c6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ca:	75 7c                	jne    801a48 <strtol+0xca>
		s += 2, base = 16;
  8019cc:	83 c1 02             	add    $0x2,%ecx
  8019cf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d4:	eb 16                	jmp    8019ec <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019d6:	85 db                	test   %ebx,%ebx
  8019d8:	75 12                	jne    8019ec <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019da:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019df:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e2:	75 08                	jne    8019ec <strtol+0x6e>
		s++, base = 8;
  8019e4:	83 c1 01             	add    $0x1,%ecx
  8019e7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019f4:	0f b6 11             	movzbl (%ecx),%edx
  8019f7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019fa:	89 f3                	mov    %esi,%ebx
  8019fc:	80 fb 09             	cmp    $0x9,%bl
  8019ff:	77 08                	ja     801a09 <strtol+0x8b>
			dig = *s - '0';
  801a01:	0f be d2             	movsbl %dl,%edx
  801a04:	83 ea 30             	sub    $0x30,%edx
  801a07:	eb 22                	jmp    801a2b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a09:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a0c:	89 f3                	mov    %esi,%ebx
  801a0e:	80 fb 19             	cmp    $0x19,%bl
  801a11:	77 08                	ja     801a1b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a13:	0f be d2             	movsbl %dl,%edx
  801a16:	83 ea 57             	sub    $0x57,%edx
  801a19:	eb 10                	jmp    801a2b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a1b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a1e:	89 f3                	mov    %esi,%ebx
  801a20:	80 fb 19             	cmp    $0x19,%bl
  801a23:	77 16                	ja     801a3b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a25:	0f be d2             	movsbl %dl,%edx
  801a28:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a2e:	7d 0b                	jge    801a3b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a30:	83 c1 01             	add    $0x1,%ecx
  801a33:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a37:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a39:	eb b9                	jmp    8019f4 <strtol+0x76>

	if (endptr)
  801a3b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a3f:	74 0d                	je     801a4e <strtol+0xd0>
		*endptr = (char *) s;
  801a41:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a44:	89 0e                	mov    %ecx,(%esi)
  801a46:	eb 06                	jmp    801a4e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a48:	85 db                	test   %ebx,%ebx
  801a4a:	74 98                	je     8019e4 <strtol+0x66>
  801a4c:	eb 9e                	jmp    8019ec <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a4e:	89 c2                	mov    %eax,%edx
  801a50:	f7 da                	neg    %edx
  801a52:	85 ff                	test   %edi,%edi
  801a54:	0f 45 c2             	cmovne %edx,%eax
}
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5f                   	pop    %edi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a62:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a69:	75 2a                	jne    801a95 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801a6b:	83 ec 04             	sub    $0x4,%esp
  801a6e:	6a 07                	push   $0x7
  801a70:	68 00 f0 bf ee       	push   $0xeebff000
  801a75:	6a 00                	push   $0x0
  801a77:	e8 3c e7 ff ff       	call   8001b8 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	85 c0                	test   %eax,%eax
  801a81:	79 12                	jns    801a95 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801a83:	50                   	push   %eax
  801a84:	68 e0 22 80 00       	push   $0x8022e0
  801a89:	6a 23                	push   $0x23
  801a8b:	68 e4 22 80 00       	push   $0x8022e4
  801a90:	e8 22 f6 ff ff       	call   8010b7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a95:	8b 45 08             	mov    0x8(%ebp),%eax
  801a98:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801a9d:	83 ec 08             	sub    $0x8,%esp
  801aa0:	68 a9 03 80 00       	push   $0x8003a9
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 57 e8 ff ff       	call   800303 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	79 12                	jns    801ac5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801ab3:	50                   	push   %eax
  801ab4:	68 e0 22 80 00       	push   $0x8022e0
  801ab9:	6a 2c                	push   $0x2c
  801abb:	68 e4 22 80 00       	push   $0x8022e4
  801ac0:	e8 f2 f5 ff ff       	call   8010b7 <_panic>
	}
}
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	8b 75 08             	mov    0x8(%ebp),%esi
  801acf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	75 12                	jne    801aeb <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	68 00 00 c0 ee       	push   $0xeec00000
  801ae1:	e8 82 e8 ff ff       	call   800368 <sys_ipc_recv>
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	eb 0c                	jmp    801af7 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801aeb:	83 ec 0c             	sub    $0xc,%esp
  801aee:	50                   	push   %eax
  801aef:	e8 74 e8 ff ff       	call   800368 <sys_ipc_recv>
  801af4:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801af7:	85 f6                	test   %esi,%esi
  801af9:	0f 95 c1             	setne  %cl
  801afc:	85 db                	test   %ebx,%ebx
  801afe:	0f 95 c2             	setne  %dl
  801b01:	84 d1                	test   %dl,%cl
  801b03:	74 09                	je     801b0e <ipc_recv+0x47>
  801b05:	89 c2                	mov    %eax,%edx
  801b07:	c1 ea 1f             	shr    $0x1f,%edx
  801b0a:	84 d2                	test   %dl,%dl
  801b0c:	75 24                	jne    801b32 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801b0e:	85 f6                	test   %esi,%esi
  801b10:	74 0a                	je     801b1c <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801b12:	a1 04 40 80 00       	mov    0x804004,%eax
  801b17:	8b 40 74             	mov    0x74(%eax),%eax
  801b1a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801b1c:	85 db                	test   %ebx,%ebx
  801b1e:	74 0a                	je     801b2a <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801b20:	a1 04 40 80 00       	mov    0x804004,%eax
  801b25:	8b 40 78             	mov    0x78(%eax),%eax
  801b28:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b35:	5b                   	pop    %ebx
  801b36:	5e                   	pop    %esi
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	57                   	push   %edi
  801b3d:	56                   	push   %esi
  801b3e:	53                   	push   %ebx
  801b3f:	83 ec 0c             	sub    $0xc,%esp
  801b42:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b45:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801b4b:	85 db                	test   %ebx,%ebx
  801b4d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b52:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b55:	ff 75 14             	pushl  0x14(%ebp)
  801b58:	53                   	push   %ebx
  801b59:	56                   	push   %esi
  801b5a:	57                   	push   %edi
  801b5b:	e8 e5 e7 ff ff       	call   800345 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801b60:	89 c2                	mov    %eax,%edx
  801b62:	c1 ea 1f             	shr    $0x1f,%edx
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	84 d2                	test   %dl,%dl
  801b6a:	74 17                	je     801b83 <ipc_send+0x4a>
  801b6c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b6f:	74 12                	je     801b83 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801b71:	50                   	push   %eax
  801b72:	68 f2 22 80 00       	push   $0x8022f2
  801b77:	6a 47                	push   $0x47
  801b79:	68 00 23 80 00       	push   $0x802300
  801b7e:	e8 34 f5 ff ff       	call   8010b7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b83:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b86:	75 07                	jne    801b8f <ipc_send+0x56>
			sys_yield();
  801b88:	e8 0c e6 ff ff       	call   800199 <sys_yield>
  801b8d:	eb c6                	jmp    801b55 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	75 c2                	jne    801b55 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b96:	5b                   	pop    %ebx
  801b97:	5e                   	pop    %esi
  801b98:	5f                   	pop    %edi
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ba6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ba9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801baf:	8b 52 50             	mov    0x50(%edx),%edx
  801bb2:	39 ca                	cmp    %ecx,%edx
  801bb4:	75 0d                	jne    801bc3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801bb6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bb9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bbe:	8b 40 48             	mov    0x48(%eax),%eax
  801bc1:	eb 0f                	jmp    801bd2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bc3:	83 c0 01             	add    $0x1,%eax
  801bc6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bcb:	75 d9                	jne    801ba6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bda:	89 d0                	mov    %edx,%eax
  801bdc:	c1 e8 16             	shr    $0x16,%eax
  801bdf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801beb:	f6 c1 01             	test   $0x1,%cl
  801bee:	74 1d                	je     801c0d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bf0:	c1 ea 0c             	shr    $0xc,%edx
  801bf3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bfa:	f6 c2 01             	test   $0x1,%dl
  801bfd:	74 0e                	je     801c0d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bff:	c1 ea 0c             	shr    $0xc,%edx
  801c02:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c09:	ef 
  801c0a:	0f b7 c0             	movzwl %ax,%eax
}
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    
  801c0f:	90                   	nop

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
