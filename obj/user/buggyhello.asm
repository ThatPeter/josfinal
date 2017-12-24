
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 ad 00 00 00       	call   8000ef <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	57                   	push   %edi
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800050:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800057:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80005a:	e8 0e 01 00 00       	call   80016d <sys_getenvid>
  80005f:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800065:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80006a:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80006f:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800074:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800077:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80007d:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800080:	39 c8                	cmp    %ecx,%eax
  800082:	0f 44 fb             	cmove  %ebx,%edi
  800085:	b9 01 00 00 00       	mov    $0x1,%ecx
  80008a:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  80008d:	83 c2 01             	add    $0x1,%edx
  800090:	83 c3 7c             	add    $0x7c,%ebx
  800093:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800099:	75 d9                	jne    800074 <libmain+0x2d>
  80009b:	89 f0                	mov    %esi,%eax
  80009d:	84 c0                	test   %al,%al
  80009f:	74 06                	je     8000a7 <libmain+0x60>
  8000a1:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000ab:	7e 0a                	jle    8000b7 <libmain+0x70>
		binaryname = argv[0];
  8000ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b0:	8b 00                	mov    (%eax),%eax
  8000b2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	ff 75 0c             	pushl  0xc(%ebp)
  8000bd:	ff 75 08             	pushl  0x8(%ebp)
  8000c0:	e8 6e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c5:	e8 0b 00 00 00       	call   8000d5 <exit>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000db:	e8 87 04 00 00       	call   800567 <close_all>
	sys_env_destroy(0);
  8000e0:	83 ec 0c             	sub    $0xc,%esp
  8000e3:	6a 00                	push   $0x0
  8000e5:	e8 42 00 00 00       	call   80012c <sys_env_destroy>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	57                   	push   %edi
  8000f3:	56                   	push   %esi
  8000f4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800100:	89 c3                	mov    %eax,%ebx
  800102:	89 c7                	mov    %eax,%edi
  800104:	89 c6                	mov    %eax,%esi
  800106:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <sys_cgetc>:

int
sys_cgetc(void)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800113:	ba 00 00 00 00       	mov    $0x0,%edx
  800118:	b8 01 00 00 00       	mov    $0x1,%eax
  80011d:	89 d1                	mov    %edx,%ecx
  80011f:	89 d3                	mov    %edx,%ebx
  800121:	89 d7                	mov    %edx,%edi
  800123:	89 d6                	mov    %edx,%esi
  800125:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
  800132:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	b9 00 00 00 00       	mov    $0x0,%ecx
  80013a:	b8 03 00 00 00       	mov    $0x3,%eax
  80013f:	8b 55 08             	mov    0x8(%ebp),%edx
  800142:	89 cb                	mov    %ecx,%ebx
  800144:	89 cf                	mov    %ecx,%edi
  800146:	89 ce                	mov    %ecx,%esi
  800148:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80014a:	85 c0                	test   %eax,%eax
  80014c:	7e 17                	jle    800165 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80014e:	83 ec 0c             	sub    $0xc,%esp
  800151:	50                   	push   %eax
  800152:	6a 03                	push   $0x3
  800154:	68 2a 1e 80 00       	push   $0x801e2a
  800159:	6a 23                	push   $0x23
  80015b:	68 47 1e 80 00       	push   $0x801e47
  800160:	e8 21 0f 00 00       	call   801086 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800165:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	57                   	push   %edi
  800171:	56                   	push   %esi
  800172:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	ba 00 00 00 00       	mov    $0x0,%edx
  800178:	b8 02 00 00 00       	mov    $0x2,%eax
  80017d:	89 d1                	mov    %edx,%ecx
  80017f:	89 d3                	mov    %edx,%ebx
  800181:	89 d7                	mov    %edx,%edi
  800183:	89 d6                	mov    %edx,%esi
  800185:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800187:	5b                   	pop    %ebx
  800188:	5e                   	pop    %esi
  800189:	5f                   	pop    %edi
  80018a:	5d                   	pop    %ebp
  80018b:	c3                   	ret    

0080018c <sys_yield>:

void
sys_yield(void)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800192:	ba 00 00 00 00       	mov    $0x0,%edx
  800197:	b8 0b 00 00 00       	mov    $0xb,%eax
  80019c:	89 d1                	mov    %edx,%ecx
  80019e:	89 d3                	mov    %edx,%ebx
  8001a0:	89 d7                	mov    %edx,%edi
  8001a2:	89 d6                	mov    %edx,%esi
  8001a4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	be 00 00 00 00       	mov    $0x0,%esi
  8001b9:	b8 04 00 00 00       	mov    $0x4,%eax
  8001be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c7:	89 f7                	mov    %esi,%edi
  8001c9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	7e 17                	jle    8001e6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cf:	83 ec 0c             	sub    $0xc,%esp
  8001d2:	50                   	push   %eax
  8001d3:	6a 04                	push   $0x4
  8001d5:	68 2a 1e 80 00       	push   $0x801e2a
  8001da:	6a 23                	push   $0x23
  8001dc:	68 47 1e 80 00       	push   $0x801e47
  8001e1:	e8 a0 0e 00 00       	call   801086 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e9:	5b                   	pop    %ebx
  8001ea:	5e                   	pop    %esi
  8001eb:	5f                   	pop    %edi
  8001ec:	5d                   	pop    %ebp
  8001ed:	c3                   	ret    

008001ee <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	57                   	push   %edi
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800205:	8b 7d 14             	mov    0x14(%ebp),%edi
  800208:	8b 75 18             	mov    0x18(%ebp),%esi
  80020b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020d:	85 c0                	test   %eax,%eax
  80020f:	7e 17                	jle    800228 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800211:	83 ec 0c             	sub    $0xc,%esp
  800214:	50                   	push   %eax
  800215:	6a 05                	push   $0x5
  800217:	68 2a 1e 80 00       	push   $0x801e2a
  80021c:	6a 23                	push   $0x23
  80021e:	68 47 1e 80 00       	push   $0x801e47
  800223:	e8 5e 0e 00 00       	call   801086 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800228:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023e:	b8 06 00 00 00       	mov    $0x6,%eax
  800243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800246:	8b 55 08             	mov    0x8(%ebp),%edx
  800249:	89 df                	mov    %ebx,%edi
  80024b:	89 de                	mov    %ebx,%esi
  80024d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024f:	85 c0                	test   %eax,%eax
  800251:	7e 17                	jle    80026a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	50                   	push   %eax
  800257:	6a 06                	push   $0x6
  800259:	68 2a 1e 80 00       	push   $0x801e2a
  80025e:	6a 23                	push   $0x23
  800260:	68 47 1e 80 00       	push   $0x801e47
  800265:	e8 1c 0e 00 00       	call   801086 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	57                   	push   %edi
  800276:	56                   	push   %esi
  800277:	53                   	push   %ebx
  800278:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800280:	b8 08 00 00 00       	mov    $0x8,%eax
  800285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800288:	8b 55 08             	mov    0x8(%ebp),%edx
  80028b:	89 df                	mov    %ebx,%edi
  80028d:	89 de                	mov    %ebx,%esi
  80028f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800291:	85 c0                	test   %eax,%eax
  800293:	7e 17                	jle    8002ac <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	50                   	push   %eax
  800299:	6a 08                	push   $0x8
  80029b:	68 2a 1e 80 00       	push   $0x801e2a
  8002a0:	6a 23                	push   $0x23
  8002a2:	68 47 1e 80 00       	push   $0x801e47
  8002a7:	e8 da 0d 00 00       	call   801086 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	57                   	push   %edi
  8002b8:	56                   	push   %esi
  8002b9:	53                   	push   %ebx
  8002ba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c2:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	89 df                	mov    %ebx,%edi
  8002cf:	89 de                	mov    %ebx,%esi
  8002d1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d3:	85 c0                	test   %eax,%eax
  8002d5:	7e 17                	jle    8002ee <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	50                   	push   %eax
  8002db:	6a 09                	push   $0x9
  8002dd:	68 2a 1e 80 00       	push   $0x801e2a
  8002e2:	6a 23                	push   $0x23
  8002e4:	68 47 1e 80 00       	push   $0x801e47
  8002e9:	e8 98 0d 00 00       	call   801086 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5f                   	pop    %edi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	57                   	push   %edi
  8002fa:	56                   	push   %esi
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800304:	b8 0a 00 00 00       	mov    $0xa,%eax
  800309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030c:	8b 55 08             	mov    0x8(%ebp),%edx
  80030f:	89 df                	mov    %ebx,%edi
  800311:	89 de                	mov    %ebx,%esi
  800313:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800315:	85 c0                	test   %eax,%eax
  800317:	7e 17                	jle    800330 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800319:	83 ec 0c             	sub    $0xc,%esp
  80031c:	50                   	push   %eax
  80031d:	6a 0a                	push   $0xa
  80031f:	68 2a 1e 80 00       	push   $0x801e2a
  800324:	6a 23                	push   $0x23
  800326:	68 47 1e 80 00       	push   $0x801e47
  80032b:	e8 56 0d 00 00       	call   801086 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800330:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800333:	5b                   	pop    %ebx
  800334:	5e                   	pop    %esi
  800335:	5f                   	pop    %edi
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033e:	be 00 00 00 00       	mov    $0x0,%esi
  800343:	b8 0c 00 00 00       	mov    $0xc,%eax
  800348:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034b:	8b 55 08             	mov    0x8(%ebp),%edx
  80034e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800351:	8b 7d 14             	mov    0x14(%ebp),%edi
  800354:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
  800361:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800364:	b9 00 00 00 00       	mov    $0x0,%ecx
  800369:	b8 0d 00 00 00       	mov    $0xd,%eax
  80036e:	8b 55 08             	mov    0x8(%ebp),%edx
  800371:	89 cb                	mov    %ecx,%ebx
  800373:	89 cf                	mov    %ecx,%edi
  800375:	89 ce                	mov    %ecx,%esi
  800377:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800379:	85 c0                	test   %eax,%eax
  80037b:	7e 17                	jle    800394 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80037d:	83 ec 0c             	sub    $0xc,%esp
  800380:	50                   	push   %eax
  800381:	6a 0d                	push   $0xd
  800383:	68 2a 1e 80 00       	push   $0x801e2a
  800388:	6a 23                	push   $0x23
  80038a:	68 47 1e 80 00       	push   $0x801e47
  80038f:	e8 f2 0c 00 00       	call   801086 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800394:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800397:	5b                   	pop    %ebx
  800398:	5e                   	pop    %esi
  800399:	5f                   	pop    %edi
  80039a:	5d                   	pop    %ebp
  80039b:	c3                   	ret    

