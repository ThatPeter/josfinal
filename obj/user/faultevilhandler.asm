
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 82 01 00 00       	call   8001c9 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 be 02 00 00       	call   800314 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	57                   	push   %edi
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006e:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800075:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800078:	e8 0e 01 00 00       	call   80018b <sys_getenvid>
  80007d:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800083:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800088:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80008d:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800092:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800095:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80009b:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  80009e:	39 c8                	cmp    %ecx,%eax
  8000a0:	0f 44 fb             	cmove  %ebx,%edi
  8000a3:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000a8:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  8000ab:	83 c2 01             	add    $0x1,%edx
  8000ae:	83 c3 7c             	add    $0x7c,%ebx
  8000b1:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000b7:	75 d9                	jne    800092 <libmain+0x2d>
  8000b9:	89 f0                	mov    %esi,%eax
  8000bb:	84 c0                	test   %al,%al
  8000bd:	74 06                	je     8000c5 <libmain+0x60>
  8000bf:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000c9:	7e 0a                	jle    8000d5 <libmain+0x70>
		binaryname = argv[0];
  8000cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ce:	8b 00                	mov    (%eax),%eax
  8000d0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	ff 75 0c             	pushl  0xc(%ebp)
  8000db:	ff 75 08             	pushl  0x8(%ebp)
  8000de:	e8 50 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e3:	e8 0b 00 00 00       	call   8000f3 <exit>
}
  8000e8:	83 c4 10             	add    $0x10,%esp
  8000eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5f                   	pop    %edi
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000f9:	e8 87 04 00 00       	call   800585 <close_all>
	sys_env_destroy(0);
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	6a 00                	push   $0x0
  800103:	e8 42 00 00 00       	call   80014a <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800113:	b8 00 00 00 00       	mov    $0x0,%eax
  800118:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80011b:	8b 55 08             	mov    0x8(%ebp),%edx
  80011e:	89 c3                	mov    %eax,%ebx
  800120:	89 c7                	mov    %eax,%edi
  800122:	89 c6                	mov    %eax,%esi
  800124:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_cgetc>:

int
sys_cgetc(void)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	57                   	push   %edi
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800131:	ba 00 00 00 00       	mov    $0x0,%edx
  800136:	b8 01 00 00 00       	mov    $0x1,%eax
  80013b:	89 d1                	mov    %edx,%ecx
  80013d:	89 d3                	mov    %edx,%ebx
  80013f:	89 d7                	mov    %edx,%edi
  800141:	89 d6                	mov    %edx,%esi
  800143:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5f                   	pop    %edi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
  800150:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800153:	b9 00 00 00 00       	mov    $0x0,%ecx
  800158:	b8 03 00 00 00       	mov    $0x3,%eax
  80015d:	8b 55 08             	mov    0x8(%ebp),%edx
  800160:	89 cb                	mov    %ecx,%ebx
  800162:	89 cf                	mov    %ecx,%edi
  800164:	89 ce                	mov    %ecx,%esi
  800166:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800168:	85 c0                	test   %eax,%eax
  80016a:	7e 17                	jle    800183 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80016c:	83 ec 0c             	sub    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	6a 03                	push   $0x3
  800172:	68 4a 1e 80 00       	push   $0x801e4a
  800177:	6a 23                	push   $0x23
  800179:	68 67 1e 80 00       	push   $0x801e67
  80017e:	e8 21 0f 00 00       	call   8010a4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800183:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800186:	5b                   	pop    %ebx
  800187:	5e                   	pop    %esi
  800188:	5f                   	pop    %edi
  800189:	5d                   	pop    %ebp
  80018a:	c3                   	ret    

0080018b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	57                   	push   %edi
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800191:	ba 00 00 00 00       	mov    $0x0,%edx
  800196:	b8 02 00 00 00       	mov    $0x2,%eax
  80019b:	89 d1                	mov    %edx,%ecx
  80019d:	89 d3                	mov    %edx,%ebx
  80019f:	89 d7                	mov    %edx,%edi
  8001a1:	89 d6                	mov    %edx,%esi
  8001a3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8001a5:	5b                   	pop    %ebx
  8001a6:	5e                   	pop    %esi
  8001a7:	5f                   	pop    %edi
  8001a8:	5d                   	pop    %ebp
  8001a9:	c3                   	ret    

008001aa <sys_yield>:

void
sys_yield(void)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	57                   	push   %edi
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ba:	89 d1                	mov    %edx,%ecx
  8001bc:	89 d3                	mov    %edx,%ebx
  8001be:	89 d7                	mov    %edx,%edi
  8001c0:	89 d6                	mov    %edx,%esi
  8001c2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    

008001c9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	57                   	push   %edi
  8001cd:	56                   	push   %esi
  8001ce:	53                   	push   %ebx
  8001cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d2:	be 00 00 00 00       	mov    $0x0,%esi
  8001d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8001dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001df:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e5:	89 f7                	mov    %esi,%edi
  8001e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e9:	85 c0                	test   %eax,%eax
  8001eb:	7e 17                	jle    800204 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	50                   	push   %eax
  8001f1:	6a 04                	push   $0x4
  8001f3:	68 4a 1e 80 00       	push   $0x801e4a
  8001f8:	6a 23                	push   $0x23
  8001fa:	68 67 1e 80 00       	push   $0x801e67
  8001ff:	e8 a0 0e 00 00       	call   8010a4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800215:	b8 05 00 00 00       	mov    $0x5,%eax
  80021a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021d:	8b 55 08             	mov    0x8(%ebp),%edx
  800220:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800223:	8b 7d 14             	mov    0x14(%ebp),%edi
  800226:	8b 75 18             	mov    0x18(%ebp),%esi
  800229:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80022b:	85 c0                	test   %eax,%eax
  80022d:	7e 17                	jle    800246 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022f:	83 ec 0c             	sub    $0xc,%esp
  800232:	50                   	push   %eax
  800233:	6a 05                	push   $0x5
  800235:	68 4a 1e 80 00       	push   $0x801e4a
  80023a:	6a 23                	push   $0x23
  80023c:	68 67 1e 80 00       	push   $0x801e67
  800241:	e8 5e 0e 00 00       	call   8010a4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800246:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	57                   	push   %edi
  800252:	56                   	push   %esi
  800253:	53                   	push   %ebx
  800254:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800257:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025c:	b8 06 00 00 00       	mov    $0x6,%eax
  800261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800264:	8b 55 08             	mov    0x8(%ebp),%edx
  800267:	89 df                	mov    %ebx,%edi
  800269:	89 de                	mov    %ebx,%esi
  80026b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80026d:	85 c0                	test   %eax,%eax
  80026f:	7e 17                	jle    800288 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	50                   	push   %eax
  800275:	6a 06                	push   $0x6
  800277:	68 4a 1e 80 00       	push   $0x801e4a
  80027c:	6a 23                	push   $0x23
  80027e:	68 67 1e 80 00       	push   $0x801e67
  800283:	e8 1c 0e 00 00       	call   8010a4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800288:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028b:	5b                   	pop    %ebx
  80028c:	5e                   	pop    %esi
  80028d:	5f                   	pop    %edi
  80028e:	5d                   	pop    %ebp
  80028f:	c3                   	ret    

00800290 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800299:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029e:	b8 08 00 00 00       	mov    $0x8,%eax
  8002a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a9:	89 df                	mov    %ebx,%edi
  8002ab:	89 de                	mov    %ebx,%esi
  8002ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	7e 17                	jle    8002ca <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b3:	83 ec 0c             	sub    $0xc,%esp
  8002b6:	50                   	push   %eax
  8002b7:	6a 08                	push   $0x8
  8002b9:	68 4a 1e 80 00       	push   $0x801e4a
  8002be:	6a 23                	push   $0x23
  8002c0:	68 67 1e 80 00       	push   $0x801e67
  8002c5:	e8 da 0d 00 00       	call   8010a4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	89 df                	mov    %ebx,%edi
  8002ed:	89 de                	mov    %ebx,%esi
  8002ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	7e 17                	jle    80030c <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	50                   	push   %eax
  8002f9:	6a 09                	push   $0x9
  8002fb:	68 4a 1e 80 00       	push   $0x801e4a
  800300:	6a 23                	push   $0x23
  800302:	68 67 1e 80 00       	push   $0x801e67
  800307:	e8 98 0d 00 00       	call   8010a4 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80030c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5f                   	pop    %edi
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800322:	b8 0a 00 00 00       	mov    $0xa,%eax
  800327:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032a:	8b 55 08             	mov    0x8(%ebp),%edx
  80032d:	89 df                	mov    %ebx,%edi
  80032f:	89 de                	mov    %ebx,%esi
  800331:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800333:	85 c0                	test   %eax,%eax
  800335:	7e 17                	jle    80034e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800337:	83 ec 0c             	sub    $0xc,%esp
  80033a:	50                   	push   %eax
  80033b:	6a 0a                	push   $0xa
  80033d:	68 4a 1e 80 00       	push   $0x801e4a
  800342:	6a 23                	push   $0x23
  800344:	68 67 1e 80 00       	push   $0x801e67
  800349:	e8 56 0d 00 00       	call   8010a4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80034e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	57                   	push   %edi
  80035a:	56                   	push   %esi
  80035b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035c:	be 00 00 00 00       	mov    $0x0,%esi
  800361:	b8 0c 00 00 00       	mov    $0xc,%eax
  800366:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800369:	8b 55 08             	mov    0x8(%ebp),%edx
  80036c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800372:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800374:	5b                   	pop    %ebx
  800375:	5e                   	pop    %esi
  800376:	5f                   	pop    %edi
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    

00800379 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	57                   	push   %edi
  80037d:	56                   	push   %esi
  80037e:	53                   	push   %ebx
  80037f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800382:	b9 00 00 00 00       	mov    $0x0,%ecx
  800387:	b8 0d 00 00 00       	mov    $0xd,%eax
  80038c:	8b 55 08             	mov    0x8(%ebp),%edx
  80038f:	89 cb                	mov    %ecx,%ebx
  800391:	89 cf                	mov    %ecx,%edi
  800393:	89 ce                	mov    %ecx,%esi
  800395:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800397:	85 c0                	test   %eax,%eax
  800399:	7e 17                	jle    8003b2 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80039b:	83 ec 0c             	sub    $0xc,%esp
  80039e:	50                   	push   %eax
  80039f:	6a 0d                	push   $0xd
  8003a1:	68 4a 1e 80 00       	push   $0x801e4a
  8003a6:	6a 23                	push   $0x23
  8003a8:	68 67 1e 80 00       	push   $0x801e67
  8003ad:	e8 f2 0c 00 00       	call   8010a4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b5:	5b                   	pop    %ebx
  8003b6:	5e                   	pop    %esi
  8003b7:	5f                   	pop    %edi
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c5:	c1 e8 0c             	shr    $0xc,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d0:	05 00 00 00 30       	add    $0x30000000,%eax
  8003d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003da:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003df:	5d                   	pop    %ebp
  8003e0:	c3                   	ret    

008003e1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ec:	89 c2                	mov    %eax,%edx
  8003ee:	c1 ea 16             	shr    $0x16,%edx
  8003f1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f8:	f6 c2 01             	test   $0x1,%dl
  8003fb:	74 11                	je     80040e <fd_alloc+0x2d>
  8003fd:	89 c2                	mov    %eax,%edx
  8003ff:	c1 ea 0c             	shr    $0xc,%edx
  800402:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800409:	f6 c2 01             	test   $0x1,%dl
  80040c:	75 09                	jne    800417 <fd_alloc+0x36>
			*fd_store = fd;
  80040e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800410:	b8 00 00 00 00       	mov    $0x0,%eax
  800415:	eb 17                	jmp    80042e <fd_alloc+0x4d>
  800417:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80041c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800421:	75 c9                	jne    8003ec <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800423:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800429:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80042e:	5d                   	pop    %ebp
  80042f:	c3                   	ret    

00800430 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800436:	83 f8 1f             	cmp    $0x1f,%eax
  800439:	77 36                	ja     800471 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80043b:	c1 e0 0c             	shl    $0xc,%eax
  80043e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800443:	89 c2                	mov    %eax,%edx
  800445:	c1 ea 16             	shr    $0x16,%edx
  800448:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80044f:	f6 c2 01             	test   $0x1,%dl
  800452:	74 24                	je     800478 <fd_lookup+0x48>
  800454:	89 c2                	mov    %eax,%edx
  800456:	c1 ea 0c             	shr    $0xc,%edx
  800459:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800460:	f6 c2 01             	test   $0x1,%dl
  800463:	74 1a                	je     80047f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800465:	8b 55 0c             	mov    0xc(%ebp),%edx
  800468:	89 02                	mov    %eax,(%edx)
	return 0;
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	eb 13                	jmp    800484 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800471:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800476:	eb 0c                	jmp    800484 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800478:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80047d:	eb 05                	jmp    800484 <fd_lookup+0x54>
  80047f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800484:	5d                   	pop    %ebp
  800485:	c3                   	ret    

