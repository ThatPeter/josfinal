
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 ad 00 00 00       	call   8000f2 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	57                   	push   %edi
  80004e:	56                   	push   %esi
  80004f:	53                   	push   %ebx
  800050:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800053:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  80005a:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80005d:	e8 0e 01 00 00       	call   800170 <sys_getenvid>
  800062:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800068:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80006d:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800072:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800077:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80007a:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800080:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800083:	39 c8                	cmp    %ecx,%eax
  800085:	0f 44 fb             	cmove  %ebx,%edi
  800088:	b9 01 00 00 00       	mov    $0x1,%ecx
  80008d:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800090:	83 c2 01             	add    $0x1,%edx
  800093:	83 c3 7c             	add    $0x7c,%ebx
  800096:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80009c:	75 d9                	jne    800077 <libmain+0x2d>
  80009e:	89 f0                	mov    %esi,%eax
  8000a0:	84 c0                	test   %al,%al
  8000a2:	74 06                	je     8000aa <libmain+0x60>
  8000a4:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000aa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000ae:	7e 0a                	jle    8000ba <libmain+0x70>
		binaryname = argv[0];
  8000b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b3:	8b 00                	mov    (%eax),%eax
  8000b5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	ff 75 0c             	pushl  0xc(%ebp)
  8000c0:	ff 75 08             	pushl  0x8(%ebp)
  8000c3:	e8 6b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c8:	e8 0b 00 00 00       	call   8000d8 <exit>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000de:	e8 87 04 00 00       	call   80056a <close_all>
	sys_env_destroy(0);
  8000e3:	83 ec 0c             	sub    $0xc,%esp
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 42 00 00 00       	call   80012f <sys_env_destroy>
}
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	57                   	push   %edi
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	89 c3                	mov    %eax,%ebx
  800105:	89 c7                	mov    %eax,%edi
  800107:	89 c6                	mov    %eax,%esi
  800109:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	5f                   	pop    %edi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <sys_cgetc>:

int
sys_cgetc(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 01 00 00 00       	mov    $0x1,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
  800135:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013d:	b8 03 00 00 00       	mov    $0x3,%eax
  800142:	8b 55 08             	mov    0x8(%ebp),%edx
  800145:	89 cb                	mov    %ecx,%ebx
  800147:	89 cf                	mov    %ecx,%edi
  800149:	89 ce                	mov    %ecx,%esi
  80014b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80014d:	85 c0                	test   %eax,%eax
  80014f:	7e 17                	jle    800168 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	50                   	push   %eax
  800155:	6a 03                	push   $0x3
  800157:	68 2a 1e 80 00       	push   $0x801e2a
  80015c:	6a 23                	push   $0x23
  80015e:	68 47 1e 80 00       	push   $0x801e47
  800163:	e8 21 0f 00 00       	call   801089 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800168:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800176:	ba 00 00 00 00       	mov    $0x0,%edx
  80017b:	b8 02 00 00 00       	mov    $0x2,%eax
  800180:	89 d1                	mov    %edx,%ecx
  800182:	89 d3                	mov    %edx,%ebx
  800184:	89 d7                	mov    %edx,%edi
  800186:	89 d6                	mov    %edx,%esi
  800188:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80018a:	5b                   	pop    %ebx
  80018b:	5e                   	pop    %esi
  80018c:	5f                   	pop    %edi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    

0080018f <sys_yield>:

void
sys_yield(void)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	57                   	push   %edi
  800193:	56                   	push   %esi
  800194:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800195:	ba 00 00 00 00       	mov    $0x0,%edx
  80019a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80019f:	89 d1                	mov    %edx,%ecx
  8001a1:	89 d3                	mov    %edx,%ebx
  8001a3:	89 d7                	mov    %edx,%edi
  8001a5:	89 d6                	mov    %edx,%esi
  8001a7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a9:	5b                   	pop    %ebx
  8001aa:	5e                   	pop    %esi
  8001ab:	5f                   	pop    %edi
  8001ac:	5d                   	pop    %ebp
  8001ad:	c3                   	ret    

008001ae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	57                   	push   %edi
  8001b2:	56                   	push   %esi
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b7:	be 00 00 00 00       	mov    $0x0,%esi
  8001bc:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	89 f7                	mov    %esi,%edi
  8001cc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	7e 17                	jle    8001e9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d2:	83 ec 0c             	sub    $0xc,%esp
  8001d5:	50                   	push   %eax
  8001d6:	6a 04                	push   $0x4
  8001d8:	68 2a 1e 80 00       	push   $0x801e2a
  8001dd:	6a 23                	push   $0x23
  8001df:	68 47 1e 80 00       	push   $0x801e47
  8001e4:	e8 a0 0e 00 00       	call   801089 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ec:	5b                   	pop    %ebx
  8001ed:	5e                   	pop    %esi
  8001ee:	5f                   	pop    %edi
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    

008001f1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	57                   	push   %edi
  8001f5:	56                   	push   %esi
  8001f6:	53                   	push   %ebx
  8001f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800202:	8b 55 08             	mov    0x8(%ebp),%edx
  800205:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800208:	8b 7d 14             	mov    0x14(%ebp),%edi
  80020b:	8b 75 18             	mov    0x18(%ebp),%esi
  80020e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800210:	85 c0                	test   %eax,%eax
  800212:	7e 17                	jle    80022b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	50                   	push   %eax
  800218:	6a 05                	push   $0x5
  80021a:	68 2a 1e 80 00       	push   $0x801e2a
  80021f:	6a 23                	push   $0x23
  800221:	68 47 1e 80 00       	push   $0x801e47
  800226:	e8 5e 0e 00 00       	call   801089 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80022b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022e:	5b                   	pop    %ebx
  80022f:	5e                   	pop    %esi
  800230:	5f                   	pop    %edi
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800241:	b8 06 00 00 00       	mov    $0x6,%eax
  800246:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800249:	8b 55 08             	mov    0x8(%ebp),%edx
  80024c:	89 df                	mov    %ebx,%edi
  80024e:	89 de                	mov    %ebx,%esi
  800250:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800252:	85 c0                	test   %eax,%eax
  800254:	7e 17                	jle    80026d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800256:	83 ec 0c             	sub    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	6a 06                	push   $0x6
  80025c:	68 2a 1e 80 00       	push   $0x801e2a
  800261:	6a 23                	push   $0x23
  800263:	68 47 1e 80 00       	push   $0x801e47
  800268:	e8 1c 0e 00 00       	call   801089 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800270:	5b                   	pop    %ebx
  800271:	5e                   	pop    %esi
  800272:	5f                   	pop    %edi
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    

00800275 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	57                   	push   %edi
  800279:	56                   	push   %esi
  80027a:	53                   	push   %ebx
  80027b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800283:	b8 08 00 00 00       	mov    $0x8,%eax
  800288:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028b:	8b 55 08             	mov    0x8(%ebp),%edx
  80028e:	89 df                	mov    %ebx,%edi
  800290:	89 de                	mov    %ebx,%esi
  800292:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800294:	85 c0                	test   %eax,%eax
  800296:	7e 17                	jle    8002af <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800298:	83 ec 0c             	sub    $0xc,%esp
  80029b:	50                   	push   %eax
  80029c:	6a 08                	push   $0x8
  80029e:	68 2a 1e 80 00       	push   $0x801e2a
  8002a3:	6a 23                	push   $0x23
  8002a5:	68 47 1e 80 00       	push   $0x801e47
  8002aa:	e8 da 0d 00 00       	call   801089 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b2:	5b                   	pop    %ebx
  8002b3:	5e                   	pop    %esi
  8002b4:	5f                   	pop    %edi
  8002b5:	5d                   	pop    %ebp
  8002b6:	c3                   	ret    

008002b7 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	57                   	push   %edi
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
  8002bd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c5:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d0:	89 df                	mov    %ebx,%edi
  8002d2:	89 de                	mov    %ebx,%esi
  8002d4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d6:	85 c0                	test   %eax,%eax
  8002d8:	7e 17                	jle    8002f1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002da:	83 ec 0c             	sub    $0xc,%esp
  8002dd:	50                   	push   %eax
  8002de:	6a 09                	push   $0x9
  8002e0:	68 2a 1e 80 00       	push   $0x801e2a
  8002e5:	6a 23                	push   $0x23
  8002e7:	68 47 1e 80 00       	push   $0x801e47
  8002ec:	e8 98 0d 00 00       	call   801089 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5f                   	pop    %edi
  8002f7:	5d                   	pop    %ebp
  8002f8:	c3                   	ret    

008002f9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	57                   	push   %edi
  8002fd:	56                   	push   %esi
  8002fe:	53                   	push   %ebx
  8002ff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800302:	bb 00 00 00 00       	mov    $0x0,%ebx
  800307:	b8 0a 00 00 00       	mov    $0xa,%eax
  80030c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030f:	8b 55 08             	mov    0x8(%ebp),%edx
  800312:	89 df                	mov    %ebx,%edi
  800314:	89 de                	mov    %ebx,%esi
  800316:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800318:	85 c0                	test   %eax,%eax
  80031a:	7e 17                	jle    800333 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80031c:	83 ec 0c             	sub    $0xc,%esp
  80031f:	50                   	push   %eax
  800320:	6a 0a                	push   $0xa
  800322:	68 2a 1e 80 00       	push   $0x801e2a
  800327:	6a 23                	push   $0x23
  800329:	68 47 1e 80 00       	push   $0x801e47
  80032e:	e8 56 0d 00 00       	call   801089 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800333:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800336:	5b                   	pop    %ebx
  800337:	5e                   	pop    %esi
  800338:	5f                   	pop    %edi
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	57                   	push   %edi
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800341:	be 00 00 00 00       	mov    $0x0,%esi
  800346:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034e:	8b 55 08             	mov    0x8(%ebp),%edx
  800351:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800354:	8b 7d 14             	mov    0x14(%ebp),%edi
  800357:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800359:	5b                   	pop    %ebx
  80035a:	5e                   	pop    %esi
  80035b:	5f                   	pop    %edi
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    

0080035e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80035e:	55                   	push   %ebp
  80035f:	89 e5                	mov    %esp,%ebp
  800361:	57                   	push   %edi
  800362:	56                   	push   %esi
  800363:	53                   	push   %ebx
  800364:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800367:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800371:	8b 55 08             	mov    0x8(%ebp),%edx
  800374:	89 cb                	mov    %ecx,%ebx
  800376:	89 cf                	mov    %ecx,%edi
  800378:	89 ce                	mov    %ecx,%esi
  80037a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80037c:	85 c0                	test   %eax,%eax
  80037e:	7e 17                	jle    800397 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800380:	83 ec 0c             	sub    $0xc,%esp
  800383:	50                   	push   %eax
  800384:	6a 0d                	push   $0xd
  800386:	68 2a 1e 80 00       	push   $0x801e2a
  80038b:	6a 23                	push   $0x23
  80038d:	68 47 1e 80 00       	push   $0x801e47
  800392:	e8 f2 0c 00 00       	call   801089 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800397:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039a:	5b                   	pop    %ebx
  80039b:	5e                   	pop    %esi
  80039c:	5f                   	pop    %edi
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a5:	05 00 00 00 30       	add    $0x30000000,%eax
  8003aa:	c1 e8 0c             	shr    $0xc,%eax
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b5:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003bf:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003cc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d1:	89 c2                	mov    %eax,%edx
  8003d3:	c1 ea 16             	shr    $0x16,%edx
  8003d6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dd:	f6 c2 01             	test   $0x1,%dl
  8003e0:	74 11                	je     8003f3 <fd_alloc+0x2d>
  8003e2:	89 c2                	mov    %eax,%edx
  8003e4:	c1 ea 0c             	shr    $0xc,%edx
  8003e7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ee:	f6 c2 01             	test   $0x1,%dl
  8003f1:	75 09                	jne    8003fc <fd_alloc+0x36>
			*fd_store = fd;
  8003f3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fa:	eb 17                	jmp    800413 <fd_alloc+0x4d>
  8003fc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800401:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800406:	75 c9                	jne    8003d1 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800408:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80040e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800413:	5d                   	pop    %ebp
  800414:	c3                   	ret    

00800415 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80041b:	83 f8 1f             	cmp    $0x1f,%eax
  80041e:	77 36                	ja     800456 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800420:	c1 e0 0c             	shl    $0xc,%eax
  800423:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800428:	89 c2                	mov    %eax,%edx
  80042a:	c1 ea 16             	shr    $0x16,%edx
  80042d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800434:	f6 c2 01             	test   $0x1,%dl
  800437:	74 24                	je     80045d <fd_lookup+0x48>
  800439:	89 c2                	mov    %eax,%edx
  80043b:	c1 ea 0c             	shr    $0xc,%edx
  80043e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800445:	f6 c2 01             	test   $0x1,%dl
  800448:	74 1a                	je     800464 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80044a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044d:	89 02                	mov    %eax,(%edx)
	return 0;
  80044f:	b8 00 00 00 00       	mov    $0x0,%eax
  800454:	eb 13                	jmp    800469 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045b:	eb 0c                	jmp    800469 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800462:	eb 05                	jmp    800469 <fd_lookup+0x54>
  800464:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800469:	5d                   	pop    %ebp
  80046a:	c3                   	ret    

0080046b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800474:	ba d4 1e 80 00       	mov    $0x801ed4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800479:	eb 13                	jmp    80048e <dev_lookup+0x23>
  80047b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80047e:	39 08                	cmp    %ecx,(%eax)
  800480:	75 0c                	jne    80048e <dev_lookup+0x23>
			*dev = devtab[i];
  800482:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800485:	89 01                	mov    %eax,(%ecx)
			return 0;
  800487:	b8 00 00 00 00       	mov    $0x0,%eax
  80048c:	eb 2e                	jmp    8004bc <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80048e:	8b 02                	mov    (%edx),%eax
  800490:	85 c0                	test   %eax,%eax
  800492:	75 e7                	jne    80047b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800494:	a1 04 40 80 00       	mov    0x804004,%eax
  800499:	8b 40 48             	mov    0x48(%eax),%eax
  80049c:	83 ec 04             	sub    $0x4,%esp
  80049f:	51                   	push   %ecx
  8004a0:	50                   	push   %eax
  8004a1:	68 58 1e 80 00       	push   $0x801e58
  8004a6:	e8 b7 0c 00 00       	call   801162 <cprintf>
	*dev = 0;
  8004ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004bc:	c9                   	leave  
  8004bd:	c3                   	ret    

008004be <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	56                   	push   %esi
  8004c2:	53                   	push   %ebx
  8004c3:	83 ec 10             	sub    $0x10,%esp
  8004c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004cf:	50                   	push   %eax
  8004d0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004d6:	c1 e8 0c             	shr    $0xc,%eax
  8004d9:	50                   	push   %eax
  8004da:	e8 36 ff ff ff       	call   800415 <fd_lookup>
  8004df:	83 c4 08             	add    $0x8,%esp
  8004e2:	85 c0                	test   %eax,%eax
  8004e4:	78 05                	js     8004eb <fd_close+0x2d>
	    || fd != fd2)
  8004e6:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e9:	74 0c                	je     8004f7 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004eb:	84 db                	test   %bl,%bl
  8004ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f2:	0f 44 c2             	cmove  %edx,%eax
  8004f5:	eb 41                	jmp    800538 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f7:	83 ec 08             	sub    $0x8,%esp
  8004fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 36                	pushl  (%esi)
  800500:	e8 66 ff ff ff       	call   80046b <dev_lookup>
  800505:	89 c3                	mov    %eax,%ebx
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	85 c0                	test   %eax,%eax
  80050c:	78 1a                	js     800528 <fd_close+0x6a>
		if (dev->dev_close)
  80050e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800511:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800514:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800519:	85 c0                	test   %eax,%eax
  80051b:	74 0b                	je     800528 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80051d:	83 ec 0c             	sub    $0xc,%esp
  800520:	56                   	push   %esi
  800521:	ff d0                	call   *%eax
  800523:	89 c3                	mov    %eax,%ebx
  800525:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	56                   	push   %esi
  80052c:	6a 00                	push   $0x0
  80052e:	e8 00 fd ff ff       	call   800233 <sys_page_unmap>
	return r;
  800533:	83 c4 10             	add    $0x10,%esp
  800536:	89 d8                	mov    %ebx,%eax
}
  800538:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80053b:	5b                   	pop    %ebx
  80053c:	5e                   	pop    %esi
  80053d:	5d                   	pop    %ebp
  80053e:	c3                   	ret    