0080039c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a7:	c1 e8 0c             	shr    $0xc,%eax
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003af:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003bc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ce:	89 c2                	mov    %eax,%edx
  8003d0:	c1 ea 16             	shr    $0x16,%edx
  8003d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003da:	f6 c2 01             	test   $0x1,%dl
  8003dd:	74 11                	je     8003f0 <fd_alloc+0x2d>
  8003df:	89 c2                	mov    %eax,%edx
  8003e1:	c1 ea 0c             	shr    $0xc,%edx
  8003e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003eb:	f6 c2 01             	test   $0x1,%dl
  8003ee:	75 09                	jne    8003f9 <fd_alloc+0x36>
			*fd_store = fd;
  8003f0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f7:	eb 17                	jmp    800410 <fd_alloc+0x4d>
  8003f9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003fe:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800403:	75 c9                	jne    8003ce <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800405:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80040b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800418:	83 f8 1f             	cmp    $0x1f,%eax
  80041b:	77 36                	ja     800453 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80041d:	c1 e0 0c             	shl    $0xc,%eax
  800420:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800425:	89 c2                	mov    %eax,%edx
  800427:	c1 ea 16             	shr    $0x16,%edx
  80042a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800431:	f6 c2 01             	test   $0x1,%dl
  800434:	74 24                	je     80045a <fd_lookup+0x48>
  800436:	89 c2                	mov    %eax,%edx
  800438:	c1 ea 0c             	shr    $0xc,%edx
  80043b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800442:	f6 c2 01             	test   $0x1,%dl
  800445:	74 1a                	je     800461 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800447:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044a:	89 02                	mov    %eax,(%edx)
	return 0;
  80044c:	b8 00 00 00 00       	mov    $0x0,%eax
  800451:	eb 13                	jmp    800466 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800453:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800458:	eb 0c                	jmp    800466 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045f:	eb 05                	jmp    800466 <fd_lookup+0x54>
  800461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800471:	ba d4 1e 80 00       	mov    $0x801ed4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800476:	eb 13                	jmp    80048b <dev_lookup+0x23>
  800478:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80047b:	39 08                	cmp    %ecx,(%eax)
  80047d:	75 0c                	jne    80048b <dev_lookup+0x23>
			*dev = devtab[i];
  80047f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800482:	89 01                	mov    %eax,(%ecx)
			return 0;
  800484:	b8 00 00 00 00       	mov    $0x0,%eax
  800489:	eb 2e                	jmp    8004b9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80048b:	8b 02                	mov    (%edx),%eax
  80048d:	85 c0                	test   %eax,%eax
  80048f:	75 e7                	jne    800478 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800491:	a1 04 40 80 00       	mov    0x804004,%eax
  800496:	8b 40 48             	mov    0x48(%eax),%eax
  800499:	83 ec 04             	sub    $0x4,%esp
  80049c:	51                   	push   %ecx
  80049d:	50                   	push   %eax
  80049e:	68 58 1e 80 00       	push   $0x801e58
  8004a3:	e8 b7 0c 00 00       	call   80115f <cprintf>
	*dev = 0;
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b9:	c9                   	leave  
  8004ba:	c3                   	ret    

008004bb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004bb:	55                   	push   %ebp
  8004bc:	89 e5                	mov    %esp,%ebp
  8004be:	56                   	push   %esi
  8004bf:	53                   	push   %ebx
  8004c0:	83 ec 10             	sub    $0x10,%esp
  8004c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004cc:	50                   	push   %eax
  8004cd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004d3:	c1 e8 0c             	shr    $0xc,%eax
  8004d6:	50                   	push   %eax
  8004d7:	e8 36 ff ff ff       	call   800412 <fd_lookup>
  8004dc:	83 c4 08             	add    $0x8,%esp
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	78 05                	js     8004e8 <fd_close+0x2d>
	    || fd != fd2)
  8004e3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e6:	74 0c                	je     8004f4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004e8:	84 db                	test   %bl,%bl
  8004ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ef:	0f 44 c2             	cmove  %edx,%eax
  8004f2:	eb 41                	jmp    800535 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004fa:	50                   	push   %eax
  8004fb:	ff 36                	pushl  (%esi)
  8004fd:	e8 66 ff ff ff       	call   800468 <dev_lookup>
  800502:	89 c3                	mov    %eax,%ebx
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	85 c0                	test   %eax,%eax
  800509:	78 1a                	js     800525 <fd_close+0x6a>
		if (dev->dev_close)
  80050b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80050e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800511:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800516:	85 c0                	test   %eax,%eax
  800518:	74 0b                	je     800525 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80051a:	83 ec 0c             	sub    $0xc,%esp
  80051d:	56                   	push   %esi
  80051e:	ff d0                	call   *%eax
  800520:	89 c3                	mov    %eax,%ebx
  800522:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	56                   	push   %esi
  800529:	6a 00                	push   $0x0
  80052b:	e8 00 fd ff ff       	call   800230 <sys_page_unmap>
	return r;
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	89 d8                	mov    %ebx,%eax
}
  800535:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800538:	5b                   	pop    %ebx
  800539:	5e                   	pop    %esi
  80053a:	5d                   	pop    %ebp
  80053b:	c3                   	ret    

0080053c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800542:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800545:	50                   	push   %eax
  800546:	ff 75 08             	pushl  0x8(%ebp)
  800549:	e8 c4 fe ff ff       	call   800412 <fd_lookup>
  80054e:	83 c4 08             	add    $0x8,%esp
  800551:	85 c0                	test   %eax,%eax
  800553:	78 10                	js     800565 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	6a 01                	push   $0x1
  80055a:	ff 75 f4             	pushl  -0xc(%ebp)
  80055d:	e8 59 ff ff ff       	call   8004bb <fd_close>
  800562:	83 c4 10             	add    $0x10,%esp
}
  800565:	c9                   	leave  
  800566:	c3                   	ret    

00800567 <close_all>:

void
close_all(void)
{
  800567:	55                   	push   %ebp
  800568:	89 e5                	mov    %esp,%ebp
  80056a:	53                   	push   %ebx
  80056b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80056e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800573:	83 ec 0c             	sub    $0xc,%esp
  800576:	53                   	push   %ebx
  800577:	e8 c0 ff ff ff       	call   80053c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80057c:	83 c3 01             	add    $0x1,%ebx
  80057f:	83 c4 10             	add    $0x10,%esp
  800582:	83 fb 20             	cmp    $0x20,%ebx
  800585:	75 ec                	jne    800573 <close_all+0xc>
		close(i);
}
  800587:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80058a:	c9                   	leave  
  80058b:	c3                   	ret    

0080058c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	53                   	push   %ebx
  800592:	83 ec 2c             	sub    $0x2c,%esp
  800595:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800598:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80059b:	50                   	push   %eax
  80059c:	ff 75 08             	pushl  0x8(%ebp)
  80059f:	e8 6e fe ff ff       	call   800412 <fd_lookup>
  8005a4:	83 c4 08             	add    $0x8,%esp
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	0f 88 c1 00 00 00    	js     800670 <dup+0xe4>
		return r;
	close(newfdnum);
  8005af:	83 ec 0c             	sub    $0xc,%esp
  8005b2:	56                   	push   %esi
  8005b3:	e8 84 ff ff ff       	call   80053c <close>

	newfd = INDEX2FD(newfdnum);
  8005b8:	89 f3                	mov    %esi,%ebx
  8005ba:	c1 e3 0c             	shl    $0xc,%ebx
  8005bd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005c3:	83 c4 04             	add    $0x4,%esp
  8005c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c9:	e8 de fd ff ff       	call   8003ac <fd2data>
  8005ce:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005d0:	89 1c 24             	mov    %ebx,(%esp)
  8005d3:	e8 d4 fd ff ff       	call   8003ac <fd2data>
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005de:	89 f8                	mov    %edi,%eax
  8005e0:	c1 e8 16             	shr    $0x16,%eax
  8005e3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ea:	a8 01                	test   $0x1,%al
  8005ec:	74 37                	je     800625 <dup+0x99>
  8005ee:	89 f8                	mov    %edi,%eax
  8005f0:	c1 e8 0c             	shr    $0xc,%eax
  8005f3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005fa:	f6 c2 01             	test   $0x1,%dl
  8005fd:	74 26                	je     800625 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	25 07 0e 00 00       	and    $0xe07,%eax
  80060e:	50                   	push   %eax
  80060f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800612:	6a 00                	push   $0x0
  800614:	57                   	push   %edi
  800615:	6a 00                	push   $0x0
  800617:	e8 d2 fb ff ff       	call   8001ee <sys_page_map>
  80061c:	89 c7                	mov    %eax,%edi
  80061e:	83 c4 20             	add    $0x20,%esp
  800621:	85 c0                	test   %eax,%eax
  800623:	78 2e                	js     800653 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800628:	89 d0                	mov    %edx,%eax
  80062a:	c1 e8 0c             	shr    $0xc,%eax
  80062d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800634:	83 ec 0c             	sub    $0xc,%esp
  800637:	25 07 0e 00 00       	and    $0xe07,%eax
  80063c:	50                   	push   %eax
  80063d:	53                   	push   %ebx
  80063e:	6a 00                	push   $0x0
  800640:	52                   	push   %edx
  800641:	6a 00                	push   $0x0
  800643:	e8 a6 fb ff ff       	call   8001ee <sys_page_map>
  800648:	89 c7                	mov    %eax,%edi
  80064a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80064d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80064f:	85 ff                	test   %edi,%edi
  800651:	79 1d                	jns    800670 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 00                	push   $0x0
  800659:	e8 d2 fb ff ff       	call   800230 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	ff 75 d4             	pushl  -0x2c(%ebp)
  800664:	6a 00                	push   $0x0
  800666:	e8 c5 fb ff ff       	call   800230 <sys_page_unmap>
	return r;
  80066b:	83 c4 10             	add    $0x10,%esp
  80066e:	89 f8                	mov    %edi,%eax
}
  800670:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800673:	5b                   	pop    %ebx
  800674:	5e                   	pop    %esi
  800675:	5f                   	pop    %edi
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	53                   	push   %ebx
  80067c:	83 ec 14             	sub    $0x14,%esp
  80067f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800682:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800685:	50                   	push   %eax
  800686:	53                   	push   %ebx
  800687:	e8 86 fd ff ff       	call   800412 <fd_lookup>
  80068c:	83 c4 08             	add    $0x8,%esp
  80068f:	89 c2                	mov    %eax,%edx
  800691:	85 c0                	test   %eax,%eax
  800693:	78 6d                	js     800702 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80069b:	50                   	push   %eax
  80069c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069f:	ff 30                	pushl  (%eax)
  8006a1:	e8 c2 fd ff ff       	call   800468 <dev_lookup>
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	78 4c                	js     8006f9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006b0:	8b 42 08             	mov    0x8(%edx),%eax
  8006b3:	83 e0 03             	and    $0x3,%eax
  8006b6:	83 f8 01             	cmp    $0x1,%eax
  8006b9:	75 21                	jne    8006dc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8006c0:	8b 40 48             	mov    0x48(%eax),%eax
  8006c3:	83 ec 04             	sub    $0x4,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	50                   	push   %eax
  8006c8:	68 99 1e 80 00       	push   $0x801e99
  8006cd:	e8 8d 0a 00 00       	call   80115f <cprintf>
		return -E_INVAL;
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006da:	eb 26                	jmp    800702 <read+0x8a>
	}
	if (!dev->dev_read)
  8006dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006df:	8b 40 08             	mov    0x8(%eax),%eax
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	74 17                	je     8006fd <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8006e6:	83 ec 04             	sub    $0x4,%esp
  8006e9:	ff 75 10             	pushl  0x10(%ebp)
  8006ec:	ff 75 0c             	pushl  0xc(%ebp)
  8006ef:	52                   	push   %edx
  8006f0:	ff d0                	call   *%eax
  8006f2:	89 c2                	mov    %eax,%edx
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb 09                	jmp    800702 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f9:	89 c2                	mov    %eax,%edx
  8006fb:	eb 05                	jmp    800702 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800702:	89 d0                	mov    %edx,%eax
  800704:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800707:	c9                   	leave  
  800708:	c3                   	ret    