00800486 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80048f:	ba f4 1e 80 00       	mov    $0x801ef4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800494:	eb 13                	jmp    8004a9 <dev_lookup+0x23>
  800496:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800499:	39 08                	cmp    %ecx,(%eax)
  80049b:	75 0c                	jne    8004a9 <dev_lookup+0x23>
			*dev = devtab[i];
  80049d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004a0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a7:	eb 2e                	jmp    8004d7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004a9:	8b 02                	mov    (%edx),%eax
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	75 e7                	jne    800496 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004af:	a1 04 40 80 00       	mov    0x804004,%eax
  8004b4:	8b 40 48             	mov    0x48(%eax),%eax
  8004b7:	83 ec 04             	sub    $0x4,%esp
  8004ba:	51                   	push   %ecx
  8004bb:	50                   	push   %eax
  8004bc:	68 78 1e 80 00       	push   $0x801e78
  8004c1:	e8 b7 0c 00 00       	call   80117d <cprintf>
	*dev = 0;
  8004c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004d7:	c9                   	leave  
  8004d8:	c3                   	ret    

008004d9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	56                   	push   %esi
  8004dd:	53                   	push   %ebx
  8004de:	83 ec 10             	sub    $0x10,%esp
  8004e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ea:	50                   	push   %eax
  8004eb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004f1:	c1 e8 0c             	shr    $0xc,%eax
  8004f4:	50                   	push   %eax
  8004f5:	e8 36 ff ff ff       	call   800430 <fd_lookup>
  8004fa:	83 c4 08             	add    $0x8,%esp
  8004fd:	85 c0                	test   %eax,%eax
  8004ff:	78 05                	js     800506 <fd_close+0x2d>
	    || fd != fd2)
  800501:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800504:	74 0c                	je     800512 <fd_close+0x39>
		return (must_exist ? r : 0);
  800506:	84 db                	test   %bl,%bl
  800508:	ba 00 00 00 00       	mov    $0x0,%edx
  80050d:	0f 44 c2             	cmove  %edx,%eax
  800510:	eb 41                	jmp    800553 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800518:	50                   	push   %eax
  800519:	ff 36                	pushl  (%esi)
  80051b:	e8 66 ff ff ff       	call   800486 <dev_lookup>
  800520:	89 c3                	mov    %eax,%ebx
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	85 c0                	test   %eax,%eax
  800527:	78 1a                	js     800543 <fd_close+0x6a>
		if (dev->dev_close)
  800529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80052c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80052f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800534:	85 c0                	test   %eax,%eax
  800536:	74 0b                	je     800543 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800538:	83 ec 0c             	sub    $0xc,%esp
  80053b:	56                   	push   %esi
  80053c:	ff d0                	call   *%eax
  80053e:	89 c3                	mov    %eax,%ebx
  800540:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	6a 00                	push   $0x0
  800549:	e8 00 fd ff ff       	call   80024e <sys_page_unmap>
	return r;
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	89 d8                	mov    %ebx,%eax
}
  800553:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800556:	5b                   	pop    %ebx
  800557:	5e                   	pop    %esi
  800558:	5d                   	pop    %ebp
  800559:	c3                   	ret    

0080055a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80055a:	55                   	push   %ebp
  80055b:	89 e5                	mov    %esp,%ebp
  80055d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800560:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800563:	50                   	push   %eax
  800564:	ff 75 08             	pushl  0x8(%ebp)
  800567:	e8 c4 fe ff ff       	call   800430 <fd_lookup>
  80056c:	83 c4 08             	add    $0x8,%esp
  80056f:	85 c0                	test   %eax,%eax
  800571:	78 10                	js     800583 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	6a 01                	push   $0x1
  800578:	ff 75 f4             	pushl  -0xc(%ebp)
  80057b:	e8 59 ff ff ff       	call   8004d9 <fd_close>
  800580:	83 c4 10             	add    $0x10,%esp
}
  800583:	c9                   	leave  
  800584:	c3                   	ret    

00800585 <close_all>:

void
close_all(void)
{
  800585:	55                   	push   %ebp
  800586:	89 e5                	mov    %esp,%ebp
  800588:	53                   	push   %ebx
  800589:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80058c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800591:	83 ec 0c             	sub    $0xc,%esp
  800594:	53                   	push   %ebx
  800595:	e8 c0 ff ff ff       	call   80055a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80059a:	83 c3 01             	add    $0x1,%ebx
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	83 fb 20             	cmp    $0x20,%ebx
  8005a3:	75 ec                	jne    800591 <close_all+0xc>
		close(i);
}
  8005a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005a8:	c9                   	leave  
  8005a9:	c3                   	ret    

008005aa <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005aa:	55                   	push   %ebp
  8005ab:	89 e5                	mov    %esp,%ebp
  8005ad:	57                   	push   %edi
  8005ae:	56                   	push   %esi
  8005af:	53                   	push   %ebx
  8005b0:	83 ec 2c             	sub    $0x2c,%esp
  8005b3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 08             	pushl  0x8(%ebp)
  8005bd:	e8 6e fe ff ff       	call   800430 <fd_lookup>
  8005c2:	83 c4 08             	add    $0x8,%esp
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	0f 88 c1 00 00 00    	js     80068e <dup+0xe4>
		return r;
	close(newfdnum);
  8005cd:	83 ec 0c             	sub    $0xc,%esp
  8005d0:	56                   	push   %esi
  8005d1:	e8 84 ff ff ff       	call   80055a <close>

	newfd = INDEX2FD(newfdnum);
  8005d6:	89 f3                	mov    %esi,%ebx
  8005d8:	c1 e3 0c             	shl    $0xc,%ebx
  8005db:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005e1:	83 c4 04             	add    $0x4,%esp
  8005e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005e7:	e8 de fd ff ff       	call   8003ca <fd2data>
  8005ec:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005ee:	89 1c 24             	mov    %ebx,(%esp)
  8005f1:	e8 d4 fd ff ff       	call   8003ca <fd2data>
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005fc:	89 f8                	mov    %edi,%eax
  8005fe:	c1 e8 16             	shr    $0x16,%eax
  800601:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800608:	a8 01                	test   $0x1,%al
  80060a:	74 37                	je     800643 <dup+0x99>
  80060c:	89 f8                	mov    %edi,%eax
  80060e:	c1 e8 0c             	shr    $0xc,%eax
  800611:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800618:	f6 c2 01             	test   $0x1,%dl
  80061b:	74 26                	je     800643 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80061d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800624:	83 ec 0c             	sub    $0xc,%esp
  800627:	25 07 0e 00 00       	and    $0xe07,%eax
  80062c:	50                   	push   %eax
  80062d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800630:	6a 00                	push   $0x0
  800632:	57                   	push   %edi
  800633:	6a 00                	push   $0x0
  800635:	e8 d2 fb ff ff       	call   80020c <sys_page_map>
  80063a:	89 c7                	mov    %eax,%edi
  80063c:	83 c4 20             	add    $0x20,%esp
  80063f:	85 c0                	test   %eax,%eax
  800641:	78 2e                	js     800671 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800643:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800646:	89 d0                	mov    %edx,%eax
  800648:	c1 e8 0c             	shr    $0xc,%eax
  80064b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800652:	83 ec 0c             	sub    $0xc,%esp
  800655:	25 07 0e 00 00       	and    $0xe07,%eax
  80065a:	50                   	push   %eax
  80065b:	53                   	push   %ebx
  80065c:	6a 00                	push   $0x0
  80065e:	52                   	push   %edx
  80065f:	6a 00                	push   $0x0
  800661:	e8 a6 fb ff ff       	call   80020c <sys_page_map>
  800666:	89 c7                	mov    %eax,%edi
  800668:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80066b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80066d:	85 ff                	test   %edi,%edi
  80066f:	79 1d                	jns    80068e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 00                	push   $0x0
  800677:	e8 d2 fb ff ff       	call   80024e <sys_page_unmap>
	sys_page_unmap(0, nva);
  80067c:	83 c4 08             	add    $0x8,%esp
  80067f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800682:	6a 00                	push   $0x0
  800684:	e8 c5 fb ff ff       	call   80024e <sys_page_unmap>
	return r;
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	89 f8                	mov    %edi,%eax
}
  80068e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800691:	5b                   	pop    %ebx
  800692:	5e                   	pop    %esi
  800693:	5f                   	pop    %edi
  800694:	5d                   	pop    %ebp
  800695:	c3                   	ret    

00800696 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	53                   	push   %ebx
  80069a:	83 ec 14             	sub    $0x14,%esp
  80069d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a3:	50                   	push   %eax
  8006a4:	53                   	push   %ebx
  8006a5:	e8 86 fd ff ff       	call   800430 <fd_lookup>
  8006aa:	83 c4 08             	add    $0x8,%esp
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	85 c0                	test   %eax,%eax
  8006b1:	78 6d                	js     800720 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b9:	50                   	push   %eax
  8006ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006bd:	ff 30                	pushl  (%eax)
  8006bf:	e8 c2 fd ff ff       	call   800486 <dev_lookup>
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	85 c0                	test   %eax,%eax
  8006c9:	78 4c                	js     800717 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006ce:	8b 42 08             	mov    0x8(%edx),%eax
  8006d1:	83 e0 03             	and    $0x3,%eax
  8006d4:	83 f8 01             	cmp    $0x1,%eax
  8006d7:	75 21                	jne    8006fa <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8006de:	8b 40 48             	mov    0x48(%eax),%eax
  8006e1:	83 ec 04             	sub    $0x4,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	50                   	push   %eax
  8006e6:	68 b9 1e 80 00       	push   $0x801eb9
  8006eb:	e8 8d 0a 00 00       	call   80117d <cprintf>
		return -E_INVAL;
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006f8:	eb 26                	jmp    800720 <read+0x8a>
	}
	if (!dev->dev_read)
  8006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fd:	8b 40 08             	mov    0x8(%eax),%eax
  800700:	85 c0                	test   %eax,%eax
  800702:	74 17                	je     80071b <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800704:	83 ec 04             	sub    $0x4,%esp
  800707:	ff 75 10             	pushl  0x10(%ebp)
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	52                   	push   %edx
  80070e:	ff d0                	call   *%eax
  800710:	89 c2                	mov    %eax,%edx
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	eb 09                	jmp    800720 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800717:	89 c2                	mov    %eax,%edx
  800719:	eb 05                	jmp    800720 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80071b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800720:	89 d0                	mov    %edx,%eax
  800722:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800725:	c9                   	leave  
  800726:	c3                   	ret    

00800727 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	57                   	push   %edi
  80072b:	56                   	push   %esi
  80072c:	53                   	push   %ebx
  80072d:	83 ec 0c             	sub    $0xc,%esp
  800730:	8b 7d 08             	mov    0x8(%ebp),%edi
  800733:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800736:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073b:	eb 21                	jmp    80075e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80073d:	83 ec 04             	sub    $0x4,%esp
  800740:	89 f0                	mov    %esi,%eax
  800742:	29 d8                	sub    %ebx,%eax
  800744:	50                   	push   %eax
  800745:	89 d8                	mov    %ebx,%eax
  800747:	03 45 0c             	add    0xc(%ebp),%eax
  80074a:	50                   	push   %eax
  80074b:	57                   	push   %edi
  80074c:	e8 45 ff ff ff       	call   800696 <read>
		if (m < 0)
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	85 c0                	test   %eax,%eax
  800756:	78 10                	js     800768 <readn+0x41>
			return m;
		if (m == 0)
  800758:	85 c0                	test   %eax,%eax
  80075a:	74 0a                	je     800766 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80075c:	01 c3                	add    %eax,%ebx
  80075e:	39 f3                	cmp    %esi,%ebx
  800760:	72 db                	jb     80073d <readn+0x16>
  800762:	89 d8                	mov    %ebx,%eax
  800764:	eb 02                	jmp    800768 <readn+0x41>
  800766:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800768:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	83 ec 14             	sub    $0x14,%esp
  800777:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80077a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80077d:	50                   	push   %eax
  80077e:	53                   	push   %ebx
  80077f:	e8 ac fc ff ff       	call   800430 <fd_lookup>
  800784:	83 c4 08             	add    $0x8,%esp
  800787:	89 c2                	mov    %eax,%edx
  800789:	85 c0                	test   %eax,%eax
  80078b:	78 68                	js     8007f5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	83 ec 08             	sub    $0x8,%esp
  800790:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800793:	50                   	push   %eax
  800794:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800797:	ff 30                	pushl  (%eax)
  800799:	e8 e8 fc ff ff       	call   800486 <dev_lookup>
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	78 47                	js     8007ec <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ac:	75 21                	jne    8007cf <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8007b3:	8b 40 48             	mov    0x48(%eax),%eax
  8007b6:	83 ec 04             	sub    $0x4,%esp
  8007b9:	53                   	push   %ebx
  8007ba:	50                   	push   %eax
  8007bb:	68 d5 1e 80 00       	push   $0x801ed5
  8007c0:	e8 b8 09 00 00       	call   80117d <cprintf>
		return -E_INVAL;
  8007c5:	83 c4 10             	add    $0x10,%esp
  8007c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007cd:	eb 26                	jmp    8007f5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d2:	8b 52 0c             	mov    0xc(%edx),%edx
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	74 17                	je     8007f0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007d9:	83 ec 04             	sub    $0x4,%esp
  8007dc:	ff 75 10             	pushl  0x10(%ebp)
  8007df:	ff 75 0c             	pushl  0xc(%ebp)
  8007e2:	50                   	push   %eax
  8007e3:	ff d2                	call   *%edx
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	83 c4 10             	add    $0x10,%esp
  8007ea:	eb 09                	jmp    8007f5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ec:	89 c2                	mov    %eax,%edx
  8007ee:	eb 05                	jmp    8007f5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007f5:	89 d0                	mov    %edx,%eax
  8007f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <seek>:

int
seek(int fdnum, off_t offset)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800802:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800805:	50                   	push   %eax
  800806:	ff 75 08             	pushl  0x8(%ebp)
  800809:	e8 22 fc ff ff       	call   800430 <fd_lookup>
  80080e:	83 c4 08             	add    $0x8,%esp
  800811:	85 c0                	test   %eax,%eax
  800813:	78 0e                	js     800823 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800815:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80081e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800823:	c9                   	leave  
  800824:	c3                   	ret    

00800825 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	83 ec 14             	sub    $0x14,%esp
  80082c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800832:	50                   	push   %eax
  800833:	53                   	push   %ebx
  800834:	e8 f7 fb ff ff       	call   800430 <fd_lookup>
  800839:	83 c4 08             	add    $0x8,%esp
  80083c:	89 c2                	mov    %eax,%edx
  80083e:	85 c0                	test   %eax,%eax
  800840:	78 65                	js     8008a7 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084c:	ff 30                	pushl  (%eax)
  80084e:	e8 33 fc ff ff       	call   800486 <dev_lookup>
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	85 c0                	test   %eax,%eax
  800858:	78 44                	js     80089e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80085a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800861:	75 21                	jne    800884 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800863:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800868:	8b 40 48             	mov    0x48(%eax),%eax
  80086b:	83 ec 04             	sub    $0x4,%esp
  80086e:	53                   	push   %ebx
  80086f:	50                   	push   %eax
  800870:	68 98 1e 80 00       	push   $0x801e98
  800875:	e8 03 09 00 00       	call   80117d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800882:	eb 23                	jmp    8008a7 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800884:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800887:	8b 52 18             	mov    0x18(%edx),%edx
  80088a:	85 d2                	test   %edx,%edx
  80088c:	74 14                	je     8008a2 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80088e:	83 ec 08             	sub    $0x8,%esp
  800891:	ff 75 0c             	pushl  0xc(%ebp)
  800894:	50                   	push   %eax
  800895:	ff d2                	call   *%edx
  800897:	89 c2                	mov    %eax,%edx
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	eb 09                	jmp    8008a7 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	eb 05                	jmp    8008a7 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008a7:	89 d0                	mov    %edx,%eax
  8008a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	53                   	push   %ebx
  8008b2:	83 ec 14             	sub    $0x14,%esp
  8008b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008bb:	50                   	push   %eax
  8008bc:	ff 75 08             	pushl  0x8(%ebp)
  8008bf:	e8 6c fb ff ff       	call   800430 <fd_lookup>
  8008c4:	83 c4 08             	add    $0x8,%esp
  8008c7:	89 c2                	mov    %eax,%edx
  8008c9:	85 c0                	test   %eax,%eax
  8008cb:	78 58                	js     800925 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cd:	83 ec 08             	sub    $0x8,%esp
  8008d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d3:	50                   	push   %eax
  8008d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008d7:	ff 30                	pushl  (%eax)
  8008d9:	e8 a8 fb ff ff       	call   800486 <dev_lookup>
  8008de:	83 c4 10             	add    $0x10,%esp
  8008e1:	85 c0                	test   %eax,%eax
  8008e3:	78 37                	js     80091c <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ec:	74 32                	je     800920 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ee:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008f1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008f8:	00 00 00 
	stat->st_isdir = 0;
  8008fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800902:	00 00 00 
	stat->st_dev = dev;
  800905:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	53                   	push   %ebx
  80090f:	ff 75 f0             	pushl  -0x10(%ebp)
  800912:	ff 50 14             	call   *0x14(%eax)
  800915:	89 c2                	mov    %eax,%edx
  800917:	83 c4 10             	add    $0x10,%esp
  80091a:	eb 09                	jmp    800925 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80091c:	89 c2                	mov    %eax,%edx
  80091e:	eb 05                	jmp    800925 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800920:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800925:	89 d0                	mov    %edx,%eax
  800927:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800931:	83 ec 08             	sub    $0x8,%esp
  800934:	6a 00                	push   $0x0
  800936:	ff 75 08             	pushl  0x8(%ebp)
  800939:	e8 e3 01 00 00       	call   800b21 <open>
  80093e:	89 c3                	mov    %eax,%ebx
  800940:	83 c4 10             	add    $0x10,%esp
  800943:	85 c0                	test   %eax,%eax
  800945:	78 1b                	js     800962 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800947:	83 ec 08             	sub    $0x8,%esp
  80094a:	ff 75 0c             	pushl  0xc(%ebp)
  80094d:	50                   	push   %eax
  80094e:	e8 5b ff ff ff       	call   8008ae <fstat>
  800953:	89 c6                	mov    %eax,%esi
	close(fd);
  800955:	89 1c 24             	mov    %ebx,(%esp)
  800958:	e8 fd fb ff ff       	call   80055a <close>
	return r;
  80095d:	83 c4 10             	add    $0x10,%esp
  800960:	89 f0                	mov    %esi,%eax
}
  800962:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	56                   	push   %esi
  80096d:	53                   	push   %ebx
  80096e:	89 c6                	mov    %eax,%esi
  800970:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800972:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800979:	75 12                	jne    80098d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80097b:	83 ec 0c             	sub    $0xc,%esp
  80097e:	6a 01                	push   $0x1
  800980:	e8 98 11 00 00       	call   801b1d <ipc_find_env>
  800985:	a3 00 40 80 00       	mov    %eax,0x804000
  80098a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80098d:	6a 07                	push   $0x7
  80098f:	68 00 50 80 00       	push   $0x805000
  800994:	56                   	push   %esi
  800995:	ff 35 00 40 80 00    	pushl  0x804000
  80099b:	e8 1b 11 00 00       	call   801abb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009a0:	83 c4 0c             	add    $0xc,%esp
  8009a3:	6a 00                	push   $0x0
  8009a5:	53                   	push   %ebx
  8009a6:	6a 00                	push   $0x0
  8009a8:	e8 9c 10 00 00       	call   801a49 <ipc_recv>
}
  8009ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 02 00 00 00       	mov    $0x2,%eax
  8009d7:	e8 8d ff ff ff       	call   800969 <fsipc>
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ea:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f9:	e8 6b ff ff ff       	call   800969 <fsipc>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	53                   	push   %ebx
  800a04:	83 ec 04             	sub    $0x4,%esp
  800a07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a10:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a15:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a1f:	e8 45 ff ff ff       	call   800969 <fsipc>
  800a24:	85 c0                	test   %eax,%eax
  800a26:	78 2c                	js     800a54 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a28:	83 ec 08             	sub    $0x8,%esp
  800a2b:	68 00 50 80 00       	push   $0x805000
  800a30:	53                   	push   %ebx
  800a31:	e8 cc 0c 00 00       	call   801702 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a36:	a1 80 50 80 00       	mov    0x805080,%eax
  800a3b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a41:	a1 84 50 80 00       	mov    0x805084,%eax
  800a46:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a4c:	83 c4 10             	add    $0x10,%esp
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a57:	c9                   	leave  
  800a58:	c3                   	ret    

00800a59 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	83 ec 0c             	sub    $0xc,%esp
  800a5f:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a62:	8b 55 08             	mov    0x8(%ebp),%edx
  800a65:	8b 52 0c             	mov    0xc(%edx),%edx
  800a68:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a6e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a73:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a78:	0f 47 c2             	cmova  %edx,%eax
  800a7b:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a80:	50                   	push   %eax
  800a81:	ff 75 0c             	pushl  0xc(%ebp)
  800a84:	68 08 50 80 00       	push   $0x805008
  800a89:	e8 06 0e 00 00       	call   801894 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a93:	b8 04 00 00 00       	mov    $0x4,%eax
  800a98:	e8 cc fe ff ff       	call   800969 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 40 0c             	mov    0xc(%eax),%eax
  800aad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ab2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac2:	e8 a2 fe ff ff       	call   800969 <fsipc>
  800ac7:	89 c3                	mov    %eax,%ebx
  800ac9:	85 c0                	test   %eax,%eax
  800acb:	78 4b                	js     800b18 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800acd:	39 c6                	cmp    %eax,%esi
  800acf:	73 16                	jae    800ae7 <devfile_read+0x48>
  800ad1:	68 04 1f 80 00       	push   $0x801f04
  800ad6:	68 0b 1f 80 00       	push   $0x801f0b
  800adb:	6a 7c                	push   $0x7c
  800add:	68 20 1f 80 00       	push   $0x801f20
  800ae2:	e8 bd 05 00 00       	call   8010a4 <_panic>
	assert(r <= PGSIZE);
  800ae7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aec:	7e 16                	jle    800b04 <devfile_read+0x65>
  800aee:	68 2b 1f 80 00       	push   $0x801f2b
  800af3:	68 0b 1f 80 00       	push   $0x801f0b
  800af8:	6a 7d                	push   $0x7d
  800afa:	68 20 1f 80 00       	push   $0x801f20
  800aff:	e8 a0 05 00 00       	call   8010a4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b04:	83 ec 04             	sub    $0x4,%esp
  800b07:	50                   	push   %eax
  800b08:	68 00 50 80 00       	push   $0x805000
  800b0d:	ff 75 0c             	pushl  0xc(%ebp)
  800b10:	e8 7f 0d 00 00       	call   801894 <memmove>
	return r;
  800b15:	83 c4 10             	add    $0x10,%esp
}
  800b18:	89 d8                	mov    %ebx,%eax
  800b1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	53                   	push   %ebx
  800b25:	83 ec 20             	sub    $0x20,%esp
  800b28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b2b:	53                   	push   %ebx
  800b2c:	e8 98 0b 00 00       	call   8016c9 <strlen>
  800b31:	83 c4 10             	add    $0x10,%esp
  800b34:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b39:	7f 67                	jg     800ba2 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b41:	50                   	push   %eax
  800b42:	e8 9a f8 ff ff       	call   8003e1 <fd_alloc>
  800b47:	83 c4 10             	add    $0x10,%esp
		return r;
  800b4a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	78 57                	js     800ba7 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b50:	83 ec 08             	sub    $0x8,%esp
  800b53:	53                   	push   %ebx
  800b54:	68 00 50 80 00       	push   $0x805000
  800b59:	e8 a4 0b 00 00       	call   801702 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b61:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b69:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6e:	e8 f6 fd ff ff       	call   800969 <fsipc>
  800b73:	89 c3                	mov    %eax,%ebx
  800b75:	83 c4 10             	add    $0x10,%esp
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	79 14                	jns    800b90 <open+0x6f>
		fd_close(fd, 0);
  800b7c:	83 ec 08             	sub    $0x8,%esp
  800b7f:	6a 00                	push   $0x0
  800b81:	ff 75 f4             	pushl  -0xc(%ebp)
  800b84:	e8 50 f9 ff ff       	call   8004d9 <fd_close>
		return r;
  800b89:	83 c4 10             	add    $0x10,%esp
  800b8c:	89 da                	mov    %ebx,%edx
  800b8e:	eb 17                	jmp    800ba7 <open+0x86>
	}

	return fd2num(fd);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	ff 75 f4             	pushl  -0xc(%ebp)
  800b96:	e8 1f f8 ff ff       	call   8003ba <fd2num>
  800b9b:	89 c2                	mov    %eax,%edx
  800b9d:	83 c4 10             	add    $0x10,%esp
  800ba0:	eb 05                	jmp    800ba7 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ba2:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ba7:	89 d0                	mov    %edx,%eax
  800ba9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bac:	c9                   	leave  
  800bad:	c3                   	ret    

00800bae <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 08 00 00 00       	mov    $0x8,%eax
  800bbe:	e8 a6 fd ff ff       	call   800969 <fsipc>
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	ff 75 08             	pushl  0x8(%ebp)
  800bd3:	e8 f2 f7 ff ff       	call   8003ca <fd2data>
  800bd8:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bda:	83 c4 08             	add    $0x8,%esp
  800bdd:	68 37 1f 80 00       	push   $0x801f37
  800be2:	53                   	push   %ebx
  800be3:	e8 1a 0b 00 00       	call   801702 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800be8:	8b 46 04             	mov    0x4(%esi),%eax
  800beb:	2b 06                	sub    (%esi),%eax
  800bed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bf3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bfa:	00 00 00 
	stat->st_dev = &devpipe;
  800bfd:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800c04:	30 80 00 
	return 0;
}
  800c07:	b8 00 00 00 00       	mov    $0x0,%eax
  800c0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    