0080053f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800545:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800548:	50                   	push   %eax
  800549:	ff 75 08             	pushl  0x8(%ebp)
  80054c:	e8 c4 fe ff ff       	call   800415 <fd_lookup>
  800551:	83 c4 08             	add    $0x8,%esp
  800554:	85 c0                	test   %eax,%eax
  800556:	78 10                	js     800568 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	6a 01                	push   $0x1
  80055d:	ff 75 f4             	pushl  -0xc(%ebp)
  800560:	e8 59 ff ff ff       	call   8004be <fd_close>
  800565:	83 c4 10             	add    $0x10,%esp
}
  800568:	c9                   	leave  
  800569:	c3                   	ret    

0080056a <close_all>:

void
close_all(void)
{
  80056a:	55                   	push   %ebp
  80056b:	89 e5                	mov    %esp,%ebp
  80056d:	53                   	push   %ebx
  80056e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800571:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800576:	83 ec 0c             	sub    $0xc,%esp
  800579:	53                   	push   %ebx
  80057a:	e8 c0 ff ff ff       	call   80053f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80057f:	83 c3 01             	add    $0x1,%ebx
  800582:	83 c4 10             	add    $0x10,%esp
  800585:	83 fb 20             	cmp    $0x20,%ebx
  800588:	75 ec                	jne    800576 <close_all+0xc>
		close(i);
}
  80058a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80058d:	c9                   	leave  
  80058e:	c3                   	ret    

0080058f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	57                   	push   %edi
  800593:	56                   	push   %esi
  800594:	53                   	push   %ebx
  800595:	83 ec 2c             	sub    $0x2c,%esp
  800598:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80059b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80059e:	50                   	push   %eax
  80059f:	ff 75 08             	pushl  0x8(%ebp)
  8005a2:	e8 6e fe ff ff       	call   800415 <fd_lookup>
  8005a7:	83 c4 08             	add    $0x8,%esp
  8005aa:	85 c0                	test   %eax,%eax
  8005ac:	0f 88 c1 00 00 00    	js     800673 <dup+0xe4>
		return r;
	close(newfdnum);
  8005b2:	83 ec 0c             	sub    $0xc,%esp
  8005b5:	56                   	push   %esi
  8005b6:	e8 84 ff ff ff       	call   80053f <close>

	newfd = INDEX2FD(newfdnum);
  8005bb:	89 f3                	mov    %esi,%ebx
  8005bd:	c1 e3 0c             	shl    $0xc,%ebx
  8005c0:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005c6:	83 c4 04             	add    $0x4,%esp
  8005c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005cc:	e8 de fd ff ff       	call   8003af <fd2data>
  8005d1:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005d3:	89 1c 24             	mov    %ebx,(%esp)
  8005d6:	e8 d4 fd ff ff       	call   8003af <fd2data>
  8005db:	83 c4 10             	add    $0x10,%esp
  8005de:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e1:	89 f8                	mov    %edi,%eax
  8005e3:	c1 e8 16             	shr    $0x16,%eax
  8005e6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ed:	a8 01                	test   $0x1,%al
  8005ef:	74 37                	je     800628 <dup+0x99>
  8005f1:	89 f8                	mov    %edi,%eax
  8005f3:	c1 e8 0c             	shr    $0xc,%eax
  8005f6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005fd:	f6 c2 01             	test   $0x1,%dl
  800600:	74 26                	je     800628 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800602:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800609:	83 ec 0c             	sub    $0xc,%esp
  80060c:	25 07 0e 00 00       	and    $0xe07,%eax
  800611:	50                   	push   %eax
  800612:	ff 75 d4             	pushl  -0x2c(%ebp)
  800615:	6a 00                	push   $0x0
  800617:	57                   	push   %edi
  800618:	6a 00                	push   $0x0
  80061a:	e8 d2 fb ff ff       	call   8001f1 <sys_page_map>
  80061f:	89 c7                	mov    %eax,%edi
  800621:	83 c4 20             	add    $0x20,%esp
  800624:	85 c0                	test   %eax,%eax
  800626:	78 2e                	js     800656 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800628:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062b:	89 d0                	mov    %edx,%eax
  80062d:	c1 e8 0c             	shr    $0xc,%eax
  800630:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800637:	83 ec 0c             	sub    $0xc,%esp
  80063a:	25 07 0e 00 00       	and    $0xe07,%eax
  80063f:	50                   	push   %eax
  800640:	53                   	push   %ebx
  800641:	6a 00                	push   $0x0
  800643:	52                   	push   %edx
  800644:	6a 00                	push   $0x0
  800646:	e8 a6 fb ff ff       	call   8001f1 <sys_page_map>
  80064b:	89 c7                	mov    %eax,%edi
  80064d:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800650:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800652:	85 ff                	test   %edi,%edi
  800654:	79 1d                	jns    800673 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 00                	push   $0x0
  80065c:	e8 d2 fb ff ff       	call   800233 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800661:	83 c4 08             	add    $0x8,%esp
  800664:	ff 75 d4             	pushl  -0x2c(%ebp)
  800667:	6a 00                	push   $0x0
  800669:	e8 c5 fb ff ff       	call   800233 <sys_page_unmap>
	return r;
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	89 f8                	mov    %edi,%eax
}
  800673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800676:	5b                   	pop    %ebx
  800677:	5e                   	pop    %esi
  800678:	5f                   	pop    %edi
  800679:	5d                   	pop    %ebp
  80067a:	c3                   	ret    