00800709 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	57                   	push   %edi
  80070d:	56                   	push   %esi
  80070e:	53                   	push   %ebx
  80070f:	83 ec 0c             	sub    $0xc,%esp
  800712:	8b 7d 08             	mov    0x8(%ebp),%edi
  800715:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800718:	bb 00 00 00 00       	mov    $0x0,%ebx
  80071d:	eb 21                	jmp    800740 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80071f:	83 ec 04             	sub    $0x4,%esp
  800722:	89 f0                	mov    %esi,%eax
  800724:	29 d8                	sub    %ebx,%eax
  800726:	50                   	push   %eax
  800727:	89 d8                	mov    %ebx,%eax
  800729:	03 45 0c             	add    0xc(%ebp),%eax
  80072c:	50                   	push   %eax
  80072d:	57                   	push   %edi
  80072e:	e8 45 ff ff ff       	call   800678 <read>
		if (m < 0)
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	85 c0                	test   %eax,%eax
  800738:	78 10                	js     80074a <readn+0x41>
			return m;
		if (m == 0)
  80073a:	85 c0                	test   %eax,%eax
  80073c:	74 0a                	je     800748 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80073e:	01 c3                	add    %eax,%ebx
  800740:	39 f3                	cmp    %esi,%ebx
  800742:	72 db                	jb     80071f <readn+0x16>
  800744:	89 d8                	mov    %ebx,%eax
  800746:	eb 02                	jmp    80074a <readn+0x41>
  800748:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80074a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	53                   	push   %ebx
  800756:	83 ec 14             	sub    $0x14,%esp
  800759:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80075f:	50                   	push   %eax
  800760:	53                   	push   %ebx
  800761:	e8 ac fc ff ff       	call   800412 <fd_lookup>
  800766:	83 c4 08             	add    $0x8,%esp
  800769:	89 c2                	mov    %eax,%edx
  80076b:	85 c0                	test   %eax,%eax
  80076d:	78 68                	js     8007d7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800775:	50                   	push   %eax
  800776:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800779:	ff 30                	pushl  (%eax)
  80077b:	e8 e8 fc ff ff       	call   800468 <dev_lookup>
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	85 c0                	test   %eax,%eax
  800785:	78 47                	js     8007ce <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80078e:	75 21                	jne    8007b1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800790:	a1 04 40 80 00       	mov    0x804004,%eax
  800795:	8b 40 48             	mov    0x48(%eax),%eax
  800798:	83 ec 04             	sub    $0x4,%esp
  80079b:	53                   	push   %ebx
  80079c:	50                   	push   %eax
  80079d:	68 b5 1e 80 00       	push   $0x801eb5
  8007a2:	e8 b8 09 00 00       	call   80115f <cprintf>
		return -E_INVAL;
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007af:	eb 26                	jmp    8007d7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b4:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	74 17                	je     8007d2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007bb:	83 ec 04             	sub    $0x4,%esp
  8007be:	ff 75 10             	pushl  0x10(%ebp)
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	50                   	push   %eax
  8007c5:	ff d2                	call   *%edx
  8007c7:	89 c2                	mov    %eax,%edx
  8007c9:	83 c4 10             	add    $0x10,%esp
  8007cc:	eb 09                	jmp    8007d7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ce:	89 c2                	mov    %eax,%edx
  8007d0:	eb 05                	jmp    8007d7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007d7:	89 d0                	mov    %edx,%eax
  8007d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <seek>:

int
seek(int fdnum, off_t offset)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e7:	50                   	push   %eax
  8007e8:	ff 75 08             	pushl  0x8(%ebp)
  8007eb:	e8 22 fc ff ff       	call   800412 <fd_lookup>
  8007f0:	83 c4 08             	add    $0x8,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 0e                	js     800805 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	83 ec 14             	sub    $0x14,%esp
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800811:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800814:	50                   	push   %eax
  800815:	53                   	push   %ebx
  800816:	e8 f7 fb ff ff       	call   800412 <fd_lookup>
  80081b:	83 c4 08             	add    $0x8,%esp
  80081e:	89 c2                	mov    %eax,%edx
  800820:	85 c0                	test   %eax,%eax
  800822:	78 65                	js     800889 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082a:	50                   	push   %eax
  80082b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082e:	ff 30                	pushl  (%eax)
  800830:	e8 33 fc ff ff       	call   800468 <dev_lookup>
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	85 c0                	test   %eax,%eax
  80083a:	78 44                	js     800880 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80083c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800843:	75 21                	jne    800866 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800845:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80084a:	8b 40 48             	mov    0x48(%eax),%eax
  80084d:	83 ec 04             	sub    $0x4,%esp
  800850:	53                   	push   %ebx
  800851:	50                   	push   %eax
  800852:	68 78 1e 80 00       	push   $0x801e78
  800857:	e8 03 09 00 00       	call   80115f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800864:	eb 23                	jmp    800889 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800866:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800869:	8b 52 18             	mov    0x18(%edx),%edx
  80086c:	85 d2                	test   %edx,%edx
  80086e:	74 14                	je     800884 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	ff 75 0c             	pushl  0xc(%ebp)
  800876:	50                   	push   %eax
  800877:	ff d2                	call   *%edx
  800879:	89 c2                	mov    %eax,%edx
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	eb 09                	jmp    800889 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800880:	89 c2                	mov    %eax,%edx
  800882:	eb 05                	jmp    800889 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800884:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800889:	89 d0                	mov    %edx,%eax
  80088b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	83 ec 14             	sub    $0x14,%esp
  800897:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80089d:	50                   	push   %eax
  80089e:	ff 75 08             	pushl  0x8(%ebp)
  8008a1:	e8 6c fb ff ff       	call   800412 <fd_lookup>
  8008a6:	83 c4 08             	add    $0x8,%esp
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	85 c0                	test   %eax,%eax
  8008ad:	78 58                	js     800907 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008af:	83 ec 08             	sub    $0x8,%esp
  8008b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b5:	50                   	push   %eax
  8008b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b9:	ff 30                	pushl  (%eax)
  8008bb:	e8 a8 fb ff ff       	call   800468 <dev_lookup>
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	78 37                	js     8008fe <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ca:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ce:	74 32                	je     800902 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008d0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008da:	00 00 00 
	stat->st_isdir = 0;
  8008dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e4:	00 00 00 
	stat->st_dev = dev;
  8008e7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	53                   	push   %ebx
  8008f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8008f4:	ff 50 14             	call   *0x14(%eax)
  8008f7:	89 c2                	mov    %eax,%edx
  8008f9:	83 c4 10             	add    $0x10,%esp
  8008fc:	eb 09                	jmp    800907 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008fe:	89 c2                	mov    %eax,%edx
  800900:	eb 05                	jmp    800907 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800902:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800907:	89 d0                	mov    %edx,%eax
  800909:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090c:	c9                   	leave  
  80090d:	c3                   	ret    

0080090e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	6a 00                	push   $0x0
  800918:	ff 75 08             	pushl  0x8(%ebp)
  80091b:	e8 e3 01 00 00       	call   800b03 <open>
  800920:	89 c3                	mov    %eax,%ebx
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	85 c0                	test   %eax,%eax
  800927:	78 1b                	js     800944 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800929:	83 ec 08             	sub    $0x8,%esp
  80092c:	ff 75 0c             	pushl  0xc(%ebp)
  80092f:	50                   	push   %eax
  800930:	e8 5b ff ff ff       	call   800890 <fstat>
  800935:	89 c6                	mov    %eax,%esi
	close(fd);
  800937:	89 1c 24             	mov    %ebx,(%esp)
  80093a:	e8 fd fb ff ff       	call   80053c <close>
	return r;
  80093f:	83 c4 10             	add    $0x10,%esp
  800942:	89 f0                	mov    %esi,%eax
}
  800944:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800947:	5b                   	pop    %ebx
  800948:	5e                   	pop    %esi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	56                   	push   %esi
  80094f:	53                   	push   %ebx
  800950:	89 c6                	mov    %eax,%esi
  800952:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800954:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80095b:	75 12                	jne    80096f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80095d:	83 ec 0c             	sub    $0xc,%esp
  800960:	6a 01                	push   $0x1
  800962:	e8 98 11 00 00       	call   801aff <ipc_find_env>
  800967:	a3 00 40 80 00       	mov    %eax,0x804000
  80096c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80096f:	6a 07                	push   $0x7
  800971:	68 00 50 80 00       	push   $0x805000
  800976:	56                   	push   %esi
  800977:	ff 35 00 40 80 00    	pushl  0x804000
  80097d:	e8 1b 11 00 00       	call   801a9d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800982:	83 c4 0c             	add    $0xc,%esp
  800985:	6a 00                	push   $0x0
  800987:	53                   	push   %ebx
  800988:	6a 00                	push   $0x0
  80098a:	e8 9c 10 00 00       	call   801a2b <ipc_recv>
}
  80098f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009aa:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b9:	e8 8d ff ff ff       	call   80094b <fsipc>
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d6:	b8 06 00 00 00       	mov    $0x6,%eax
  8009db:	e8 6b ff ff ff       	call   80094b <fsipc>
}
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	53                   	push   %ebx
  8009e6:	83 ec 04             	sub    $0x4,%esp
  8009e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fc:	b8 05 00 00 00       	mov    $0x5,%eax
  800a01:	e8 45 ff ff ff       	call   80094b <fsipc>
  800a06:	85 c0                	test   %eax,%eax
  800a08:	78 2c                	js     800a36 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a0a:	83 ec 08             	sub    $0x8,%esp
  800a0d:	68 00 50 80 00       	push   $0x805000
  800a12:	53                   	push   %ebx
  800a13:	e8 cc 0c 00 00       	call   8016e4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a18:	a1 80 50 80 00       	mov    0x805080,%eax
  800a1d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a23:	a1 84 50 80 00       	mov    0x805084,%eax
  800a28:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a2e:	83 c4 10             	add    $0x10,%esp
  800a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	83 ec 0c             	sub    $0xc,%esp
  800a41:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a44:	8b 55 08             	mov    0x8(%ebp),%edx
  800a47:	8b 52 0c             	mov    0xc(%edx),%edx
  800a4a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a50:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a55:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a5a:	0f 47 c2             	cmova  %edx,%eax
  800a5d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a62:	50                   	push   %eax
  800a63:	ff 75 0c             	pushl  0xc(%ebp)
  800a66:	68 08 50 80 00       	push   $0x805008
  800a6b:	e8 06 0e 00 00       	call   801876 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a70:	ba 00 00 00 00       	mov    $0x0,%edx
  800a75:	b8 04 00 00 00       	mov    $0x4,%eax
  800a7a:	e8 cc fe ff ff       	call   80094b <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800a7f:	c9                   	leave  
  800a80:	c3                   	ret    