00800c13 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	53                   	push   %ebx
  800c17:	83 ec 0c             	sub    $0xc,%esp
  800c1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c1d:	53                   	push   %ebx
  800c1e:	6a 00                	push   $0x0
  800c20:	e8 29 f6 ff ff       	call   80024e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c25:	89 1c 24             	mov    %ebx,(%esp)
  800c28:	e8 9d f7 ff ff       	call   8003ca <fd2data>
  800c2d:	83 c4 08             	add    $0x8,%esp
  800c30:	50                   	push   %eax
  800c31:	6a 00                	push   $0x0
  800c33:	e8 16 f6 ff ff       	call   80024e <sys_page_unmap>
}
  800c38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c3b:	c9                   	leave  
  800c3c:	c3                   	ret    

00800c3d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 1c             	sub    $0x1c,%esp
  800c46:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c49:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c4b:	a1 04 40 80 00       	mov    0x804004,%eax
  800c50:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	ff 75 e0             	pushl  -0x20(%ebp)
  800c59:	e8 f8 0e 00 00       	call   801b56 <pageref>
  800c5e:	89 c3                	mov    %eax,%ebx
  800c60:	89 3c 24             	mov    %edi,(%esp)
  800c63:	e8 ee 0e 00 00       	call   801b56 <pageref>
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	39 c3                	cmp    %eax,%ebx
  800c6d:	0f 94 c1             	sete   %cl
  800c70:	0f b6 c9             	movzbl %cl,%ecx
  800c73:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c76:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c7c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c7f:	39 ce                	cmp    %ecx,%esi
  800c81:	74 1b                	je     800c9e <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c83:	39 c3                	cmp    %eax,%ebx
  800c85:	75 c4                	jne    800c4b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c87:	8b 42 58             	mov    0x58(%edx),%eax
  800c8a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c8d:	50                   	push   %eax
  800c8e:	56                   	push   %esi
  800c8f:	68 3e 1f 80 00       	push   $0x801f3e
  800c94:	e8 e4 04 00 00       	call   80117d <cprintf>
  800c99:	83 c4 10             	add    $0x10,%esp
  800c9c:	eb ad                	jmp    800c4b <_pipeisclosed+0xe>
	}
}
  800c9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ca1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    

00800ca9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	57                   	push   %edi
  800cad:	56                   	push   %esi
  800cae:	53                   	push   %ebx
  800caf:	83 ec 28             	sub    $0x28,%esp
  800cb2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800cb5:	56                   	push   %esi
  800cb6:	e8 0f f7 ff ff       	call   8003ca <fd2data>
  800cbb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbd:	83 c4 10             	add    $0x10,%esp
  800cc0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc5:	eb 4b                	jmp    800d12 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cc7:	89 da                	mov    %ebx,%edx
  800cc9:	89 f0                	mov    %esi,%eax
  800ccb:	e8 6d ff ff ff       	call   800c3d <_pipeisclosed>
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	75 48                	jne    800d1c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cd4:	e8 d1 f4 ff ff       	call   8001aa <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cd9:	8b 43 04             	mov    0x4(%ebx),%eax
  800cdc:	8b 0b                	mov    (%ebx),%ecx
  800cde:	8d 51 20             	lea    0x20(%ecx),%edx
  800ce1:	39 d0                	cmp    %edx,%eax
  800ce3:	73 e2                	jae    800cc7 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cec:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cef:	89 c2                	mov    %eax,%edx
  800cf1:	c1 fa 1f             	sar    $0x1f,%edx
  800cf4:	89 d1                	mov    %edx,%ecx
  800cf6:	c1 e9 1b             	shr    $0x1b,%ecx
  800cf9:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cfc:	83 e2 1f             	and    $0x1f,%edx
  800cff:	29 ca                	sub    %ecx,%edx
  800d01:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800d05:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800d09:	83 c0 01             	add    $0x1,%eax
  800d0c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0f:	83 c7 01             	add    $0x1,%edi
  800d12:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800d15:	75 c2                	jne    800cd9 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800d17:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1a:	eb 05                	jmp    800d21 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 18             	sub    $0x18,%esp
  800d32:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d35:	57                   	push   %edi
  800d36:	e8 8f f6 ff ff       	call   8003ca <fd2data>
  800d3b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d45:	eb 3d                	jmp    800d84 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d47:	85 db                	test   %ebx,%ebx
  800d49:	74 04                	je     800d4f <devpipe_read+0x26>
				return i;
  800d4b:	89 d8                	mov    %ebx,%eax
  800d4d:	eb 44                	jmp    800d93 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d4f:	89 f2                	mov    %esi,%edx
  800d51:	89 f8                	mov    %edi,%eax
  800d53:	e8 e5 fe ff ff       	call   800c3d <_pipeisclosed>
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	75 32                	jne    800d8e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d5c:	e8 49 f4 ff ff       	call   8001aa <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d61:	8b 06                	mov    (%esi),%eax
  800d63:	3b 46 04             	cmp    0x4(%esi),%eax
  800d66:	74 df                	je     800d47 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d68:	99                   	cltd   
  800d69:	c1 ea 1b             	shr    $0x1b,%edx
  800d6c:	01 d0                	add    %edx,%eax
  800d6e:	83 e0 1f             	and    $0x1f,%eax
  800d71:	29 d0                	sub    %edx,%eax
  800d73:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d7e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d81:	83 c3 01             	add    $0x1,%ebx
  800d84:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d87:	75 d8                	jne    800d61 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d89:	8b 45 10             	mov    0x10(%ebp),%eax
  800d8c:	eb 05                	jmp    800d93 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d8e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800da3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800da6:	50                   	push   %eax
  800da7:	e8 35 f6 ff ff       	call   8003e1 <fd_alloc>
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	89 c2                	mov    %eax,%edx
  800db1:	85 c0                	test   %eax,%eax
  800db3:	0f 88 2c 01 00 00    	js     800ee5 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db9:	83 ec 04             	sub    $0x4,%esp
  800dbc:	68 07 04 00 00       	push   $0x407
  800dc1:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc4:	6a 00                	push   $0x0
  800dc6:	e8 fe f3 ff ff       	call   8001c9 <sys_page_alloc>
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	89 c2                	mov    %eax,%edx
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	0f 88 0d 01 00 00    	js     800ee5 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dde:	50                   	push   %eax
  800ddf:	e8 fd f5 ff ff       	call   8003e1 <fd_alloc>
  800de4:	89 c3                	mov    %eax,%ebx
  800de6:	83 c4 10             	add    $0x10,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	0f 88 e2 00 00 00    	js     800ed3 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df1:	83 ec 04             	sub    $0x4,%esp
  800df4:	68 07 04 00 00       	push   $0x407
  800df9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 c6 f3 ff ff       	call   8001c9 <sys_page_alloc>
  800e03:	89 c3                	mov    %eax,%ebx
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	0f 88 c3 00 00 00    	js     800ed3 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800e10:	83 ec 0c             	sub    $0xc,%esp
  800e13:	ff 75 f4             	pushl  -0xc(%ebp)
  800e16:	e8 af f5 ff ff       	call   8003ca <fd2data>
  800e1b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e1d:	83 c4 0c             	add    $0xc,%esp
  800e20:	68 07 04 00 00       	push   $0x407
  800e25:	50                   	push   %eax
  800e26:	6a 00                	push   $0x0
  800e28:	e8 9c f3 ff ff       	call   8001c9 <sys_page_alloc>
  800e2d:	89 c3                	mov    %eax,%ebx
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	0f 88 89 00 00 00    	js     800ec3 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e3a:	83 ec 0c             	sub    $0xc,%esp
  800e3d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e40:	e8 85 f5 ff ff       	call   8003ca <fd2data>
  800e45:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e4c:	50                   	push   %eax
  800e4d:	6a 00                	push   $0x0
  800e4f:	56                   	push   %esi
  800e50:	6a 00                	push   $0x0
  800e52:	e8 b5 f3 ff ff       	call   80020c <sys_page_map>
  800e57:	89 c3                	mov    %eax,%ebx
  800e59:	83 c4 20             	add    $0x20,%esp
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	78 55                	js     800eb5 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e60:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e69:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e75:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e7e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e80:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e83:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e90:	e8 25 f5 ff ff       	call   8003ba <fd2num>
  800e95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e98:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e9a:	83 c4 04             	add    $0x4,%esp
  800e9d:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea0:	e8 15 f5 ff ff       	call   8003ba <fd2num>
  800ea5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea8:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb3:	eb 30                	jmp    800ee5 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800eb5:	83 ec 08             	sub    $0x8,%esp
  800eb8:	56                   	push   %esi
  800eb9:	6a 00                	push   $0x0
  800ebb:	e8 8e f3 ff ff       	call   80024e <sys_page_unmap>
  800ec0:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ec3:	83 ec 08             	sub    $0x8,%esp
  800ec6:	ff 75 f0             	pushl  -0x10(%ebp)
  800ec9:	6a 00                	push   $0x0
  800ecb:	e8 7e f3 ff ff       	call   80024e <sys_page_unmap>
  800ed0:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed9:	6a 00                	push   $0x0
  800edb:	e8 6e f3 ff ff       	call   80024e <sys_page_unmap>
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ee5:	89 d0                	mov    %edx,%eax
  800ee7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eea:	5b                   	pop    %ebx
  800eeb:	5e                   	pop    %esi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef7:	50                   	push   %eax
  800ef8:	ff 75 08             	pushl  0x8(%ebp)
  800efb:	e8 30 f5 ff ff       	call   800430 <fd_lookup>
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	85 c0                	test   %eax,%eax
  800f05:	78 18                	js     800f1f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800f07:	83 ec 0c             	sub    $0xc,%esp
  800f0a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0d:	e8 b8 f4 ff ff       	call   8003ca <fd2data>
	return _pipeisclosed(fd, p);
  800f12:	89 c2                	mov    %eax,%edx
  800f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f17:	e8 21 fd ff ff       	call   800c3d <_pipeisclosed>
  800f1c:	83 c4 10             	add    $0x10,%esp
}
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f31:	68 56 1f 80 00       	push   $0x801f56
  800f36:	ff 75 0c             	pushl  0xc(%ebp)
  800f39:	e8 c4 07 00 00       	call   801702 <strcpy>
	return 0;
}
  800f3e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
  800f4b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f51:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f56:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5c:	eb 2d                	jmp    800f8b <devcons_write+0x46>
		m = n - tot;
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f63:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f66:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f6b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f6e:	83 ec 04             	sub    $0x4,%esp
  800f71:	53                   	push   %ebx
  800f72:	03 45 0c             	add    0xc(%ebp),%eax
  800f75:	50                   	push   %eax
  800f76:	57                   	push   %edi
  800f77:	e8 18 09 00 00       	call   801894 <memmove>
		sys_cputs(buf, m);
  800f7c:	83 c4 08             	add    $0x8,%esp
  800f7f:	53                   	push   %ebx
  800f80:	57                   	push   %edi
  800f81:	e8 87 f1 ff ff       	call   80010d <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f86:	01 de                	add    %ebx,%esi
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	89 f0                	mov    %esi,%eax
  800f8d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f90:	72 cc                	jb     800f5e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800fa5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800fa9:	74 2a                	je     800fd5 <devcons_read+0x3b>
  800fab:	eb 05                	jmp    800fb2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800fad:	e8 f8 f1 ff ff       	call   8001aa <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800fb2:	e8 74 f1 ff ff       	call   80012b <sys_cgetc>
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	74 f2                	je     800fad <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	78 16                	js     800fd5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fbf:	83 f8 04             	cmp    $0x4,%eax
  800fc2:	74 0c                	je     800fd0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc7:	88 02                	mov    %al,(%edx)
	return 1;
  800fc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fce:	eb 05                	jmp    800fd5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fd0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe0:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fe3:	6a 01                	push   $0x1
  800fe5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe8:	50                   	push   %eax
  800fe9:	e8 1f f1 ff ff       	call   80010d <sys_cputs>
}
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <getchar>:

int
getchar(void)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800ff9:	6a 01                	push   $0x1
  800ffb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800ffe:	50                   	push   %eax
  800fff:	6a 00                	push   $0x0
  801001:	e8 90 f6 ff ff       	call   800696 <read>
	if (r < 0)
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 0f                	js     80101c <getchar+0x29>
		return r;
	if (r < 1)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	7e 06                	jle    801017 <getchar+0x24>
		return -E_EOF;
	return c;
  801011:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801015:	eb 05                	jmp    80101c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801017:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801024:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801027:	50                   	push   %eax
  801028:	ff 75 08             	pushl  0x8(%ebp)
  80102b:	e8 00 f4 ff ff       	call   800430 <fd_lookup>
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	78 11                	js     801048 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801037:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801040:	39 10                	cmp    %edx,(%eax)
  801042:	0f 94 c0             	sete   %al
  801045:	0f b6 c0             	movzbl %al,%eax
}
  801048:	c9                   	leave  
  801049:	c3                   	ret    

0080104a <opencons>:

int
opencons(void)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801050:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801053:	50                   	push   %eax
  801054:	e8 88 f3 ff ff       	call   8003e1 <fd_alloc>
  801059:	83 c4 10             	add    $0x10,%esp
		return r;
  80105c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80105e:	85 c0                	test   %eax,%eax
  801060:	78 3e                	js     8010a0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801062:	83 ec 04             	sub    $0x4,%esp
  801065:	68 07 04 00 00       	push   $0x407
  80106a:	ff 75 f4             	pushl  -0xc(%ebp)
  80106d:	6a 00                	push   $0x0
  80106f:	e8 55 f1 ff ff       	call   8001c9 <sys_page_alloc>
  801074:	83 c4 10             	add    $0x10,%esp
		return r;
  801077:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801079:	85 c0                	test   %eax,%eax
  80107b:	78 23                	js     8010a0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80107d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801083:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801086:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801088:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	50                   	push   %eax
  801096:	e8 1f f3 ff ff       	call   8003ba <fd2num>
  80109b:	89 c2                	mov    %eax,%edx
  80109d:	83 c4 10             	add    $0x10,%esp
}
  8010a0:	89 d0                	mov    %edx,%eax
  8010a2:	c9                   	leave  
  8010a3:	c3                   	ret    

008010a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010a9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010ac:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8010b2:	e8 d4 f0 ff ff       	call   80018b <sys_getenvid>
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	ff 75 0c             	pushl  0xc(%ebp)
  8010bd:	ff 75 08             	pushl  0x8(%ebp)
  8010c0:	56                   	push   %esi
  8010c1:	50                   	push   %eax
  8010c2:	68 64 1f 80 00       	push   $0x801f64
  8010c7:	e8 b1 00 00 00       	call   80117d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010cc:	83 c4 18             	add    $0x18,%esp
  8010cf:	53                   	push   %ebx
  8010d0:	ff 75 10             	pushl  0x10(%ebp)
  8010d3:	e8 54 00 00 00       	call   80112c <vcprintf>
	cprintf("\n");
  8010d8:	c7 04 24 4f 1f 80 00 	movl   $0x801f4f,(%esp)
  8010df:	e8 99 00 00 00       	call   80117d <cprintf>
  8010e4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010e7:	cc                   	int3   
  8010e8:	eb fd                	jmp    8010e7 <_panic+0x43>

008010ea <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010ea:	55                   	push   %ebp
  8010eb:	89 e5                	mov    %esp,%ebp
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 04             	sub    $0x4,%esp
  8010f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010f4:	8b 13                	mov    (%ebx),%edx
  8010f6:	8d 42 01             	lea    0x1(%edx),%eax
  8010f9:	89 03                	mov    %eax,(%ebx)
  8010fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801102:	3d ff 00 00 00       	cmp    $0xff,%eax
  801107:	75 1a                	jne    801123 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801109:	83 ec 08             	sub    $0x8,%esp
  80110c:	68 ff 00 00 00       	push   $0xff
  801111:	8d 43 08             	lea    0x8(%ebx),%eax
  801114:	50                   	push   %eax
  801115:	e8 f3 ef ff ff       	call   80010d <sys_cputs>
		b->idx = 0;
  80111a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801120:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801123:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801127:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801135:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80113c:	00 00 00 
	b.cnt = 0;
  80113f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801146:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801149:	ff 75 0c             	pushl  0xc(%ebp)
  80114c:	ff 75 08             	pushl  0x8(%ebp)
  80114f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801155:	50                   	push   %eax
  801156:	68 ea 10 80 00       	push   $0x8010ea
  80115b:	e8 54 01 00 00       	call   8012b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801160:	83 c4 08             	add    $0x8,%esp
  801163:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801169:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	e8 98 ef ff ff       	call   80010d <sys_cputs>

	return b.cnt;
}
  801175:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80117b:	c9                   	leave  
  80117c:	c3                   	ret    

0080117d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801183:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801186:	50                   	push   %eax
  801187:	ff 75 08             	pushl  0x8(%ebp)
  80118a:	e8 9d ff ff ff       	call   80112c <vcprintf>
	va_end(ap);

	return cnt;
}
  80118f:	c9                   	leave  
  801190:	c3                   	ret    

00801191 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	57                   	push   %edi
  801195:	56                   	push   %esi
  801196:	53                   	push   %ebx
  801197:	83 ec 1c             	sub    $0x1c,%esp
  80119a:	89 c7                	mov    %eax,%edi
  80119c:	89 d6                	mov    %edx,%esi
  80119e:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8011a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8011aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8011b5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8011b8:	39 d3                	cmp    %edx,%ebx
  8011ba:	72 05                	jb     8011c1 <printnum+0x30>
  8011bc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8011bf:	77 45                	ja     801206 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011c1:	83 ec 0c             	sub    $0xc,%esp
  8011c4:	ff 75 18             	pushl  0x18(%ebp)
  8011c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8011ca:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011cd:	53                   	push   %ebx
  8011ce:	ff 75 10             	pushl  0x10(%ebp)
  8011d1:	83 ec 08             	sub    $0x8,%esp
  8011d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011da:	ff 75 dc             	pushl  -0x24(%ebp)
  8011dd:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e0:	e8 bb 09 00 00       	call   801ba0 <__udivdi3>
  8011e5:	83 c4 18             	add    $0x18,%esp
  8011e8:	52                   	push   %edx
  8011e9:	50                   	push   %eax
  8011ea:	89 f2                	mov    %esi,%edx
  8011ec:	89 f8                	mov    %edi,%eax
  8011ee:	e8 9e ff ff ff       	call   801191 <printnum>
  8011f3:	83 c4 20             	add    $0x20,%esp
  8011f6:	eb 18                	jmp    801210 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	56                   	push   %esi
  8011fc:	ff 75 18             	pushl  0x18(%ebp)
  8011ff:	ff d7                	call   *%edi
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	eb 03                	jmp    801209 <printnum+0x78>
  801206:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801209:	83 eb 01             	sub    $0x1,%ebx
  80120c:	85 db                	test   %ebx,%ebx
  80120e:	7f e8                	jg     8011f8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	56                   	push   %esi
  801214:	83 ec 04             	sub    $0x4,%esp
  801217:	ff 75 e4             	pushl  -0x1c(%ebp)
  80121a:	ff 75 e0             	pushl  -0x20(%ebp)
  80121d:	ff 75 dc             	pushl  -0x24(%ebp)
  801220:	ff 75 d8             	pushl  -0x28(%ebp)
  801223:	e8 a8 0a 00 00       	call   801cd0 <__umoddi3>
  801228:	83 c4 14             	add    $0x14,%esp
  80122b:	0f be 80 87 1f 80 00 	movsbl 0x801f87(%eax),%eax
  801232:	50                   	push   %eax
  801233:	ff d7                	call   *%edi
}
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5f                   	pop    %edi
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801243:	83 fa 01             	cmp    $0x1,%edx
  801246:	7e 0e                	jle    801256 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801248:	8b 10                	mov    (%eax),%edx
  80124a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80124d:	89 08                	mov    %ecx,(%eax)
  80124f:	8b 02                	mov    (%edx),%eax
  801251:	8b 52 04             	mov    0x4(%edx),%edx
  801254:	eb 22                	jmp    801278 <getuint+0x38>
	else if (lflag)
  801256:	85 d2                	test   %edx,%edx
  801258:	74 10                	je     80126a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80125a:	8b 10                	mov    (%eax),%edx
  80125c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80125f:	89 08                	mov    %ecx,(%eax)
  801261:	8b 02                	mov    (%edx),%eax
  801263:	ba 00 00 00 00       	mov    $0x0,%edx
  801268:	eb 0e                	jmp    801278 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80126a:	8b 10                	mov    (%eax),%edx
  80126c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80126f:	89 08                	mov    %ecx,(%eax)
  801271:	8b 02                	mov    (%edx),%eax
  801273:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801280:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801284:	8b 10                	mov    (%eax),%edx
  801286:	3b 50 04             	cmp    0x4(%eax),%edx
  801289:	73 0a                	jae    801295 <sprintputch+0x1b>
		*b->buf++ = ch;
  80128b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80128e:	89 08                	mov    %ecx,(%eax)
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
  801293:	88 02                	mov    %al,(%edx)
}
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80129d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012a0:	50                   	push   %eax
  8012a1:	ff 75 10             	pushl  0x10(%ebp)
  8012a4:	ff 75 0c             	pushl  0xc(%ebp)
  8012a7:	ff 75 08             	pushl  0x8(%ebp)
  8012aa:	e8 05 00 00 00       	call   8012b4 <vprintfmt>
	va_end(ap);
}
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	c9                   	leave  
  8012b3:	c3                   	ret    