0080067b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	53                   	push   %ebx
  80067f:	83 ec 14             	sub    $0x14,%esp
  800682:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800685:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800688:	50                   	push   %eax
  800689:	53                   	push   %ebx
  80068a:	e8 86 fd ff ff       	call   800415 <fd_lookup>
  80068f:	83 c4 08             	add    $0x8,%esp
  800692:	89 c2                	mov    %eax,%edx
  800694:	85 c0                	test   %eax,%eax
  800696:	78 6d                	js     800705 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80069e:	50                   	push   %eax
  80069f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a2:	ff 30                	pushl  (%eax)
  8006a4:	e8 c2 fd ff ff       	call   80046b <dev_lookup>
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	78 4c                	js     8006fc <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006b3:	8b 42 08             	mov    0x8(%edx),%eax
  8006b6:	83 e0 03             	and    $0x3,%eax
  8006b9:	83 f8 01             	cmp    $0x1,%eax
  8006bc:	75 21                	jne    8006df <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006be:	a1 04 40 80 00       	mov    0x804004,%eax
  8006c3:	8b 40 48             	mov    0x48(%eax),%eax
  8006c6:	83 ec 04             	sub    $0x4,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	50                   	push   %eax
  8006cb:	68 99 1e 80 00       	push   $0x801e99
  8006d0:	e8 8d 0a 00 00       	call   801162 <cprintf>
		return -E_INVAL;
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006dd:	eb 26                	jmp    800705 <read+0x8a>
	}
	if (!dev->dev_read)
  8006df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e2:	8b 40 08             	mov    0x8(%eax),%eax
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 17                	je     800700 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8006e9:	83 ec 04             	sub    $0x4,%esp
  8006ec:	ff 75 10             	pushl  0x10(%ebp)
  8006ef:	ff 75 0c             	pushl  0xc(%ebp)
  8006f2:	52                   	push   %edx
  8006f3:	ff d0                	call   *%eax
  8006f5:	89 c2                	mov    %eax,%edx
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	eb 09                	jmp    800705 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006fc:	89 c2                	mov    %eax,%edx
  8006fe:	eb 05                	jmp    800705 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800700:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800705:	89 d0                	mov    %edx,%eax
  800707:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	57                   	push   %edi
  800710:	56                   	push   %esi
  800711:	53                   	push   %ebx
  800712:	83 ec 0c             	sub    $0xc,%esp
  800715:	8b 7d 08             	mov    0x8(%ebp),%edi
  800718:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800720:	eb 21                	jmp    800743 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800722:	83 ec 04             	sub    $0x4,%esp
  800725:	89 f0                	mov    %esi,%eax
  800727:	29 d8                	sub    %ebx,%eax
  800729:	50                   	push   %eax
  80072a:	89 d8                	mov    %ebx,%eax
  80072c:	03 45 0c             	add    0xc(%ebp),%eax
  80072f:	50                   	push   %eax
  800730:	57                   	push   %edi
  800731:	e8 45 ff ff ff       	call   80067b <read>
		if (m < 0)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	85 c0                	test   %eax,%eax
  80073b:	78 10                	js     80074d <readn+0x41>
			return m;
		if (m == 0)
  80073d:	85 c0                	test   %eax,%eax
  80073f:	74 0a                	je     80074b <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800741:	01 c3                	add    %eax,%ebx
  800743:	39 f3                	cmp    %esi,%ebx
  800745:	72 db                	jb     800722 <readn+0x16>
  800747:	89 d8                	mov    %ebx,%eax
  800749:	eb 02                	jmp    80074d <readn+0x41>
  80074b:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80074d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800750:	5b                   	pop    %ebx
  800751:	5e                   	pop    %esi
  800752:	5f                   	pop    %edi
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	53                   	push   %ebx
  800759:	83 ec 14             	sub    $0x14,%esp
  80075c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800762:	50                   	push   %eax
  800763:	53                   	push   %ebx
  800764:	e8 ac fc ff ff       	call   800415 <fd_lookup>
  800769:	83 c4 08             	add    $0x8,%esp
  80076c:	89 c2                	mov    %eax,%edx
  80076e:	85 c0                	test   %eax,%eax
  800770:	78 68                	js     8007da <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800778:	50                   	push   %eax
  800779:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077c:	ff 30                	pushl  (%eax)
  80077e:	e8 e8 fc ff ff       	call   80046b <dev_lookup>
  800783:	83 c4 10             	add    $0x10,%esp
  800786:	85 c0                	test   %eax,%eax
  800788:	78 47                	js     8007d1 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800791:	75 21                	jne    8007b4 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800793:	a1 04 40 80 00       	mov    0x804004,%eax
  800798:	8b 40 48             	mov    0x48(%eax),%eax
  80079b:	83 ec 04             	sub    $0x4,%esp
  80079e:	53                   	push   %ebx
  80079f:	50                   	push   %eax
  8007a0:	68 b5 1e 80 00       	push   $0x801eb5
  8007a5:	e8 b8 09 00 00       	call   801162 <cprintf>
		return -E_INVAL;
  8007aa:	83 c4 10             	add    $0x10,%esp
  8007ad:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007b2:	eb 26                	jmp    8007da <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	74 17                	je     8007d5 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007be:	83 ec 04             	sub    $0x4,%esp
  8007c1:	ff 75 10             	pushl  0x10(%ebp)
  8007c4:	ff 75 0c             	pushl  0xc(%ebp)
  8007c7:	50                   	push   %eax
  8007c8:	ff d2                	call   *%edx
  8007ca:	89 c2                	mov    %eax,%edx
  8007cc:	83 c4 10             	add    $0x10,%esp
  8007cf:	eb 09                	jmp    8007da <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	eb 05                	jmp    8007da <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007da:	89 d0                	mov    %edx,%eax
  8007dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e7:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	ff 75 08             	pushl  0x8(%ebp)
  8007ee:	e8 22 fc ff ff       	call   800415 <fd_lookup>
  8007f3:	83 c4 08             	add    $0x8,%esp
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 0e                	js     800808 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800800:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	83 ec 14             	sub    $0x14,%esp
  800811:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800814:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800817:	50                   	push   %eax
  800818:	53                   	push   %ebx
  800819:	e8 f7 fb ff ff       	call   800415 <fd_lookup>
  80081e:	83 c4 08             	add    $0x8,%esp
  800821:	89 c2                	mov    %eax,%edx
  800823:	85 c0                	test   %eax,%eax
  800825:	78 65                	js     80088c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082d:	50                   	push   %eax
  80082e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800831:	ff 30                	pushl  (%eax)
  800833:	e8 33 fc ff ff       	call   80046b <dev_lookup>
  800838:	83 c4 10             	add    $0x10,%esp
  80083b:	85 c0                	test   %eax,%eax
  80083d:	78 44                	js     800883 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80083f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800842:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800846:	75 21                	jne    800869 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800848:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80084d:	8b 40 48             	mov    0x48(%eax),%eax
  800850:	83 ec 04             	sub    $0x4,%esp
  800853:	53                   	push   %ebx
  800854:	50                   	push   %eax
  800855:	68 78 1e 80 00       	push   $0x801e78
  80085a:	e8 03 09 00 00       	call   801162 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80085f:	83 c4 10             	add    $0x10,%esp
  800862:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800867:	eb 23                	jmp    80088c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800869:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80086c:	8b 52 18             	mov    0x18(%edx),%edx
  80086f:	85 d2                	test   %edx,%edx
  800871:	74 14                	je     800887 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800873:	83 ec 08             	sub    $0x8,%esp
  800876:	ff 75 0c             	pushl  0xc(%ebp)
  800879:	50                   	push   %eax
  80087a:	ff d2                	call   *%edx
  80087c:	89 c2                	mov    %eax,%edx
  80087e:	83 c4 10             	add    $0x10,%esp
  800881:	eb 09                	jmp    80088c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800883:	89 c2                	mov    %eax,%edx
  800885:	eb 05                	jmp    80088c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800887:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80088c:	89 d0                	mov    %edx,%eax
  80088e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	83 ec 14             	sub    $0x14,%esp
  80089a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a0:	50                   	push   %eax
  8008a1:	ff 75 08             	pushl  0x8(%ebp)
  8008a4:	e8 6c fb ff ff       	call   800415 <fd_lookup>
  8008a9:	83 c4 08             	add    $0x8,%esp
  8008ac:	89 c2                	mov    %eax,%edx
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 58                	js     80090a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b2:	83 ec 08             	sub    $0x8,%esp
  8008b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b8:	50                   	push   %eax
  8008b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008bc:	ff 30                	pushl  (%eax)
  8008be:	e8 a8 fb ff ff       	call   80046b <dev_lookup>
  8008c3:	83 c4 10             	add    $0x10,%esp
  8008c6:	85 c0                	test   %eax,%eax
  8008c8:	78 37                	js     800901 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d1:	74 32                	je     800905 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008d3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008dd:	00 00 00 
	stat->st_isdir = 0;
  8008e0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e7:	00 00 00 
	stat->st_dev = dev;
  8008ea:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	53                   	push   %ebx
  8008f4:	ff 75 f0             	pushl  -0x10(%ebp)
  8008f7:	ff 50 14             	call   *0x14(%eax)
  8008fa:	89 c2                	mov    %eax,%edx
  8008fc:	83 c4 10             	add    $0x10,%esp
  8008ff:	eb 09                	jmp    80090a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800901:	89 c2                	mov    %eax,%edx
  800903:	eb 05                	jmp    80090a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800905:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80090a:	89 d0                	mov    %edx,%eax
  80090c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800916:	83 ec 08             	sub    $0x8,%esp
  800919:	6a 00                	push   $0x0
  80091b:	ff 75 08             	pushl  0x8(%ebp)
  80091e:	e8 e3 01 00 00       	call   800b06 <open>
  800923:	89 c3                	mov    %eax,%ebx
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	85 c0                	test   %eax,%eax
  80092a:	78 1b                	js     800947 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80092c:	83 ec 08             	sub    $0x8,%esp
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	50                   	push   %eax
  800933:	e8 5b ff ff ff       	call   800893 <fstat>
  800938:	89 c6                	mov    %eax,%esi
	close(fd);
  80093a:	89 1c 24             	mov    %ebx,(%esp)
  80093d:	e8 fd fb ff ff       	call   80053f <close>
	return r;
  800942:	83 c4 10             	add    $0x10,%esp
  800945:	89 f0                	mov    %esi,%eax
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	56                   	push   %esi
  800952:	53                   	push   %ebx
  800953:	89 c6                	mov    %eax,%esi
  800955:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800957:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80095e:	75 12                	jne    800972 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800960:	83 ec 0c             	sub    $0xc,%esp
  800963:	6a 01                	push   $0x1
  800965:	e8 98 11 00 00       	call   801b02 <ipc_find_env>
  80096a:	a3 00 40 80 00       	mov    %eax,0x804000
  80096f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800972:	6a 07                	push   $0x7
  800974:	68 00 50 80 00       	push   $0x805000
  800979:	56                   	push   %esi
  80097a:	ff 35 00 40 80 00    	pushl  0x804000
  800980:	e8 1b 11 00 00       	call   801aa0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800985:	83 c4 0c             	add    $0xc,%esp
  800988:	6a 00                	push   $0x0
  80098a:	53                   	push   %ebx
  80098b:	6a 00                	push   $0x0
  80098d:	e8 9c 10 00 00       	call   801a2e <ipc_recv>
}
  800992:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ad:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 02 00 00 00       	mov    $0x2,%eax
  8009bc:	e8 8d ff ff ff       	call   80094e <fsipc>
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cf:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d9:	b8 06 00 00 00       	mov    $0x6,%eax
  8009de:	e8 6b ff ff ff       	call   80094e <fsipc>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	53                   	push   %ebx
  8009e9:	83 ec 04             	sub    $0x4,%esp
  8009ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ff:	b8 05 00 00 00       	mov    $0x5,%eax
  800a04:	e8 45 ff ff ff       	call   80094e <fsipc>
  800a09:	85 c0                	test   %eax,%eax
  800a0b:	78 2c                	js     800a39 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	68 00 50 80 00       	push   $0x805000
  800a15:	53                   	push   %ebx
  800a16:	e8 cc 0c 00 00       	call   8016e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a1b:	a1 80 50 80 00       	mov    0x805080,%eax
  800a20:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a26:	a1 84 50 80 00       	mov    0x805084,%eax
  800a2b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a31:	83 c4 10             	add    $0x10,%esp
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a3c:	c9                   	leave  
  800a3d:	c3                   	ret    

00800a3e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	83 ec 0c             	sub    $0xc,%esp
  800a44:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a47:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4a:	8b 52 0c             	mov    0xc(%edx),%edx
  800a4d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a53:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a58:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a5d:	0f 47 c2             	cmova  %edx,%eax
  800a60:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a65:	50                   	push   %eax
  800a66:	ff 75 0c             	pushl  0xc(%ebp)
  800a69:	68 08 50 80 00       	push   $0x805008
  800a6e:	e8 06 0e 00 00       	call   801879 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a73:	ba 00 00 00 00       	mov    $0x0,%edx
  800a78:	b8 04 00 00 00       	mov    $0x4,%eax
  800a7d:	e8 cc fe ff ff       	call   80094e <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800a82:	c9                   	leave  
  800a83:	c3                   	ret    

00800a84 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	56                   	push   %esi
  800a88:	53                   	push   %ebx
  800a89:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a92:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a97:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa2:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa7:	e8 a2 fe ff ff       	call   80094e <fsipc>
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	85 c0                	test   %eax,%eax
  800ab0:	78 4b                	js     800afd <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ab2:	39 c6                	cmp    %eax,%esi
  800ab4:	73 16                	jae    800acc <devfile_read+0x48>
  800ab6:	68 e4 1e 80 00       	push   $0x801ee4
  800abb:	68 eb 1e 80 00       	push   $0x801eeb
  800ac0:	6a 7c                	push   $0x7c
  800ac2:	68 00 1f 80 00       	push   $0x801f00
  800ac7:	e8 bd 05 00 00       	call   801089 <_panic>
	assert(r <= PGSIZE);
  800acc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ad1:	7e 16                	jle    800ae9 <devfile_read+0x65>
  800ad3:	68 0b 1f 80 00       	push   $0x801f0b
  800ad8:	68 eb 1e 80 00       	push   $0x801eeb
  800add:	6a 7d                	push   $0x7d
  800adf:	68 00 1f 80 00       	push   $0x801f00
  800ae4:	e8 a0 05 00 00       	call   801089 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae9:	83 ec 04             	sub    $0x4,%esp
  800aec:	50                   	push   %eax
  800aed:	68 00 50 80 00       	push   $0x805000
  800af2:	ff 75 0c             	pushl  0xc(%ebp)
  800af5:	e8 7f 0d 00 00       	call   801879 <memmove>
	return r;
  800afa:	83 c4 10             	add    $0x10,%esp
}
  800afd:	89 d8                	mov    %ebx,%eax
  800aff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 20             	sub    $0x20,%esp
  800b0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b10:	53                   	push   %ebx
  800b11:	e8 98 0b 00 00       	call   8016ae <strlen>
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1e:	7f 67                	jg     800b87 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b26:	50                   	push   %eax
  800b27:	e8 9a f8 ff ff       	call   8003c6 <fd_alloc>
  800b2c:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b31:	85 c0                	test   %eax,%eax
  800b33:	78 57                	js     800b8c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b35:	83 ec 08             	sub    $0x8,%esp
  800b38:	53                   	push   %ebx
  800b39:	68 00 50 80 00       	push   $0x805000
  800b3e:	e8 a4 0b 00 00       	call   8016e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b46:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b53:	e8 f6 fd ff ff       	call   80094e <fsipc>
  800b58:	89 c3                	mov    %eax,%ebx
  800b5a:	83 c4 10             	add    $0x10,%esp
  800b5d:	85 c0                	test   %eax,%eax
  800b5f:	79 14                	jns    800b75 <open+0x6f>
		fd_close(fd, 0);
  800b61:	83 ec 08             	sub    $0x8,%esp
  800b64:	6a 00                	push   $0x0
  800b66:	ff 75 f4             	pushl  -0xc(%ebp)
  800b69:	e8 50 f9 ff ff       	call   8004be <fd_close>
		return r;
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	89 da                	mov    %ebx,%edx
  800b73:	eb 17                	jmp    800b8c <open+0x86>
	}

	return fd2num(fd);
  800b75:	83 ec 0c             	sub    $0xc,%esp
  800b78:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7b:	e8 1f f8 ff ff       	call   80039f <fd2num>
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	83 c4 10             	add    $0x10,%esp
  800b85:	eb 05                	jmp    800b8c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b87:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b8c:	89 d0                	mov    %edx,%eax
  800b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b99:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9e:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba3:	e8 a6 fd ff ff       	call   80094e <fsipc>
}
  800ba8:	c9                   	leave  
  800ba9:	c3                   	ret    