00800a81 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a89:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a94:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa4:	e8 a2 fe ff ff       	call   80094b <fsipc>
  800aa9:	89 c3                	mov    %eax,%ebx
  800aab:	85 c0                	test   %eax,%eax
  800aad:	78 4b                	js     800afa <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aaf:	39 c6                	cmp    %eax,%esi
  800ab1:	73 16                	jae    800ac9 <devfile_read+0x48>
  800ab3:	68 e4 1e 80 00       	push   $0x801ee4
  800ab8:	68 eb 1e 80 00       	push   $0x801eeb
  800abd:	6a 7c                	push   $0x7c
  800abf:	68 00 1f 80 00       	push   $0x801f00
  800ac4:	e8 bd 05 00 00       	call   801086 <_panic>
	assert(r <= PGSIZE);
  800ac9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ace:	7e 16                	jle    800ae6 <devfile_read+0x65>
  800ad0:	68 0b 1f 80 00       	push   $0x801f0b
  800ad5:	68 eb 1e 80 00       	push   $0x801eeb
  800ada:	6a 7d                	push   $0x7d
  800adc:	68 00 1f 80 00       	push   $0x801f00
  800ae1:	e8 a0 05 00 00       	call   801086 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae6:	83 ec 04             	sub    $0x4,%esp
  800ae9:	50                   	push   %eax
  800aea:	68 00 50 80 00       	push   $0x805000
  800aef:	ff 75 0c             	pushl  0xc(%ebp)
  800af2:	e8 7f 0d 00 00       	call   801876 <memmove>
	return r;
  800af7:	83 c4 10             	add    $0x10,%esp
}
  800afa:	89 d8                	mov    %ebx,%eax
  800afc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	53                   	push   %ebx
  800b07:	83 ec 20             	sub    $0x20,%esp
  800b0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b0d:	53                   	push   %ebx
  800b0e:	e8 98 0b 00 00       	call   8016ab <strlen>
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b1b:	7f 67                	jg     800b84 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b23:	50                   	push   %eax
  800b24:	e8 9a f8 ff ff       	call   8003c3 <fd_alloc>
  800b29:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 57                	js     800b89 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b32:	83 ec 08             	sub    $0x8,%esp
  800b35:	53                   	push   %ebx
  800b36:	68 00 50 80 00       	push   $0x805000
  800b3b:	e8 a4 0b 00 00       	call   8016e4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b50:	e8 f6 fd ff ff       	call   80094b <fsipc>
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	79 14                	jns    800b72 <open+0x6f>
		fd_close(fd, 0);
  800b5e:	83 ec 08             	sub    $0x8,%esp
  800b61:	6a 00                	push   $0x0
  800b63:	ff 75 f4             	pushl  -0xc(%ebp)
  800b66:	e8 50 f9 ff ff       	call   8004bb <fd_close>
		return r;
  800b6b:	83 c4 10             	add    $0x10,%esp
  800b6e:	89 da                	mov    %ebx,%edx
  800b70:	eb 17                	jmp    800b89 <open+0x86>
	}

	return fd2num(fd);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	ff 75 f4             	pushl  -0xc(%ebp)
  800b78:	e8 1f f8 ff ff       	call   80039c <fd2num>
  800b7d:	89 c2                	mov    %eax,%edx
  800b7f:	83 c4 10             	add    $0x10,%esp
  800b82:	eb 05                	jmp    800b89 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b84:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b89:	89 d0                	mov    %edx,%eax
  800b8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba0:	e8 a6 fd ff ff       	call   80094b <fsipc>
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800baf:	83 ec 0c             	sub    $0xc,%esp
  800bb2:	ff 75 08             	pushl  0x8(%ebp)
  800bb5:	e8 f2 f7 ff ff       	call   8003ac <fd2data>
  800bba:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bbc:	83 c4 08             	add    $0x8,%esp
  800bbf:	68 17 1f 80 00       	push   $0x801f17
  800bc4:	53                   	push   %ebx
  800bc5:	e8 1a 0b 00 00       	call   8016e4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bca:	8b 46 04             	mov    0x4(%esi),%eax
  800bcd:	2b 06                	sub    (%esi),%eax
  800bcf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bdc:	00 00 00 
	stat->st_dev = &devpipe;
  800bdf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be6:	30 80 00 
	return 0;
}
  800be9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bff:	53                   	push   %ebx
  800c00:	6a 00                	push   $0x0
  800c02:	e8 29 f6 ff ff       	call   800230 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c07:	89 1c 24             	mov    %ebx,(%esp)
  800c0a:	e8 9d f7 ff ff       	call   8003ac <fd2data>
  800c0f:	83 c4 08             	add    $0x8,%esp
  800c12:	50                   	push   %eax
  800c13:	6a 00                	push   $0x0
  800c15:	e8 16 f6 ff ff       	call   800230 <sys_page_unmap>
}
  800c1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 1c             	sub    $0x1c,%esp
  800c28:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c2b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c2d:	a1 04 40 80 00       	mov    0x804004,%eax
  800c32:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c35:	83 ec 0c             	sub    $0xc,%esp
  800c38:	ff 75 e0             	pushl  -0x20(%ebp)
  800c3b:	e8 f8 0e 00 00       	call   801b38 <pageref>
  800c40:	89 c3                	mov    %eax,%ebx
  800c42:	89 3c 24             	mov    %edi,(%esp)
  800c45:	e8 ee 0e 00 00       	call   801b38 <pageref>
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	39 c3                	cmp    %eax,%ebx
  800c4f:	0f 94 c1             	sete   %cl
  800c52:	0f b6 c9             	movzbl %cl,%ecx
  800c55:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c58:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c5e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c61:	39 ce                	cmp    %ecx,%esi
  800c63:	74 1b                	je     800c80 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c65:	39 c3                	cmp    %eax,%ebx
  800c67:	75 c4                	jne    800c2d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c69:	8b 42 58             	mov    0x58(%edx),%eax
  800c6c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c6f:	50                   	push   %eax
  800c70:	56                   	push   %esi
  800c71:	68 1e 1f 80 00       	push   $0x801f1e
  800c76:	e8 e4 04 00 00       	call   80115f <cprintf>
  800c7b:	83 c4 10             	add    $0x10,%esp
  800c7e:	eb ad                	jmp    800c2d <_pipeisclosed+0xe>
	}
}
  800c80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c86:	5b                   	pop    %ebx
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 28             	sub    $0x28,%esp
  800c94:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c97:	56                   	push   %esi
  800c98:	e8 0f f7 ff ff       	call   8003ac <fd2data>
  800c9d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9f:	83 c4 10             	add    $0x10,%esp
  800ca2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca7:	eb 4b                	jmp    800cf4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ca9:	89 da                	mov    %ebx,%edx
  800cab:	89 f0                	mov    %esi,%eax
  800cad:	e8 6d ff ff ff       	call   800c1f <_pipeisclosed>
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	75 48                	jne    800cfe <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cb6:	e8 d1 f4 ff ff       	call   80018c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cbb:	8b 43 04             	mov    0x4(%ebx),%eax
  800cbe:	8b 0b                	mov    (%ebx),%ecx
  800cc0:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc3:	39 d0                	cmp    %edx,%eax
  800cc5:	73 e2                	jae    800ca9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cce:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd1:	89 c2                	mov    %eax,%edx
  800cd3:	c1 fa 1f             	sar    $0x1f,%edx
  800cd6:	89 d1                	mov    %edx,%ecx
  800cd8:	c1 e9 1b             	shr    $0x1b,%ecx
  800cdb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cde:	83 e2 1f             	and    $0x1f,%edx
  800ce1:	29 ca                	sub    %ecx,%edx
  800ce3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ce7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ceb:	83 c0 01             	add    $0x1,%eax
  800cee:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf1:	83 c7 01             	add    $0x1,%edi
  800cf4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf7:	75 c2                	jne    800cbb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cf9:	8b 45 10             	mov    0x10(%ebp),%eax
  800cfc:	eb 05                	jmp    800d03 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cfe:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 18             	sub    $0x18,%esp
  800d14:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d17:	57                   	push   %edi
  800d18:	e8 8f f6 ff ff       	call   8003ac <fd2data>
  800d1d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1f:	83 c4 10             	add    $0x10,%esp
  800d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d27:	eb 3d                	jmp    800d66 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d29:	85 db                	test   %ebx,%ebx
  800d2b:	74 04                	je     800d31 <devpipe_read+0x26>
				return i;
  800d2d:	89 d8                	mov    %ebx,%eax
  800d2f:	eb 44                	jmp    800d75 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d31:	89 f2                	mov    %esi,%edx
  800d33:	89 f8                	mov    %edi,%eax
  800d35:	e8 e5 fe ff ff       	call   800c1f <_pipeisclosed>
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	75 32                	jne    800d70 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d3e:	e8 49 f4 ff ff       	call   80018c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d43:	8b 06                	mov    (%esi),%eax
  800d45:	3b 46 04             	cmp    0x4(%esi),%eax
  800d48:	74 df                	je     800d29 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d4a:	99                   	cltd   
  800d4b:	c1 ea 1b             	shr    $0x1b,%edx
  800d4e:	01 d0                	add    %edx,%eax
  800d50:	83 e0 1f             	and    $0x1f,%eax
  800d53:	29 d0                	sub    %edx,%eax
  800d55:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d60:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d63:	83 c3 01             	add    $0x1,%ebx
  800d66:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d69:	75 d8                	jne    800d43 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d6b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6e:	eb 05                	jmp    800d75 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d70:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
  800d82:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d88:	50                   	push   %eax
  800d89:	e8 35 f6 ff ff       	call   8003c3 <fd_alloc>
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	85 c0                	test   %eax,%eax
  800d95:	0f 88 2c 01 00 00    	js     800ec7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	68 07 04 00 00       	push   $0x407
  800da3:	ff 75 f4             	pushl  -0xc(%ebp)
  800da6:	6a 00                	push   $0x0
  800da8:	e8 fe f3 ff ff       	call   8001ab <sys_page_alloc>
  800dad:	83 c4 10             	add    $0x10,%esp
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	85 c0                	test   %eax,%eax
  800db4:	0f 88 0d 01 00 00    	js     800ec7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc0:	50                   	push   %eax
  800dc1:	e8 fd f5 ff ff       	call   8003c3 <fd_alloc>
  800dc6:	89 c3                	mov    %eax,%ebx
  800dc8:	83 c4 10             	add    $0x10,%esp
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	0f 88 e2 00 00 00    	js     800eb5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd3:	83 ec 04             	sub    $0x4,%esp
  800dd6:	68 07 04 00 00       	push   $0x407
  800ddb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dde:	6a 00                	push   $0x0
  800de0:	e8 c6 f3 ff ff       	call   8001ab <sys_page_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 c3 00 00 00    	js     800eb5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	ff 75 f4             	pushl  -0xc(%ebp)
  800df8:	e8 af f5 ff ff       	call   8003ac <fd2data>
  800dfd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dff:	83 c4 0c             	add    $0xc,%esp
  800e02:	68 07 04 00 00       	push   $0x407
  800e07:	50                   	push   %eax
  800e08:	6a 00                	push   $0x0
  800e0a:	e8 9c f3 ff ff       	call   8001ab <sys_page_alloc>
  800e0f:	89 c3                	mov    %eax,%ebx
  800e11:	83 c4 10             	add    $0x10,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	0f 88 89 00 00 00    	js     800ea5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1c:	83 ec 0c             	sub    $0xc,%esp
  800e1f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e22:	e8 85 f5 ff ff       	call   8003ac <fd2data>
  800e27:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e2e:	50                   	push   %eax
  800e2f:	6a 00                	push   $0x0
  800e31:	56                   	push   %esi
  800e32:	6a 00                	push   $0x0
  800e34:	e8 b5 f3 ff ff       	call   8001ee <sys_page_map>
  800e39:	89 c3                	mov    %eax,%ebx
  800e3b:	83 c4 20             	add    $0x20,%esp
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	78 55                	js     800e97 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e42:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e50:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e57:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e60:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e65:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e72:	e8 25 f5 ff ff       	call   80039c <fd2num>
  800e77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e7c:	83 c4 04             	add    $0x4,%esp
  800e7f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e82:	e8 15 f5 ff ff       	call   80039c <fd2num>
  800e87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	ba 00 00 00 00       	mov    $0x0,%edx
  800e95:	eb 30                	jmp    800ec7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e97:	83 ec 08             	sub    $0x8,%esp
  800e9a:	56                   	push   %esi
  800e9b:	6a 00                	push   $0x0
  800e9d:	e8 8e f3 ff ff       	call   800230 <sys_page_unmap>
  800ea2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea5:	83 ec 08             	sub    $0x8,%esp
  800ea8:	ff 75 f0             	pushl  -0x10(%ebp)
  800eab:	6a 00                	push   $0x0
  800ead:	e8 7e f3 ff ff       	call   800230 <sys_page_unmap>
  800eb2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebb:	6a 00                	push   $0x0
  800ebd:	e8 6e f3 ff ff       	call   800230 <sys_page_unmap>
  800ec2:	83 c4 10             	add    $0x10,%esp
  800ec5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ec7:	89 d0                	mov    %edx,%eax
  800ec9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed9:	50                   	push   %eax
  800eda:	ff 75 08             	pushl  0x8(%ebp)
  800edd:	e8 30 f5 ff ff       	call   800412 <fd_lookup>
  800ee2:	83 c4 10             	add    $0x10,%esp
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	78 18                	js     800f01 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ee9:	83 ec 0c             	sub    $0xc,%esp
  800eec:	ff 75 f4             	pushl  -0xc(%ebp)
  800eef:	e8 b8 f4 ff ff       	call   8003ac <fd2data>
	return _pipeisclosed(fd, p);
  800ef4:	89 c2                	mov    %eax,%edx
  800ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef9:	e8 21 fd ff ff       	call   800c1f <_pipeisclosed>
  800efe:	83 c4 10             	add    $0x10,%esp
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f06:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f13:	68 36 1f 80 00       	push   $0x801f36
  800f18:	ff 75 0c             	pushl  0xc(%ebp)
  800f1b:	e8 c4 07 00 00       	call   8016e4 <strcpy>
	return 0;
}
  800f20:	b8 00 00 00 00       	mov    $0x0,%eax
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f33:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f38:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3e:	eb 2d                	jmp    800f6d <devcons_write+0x46>
		m = n - tot;
  800f40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f43:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f45:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f48:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f4d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f50:	83 ec 04             	sub    $0x4,%esp
  800f53:	53                   	push   %ebx
  800f54:	03 45 0c             	add    0xc(%ebp),%eax
  800f57:	50                   	push   %eax
  800f58:	57                   	push   %edi
  800f59:	e8 18 09 00 00       	call   801876 <memmove>
		sys_cputs(buf, m);
  800f5e:	83 c4 08             	add    $0x8,%esp
  800f61:	53                   	push   %ebx
  800f62:	57                   	push   %edi
  800f63:	e8 87 f1 ff ff       	call   8000ef <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f68:	01 de                	add    %ebx,%esi
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	89 f0                	mov    %esi,%eax
  800f6f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f72:	72 cc                	jb     800f40 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 08             	sub    $0x8,%esp
  800f82:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f87:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f8b:	74 2a                	je     800fb7 <devcons_read+0x3b>
  800f8d:	eb 05                	jmp    800f94 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f8f:	e8 f8 f1 ff ff       	call   80018c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f94:	e8 74 f1 ff ff       	call   80010d <sys_cgetc>
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	74 f2                	je     800f8f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	78 16                	js     800fb7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa1:	83 f8 04             	cmp    $0x4,%eax
  800fa4:	74 0c                	je     800fb2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fa6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa9:	88 02                	mov    %al,(%edx)
	return 1;
  800fab:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb0:	eb 05                	jmp    800fb7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fc5:	6a 01                	push   $0x1
  800fc7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fca:	50                   	push   %eax
  800fcb:	e8 1f f1 ff ff       	call   8000ef <sys_cputs>
}
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <getchar>:

int
getchar(void)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fdb:	6a 01                	push   $0x1
  800fdd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	6a 00                	push   $0x0
  800fe3:	e8 90 f6 ff ff       	call   800678 <read>
	if (r < 0)
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 0f                	js     800ffe <getchar+0x29>
		return r;
	if (r < 1)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	7e 06                	jle    800ff9 <getchar+0x24>
		return -E_EOF;
	return c;
  800ff3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ff7:	eb 05                	jmp    800ffe <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ff9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    

00801000 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801006:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801009:	50                   	push   %eax
  80100a:	ff 75 08             	pushl  0x8(%ebp)
  80100d:	e8 00 f4 ff ff       	call   800412 <fd_lookup>
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	85 c0                	test   %eax,%eax
  801017:	78 11                	js     80102a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801019:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801022:	39 10                	cmp    %edx,(%eax)
  801024:	0f 94 c0             	sete   %al
  801027:	0f b6 c0             	movzbl %al,%eax
}
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <opencons>:

int
opencons(void)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801032:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801035:	50                   	push   %eax
  801036:	e8 88 f3 ff ff       	call   8003c3 <fd_alloc>
  80103b:	83 c4 10             	add    $0x10,%esp
		return r;
  80103e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801040:	85 c0                	test   %eax,%eax
  801042:	78 3e                	js     801082 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801044:	83 ec 04             	sub    $0x4,%esp
  801047:	68 07 04 00 00       	push   $0x407
  80104c:	ff 75 f4             	pushl  -0xc(%ebp)
  80104f:	6a 00                	push   $0x0
  801051:	e8 55 f1 ff ff       	call   8001ab <sys_page_alloc>
  801056:	83 c4 10             	add    $0x10,%esp
		return r;
  801059:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 23                	js     801082 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80105f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801068:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80106a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	50                   	push   %eax
  801078:	e8 1f f3 ff ff       	call   80039c <fd2num>
  80107d:	89 c2                	mov    %eax,%edx
  80107f:	83 c4 10             	add    $0x10,%esp
}
  801082:	89 d0                	mov    %edx,%eax
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80108b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80108e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801094:	e8 d4 f0 ff ff       	call   80016d <sys_getenvid>
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	ff 75 0c             	pushl  0xc(%ebp)
  80109f:	ff 75 08             	pushl  0x8(%ebp)
  8010a2:	56                   	push   %esi
  8010a3:	50                   	push   %eax
  8010a4:	68 44 1f 80 00       	push   $0x801f44
  8010a9:	e8 b1 00 00 00       	call   80115f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010ae:	83 c4 18             	add    $0x18,%esp
  8010b1:	53                   	push   %ebx
  8010b2:	ff 75 10             	pushl  0x10(%ebp)
  8010b5:	e8 54 00 00 00       	call   80110e <vcprintf>
	cprintf("\n");
  8010ba:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  8010c1:	e8 99 00 00 00       	call   80115f <cprintf>
  8010c6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c9:	cc                   	int3   
  8010ca:	eb fd                	jmp    8010c9 <_panic+0x43>

008010cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	53                   	push   %ebx
  8010d0:	83 ec 04             	sub    $0x4,%esp
  8010d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d6:	8b 13                	mov    (%ebx),%edx
  8010d8:	8d 42 01             	lea    0x1(%edx),%eax
  8010db:	89 03                	mov    %eax,(%ebx)
  8010dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e9:	75 1a                	jne    801105 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010eb:	83 ec 08             	sub    $0x8,%esp
  8010ee:	68 ff 00 00 00       	push   $0xff
  8010f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f6:	50                   	push   %eax
  8010f7:	e8 f3 ef ff ff       	call   8000ef <sys_cputs>
		b->idx = 0;
  8010fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801102:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801105:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801109:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110c:	c9                   	leave  
  80110d:	c3                   	ret    

0080110e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801117:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80111e:	00 00 00 
	b.cnt = 0;
  801121:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801128:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80112b:	ff 75 0c             	pushl  0xc(%ebp)
  80112e:	ff 75 08             	pushl  0x8(%ebp)
  801131:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801137:	50                   	push   %eax
  801138:	68 cc 10 80 00       	push   $0x8010cc
  80113d:	e8 54 01 00 00       	call   801296 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801142:	83 c4 08             	add    $0x8,%esp
  801145:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80114b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	e8 98 ef ff ff       	call   8000ef <sys_cputs>

	return b.cnt;
}
  801157:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    

0080115f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801165:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801168:	50                   	push   %eax
  801169:	ff 75 08             	pushl  0x8(%ebp)
  80116c:	e8 9d ff ff ff       	call   80110e <vcprintf>
	va_end(ap);

	return cnt;
}
  801171:	c9                   	leave  
  801172:	c3                   	ret    

00801173 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 1c             	sub    $0x1c,%esp
  80117c:	89 c7                	mov    %eax,%edi
  80117e:	89 d6                	mov    %edx,%esi
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	8b 55 0c             	mov    0xc(%ebp),%edx
  801186:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801189:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80118c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80118f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801194:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801197:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80119a:	39 d3                	cmp    %edx,%ebx
  80119c:	72 05                	jb     8011a3 <printnum+0x30>
  80119e:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011a1:	77 45                	ja     8011e8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	ff 75 18             	pushl  0x18(%ebp)
  8011a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8011ac:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011af:	53                   	push   %ebx
  8011b0:	ff 75 10             	pushl  0x10(%ebp)
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8011bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c2:	e8 b9 09 00 00       	call   801b80 <__udivdi3>
  8011c7:	83 c4 18             	add    $0x18,%esp
  8011ca:	52                   	push   %edx
  8011cb:	50                   	push   %eax
  8011cc:	89 f2                	mov    %esi,%edx
  8011ce:	89 f8                	mov    %edi,%eax
  8011d0:	e8 9e ff ff ff       	call   801173 <printnum>
  8011d5:	83 c4 20             	add    $0x20,%esp
  8011d8:	eb 18                	jmp    8011f2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	56                   	push   %esi
  8011de:	ff 75 18             	pushl  0x18(%ebp)
  8011e1:	ff d7                	call   *%edi
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	eb 03                	jmp    8011eb <printnum+0x78>
  8011e8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011eb:	83 eb 01             	sub    $0x1,%ebx
  8011ee:	85 db                	test   %ebx,%ebx
  8011f0:	7f e8                	jg     8011da <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f2:	83 ec 08             	sub    $0x8,%esp
  8011f5:	56                   	push   %esi
  8011f6:	83 ec 04             	sub    $0x4,%esp
  8011f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ff:	ff 75 dc             	pushl  -0x24(%ebp)
  801202:	ff 75 d8             	pushl  -0x28(%ebp)
  801205:	e8 a6 0a 00 00       	call   801cb0 <__umoddi3>
  80120a:	83 c4 14             	add    $0x14,%esp
  80120d:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  801214:	50                   	push   %eax
  801215:	ff d7                	call   *%edi
}
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801225:	83 fa 01             	cmp    $0x1,%edx
  801228:	7e 0e                	jle    801238 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80122a:	8b 10                	mov    (%eax),%edx
  80122c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80122f:	89 08                	mov    %ecx,(%eax)
  801231:	8b 02                	mov    (%edx),%eax
  801233:	8b 52 04             	mov    0x4(%edx),%edx
  801236:	eb 22                	jmp    80125a <getuint+0x38>
	else if (lflag)
  801238:	85 d2                	test   %edx,%edx
  80123a:	74 10                	je     80124c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80123c:	8b 10                	mov    (%eax),%edx
  80123e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801241:	89 08                	mov    %ecx,(%eax)
  801243:	8b 02                	mov    (%edx),%eax
  801245:	ba 00 00 00 00       	mov    $0x0,%edx
  80124a:	eb 0e                	jmp    80125a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80124c:	8b 10                	mov    (%eax),%edx
  80124e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801251:	89 08                	mov    %ecx,(%eax)
  801253:	8b 02                	mov    (%edx),%eax
  801255:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    