008012b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	57                   	push   %edi
  8012b8:	56                   	push   %esi
  8012b9:	53                   	push   %ebx
  8012ba:	83 ec 2c             	sub    $0x2c,%esp
  8012bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8012c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012c6:	eb 12                	jmp    8012da <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	0f 84 89 03 00 00    	je     801659 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	53                   	push   %ebx
  8012d4:	50                   	push   %eax
  8012d5:	ff d6                	call   *%esi
  8012d7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012da:	83 c7 01             	add    $0x1,%edi
  8012dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012e1:	83 f8 25             	cmp    $0x25,%eax
  8012e4:	75 e2                	jne    8012c8 <vprintfmt+0x14>
  8012e6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012ea:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012f1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012f8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801304:	eb 07                	jmp    80130d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801306:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801309:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130d:	8d 47 01             	lea    0x1(%edi),%eax
  801310:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801313:	0f b6 07             	movzbl (%edi),%eax
  801316:	0f b6 c8             	movzbl %al,%ecx
  801319:	83 e8 23             	sub    $0x23,%eax
  80131c:	3c 55                	cmp    $0x55,%al
  80131e:	0f 87 1a 03 00 00    	ja     80163e <vprintfmt+0x38a>
  801324:	0f b6 c0             	movzbl %al,%eax
  801327:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80132e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801331:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801335:	eb d6                	jmp    80130d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
  80133f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801342:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801345:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801349:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80134c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80134f:	83 fa 09             	cmp    $0x9,%edx
  801352:	77 39                	ja     80138d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801354:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801357:	eb e9                	jmp    801342 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801359:	8b 45 14             	mov    0x14(%ebp),%eax
  80135c:	8d 48 04             	lea    0x4(%eax),%ecx
  80135f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801362:	8b 00                	mov    (%eax),%eax
  801364:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80136a:	eb 27                	jmp    801393 <vprintfmt+0xdf>
  80136c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80136f:	85 c0                	test   %eax,%eax
  801371:	b9 00 00 00 00       	mov    $0x0,%ecx
  801376:	0f 49 c8             	cmovns %eax,%ecx
  801379:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80137f:	eb 8c                	jmp    80130d <vprintfmt+0x59>
  801381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801384:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80138b:	eb 80                	jmp    80130d <vprintfmt+0x59>
  80138d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801390:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801393:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801397:	0f 89 70 ff ff ff    	jns    80130d <vprintfmt+0x59>
				width = precision, precision = -1;
  80139d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8013a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8013aa:	e9 5e ff ff ff       	jmp    80130d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8013af:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8013b5:	e9 53 ff ff ff       	jmp    80130d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8013ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8013bd:	8d 50 04             	lea    0x4(%eax),%edx
  8013c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	53                   	push   %ebx
  8013c7:	ff 30                	pushl  (%eax)
  8013c9:	ff d6                	call   *%esi
			break;
  8013cb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013d1:	e9 04 ff ff ff       	jmp    8012da <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d9:	8d 50 04             	lea    0x4(%eax),%edx
  8013dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8013df:	8b 00                	mov    (%eax),%eax
  8013e1:	99                   	cltd   
  8013e2:	31 d0                	xor    %edx,%eax
  8013e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013e6:	83 f8 0f             	cmp    $0xf,%eax
  8013e9:	7f 0b                	jg     8013f6 <vprintfmt+0x142>
  8013eb:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  8013f2:	85 d2                	test   %edx,%edx
  8013f4:	75 18                	jne    80140e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013f6:	50                   	push   %eax
  8013f7:	68 9f 1f 80 00       	push   $0x801f9f
  8013fc:	53                   	push   %ebx
  8013fd:	56                   	push   %esi
  8013fe:	e8 94 fe ff ff       	call   801297 <printfmt>
  801403:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801409:	e9 cc fe ff ff       	jmp    8012da <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80140e:	52                   	push   %edx
  80140f:	68 1d 1f 80 00       	push   $0x801f1d
  801414:	53                   	push   %ebx
  801415:	56                   	push   %esi
  801416:	e8 7c fe ff ff       	call   801297 <printfmt>
  80141b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80141e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801421:	e9 b4 fe ff ff       	jmp    8012da <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801426:	8b 45 14             	mov    0x14(%ebp),%eax
  801429:	8d 50 04             	lea    0x4(%eax),%edx
  80142c:	89 55 14             	mov    %edx,0x14(%ebp)
  80142f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801431:	85 ff                	test   %edi,%edi
  801433:	b8 98 1f 80 00       	mov    $0x801f98,%eax
  801438:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80143b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80143f:	0f 8e 94 00 00 00    	jle    8014d9 <vprintfmt+0x225>
  801445:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801449:	0f 84 98 00 00 00    	je     8014e7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80144f:	83 ec 08             	sub    $0x8,%esp
  801452:	ff 75 d0             	pushl  -0x30(%ebp)
  801455:	57                   	push   %edi
  801456:	e8 86 02 00 00       	call   8016e1 <strnlen>
  80145b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80145e:	29 c1                	sub    %eax,%ecx
  801460:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801463:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801466:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80146a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80146d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801470:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801472:	eb 0f                	jmp    801483 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	53                   	push   %ebx
  801478:	ff 75 e0             	pushl  -0x20(%ebp)
  80147b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80147d:	83 ef 01             	sub    $0x1,%edi
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	85 ff                	test   %edi,%edi
  801485:	7f ed                	jg     801474 <vprintfmt+0x1c0>
  801487:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80148a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80148d:	85 c9                	test   %ecx,%ecx
  80148f:	b8 00 00 00 00       	mov    $0x0,%eax
  801494:	0f 49 c1             	cmovns %ecx,%eax
  801497:	29 c1                	sub    %eax,%ecx
  801499:	89 75 08             	mov    %esi,0x8(%ebp)
  80149c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80149f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a2:	89 cb                	mov    %ecx,%ebx
  8014a4:	eb 4d                	jmp    8014f3 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8014a6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014aa:	74 1b                	je     8014c7 <vprintfmt+0x213>
  8014ac:	0f be c0             	movsbl %al,%eax
  8014af:	83 e8 20             	sub    $0x20,%eax
  8014b2:	83 f8 5e             	cmp    $0x5e,%eax
  8014b5:	76 10                	jbe    8014c7 <vprintfmt+0x213>
					putch('?', putdat);
  8014b7:	83 ec 08             	sub    $0x8,%esp
  8014ba:	ff 75 0c             	pushl  0xc(%ebp)
  8014bd:	6a 3f                	push   $0x3f
  8014bf:	ff 55 08             	call   *0x8(%ebp)
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	eb 0d                	jmp    8014d4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	ff 75 0c             	pushl  0xc(%ebp)
  8014cd:	52                   	push   %edx
  8014ce:	ff 55 08             	call   *0x8(%ebp)
  8014d1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014d4:	83 eb 01             	sub    $0x1,%ebx
  8014d7:	eb 1a                	jmp    8014f3 <vprintfmt+0x23f>
  8014d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8014dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014e2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014e5:	eb 0c                	jmp    8014f3 <vprintfmt+0x23f>
  8014e7:	89 75 08             	mov    %esi,0x8(%ebp)
  8014ea:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014f0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014f3:	83 c7 01             	add    $0x1,%edi
  8014f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014fa:	0f be d0             	movsbl %al,%edx
  8014fd:	85 d2                	test   %edx,%edx
  8014ff:	74 23                	je     801524 <vprintfmt+0x270>
  801501:	85 f6                	test   %esi,%esi
  801503:	78 a1                	js     8014a6 <vprintfmt+0x1f2>
  801505:	83 ee 01             	sub    $0x1,%esi
  801508:	79 9c                	jns    8014a6 <vprintfmt+0x1f2>
  80150a:	89 df                	mov    %ebx,%edi
  80150c:	8b 75 08             	mov    0x8(%ebp),%esi
  80150f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801512:	eb 18                	jmp    80152c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	53                   	push   %ebx
  801518:	6a 20                	push   $0x20
  80151a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80151c:	83 ef 01             	sub    $0x1,%edi
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	eb 08                	jmp    80152c <vprintfmt+0x278>
  801524:	89 df                	mov    %ebx,%edi
  801526:	8b 75 08             	mov    0x8(%ebp),%esi
  801529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80152c:	85 ff                	test   %edi,%edi
  80152e:	7f e4                	jg     801514 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801533:	e9 a2 fd ff ff       	jmp    8012da <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801538:	83 fa 01             	cmp    $0x1,%edx
  80153b:	7e 16                	jle    801553 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80153d:	8b 45 14             	mov    0x14(%ebp),%eax
  801540:	8d 50 08             	lea    0x8(%eax),%edx
  801543:	89 55 14             	mov    %edx,0x14(%ebp)
  801546:	8b 50 04             	mov    0x4(%eax),%edx
  801549:	8b 00                	mov    (%eax),%eax
  80154b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801551:	eb 32                	jmp    801585 <vprintfmt+0x2d1>
	else if (lflag)
  801553:	85 d2                	test   %edx,%edx
  801555:	74 18                	je     80156f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801557:	8b 45 14             	mov    0x14(%ebp),%eax
  80155a:	8d 50 04             	lea    0x4(%eax),%edx
  80155d:	89 55 14             	mov    %edx,0x14(%ebp)
  801560:	8b 00                	mov    (%eax),%eax
  801562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801565:	89 c1                	mov    %eax,%ecx
  801567:	c1 f9 1f             	sar    $0x1f,%ecx
  80156a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80156d:	eb 16                	jmp    801585 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80156f:	8b 45 14             	mov    0x14(%ebp),%eax
  801572:	8d 50 04             	lea    0x4(%eax),%edx
  801575:	89 55 14             	mov    %edx,0x14(%ebp)
  801578:	8b 00                	mov    (%eax),%eax
  80157a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80157d:	89 c1                	mov    %eax,%ecx
  80157f:	c1 f9 1f             	sar    $0x1f,%ecx
  801582:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801585:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801588:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80158b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801590:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801594:	79 74                	jns    80160a <vprintfmt+0x356>
				putch('-', putdat);
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	53                   	push   %ebx
  80159a:	6a 2d                	push   $0x2d
  80159c:	ff d6                	call   *%esi
				num = -(long long) num;
  80159e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8015a1:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8015a4:	f7 d8                	neg    %eax
  8015a6:	83 d2 00             	adc    $0x0,%edx
  8015a9:	f7 da                	neg    %edx
  8015ab:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8015ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8015b3:	eb 55                	jmp    80160a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8015b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b8:	e8 83 fc ff ff       	call   801240 <getuint>
			base = 10;
  8015bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015c2:	eb 46                	jmp    80160a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8015c7:	e8 74 fc ff ff       	call   801240 <getuint>
			base = 8;
  8015cc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015d1:	eb 37                	jmp    80160a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015d3:	83 ec 08             	sub    $0x8,%esp
  8015d6:	53                   	push   %ebx
  8015d7:	6a 30                	push   $0x30
  8015d9:	ff d6                	call   *%esi
			putch('x', putdat);
  8015db:	83 c4 08             	add    $0x8,%esp
  8015de:	53                   	push   %ebx
  8015df:	6a 78                	push   $0x78
  8015e1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e6:	8d 50 04             	lea    0x4(%eax),%edx
  8015e9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015ec:	8b 00                	mov    (%eax),%eax
  8015ee:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015f3:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015f6:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015fb:	eb 0d                	jmp    80160a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015fd:	8d 45 14             	lea    0x14(%ebp),%eax
  801600:	e8 3b fc ff ff       	call   801240 <getuint>
			base = 16;
  801605:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80160a:	83 ec 0c             	sub    $0xc,%esp
  80160d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801611:	57                   	push   %edi
  801612:	ff 75 e0             	pushl  -0x20(%ebp)
  801615:	51                   	push   %ecx
  801616:	52                   	push   %edx
  801617:	50                   	push   %eax
  801618:	89 da                	mov    %ebx,%edx
  80161a:	89 f0                	mov    %esi,%eax
  80161c:	e8 70 fb ff ff       	call   801191 <printnum>
			break;
  801621:	83 c4 20             	add    $0x20,%esp
  801624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801627:	e9 ae fc ff ff       	jmp    8012da <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	53                   	push   %ebx
  801630:	51                   	push   %ecx
  801631:	ff d6                	call   *%esi
			break;
  801633:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801639:	e9 9c fc ff ff       	jmp    8012da <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	53                   	push   %ebx
  801642:	6a 25                	push   $0x25
  801644:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	eb 03                	jmp    80164e <vprintfmt+0x39a>
  80164b:	83 ef 01             	sub    $0x1,%edi
  80164e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801652:	75 f7                	jne    80164b <vprintfmt+0x397>
  801654:	e9 81 fc ff ff       	jmp    8012da <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165c:	5b                   	pop    %ebx
  80165d:	5e                   	pop    %esi
  80165e:	5f                   	pop    %edi
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    

00801661 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 18             	sub    $0x18,%esp
  801667:	8b 45 08             	mov    0x8(%ebp),%eax
  80166a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80166d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801670:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801674:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801677:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80167e:	85 c0                	test   %eax,%eax
  801680:	74 26                	je     8016a8 <vsnprintf+0x47>
  801682:	85 d2                	test   %edx,%edx
  801684:	7e 22                	jle    8016a8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801686:	ff 75 14             	pushl  0x14(%ebp)
  801689:	ff 75 10             	pushl  0x10(%ebp)
  80168c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80168f:	50                   	push   %eax
  801690:	68 7a 12 80 00       	push   $0x80127a
  801695:	e8 1a fc ff ff       	call   8012b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80169a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80169d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a3:	83 c4 10             	add    $0x10,%esp
  8016a6:	eb 05                	jmp    8016ad <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016b5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016b8:	50                   	push   %eax
  8016b9:	ff 75 10             	pushl  0x10(%ebp)
  8016bc:	ff 75 0c             	pushl  0xc(%ebp)
  8016bf:	ff 75 08             	pushl  0x8(%ebp)
  8016c2:	e8 9a ff ff ff       	call   801661 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d4:	eb 03                	jmp    8016d9 <strlen+0x10>
		n++;
  8016d6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016d9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016dd:	75 f7                	jne    8016d6 <strlen+0xd>
		n++;
	return n;
}
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ef:	eb 03                	jmp    8016f4 <strnlen+0x13>
		n++;
  8016f1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f4:	39 c2                	cmp    %eax,%edx
  8016f6:	74 08                	je     801700 <strnlen+0x1f>
  8016f8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016fc:	75 f3                	jne    8016f1 <strnlen+0x10>
  8016fe:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    

00801702 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	53                   	push   %ebx
  801706:	8b 45 08             	mov    0x8(%ebp),%eax
  801709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80170c:	89 c2                	mov    %eax,%edx
  80170e:	83 c2 01             	add    $0x1,%edx
  801711:	83 c1 01             	add    $0x1,%ecx
  801714:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801718:	88 5a ff             	mov    %bl,-0x1(%edx)
  80171b:	84 db                	test   %bl,%bl
  80171d:	75 ef                	jne    80170e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80171f:	5b                   	pop    %ebx
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	53                   	push   %ebx
  801726:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801729:	53                   	push   %ebx
  80172a:	e8 9a ff ff ff       	call   8016c9 <strlen>
  80172f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801732:	ff 75 0c             	pushl  0xc(%ebp)
  801735:	01 d8                	add    %ebx,%eax
  801737:	50                   	push   %eax
  801738:	e8 c5 ff ff ff       	call   801702 <strcpy>
	return dst;
}
  80173d:	89 d8                	mov    %ebx,%eax
  80173f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	56                   	push   %esi
  801748:	53                   	push   %ebx
  801749:	8b 75 08             	mov    0x8(%ebp),%esi
  80174c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174f:	89 f3                	mov    %esi,%ebx
  801751:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801754:	89 f2                	mov    %esi,%edx
  801756:	eb 0f                	jmp    801767 <strncpy+0x23>
		*dst++ = *src;
  801758:	83 c2 01             	add    $0x1,%edx
  80175b:	0f b6 01             	movzbl (%ecx),%eax
  80175e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801761:	80 39 01             	cmpb   $0x1,(%ecx)
  801764:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801767:	39 da                	cmp    %ebx,%edx
  801769:	75 ed                	jne    801758 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80176b:	89 f0                	mov    %esi,%eax
  80176d:	5b                   	pop    %ebx
  80176e:	5e                   	pop    %esi
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	56                   	push   %esi
  801775:	53                   	push   %ebx
  801776:	8b 75 08             	mov    0x8(%ebp),%esi
  801779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177c:	8b 55 10             	mov    0x10(%ebp),%edx
  80177f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801781:	85 d2                	test   %edx,%edx
  801783:	74 21                	je     8017a6 <strlcpy+0x35>
  801785:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801789:	89 f2                	mov    %esi,%edx
  80178b:	eb 09                	jmp    801796 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80178d:	83 c2 01             	add    $0x1,%edx
  801790:	83 c1 01             	add    $0x1,%ecx
  801793:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801796:	39 c2                	cmp    %eax,%edx
  801798:	74 09                	je     8017a3 <strlcpy+0x32>
  80179a:	0f b6 19             	movzbl (%ecx),%ebx
  80179d:	84 db                	test   %bl,%bl
  80179f:	75 ec                	jne    80178d <strlcpy+0x1c>
  8017a1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017a3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017a6:	29 f0                	sub    %esi,%eax
}
  8017a8:	5b                   	pop    %ebx
  8017a9:	5e                   	pop    %esi
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017b5:	eb 06                	jmp    8017bd <strcmp+0x11>
		p++, q++;
  8017b7:	83 c1 01             	add    $0x1,%ecx
  8017ba:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017bd:	0f b6 01             	movzbl (%ecx),%eax
  8017c0:	84 c0                	test   %al,%al
  8017c2:	74 04                	je     8017c8 <strcmp+0x1c>
  8017c4:	3a 02                	cmp    (%edx),%al
  8017c6:	74 ef                	je     8017b7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c8:	0f b6 c0             	movzbl %al,%eax
  8017cb:	0f b6 12             	movzbl (%edx),%edx
  8017ce:	29 d0                	sub    %edx,%eax
}
  8017d0:	5d                   	pop    %ebp
  8017d1:	c3                   	ret    