00800baa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	ff 75 08             	pushl  0x8(%ebp)
  800bb8:	e8 f2 f7 ff ff       	call   8003af <fd2data>
  800bbd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	68 17 1f 80 00       	push   $0x801f17
  800bc7:	53                   	push   %ebx
  800bc8:	e8 1a 0b 00 00       	call   8016e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bcd:	8b 46 04             	mov    0x4(%esi),%eax
  800bd0:	2b 06                	sub    (%esi),%eax
  800bd2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bdf:	00 00 00 
	stat->st_dev = &devpipe;
  800be2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be9:	30 80 00 
	return 0;
}
  800bec:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c02:	53                   	push   %ebx
  800c03:	6a 00                	push   $0x0
  800c05:	e8 29 f6 ff ff       	call   800233 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c0a:	89 1c 24             	mov    %ebx,(%esp)
  800c0d:	e8 9d f7 ff ff       	call   8003af <fd2data>
  800c12:	83 c4 08             	add    $0x8,%esp
  800c15:	50                   	push   %eax
  800c16:	6a 00                	push   $0x0
  800c18:	e8 16 f6 ff ff       	call   800233 <sys_page_unmap>
}
  800c1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 1c             	sub    $0x1c,%esp
  800c2b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c30:	a1 04 40 80 00       	mov    0x804004,%eax
  800c35:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c38:	83 ec 0c             	sub    $0xc,%esp
  800c3b:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3e:	e8 f8 0e 00 00       	call   801b3b <pageref>
  800c43:	89 c3                	mov    %eax,%ebx
  800c45:	89 3c 24             	mov    %edi,(%esp)
  800c48:	e8 ee 0e 00 00       	call   801b3b <pageref>
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	39 c3                	cmp    %eax,%ebx
  800c52:	0f 94 c1             	sete   %cl
  800c55:	0f b6 c9             	movzbl %cl,%ecx
  800c58:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c5b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c61:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c64:	39 ce                	cmp    %ecx,%esi
  800c66:	74 1b                	je     800c83 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c68:	39 c3                	cmp    %eax,%ebx
  800c6a:	75 c4                	jne    800c30 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c6c:	8b 42 58             	mov    0x58(%edx),%eax
  800c6f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c72:	50                   	push   %eax
  800c73:	56                   	push   %esi
  800c74:	68 1e 1f 80 00       	push   $0x801f1e
  800c79:	e8 e4 04 00 00       	call   801162 <cprintf>
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	eb ad                	jmp    800c30 <_pipeisclosed+0xe>
	}
}
  800c83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 28             	sub    $0x28,%esp
  800c97:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c9a:	56                   	push   %esi
  800c9b:	e8 0f f7 ff ff       	call   8003af <fd2data>
  800ca0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	bf 00 00 00 00       	mov    $0x0,%edi
  800caa:	eb 4b                	jmp    800cf7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cac:	89 da                	mov    %ebx,%edx
  800cae:	89 f0                	mov    %esi,%eax
  800cb0:	e8 6d ff ff ff       	call   800c22 <_pipeisclosed>
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	75 48                	jne    800d01 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cb9:	e8 d1 f4 ff ff       	call   80018f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cbe:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc1:	8b 0b                	mov    (%ebx),%ecx
  800cc3:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc6:	39 d0                	cmp    %edx,%eax
  800cc8:	73 e2                	jae    800cac <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cd1:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd4:	89 c2                	mov    %eax,%edx
  800cd6:	c1 fa 1f             	sar    $0x1f,%edx
  800cd9:	89 d1                	mov    %edx,%ecx
  800cdb:	c1 e9 1b             	shr    $0x1b,%ecx
  800cde:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ce1:	83 e2 1f             	and    $0x1f,%edx
  800ce4:	29 ca                	sub    %ecx,%edx
  800ce6:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cee:	83 c0 01             	add    $0x1,%eax
  800cf1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf4:	83 c7 01             	add    $0x1,%edi
  800cf7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cfa:	75 c2                	jne    800cbe <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cfc:	8b 45 10             	mov    0x10(%ebp),%eax
  800cff:	eb 05                	jmp    800d06 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 18             	sub    $0x18,%esp
  800d17:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d1a:	57                   	push   %edi
  800d1b:	e8 8f f6 ff ff       	call   8003af <fd2data>
  800d20:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d22:	83 c4 10             	add    $0x10,%esp
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	eb 3d                	jmp    800d69 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d2c:	85 db                	test   %ebx,%ebx
  800d2e:	74 04                	je     800d34 <devpipe_read+0x26>
				return i;
  800d30:	89 d8                	mov    %ebx,%eax
  800d32:	eb 44                	jmp    800d78 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d34:	89 f2                	mov    %esi,%edx
  800d36:	89 f8                	mov    %edi,%eax
  800d38:	e8 e5 fe ff ff       	call   800c22 <_pipeisclosed>
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	75 32                	jne    800d73 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d41:	e8 49 f4 ff ff       	call   80018f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d46:	8b 06                	mov    (%esi),%eax
  800d48:	3b 46 04             	cmp    0x4(%esi),%eax
  800d4b:	74 df                	je     800d2c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d4d:	99                   	cltd   
  800d4e:	c1 ea 1b             	shr    $0x1b,%edx
  800d51:	01 d0                	add    %edx,%eax
  800d53:	83 e0 1f             	and    $0x1f,%eax
  800d56:	29 d0                	sub    %edx,%eax
  800d58:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d63:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d66:	83 c3 01             	add    $0x1,%ebx
  800d69:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d6c:	75 d8                	jne    800d46 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d6e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d71:	eb 05                	jmp    800d78 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    

00800d80 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d8b:	50                   	push   %eax
  800d8c:	e8 35 f6 ff ff       	call   8003c6 <fd_alloc>
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	89 c2                	mov    %eax,%edx
  800d96:	85 c0                	test   %eax,%eax
  800d98:	0f 88 2c 01 00 00    	js     800eca <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9e:	83 ec 04             	sub    $0x4,%esp
  800da1:	68 07 04 00 00       	push   $0x407
  800da6:	ff 75 f4             	pushl  -0xc(%ebp)
  800da9:	6a 00                	push   $0x0
  800dab:	e8 fe f3 ff ff       	call   8001ae <sys_page_alloc>
  800db0:	83 c4 10             	add    $0x10,%esp
  800db3:	89 c2                	mov    %eax,%edx
  800db5:	85 c0                	test   %eax,%eax
  800db7:	0f 88 0d 01 00 00    	js     800eca <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc3:	50                   	push   %eax
  800dc4:	e8 fd f5 ff ff       	call   8003c6 <fd_alloc>
  800dc9:	89 c3                	mov    %eax,%ebx
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	0f 88 e2 00 00 00    	js     800eb8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd6:	83 ec 04             	sub    $0x4,%esp
  800dd9:	68 07 04 00 00       	push   $0x407
  800dde:	ff 75 f0             	pushl  -0x10(%ebp)
  800de1:	6a 00                	push   $0x0
  800de3:	e8 c6 f3 ff ff       	call   8001ae <sys_page_alloc>
  800de8:	89 c3                	mov    %eax,%ebx
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	85 c0                	test   %eax,%eax
  800def:	0f 88 c3 00 00 00    	js     800eb8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfb:	e8 af f5 ff ff       	call   8003af <fd2data>
  800e00:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e02:	83 c4 0c             	add    $0xc,%esp
  800e05:	68 07 04 00 00       	push   $0x407
  800e0a:	50                   	push   %eax
  800e0b:	6a 00                	push   $0x0
  800e0d:	e8 9c f3 ff ff       	call   8001ae <sys_page_alloc>
  800e12:	89 c3                	mov    %eax,%ebx
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	85 c0                	test   %eax,%eax
  800e19:	0f 88 89 00 00 00    	js     800ea8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	ff 75 f0             	pushl  -0x10(%ebp)
  800e25:	e8 85 f5 ff ff       	call   8003af <fd2data>
  800e2a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e31:	50                   	push   %eax
  800e32:	6a 00                	push   $0x0
  800e34:	56                   	push   %esi
  800e35:	6a 00                	push   $0x0
  800e37:	e8 b5 f3 ff ff       	call   8001f1 <sys_page_map>
  800e3c:	89 c3                	mov    %eax,%ebx
  800e3e:	83 c4 20             	add    $0x20,%esp
  800e41:	85 c0                	test   %eax,%eax
  800e43:	78 55                	js     800e9a <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e45:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e53:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e5a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e63:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e68:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e6f:	83 ec 0c             	sub    $0xc,%esp
  800e72:	ff 75 f4             	pushl  -0xc(%ebp)
  800e75:	e8 25 f5 ff ff       	call   80039f <fd2num>
  800e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e7f:	83 c4 04             	add    $0x4,%esp
  800e82:	ff 75 f0             	pushl  -0x10(%ebp)
  800e85:	e8 15 f5 ff ff       	call   80039f <fd2num>
  800e8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8d:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  800e90:	83 c4 10             	add    $0x10,%esp
  800e93:	ba 00 00 00 00       	mov    $0x0,%edx
  800e98:	eb 30                	jmp    800eca <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e9a:	83 ec 08             	sub    $0x8,%esp
  800e9d:	56                   	push   %esi
  800e9e:	6a 00                	push   $0x0
  800ea0:	e8 8e f3 ff ff       	call   800233 <sys_page_unmap>
  800ea5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea8:	83 ec 08             	sub    $0x8,%esp
  800eab:	ff 75 f0             	pushl  -0x10(%ebp)
  800eae:	6a 00                	push   $0x0
  800eb0:	e8 7e f3 ff ff       	call   800233 <sys_page_unmap>
  800eb5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb8:	83 ec 08             	sub    $0x8,%esp
  800ebb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebe:	6a 00                	push   $0x0
  800ec0:	e8 6e f3 ff ff       	call   800233 <sys_page_unmap>
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eca:	89 d0                	mov    %edx,%eax
  800ecc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edc:	50                   	push   %eax
  800edd:	ff 75 08             	pushl  0x8(%ebp)
  800ee0:	e8 30 f5 ff ff       	call   800415 <fd_lookup>
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	78 18                	js     800f04 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eec:	83 ec 0c             	sub    $0xc,%esp
  800eef:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef2:	e8 b8 f4 ff ff       	call   8003af <fd2data>
	return _pipeisclosed(fd, p);
  800ef7:	89 c2                	mov    %eax,%edx
  800ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800efc:	e8 21 fd ff ff       	call   800c22 <_pipeisclosed>
  800f01:	83 c4 10             	add    $0x10,%esp
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    

00800f06 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f16:	68 36 1f 80 00       	push   $0x801f36
  800f1b:	ff 75 0c             	pushl  0xc(%ebp)
  800f1e:	e8 c4 07 00 00       	call   8016e7 <strcpy>
	return 0;
}
  800f23:	b8 00 00 00 00       	mov    $0x0,%eax
  800f28:	c9                   	leave  
  800f29:	c3                   	ret    

00800f2a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	57                   	push   %edi
  800f2e:	56                   	push   %esi
  800f2f:	53                   	push   %ebx
  800f30:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f36:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f3b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f41:	eb 2d                	jmp    800f70 <devcons_write+0x46>
		m = n - tot;
  800f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f46:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f48:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f4b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f50:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	53                   	push   %ebx
  800f57:	03 45 0c             	add    0xc(%ebp),%eax
  800f5a:	50                   	push   %eax
  800f5b:	57                   	push   %edi
  800f5c:	e8 18 09 00 00       	call   801879 <memmove>
		sys_cputs(buf, m);
  800f61:	83 c4 08             	add    $0x8,%esp
  800f64:	53                   	push   %ebx
  800f65:	57                   	push   %edi
  800f66:	e8 87 f1 ff ff       	call   8000f2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f6b:	01 de                	add    %ebx,%esi
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	89 f0                	mov    %esi,%eax
  800f72:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f75:	72 cc                	jb     800f43 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 08             	sub    $0x8,%esp
  800f85:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f8a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f8e:	74 2a                	je     800fba <devcons_read+0x3b>
  800f90:	eb 05                	jmp    800f97 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f92:	e8 f8 f1 ff ff       	call   80018f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f97:	e8 74 f1 ff ff       	call   800110 <sys_cgetc>
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	74 f2                	je     800f92 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	78 16                	js     800fba <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa4:	83 f8 04             	cmp    $0x4,%eax
  800fa7:	74 0c                	je     800fb5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fac:	88 02                	mov    %al,(%edx)
	return 1;
  800fae:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb3:	eb 05                	jmp    800fba <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fb5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fba:	c9                   	leave  
  800fbb:	c3                   	ret    

00800fbc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc5:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fc8:	6a 01                	push   $0x1
  800fca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fcd:	50                   	push   %eax
  800fce:	e8 1f f1 ff ff       	call   8000f2 <sys_cputs>
}
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <getchar>:

int
getchar(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fde:	6a 01                	push   $0x1
  800fe0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe3:	50                   	push   %eax
  800fe4:	6a 00                	push   $0x0
  800fe6:	e8 90 f6 ff ff       	call   80067b <read>
	if (r < 0)
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 0f                	js     801001 <getchar+0x29>
		return r;
	if (r < 1)
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	7e 06                	jle    800ffc <getchar+0x24>
		return -E_EOF;
	return c;
  800ff6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ffa:	eb 05                	jmp    801001 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ffc:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801001:	c9                   	leave  
  801002:	c3                   	ret    

00801003 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801009:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100c:	50                   	push   %eax
  80100d:	ff 75 08             	pushl  0x8(%ebp)
  801010:	e8 00 f4 ff ff       	call   800415 <fd_lookup>
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 11                	js     80102d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80101c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801025:	39 10                	cmp    %edx,(%eax)
  801027:	0f 94 c0             	sete   %al
  80102a:	0f b6 c0             	movzbl %al,%eax
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <opencons>:

int
opencons(void)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801035:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801038:	50                   	push   %eax
  801039:	e8 88 f3 ff ff       	call   8003c6 <fd_alloc>
  80103e:	83 c4 10             	add    $0x10,%esp
		return r;
  801041:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801043:	85 c0                	test   %eax,%eax
  801045:	78 3e                	js     801085 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801047:	83 ec 04             	sub    $0x4,%esp
  80104a:	68 07 04 00 00       	push   $0x407
  80104f:	ff 75 f4             	pushl  -0xc(%ebp)
  801052:	6a 00                	push   $0x0
  801054:	e8 55 f1 ff ff       	call   8001ae <sys_page_alloc>
  801059:	83 c4 10             	add    $0x10,%esp
		return r;
  80105c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 23                	js     801085 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801062:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801068:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80106d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801070:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801077:	83 ec 0c             	sub    $0xc,%esp
  80107a:	50                   	push   %eax
  80107b:	e8 1f f3 ff ff       	call   80039f <fd2num>
  801080:	89 c2                	mov    %eax,%edx
  801082:	83 c4 10             	add    $0x10,%esp
}
  801085:	89 d0                	mov    %edx,%eax
  801087:	c9                   	leave  
  801088:	c3                   	ret    