0080125c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80125c:	55                   	push   %ebp
  80125d:	89 e5                	mov    %esp,%ebp
  80125f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801262:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801266:	8b 10                	mov    (%eax),%edx
  801268:	3b 50 04             	cmp    0x4(%eax),%edx
  80126b:	73 0a                	jae    801277 <sprintputch+0x1b>
		*b->buf++ = ch;
  80126d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801270:	89 08                	mov    %ecx,(%eax)
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
  801275:	88 02                	mov    %al,(%edx)
}
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80127f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801282:	50                   	push   %eax
  801283:	ff 75 10             	pushl  0x10(%ebp)
  801286:	ff 75 0c             	pushl  0xc(%ebp)
  801289:	ff 75 08             	pushl  0x8(%ebp)
  80128c:	e8 05 00 00 00       	call   801296 <vprintfmt>
	va_end(ap);
}
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	57                   	push   %edi
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
  80129c:	83 ec 2c             	sub    $0x2c,%esp
  80129f:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a8:	eb 12                	jmp    8012bc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	0f 84 89 03 00 00    	je     80163b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012b2:	83 ec 08             	sub    $0x8,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	50                   	push   %eax
  8012b7:	ff d6                	call   *%esi
  8012b9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012bc:	83 c7 01             	add    $0x1,%edi
  8012bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012c3:	83 f8 25             	cmp    $0x25,%eax
  8012c6:	75 e2                	jne    8012aa <vprintfmt+0x14>
  8012c8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012cc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012d3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012da:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e6:	eb 07                	jmp    8012ef <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012eb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ef:	8d 47 01             	lea    0x1(%edi),%eax
  8012f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f5:	0f b6 07             	movzbl (%edi),%eax
  8012f8:	0f b6 c8             	movzbl %al,%ecx
  8012fb:	83 e8 23             	sub    $0x23,%eax
  8012fe:	3c 55                	cmp    $0x55,%al
  801300:	0f 87 1a 03 00 00    	ja     801620 <vprintfmt+0x38a>
  801306:	0f b6 c0             	movzbl %al,%eax
  801309:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  801310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801313:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801317:	eb d6                	jmp    8012ef <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
  801321:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801324:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801327:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80132b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80132e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801331:	83 fa 09             	cmp    $0x9,%edx
  801334:	77 39                	ja     80136f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801336:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801339:	eb e9                	jmp    801324 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80133b:	8b 45 14             	mov    0x14(%ebp),%eax
  80133e:	8d 48 04             	lea    0x4(%eax),%ecx
  801341:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801344:	8b 00                	mov    (%eax),%eax
  801346:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80134c:	eb 27                	jmp    801375 <vprintfmt+0xdf>
  80134e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801351:	85 c0                	test   %eax,%eax
  801353:	b9 00 00 00 00       	mov    $0x0,%ecx
  801358:	0f 49 c8             	cmovns %eax,%ecx
  80135b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801361:	eb 8c                	jmp    8012ef <vprintfmt+0x59>
  801363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801366:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80136d:	eb 80                	jmp    8012ef <vprintfmt+0x59>
  80136f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801372:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801375:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801379:	0f 89 70 ff ff ff    	jns    8012ef <vprintfmt+0x59>
				width = precision, precision = -1;
  80137f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801382:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801385:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80138c:	e9 5e ff ff ff       	jmp    8012ef <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801391:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801397:	e9 53 ff ff ff       	jmp    8012ef <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80139c:	8b 45 14             	mov    0x14(%ebp),%eax
  80139f:	8d 50 04             	lea    0x4(%eax),%edx
  8013a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a5:	83 ec 08             	sub    $0x8,%esp
  8013a8:	53                   	push   %ebx
  8013a9:	ff 30                	pushl  (%eax)
  8013ab:	ff d6                	call   *%esi
			break;
  8013ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013b3:	e9 04 ff ff ff       	jmp    8012bc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013bb:	8d 50 04             	lea    0x4(%eax),%edx
  8013be:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c1:	8b 00                	mov    (%eax),%eax
  8013c3:	99                   	cltd   
  8013c4:	31 d0                	xor    %edx,%eax
  8013c6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013c8:	83 f8 0f             	cmp    $0xf,%eax
  8013cb:	7f 0b                	jg     8013d8 <vprintfmt+0x142>
  8013cd:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  8013d4:	85 d2                	test   %edx,%edx
  8013d6:	75 18                	jne    8013f0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013d8:	50                   	push   %eax
  8013d9:	68 7f 1f 80 00       	push   $0x801f7f
  8013de:	53                   	push   %ebx
  8013df:	56                   	push   %esi
  8013e0:	e8 94 fe ff ff       	call   801279 <printfmt>
  8013e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013eb:	e9 cc fe ff ff       	jmp    8012bc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013f0:	52                   	push   %edx
  8013f1:	68 fd 1e 80 00       	push   $0x801efd
  8013f6:	53                   	push   %ebx
  8013f7:	56                   	push   %esi
  8013f8:	e8 7c fe ff ff       	call   801279 <printfmt>
  8013fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801400:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801403:	e9 b4 fe ff ff       	jmp    8012bc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801408:	8b 45 14             	mov    0x14(%ebp),%eax
  80140b:	8d 50 04             	lea    0x4(%eax),%edx
  80140e:	89 55 14             	mov    %edx,0x14(%ebp)
  801411:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801413:	85 ff                	test   %edi,%edi
  801415:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  80141a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80141d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801421:	0f 8e 94 00 00 00    	jle    8014bb <vprintfmt+0x225>
  801427:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80142b:	0f 84 98 00 00 00    	je     8014c9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801431:	83 ec 08             	sub    $0x8,%esp
  801434:	ff 75 d0             	pushl  -0x30(%ebp)
  801437:	57                   	push   %edi
  801438:	e8 86 02 00 00       	call   8016c3 <strnlen>
  80143d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801440:	29 c1                	sub    %eax,%ecx
  801442:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801445:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801448:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80144c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80144f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801452:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801454:	eb 0f                	jmp    801465 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	53                   	push   %ebx
  80145a:	ff 75 e0             	pushl  -0x20(%ebp)
  80145d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80145f:	83 ef 01             	sub    $0x1,%edi
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	85 ff                	test   %edi,%edi
  801467:	7f ed                	jg     801456 <vprintfmt+0x1c0>
  801469:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80146c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80146f:	85 c9                	test   %ecx,%ecx
  801471:	b8 00 00 00 00       	mov    $0x0,%eax
  801476:	0f 49 c1             	cmovns %ecx,%eax
  801479:	29 c1                	sub    %eax,%ecx
  80147b:	89 75 08             	mov    %esi,0x8(%ebp)
  80147e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801481:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801484:	89 cb                	mov    %ecx,%ebx
  801486:	eb 4d                	jmp    8014d5 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801488:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80148c:	74 1b                	je     8014a9 <vprintfmt+0x213>
  80148e:	0f be c0             	movsbl %al,%eax
  801491:	83 e8 20             	sub    $0x20,%eax
  801494:	83 f8 5e             	cmp    $0x5e,%eax
  801497:	76 10                	jbe    8014a9 <vprintfmt+0x213>
					putch('?', putdat);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	ff 75 0c             	pushl  0xc(%ebp)
  80149f:	6a 3f                	push   $0x3f
  8014a1:	ff 55 08             	call   *0x8(%ebp)
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	eb 0d                	jmp    8014b6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	ff 75 0c             	pushl  0xc(%ebp)
  8014af:	52                   	push   %edx
  8014b0:	ff 55 08             	call   *0x8(%ebp)
  8014b3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014b6:	83 eb 01             	sub    $0x1,%ebx
  8014b9:	eb 1a                	jmp    8014d5 <vprintfmt+0x23f>
  8014bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8014be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c7:	eb 0c                	jmp    8014d5 <vprintfmt+0x23f>
  8014c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8014cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014d5:	83 c7 01             	add    $0x1,%edi
  8014d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014dc:	0f be d0             	movsbl %al,%edx
  8014df:	85 d2                	test   %edx,%edx
  8014e1:	74 23                	je     801506 <vprintfmt+0x270>
  8014e3:	85 f6                	test   %esi,%esi
  8014e5:	78 a1                	js     801488 <vprintfmt+0x1f2>
  8014e7:	83 ee 01             	sub    $0x1,%esi
  8014ea:	79 9c                	jns    801488 <vprintfmt+0x1f2>
  8014ec:	89 df                	mov    %ebx,%edi
  8014ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014f4:	eb 18                	jmp    80150e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	53                   	push   %ebx
  8014fa:	6a 20                	push   $0x20
  8014fc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014fe:	83 ef 01             	sub    $0x1,%edi
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	eb 08                	jmp    80150e <vprintfmt+0x278>
  801506:	89 df                	mov    %ebx,%edi
  801508:	8b 75 08             	mov    0x8(%ebp),%esi
  80150b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80150e:	85 ff                	test   %edi,%edi
  801510:	7f e4                	jg     8014f6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801512:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801515:	e9 a2 fd ff ff       	jmp    8012bc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80151a:	83 fa 01             	cmp    $0x1,%edx
  80151d:	7e 16                	jle    801535 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80151f:	8b 45 14             	mov    0x14(%ebp),%eax
  801522:	8d 50 08             	lea    0x8(%eax),%edx
  801525:	89 55 14             	mov    %edx,0x14(%ebp)
  801528:	8b 50 04             	mov    0x4(%eax),%edx
  80152b:	8b 00                	mov    (%eax),%eax
  80152d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801530:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801533:	eb 32                	jmp    801567 <vprintfmt+0x2d1>
	else if (lflag)
  801535:	85 d2                	test   %edx,%edx
  801537:	74 18                	je     801551 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801539:	8b 45 14             	mov    0x14(%ebp),%eax
  80153c:	8d 50 04             	lea    0x4(%eax),%edx
  80153f:	89 55 14             	mov    %edx,0x14(%ebp)
  801542:	8b 00                	mov    (%eax),%eax
  801544:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801547:	89 c1                	mov    %eax,%ecx
  801549:	c1 f9 1f             	sar    $0x1f,%ecx
  80154c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80154f:	eb 16                	jmp    801567 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801551:	8b 45 14             	mov    0x14(%ebp),%eax
  801554:	8d 50 04             	lea    0x4(%eax),%edx
  801557:	89 55 14             	mov    %edx,0x14(%ebp)
  80155a:	8b 00                	mov    (%eax),%eax
  80155c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80155f:	89 c1                	mov    %eax,%ecx
  801561:	c1 f9 1f             	sar    $0x1f,%ecx
  801564:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801567:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80156a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80156d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801572:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801576:	79 74                	jns    8015ec <vprintfmt+0x356>
				putch('-', putdat);
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	53                   	push   %ebx
  80157c:	6a 2d                	push   $0x2d
  80157e:	ff d6                	call   *%esi
				num = -(long long) num;
  801580:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801583:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801586:	f7 d8                	neg    %eax
  801588:	83 d2 00             	adc    $0x0,%edx
  80158b:	f7 da                	neg    %edx
  80158d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801590:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801595:	eb 55                	jmp    8015ec <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801597:	8d 45 14             	lea    0x14(%ebp),%eax
  80159a:	e8 83 fc ff ff       	call   801222 <getuint>
			base = 10;
  80159f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015a4:	eb 46                	jmp    8015ec <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a9:	e8 74 fc ff ff       	call   801222 <getuint>
			base = 8;
  8015ae:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015b3:	eb 37                	jmp    8015ec <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b5:	83 ec 08             	sub    $0x8,%esp
  8015b8:	53                   	push   %ebx
  8015b9:	6a 30                	push   $0x30
  8015bb:	ff d6                	call   *%esi
			putch('x', putdat);
  8015bd:	83 c4 08             	add    $0x8,%esp
  8015c0:	53                   	push   %ebx
  8015c1:	6a 78                	push   $0x78
  8015c3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c8:	8d 50 04             	lea    0x4(%eax),%edx
  8015cb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015ce:	8b 00                	mov    (%eax),%eax
  8015d0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015d8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015dd:	eb 0d                	jmp    8015ec <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015df:	8d 45 14             	lea    0x14(%ebp),%eax
  8015e2:	e8 3b fc ff ff       	call   801222 <getuint>
			base = 16;
  8015e7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015ec:	83 ec 0c             	sub    $0xc,%esp
  8015ef:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015f3:	57                   	push   %edi
  8015f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f7:	51                   	push   %ecx
  8015f8:	52                   	push   %edx
  8015f9:	50                   	push   %eax
  8015fa:	89 da                	mov    %ebx,%edx
  8015fc:	89 f0                	mov    %esi,%eax
  8015fe:	e8 70 fb ff ff       	call   801173 <printnum>
			break;
  801603:	83 c4 20             	add    $0x20,%esp
  801606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801609:	e9 ae fc ff ff       	jmp    8012bc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	53                   	push   %ebx
  801612:	51                   	push   %ecx
  801613:	ff d6                	call   *%esi
			break;
  801615:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80161b:	e9 9c fc ff ff       	jmp    8012bc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801620:	83 ec 08             	sub    $0x8,%esp
  801623:	53                   	push   %ebx
  801624:	6a 25                	push   $0x25
  801626:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	eb 03                	jmp    801630 <vprintfmt+0x39a>
  80162d:	83 ef 01             	sub    $0x1,%edi
  801630:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801634:	75 f7                	jne    80162d <vprintfmt+0x397>
  801636:	e9 81 fc ff ff       	jmp    8012bc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80163b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80163e:	5b                   	pop    %ebx
  80163f:	5e                   	pop    %esi
  801640:	5f                   	pop    %edi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    