008017d2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	53                   	push   %ebx
  8017d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017e1:	eb 06                	jmp    8017e9 <strncmp+0x17>
		n--, p++, q++;
  8017e3:	83 c0 01             	add    $0x1,%eax
  8017e6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017e9:	39 d8                	cmp    %ebx,%eax
  8017eb:	74 15                	je     801802 <strncmp+0x30>
  8017ed:	0f b6 08             	movzbl (%eax),%ecx
  8017f0:	84 c9                	test   %cl,%cl
  8017f2:	74 04                	je     8017f8 <strncmp+0x26>
  8017f4:	3a 0a                	cmp    (%edx),%cl
  8017f6:	74 eb                	je     8017e3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f8:	0f b6 00             	movzbl (%eax),%eax
  8017fb:	0f b6 12             	movzbl (%edx),%edx
  8017fe:	29 d0                	sub    %edx,%eax
  801800:	eb 05                	jmp    801807 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801802:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801807:	5b                   	pop    %ebx
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801814:	eb 07                	jmp    80181d <strchr+0x13>
		if (*s == c)
  801816:	38 ca                	cmp    %cl,%dl
  801818:	74 0f                	je     801829 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80181a:	83 c0 01             	add    $0x1,%eax
  80181d:	0f b6 10             	movzbl (%eax),%edx
  801820:	84 d2                	test   %dl,%dl
  801822:	75 f2                	jne    801816 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801824:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801829:	5d                   	pop    %ebp
  80182a:	c3                   	ret    

0080182b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	8b 45 08             	mov    0x8(%ebp),%eax
  801831:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801835:	eb 03                	jmp    80183a <strfind+0xf>
  801837:	83 c0 01             	add    $0x1,%eax
  80183a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80183d:	38 ca                	cmp    %cl,%dl
  80183f:	74 04                	je     801845 <strfind+0x1a>
  801841:	84 d2                	test   %dl,%dl
  801843:	75 f2                	jne    801837 <strfind+0xc>
			break;
	return (char *) s;
}
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	57                   	push   %edi
  80184b:	56                   	push   %esi
  80184c:	53                   	push   %ebx
  80184d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801850:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801853:	85 c9                	test   %ecx,%ecx
  801855:	74 36                	je     80188d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801857:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80185d:	75 28                	jne    801887 <memset+0x40>
  80185f:	f6 c1 03             	test   $0x3,%cl
  801862:	75 23                	jne    801887 <memset+0x40>
		c &= 0xFF;
  801864:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801868:	89 d3                	mov    %edx,%ebx
  80186a:	c1 e3 08             	shl    $0x8,%ebx
  80186d:	89 d6                	mov    %edx,%esi
  80186f:	c1 e6 18             	shl    $0x18,%esi
  801872:	89 d0                	mov    %edx,%eax
  801874:	c1 e0 10             	shl    $0x10,%eax
  801877:	09 f0                	or     %esi,%eax
  801879:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80187b:	89 d8                	mov    %ebx,%eax
  80187d:	09 d0                	or     %edx,%eax
  80187f:	c1 e9 02             	shr    $0x2,%ecx
  801882:	fc                   	cld    
  801883:	f3 ab                	rep stos %eax,%es:(%edi)
  801885:	eb 06                	jmp    80188d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801887:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188a:	fc                   	cld    
  80188b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80188d:	89 f8                	mov    %edi,%eax
  80188f:	5b                   	pop    %ebx
  801890:	5e                   	pop    %esi
  801891:	5f                   	pop    %edi
  801892:	5d                   	pop    %ebp
  801893:	c3                   	ret    

00801894 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	57                   	push   %edi
  801898:	56                   	push   %esi
  801899:	8b 45 08             	mov    0x8(%ebp),%eax
  80189c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80189f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018a2:	39 c6                	cmp    %eax,%esi
  8018a4:	73 35                	jae    8018db <memmove+0x47>
  8018a6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018a9:	39 d0                	cmp    %edx,%eax
  8018ab:	73 2e                	jae    8018db <memmove+0x47>
		s += n;
		d += n;
  8018ad:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b0:	89 d6                	mov    %edx,%esi
  8018b2:	09 fe                	or     %edi,%esi
  8018b4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018ba:	75 13                	jne    8018cf <memmove+0x3b>
  8018bc:	f6 c1 03             	test   $0x3,%cl
  8018bf:	75 0e                	jne    8018cf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018c1:	83 ef 04             	sub    $0x4,%edi
  8018c4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018c7:	c1 e9 02             	shr    $0x2,%ecx
  8018ca:	fd                   	std    
  8018cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018cd:	eb 09                	jmp    8018d8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018cf:	83 ef 01             	sub    $0x1,%edi
  8018d2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018d5:	fd                   	std    
  8018d6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018d8:	fc                   	cld    
  8018d9:	eb 1d                	jmp    8018f8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018db:	89 f2                	mov    %esi,%edx
  8018dd:	09 c2                	or     %eax,%edx
  8018df:	f6 c2 03             	test   $0x3,%dl
  8018e2:	75 0f                	jne    8018f3 <memmove+0x5f>
  8018e4:	f6 c1 03             	test   $0x3,%cl
  8018e7:	75 0a                	jne    8018f3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018e9:	c1 e9 02             	shr    $0x2,%ecx
  8018ec:	89 c7                	mov    %eax,%edi
  8018ee:	fc                   	cld    
  8018ef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f1:	eb 05                	jmp    8018f8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018f3:	89 c7                	mov    %eax,%edi
  8018f5:	fc                   	cld    
  8018f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018f8:	5e                   	pop    %esi
  8018f9:	5f                   	pop    %edi
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    

008018fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018ff:	ff 75 10             	pushl  0x10(%ebp)
  801902:	ff 75 0c             	pushl  0xc(%ebp)
  801905:	ff 75 08             	pushl  0x8(%ebp)
  801908:	e8 87 ff ff ff       	call   801894 <memmove>
}
  80190d:	c9                   	leave  
  80190e:	c3                   	ret    

0080190f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	56                   	push   %esi
  801913:	53                   	push   %ebx
  801914:	8b 45 08             	mov    0x8(%ebp),%eax
  801917:	8b 55 0c             	mov    0xc(%ebp),%edx
  80191a:	89 c6                	mov    %eax,%esi
  80191c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80191f:	eb 1a                	jmp    80193b <memcmp+0x2c>
		if (*s1 != *s2)
  801921:	0f b6 08             	movzbl (%eax),%ecx
  801924:	0f b6 1a             	movzbl (%edx),%ebx
  801927:	38 d9                	cmp    %bl,%cl
  801929:	74 0a                	je     801935 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80192b:	0f b6 c1             	movzbl %cl,%eax
  80192e:	0f b6 db             	movzbl %bl,%ebx
  801931:	29 d8                	sub    %ebx,%eax
  801933:	eb 0f                	jmp    801944 <memcmp+0x35>
		s1++, s2++;
  801935:	83 c0 01             	add    $0x1,%eax
  801938:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80193b:	39 f0                	cmp    %esi,%eax
  80193d:	75 e2                	jne    801921 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80193f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801944:	5b                   	pop    %ebx
  801945:	5e                   	pop    %esi
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	53                   	push   %ebx
  80194c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80194f:	89 c1                	mov    %eax,%ecx
  801951:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801954:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801958:	eb 0a                	jmp    801964 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80195a:	0f b6 10             	movzbl (%eax),%edx
  80195d:	39 da                	cmp    %ebx,%edx
  80195f:	74 07                	je     801968 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801961:	83 c0 01             	add    $0x1,%eax
  801964:	39 c8                	cmp    %ecx,%eax
  801966:	72 f2                	jb     80195a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801968:	5b                   	pop    %ebx
  801969:	5d                   	pop    %ebp
  80196a:	c3                   	ret    

0080196b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	57                   	push   %edi
  80196f:	56                   	push   %esi
  801970:	53                   	push   %ebx
  801971:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801974:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801977:	eb 03                	jmp    80197c <strtol+0x11>
		s++;
  801979:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80197c:	0f b6 01             	movzbl (%ecx),%eax
  80197f:	3c 20                	cmp    $0x20,%al
  801981:	74 f6                	je     801979 <strtol+0xe>
  801983:	3c 09                	cmp    $0x9,%al
  801985:	74 f2                	je     801979 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801987:	3c 2b                	cmp    $0x2b,%al
  801989:	75 0a                	jne    801995 <strtol+0x2a>
		s++;
  80198b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80198e:	bf 00 00 00 00       	mov    $0x0,%edi
  801993:	eb 11                	jmp    8019a6 <strtol+0x3b>
  801995:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80199a:	3c 2d                	cmp    $0x2d,%al
  80199c:	75 08                	jne    8019a6 <strtol+0x3b>
		s++, neg = 1;
  80199e:	83 c1 01             	add    $0x1,%ecx
  8019a1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019a6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019ac:	75 15                	jne    8019c3 <strtol+0x58>
  8019ae:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b1:	75 10                	jne    8019c3 <strtol+0x58>
  8019b3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019b7:	75 7c                	jne    801a35 <strtol+0xca>
		s += 2, base = 16;
  8019b9:	83 c1 02             	add    $0x2,%ecx
  8019bc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019c1:	eb 16                	jmp    8019d9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019c3:	85 db                	test   %ebx,%ebx
  8019c5:	75 12                	jne    8019d9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019c7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019cc:	80 39 30             	cmpb   $0x30,(%ecx)
  8019cf:	75 08                	jne    8019d9 <strtol+0x6e>
		s++, base = 8;
  8019d1:	83 c1 01             	add    $0x1,%ecx
  8019d4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019de:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019e1:	0f b6 11             	movzbl (%ecx),%edx
  8019e4:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019e7:	89 f3                	mov    %esi,%ebx
  8019e9:	80 fb 09             	cmp    $0x9,%bl
  8019ec:	77 08                	ja     8019f6 <strtol+0x8b>
			dig = *s - '0';
  8019ee:	0f be d2             	movsbl %dl,%edx
  8019f1:	83 ea 30             	sub    $0x30,%edx
  8019f4:	eb 22                	jmp    801a18 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019f6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019f9:	89 f3                	mov    %esi,%ebx
  8019fb:	80 fb 19             	cmp    $0x19,%bl
  8019fe:	77 08                	ja     801a08 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a00:	0f be d2             	movsbl %dl,%edx
  801a03:	83 ea 57             	sub    $0x57,%edx
  801a06:	eb 10                	jmp    801a18 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a08:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a0b:	89 f3                	mov    %esi,%ebx
  801a0d:	80 fb 19             	cmp    $0x19,%bl
  801a10:	77 16                	ja     801a28 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a12:	0f be d2             	movsbl %dl,%edx
  801a15:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a18:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a1b:	7d 0b                	jge    801a28 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a1d:	83 c1 01             	add    $0x1,%ecx
  801a20:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a24:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a26:	eb b9                	jmp    8019e1 <strtol+0x76>

	if (endptr)
  801a28:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a2c:	74 0d                	je     801a3b <strtol+0xd0>
		*endptr = (char *) s;
  801a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a31:	89 0e                	mov    %ecx,(%esi)
  801a33:	eb 06                	jmp    801a3b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a35:	85 db                	test   %ebx,%ebx
  801a37:	74 98                	je     8019d1 <strtol+0x66>
  801a39:	eb 9e                	jmp    8019d9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a3b:	89 c2                	mov    %eax,%edx
  801a3d:	f7 da                	neg    %edx
  801a3f:	85 ff                	test   %edi,%edi
  801a41:	0f 45 c2             	cmovne %edx,%eax
}
  801a44:	5b                   	pop    %ebx
  801a45:	5e                   	pop    %esi
  801a46:	5f                   	pop    %edi
  801a47:	5d                   	pop    %ebp
  801a48:	c3                   	ret    