00801089 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	56                   	push   %esi
  80108d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80108e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801091:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801097:	e8 d4 f0 ff ff       	call   800170 <sys_getenvid>
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	ff 75 0c             	pushl  0xc(%ebp)
  8010a2:	ff 75 08             	pushl  0x8(%ebp)
  8010a5:	56                   	push   %esi
  8010a6:	50                   	push   %eax
  8010a7:	68 44 1f 80 00       	push   $0x801f44
  8010ac:	e8 b1 00 00 00       	call   801162 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010b1:	83 c4 18             	add    $0x18,%esp
  8010b4:	53                   	push   %ebx
  8010b5:	ff 75 10             	pushl  0x10(%ebp)
  8010b8:	e8 54 00 00 00       	call   801111 <vcprintf>
	cprintf("\n");
  8010bd:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  8010c4:	e8 99 00 00 00       	call   801162 <cprintf>
  8010c9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010cc:	cc                   	int3   
  8010cd:	eb fd                	jmp    8010cc <_panic+0x43>

008010cf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	53                   	push   %ebx
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d9:	8b 13                	mov    (%ebx),%edx
  8010db:	8d 42 01             	lea    0x1(%edx),%eax
  8010de:	89 03                	mov    %eax,(%ebx)
  8010e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010e7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010ec:	75 1a                	jne    801108 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010ee:	83 ec 08             	sub    $0x8,%esp
  8010f1:	68 ff 00 00 00       	push   $0xff
  8010f6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f9:	50                   	push   %eax
  8010fa:	e8 f3 ef ff ff       	call   8000f2 <sys_cputs>
		b->idx = 0;
  8010ff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801105:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801108:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80110c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110f:	c9                   	leave  
  801110:	c3                   	ret    

00801111 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80111a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801121:	00 00 00 
	b.cnt = 0;
  801124:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80112b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80112e:	ff 75 0c             	pushl  0xc(%ebp)
  801131:	ff 75 08             	pushl  0x8(%ebp)
  801134:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	68 cf 10 80 00       	push   $0x8010cf
  801140:	e8 54 01 00 00       	call   801299 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801145:	83 c4 08             	add    $0x8,%esp
  801148:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80114e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801154:	50                   	push   %eax
  801155:	e8 98 ef ff ff       	call   8000f2 <sys_cputs>

	return b.cnt;
}
  80115a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801160:	c9                   	leave  
  801161:	c3                   	ret    

00801162 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801168:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80116b:	50                   	push   %eax
  80116c:	ff 75 08             	pushl  0x8(%ebp)
  80116f:	e8 9d ff ff ff       	call   801111 <vcprintf>
	va_end(ap);

	return cnt;
}
  801174:	c9                   	leave  
  801175:	c3                   	ret    

00801176 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	57                   	push   %edi
  80117a:	56                   	push   %esi
  80117b:	53                   	push   %ebx
  80117c:	83 ec 1c             	sub    $0x1c,%esp
  80117f:	89 c7                	mov    %eax,%edi
  801181:	89 d6                	mov    %edx,%esi
  801183:	8b 45 08             	mov    0x8(%ebp),%eax
  801186:	8b 55 0c             	mov    0xc(%ebp),%edx
  801189:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80118c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80118f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801192:	bb 00 00 00 00       	mov    $0x0,%ebx
  801197:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80119a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80119d:	39 d3                	cmp    %edx,%ebx
  80119f:	72 05                	jb     8011a6 <printnum+0x30>
  8011a1:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011a4:	77 45                	ja     8011eb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a6:	83 ec 0c             	sub    $0xc,%esp
  8011a9:	ff 75 18             	pushl  0x18(%ebp)
  8011ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8011af:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011b2:	53                   	push   %ebx
  8011b3:	ff 75 10             	pushl  0x10(%ebp)
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c5:	e8 b6 09 00 00       	call   801b80 <__udivdi3>
  8011ca:	83 c4 18             	add    $0x18,%esp
  8011cd:	52                   	push   %edx
  8011ce:	50                   	push   %eax
  8011cf:	89 f2                	mov    %esi,%edx
  8011d1:	89 f8                	mov    %edi,%eax
  8011d3:	e8 9e ff ff ff       	call   801176 <printnum>
  8011d8:	83 c4 20             	add    $0x20,%esp
  8011db:	eb 18                	jmp    8011f5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	56                   	push   %esi
  8011e1:	ff 75 18             	pushl  0x18(%ebp)
  8011e4:	ff d7                	call   *%edi
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	eb 03                	jmp    8011ee <printnum+0x78>
  8011eb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011ee:	83 eb 01             	sub    $0x1,%ebx
  8011f1:	85 db                	test   %ebx,%ebx
  8011f3:	7f e8                	jg     8011dd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f5:	83 ec 08             	sub    $0x8,%esp
  8011f8:	56                   	push   %esi
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ff:	ff 75 e0             	pushl  -0x20(%ebp)
  801202:	ff 75 dc             	pushl  -0x24(%ebp)
  801205:	ff 75 d8             	pushl  -0x28(%ebp)
  801208:	e8 a3 0a 00 00       	call   801cb0 <__umoddi3>
  80120d:	83 c4 14             	add    $0x14,%esp
  801210:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  801217:	50                   	push   %eax
  801218:	ff d7                	call   *%edi
}
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5f                   	pop    %edi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801228:	83 fa 01             	cmp    $0x1,%edx
  80122b:	7e 0e                	jle    80123b <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80122d:	8b 10                	mov    (%eax),%edx
  80122f:	8d 4a 08             	lea    0x8(%edx),%ecx
  801232:	89 08                	mov    %ecx,(%eax)
  801234:	8b 02                	mov    (%edx),%eax
  801236:	8b 52 04             	mov    0x4(%edx),%edx
  801239:	eb 22                	jmp    80125d <getuint+0x38>
	else if (lflag)
  80123b:	85 d2                	test   %edx,%edx
  80123d:	74 10                	je     80124f <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80123f:	8b 10                	mov    (%eax),%edx
  801241:	8d 4a 04             	lea    0x4(%edx),%ecx
  801244:	89 08                	mov    %ecx,(%eax)
  801246:	8b 02                	mov    (%edx),%eax
  801248:	ba 00 00 00 00       	mov    $0x0,%edx
  80124d:	eb 0e                	jmp    80125d <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80124f:	8b 10                	mov    (%eax),%edx
  801251:	8d 4a 04             	lea    0x4(%edx),%ecx
  801254:	89 08                	mov    %ecx,(%eax)
  801256:	8b 02                	mov    (%edx),%eax
  801258:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801265:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801269:	8b 10                	mov    (%eax),%edx
  80126b:	3b 50 04             	cmp    0x4(%eax),%edx
  80126e:	73 0a                	jae    80127a <sprintputch+0x1b>
		*b->buf++ = ch;
  801270:	8d 4a 01             	lea    0x1(%edx),%ecx
  801273:	89 08                	mov    %ecx,(%eax)
  801275:	8b 45 08             	mov    0x8(%ebp),%eax
  801278:	88 02                	mov    %al,(%edx)
}
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801282:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801285:	50                   	push   %eax
  801286:	ff 75 10             	pushl  0x10(%ebp)
  801289:	ff 75 0c             	pushl  0xc(%ebp)
  80128c:	ff 75 08             	pushl  0x8(%ebp)
  80128f:	e8 05 00 00 00       	call   801299 <vprintfmt>
	va_end(ap);
}
  801294:	83 c4 10             	add    $0x10,%esp
  801297:	c9                   	leave  
  801298:	c3                   	ret    