00801643 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	83 ec 18             	sub    $0x18,%esp
  801649:	8b 45 08             	mov    0x8(%ebp),%eax
  80164c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80164f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801652:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801656:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801659:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801660:	85 c0                	test   %eax,%eax
  801662:	74 26                	je     80168a <vsnprintf+0x47>
  801664:	85 d2                	test   %edx,%edx
  801666:	7e 22                	jle    80168a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801668:	ff 75 14             	pushl  0x14(%ebp)
  80166b:	ff 75 10             	pushl  0x10(%ebp)
  80166e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801671:	50                   	push   %eax
  801672:	68 5c 12 80 00       	push   $0x80125c
  801677:	e8 1a fc ff ff       	call   801296 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80167c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80167f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	eb 05                	jmp    80168f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80168a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80168f:	c9                   	leave  
  801690:	c3                   	ret    

00801691 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801697:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80169a:	50                   	push   %eax
  80169b:	ff 75 10             	pushl  0x10(%ebp)
  80169e:	ff 75 0c             	pushl  0xc(%ebp)
  8016a1:	ff 75 08             	pushl  0x8(%ebp)
  8016a4:	e8 9a ff ff ff       	call   801643 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    

008016ab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b6:	eb 03                	jmp    8016bb <strlen+0x10>
		n++;
  8016b8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016bf:	75 f7                	jne    8016b8 <strlen+0xd>
		n++;
	return n;
}
  8016c1:	5d                   	pop    %ebp
  8016c2:	c3                   	ret    

008016c3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d1:	eb 03                	jmp    8016d6 <strnlen+0x13>
		n++;
  8016d3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d6:	39 c2                	cmp    %eax,%edx
  8016d8:	74 08                	je     8016e2 <strnlen+0x1f>
  8016da:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016de:	75 f3                	jne    8016d3 <strnlen+0x10>
  8016e0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	53                   	push   %ebx
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ee:	89 c2                	mov    %eax,%edx
  8016f0:	83 c2 01             	add    $0x1,%edx
  8016f3:	83 c1 01             	add    $0x1,%ecx
  8016f6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016fa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016fd:	84 db                	test   %bl,%bl
  8016ff:	75 ef                	jne    8016f0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801701:	5b                   	pop    %ebx
  801702:	5d                   	pop    %ebp
  801703:	c3                   	ret    

00801704 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801704:	55                   	push   %ebp
  801705:	89 e5                	mov    %esp,%ebp
  801707:	53                   	push   %ebx
  801708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80170b:	53                   	push   %ebx
  80170c:	e8 9a ff ff ff       	call   8016ab <strlen>
  801711:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801714:	ff 75 0c             	pushl  0xc(%ebp)
  801717:	01 d8                	add    %ebx,%eax
  801719:	50                   	push   %eax
  80171a:	e8 c5 ff ff ff       	call   8016e4 <strcpy>
	return dst;
}
  80171f:	89 d8                	mov    %ebx,%eax
  801721:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	8b 75 08             	mov    0x8(%ebp),%esi
  80172e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801731:	89 f3                	mov    %esi,%ebx
  801733:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801736:	89 f2                	mov    %esi,%edx
  801738:	eb 0f                	jmp    801749 <strncpy+0x23>
		*dst++ = *src;
  80173a:	83 c2 01             	add    $0x1,%edx
  80173d:	0f b6 01             	movzbl (%ecx),%eax
  801740:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801743:	80 39 01             	cmpb   $0x1,(%ecx)
  801746:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801749:	39 da                	cmp    %ebx,%edx
  80174b:	75 ed                	jne    80173a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80174d:	89 f0                	mov    %esi,%eax
  80174f:	5b                   	pop    %ebx
  801750:	5e                   	pop    %esi
  801751:	5d                   	pop    %ebp
  801752:	c3                   	ret    

00801753 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
  801758:	8b 75 08             	mov    0x8(%ebp),%esi
  80175b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175e:	8b 55 10             	mov    0x10(%ebp),%edx
  801761:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801763:	85 d2                	test   %edx,%edx
  801765:	74 21                	je     801788 <strlcpy+0x35>
  801767:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80176b:	89 f2                	mov    %esi,%edx
  80176d:	eb 09                	jmp    801778 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80176f:	83 c2 01             	add    $0x1,%edx
  801772:	83 c1 01             	add    $0x1,%ecx
  801775:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801778:	39 c2                	cmp    %eax,%edx
  80177a:	74 09                	je     801785 <strlcpy+0x32>
  80177c:	0f b6 19             	movzbl (%ecx),%ebx
  80177f:	84 db                	test   %bl,%bl
  801781:	75 ec                	jne    80176f <strlcpy+0x1c>
  801783:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801785:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801788:	29 f0                	sub    %esi,%eax
}
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801794:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801797:	eb 06                	jmp    80179f <strcmp+0x11>
		p++, q++;
  801799:	83 c1 01             	add    $0x1,%ecx
  80179c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80179f:	0f b6 01             	movzbl (%ecx),%eax
  8017a2:	84 c0                	test   %al,%al
  8017a4:	74 04                	je     8017aa <strcmp+0x1c>
  8017a6:	3a 02                	cmp    (%edx),%al
  8017a8:	74 ef                	je     801799 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017aa:	0f b6 c0             	movzbl %al,%eax
  8017ad:	0f b6 12             	movzbl (%edx),%edx
  8017b0:	29 d0                	sub    %edx,%eax
}
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	53                   	push   %ebx
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c3:	eb 06                	jmp    8017cb <strncmp+0x17>
		n--, p++, q++;
  8017c5:	83 c0 01             	add    $0x1,%eax
  8017c8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017cb:	39 d8                	cmp    %ebx,%eax
  8017cd:	74 15                	je     8017e4 <strncmp+0x30>
  8017cf:	0f b6 08             	movzbl (%eax),%ecx
  8017d2:	84 c9                	test   %cl,%cl
  8017d4:	74 04                	je     8017da <strncmp+0x26>
  8017d6:	3a 0a                	cmp    (%edx),%cl
  8017d8:	74 eb                	je     8017c5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017da:	0f b6 00             	movzbl (%eax),%eax
  8017dd:	0f b6 12             	movzbl (%edx),%edx
  8017e0:	29 d0                	sub    %edx,%eax
  8017e2:	eb 05                	jmp    8017e9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017e4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017e9:	5b                   	pop    %ebx
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f6:	eb 07                	jmp    8017ff <strchr+0x13>
		if (*s == c)
  8017f8:	38 ca                	cmp    %cl,%dl
  8017fa:	74 0f                	je     80180b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017fc:	83 c0 01             	add    $0x1,%eax
  8017ff:	0f b6 10             	movzbl (%eax),%edx
  801802:	84 d2                	test   %dl,%dl
  801804:	75 f2                	jne    8017f8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801806:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180b:	5d                   	pop    %ebp
  80180c:	c3                   	ret    

0080180d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80180d:	55                   	push   %ebp
  80180e:	89 e5                	mov    %esp,%ebp
  801810:	8b 45 08             	mov    0x8(%ebp),%eax
  801813:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801817:	eb 03                	jmp    80181c <strfind+0xf>
  801819:	83 c0 01             	add    $0x1,%eax
  80181c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80181f:	38 ca                	cmp    %cl,%dl
  801821:	74 04                	je     801827 <strfind+0x1a>
  801823:	84 d2                	test   %dl,%dl
  801825:	75 f2                	jne    801819 <strfind+0xc>
			break;
	return (char *) s;
}
  801827:	5d                   	pop    %ebp
  801828:	c3                   	ret    

00801829 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801829:	55                   	push   %ebp
  80182a:	89 e5                	mov    %esp,%ebp
  80182c:	57                   	push   %edi
  80182d:	56                   	push   %esi
  80182e:	53                   	push   %ebx
  80182f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801832:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801835:	85 c9                	test   %ecx,%ecx
  801837:	74 36                	je     80186f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801839:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183f:	75 28                	jne    801869 <memset+0x40>
  801841:	f6 c1 03             	test   $0x3,%cl
  801844:	75 23                	jne    801869 <memset+0x40>
		c &= 0xFF;
  801846:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80184a:	89 d3                	mov    %edx,%ebx
  80184c:	c1 e3 08             	shl    $0x8,%ebx
  80184f:	89 d6                	mov    %edx,%esi
  801851:	c1 e6 18             	shl    $0x18,%esi
  801854:	89 d0                	mov    %edx,%eax
  801856:	c1 e0 10             	shl    $0x10,%eax
  801859:	09 f0                	or     %esi,%eax
  80185b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80185d:	89 d8                	mov    %ebx,%eax
  80185f:	09 d0                	or     %edx,%eax
  801861:	c1 e9 02             	shr    $0x2,%ecx
  801864:	fc                   	cld    
  801865:	f3 ab                	rep stos %eax,%es:(%edi)
  801867:	eb 06                	jmp    80186f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186c:	fc                   	cld    
  80186d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186f:	89 f8                	mov    %edi,%eax
  801871:	5b                   	pop    %ebx
  801872:	5e                   	pop    %esi
  801873:	5f                   	pop    %edi
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    