00801a49 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a49:	55                   	push   %ebp
  801a4a:	89 e5                	mov    %esp,%ebp
  801a4c:	56                   	push   %esi
  801a4d:	53                   	push   %ebx
  801a4e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a57:	85 c0                	test   %eax,%eax
  801a59:	75 12                	jne    801a6d <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	68 00 00 c0 ee       	push   $0xeec00000
  801a63:	e8 11 e9 ff ff       	call   800379 <sys_ipc_recv>
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	eb 0c                	jmp    801a79 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	50                   	push   %eax
  801a71:	e8 03 e9 ff ff       	call   800379 <sys_ipc_recv>
  801a76:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a79:	85 f6                	test   %esi,%esi
  801a7b:	0f 95 c1             	setne  %cl
  801a7e:	85 db                	test   %ebx,%ebx
  801a80:	0f 95 c2             	setne  %dl
  801a83:	84 d1                	test   %dl,%cl
  801a85:	74 09                	je     801a90 <ipc_recv+0x47>
  801a87:	89 c2                	mov    %eax,%edx
  801a89:	c1 ea 1f             	shr    $0x1f,%edx
  801a8c:	84 d2                	test   %dl,%dl
  801a8e:	75 24                	jne    801ab4 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a90:	85 f6                	test   %esi,%esi
  801a92:	74 0a                	je     801a9e <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801a94:	a1 04 40 80 00       	mov    0x804004,%eax
  801a99:	8b 40 74             	mov    0x74(%eax),%eax
  801a9c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801a9e:	85 db                	test   %ebx,%ebx
  801aa0:	74 0a                	je     801aac <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801aa2:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa7:	8b 40 78             	mov    0x78(%eax),%eax
  801aaa:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801aac:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab1:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab7:	5b                   	pop    %ebx
  801ab8:	5e                   	pop    %esi
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	57                   	push   %edi
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801acd:	85 db                	test   %ebx,%ebx
  801acf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ad4:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ad7:	ff 75 14             	pushl  0x14(%ebp)
  801ada:	53                   	push   %ebx
  801adb:	56                   	push   %esi
  801adc:	57                   	push   %edi
  801add:	e8 74 e8 ff ff       	call   800356 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ae2:	89 c2                	mov    %eax,%edx
  801ae4:	c1 ea 1f             	shr    $0x1f,%edx
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	84 d2                	test   %dl,%dl
  801aec:	74 17                	je     801b05 <ipc_send+0x4a>
  801aee:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af1:	74 12                	je     801b05 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801af3:	50                   	push   %eax
  801af4:	68 80 22 80 00       	push   $0x802280
  801af9:	6a 47                	push   $0x47
  801afb:	68 8e 22 80 00       	push   $0x80228e
  801b00:	e8 9f f5 ff ff       	call   8010a4 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801b05:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b08:	75 07                	jne    801b11 <ipc_send+0x56>
			sys_yield();
  801b0a:	e8 9b e6 ff ff       	call   8001aa <sys_yield>
  801b0f:	eb c6                	jmp    801ad7 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801b11:	85 c0                	test   %eax,%eax
  801b13:	75 c2                	jne    801ad7 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801b15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b18:	5b                   	pop    %ebx
  801b19:	5e                   	pop    %esi
  801b1a:	5f                   	pop    %edi
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b28:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b2b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b31:	8b 52 50             	mov    0x50(%edx),%edx
  801b34:	39 ca                	cmp    %ecx,%edx
  801b36:	75 0d                	jne    801b45 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b38:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b3b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b40:	8b 40 48             	mov    0x48(%eax),%eax
  801b43:	eb 0f                	jmp    801b54 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b45:	83 c0 01             	add    $0x1,%eax
  801b48:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4d:	75 d9                	jne    801b28 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5c:	89 d0                	mov    %edx,%eax
  801b5e:	c1 e8 16             	shr    $0x16,%eax
  801b61:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b68:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6d:	f6 c1 01             	test   $0x1,%cl
  801b70:	74 1d                	je     801b8f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b72:	c1 ea 0c             	shr    $0xc,%edx
  801b75:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b7c:	f6 c2 01             	test   $0x1,%dl
  801b7f:	74 0e                	je     801b8f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b81:	c1 ea 0c             	shr    $0xc,%edx
  801b84:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b8b:	ef 
  801b8c:	0f b7 c0             	movzwl %ax,%eax
}
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    
  801b91:	66 90                	xchg   %ax,%ax
  801b93:	66 90                	xchg   %ax,%ax
  801b95:	66 90                	xchg   %ax,%ax
  801b97:	66 90                	xchg   %ax,%ax
  801b99:	66 90                	xchg   %ax,%ax
  801b9b:	66 90                	xchg   %ax,%ax
  801b9d:	66 90                	xchg   %ax,%ax
  801b9f:	90                   	nop

00801ba0 <__udivdi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
  801ba7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801baf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bb7:	85 f6                	test   %esi,%esi
  801bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbd:	89 ca                	mov    %ecx,%edx
  801bbf:	89 f8                	mov    %edi,%eax
  801bc1:	75 3d                	jne    801c00 <__udivdi3+0x60>
  801bc3:	39 cf                	cmp    %ecx,%edi
  801bc5:	0f 87 c5 00 00 00    	ja     801c90 <__udivdi3+0xf0>
  801bcb:	85 ff                	test   %edi,%edi
  801bcd:	89 fd                	mov    %edi,%ebp
  801bcf:	75 0b                	jne    801bdc <__udivdi3+0x3c>
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	31 d2                	xor    %edx,%edx
  801bd8:	f7 f7                	div    %edi
  801bda:	89 c5                	mov    %eax,%ebp
  801bdc:	89 c8                	mov    %ecx,%eax
  801bde:	31 d2                	xor    %edx,%edx
  801be0:	f7 f5                	div    %ebp
  801be2:	89 c1                	mov    %eax,%ecx
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	89 cf                	mov    %ecx,%edi
  801be8:	f7 f5                	div    %ebp
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	89 fa                	mov    %edi,%edx
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
  801bf8:	90                   	nop
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	39 ce                	cmp    %ecx,%esi
  801c02:	77 74                	ja     801c78 <__udivdi3+0xd8>
  801c04:	0f bd fe             	bsr    %esi,%edi
  801c07:	83 f7 1f             	xor    $0x1f,%edi
  801c0a:	0f 84 98 00 00 00    	je     801ca8 <__udivdi3+0x108>
  801c10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	89 c5                	mov    %eax,%ebp
  801c19:	29 fb                	sub    %edi,%ebx
  801c1b:	d3 e6                	shl    %cl,%esi
  801c1d:	89 d9                	mov    %ebx,%ecx
  801c1f:	d3 ed                	shr    %cl,%ebp
  801c21:	89 f9                	mov    %edi,%ecx
  801c23:	d3 e0                	shl    %cl,%eax
  801c25:	09 ee                	or     %ebp,%esi
  801c27:	89 d9                	mov    %ebx,%ecx
  801c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c2d:	89 d5                	mov    %edx,%ebp
  801c2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c33:	d3 ed                	shr    %cl,%ebp
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e2                	shl    %cl,%edx
  801c39:	89 d9                	mov    %ebx,%ecx
  801c3b:	d3 e8                	shr    %cl,%eax
  801c3d:	09 c2                	or     %eax,%edx
  801c3f:	89 d0                	mov    %edx,%eax
  801c41:	89 ea                	mov    %ebp,%edx
  801c43:	f7 f6                	div    %esi
  801c45:	89 d5                	mov    %edx,%ebp
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	f7 64 24 0c          	mull   0xc(%esp)
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	72 10                	jb     801c61 <__udivdi3+0xc1>
  801c51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e6                	shl    %cl,%esi
  801c59:	39 c6                	cmp    %eax,%esi
  801c5b:	73 07                	jae    801c64 <__udivdi3+0xc4>
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	75 03                	jne    801c64 <__udivdi3+0xc4>
  801c61:	83 eb 01             	sub    $0x1,%ebx
  801c64:	31 ff                	xor    %edi,%edi
  801c66:	89 d8                	mov    %ebx,%eax
  801c68:	89 fa                	mov    %edi,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	31 ff                	xor    %edi,%edi
  801c7a:	31 db                	xor    %ebx,%ebx
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	89 fa                	mov    %edi,%edx
  801c80:	83 c4 1c             	add    $0x1c,%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
  801c88:	90                   	nop
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	f7 f7                	div    %edi
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	89 d8                	mov    %ebx,%eax
  801c9a:	89 fa                	mov    %edi,%edx
  801c9c:	83 c4 1c             	add    $0x1c,%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5f                   	pop    %edi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    
  801ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca8:	39 ce                	cmp    %ecx,%esi
  801caa:	72 0c                	jb     801cb8 <__udivdi3+0x118>
  801cac:	31 db                	xor    %ebx,%ebx
  801cae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cb2:	0f 87 34 ff ff ff    	ja     801bec <__udivdi3+0x4c>
  801cb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cbd:	e9 2a ff ff ff       	jmp    801bec <__udivdi3+0x4c>
  801cc2:	66 90                	xchg   %ax,%ax
  801cc4:	66 90                	xchg   %ax,%ax
  801cc6:	66 90                	xchg   %ax,%ax
  801cc8:	66 90                	xchg   %ax,%ax
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	66 90                	xchg   %ax,%ax
  801cce:	66 90                	xchg   %ax,%ax

00801cd0 <__umoddi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
  801cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce7:	85 d2                	test   %edx,%edx
  801ce9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cf1:	89 f3                	mov    %esi,%ebx
  801cf3:	89 3c 24             	mov    %edi,(%esp)
  801cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cfa:	75 1c                	jne    801d18 <__umoddi3+0x48>
  801cfc:	39 f7                	cmp    %esi,%edi
  801cfe:	76 50                	jbe    801d50 <__umoddi3+0x80>
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	f7 f7                	div    %edi
  801d06:	89 d0                	mov    %edx,%eax
  801d08:	31 d2                	xor    %edx,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	39 f2                	cmp    %esi,%edx
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	77 52                	ja     801d70 <__umoddi3+0xa0>
  801d1e:	0f bd ea             	bsr    %edx,%ebp
  801d21:	83 f5 1f             	xor    $0x1f,%ebp
  801d24:	75 5a                	jne    801d80 <__umoddi3+0xb0>
  801d26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d2a:	0f 82 e0 00 00 00    	jb     801e10 <__umoddi3+0x140>
  801d30:	39 0c 24             	cmp    %ecx,(%esp)
  801d33:	0f 86 d7 00 00 00    	jbe    801e10 <__umoddi3+0x140>
  801d39:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d41:	83 c4 1c             	add    $0x1c,%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	85 ff                	test   %edi,%edi
  801d52:	89 fd                	mov    %edi,%ebp
  801d54:	75 0b                	jne    801d61 <__umoddi3+0x91>
  801d56:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	f7 f7                	div    %edi
  801d5f:	89 c5                	mov    %eax,%ebp
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f5                	div    %ebp
  801d67:	89 c8                	mov    %ecx,%eax
  801d69:	f7 f5                	div    %ebp
  801d6b:	89 d0                	mov    %edx,%eax
  801d6d:	eb 99                	jmp    801d08 <__umoddi3+0x38>
  801d6f:	90                   	nop
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	83 c4 1c             	add    $0x1c,%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5e                   	pop    %esi
  801d79:	5f                   	pop    %edi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    
  801d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d80:	8b 34 24             	mov    (%esp),%esi
  801d83:	bf 20 00 00 00       	mov    $0x20,%edi
  801d88:	89 e9                	mov    %ebp,%ecx
  801d8a:	29 ef                	sub    %ebp,%edi
  801d8c:	d3 e0                	shl    %cl,%eax
  801d8e:	89 f9                	mov    %edi,%ecx
  801d90:	89 f2                	mov    %esi,%edx
  801d92:	d3 ea                	shr    %cl,%edx
  801d94:	89 e9                	mov    %ebp,%ecx
  801d96:	09 c2                	or     %eax,%edx
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	89 14 24             	mov    %edx,(%esp)
  801d9d:	89 f2                	mov    %esi,%edx
  801d9f:	d3 e2                	shl    %cl,%edx
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801da7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dab:	d3 e8                	shr    %cl,%eax
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	89 c6                	mov    %eax,%esi
  801db1:	d3 e3                	shl    %cl,%ebx
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 d0                	mov    %edx,%eax
  801db7:	d3 e8                	shr    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	09 d8                	or     %ebx,%eax
  801dbd:	89 d3                	mov    %edx,%ebx
  801dbf:	89 f2                	mov    %esi,%edx
  801dc1:	f7 34 24             	divl   (%esp)
  801dc4:	89 d6                	mov    %edx,%esi
  801dc6:	d3 e3                	shl    %cl,%ebx
  801dc8:	f7 64 24 04          	mull   0x4(%esp)
  801dcc:	39 d6                	cmp    %edx,%esi
  801dce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd2:	89 d1                	mov    %edx,%ecx
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	72 08                	jb     801de0 <__umoddi3+0x110>
  801dd8:	75 11                	jne    801deb <__umoddi3+0x11b>
  801dda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dde:	73 0b                	jae    801deb <__umoddi3+0x11b>
  801de0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801de4:	1b 14 24             	sbb    (%esp),%edx
  801de7:	89 d1                	mov    %edx,%ecx
  801de9:	89 c3                	mov    %eax,%ebx
  801deb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801def:	29 da                	sub    %ebx,%edx
  801df1:	19 ce                	sbb    %ecx,%esi
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	d3 e0                	shl    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	d3 ea                	shr    %cl,%edx
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	d3 ee                	shr    %cl,%esi
  801e01:	09 d0                	or     %edx,%eax
  801e03:	89 f2                	mov    %esi,%edx
  801e05:	83 c4 1c             	add    $0x1c,%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	29 f9                	sub    %edi,%ecx
  801e12:	19 d6                	sbb    %edx,%esi
  801e14:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e1c:	e9 18 ff ff ff       	jmp    801d39 <__umoddi3+0x69>