00801299 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	57                   	push   %edi
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
  80129f:	83 ec 2c             	sub    $0x2c,%esp
  8012a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012ab:	eb 12                	jmp    8012bf <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	0f 84 89 03 00 00    	je     80163e <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012b5:	83 ec 08             	sub    $0x8,%esp
  8012b8:	53                   	push   %ebx
  8012b9:	50                   	push   %eax
  8012ba:	ff d6                	call   *%esi
  8012bc:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012bf:	83 c7 01             	add    $0x1,%edi
  8012c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012c6:	83 f8 25             	cmp    $0x25,%eax
  8012c9:	75 e2                	jne    8012ad <vprintfmt+0x14>
  8012cb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012cf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012d6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012dd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e9:	eb 07                	jmp    8012f2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012ee:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f2:	8d 47 01             	lea    0x1(%edi),%eax
  8012f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f8:	0f b6 07             	movzbl (%edi),%eax
  8012fb:	0f b6 c8             	movzbl %al,%ecx
  8012fe:	83 e8 23             	sub    $0x23,%eax
  801301:	3c 55                	cmp    $0x55,%al
  801303:	0f 87 1a 03 00 00    	ja     801623 <vprintfmt+0x38a>
  801309:	0f b6 c0             	movzbl %al,%eax
  80130c:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  801313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801316:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80131a:	eb d6                	jmp    8012f2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
  801324:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801327:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80132a:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80132e:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801331:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801334:	83 fa 09             	cmp    $0x9,%edx
  801337:	77 39                	ja     801372 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801339:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80133c:	eb e9                	jmp    801327 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80133e:	8b 45 14             	mov    0x14(%ebp),%eax
  801341:	8d 48 04             	lea    0x4(%eax),%ecx
  801344:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801347:	8b 00                	mov    (%eax),%eax
  801349:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80134f:	eb 27                	jmp    801378 <vprintfmt+0xdf>
  801351:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801354:	85 c0                	test   %eax,%eax
  801356:	b9 00 00 00 00       	mov    $0x0,%ecx
  80135b:	0f 49 c8             	cmovns %eax,%ecx
  80135e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801364:	eb 8c                	jmp    8012f2 <vprintfmt+0x59>
  801366:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801369:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801370:	eb 80                	jmp    8012f2 <vprintfmt+0x59>
  801372:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801375:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801378:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80137c:	0f 89 70 ff ff ff    	jns    8012f2 <vprintfmt+0x59>
				width = precision, precision = -1;
  801382:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801385:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801388:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80138f:	e9 5e ff ff ff       	jmp    8012f2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801394:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80139a:	e9 53 ff ff ff       	jmp    8012f2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80139f:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a2:	8d 50 04             	lea    0x4(%eax),%edx
  8013a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	53                   	push   %ebx
  8013ac:	ff 30                	pushl  (%eax)
  8013ae:	ff d6                	call   *%esi
			break;
  8013b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013b6:	e9 04 ff ff ff       	jmp    8012bf <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013be:	8d 50 04             	lea    0x4(%eax),%edx
  8013c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c4:	8b 00                	mov    (%eax),%eax
  8013c6:	99                   	cltd   
  8013c7:	31 d0                	xor    %edx,%eax
  8013c9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013cb:	83 f8 0f             	cmp    $0xf,%eax
  8013ce:	7f 0b                	jg     8013db <vprintfmt+0x142>
  8013d0:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013d7:	85 d2                	test   %edx,%edx
  8013d9:	75 18                	jne    8013f3 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013db:	50                   	push   %eax
  8013dc:	68 7f 1f 80 00       	push   $0x801f7f
  8013e1:	53                   	push   %ebx
  8013e2:	56                   	push   %esi
  8013e3:	e8 94 fe ff ff       	call   80127c <printfmt>
  8013e8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013ee:	e9 cc fe ff ff       	jmp    8012bf <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013f3:	52                   	push   %edx
  8013f4:	68 fd 1e 80 00       	push   $0x801efd
  8013f9:	53                   	push   %ebx
  8013fa:	56                   	push   %esi
  8013fb:	e8 7c fe ff ff       	call   80127c <printfmt>
  801400:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801406:	e9 b4 fe ff ff       	jmp    8012bf <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80140b:	8b 45 14             	mov    0x14(%ebp),%eax
  80140e:	8d 50 04             	lea    0x4(%eax),%edx
  801411:	89 55 14             	mov    %edx,0x14(%ebp)
  801414:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801416:	85 ff                	test   %edi,%edi
  801418:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  80141d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801420:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801424:	0f 8e 94 00 00 00    	jle    8014be <vprintfmt+0x225>
  80142a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80142e:	0f 84 98 00 00 00    	je     8014cc <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	ff 75 d0             	pushl  -0x30(%ebp)
  80143a:	57                   	push   %edi
  80143b:	e8 86 02 00 00       	call   8016c6 <strnlen>
  801440:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801443:	29 c1                	sub    %eax,%ecx
  801445:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801448:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80144b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80144f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801452:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801455:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801457:	eb 0f                	jmp    801468 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	53                   	push   %ebx
  80145d:	ff 75 e0             	pushl  -0x20(%ebp)
  801460:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801462:	83 ef 01             	sub    $0x1,%edi
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	85 ff                	test   %edi,%edi
  80146a:	7f ed                	jg     801459 <vprintfmt+0x1c0>
  80146c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80146f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801472:	85 c9                	test   %ecx,%ecx
  801474:	b8 00 00 00 00       	mov    $0x0,%eax
  801479:	0f 49 c1             	cmovns %ecx,%eax
  80147c:	29 c1                	sub    %eax,%ecx
  80147e:	89 75 08             	mov    %esi,0x8(%ebp)
  801481:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801484:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801487:	89 cb                	mov    %ecx,%ebx
  801489:	eb 4d                	jmp    8014d8 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80148b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80148f:	74 1b                	je     8014ac <vprintfmt+0x213>
  801491:	0f be c0             	movsbl %al,%eax
  801494:	83 e8 20             	sub    $0x20,%eax
  801497:	83 f8 5e             	cmp    $0x5e,%eax
  80149a:	76 10                	jbe    8014ac <vprintfmt+0x213>
					putch('?', putdat);
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	ff 75 0c             	pushl  0xc(%ebp)
  8014a2:	6a 3f                	push   $0x3f
  8014a4:	ff 55 08             	call   *0x8(%ebp)
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	eb 0d                	jmp    8014b9 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	ff 75 0c             	pushl  0xc(%ebp)
  8014b2:	52                   	push   %edx
  8014b3:	ff 55 08             	call   *0x8(%ebp)
  8014b6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014b9:	83 eb 01             	sub    $0x1,%ebx
  8014bc:	eb 1a                	jmp    8014d8 <vprintfmt+0x23f>
  8014be:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014ca:	eb 0c                	jmp    8014d8 <vprintfmt+0x23f>
  8014cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8014cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014d5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014d8:	83 c7 01             	add    $0x1,%edi
  8014db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014df:	0f be d0             	movsbl %al,%edx
  8014e2:	85 d2                	test   %edx,%edx
  8014e4:	74 23                	je     801509 <vprintfmt+0x270>
  8014e6:	85 f6                	test   %esi,%esi
  8014e8:	78 a1                	js     80148b <vprintfmt+0x1f2>
  8014ea:	83 ee 01             	sub    $0x1,%esi
  8014ed:	79 9c                	jns    80148b <vprintfmt+0x1f2>
  8014ef:	89 df                	mov    %ebx,%edi
  8014f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f7:	eb 18                	jmp    801511 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014f9:	83 ec 08             	sub    $0x8,%esp
  8014fc:	53                   	push   %ebx
  8014fd:	6a 20                	push   $0x20
  8014ff:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801501:	83 ef 01             	sub    $0x1,%edi
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	eb 08                	jmp    801511 <vprintfmt+0x278>
  801509:	89 df                	mov    %ebx,%edi
  80150b:	8b 75 08             	mov    0x8(%ebp),%esi
  80150e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801511:	85 ff                	test   %edi,%edi
  801513:	7f e4                	jg     8014f9 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801518:	e9 a2 fd ff ff       	jmp    8012bf <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80151d:	83 fa 01             	cmp    $0x1,%edx
  801520:	7e 16                	jle    801538 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801522:	8b 45 14             	mov    0x14(%ebp),%eax
  801525:	8d 50 08             	lea    0x8(%eax),%edx
  801528:	89 55 14             	mov    %edx,0x14(%ebp)
  80152b:	8b 50 04             	mov    0x4(%eax),%edx
  80152e:	8b 00                	mov    (%eax),%eax
  801530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801533:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801536:	eb 32                	jmp    80156a <vprintfmt+0x2d1>
	else if (lflag)
  801538:	85 d2                	test   %edx,%edx
  80153a:	74 18                	je     801554 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80153c:	8b 45 14             	mov    0x14(%ebp),%eax
  80153f:	8d 50 04             	lea    0x4(%eax),%edx
  801542:	89 55 14             	mov    %edx,0x14(%ebp)
  801545:	8b 00                	mov    (%eax),%eax
  801547:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154a:	89 c1                	mov    %eax,%ecx
  80154c:	c1 f9 1f             	sar    $0x1f,%ecx
  80154f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801552:	eb 16                	jmp    80156a <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801554:	8b 45 14             	mov    0x14(%ebp),%eax
  801557:	8d 50 04             	lea    0x4(%eax),%edx
  80155a:	89 55 14             	mov    %edx,0x14(%ebp)
  80155d:	8b 00                	mov    (%eax),%eax
  80155f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801562:	89 c1                	mov    %eax,%ecx
  801564:	c1 f9 1f             	sar    $0x1f,%ecx
  801567:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80156a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80156d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801570:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801575:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801579:	79 74                	jns    8015ef <vprintfmt+0x356>
				putch('-', putdat);
  80157b:	83 ec 08             	sub    $0x8,%esp
  80157e:	53                   	push   %ebx
  80157f:	6a 2d                	push   $0x2d
  801581:	ff d6                	call   *%esi
				num = -(long long) num;
  801583:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801586:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801589:	f7 d8                	neg    %eax
  80158b:	83 d2 00             	adc    $0x0,%edx
  80158e:	f7 da                	neg    %edx
  801590:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801593:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801598:	eb 55                	jmp    8015ef <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80159a:	8d 45 14             	lea    0x14(%ebp),%eax
  80159d:	e8 83 fc ff ff       	call   801225 <getuint>
			base = 10;
  8015a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015a7:	eb 46                	jmp    8015ef <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015a9:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ac:	e8 74 fc ff ff       	call   801225 <getuint>
			base = 8;
  8015b1:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015b6:	eb 37                	jmp    8015ef <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	6a 30                	push   $0x30
  8015be:	ff d6                	call   *%esi
			putch('x', putdat);
  8015c0:	83 c4 08             	add    $0x8,%esp
  8015c3:	53                   	push   %ebx
  8015c4:	6a 78                	push   $0x78
  8015c6:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cb:	8d 50 04             	lea    0x4(%eax),%edx
  8015ce:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015d1:	8b 00                	mov    (%eax),%eax
  8015d3:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d8:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015db:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015e0:	eb 0d                	jmp    8015ef <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8015e5:	e8 3b fc ff ff       	call   801225 <getuint>
			base = 16;
  8015ea:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015ef:	83 ec 0c             	sub    $0xc,%esp
  8015f2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015f6:	57                   	push   %edi
  8015f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8015fa:	51                   	push   %ecx
  8015fb:	52                   	push   %edx
  8015fc:	50                   	push   %eax
  8015fd:	89 da                	mov    %ebx,%edx
  8015ff:	89 f0                	mov    %esi,%eax
  801601:	e8 70 fb ff ff       	call   801176 <printnum>
			break;
  801606:	83 c4 20             	add    $0x20,%esp
  801609:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80160c:	e9 ae fc ff ff       	jmp    8012bf <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	53                   	push   %ebx
  801615:	51                   	push   %ecx
  801616:	ff d6                	call   *%esi
			break;
  801618:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80161e:	e9 9c fc ff ff       	jmp    8012bf <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801623:	83 ec 08             	sub    $0x8,%esp
  801626:	53                   	push   %ebx
  801627:	6a 25                	push   $0x25
  801629:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80162b:	83 c4 10             	add    $0x10,%esp
  80162e:	eb 03                	jmp    801633 <vprintfmt+0x39a>
  801630:	83 ef 01             	sub    $0x1,%edi
  801633:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801637:	75 f7                	jne    801630 <vprintfmt+0x397>
  801639:	e9 81 fc ff ff       	jmp    8012bf <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80163e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    

00801646 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	83 ec 18             	sub    $0x18,%esp
  80164c:	8b 45 08             	mov    0x8(%ebp),%eax
  80164f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801652:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801655:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801659:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80165c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801663:	85 c0                	test   %eax,%eax
  801665:	74 26                	je     80168d <vsnprintf+0x47>
  801667:	85 d2                	test   %edx,%edx
  801669:	7e 22                	jle    80168d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80166b:	ff 75 14             	pushl  0x14(%ebp)
  80166e:	ff 75 10             	pushl  0x10(%ebp)
  801671:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	68 5f 12 80 00       	push   $0x80125f
  80167a:	e8 1a fc ff ff       	call   801299 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80167f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801682:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801685:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	eb 05                	jmp    801692 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80168d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80169a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80169d:	50                   	push   %eax
  80169e:	ff 75 10             	pushl  0x10(%ebp)
  8016a1:	ff 75 0c             	pushl  0xc(%ebp)
  8016a4:	ff 75 08             	pushl  0x8(%ebp)
  8016a7:	e8 9a ff ff ff       	call   801646 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016ac:	c9                   	leave  
  8016ad:	c3                   	ret    

008016ae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b9:	eb 03                	jmp    8016be <strlen+0x10>
		n++;
  8016bb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016c2:	75 f7                	jne    8016bb <strlen+0xd>
		n++;
	return n;
}
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d4:	eb 03                	jmp    8016d9 <strnlen+0x13>
		n++;
  8016d6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d9:	39 c2                	cmp    %eax,%edx
  8016db:	74 08                	je     8016e5 <strnlen+0x1f>
  8016dd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016e1:	75 f3                	jne    8016d6 <strnlen+0x10>
  8016e3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	53                   	push   %ebx
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	83 c2 01             	add    $0x1,%edx
  8016f6:	83 c1 01             	add    $0x1,%ecx
  8016f9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016fd:	88 5a ff             	mov    %bl,-0x1(%edx)
  801700:	84 db                	test   %bl,%bl
  801702:	75 ef                	jne    8016f3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801704:	5b                   	pop    %ebx
  801705:	5d                   	pop    %ebp
  801706:	c3                   	ret    

00801707 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801707:	55                   	push   %ebp
  801708:	89 e5                	mov    %esp,%ebp
  80170a:	53                   	push   %ebx
  80170b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80170e:	53                   	push   %ebx
  80170f:	e8 9a ff ff ff       	call   8016ae <strlen>
  801714:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801717:	ff 75 0c             	pushl  0xc(%ebp)
  80171a:	01 d8                	add    %ebx,%eax
  80171c:	50                   	push   %eax
  80171d:	e8 c5 ff ff ff       	call   8016e7 <strcpy>
	return dst;
}
  801722:	89 d8                	mov    %ebx,%eax
  801724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	56                   	push   %esi
  80172d:	53                   	push   %ebx
  80172e:	8b 75 08             	mov    0x8(%ebp),%esi
  801731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801734:	89 f3                	mov    %esi,%ebx
  801736:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801739:	89 f2                	mov    %esi,%edx
  80173b:	eb 0f                	jmp    80174c <strncpy+0x23>
		*dst++ = *src;
  80173d:	83 c2 01             	add    $0x1,%edx
  801740:	0f b6 01             	movzbl (%ecx),%eax
  801743:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801746:	80 39 01             	cmpb   $0x1,(%ecx)
  801749:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80174c:	39 da                	cmp    %ebx,%edx
  80174e:	75 ed                	jne    80173d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801750:	89 f0                	mov    %esi,%eax
  801752:	5b                   	pop    %ebx
  801753:	5e                   	pop    %esi
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	8b 75 08             	mov    0x8(%ebp),%esi
  80175e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801761:	8b 55 10             	mov    0x10(%ebp),%edx
  801764:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801766:	85 d2                	test   %edx,%edx
  801768:	74 21                	je     80178b <strlcpy+0x35>
  80176a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80176e:	89 f2                	mov    %esi,%edx
  801770:	eb 09                	jmp    80177b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801772:	83 c2 01             	add    $0x1,%edx
  801775:	83 c1 01             	add    $0x1,%ecx
  801778:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80177b:	39 c2                	cmp    %eax,%edx
  80177d:	74 09                	je     801788 <strlcpy+0x32>
  80177f:	0f b6 19             	movzbl (%ecx),%ebx
  801782:	84 db                	test   %bl,%bl
  801784:	75 ec                	jne    801772 <strlcpy+0x1c>
  801786:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801788:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80178b:	29 f0                	sub    %esi,%eax
}
  80178d:	5b                   	pop    %ebx
  80178e:	5e                   	pop    %esi
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801797:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179a:	eb 06                	jmp    8017a2 <strcmp+0x11>
		p++, q++;
  80179c:	83 c1 01             	add    $0x1,%ecx
  80179f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017a2:	0f b6 01             	movzbl (%ecx),%eax
  8017a5:	84 c0                	test   %al,%al
  8017a7:	74 04                	je     8017ad <strcmp+0x1c>
  8017a9:	3a 02                	cmp    (%edx),%al
  8017ab:	74 ef                	je     80179c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ad:	0f b6 c0             	movzbl %al,%eax
  8017b0:	0f b6 12             	movzbl (%edx),%edx
  8017b3:	29 d0                	sub    %edx,%eax
}
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c1:	89 c3                	mov    %eax,%ebx
  8017c3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c6:	eb 06                	jmp    8017ce <strncmp+0x17>
		n--, p++, q++;
  8017c8:	83 c0 01             	add    $0x1,%eax
  8017cb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017ce:	39 d8                	cmp    %ebx,%eax
  8017d0:	74 15                	je     8017e7 <strncmp+0x30>
  8017d2:	0f b6 08             	movzbl (%eax),%ecx
  8017d5:	84 c9                	test   %cl,%cl
  8017d7:	74 04                	je     8017dd <strncmp+0x26>
  8017d9:	3a 0a                	cmp    (%edx),%cl
  8017db:	74 eb                	je     8017c8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017dd:	0f b6 00             	movzbl (%eax),%eax
  8017e0:	0f b6 12             	movzbl (%edx),%edx
  8017e3:	29 d0                	sub    %edx,%eax
  8017e5:	eb 05                	jmp    8017ec <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017e7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017ec:	5b                   	pop    %ebx
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    