00801876 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	57                   	push   %edi
  80187a:	56                   	push   %esi
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801881:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801884:	39 c6                	cmp    %eax,%esi
  801886:	73 35                	jae    8018bd <memmove+0x47>
  801888:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80188b:	39 d0                	cmp    %edx,%eax
  80188d:	73 2e                	jae    8018bd <memmove+0x47>
		s += n;
		d += n;
  80188f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801892:	89 d6                	mov    %edx,%esi
  801894:	09 fe                	or     %edi,%esi
  801896:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189c:	75 13                	jne    8018b1 <memmove+0x3b>
  80189e:	f6 c1 03             	test   $0x3,%cl
  8018a1:	75 0e                	jne    8018b1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018a3:	83 ef 04             	sub    $0x4,%edi
  8018a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a9:	c1 e9 02             	shr    $0x2,%ecx
  8018ac:	fd                   	std    
  8018ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018af:	eb 09                	jmp    8018ba <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b1:	83 ef 01             	sub    $0x1,%edi
  8018b4:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b7:	fd                   	std    
  8018b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ba:	fc                   	cld    
  8018bb:	eb 1d                	jmp    8018da <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bd:	89 f2                	mov    %esi,%edx
  8018bf:	09 c2                	or     %eax,%edx
  8018c1:	f6 c2 03             	test   $0x3,%dl
  8018c4:	75 0f                	jne    8018d5 <memmove+0x5f>
  8018c6:	f6 c1 03             	test   $0x3,%cl
  8018c9:	75 0a                	jne    8018d5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018cb:	c1 e9 02             	shr    $0x2,%ecx
  8018ce:	89 c7                	mov    %eax,%edi
  8018d0:	fc                   	cld    
  8018d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d3:	eb 05                	jmp    8018da <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d5:	89 c7                	mov    %eax,%edi
  8018d7:	fc                   	cld    
  8018d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018da:	5e                   	pop    %esi
  8018db:	5f                   	pop    %edi
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e1:	ff 75 10             	pushl  0x10(%ebp)
  8018e4:	ff 75 0c             	pushl  0xc(%ebp)
  8018e7:	ff 75 08             	pushl  0x8(%ebp)
  8018ea:	e8 87 ff ff ff       	call   801876 <memmove>
}
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	56                   	push   %esi
  8018f5:	53                   	push   %ebx
  8018f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fc:	89 c6                	mov    %eax,%esi
  8018fe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801901:	eb 1a                	jmp    80191d <memcmp+0x2c>
		if (*s1 != *s2)
  801903:	0f b6 08             	movzbl (%eax),%ecx
  801906:	0f b6 1a             	movzbl (%edx),%ebx
  801909:	38 d9                	cmp    %bl,%cl
  80190b:	74 0a                	je     801917 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80190d:	0f b6 c1             	movzbl %cl,%eax
  801910:	0f b6 db             	movzbl %bl,%ebx
  801913:	29 d8                	sub    %ebx,%eax
  801915:	eb 0f                	jmp    801926 <memcmp+0x35>
		s1++, s2++;
  801917:	83 c0 01             	add    $0x1,%eax
  80191a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80191d:	39 f0                	cmp    %esi,%eax
  80191f:	75 e2                	jne    801903 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801921:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	53                   	push   %ebx
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801931:	89 c1                	mov    %eax,%ecx
  801933:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801936:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193a:	eb 0a                	jmp    801946 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80193c:	0f b6 10             	movzbl (%eax),%edx
  80193f:	39 da                	cmp    %ebx,%edx
  801941:	74 07                	je     80194a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801943:	83 c0 01             	add    $0x1,%eax
  801946:	39 c8                	cmp    %ecx,%eax
  801948:	72 f2                	jb     80193c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80194a:	5b                   	pop    %ebx
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    

0080194d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	57                   	push   %edi
  801951:	56                   	push   %esi
  801952:	53                   	push   %ebx
  801953:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801956:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801959:	eb 03                	jmp    80195e <strtol+0x11>
		s++;
  80195b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195e:	0f b6 01             	movzbl (%ecx),%eax
  801961:	3c 20                	cmp    $0x20,%al
  801963:	74 f6                	je     80195b <strtol+0xe>
  801965:	3c 09                	cmp    $0x9,%al
  801967:	74 f2                	je     80195b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801969:	3c 2b                	cmp    $0x2b,%al
  80196b:	75 0a                	jne    801977 <strtol+0x2a>
		s++;
  80196d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801970:	bf 00 00 00 00       	mov    $0x0,%edi
  801975:	eb 11                	jmp    801988 <strtol+0x3b>
  801977:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80197c:	3c 2d                	cmp    $0x2d,%al
  80197e:	75 08                	jne    801988 <strtol+0x3b>
		s++, neg = 1;
  801980:	83 c1 01             	add    $0x1,%ecx
  801983:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801988:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80198e:	75 15                	jne    8019a5 <strtol+0x58>
  801990:	80 39 30             	cmpb   $0x30,(%ecx)
  801993:	75 10                	jne    8019a5 <strtol+0x58>
  801995:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801999:	75 7c                	jne    801a17 <strtol+0xca>
		s += 2, base = 16;
  80199b:	83 c1 02             	add    $0x2,%ecx
  80199e:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a3:	eb 16                	jmp    8019bb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019a5:	85 db                	test   %ebx,%ebx
  8019a7:	75 12                	jne    8019bb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ae:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b1:	75 08                	jne    8019bb <strtol+0x6e>
		s++, base = 8;
  8019b3:	83 c1 01             	add    $0x1,%ecx
  8019b6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019c3:	0f b6 11             	movzbl (%ecx),%edx
  8019c6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c9:	89 f3                	mov    %esi,%ebx
  8019cb:	80 fb 09             	cmp    $0x9,%bl
  8019ce:	77 08                	ja     8019d8 <strtol+0x8b>
			dig = *s - '0';
  8019d0:	0f be d2             	movsbl %dl,%edx
  8019d3:	83 ea 30             	sub    $0x30,%edx
  8019d6:	eb 22                	jmp    8019fa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019d8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019db:	89 f3                	mov    %esi,%ebx
  8019dd:	80 fb 19             	cmp    $0x19,%bl
  8019e0:	77 08                	ja     8019ea <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019e2:	0f be d2             	movsbl %dl,%edx
  8019e5:	83 ea 57             	sub    $0x57,%edx
  8019e8:	eb 10                	jmp    8019fa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019ea:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019ed:	89 f3                	mov    %esi,%ebx
  8019ef:	80 fb 19             	cmp    $0x19,%bl
  8019f2:	77 16                	ja     801a0a <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019f4:	0f be d2             	movsbl %dl,%edx
  8019f7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019fa:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019fd:	7d 0b                	jge    801a0a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019ff:	83 c1 01             	add    $0x1,%ecx
  801a02:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a06:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a08:	eb b9                	jmp    8019c3 <strtol+0x76>

	if (endptr)
  801a0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a0e:	74 0d                	je     801a1d <strtol+0xd0>
		*endptr = (char *) s;
  801a10:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a13:	89 0e                	mov    %ecx,(%esi)
  801a15:	eb 06                	jmp    801a1d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a17:	85 db                	test   %ebx,%ebx
  801a19:	74 98                	je     8019b3 <strtol+0x66>
  801a1b:	eb 9e                	jmp    8019bb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a1d:	89 c2                	mov    %eax,%edx
  801a1f:	f7 da                	neg    %edx
  801a21:	85 ff                	test   %edi,%edi
  801a23:	0f 45 c2             	cmovne %edx,%eax
}
  801a26:	5b                   	pop    %ebx
  801a27:	5e                   	pop    %esi
  801a28:	5f                   	pop    %edi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	56                   	push   %esi
  801a2f:	53                   	push   %ebx
  801a30:	8b 75 08             	mov    0x8(%ebp),%esi
  801a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	75 12                	jne    801a4f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	68 00 00 c0 ee       	push   $0xeec00000
  801a45:	e8 11 e9 ff ff       	call   80035b <sys_ipc_recv>
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	eb 0c                	jmp    801a5b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	50                   	push   %eax
  801a53:	e8 03 e9 ff ff       	call   80035b <sys_ipc_recv>
  801a58:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a5b:	85 f6                	test   %esi,%esi
  801a5d:	0f 95 c1             	setne  %cl
  801a60:	85 db                	test   %ebx,%ebx
  801a62:	0f 95 c2             	setne  %dl
  801a65:	84 d1                	test   %dl,%cl
  801a67:	74 09                	je     801a72 <ipc_recv+0x47>
  801a69:	89 c2                	mov    %eax,%edx
  801a6b:	c1 ea 1f             	shr    $0x1f,%edx
  801a6e:	84 d2                	test   %dl,%dl
  801a70:	75 24                	jne    801a96 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a72:	85 f6                	test   %esi,%esi
  801a74:	74 0a                	je     801a80 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801a76:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7b:	8b 40 74             	mov    0x74(%eax),%eax
  801a7e:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801a80:	85 db                	test   %ebx,%ebx
  801a82:	74 0a                	je     801a8e <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801a84:	a1 04 40 80 00       	mov    0x804004,%eax
  801a89:	8b 40 78             	mov    0x78(%eax),%eax
  801a8c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a8e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a93:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a99:	5b                   	pop    %ebx
  801a9a:	5e                   	pop    %esi
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    

00801a9d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	57                   	push   %edi
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 0c             	sub    $0xc,%esp
  801aa6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801aaf:	85 db                	test   %ebx,%ebx
  801ab1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ab6:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ab9:	ff 75 14             	pushl  0x14(%ebp)
  801abc:	53                   	push   %ebx
  801abd:	56                   	push   %esi
  801abe:	57                   	push   %edi
  801abf:	e8 74 e8 ff ff       	call   800338 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ac4:	89 c2                	mov    %eax,%edx
  801ac6:	c1 ea 1f             	shr    $0x1f,%edx
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	84 d2                	test   %dl,%dl
  801ace:	74 17                	je     801ae7 <ipc_send+0x4a>
  801ad0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad3:	74 12                	je     801ae7 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ad5:	50                   	push   %eax
  801ad6:	68 60 22 80 00       	push   $0x802260
  801adb:	6a 47                	push   $0x47
  801add:	68 6e 22 80 00       	push   $0x80226e
  801ae2:	e8 9f f5 ff ff       	call   801086 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ae7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aea:	75 07                	jne    801af3 <ipc_send+0x56>
			sys_yield();
  801aec:	e8 9b e6 ff ff       	call   80018c <sys_yield>
  801af1:	eb c6                	jmp    801ab9 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801af3:	85 c0                	test   %eax,%eax
  801af5:	75 c2                	jne    801ab9 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801af7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afa:	5b                   	pop    %ebx
  801afb:	5e                   	pop    %esi
  801afc:	5f                   	pop    %edi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    

00801aff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b05:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b0a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b0d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b13:	8b 52 50             	mov    0x50(%edx),%edx
  801b16:	39 ca                	cmp    %ecx,%edx
  801b18:	75 0d                	jne    801b27 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b1a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b22:	8b 40 48             	mov    0x48(%eax),%eax
  801b25:	eb 0f                	jmp    801b36 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b27:	83 c0 01             	add    $0x1,%eax
  801b2a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b2f:	75 d9                	jne    801b0a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3e:	89 d0                	mov    %edx,%eax
  801b40:	c1 e8 16             	shr    $0x16,%eax
  801b43:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b4a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b4f:	f6 c1 01             	test   $0x1,%cl
  801b52:	74 1d                	je     801b71 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b54:	c1 ea 0c             	shr    $0xc,%edx
  801b57:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b5e:	f6 c2 01             	test   $0x1,%dl
  801b61:	74 0e                	je     801b71 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b63:	c1 ea 0c             	shr    $0xc,%edx
  801b66:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b6d:	ef 
  801b6e:	0f b7 c0             	movzwl %ax,%eax
}
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    
  801b73:	66 90                	xchg   %ax,%ax
  801b75:	66 90                	xchg   %ax,%ax
  801b77:	66 90                	xchg   %ax,%ax
  801b79:	66 90                	xchg   %ax,%ax
  801b7b:	66 90                	xchg   %ax,%ax
  801b7d:	66 90                	xchg   %ax,%ax
  801b7f:	90                   	nop

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