008017ef <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f9:	eb 07                	jmp    801802 <strchr+0x13>
		if (*s == c)
  8017fb:	38 ca                	cmp    %cl,%dl
  8017fd:	74 0f                	je     80180e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017ff:	83 c0 01             	add    $0x1,%eax
  801802:	0f b6 10             	movzbl (%eax),%edx
  801805:	84 d2                	test   %dl,%dl
  801807:	75 f2                	jne    8017fb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801809:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180e:	5d                   	pop    %ebp
  80180f:	c3                   	ret    

00801810 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	8b 45 08             	mov    0x8(%ebp),%eax
  801816:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181a:	eb 03                	jmp    80181f <strfind+0xf>
  80181c:	83 c0 01             	add    $0x1,%eax
  80181f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801822:	38 ca                	cmp    %cl,%dl
  801824:	74 04                	je     80182a <strfind+0x1a>
  801826:	84 d2                	test   %dl,%dl
  801828:	75 f2                	jne    80181c <strfind+0xc>
			break;
	return (char *) s;
}
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    

0080182c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80182c:	55                   	push   %ebp
  80182d:	89 e5                	mov    %esp,%ebp
  80182f:	57                   	push   %edi
  801830:	56                   	push   %esi
  801831:	53                   	push   %ebx
  801832:	8b 7d 08             	mov    0x8(%ebp),%edi
  801835:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801838:	85 c9                	test   %ecx,%ecx
  80183a:	74 36                	je     801872 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80183c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801842:	75 28                	jne    80186c <memset+0x40>
  801844:	f6 c1 03             	test   $0x3,%cl
  801847:	75 23                	jne    80186c <memset+0x40>
		c &= 0xFF;
  801849:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80184d:	89 d3                	mov    %edx,%ebx
  80184f:	c1 e3 08             	shl    $0x8,%ebx
  801852:	89 d6                	mov    %edx,%esi
  801854:	c1 e6 18             	shl    $0x18,%esi
  801857:	89 d0                	mov    %edx,%eax
  801859:	c1 e0 10             	shl    $0x10,%eax
  80185c:	09 f0                	or     %esi,%eax
  80185e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801860:	89 d8                	mov    %ebx,%eax
  801862:	09 d0                	or     %edx,%eax
  801864:	c1 e9 02             	shr    $0x2,%ecx
  801867:	fc                   	cld    
  801868:	f3 ab                	rep stos %eax,%es:(%edi)
  80186a:	eb 06                	jmp    801872 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80186c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186f:	fc                   	cld    
  801870:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801872:	89 f8                	mov    %edi,%eax
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5f                   	pop    %edi
  801877:	5d                   	pop    %ebp
  801878:	c3                   	ret    

00801879 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	57                   	push   %edi
  80187d:	56                   	push   %esi
  80187e:	8b 45 08             	mov    0x8(%ebp),%eax
  801881:	8b 75 0c             	mov    0xc(%ebp),%esi
  801884:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801887:	39 c6                	cmp    %eax,%esi
  801889:	73 35                	jae    8018c0 <memmove+0x47>
  80188b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80188e:	39 d0                	cmp    %edx,%eax
  801890:	73 2e                	jae    8018c0 <memmove+0x47>
		s += n;
		d += n;
  801892:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801895:	89 d6                	mov    %edx,%esi
  801897:	09 fe                	or     %edi,%esi
  801899:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189f:	75 13                	jne    8018b4 <memmove+0x3b>
  8018a1:	f6 c1 03             	test   $0x3,%cl
  8018a4:	75 0e                	jne    8018b4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018a6:	83 ef 04             	sub    $0x4,%edi
  8018a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018ac:	c1 e9 02             	shr    $0x2,%ecx
  8018af:	fd                   	std    
  8018b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b2:	eb 09                	jmp    8018bd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b4:	83 ef 01             	sub    $0x1,%edi
  8018b7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018ba:	fd                   	std    
  8018bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018bd:	fc                   	cld    
  8018be:	eb 1d                	jmp    8018dd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c0:	89 f2                	mov    %esi,%edx
  8018c2:	09 c2                	or     %eax,%edx
  8018c4:	f6 c2 03             	test   $0x3,%dl
  8018c7:	75 0f                	jne    8018d8 <memmove+0x5f>
  8018c9:	f6 c1 03             	test   $0x3,%cl
  8018cc:	75 0a                	jne    8018d8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018ce:	c1 e9 02             	shr    $0x2,%ecx
  8018d1:	89 c7                	mov    %eax,%edi
  8018d3:	fc                   	cld    
  8018d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d6:	eb 05                	jmp    8018dd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d8:	89 c7                	mov    %eax,%edi
  8018da:	fc                   	cld    
  8018db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018dd:	5e                   	pop    %esi
  8018de:	5f                   	pop    %edi
  8018df:	5d                   	pop    %ebp
  8018e0:	c3                   	ret    

008018e1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e4:	ff 75 10             	pushl  0x10(%ebp)
  8018e7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ea:	ff 75 08             	pushl  0x8(%ebp)
  8018ed:	e8 87 ff ff ff       	call   801879 <memmove>
}
  8018f2:	c9                   	leave  
  8018f3:	c3                   	ret    

008018f4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	56                   	push   %esi
  8018f8:	53                   	push   %ebx
  8018f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ff:	89 c6                	mov    %eax,%esi
  801901:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801904:	eb 1a                	jmp    801920 <memcmp+0x2c>
		if (*s1 != *s2)
  801906:	0f b6 08             	movzbl (%eax),%ecx
  801909:	0f b6 1a             	movzbl (%edx),%ebx
  80190c:	38 d9                	cmp    %bl,%cl
  80190e:	74 0a                	je     80191a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801910:	0f b6 c1             	movzbl %cl,%eax
  801913:	0f b6 db             	movzbl %bl,%ebx
  801916:	29 d8                	sub    %ebx,%eax
  801918:	eb 0f                	jmp    801929 <memcmp+0x35>
		s1++, s2++;
  80191a:	83 c0 01             	add    $0x1,%eax
  80191d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801920:	39 f0                	cmp    %esi,%eax
  801922:	75 e2                	jne    801906 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801924:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801929:	5b                   	pop    %ebx
  80192a:	5e                   	pop    %esi
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    

0080192d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
  801930:	53                   	push   %ebx
  801931:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801934:	89 c1                	mov    %eax,%ecx
  801936:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801939:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193d:	eb 0a                	jmp    801949 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80193f:	0f b6 10             	movzbl (%eax),%edx
  801942:	39 da                	cmp    %ebx,%edx
  801944:	74 07                	je     80194d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801946:	83 c0 01             	add    $0x1,%eax
  801949:	39 c8                	cmp    %ecx,%eax
  80194b:	72 f2                	jb     80193f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80194d:	5b                   	pop    %ebx
  80194e:	5d                   	pop    %ebp
  80194f:	c3                   	ret    

00801950 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	57                   	push   %edi
  801954:	56                   	push   %esi
  801955:	53                   	push   %ebx
  801956:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801959:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195c:	eb 03                	jmp    801961 <strtol+0x11>
		s++;
  80195e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801961:	0f b6 01             	movzbl (%ecx),%eax
  801964:	3c 20                	cmp    $0x20,%al
  801966:	74 f6                	je     80195e <strtol+0xe>
  801968:	3c 09                	cmp    $0x9,%al
  80196a:	74 f2                	je     80195e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80196c:	3c 2b                	cmp    $0x2b,%al
  80196e:	75 0a                	jne    80197a <strtol+0x2a>
		s++;
  801970:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801973:	bf 00 00 00 00       	mov    $0x0,%edi
  801978:	eb 11                	jmp    80198b <strtol+0x3b>
  80197a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80197f:	3c 2d                	cmp    $0x2d,%al
  801981:	75 08                	jne    80198b <strtol+0x3b>
		s++, neg = 1;
  801983:	83 c1 01             	add    $0x1,%ecx
  801986:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801991:	75 15                	jne    8019a8 <strtol+0x58>
  801993:	80 39 30             	cmpb   $0x30,(%ecx)
  801996:	75 10                	jne    8019a8 <strtol+0x58>
  801998:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80199c:	75 7c                	jne    801a1a <strtol+0xca>
		s += 2, base = 16;
  80199e:	83 c1 02             	add    $0x2,%ecx
  8019a1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a6:	eb 16                	jmp    8019be <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019a8:	85 db                	test   %ebx,%ebx
  8019aa:	75 12                	jne    8019be <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019ac:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019b1:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b4:	75 08                	jne    8019be <strtol+0x6e>
		s++, base = 8;
  8019b6:	83 c1 01             	add    $0x1,%ecx
  8019b9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019be:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019c6:	0f b6 11             	movzbl (%ecx),%edx
  8019c9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019cc:	89 f3                	mov    %esi,%ebx
  8019ce:	80 fb 09             	cmp    $0x9,%bl
  8019d1:	77 08                	ja     8019db <strtol+0x8b>
			dig = *s - '0';
  8019d3:	0f be d2             	movsbl %dl,%edx
  8019d6:	83 ea 30             	sub    $0x30,%edx
  8019d9:	eb 22                	jmp    8019fd <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019db:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019de:	89 f3                	mov    %esi,%ebx
  8019e0:	80 fb 19             	cmp    $0x19,%bl
  8019e3:	77 08                	ja     8019ed <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019e5:	0f be d2             	movsbl %dl,%edx
  8019e8:	83 ea 57             	sub    $0x57,%edx
  8019eb:	eb 10                	jmp    8019fd <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019ed:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019f0:	89 f3                	mov    %esi,%ebx
  8019f2:	80 fb 19             	cmp    $0x19,%bl
  8019f5:	77 16                	ja     801a0d <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019f7:	0f be d2             	movsbl %dl,%edx
  8019fa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019fd:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a00:	7d 0b                	jge    801a0d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a02:	83 c1 01             	add    $0x1,%ecx
  801a05:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a09:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a0b:	eb b9                	jmp    8019c6 <strtol+0x76>

	if (endptr)
  801a0d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a11:	74 0d                	je     801a20 <strtol+0xd0>
		*endptr = (char *) s;
  801a13:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a16:	89 0e                	mov    %ecx,(%esi)
  801a18:	eb 06                	jmp    801a20 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a1a:	85 db                	test   %ebx,%ebx
  801a1c:	74 98                	je     8019b6 <strtol+0x66>
  801a1e:	eb 9e                	jmp    8019be <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a20:	89 c2                	mov    %eax,%edx
  801a22:	f7 da                	neg    %edx
  801a24:	85 ff                	test   %edi,%edi
  801a26:	0f 45 c2             	cmovne %edx,%eax
}
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	5f                   	pop    %edi
  801a2c:	5d                   	pop    %ebp
  801a2d:	c3                   	ret    

00801a2e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	8b 75 08             	mov    0x8(%ebp),%esi
  801a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	75 12                	jne    801a52 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	68 00 00 c0 ee       	push   $0xeec00000
  801a48:	e8 11 e9 ff ff       	call   80035e <sys_ipc_recv>
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	eb 0c                	jmp    801a5e <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a52:	83 ec 0c             	sub    $0xc,%esp
  801a55:	50                   	push   %eax
  801a56:	e8 03 e9 ff ff       	call   80035e <sys_ipc_recv>
  801a5b:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a5e:	85 f6                	test   %esi,%esi
  801a60:	0f 95 c1             	setne  %cl
  801a63:	85 db                	test   %ebx,%ebx
  801a65:	0f 95 c2             	setne  %dl
  801a68:	84 d1                	test   %dl,%cl
  801a6a:	74 09                	je     801a75 <ipc_recv+0x47>
  801a6c:	89 c2                	mov    %eax,%edx
  801a6e:	c1 ea 1f             	shr    $0x1f,%edx
  801a71:	84 d2                	test   %dl,%dl
  801a73:	75 24                	jne    801a99 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a75:	85 f6                	test   %esi,%esi
  801a77:	74 0a                	je     801a83 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801a79:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7e:	8b 40 74             	mov    0x74(%eax),%eax
  801a81:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801a83:	85 db                	test   %ebx,%ebx
  801a85:	74 0a                	je     801a91 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801a87:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8c:	8b 40 78             	mov    0x78(%eax),%eax
  801a8f:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a91:	a1 04 40 80 00       	mov    0x804004,%eax
  801a96:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    

00801aa0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	57                   	push   %edi
  801aa4:	56                   	push   %esi
  801aa5:	53                   	push   %ebx
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ab2:	85 db                	test   %ebx,%ebx
  801ab4:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ab9:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801abc:	ff 75 14             	pushl  0x14(%ebp)
  801abf:	53                   	push   %ebx
  801ac0:	56                   	push   %esi
  801ac1:	57                   	push   %edi
  801ac2:	e8 74 e8 ff ff       	call   80033b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ac7:	89 c2                	mov    %eax,%edx
  801ac9:	c1 ea 1f             	shr    $0x1f,%edx
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	84 d2                	test   %dl,%dl
  801ad1:	74 17                	je     801aea <ipc_send+0x4a>
  801ad3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad6:	74 12                	je     801aea <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ad8:	50                   	push   %eax
  801ad9:	68 60 22 80 00       	push   $0x802260
  801ade:	6a 47                	push   $0x47
  801ae0:	68 6e 22 80 00       	push   $0x80226e
  801ae5:	e8 9f f5 ff ff       	call   801089 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801aea:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aed:	75 07                	jne    801af6 <ipc_send+0x56>
			sys_yield();
  801aef:	e8 9b e6 ff ff       	call   80018f <sys_yield>
  801af4:	eb c6                	jmp    801abc <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801af6:	85 c0                	test   %eax,%eax
  801af8:	75 c2                	jne    801abc <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801afa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afd:	5b                   	pop    %ebx
  801afe:	5e                   	pop    %esi
  801aff:	5f                   	pop    %edi
  801b00:	5d                   	pop    %ebp
  801b01:	c3                   	ret    

00801b02 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b08:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b0d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b10:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b16:	8b 52 50             	mov    0x50(%edx),%edx
  801b19:	39 ca                	cmp    %ecx,%edx
  801b1b:	75 0d                	jne    801b2a <ipc_find_env+0x28>
			return envs[i].env_id;
  801b1d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b20:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b25:	8b 40 48             	mov    0x48(%eax),%eax
  801b28:	eb 0f                	jmp    801b39 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b2a:	83 c0 01             	add    $0x1,%eax
  801b2d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b32:	75 d9                	jne    801b0d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b39:	5d                   	pop    %ebp
  801b3a:	c3                   	ret    

00801b3b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b41:	89 d0                	mov    %edx,%eax
  801b43:	c1 e8 16             	shr    $0x16,%eax
  801b46:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b4d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b52:	f6 c1 01             	test   $0x1,%cl
  801b55:	74 1d                	je     801b74 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b57:	c1 ea 0c             	shr    $0xc,%edx
  801b5a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b61:	f6 c2 01             	test   $0x1,%dl
  801b64:	74 0e                	je     801b74 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b66:	c1 ea 0c             	shr    $0xc,%edx
  801b69:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b70:	ef 
  801b71:	0f b7 c0             	movzwl %ax,%eax
}
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    
  801b76:	66 90                	xchg   %ax,%ax
  801b78:	66 90                	xchg   %ax,%ax
  801b7a:	66 90                	xchg   %ax,%ax
  801b7c:	66 90                	xchg   %ax,%ax
  801b7e:	66 90                	xchg   %ax,%ax

00801b80 <__udivdi3>:
  801b80:	55                   	push   %ebp
  801b81:	57                   	push   %edi
  801b82:	56                   	push   %esi
  801b83:	53                   	push   %ebx
  801b84:	83 ec 1c             	sub    $0x1c,%esp
  801b87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b97:	85 f6                	test   %esi,%esi
  801b99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b9d:	89 ca                	mov    %ecx,%edx
  801b9f:	89 f8                	mov    %edi,%eax
  801ba1:	75 3d                	jne    801be0 <__udivdi3+0x60>
  801ba3:	39 cf                	cmp    %ecx,%edi
  801ba5:	0f 87 c5 00 00 00    	ja     801c70 <__udivdi3+0xf0>
  801bab:	85 ff                	test   %edi,%edi
  801bad:	89 fd                	mov    %edi,%ebp
  801baf:	75 0b                	jne    801bbc <__udivdi3+0x3c>
  801bb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bb6:	31 d2                	xor    %edx,%edx
  801bb8:	f7 f7                	div    %edi
  801bba:	89 c5                	mov    %eax,%ebp
  801bbc:	89 c8                	mov    %ecx,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f5                	div    %ebp
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	89 d8                	mov    %ebx,%eax
  801bc6:	89 cf                	mov    %ecx,%edi
  801bc8:	f7 f5                	div    %ebp
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	89 d8                	mov    %ebx,%eax
  801bce:	89 fa                	mov    %edi,%edx
  801bd0:	83 c4 1c             	add    $0x1c,%esp
  801bd3:	5b                   	pop    %ebx
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
  801bd8:	90                   	nop
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 ce                	cmp    %ecx,%esi
  801be2:	77 74                	ja     801c58 <__udivdi3+0xd8>
  801be4:	0f bd fe             	bsr    %esi,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0x108>
  801bf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	89 c5                	mov    %eax,%ebp
  801bf9:	29 fb                	sub    %edi,%ebx
  801bfb:	d3 e6                	shl    %cl,%esi
  801bfd:	89 d9                	mov    %ebx,%ecx
  801bff:	d3 ed                	shr    %cl,%ebp
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e0                	shl    %cl,%eax
  801c05:	09 ee                	or     %ebp,%esi
  801c07:	89 d9                	mov    %ebx,%ecx
  801c09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c0d:	89 d5                	mov    %edx,%ebp
  801c0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c13:	d3 ed                	shr    %cl,%ebp
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e2                	shl    %cl,%edx
  801c19:	89 d9                	mov    %ebx,%ecx
  801c1b:	d3 e8                	shr    %cl,%eax
  801c1d:	09 c2                	or     %eax,%edx
  801c1f:	89 d0                	mov    %edx,%eax
  801c21:	89 ea                	mov    %ebp,%edx
  801c23:	f7 f6                	div    %esi
  801c25:	89 d5                	mov    %edx,%ebp
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	f7 64 24 0c          	mull   0xc(%esp)
  801c2d:	39 d5                	cmp    %edx,%ebp
  801c2f:	72 10                	jb     801c41 <__udivdi3+0xc1>
  801c31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e6                	shl    %cl,%esi
  801c39:	39 c6                	cmp    %eax,%esi
  801c3b:	73 07                	jae    801c44 <__udivdi3+0xc4>
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	75 03                	jne    801c44 <__udivdi3+0xc4>
  801c41:	83 eb 01             	sub    $0x1,%ebx
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 d8                	mov    %ebx,%eax
  801c48:	89 fa                	mov    %edi,%edx
  801c4a:	83 c4 1c             	add    $0x1c,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
  801c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c58:	31 ff                	xor    %edi,%edi
  801c5a:	31 db                	xor    %ebx,%ebx
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
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	f7 f7                	div    %edi
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 c3                	mov    %eax,%ebx
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	89 fa                	mov    %edi,%edx
  801c7c:	83 c4 1c             	add    $0x1c,%esp
  801c7f:	5b                   	pop    %ebx
  801c80:	5e                   	pop    %esi
  801c81:	5f                   	pop    %edi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
  801c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c88:	39 ce                	cmp    %ecx,%esi
  801c8a:	72 0c                	jb     801c98 <__udivdi3+0x118>
  801c8c:	31 db                	xor    %ebx,%ebx
  801c8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c92:	0f 87 34 ff ff ff    	ja     801bcc <__udivdi3+0x4c>
  801c98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c9d:	e9 2a ff ff ff       	jmp    801bcc <__udivdi3+0x4c>
  801ca2:	66 90                	xchg   %ax,%ax
  801ca4:	66 90                	xchg   %ax,%ax
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 d2                	test   %edx,%edx
  801cc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cd1:	89 f3                	mov    %esi,%ebx
  801cd3:	89 3c 24             	mov    %edi,(%esp)
  801cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cda:	75 1c                	jne    801cf8 <__umoddi3+0x48>
  801cdc:	39 f7                	cmp    %esi,%edi
  801cde:	76 50                	jbe    801d30 <__umoddi3+0x80>
  801ce0:	89 c8                	mov    %ecx,%eax
  801ce2:	89 f2                	mov    %esi,%edx
  801ce4:	f7 f7                	div    %edi
  801ce6:	89 d0                	mov    %edx,%eax
  801ce8:	31 d2                	xor    %edx,%edx
  801cea:	83 c4 1c             	add    $0x1c,%esp
  801ced:	5b                   	pop    %ebx
  801cee:	5e                   	pop    %esi
  801cef:	5f                   	pop    %edi
  801cf0:	5d                   	pop    %ebp
  801cf1:	c3                   	ret    
  801cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	89 d0                	mov    %edx,%eax
  801cfc:	77 52                	ja     801d50 <__umoddi3+0xa0>
  801cfe:	0f bd ea             	bsr    %edx,%ebp
  801d01:	83 f5 1f             	xor    $0x1f,%ebp
  801d04:	75 5a                	jne    801d60 <__umoddi3+0xb0>
  801d06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d0a:	0f 82 e0 00 00 00    	jb     801df0 <__umoddi3+0x140>
  801d10:	39 0c 24             	cmp    %ecx,(%esp)
  801d13:	0f 86 d7 00 00 00    	jbe    801df0 <__umoddi3+0x140>
  801d19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d21:	83 c4 1c             	add    $0x1c,%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	85 ff                	test   %edi,%edi
  801d32:	89 fd                	mov    %edi,%ebp
  801d34:	75 0b                	jne    801d41 <__umoddi3+0x91>
  801d36:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	f7 f7                	div    %edi
  801d3f:	89 c5                	mov    %eax,%ebp
  801d41:	89 f0                	mov    %esi,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f5                	div    %ebp
  801d47:	89 c8                	mov    %ecx,%eax
  801d49:	f7 f5                	div    %ebp
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	eb 99                	jmp    801ce8 <__umoddi3+0x38>
  801d4f:	90                   	nop
  801d50:	89 c8                	mov    %ecx,%eax
  801d52:	89 f2                	mov    %esi,%edx
  801d54:	83 c4 1c             	add    $0x1c,%esp
  801d57:	5b                   	pop    %ebx
  801d58:	5e                   	pop    %esi
  801d59:	5f                   	pop    %edi
  801d5a:	5d                   	pop    %ebp
  801d5b:	c3                   	ret    
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	8b 34 24             	mov    (%esp),%esi
  801d63:	bf 20 00 00 00       	mov    $0x20,%edi
  801d68:	89 e9                	mov    %ebp,%ecx
  801d6a:	29 ef                	sub    %ebp,%edi
  801d6c:	d3 e0                	shl    %cl,%eax
  801d6e:	89 f9                	mov    %edi,%ecx
  801d70:	89 f2                	mov    %esi,%edx
  801d72:	d3 ea                	shr    %cl,%edx
  801d74:	89 e9                	mov    %ebp,%ecx
  801d76:	09 c2                	or     %eax,%edx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 14 24             	mov    %edx,(%esp)
  801d7d:	89 f2                	mov    %esi,%edx
  801d7f:	d3 e2                	shl    %cl,%edx
  801d81:	89 f9                	mov    %edi,%ecx
  801d83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d8b:	d3 e8                	shr    %cl,%eax
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	89 c6                	mov    %eax,%esi
  801d91:	d3 e3                	shl    %cl,%ebx
  801d93:	89 f9                	mov    %edi,%ecx
  801d95:	89 d0                	mov    %edx,%eax
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	09 d8                	or     %ebx,%eax
  801d9d:	89 d3                	mov    %edx,%ebx
  801d9f:	89 f2                	mov    %esi,%edx
  801da1:	f7 34 24             	divl   (%esp)
  801da4:	89 d6                	mov    %edx,%esi
  801da6:	d3 e3                	shl    %cl,%ebx
  801da8:	f7 64 24 04          	mull   0x4(%esp)
  801dac:	39 d6                	cmp    %edx,%esi
  801dae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801db2:	89 d1                	mov    %edx,%ecx
  801db4:	89 c3                	mov    %eax,%ebx
  801db6:	72 08                	jb     801dc0 <__umoddi3+0x110>
  801db8:	75 11                	jne    801dcb <__umoddi3+0x11b>
  801dba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dbe:	73 0b                	jae    801dcb <__umoddi3+0x11b>
  801dc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dc4:	1b 14 24             	sbb    (%esp),%edx
  801dc7:	89 d1                	mov    %edx,%ecx
  801dc9:	89 c3                	mov    %eax,%ebx
  801dcb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dcf:	29 da                	sub    %ebx,%edx
  801dd1:	19 ce                	sbb    %ecx,%esi
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 f0                	mov    %esi,%eax
  801dd7:	d3 e0                	shl    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	d3 ea                	shr    %cl,%edx
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	d3 ee                	shr    %cl,%esi
  801de1:	09 d0                	or     %edx,%eax
  801de3:	89 f2                	mov    %esi,%edx
  801de5:	83 c4 1c             	add    $0x1c,%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5e                   	pop    %esi
  801dea:	5f                   	pop    %edi
  801deb:	5d                   	pop    %ebp
  801dec:	c3                   	ret    
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	29 f9                	sub    %edi,%ecx
  801df2:	19 d6                	sbb    %edx,%esi
  801df4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801df8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dfc:	e9 18 ff ff ff       	jmp    801d19 <__umoddi3+0x69>
