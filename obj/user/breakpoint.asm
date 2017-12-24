
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800042:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800049:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  80004c:	e8 0e 01 00 00       	call   80015f <sys_getenvid>
  800051:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800057:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80005c:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  800061:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  800066:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800069:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80006f:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  800072:	39 c8                	cmp    %ecx,%eax
  800074:	0f 44 fb             	cmove  %ebx,%edi
  800077:	b9 01 00 00 00       	mov    $0x1,%ecx
  80007c:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  80007f:	83 c2 01             	add    $0x1,%edx
  800082:	83 c3 7c             	add    $0x7c,%ebx
  800085:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80008b:	75 d9                	jne    800066 <libmain+0x2d>
  80008d:	89 f0                	mov    %esi,%eax
  80008f:	84 c0                	test   %al,%al
  800091:	74 06                	je     800099 <libmain+0x60>
  800093:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80009d:	7e 0a                	jle    8000a9 <libmain+0x70>
		binaryname = argv[0];
  80009f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a2:	8b 00                	mov    (%eax),%eax
  8000a4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a9:	83 ec 08             	sub    $0x8,%esp
  8000ac:	ff 75 0c             	pushl  0xc(%ebp)
  8000af:	ff 75 08             	pushl  0x8(%ebp)
  8000b2:	e8 7c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0b 00 00 00       	call   8000c7 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cd:	e8 87 04 00 00       	call   800559 <close_all>
	sys_env_destroy(0);
  8000d2:	83 ec 0c             	sub    $0xc,%esp
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 42 00 00 00       	call   80011e <sys_env_destroy>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f2:	89 c3                	mov    %eax,%ebx
  8000f4:	89 c7                	mov    %eax,%edi
  8000f6:	89 c6                	mov    %eax,%esi
  8000f8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800105:	ba 00 00 00 00       	mov    $0x0,%edx
  80010a:	b8 01 00 00 00       	mov    $0x1,%eax
  80010f:	89 d1                	mov    %edx,%ecx
  800111:	89 d3                	mov    %edx,%ebx
  800113:	89 d7                	mov    %edx,%edi
  800115:	89 d6                	mov    %edx,%esi
  800117:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    

0080011e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	57                   	push   %edi
  800122:	56                   	push   %esi
  800123:	53                   	push   %ebx
  800124:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800127:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012c:	b8 03 00 00 00       	mov    $0x3,%eax
  800131:	8b 55 08             	mov    0x8(%ebp),%edx
  800134:	89 cb                	mov    %ecx,%ebx
  800136:	89 cf                	mov    %ecx,%edi
  800138:	89 ce                	mov    %ecx,%esi
  80013a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80013c:	85 c0                	test   %eax,%eax
  80013e:	7e 17                	jle    800157 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	50                   	push   %eax
  800144:	6a 03                	push   $0x3
  800146:	68 0a 1e 80 00       	push   $0x801e0a
  80014b:	6a 23                	push   $0x23
  80014d:	68 27 1e 80 00       	push   $0x801e27
  800152:	e8 21 0f 00 00       	call   801078 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800157:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800165:	ba 00 00 00 00       	mov    $0x0,%edx
  80016a:	b8 02 00 00 00       	mov    $0x2,%eax
  80016f:	89 d1                	mov    %edx,%ecx
  800171:	89 d3                	mov    %edx,%ebx
  800173:	89 d7                	mov    %edx,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <sys_yield>:

void
sys_yield(void)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800184:	ba 00 00 00 00       	mov    $0x0,%edx
  800189:	b8 0b 00 00 00       	mov    $0xb,%eax
  80018e:	89 d1                	mov    %edx,%ecx
  800190:	89 d3                	mov    %edx,%ebx
  800192:	89 d7                	mov    %edx,%edi
  800194:	89 d6                	mov    %edx,%esi
  800196:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	be 00 00 00 00       	mov    $0x0,%esi
  8001ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b9:	89 f7                	mov    %esi,%edi
  8001bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7e 17                	jle    8001d8 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c1:	83 ec 0c             	sub    $0xc,%esp
  8001c4:	50                   	push   %eax
  8001c5:	6a 04                	push   $0x4
  8001c7:	68 0a 1e 80 00       	push   $0x801e0a
  8001cc:	6a 23                	push   $0x23
  8001ce:	68 27 1e 80 00       	push   $0x801e27
  8001d3:	e8 a0 0e 00 00       	call   801078 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e9:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001fa:	8b 75 18             	mov    0x18(%ebp),%esi
  8001fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ff:	85 c0                	test   %eax,%eax
  800201:	7e 17                	jle    80021a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	50                   	push   %eax
  800207:	6a 05                	push   $0x5
  800209:	68 0a 1e 80 00       	push   $0x801e0a
  80020e:	6a 23                	push   $0x23
  800210:	68 27 1e 80 00       	push   $0x801e27
  800215:	e8 5e 0e 00 00       	call   801078 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	57                   	push   %edi
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
  800228:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	b8 06 00 00 00       	mov    $0x6,%eax
  800235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	89 df                	mov    %ebx,%edi
  80023d:	89 de                	mov    %ebx,%esi
  80023f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	7e 17                	jle    80025c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	50                   	push   %eax
  800249:	6a 06                	push   $0x6
  80024b:	68 0a 1e 80 00       	push   $0x801e0a
  800250:	6a 23                	push   $0x23
  800252:	68 27 1e 80 00       	push   $0x801e27
  800257:	e8 1c 0e 00 00       	call   801078 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800272:	b8 08 00 00 00       	mov    $0x8,%eax
  800277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	89 df                	mov    %ebx,%edi
  80027f:	89 de                	mov    %ebx,%esi
  800281:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800283:	85 c0                	test   %eax,%eax
  800285:	7e 17                	jle    80029e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	50                   	push   %eax
  80028b:	6a 08                	push   $0x8
  80028d:	68 0a 1e 80 00       	push   $0x801e0a
  800292:	6a 23                	push   $0x23
  800294:	68 27 1e 80 00       	push   $0x801e27
  800299:	e8 da 0d 00 00       	call   801078 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80029e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
  8002ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	89 df                	mov    %ebx,%edi
  8002c1:	89 de                	mov    %ebx,%esi
  8002c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c5:	85 c0                	test   %eax,%eax
  8002c7:	7e 17                	jle    8002e0 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c9:	83 ec 0c             	sub    $0xc,%esp
  8002cc:	50                   	push   %eax
  8002cd:	6a 09                	push   $0x9
  8002cf:	68 0a 1e 80 00       	push   $0x801e0a
  8002d4:	6a 23                	push   $0x23
  8002d6:	68 27 1e 80 00       	push   $0x801e27
  8002db:	e8 98 0d 00 00       	call   801078 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e3:	5b                   	pop    %ebx
  8002e4:	5e                   	pop    %esi
  8002e5:	5f                   	pop    %edi
  8002e6:	5d                   	pop    %ebp
  8002e7:	c3                   	ret    

008002e8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	57                   	push   %edi
  8002ec:	56                   	push   %esi
  8002ed:	53                   	push   %ebx
  8002ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	89 df                	mov    %ebx,%edi
  800303:	89 de                	mov    %ebx,%esi
  800305:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800307:	85 c0                	test   %eax,%eax
  800309:	7e 17                	jle    800322 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80030b:	83 ec 0c             	sub    $0xc,%esp
  80030e:	50                   	push   %eax
  80030f:	6a 0a                	push   $0xa
  800311:	68 0a 1e 80 00       	push   $0x801e0a
  800316:	6a 23                	push   $0x23
  800318:	68 27 1e 80 00       	push   $0x801e27
  80031d:	e8 56 0d 00 00       	call   801078 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800322:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	57                   	push   %edi
  80032e:	56                   	push   %esi
  80032f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800330:	be 00 00 00 00       	mov    $0x0,%esi
  800335:	b8 0c 00 00 00       	mov    $0xc,%eax
  80033a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033d:	8b 55 08             	mov    0x8(%ebp),%edx
  800340:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800343:	8b 7d 14             	mov    0x14(%ebp),%edi
  800346:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800348:	5b                   	pop    %ebx
  800349:	5e                   	pop    %esi
  80034a:	5f                   	pop    %edi
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	57                   	push   %edi
  800351:	56                   	push   %esi
  800352:	53                   	push   %ebx
  800353:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800356:	b9 00 00 00 00       	mov    $0x0,%ecx
  80035b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800360:	8b 55 08             	mov    0x8(%ebp),%edx
  800363:	89 cb                	mov    %ecx,%ebx
  800365:	89 cf                	mov    %ecx,%edi
  800367:	89 ce                	mov    %ecx,%esi
  800369:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80036b:	85 c0                	test   %eax,%eax
  80036d:	7e 17                	jle    800386 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036f:	83 ec 0c             	sub    $0xc,%esp
  800372:	50                   	push   %eax
  800373:	6a 0d                	push   $0xd
  800375:	68 0a 1e 80 00       	push   $0x801e0a
  80037a:	6a 23                	push   $0x23
  80037c:	68 27 1e 80 00       	push   $0x801e27
  800381:	e8 f2 0c 00 00       	call   801078 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	05 00 00 00 30       	add    $0x30000000,%eax
  800399:	c1 e8 0c             	shr    $0xc,%eax
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003ae:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c0:	89 c2                	mov    %eax,%edx
  8003c2:	c1 ea 16             	shr    $0x16,%edx
  8003c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003cc:	f6 c2 01             	test   $0x1,%dl
  8003cf:	74 11                	je     8003e2 <fd_alloc+0x2d>
  8003d1:	89 c2                	mov    %eax,%edx
  8003d3:	c1 ea 0c             	shr    $0xc,%edx
  8003d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003dd:	f6 c2 01             	test   $0x1,%dl
  8003e0:	75 09                	jne    8003eb <fd_alloc+0x36>
			*fd_store = fd;
  8003e2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e9:	eb 17                	jmp    800402 <fd_alloc+0x4d>
  8003eb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f5:	75 c9                	jne    8003c0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003fd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040a:	83 f8 1f             	cmp    $0x1f,%eax
  80040d:	77 36                	ja     800445 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80040f:	c1 e0 0c             	shl    $0xc,%eax
  800412:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 16             	shr    $0x16,%edx
  80041c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800423:	f6 c2 01             	test   $0x1,%dl
  800426:	74 24                	je     80044c <fd_lookup+0x48>
  800428:	89 c2                	mov    %eax,%edx
  80042a:	c1 ea 0c             	shr    $0xc,%edx
  80042d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800434:	f6 c2 01             	test   $0x1,%dl
  800437:	74 1a                	je     800453 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800439:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043c:	89 02                	mov    %eax,(%edx)
	return 0;
  80043e:	b8 00 00 00 00       	mov    $0x0,%eax
  800443:	eb 13                	jmp    800458 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044a:	eb 0c                	jmp    800458 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800451:	eb 05                	jmp    800458 <fd_lookup+0x54>
  800453:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800458:	5d                   	pop    %ebp
  800459:	c3                   	ret    

0080045a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800463:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800468:	eb 13                	jmp    80047d <dev_lookup+0x23>
  80046a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80046d:	39 08                	cmp    %ecx,(%eax)
  80046f:	75 0c                	jne    80047d <dev_lookup+0x23>
			*dev = devtab[i];
  800471:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800474:	89 01                	mov    %eax,(%ecx)
			return 0;
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	eb 2e                	jmp    8004ab <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80047d:	8b 02                	mov    (%edx),%eax
  80047f:	85 c0                	test   %eax,%eax
  800481:	75 e7                	jne    80046a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800483:	a1 04 40 80 00       	mov    0x804004,%eax
  800488:	8b 40 48             	mov    0x48(%eax),%eax
  80048b:	83 ec 04             	sub    $0x4,%esp
  80048e:	51                   	push   %ecx
  80048f:	50                   	push   %eax
  800490:	68 38 1e 80 00       	push   $0x801e38
  800495:	e8 b7 0c 00 00       	call   801151 <cprintf>
	*dev = 0;
  80049a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ab:	c9                   	leave  
  8004ac:	c3                   	ret    

008004ad <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 10             	sub    $0x10,%esp
  8004b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004be:	50                   	push   %eax
  8004bf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c5:	c1 e8 0c             	shr    $0xc,%eax
  8004c8:	50                   	push   %eax
  8004c9:	e8 36 ff ff ff       	call   800404 <fd_lookup>
  8004ce:	83 c4 08             	add    $0x8,%esp
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	78 05                	js     8004da <fd_close+0x2d>
	    || fd != fd2)
  8004d5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004d8:	74 0c                	je     8004e6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004da:	84 db                	test   %bl,%bl
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e1:	0f 44 c2             	cmove  %edx,%eax
  8004e4:	eb 41                	jmp    800527 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ec:	50                   	push   %eax
  8004ed:	ff 36                	pushl  (%esi)
  8004ef:	e8 66 ff ff ff       	call   80045a <dev_lookup>
  8004f4:	89 c3                	mov    %eax,%ebx
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	85 c0                	test   %eax,%eax
  8004fb:	78 1a                	js     800517 <fd_close+0x6a>
		if (dev->dev_close)
  8004fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800500:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800503:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800508:	85 c0                	test   %eax,%eax
  80050a:	74 0b                	je     800517 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80050c:	83 ec 0c             	sub    $0xc,%esp
  80050f:	56                   	push   %esi
  800510:	ff d0                	call   *%eax
  800512:	89 c3                	mov    %eax,%ebx
  800514:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	56                   	push   %esi
  80051b:	6a 00                	push   $0x0
  80051d:	e8 00 fd ff ff       	call   800222 <sys_page_unmap>
	return r;
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	89 d8                	mov    %ebx,%eax
}
  800527:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052a:	5b                   	pop    %ebx
  80052b:	5e                   	pop    %esi
  80052c:	5d                   	pop    %ebp
  80052d:	c3                   	ret    

0080052e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800534:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800537:	50                   	push   %eax
  800538:	ff 75 08             	pushl  0x8(%ebp)
  80053b:	e8 c4 fe ff ff       	call   800404 <fd_lookup>
  800540:	83 c4 08             	add    $0x8,%esp
  800543:	85 c0                	test   %eax,%eax
  800545:	78 10                	js     800557 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	6a 01                	push   $0x1
  80054c:	ff 75 f4             	pushl  -0xc(%ebp)
  80054f:	e8 59 ff ff ff       	call   8004ad <fd_close>
  800554:	83 c4 10             	add    $0x10,%esp
}
  800557:	c9                   	leave  
  800558:	c3                   	ret    

00800559 <close_all>:

void
close_all(void)
{
  800559:	55                   	push   %ebp
  80055a:	89 e5                	mov    %esp,%ebp
  80055c:	53                   	push   %ebx
  80055d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800560:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800565:	83 ec 0c             	sub    $0xc,%esp
  800568:	53                   	push   %ebx
  800569:	e8 c0 ff ff ff       	call   80052e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80056e:	83 c3 01             	add    $0x1,%ebx
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	83 fb 20             	cmp    $0x20,%ebx
  800577:	75 ec                	jne    800565 <close_all+0xc>
		close(i);
}
  800579:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057c:	c9                   	leave  
  80057d:	c3                   	ret    

0080057e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  800581:	57                   	push   %edi
  800582:	56                   	push   %esi
  800583:	53                   	push   %ebx
  800584:	83 ec 2c             	sub    $0x2c,%esp
  800587:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80058d:	50                   	push   %eax
  80058e:	ff 75 08             	pushl  0x8(%ebp)
  800591:	e8 6e fe ff ff       	call   800404 <fd_lookup>
  800596:	83 c4 08             	add    $0x8,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	0f 88 c1 00 00 00    	js     800662 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a1:	83 ec 0c             	sub    $0xc,%esp
  8005a4:	56                   	push   %esi
  8005a5:	e8 84 ff ff ff       	call   80052e <close>

	newfd = INDEX2FD(newfdnum);
  8005aa:	89 f3                	mov    %esi,%ebx
  8005ac:	c1 e3 0c             	shl    $0xc,%ebx
  8005af:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b5:	83 c4 04             	add    $0x4,%esp
  8005b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005bb:	e8 de fd ff ff       	call   80039e <fd2data>
  8005c0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c2:	89 1c 24             	mov    %ebx,(%esp)
  8005c5:	e8 d4 fd ff ff       	call   80039e <fd2data>
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d0:	89 f8                	mov    %edi,%eax
  8005d2:	c1 e8 16             	shr    $0x16,%eax
  8005d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005dc:	a8 01                	test   $0x1,%al
  8005de:	74 37                	je     800617 <dup+0x99>
  8005e0:	89 f8                	mov    %edi,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ec:	f6 c2 01             	test   $0x1,%dl
  8005ef:	74 26                	je     800617 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f8:	83 ec 0c             	sub    $0xc,%esp
  8005fb:	25 07 0e 00 00       	and    $0xe07,%eax
  800600:	50                   	push   %eax
  800601:	ff 75 d4             	pushl  -0x2c(%ebp)
  800604:	6a 00                	push   $0x0
  800606:	57                   	push   %edi
  800607:	6a 00                	push   $0x0
  800609:	e8 d2 fb ff ff       	call   8001e0 <sys_page_map>
  80060e:	89 c7                	mov    %eax,%edi
  800610:	83 c4 20             	add    $0x20,%esp
  800613:	85 c0                	test   %eax,%eax
  800615:	78 2e                	js     800645 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800617:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061a:	89 d0                	mov    %edx,%eax
  80061c:	c1 e8 0c             	shr    $0xc,%eax
  80061f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	25 07 0e 00 00       	and    $0xe07,%eax
  80062e:	50                   	push   %eax
  80062f:	53                   	push   %ebx
  800630:	6a 00                	push   $0x0
  800632:	52                   	push   %edx
  800633:	6a 00                	push   $0x0
  800635:	e8 a6 fb ff ff       	call   8001e0 <sys_page_map>
  80063a:	89 c7                	mov    %eax,%edi
  80063c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80063f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800641:	85 ff                	test   %edi,%edi
  800643:	79 1d                	jns    800662 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 00                	push   $0x0
  80064b:	e8 d2 fb ff ff       	call   800222 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800650:	83 c4 08             	add    $0x8,%esp
  800653:	ff 75 d4             	pushl  -0x2c(%ebp)
  800656:	6a 00                	push   $0x0
  800658:	e8 c5 fb ff ff       	call   800222 <sys_page_unmap>
	return r;
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	89 f8                	mov    %edi,%eax
}
  800662:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800665:	5b                   	pop    %ebx
  800666:	5e                   	pop    %esi
  800667:	5f                   	pop    %edi
  800668:	5d                   	pop    %ebp
  800669:	c3                   	ret    

0080066a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066a:	55                   	push   %ebp
  80066b:	89 e5                	mov    %esp,%ebp
  80066d:	53                   	push   %ebx
  80066e:	83 ec 14             	sub    $0x14,%esp
  800671:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800674:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800677:	50                   	push   %eax
  800678:	53                   	push   %ebx
  800679:	e8 86 fd ff ff       	call   800404 <fd_lookup>
  80067e:	83 c4 08             	add    $0x8,%esp
  800681:	89 c2                	mov    %eax,%edx
  800683:	85 c0                	test   %eax,%eax
  800685:	78 6d                	js     8006f4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80068d:	50                   	push   %eax
  80068e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800691:	ff 30                	pushl  (%eax)
  800693:	e8 c2 fd ff ff       	call   80045a <dev_lookup>
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	85 c0                	test   %eax,%eax
  80069d:	78 4c                	js     8006eb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80069f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a2:	8b 42 08             	mov    0x8(%edx),%eax
  8006a5:	83 e0 03             	and    $0x3,%eax
  8006a8:	83 f8 01             	cmp    $0x1,%eax
  8006ab:	75 21                	jne    8006ce <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ad:	a1 04 40 80 00       	mov    0x804004,%eax
  8006b2:	8b 40 48             	mov    0x48(%eax),%eax
  8006b5:	83 ec 04             	sub    $0x4,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	50                   	push   %eax
  8006ba:	68 79 1e 80 00       	push   $0x801e79
  8006bf:	e8 8d 0a 00 00       	call   801151 <cprintf>
		return -E_INVAL;
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006cc:	eb 26                	jmp    8006f4 <read+0x8a>
	}
	if (!dev->dev_read)
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	8b 40 08             	mov    0x8(%eax),%eax
  8006d4:	85 c0                	test   %eax,%eax
  8006d6:	74 17                	je     8006ef <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8006d8:	83 ec 04             	sub    $0x4,%esp
  8006db:	ff 75 10             	pushl  0x10(%ebp)
  8006de:	ff 75 0c             	pushl  0xc(%ebp)
  8006e1:	52                   	push   %edx
  8006e2:	ff d0                	call   *%eax
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb 09                	jmp    8006f4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006eb:	89 c2                	mov    %eax,%edx
  8006ed:	eb 05                	jmp    8006f4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8006f4:	89 d0                	mov    %edx,%eax
  8006f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f9:	c9                   	leave  
  8006fa:	c3                   	ret    

008006fb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	57                   	push   %edi
  8006ff:	56                   	push   %esi
  800700:	53                   	push   %ebx
  800701:	83 ec 0c             	sub    $0xc,%esp
  800704:	8b 7d 08             	mov    0x8(%ebp),%edi
  800707:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80070f:	eb 21                	jmp    800732 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800711:	83 ec 04             	sub    $0x4,%esp
  800714:	89 f0                	mov    %esi,%eax
  800716:	29 d8                	sub    %ebx,%eax
  800718:	50                   	push   %eax
  800719:	89 d8                	mov    %ebx,%eax
  80071b:	03 45 0c             	add    0xc(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	57                   	push   %edi
  800720:	e8 45 ff ff ff       	call   80066a <read>
		if (m < 0)
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	85 c0                	test   %eax,%eax
  80072a:	78 10                	js     80073c <readn+0x41>
			return m;
		if (m == 0)
  80072c:	85 c0                	test   %eax,%eax
  80072e:	74 0a                	je     80073a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800730:	01 c3                	add    %eax,%ebx
  800732:	39 f3                	cmp    %esi,%ebx
  800734:	72 db                	jb     800711 <readn+0x16>
  800736:	89 d8                	mov    %ebx,%eax
  800738:	eb 02                	jmp    80073c <readn+0x41>
  80073a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80073c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073f:	5b                   	pop    %ebx
  800740:	5e                   	pop    %esi
  800741:	5f                   	pop    %edi
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	53                   	push   %ebx
  800748:	83 ec 14             	sub    $0x14,%esp
  80074b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80074e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800751:	50                   	push   %eax
  800752:	53                   	push   %ebx
  800753:	e8 ac fc ff ff       	call   800404 <fd_lookup>
  800758:	83 c4 08             	add    $0x8,%esp
  80075b:	89 c2                	mov    %eax,%edx
  80075d:	85 c0                	test   %eax,%eax
  80075f:	78 68                	js     8007c9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800767:	50                   	push   %eax
  800768:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076b:	ff 30                	pushl  (%eax)
  80076d:	e8 e8 fc ff ff       	call   80045a <dev_lookup>
  800772:	83 c4 10             	add    $0x10,%esp
  800775:	85 c0                	test   %eax,%eax
  800777:	78 47                	js     8007c0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800779:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800780:	75 21                	jne    8007a3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800782:	a1 04 40 80 00       	mov    0x804004,%eax
  800787:	8b 40 48             	mov    0x48(%eax),%eax
  80078a:	83 ec 04             	sub    $0x4,%esp
  80078d:	53                   	push   %ebx
  80078e:	50                   	push   %eax
  80078f:	68 95 1e 80 00       	push   $0x801e95
  800794:	e8 b8 09 00 00       	call   801151 <cprintf>
		return -E_INVAL;
  800799:	83 c4 10             	add    $0x10,%esp
  80079c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a1:	eb 26                	jmp    8007c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a6:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	74 17                	je     8007c4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ad:	83 ec 04             	sub    $0x4,%esp
  8007b0:	ff 75 10             	pushl  0x10(%ebp)
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	50                   	push   %eax
  8007b7:	ff d2                	call   *%edx
  8007b9:	89 c2                	mov    %eax,%edx
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	eb 09                	jmp    8007c9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	eb 05                	jmp    8007c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c9:	89 d0                	mov    %edx,%eax
  8007cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	ff 75 08             	pushl  0x8(%ebp)
  8007dd:	e8 22 fc ff ff       	call   800404 <fd_lookup>
  8007e2:	83 c4 08             	add    $0x8,%esp
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	78 0e                	js     8007f7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ef:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	83 ec 14             	sub    $0x14,%esp
  800800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800803:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800806:	50                   	push   %eax
  800807:	53                   	push   %ebx
  800808:	e8 f7 fb ff ff       	call   800404 <fd_lookup>
  80080d:	83 c4 08             	add    $0x8,%esp
  800810:	89 c2                	mov    %eax,%edx
  800812:	85 c0                	test   %eax,%eax
  800814:	78 65                	js     80087b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081c:	50                   	push   %eax
  80081d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800820:	ff 30                	pushl  (%eax)
  800822:	e8 33 fc ff ff       	call   80045a <dev_lookup>
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	85 c0                	test   %eax,%eax
  80082c:	78 44                	js     800872 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800831:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800835:	75 21                	jne    800858 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800837:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083c:	8b 40 48             	mov    0x48(%eax),%eax
  80083f:	83 ec 04             	sub    $0x4,%esp
  800842:	53                   	push   %ebx
  800843:	50                   	push   %eax
  800844:	68 58 1e 80 00       	push   $0x801e58
  800849:	e8 03 09 00 00       	call   801151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800856:	eb 23                	jmp    80087b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085b:	8b 52 18             	mov    0x18(%edx),%edx
  80085e:	85 d2                	test   %edx,%edx
  800860:	74 14                	je     800876 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	ff 75 0c             	pushl  0xc(%ebp)
  800868:	50                   	push   %eax
  800869:	ff d2                	call   *%edx
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	eb 09                	jmp    80087b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800872:	89 c2                	mov    %eax,%edx
  800874:	eb 05                	jmp    80087b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800876:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80087b:	89 d0                	mov    %edx,%eax
  80087d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	83 ec 14             	sub    $0x14,%esp
  800889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088f:	50                   	push   %eax
  800890:	ff 75 08             	pushl  0x8(%ebp)
  800893:	e8 6c fb ff ff       	call   800404 <fd_lookup>
  800898:	83 c4 08             	add    $0x8,%esp
  80089b:	89 c2                	mov    %eax,%edx
  80089d:	85 c0                	test   %eax,%eax
  80089f:	78 58                	js     8008f9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a7:	50                   	push   %eax
  8008a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ab:	ff 30                	pushl  (%eax)
  8008ad:	e8 a8 fb ff ff       	call   80045a <dev_lookup>
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	85 c0                	test   %eax,%eax
  8008b7:	78 37                	js     8008f0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c0:	74 32                	je     8008f4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008cc:	00 00 00 
	stat->st_isdir = 0;
  8008cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d6:	00 00 00 
	stat->st_dev = dev;
  8008d9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e6:	ff 50 14             	call   *0x14(%eax)
  8008e9:	89 c2                	mov    %eax,%edx
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	eb 09                	jmp    8008f9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f0:	89 c2                	mov    %eax,%edx
  8008f2:	eb 05                	jmp    8008f9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f9:	89 d0                	mov    %edx,%eax
  8008fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800905:	83 ec 08             	sub    $0x8,%esp
  800908:	6a 00                	push   $0x0
  80090a:	ff 75 08             	pushl  0x8(%ebp)
  80090d:	e8 e3 01 00 00       	call   800af5 <open>
  800912:	89 c3                	mov    %eax,%ebx
  800914:	83 c4 10             	add    $0x10,%esp
  800917:	85 c0                	test   %eax,%eax
  800919:	78 1b                	js     800936 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	ff 75 0c             	pushl  0xc(%ebp)
  800921:	50                   	push   %eax
  800922:	e8 5b ff ff ff       	call   800882 <fstat>
  800927:	89 c6                	mov    %eax,%esi
	close(fd);
  800929:	89 1c 24             	mov    %ebx,(%esp)
  80092c:	e8 fd fb ff ff       	call   80052e <close>
	return r;
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	89 f0                	mov    %esi,%eax
}
  800936:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	56                   	push   %esi
  800941:	53                   	push   %ebx
  800942:	89 c6                	mov    %eax,%esi
  800944:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800946:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80094d:	75 12                	jne    800961 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80094f:	83 ec 0c             	sub    $0xc,%esp
  800952:	6a 01                	push   $0x1
  800954:	e8 98 11 00 00       	call   801af1 <ipc_find_env>
  800959:	a3 00 40 80 00       	mov    %eax,0x804000
  80095e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800961:	6a 07                	push   $0x7
  800963:	68 00 50 80 00       	push   $0x805000
  800968:	56                   	push   %esi
  800969:	ff 35 00 40 80 00    	pushl  0x804000
  80096f:	e8 1b 11 00 00       	call   801a8f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800974:	83 c4 0c             	add    $0xc,%esp
  800977:	6a 00                	push   $0x0
  800979:	53                   	push   %ebx
  80097a:	6a 00                	push   $0x0
  80097c:	e8 9c 10 00 00       	call   801a1d <ipc_recv>
}
  800981:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 40 0c             	mov    0xc(%eax),%eax
  800994:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800999:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ab:	e8 8d ff ff ff       	call   80093d <fsipc>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8009be:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8009cd:	e8 6b ff ff ff       	call   80093d <fsipc>
}
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	53                   	push   %ebx
  8009d8:	83 ec 04             	sub    $0x4,%esp
  8009db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f3:	e8 45 ff ff ff       	call   80093d <fsipc>
  8009f8:	85 c0                	test   %eax,%eax
  8009fa:	78 2c                	js     800a28 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009fc:	83 ec 08             	sub    $0x8,%esp
  8009ff:	68 00 50 80 00       	push   $0x805000
  800a04:	53                   	push   %ebx
  800a05:	e8 cc 0c 00 00       	call   8016d6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0a:	a1 80 50 80 00       	mov    0x805080,%eax
  800a0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a15:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a20:	83 c4 10             	add    $0x10,%esp
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	83 ec 0c             	sub    $0xc,%esp
  800a33:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a36:	8b 55 08             	mov    0x8(%ebp),%edx
  800a39:	8b 52 0c             	mov    0xc(%edx),%edx
  800a3c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a42:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a47:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a4c:	0f 47 c2             	cmova  %edx,%eax
  800a4f:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a54:	50                   	push   %eax
  800a55:	ff 75 0c             	pushl  0xc(%ebp)
  800a58:	68 08 50 80 00       	push   $0x805008
  800a5d:	e8 06 0e 00 00       	call   801868 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a62:	ba 00 00 00 00       	mov    $0x0,%edx
  800a67:	b8 04 00 00 00       	mov    $0x4,%eax
  800a6c:	e8 cc fe ff ff       	call   80093d <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a81:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a86:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a91:	b8 03 00 00 00       	mov    $0x3,%eax
  800a96:	e8 a2 fe ff ff       	call   80093d <fsipc>
  800a9b:	89 c3                	mov    %eax,%ebx
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	78 4b                	js     800aec <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa1:	39 c6                	cmp    %eax,%esi
  800aa3:	73 16                	jae    800abb <devfile_read+0x48>
  800aa5:	68 c4 1e 80 00       	push   $0x801ec4
  800aaa:	68 cb 1e 80 00       	push   $0x801ecb
  800aaf:	6a 7c                	push   $0x7c
  800ab1:	68 e0 1e 80 00       	push   $0x801ee0
  800ab6:	e8 bd 05 00 00       	call   801078 <_panic>
	assert(r <= PGSIZE);
  800abb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac0:	7e 16                	jle    800ad8 <devfile_read+0x65>
  800ac2:	68 eb 1e 80 00       	push   $0x801eeb
  800ac7:	68 cb 1e 80 00       	push   $0x801ecb
  800acc:	6a 7d                	push   $0x7d
  800ace:	68 e0 1e 80 00       	push   $0x801ee0
  800ad3:	e8 a0 05 00 00       	call   801078 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad8:	83 ec 04             	sub    $0x4,%esp
  800adb:	50                   	push   %eax
  800adc:	68 00 50 80 00       	push   $0x805000
  800ae1:	ff 75 0c             	pushl  0xc(%ebp)
  800ae4:	e8 7f 0d 00 00       	call   801868 <memmove>
	return r;
  800ae9:	83 c4 10             	add    $0x10,%esp
}
  800aec:	89 d8                	mov    %ebx,%eax
  800aee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	53                   	push   %ebx
  800af9:	83 ec 20             	sub    $0x20,%esp
  800afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aff:	53                   	push   %ebx
  800b00:	e8 98 0b 00 00       	call   80169d <strlen>
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0d:	7f 67                	jg     800b76 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0f:	83 ec 0c             	sub    $0xc,%esp
  800b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b15:	50                   	push   %eax
  800b16:	e8 9a f8 ff ff       	call   8003b5 <fd_alloc>
  800b1b:	83 c4 10             	add    $0x10,%esp
		return r;
  800b1e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b20:	85 c0                	test   %eax,%eax
  800b22:	78 57                	js     800b7b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b24:	83 ec 08             	sub    $0x8,%esp
  800b27:	53                   	push   %ebx
  800b28:	68 00 50 80 00       	push   $0x805000
  800b2d:	e8 a4 0b 00 00       	call   8016d6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b42:	e8 f6 fd ff ff       	call   80093d <fsipc>
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	83 c4 10             	add    $0x10,%esp
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	79 14                	jns    800b64 <open+0x6f>
		fd_close(fd, 0);
  800b50:	83 ec 08             	sub    $0x8,%esp
  800b53:	6a 00                	push   $0x0
  800b55:	ff 75 f4             	pushl  -0xc(%ebp)
  800b58:	e8 50 f9 ff ff       	call   8004ad <fd_close>
		return r;
  800b5d:	83 c4 10             	add    $0x10,%esp
  800b60:	89 da                	mov    %ebx,%edx
  800b62:	eb 17                	jmp    800b7b <open+0x86>
	}

	return fd2num(fd);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6a:	e8 1f f8 ff ff       	call   80038e <fd2num>
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	eb 05                	jmp    800b7b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b76:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b7b:	89 d0                	mov    %edx,%eax
  800b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b92:	e8 a6 fd ff ff       	call   80093d <fsipc>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	ff 75 08             	pushl  0x8(%ebp)
  800ba7:	e8 f2 f7 ff ff       	call   80039e <fd2data>
  800bac:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bae:	83 c4 08             	add    $0x8,%esp
  800bb1:	68 f7 1e 80 00       	push   $0x801ef7
  800bb6:	53                   	push   %ebx
  800bb7:	e8 1a 0b 00 00       	call   8016d6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bbc:	8b 46 04             	mov    0x4(%esi),%eax
  800bbf:	2b 06                	sub    (%esi),%eax
  800bc1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bc7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bce:	00 00 00 
	stat->st_dev = &devpipe;
  800bd1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bd8:	30 80 00 
	return 0;
}
  800bdb:	b8 00 00 00 00       	mov    $0x0,%eax
  800be0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800be3:	5b                   	pop    %ebx
  800be4:	5e                   	pop    %esi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	53                   	push   %ebx
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf1:	53                   	push   %ebx
  800bf2:	6a 00                	push   $0x0
  800bf4:	e8 29 f6 ff ff       	call   800222 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bf9:	89 1c 24             	mov    %ebx,(%esp)
  800bfc:	e8 9d f7 ff ff       	call   80039e <fd2data>
  800c01:	83 c4 08             	add    $0x8,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 00                	push   $0x0
  800c07:	e8 16 f6 ff ff       	call   800222 <sys_page_unmap>
}
  800c0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 1c             	sub    $0x1c,%esp
  800c1a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c1d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c1f:	a1 04 40 80 00       	mov    0x804004,%eax
  800c24:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c27:	83 ec 0c             	sub    $0xc,%esp
  800c2a:	ff 75 e0             	pushl  -0x20(%ebp)
  800c2d:	e8 f8 0e 00 00       	call   801b2a <pageref>
  800c32:	89 c3                	mov    %eax,%ebx
  800c34:	89 3c 24             	mov    %edi,(%esp)
  800c37:	e8 ee 0e 00 00       	call   801b2a <pageref>
  800c3c:	83 c4 10             	add    $0x10,%esp
  800c3f:	39 c3                	cmp    %eax,%ebx
  800c41:	0f 94 c1             	sete   %cl
  800c44:	0f b6 c9             	movzbl %cl,%ecx
  800c47:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c4a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c50:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c53:	39 ce                	cmp    %ecx,%esi
  800c55:	74 1b                	je     800c72 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c57:	39 c3                	cmp    %eax,%ebx
  800c59:	75 c4                	jne    800c1f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c5b:	8b 42 58             	mov    0x58(%edx),%eax
  800c5e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c61:	50                   	push   %eax
  800c62:	56                   	push   %esi
  800c63:	68 fe 1e 80 00       	push   $0x801efe
  800c68:	e8 e4 04 00 00       	call   801151 <cprintf>
  800c6d:	83 c4 10             	add    $0x10,%esp
  800c70:	eb ad                	jmp    800c1f <_pipeisclosed+0xe>
	}
}
  800c72:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 28             	sub    $0x28,%esp
  800c86:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c89:	56                   	push   %esi
  800c8a:	e8 0f f7 ff ff       	call   80039e <fd2data>
  800c8f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c91:	83 c4 10             	add    $0x10,%esp
  800c94:	bf 00 00 00 00       	mov    $0x0,%edi
  800c99:	eb 4b                	jmp    800ce6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c9b:	89 da                	mov    %ebx,%edx
  800c9d:	89 f0                	mov    %esi,%eax
  800c9f:	e8 6d ff ff ff       	call   800c11 <_pipeisclosed>
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	75 48                	jne    800cf0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ca8:	e8 d1 f4 ff ff       	call   80017e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cad:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb0:	8b 0b                	mov    (%ebx),%ecx
  800cb2:	8d 51 20             	lea    0x20(%ecx),%edx
  800cb5:	39 d0                	cmp    %edx,%eax
  800cb7:	73 e2                	jae    800c9b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cc3:	89 c2                	mov    %eax,%edx
  800cc5:	c1 fa 1f             	sar    $0x1f,%edx
  800cc8:	89 d1                	mov    %edx,%ecx
  800cca:	c1 e9 1b             	shr    $0x1b,%ecx
  800ccd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd0:	83 e2 1f             	and    $0x1f,%edx
  800cd3:	29 ca                	sub    %ecx,%edx
  800cd5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cd9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cdd:	83 c0 01             	add    $0x1,%eax
  800ce0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce3:	83 c7 01             	add    $0x1,%edi
  800ce6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce9:	75 c2                	jne    800cad <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ceb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cee:	eb 05                	jmp    800cf5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    

00800cfd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cfd:	55                   	push   %ebp
  800cfe:	89 e5                	mov    %esp,%ebp
  800d00:	57                   	push   %edi
  800d01:	56                   	push   %esi
  800d02:	53                   	push   %ebx
  800d03:	83 ec 18             	sub    $0x18,%esp
  800d06:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d09:	57                   	push   %edi
  800d0a:	e8 8f f6 ff ff       	call   80039e <fd2data>
  800d0f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d11:	83 c4 10             	add    $0x10,%esp
  800d14:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d19:	eb 3d                	jmp    800d58 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d1b:	85 db                	test   %ebx,%ebx
  800d1d:	74 04                	je     800d23 <devpipe_read+0x26>
				return i;
  800d1f:	89 d8                	mov    %ebx,%eax
  800d21:	eb 44                	jmp    800d67 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d23:	89 f2                	mov    %esi,%edx
  800d25:	89 f8                	mov    %edi,%eax
  800d27:	e8 e5 fe ff ff       	call   800c11 <_pipeisclosed>
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	75 32                	jne    800d62 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d30:	e8 49 f4 ff ff       	call   80017e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d35:	8b 06                	mov    (%esi),%eax
  800d37:	3b 46 04             	cmp    0x4(%esi),%eax
  800d3a:	74 df                	je     800d1b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d3c:	99                   	cltd   
  800d3d:	c1 ea 1b             	shr    $0x1b,%edx
  800d40:	01 d0                	add    %edx,%eax
  800d42:	83 e0 1f             	and    $0x1f,%eax
  800d45:	29 d0                	sub    %edx,%eax
  800d47:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d52:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d55:	83 c3 01             	add    $0x1,%ebx
  800d58:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d5b:	75 d8                	jne    800d35 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d5d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d60:	eb 05                	jmp    800d67 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d62:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    

00800d6f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d7a:	50                   	push   %eax
  800d7b:	e8 35 f6 ff ff       	call   8003b5 <fd_alloc>
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	89 c2                	mov    %eax,%edx
  800d85:	85 c0                	test   %eax,%eax
  800d87:	0f 88 2c 01 00 00    	js     800eb9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8d:	83 ec 04             	sub    $0x4,%esp
  800d90:	68 07 04 00 00       	push   $0x407
  800d95:	ff 75 f4             	pushl  -0xc(%ebp)
  800d98:	6a 00                	push   $0x0
  800d9a:	e8 fe f3 ff ff       	call   80019d <sys_page_alloc>
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	89 c2                	mov    %eax,%edx
  800da4:	85 c0                	test   %eax,%eax
  800da6:	0f 88 0d 01 00 00    	js     800eb9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800db2:	50                   	push   %eax
  800db3:	e8 fd f5 ff ff       	call   8003b5 <fd_alloc>
  800db8:	89 c3                	mov    %eax,%ebx
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	0f 88 e2 00 00 00    	js     800ea7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc5:	83 ec 04             	sub    $0x4,%esp
  800dc8:	68 07 04 00 00       	push   $0x407
  800dcd:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd0:	6a 00                	push   $0x0
  800dd2:	e8 c6 f3 ff ff       	call   80019d <sys_page_alloc>
  800dd7:	89 c3                	mov    %eax,%ebx
  800dd9:	83 c4 10             	add    $0x10,%esp
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	0f 88 c3 00 00 00    	js     800ea7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800de4:	83 ec 0c             	sub    $0xc,%esp
  800de7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dea:	e8 af f5 ff ff       	call   80039e <fd2data>
  800def:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df1:	83 c4 0c             	add    $0xc,%esp
  800df4:	68 07 04 00 00       	push   $0x407
  800df9:	50                   	push   %eax
  800dfa:	6a 00                	push   $0x0
  800dfc:	e8 9c f3 ff ff       	call   80019d <sys_page_alloc>
  800e01:	89 c3                	mov    %eax,%ebx
  800e03:	83 c4 10             	add    $0x10,%esp
  800e06:	85 c0                	test   %eax,%eax
  800e08:	0f 88 89 00 00 00    	js     800e97 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	ff 75 f0             	pushl  -0x10(%ebp)
  800e14:	e8 85 f5 ff ff       	call   80039e <fd2data>
  800e19:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e20:	50                   	push   %eax
  800e21:	6a 00                	push   $0x0
  800e23:	56                   	push   %esi
  800e24:	6a 00                	push   $0x0
  800e26:	e8 b5 f3 ff ff       	call   8001e0 <sys_page_map>
  800e2b:	89 c3                	mov    %eax,%ebx
  800e2d:	83 c4 20             	add    $0x20,%esp
  800e30:	85 c0                	test   %eax,%eax
  800e32:	78 55                	js     800e89 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e34:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e42:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e49:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e52:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e57:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e5e:	83 ec 0c             	sub    $0xc,%esp
  800e61:	ff 75 f4             	pushl  -0xc(%ebp)
  800e64:	e8 25 f5 ff ff       	call   80038e <fd2num>
  800e69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e6e:	83 c4 04             	add    $0x4,%esp
  800e71:	ff 75 f0             	pushl  -0x10(%ebp)
  800e74:	e8 15 f5 ff ff       	call   80038e <fd2num>
  800e79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7c:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	ba 00 00 00 00       	mov    $0x0,%edx
  800e87:	eb 30                	jmp    800eb9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e89:	83 ec 08             	sub    $0x8,%esp
  800e8c:	56                   	push   %esi
  800e8d:	6a 00                	push   $0x0
  800e8f:	e8 8e f3 ff ff       	call   800222 <sys_page_unmap>
  800e94:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e97:	83 ec 08             	sub    $0x8,%esp
  800e9a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e9d:	6a 00                	push   $0x0
  800e9f:	e8 7e f3 ff ff       	call   800222 <sys_page_unmap>
  800ea4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ea7:	83 ec 08             	sub    $0x8,%esp
  800eaa:	ff 75 f4             	pushl  -0xc(%ebp)
  800ead:	6a 00                	push   $0x0
  800eaf:	e8 6e f3 ff ff       	call   800222 <sys_page_unmap>
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eb9:	89 d0                	mov    %edx,%eax
  800ebb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ecb:	50                   	push   %eax
  800ecc:	ff 75 08             	pushl  0x8(%ebp)
  800ecf:	e8 30 f5 ff ff       	call   800404 <fd_lookup>
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	78 18                	js     800ef3 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800edb:	83 ec 0c             	sub    $0xc,%esp
  800ede:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee1:	e8 b8 f4 ff ff       	call   80039e <fd2data>
	return _pipeisclosed(fd, p);
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eeb:	e8 21 fd ff ff       	call   800c11 <_pipeisclosed>
  800ef0:	83 c4 10             	add    $0x10,%esp
}
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    

00800ef5 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f05:	68 16 1f 80 00       	push   $0x801f16
  800f0a:	ff 75 0c             	pushl  0xc(%ebp)
  800f0d:	e8 c4 07 00 00       	call   8016d6 <strcpy>
	return 0;
}
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    

00800f19 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	57                   	push   %edi
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f25:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f2a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f30:	eb 2d                	jmp    800f5f <devcons_write+0x46>
		m = n - tot;
  800f32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f35:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f37:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f3a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f3f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f42:	83 ec 04             	sub    $0x4,%esp
  800f45:	53                   	push   %ebx
  800f46:	03 45 0c             	add    0xc(%ebp),%eax
  800f49:	50                   	push   %eax
  800f4a:	57                   	push   %edi
  800f4b:	e8 18 09 00 00       	call   801868 <memmove>
		sys_cputs(buf, m);
  800f50:	83 c4 08             	add    $0x8,%esp
  800f53:	53                   	push   %ebx
  800f54:	57                   	push   %edi
  800f55:	e8 87 f1 ff ff       	call   8000e1 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f5a:	01 de                	add    %ebx,%esi
  800f5c:	83 c4 10             	add    $0x10,%esp
  800f5f:	89 f0                	mov    %esi,%eax
  800f61:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f64:	72 cc                	jb     800f32 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f69:	5b                   	pop    %ebx
  800f6a:	5e                   	pop    %esi
  800f6b:	5f                   	pop    %edi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f79:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7d:	74 2a                	je     800fa9 <devcons_read+0x3b>
  800f7f:	eb 05                	jmp    800f86 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f81:	e8 f8 f1 ff ff       	call   80017e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f86:	e8 74 f1 ff ff       	call   8000ff <sys_cgetc>
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	74 f2                	je     800f81 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	78 16                	js     800fa9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f93:	83 f8 04             	cmp    $0x4,%eax
  800f96:	74 0c                	je     800fa4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9b:	88 02                	mov    %al,(%edx)
	return 1;
  800f9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa2:	eb 05                	jmp    800fa9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fb7:	6a 01                	push   $0x1
  800fb9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	e8 1f f1 ff ff       	call   8000e1 <sys_cputs>
}
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	c9                   	leave  
  800fc6:	c3                   	ret    

00800fc7 <getchar>:

int
getchar(void)
{
  800fc7:	55                   	push   %ebp
  800fc8:	89 e5                	mov    %esp,%ebp
  800fca:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fcd:	6a 01                	push   $0x1
  800fcf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd2:	50                   	push   %eax
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 90 f6 ff ff       	call   80066a <read>
	if (r < 0)
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 0f                	js     800ff0 <getchar+0x29>
		return r;
	if (r < 1)
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	7e 06                	jle    800feb <getchar+0x24>
		return -E_EOF;
	return c;
  800fe5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fe9:	eb 05                	jmp    800ff0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800feb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    

00800ff2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffb:	50                   	push   %eax
  800ffc:	ff 75 08             	pushl  0x8(%ebp)
  800fff:	e8 00 f4 ff ff       	call   800404 <fd_lookup>
  801004:	83 c4 10             	add    $0x10,%esp
  801007:	85 c0                	test   %eax,%eax
  801009:	78 11                	js     80101c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80100b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801014:	39 10                	cmp    %edx,(%eax)
  801016:	0f 94 c0             	sete   %al
  801019:	0f b6 c0             	movzbl %al,%eax
}
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <opencons>:

int
opencons(void)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801024:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801027:	50                   	push   %eax
  801028:	e8 88 f3 ff ff       	call   8003b5 <fd_alloc>
  80102d:	83 c4 10             	add    $0x10,%esp
		return r;
  801030:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801032:	85 c0                	test   %eax,%eax
  801034:	78 3e                	js     801074 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	68 07 04 00 00       	push   $0x407
  80103e:	ff 75 f4             	pushl  -0xc(%ebp)
  801041:	6a 00                	push   $0x0
  801043:	e8 55 f1 ff ff       	call   80019d <sys_page_alloc>
  801048:	83 c4 10             	add    $0x10,%esp
		return r;
  80104b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 23                	js     801074 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801051:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801057:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80105c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	50                   	push   %eax
  80106a:	e8 1f f3 ff ff       	call   80038e <fd2num>
  80106f:	89 c2                	mov    %eax,%edx
  801071:	83 c4 10             	add    $0x10,%esp
}
  801074:	89 d0                	mov    %edx,%eax
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	56                   	push   %esi
  80107c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801080:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801086:	e8 d4 f0 ff ff       	call   80015f <sys_getenvid>
  80108b:	83 ec 0c             	sub    $0xc,%esp
  80108e:	ff 75 0c             	pushl  0xc(%ebp)
  801091:	ff 75 08             	pushl  0x8(%ebp)
  801094:	56                   	push   %esi
  801095:	50                   	push   %eax
  801096:	68 24 1f 80 00       	push   $0x801f24
  80109b:	e8 b1 00 00 00       	call   801151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a0:	83 c4 18             	add    $0x18,%esp
  8010a3:	53                   	push   %ebx
  8010a4:	ff 75 10             	pushl  0x10(%ebp)
  8010a7:	e8 54 00 00 00       	call   801100 <vcprintf>
	cprintf("\n");
  8010ac:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  8010b3:	e8 99 00 00 00       	call   801151 <cprintf>
  8010b8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010bb:	cc                   	int3   
  8010bc:	eb fd                	jmp    8010bb <_panic+0x43>

008010be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	53                   	push   %ebx
  8010c2:	83 ec 04             	sub    $0x4,%esp
  8010c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c8:	8b 13                	mov    (%ebx),%edx
  8010ca:	8d 42 01             	lea    0x1(%edx),%eax
  8010cd:	89 03                	mov    %eax,(%ebx)
  8010cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010db:	75 1a                	jne    8010f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010dd:	83 ec 08             	sub    $0x8,%esp
  8010e0:	68 ff 00 00 00       	push   $0xff
  8010e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e8:	50                   	push   %eax
  8010e9:	e8 f3 ef ff ff       	call   8000e1 <sys_cputs>
		b->idx = 0;
  8010ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fe:	c9                   	leave  
  8010ff:	c3                   	ret    

00801100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801110:	00 00 00 
	b.cnt = 0;
  801113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80111a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80111d:	ff 75 0c             	pushl  0xc(%ebp)
  801120:	ff 75 08             	pushl  0x8(%ebp)
  801123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801129:	50                   	push   %eax
  80112a:	68 be 10 80 00       	push   $0x8010be
  80112f:	e8 54 01 00 00       	call   801288 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801134:	83 c4 08             	add    $0x8,%esp
  801137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80113d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801143:	50                   	push   %eax
  801144:	e8 98 ef ff ff       	call   8000e1 <sys_cputs>

	return b.cnt;
}
  801149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80114f:	c9                   	leave  
  801150:	c3                   	ret    

00801151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80115a:	50                   	push   %eax
  80115b:	ff 75 08             	pushl  0x8(%ebp)
  80115e:	e8 9d ff ff ff       	call   801100 <vcprintf>
	va_end(ap);

	return cnt;
}
  801163:	c9                   	leave  
  801164:	c3                   	ret    

00801165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 1c             	sub    $0x1c,%esp
  80116e:	89 c7                	mov    %eax,%edi
  801170:	89 d6                	mov    %edx,%esi
  801172:	8b 45 08             	mov    0x8(%ebp),%eax
  801175:	8b 55 0c             	mov    0xc(%ebp),%edx
  801178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80117e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801181:	bb 00 00 00 00       	mov    $0x0,%ebx
  801186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80118c:	39 d3                	cmp    %edx,%ebx
  80118e:	72 05                	jb     801195 <printnum+0x30>
  801190:	39 45 10             	cmp    %eax,0x10(%ebp)
  801193:	77 45                	ja     8011da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801195:	83 ec 0c             	sub    $0xc,%esp
  801198:	ff 75 18             	pushl  0x18(%ebp)
  80119b:	8b 45 14             	mov    0x14(%ebp),%eax
  80119e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011a1:	53                   	push   %ebx
  8011a2:	ff 75 10             	pushl  0x10(%ebp)
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b4:	e8 b7 09 00 00       	call   801b70 <__udivdi3>
  8011b9:	83 c4 18             	add    $0x18,%esp
  8011bc:	52                   	push   %edx
  8011bd:	50                   	push   %eax
  8011be:	89 f2                	mov    %esi,%edx
  8011c0:	89 f8                	mov    %edi,%eax
  8011c2:	e8 9e ff ff ff       	call   801165 <printnum>
  8011c7:	83 c4 20             	add    $0x20,%esp
  8011ca:	eb 18                	jmp    8011e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011cc:	83 ec 08             	sub    $0x8,%esp
  8011cf:	56                   	push   %esi
  8011d0:	ff 75 18             	pushl  0x18(%ebp)
  8011d3:	ff d7                	call   *%edi
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	eb 03                	jmp    8011dd <printnum+0x78>
  8011da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011dd:	83 eb 01             	sub    $0x1,%ebx
  8011e0:	85 db                	test   %ebx,%ebx
  8011e2:	7f e8                	jg     8011cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	56                   	push   %esi
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f7:	e8 a4 0a 00 00       	call   801ca0 <__umoddi3>
  8011fc:	83 c4 14             	add    $0x14,%esp
  8011ff:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  801206:	50                   	push   %eax
  801207:	ff d7                	call   *%edi
}
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80120f:	5b                   	pop    %ebx
  801210:	5e                   	pop    %esi
  801211:	5f                   	pop    %edi
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801217:	83 fa 01             	cmp    $0x1,%edx
  80121a:	7e 0e                	jle    80122a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80121c:	8b 10                	mov    (%eax),%edx
  80121e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801221:	89 08                	mov    %ecx,(%eax)
  801223:	8b 02                	mov    (%edx),%eax
  801225:	8b 52 04             	mov    0x4(%edx),%edx
  801228:	eb 22                	jmp    80124c <getuint+0x38>
	else if (lflag)
  80122a:	85 d2                	test   %edx,%edx
  80122c:	74 10                	je     80123e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80122e:	8b 10                	mov    (%eax),%edx
  801230:	8d 4a 04             	lea    0x4(%edx),%ecx
  801233:	89 08                	mov    %ecx,(%eax)
  801235:	8b 02                	mov    (%edx),%eax
  801237:	ba 00 00 00 00       	mov    $0x0,%edx
  80123c:	eb 0e                	jmp    80124c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80123e:	8b 10                	mov    (%eax),%edx
  801240:	8d 4a 04             	lea    0x4(%edx),%ecx
  801243:	89 08                	mov    %ecx,(%eax)
  801245:	8b 02                	mov    (%edx),%eax
  801247:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801254:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801258:	8b 10                	mov    (%eax),%edx
  80125a:	3b 50 04             	cmp    0x4(%eax),%edx
  80125d:	73 0a                	jae    801269 <sprintputch+0x1b>
		*b->buf++ = ch;
  80125f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801262:	89 08                	mov    %ecx,(%eax)
  801264:	8b 45 08             	mov    0x8(%ebp),%eax
  801267:	88 02                	mov    %al,(%edx)
}
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    

0080126b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801271:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801274:	50                   	push   %eax
  801275:	ff 75 10             	pushl  0x10(%ebp)
  801278:	ff 75 0c             	pushl  0xc(%ebp)
  80127b:	ff 75 08             	pushl  0x8(%ebp)
  80127e:	e8 05 00 00 00       	call   801288 <vprintfmt>
	va_end(ap);
}
  801283:	83 c4 10             	add    $0x10,%esp
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	57                   	push   %edi
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	83 ec 2c             	sub    $0x2c,%esp
  801291:	8b 75 08             	mov    0x8(%ebp),%esi
  801294:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801297:	8b 7d 10             	mov    0x10(%ebp),%edi
  80129a:	eb 12                	jmp    8012ae <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80129c:	85 c0                	test   %eax,%eax
  80129e:	0f 84 89 03 00 00    	je     80162d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012a4:	83 ec 08             	sub    $0x8,%esp
  8012a7:	53                   	push   %ebx
  8012a8:	50                   	push   %eax
  8012a9:	ff d6                	call   *%esi
  8012ab:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012ae:	83 c7 01             	add    $0x1,%edi
  8012b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012b5:	83 f8 25             	cmp    $0x25,%eax
  8012b8:	75 e2                	jne    80129c <vprintfmt+0x14>
  8012ba:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d8:	eb 07                	jmp    8012e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012da:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012dd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e1:	8d 47 01             	lea    0x1(%edi),%eax
  8012e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e7:	0f b6 07             	movzbl (%edi),%eax
  8012ea:	0f b6 c8             	movzbl %al,%ecx
  8012ed:	83 e8 23             	sub    $0x23,%eax
  8012f0:	3c 55                	cmp    $0x55,%al
  8012f2:	0f 87 1a 03 00 00    	ja     801612 <vprintfmt+0x38a>
  8012f8:	0f b6 c0             	movzbl %al,%eax
  8012fb:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  801302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801305:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801309:	eb d6                	jmp    8012e1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80130e:	b8 00 00 00 00       	mov    $0x0,%eax
  801313:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801316:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801319:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80131d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801320:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801323:	83 fa 09             	cmp    $0x9,%edx
  801326:	77 39                	ja     801361 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801328:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80132b:	eb e9                	jmp    801316 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80132d:	8b 45 14             	mov    0x14(%ebp),%eax
  801330:	8d 48 04             	lea    0x4(%eax),%ecx
  801333:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801336:	8b 00                	mov    (%eax),%eax
  801338:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80133e:	eb 27                	jmp    801367 <vprintfmt+0xdf>
  801340:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801343:	85 c0                	test   %eax,%eax
  801345:	b9 00 00 00 00       	mov    $0x0,%ecx
  80134a:	0f 49 c8             	cmovns %eax,%ecx
  80134d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801350:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801353:	eb 8c                	jmp    8012e1 <vprintfmt+0x59>
  801355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801358:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80135f:	eb 80                	jmp    8012e1 <vprintfmt+0x59>
  801361:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801364:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80136b:	0f 89 70 ff ff ff    	jns    8012e1 <vprintfmt+0x59>
				width = precision, precision = -1;
  801371:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801374:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801377:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80137e:	e9 5e ff ff ff       	jmp    8012e1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801383:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801389:	e9 53 ff ff ff       	jmp    8012e1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80138e:	8b 45 14             	mov    0x14(%ebp),%eax
  801391:	8d 50 04             	lea    0x4(%eax),%edx
  801394:	89 55 14             	mov    %edx,0x14(%ebp)
  801397:	83 ec 08             	sub    $0x8,%esp
  80139a:	53                   	push   %ebx
  80139b:	ff 30                	pushl  (%eax)
  80139d:	ff d6                	call   *%esi
			break;
  80139f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013a5:	e9 04 ff ff ff       	jmp    8012ae <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ad:	8d 50 04             	lea    0x4(%eax),%edx
  8013b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b3:	8b 00                	mov    (%eax),%eax
  8013b5:	99                   	cltd   
  8013b6:	31 d0                	xor    %edx,%eax
  8013b8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013ba:	83 f8 0f             	cmp    $0xf,%eax
  8013bd:	7f 0b                	jg     8013ca <vprintfmt+0x142>
  8013bf:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013c6:	85 d2                	test   %edx,%edx
  8013c8:	75 18                	jne    8013e2 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013ca:	50                   	push   %eax
  8013cb:	68 5f 1f 80 00       	push   $0x801f5f
  8013d0:	53                   	push   %ebx
  8013d1:	56                   	push   %esi
  8013d2:	e8 94 fe ff ff       	call   80126b <printfmt>
  8013d7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013dd:	e9 cc fe ff ff       	jmp    8012ae <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013e2:	52                   	push   %edx
  8013e3:	68 dd 1e 80 00       	push   $0x801edd
  8013e8:	53                   	push   %ebx
  8013e9:	56                   	push   %esi
  8013ea:	e8 7c fe ff ff       	call   80126b <printfmt>
  8013ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013f5:	e9 b4 fe ff ff       	jmp    8012ae <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8013fd:	8d 50 04             	lea    0x4(%eax),%edx
  801400:	89 55 14             	mov    %edx,0x14(%ebp)
  801403:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801405:	85 ff                	test   %edi,%edi
  801407:	b8 58 1f 80 00       	mov    $0x801f58,%eax
  80140c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80140f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801413:	0f 8e 94 00 00 00    	jle    8014ad <vprintfmt+0x225>
  801419:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80141d:	0f 84 98 00 00 00    	je     8014bb <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	ff 75 d0             	pushl  -0x30(%ebp)
  801429:	57                   	push   %edi
  80142a:	e8 86 02 00 00       	call   8016b5 <strnlen>
  80142f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801432:	29 c1                	sub    %eax,%ecx
  801434:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801437:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80143a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80143e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801441:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801444:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801446:	eb 0f                	jmp    801457 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801448:	83 ec 08             	sub    $0x8,%esp
  80144b:	53                   	push   %ebx
  80144c:	ff 75 e0             	pushl  -0x20(%ebp)
  80144f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801451:	83 ef 01             	sub    $0x1,%edi
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 ff                	test   %edi,%edi
  801459:	7f ed                	jg     801448 <vprintfmt+0x1c0>
  80145b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80145e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801461:	85 c9                	test   %ecx,%ecx
  801463:	b8 00 00 00 00       	mov    $0x0,%eax
  801468:	0f 49 c1             	cmovns %ecx,%eax
  80146b:	29 c1                	sub    %eax,%ecx
  80146d:	89 75 08             	mov    %esi,0x8(%ebp)
  801470:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801473:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801476:	89 cb                	mov    %ecx,%ebx
  801478:	eb 4d                	jmp    8014c7 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80147a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80147e:	74 1b                	je     80149b <vprintfmt+0x213>
  801480:	0f be c0             	movsbl %al,%eax
  801483:	83 e8 20             	sub    $0x20,%eax
  801486:	83 f8 5e             	cmp    $0x5e,%eax
  801489:	76 10                	jbe    80149b <vprintfmt+0x213>
					putch('?', putdat);
  80148b:	83 ec 08             	sub    $0x8,%esp
  80148e:	ff 75 0c             	pushl  0xc(%ebp)
  801491:	6a 3f                	push   $0x3f
  801493:	ff 55 08             	call   *0x8(%ebp)
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	eb 0d                	jmp    8014a8 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	ff 75 0c             	pushl  0xc(%ebp)
  8014a1:	52                   	push   %edx
  8014a2:	ff 55 08             	call   *0x8(%ebp)
  8014a5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a8:	83 eb 01             	sub    $0x1,%ebx
  8014ab:	eb 1a                	jmp    8014c7 <vprintfmt+0x23f>
  8014ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014b9:	eb 0c                	jmp    8014c7 <vprintfmt+0x23f>
  8014bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8014be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c7:	83 c7 01             	add    $0x1,%edi
  8014ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ce:	0f be d0             	movsbl %al,%edx
  8014d1:	85 d2                	test   %edx,%edx
  8014d3:	74 23                	je     8014f8 <vprintfmt+0x270>
  8014d5:	85 f6                	test   %esi,%esi
  8014d7:	78 a1                	js     80147a <vprintfmt+0x1f2>
  8014d9:	83 ee 01             	sub    $0x1,%esi
  8014dc:	79 9c                	jns    80147a <vprintfmt+0x1f2>
  8014de:	89 df                	mov    %ebx,%edi
  8014e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e6:	eb 18                	jmp    801500 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	53                   	push   %ebx
  8014ec:	6a 20                	push   $0x20
  8014ee:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014f0:	83 ef 01             	sub    $0x1,%edi
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	eb 08                	jmp    801500 <vprintfmt+0x278>
  8014f8:	89 df                	mov    %ebx,%edi
  8014fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8014fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801500:	85 ff                	test   %edi,%edi
  801502:	7f e4                	jg     8014e8 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801504:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801507:	e9 a2 fd ff ff       	jmp    8012ae <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80150c:	83 fa 01             	cmp    $0x1,%edx
  80150f:	7e 16                	jle    801527 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801511:	8b 45 14             	mov    0x14(%ebp),%eax
  801514:	8d 50 08             	lea    0x8(%eax),%edx
  801517:	89 55 14             	mov    %edx,0x14(%ebp)
  80151a:	8b 50 04             	mov    0x4(%eax),%edx
  80151d:	8b 00                	mov    (%eax),%eax
  80151f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801522:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801525:	eb 32                	jmp    801559 <vprintfmt+0x2d1>
	else if (lflag)
  801527:	85 d2                	test   %edx,%edx
  801529:	74 18                	je     801543 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80152b:	8b 45 14             	mov    0x14(%ebp),%eax
  80152e:	8d 50 04             	lea    0x4(%eax),%edx
  801531:	89 55 14             	mov    %edx,0x14(%ebp)
  801534:	8b 00                	mov    (%eax),%eax
  801536:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801539:	89 c1                	mov    %eax,%ecx
  80153b:	c1 f9 1f             	sar    $0x1f,%ecx
  80153e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801541:	eb 16                	jmp    801559 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801543:	8b 45 14             	mov    0x14(%ebp),%eax
  801546:	8d 50 04             	lea    0x4(%eax),%edx
  801549:	89 55 14             	mov    %edx,0x14(%ebp)
  80154c:	8b 00                	mov    (%eax),%eax
  80154e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801551:	89 c1                	mov    %eax,%ecx
  801553:	c1 f9 1f             	sar    $0x1f,%ecx
  801556:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801559:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80155c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80155f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801564:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801568:	79 74                	jns    8015de <vprintfmt+0x356>
				putch('-', putdat);
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	53                   	push   %ebx
  80156e:	6a 2d                	push   $0x2d
  801570:	ff d6                	call   *%esi
				num = -(long long) num;
  801572:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801575:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801578:	f7 d8                	neg    %eax
  80157a:	83 d2 00             	adc    $0x0,%edx
  80157d:	f7 da                	neg    %edx
  80157f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801582:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801587:	eb 55                	jmp    8015de <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801589:	8d 45 14             	lea    0x14(%ebp),%eax
  80158c:	e8 83 fc ff ff       	call   801214 <getuint>
			base = 10;
  801591:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801596:	eb 46                	jmp    8015de <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801598:	8d 45 14             	lea    0x14(%ebp),%eax
  80159b:	e8 74 fc ff ff       	call   801214 <getuint>
			base = 8;
  8015a0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015a5:	eb 37                	jmp    8015de <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	53                   	push   %ebx
  8015ab:	6a 30                	push   $0x30
  8015ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8015af:	83 c4 08             	add    $0x8,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	6a 78                	push   $0x78
  8015b5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ba:	8d 50 04             	lea    0x4(%eax),%edx
  8015bd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015c0:	8b 00                	mov    (%eax),%eax
  8015c2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015ca:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015cf:	eb 0d                	jmp    8015de <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d4:	e8 3b fc ff ff       	call   801214 <getuint>
			base = 16;
  8015d9:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015e5:	57                   	push   %edi
  8015e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e9:	51                   	push   %ecx
  8015ea:	52                   	push   %edx
  8015eb:	50                   	push   %eax
  8015ec:	89 da                	mov    %ebx,%edx
  8015ee:	89 f0                	mov    %esi,%eax
  8015f0:	e8 70 fb ff ff       	call   801165 <printnum>
			break;
  8015f5:	83 c4 20             	add    $0x20,%esp
  8015f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015fb:	e9 ae fc ff ff       	jmp    8012ae <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	53                   	push   %ebx
  801604:	51                   	push   %ecx
  801605:	ff d6                	call   *%esi
			break;
  801607:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80160d:	e9 9c fc ff ff       	jmp    8012ae <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	53                   	push   %ebx
  801616:	6a 25                	push   $0x25
  801618:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	eb 03                	jmp    801622 <vprintfmt+0x39a>
  80161f:	83 ef 01             	sub    $0x1,%edi
  801622:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801626:	75 f7                	jne    80161f <vprintfmt+0x397>
  801628:	e9 81 fc ff ff       	jmp    8012ae <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80162d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801630:	5b                   	pop    %ebx
  801631:	5e                   	pop    %esi
  801632:	5f                   	pop    %edi
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	83 ec 18             	sub    $0x18,%esp
  80163b:	8b 45 08             	mov    0x8(%ebp),%eax
  80163e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801641:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801644:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801648:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80164b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801652:	85 c0                	test   %eax,%eax
  801654:	74 26                	je     80167c <vsnprintf+0x47>
  801656:	85 d2                	test   %edx,%edx
  801658:	7e 22                	jle    80167c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80165a:	ff 75 14             	pushl  0x14(%ebp)
  80165d:	ff 75 10             	pushl  0x10(%ebp)
  801660:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	68 4e 12 80 00       	push   $0x80124e
  801669:	e8 1a fc ff ff       	call   801288 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80166e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801671:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	eb 05                	jmp    801681 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80167c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801689:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80168c:	50                   	push   %eax
  80168d:	ff 75 10             	pushl  0x10(%ebp)
  801690:	ff 75 0c             	pushl  0xc(%ebp)
  801693:	ff 75 08             	pushl  0x8(%ebp)
  801696:	e8 9a ff ff ff       	call   801635 <vsnprintf>
	va_end(ap);

	return rc;
}
  80169b:	c9                   	leave  
  80169c:	c3                   	ret    

0080169d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a8:	eb 03                	jmp    8016ad <strlen+0x10>
		n++;
  8016aa:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b1:	75 f7                	jne    8016aa <strlen+0xd>
		n++;
	return n;
}
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016be:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c3:	eb 03                	jmp    8016c8 <strnlen+0x13>
		n++;
  8016c5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c8:	39 c2                	cmp    %eax,%edx
  8016ca:	74 08                	je     8016d4 <strnlen+0x1f>
  8016cc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d0:	75 f3                	jne    8016c5 <strnlen+0x10>
  8016d2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016d4:	5d                   	pop    %ebp
  8016d5:	c3                   	ret    

008016d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	83 c2 01             	add    $0x1,%edx
  8016e5:	83 c1 01             	add    $0x1,%ecx
  8016e8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ec:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016ef:	84 db                	test   %bl,%bl
  8016f1:	75 ef                	jne    8016e2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016f3:	5b                   	pop    %ebx
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	53                   	push   %ebx
  8016fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016fd:	53                   	push   %ebx
  8016fe:	e8 9a ff ff ff       	call   80169d <strlen>
  801703:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801706:	ff 75 0c             	pushl  0xc(%ebp)
  801709:	01 d8                	add    %ebx,%eax
  80170b:	50                   	push   %eax
  80170c:	e8 c5 ff ff ff       	call   8016d6 <strcpy>
	return dst;
}
  801711:	89 d8                	mov    %ebx,%eax
  801713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	56                   	push   %esi
  80171c:	53                   	push   %ebx
  80171d:	8b 75 08             	mov    0x8(%ebp),%esi
  801720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801723:	89 f3                	mov    %esi,%ebx
  801725:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801728:	89 f2                	mov    %esi,%edx
  80172a:	eb 0f                	jmp    80173b <strncpy+0x23>
		*dst++ = *src;
  80172c:	83 c2 01             	add    $0x1,%edx
  80172f:	0f b6 01             	movzbl (%ecx),%eax
  801732:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801735:	80 39 01             	cmpb   $0x1,(%ecx)
  801738:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173b:	39 da                	cmp    %ebx,%edx
  80173d:	75 ed                	jne    80172c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80173f:	89 f0                	mov    %esi,%eax
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
  80174a:	8b 75 08             	mov    0x8(%ebp),%esi
  80174d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801750:	8b 55 10             	mov    0x10(%ebp),%edx
  801753:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801755:	85 d2                	test   %edx,%edx
  801757:	74 21                	je     80177a <strlcpy+0x35>
  801759:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80175d:	89 f2                	mov    %esi,%edx
  80175f:	eb 09                	jmp    80176a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801761:	83 c2 01             	add    $0x1,%edx
  801764:	83 c1 01             	add    $0x1,%ecx
  801767:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80176a:	39 c2                	cmp    %eax,%edx
  80176c:	74 09                	je     801777 <strlcpy+0x32>
  80176e:	0f b6 19             	movzbl (%ecx),%ebx
  801771:	84 db                	test   %bl,%bl
  801773:	75 ec                	jne    801761 <strlcpy+0x1c>
  801775:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801777:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80177a:	29 f0                	sub    %esi,%eax
}
  80177c:	5b                   	pop    %ebx
  80177d:	5e                   	pop    %esi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801786:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801789:	eb 06                	jmp    801791 <strcmp+0x11>
		p++, q++;
  80178b:	83 c1 01             	add    $0x1,%ecx
  80178e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801791:	0f b6 01             	movzbl (%ecx),%eax
  801794:	84 c0                	test   %al,%al
  801796:	74 04                	je     80179c <strcmp+0x1c>
  801798:	3a 02                	cmp    (%edx),%al
  80179a:	74 ef                	je     80178b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80179c:	0f b6 c0             	movzbl %al,%eax
  80179f:	0f b6 12             	movzbl (%edx),%edx
  8017a2:	29 d0                	sub    %edx,%eax
}
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	53                   	push   %ebx
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b0:	89 c3                	mov    %eax,%ebx
  8017b2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b5:	eb 06                	jmp    8017bd <strncmp+0x17>
		n--, p++, q++;
  8017b7:	83 c0 01             	add    $0x1,%eax
  8017ba:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017bd:	39 d8                	cmp    %ebx,%eax
  8017bf:	74 15                	je     8017d6 <strncmp+0x30>
  8017c1:	0f b6 08             	movzbl (%eax),%ecx
  8017c4:	84 c9                	test   %cl,%cl
  8017c6:	74 04                	je     8017cc <strncmp+0x26>
  8017c8:	3a 0a                	cmp    (%edx),%cl
  8017ca:	74 eb                	je     8017b7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017cc:	0f b6 00             	movzbl (%eax),%eax
  8017cf:	0f b6 12             	movzbl (%edx),%edx
  8017d2:	29 d0                	sub    %edx,%eax
  8017d4:	eb 05                	jmp    8017db <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017d6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017db:	5b                   	pop    %ebx
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e8:	eb 07                	jmp    8017f1 <strchr+0x13>
		if (*s == c)
  8017ea:	38 ca                	cmp    %cl,%dl
  8017ec:	74 0f                	je     8017fd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017ee:	83 c0 01             	add    $0x1,%eax
  8017f1:	0f b6 10             	movzbl (%eax),%edx
  8017f4:	84 d2                	test   %dl,%dl
  8017f6:	75 f2                	jne    8017ea <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801809:	eb 03                	jmp    80180e <strfind+0xf>
  80180b:	83 c0 01             	add    $0x1,%eax
  80180e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801811:	38 ca                	cmp    %cl,%dl
  801813:	74 04                	je     801819 <strfind+0x1a>
  801815:	84 d2                	test   %dl,%dl
  801817:	75 f2                	jne    80180b <strfind+0xc>
			break;
	return (char *) s;
}
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	57                   	push   %edi
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	8b 7d 08             	mov    0x8(%ebp),%edi
  801824:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801827:	85 c9                	test   %ecx,%ecx
  801829:	74 36                	je     801861 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80182b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801831:	75 28                	jne    80185b <memset+0x40>
  801833:	f6 c1 03             	test   $0x3,%cl
  801836:	75 23                	jne    80185b <memset+0x40>
		c &= 0xFF;
  801838:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80183c:	89 d3                	mov    %edx,%ebx
  80183e:	c1 e3 08             	shl    $0x8,%ebx
  801841:	89 d6                	mov    %edx,%esi
  801843:	c1 e6 18             	shl    $0x18,%esi
  801846:	89 d0                	mov    %edx,%eax
  801848:	c1 e0 10             	shl    $0x10,%eax
  80184b:	09 f0                	or     %esi,%eax
  80184d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80184f:	89 d8                	mov    %ebx,%eax
  801851:	09 d0                	or     %edx,%eax
  801853:	c1 e9 02             	shr    $0x2,%ecx
  801856:	fc                   	cld    
  801857:	f3 ab                	rep stos %eax,%es:(%edi)
  801859:	eb 06                	jmp    801861 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185e:	fc                   	cld    
  80185f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801861:	89 f8                	mov    %edi,%eax
  801863:	5b                   	pop    %ebx
  801864:	5e                   	pop    %esi
  801865:	5f                   	pop    %edi
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	57                   	push   %edi
  80186c:	56                   	push   %esi
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	8b 75 0c             	mov    0xc(%ebp),%esi
  801873:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801876:	39 c6                	cmp    %eax,%esi
  801878:	73 35                	jae    8018af <memmove+0x47>
  80187a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80187d:	39 d0                	cmp    %edx,%eax
  80187f:	73 2e                	jae    8018af <memmove+0x47>
		s += n;
		d += n;
  801881:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801884:	89 d6                	mov    %edx,%esi
  801886:	09 fe                	or     %edi,%esi
  801888:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80188e:	75 13                	jne    8018a3 <memmove+0x3b>
  801890:	f6 c1 03             	test   $0x3,%cl
  801893:	75 0e                	jne    8018a3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801895:	83 ef 04             	sub    $0x4,%edi
  801898:	8d 72 fc             	lea    -0x4(%edx),%esi
  80189b:	c1 e9 02             	shr    $0x2,%ecx
  80189e:	fd                   	std    
  80189f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a1:	eb 09                	jmp    8018ac <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a3:	83 ef 01             	sub    $0x1,%edi
  8018a6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018a9:	fd                   	std    
  8018aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ac:	fc                   	cld    
  8018ad:	eb 1d                	jmp    8018cc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018af:	89 f2                	mov    %esi,%edx
  8018b1:	09 c2                	or     %eax,%edx
  8018b3:	f6 c2 03             	test   $0x3,%dl
  8018b6:	75 0f                	jne    8018c7 <memmove+0x5f>
  8018b8:	f6 c1 03             	test   $0x3,%cl
  8018bb:	75 0a                	jne    8018c7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018bd:	c1 e9 02             	shr    $0x2,%ecx
  8018c0:	89 c7                	mov    %eax,%edi
  8018c2:	fc                   	cld    
  8018c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c5:	eb 05                	jmp    8018cc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018c7:	89 c7                	mov    %eax,%edi
  8018c9:	fc                   	cld    
  8018ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018cc:	5e                   	pop    %esi
  8018cd:	5f                   	pop    %edi
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d3:	ff 75 10             	pushl  0x10(%ebp)
  8018d6:	ff 75 0c             	pushl  0xc(%ebp)
  8018d9:	ff 75 08             	pushl  0x8(%ebp)
  8018dc:	e8 87 ff ff ff       	call   801868 <memmove>
}
  8018e1:	c9                   	leave  
  8018e2:	c3                   	ret    

008018e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ee:	89 c6                	mov    %eax,%esi
  8018f0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f3:	eb 1a                	jmp    80190f <memcmp+0x2c>
		if (*s1 != *s2)
  8018f5:	0f b6 08             	movzbl (%eax),%ecx
  8018f8:	0f b6 1a             	movzbl (%edx),%ebx
  8018fb:	38 d9                	cmp    %bl,%cl
  8018fd:	74 0a                	je     801909 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018ff:	0f b6 c1             	movzbl %cl,%eax
  801902:	0f b6 db             	movzbl %bl,%ebx
  801905:	29 d8                	sub    %ebx,%eax
  801907:	eb 0f                	jmp    801918 <memcmp+0x35>
		s1++, s2++;
  801909:	83 c0 01             	add    $0x1,%eax
  80190c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190f:	39 f0                	cmp    %esi,%eax
  801911:	75 e2                	jne    8018f5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	53                   	push   %ebx
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801923:	89 c1                	mov    %eax,%ecx
  801925:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801928:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80192c:	eb 0a                	jmp    801938 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80192e:	0f b6 10             	movzbl (%eax),%edx
  801931:	39 da                	cmp    %ebx,%edx
  801933:	74 07                	je     80193c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801935:	83 c0 01             	add    $0x1,%eax
  801938:	39 c8                	cmp    %ecx,%eax
  80193a:	72 f2                	jb     80192e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80193c:	5b                   	pop    %ebx
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	57                   	push   %edi
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801948:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194b:	eb 03                	jmp    801950 <strtol+0x11>
		s++;
  80194d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801950:	0f b6 01             	movzbl (%ecx),%eax
  801953:	3c 20                	cmp    $0x20,%al
  801955:	74 f6                	je     80194d <strtol+0xe>
  801957:	3c 09                	cmp    $0x9,%al
  801959:	74 f2                	je     80194d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80195b:	3c 2b                	cmp    $0x2b,%al
  80195d:	75 0a                	jne    801969 <strtol+0x2a>
		s++;
  80195f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801962:	bf 00 00 00 00       	mov    $0x0,%edi
  801967:	eb 11                	jmp    80197a <strtol+0x3b>
  801969:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80196e:	3c 2d                	cmp    $0x2d,%al
  801970:	75 08                	jne    80197a <strtol+0x3b>
		s++, neg = 1;
  801972:	83 c1 01             	add    $0x1,%ecx
  801975:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801980:	75 15                	jne    801997 <strtol+0x58>
  801982:	80 39 30             	cmpb   $0x30,(%ecx)
  801985:	75 10                	jne    801997 <strtol+0x58>
  801987:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80198b:	75 7c                	jne    801a09 <strtol+0xca>
		s += 2, base = 16;
  80198d:	83 c1 02             	add    $0x2,%ecx
  801990:	bb 10 00 00 00       	mov    $0x10,%ebx
  801995:	eb 16                	jmp    8019ad <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801997:	85 db                	test   %ebx,%ebx
  801999:	75 12                	jne    8019ad <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a3:	75 08                	jne    8019ad <strtol+0x6e>
		s++, base = 8;
  8019a5:	83 c1 01             	add    $0x1,%ecx
  8019a8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019b5:	0f b6 11             	movzbl (%ecx),%edx
  8019b8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019bb:	89 f3                	mov    %esi,%ebx
  8019bd:	80 fb 09             	cmp    $0x9,%bl
  8019c0:	77 08                	ja     8019ca <strtol+0x8b>
			dig = *s - '0';
  8019c2:	0f be d2             	movsbl %dl,%edx
  8019c5:	83 ea 30             	sub    $0x30,%edx
  8019c8:	eb 22                	jmp    8019ec <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019ca:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019cd:	89 f3                	mov    %esi,%ebx
  8019cf:	80 fb 19             	cmp    $0x19,%bl
  8019d2:	77 08                	ja     8019dc <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019d4:	0f be d2             	movsbl %dl,%edx
  8019d7:	83 ea 57             	sub    $0x57,%edx
  8019da:	eb 10                	jmp    8019ec <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019dc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019df:	89 f3                	mov    %esi,%ebx
  8019e1:	80 fb 19             	cmp    $0x19,%bl
  8019e4:	77 16                	ja     8019fc <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019e6:	0f be d2             	movsbl %dl,%edx
  8019e9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019ec:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ef:	7d 0b                	jge    8019fc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019f1:	83 c1 01             	add    $0x1,%ecx
  8019f4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019fa:	eb b9                	jmp    8019b5 <strtol+0x76>

	if (endptr)
  8019fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a00:	74 0d                	je     801a0f <strtol+0xd0>
		*endptr = (char *) s;
  801a02:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a05:	89 0e                	mov    %ecx,(%esi)
  801a07:	eb 06                	jmp    801a0f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a09:	85 db                	test   %ebx,%ebx
  801a0b:	74 98                	je     8019a5 <strtol+0x66>
  801a0d:	eb 9e                	jmp    8019ad <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a0f:	89 c2                	mov    %eax,%edx
  801a11:	f7 da                	neg    %edx
  801a13:	85 ff                	test   %edi,%edi
  801a15:	0f 45 c2             	cmovne %edx,%eax
}
  801a18:	5b                   	pop    %ebx
  801a19:	5e                   	pop    %esi
  801a1a:	5f                   	pop    %edi
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    

00801a1d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	8b 75 08             	mov    0x8(%ebp),%esi
  801a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	75 12                	jne    801a41 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	68 00 00 c0 ee       	push   $0xeec00000
  801a37:	e8 11 e9 ff ff       	call   80034d <sys_ipc_recv>
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	eb 0c                	jmp    801a4d <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a41:	83 ec 0c             	sub    $0xc,%esp
  801a44:	50                   	push   %eax
  801a45:	e8 03 e9 ff ff       	call   80034d <sys_ipc_recv>
  801a4a:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a4d:	85 f6                	test   %esi,%esi
  801a4f:	0f 95 c1             	setne  %cl
  801a52:	85 db                	test   %ebx,%ebx
  801a54:	0f 95 c2             	setne  %dl
  801a57:	84 d1                	test   %dl,%cl
  801a59:	74 09                	je     801a64 <ipc_recv+0x47>
  801a5b:	89 c2                	mov    %eax,%edx
  801a5d:	c1 ea 1f             	shr    $0x1f,%edx
  801a60:	84 d2                	test   %dl,%dl
  801a62:	75 24                	jne    801a88 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a64:	85 f6                	test   %esi,%esi
  801a66:	74 0a                	je     801a72 <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801a68:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6d:	8b 40 74             	mov    0x74(%eax),%eax
  801a70:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801a72:	85 db                	test   %ebx,%ebx
  801a74:	74 0a                	je     801a80 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801a76:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7b:	8b 40 78             	mov    0x78(%eax),%eax
  801a7e:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a80:	a1 04 40 80 00       	mov    0x804004,%eax
  801a85:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5e                   	pop    %esi
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    

00801a8f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	57                   	push   %edi
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801aa1:	85 db                	test   %ebx,%ebx
  801aa3:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aa8:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801aab:	ff 75 14             	pushl  0x14(%ebp)
  801aae:	53                   	push   %ebx
  801aaf:	56                   	push   %esi
  801ab0:	57                   	push   %edi
  801ab1:	e8 74 e8 ff ff       	call   80032a <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ab6:	89 c2                	mov    %eax,%edx
  801ab8:	c1 ea 1f             	shr    $0x1f,%edx
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	84 d2                	test   %dl,%dl
  801ac0:	74 17                	je     801ad9 <ipc_send+0x4a>
  801ac2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ac5:	74 12                	je     801ad9 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ac7:	50                   	push   %eax
  801ac8:	68 40 22 80 00       	push   $0x802240
  801acd:	6a 47                	push   $0x47
  801acf:	68 4e 22 80 00       	push   $0x80224e
  801ad4:	e8 9f f5 ff ff       	call   801078 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ad9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801adc:	75 07                	jne    801ae5 <ipc_send+0x56>
			sys_yield();
  801ade:	e8 9b e6 ff ff       	call   80017e <sys_yield>
  801ae3:	eb c6                	jmp    801aab <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	75 c2                	jne    801aab <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5f                   	pop    %edi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801afc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aff:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b05:	8b 52 50             	mov    0x50(%edx),%edx
  801b08:	39 ca                	cmp    %ecx,%edx
  801b0a:	75 0d                	jne    801b19 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b0c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b0f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b14:	8b 40 48             	mov    0x48(%eax),%eax
  801b17:	eb 0f                	jmp    801b28 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b19:	83 c0 01             	add    $0x1,%eax
  801b1c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b21:	75 d9                	jne    801afc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b28:	5d                   	pop    %ebp
  801b29:	c3                   	ret    

00801b2a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b30:	89 d0                	mov    %edx,%eax
  801b32:	c1 e8 16             	shr    $0x16,%eax
  801b35:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b3c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b41:	f6 c1 01             	test   $0x1,%cl
  801b44:	74 1d                	je     801b63 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b46:	c1 ea 0c             	shr    $0xc,%edx
  801b49:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b50:	f6 c2 01             	test   $0x1,%dl
  801b53:	74 0e                	je     801b63 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b55:	c1 ea 0c             	shr    $0xc,%edx
  801b58:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b5f:	ef 
  801b60:	0f b7 c0             	movzwl %ax,%eax
}
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    
  801b65:	66 90                	xchg   %ax,%ax
  801b67:	66 90                	xchg   %ax,%ax
  801b69:	66 90                	xchg   %ax,%ax
  801b6b:	66 90                	xchg   %ax,%ax
  801b6d:	66 90                	xchg   %ax,%ax
  801b6f:	90                   	nop

00801b70 <__udivdi3>:
  801b70:	55                   	push   %ebp
  801b71:	57                   	push   %edi
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	83 ec 1c             	sub    $0x1c,%esp
  801b77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b87:	85 f6                	test   %esi,%esi
  801b89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b8d:	89 ca                	mov    %ecx,%edx
  801b8f:	89 f8                	mov    %edi,%eax
  801b91:	75 3d                	jne    801bd0 <__udivdi3+0x60>
  801b93:	39 cf                	cmp    %ecx,%edi
  801b95:	0f 87 c5 00 00 00    	ja     801c60 <__udivdi3+0xf0>
  801b9b:	85 ff                	test   %edi,%edi
  801b9d:	89 fd                	mov    %edi,%ebp
  801b9f:	75 0b                	jne    801bac <__udivdi3+0x3c>
  801ba1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba6:	31 d2                	xor    %edx,%edx
  801ba8:	f7 f7                	div    %edi
  801baa:	89 c5                	mov    %eax,%ebp
  801bac:	89 c8                	mov    %ecx,%eax
  801bae:	31 d2                	xor    %edx,%edx
  801bb0:	f7 f5                	div    %ebp
  801bb2:	89 c1                	mov    %eax,%ecx
  801bb4:	89 d8                	mov    %ebx,%eax
  801bb6:	89 cf                	mov    %ecx,%edi
  801bb8:	f7 f5                	div    %ebp
  801bba:	89 c3                	mov    %eax,%ebx
  801bbc:	89 d8                	mov    %ebx,%eax
  801bbe:	89 fa                	mov    %edi,%edx
  801bc0:	83 c4 1c             	add    $0x1c,%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5f                   	pop    %edi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    
  801bc8:	90                   	nop
  801bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	39 ce                	cmp    %ecx,%esi
  801bd2:	77 74                	ja     801c48 <__udivdi3+0xd8>
  801bd4:	0f bd fe             	bsr    %esi,%edi
  801bd7:	83 f7 1f             	xor    $0x1f,%edi
  801bda:	0f 84 98 00 00 00    	je     801c78 <__udivdi3+0x108>
  801be0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	89 c5                	mov    %eax,%ebp
  801be9:	29 fb                	sub    %edi,%ebx
  801beb:	d3 e6                	shl    %cl,%esi
  801bed:	89 d9                	mov    %ebx,%ecx
  801bef:	d3 ed                	shr    %cl,%ebp
  801bf1:	89 f9                	mov    %edi,%ecx
  801bf3:	d3 e0                	shl    %cl,%eax
  801bf5:	09 ee                	or     %ebp,%esi
  801bf7:	89 d9                	mov    %ebx,%ecx
  801bf9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfd:	89 d5                	mov    %edx,%ebp
  801bff:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c03:	d3 ed                	shr    %cl,%ebp
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	d3 e2                	shl    %cl,%edx
  801c09:	89 d9                	mov    %ebx,%ecx
  801c0b:	d3 e8                	shr    %cl,%eax
  801c0d:	09 c2                	or     %eax,%edx
  801c0f:	89 d0                	mov    %edx,%eax
  801c11:	89 ea                	mov    %ebp,%edx
  801c13:	f7 f6                	div    %esi
  801c15:	89 d5                	mov    %edx,%ebp
  801c17:	89 c3                	mov    %eax,%ebx
  801c19:	f7 64 24 0c          	mull   0xc(%esp)
  801c1d:	39 d5                	cmp    %edx,%ebp
  801c1f:	72 10                	jb     801c31 <__udivdi3+0xc1>
  801c21:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	d3 e6                	shl    %cl,%esi
  801c29:	39 c6                	cmp    %eax,%esi
  801c2b:	73 07                	jae    801c34 <__udivdi3+0xc4>
  801c2d:	39 d5                	cmp    %edx,%ebp
  801c2f:	75 03                	jne    801c34 <__udivdi3+0xc4>
  801c31:	83 eb 01             	sub    $0x1,%ebx
  801c34:	31 ff                	xor    %edi,%edi
  801c36:	89 d8                	mov    %ebx,%eax
  801c38:	89 fa                	mov    %edi,%edx
  801c3a:	83 c4 1c             	add    $0x1c,%esp
  801c3d:	5b                   	pop    %ebx
  801c3e:	5e                   	pop    %esi
  801c3f:	5f                   	pop    %edi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    
  801c42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c48:	31 ff                	xor    %edi,%edi
  801c4a:	31 db                	xor    %ebx,%ebx
  801c4c:	89 d8                	mov    %ebx,%eax
  801c4e:	89 fa                	mov    %edi,%edx
  801c50:	83 c4 1c             	add    $0x1c,%esp
  801c53:	5b                   	pop    %ebx
  801c54:	5e                   	pop    %esi
  801c55:	5f                   	pop    %edi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    
  801c58:	90                   	nop
  801c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c60:	89 d8                	mov    %ebx,%eax
  801c62:	f7 f7                	div    %edi
  801c64:	31 ff                	xor    %edi,%edi
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	89 d8                	mov    %ebx,%eax
  801c6a:	89 fa                	mov    %edi,%edx
  801c6c:	83 c4 1c             	add    $0x1c,%esp
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5f                   	pop    %edi
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    
  801c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c78:	39 ce                	cmp    %ecx,%esi
  801c7a:	72 0c                	jb     801c88 <__udivdi3+0x118>
  801c7c:	31 db                	xor    %ebx,%ebx
  801c7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c82:	0f 87 34 ff ff ff    	ja     801bbc <__udivdi3+0x4c>
  801c88:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c8d:	e9 2a ff ff ff       	jmp    801bbc <__udivdi3+0x4c>
  801c92:	66 90                	xchg   %ax,%ax
  801c94:	66 90                	xchg   %ax,%ax
  801c96:	66 90                	xchg   %ax,%ax
  801c98:	66 90                	xchg   %ax,%ax
  801c9a:	66 90                	xchg   %ax,%ax
  801c9c:	66 90                	xchg   %ax,%ax
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__umoddi3>:
  801ca0:	55                   	push   %ebp
  801ca1:	57                   	push   %edi
  801ca2:	56                   	push   %esi
  801ca3:	53                   	push   %ebx
  801ca4:	83 ec 1c             	sub    $0x1c,%esp
  801ca7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801caf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cb7:	85 d2                	test   %edx,%edx
  801cb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cc1:	89 f3                	mov    %esi,%ebx
  801cc3:	89 3c 24             	mov    %edi,(%esp)
  801cc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cca:	75 1c                	jne    801ce8 <__umoddi3+0x48>
  801ccc:	39 f7                	cmp    %esi,%edi
  801cce:	76 50                	jbe    801d20 <__umoddi3+0x80>
  801cd0:	89 c8                	mov    %ecx,%eax
  801cd2:	89 f2                	mov    %esi,%edx
  801cd4:	f7 f7                	div    %edi
  801cd6:	89 d0                	mov    %edx,%eax
  801cd8:	31 d2                	xor    %edx,%edx
  801cda:	83 c4 1c             	add    $0x1c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    
  801ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ce8:	39 f2                	cmp    %esi,%edx
  801cea:	89 d0                	mov    %edx,%eax
  801cec:	77 52                	ja     801d40 <__umoddi3+0xa0>
  801cee:	0f bd ea             	bsr    %edx,%ebp
  801cf1:	83 f5 1f             	xor    $0x1f,%ebp
  801cf4:	75 5a                	jne    801d50 <__umoddi3+0xb0>
  801cf6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cfa:	0f 82 e0 00 00 00    	jb     801de0 <__umoddi3+0x140>
  801d00:	39 0c 24             	cmp    %ecx,(%esp)
  801d03:	0f 86 d7 00 00 00    	jbe    801de0 <__umoddi3+0x140>
  801d09:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d11:	83 c4 1c             	add    $0x1c,%esp
  801d14:	5b                   	pop    %ebx
  801d15:	5e                   	pop    %esi
  801d16:	5f                   	pop    %edi
  801d17:	5d                   	pop    %ebp
  801d18:	c3                   	ret    
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	85 ff                	test   %edi,%edi
  801d22:	89 fd                	mov    %edi,%ebp
  801d24:	75 0b                	jne    801d31 <__umoddi3+0x91>
  801d26:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2b:	31 d2                	xor    %edx,%edx
  801d2d:	f7 f7                	div    %edi
  801d2f:	89 c5                	mov    %eax,%ebp
  801d31:	89 f0                	mov    %esi,%eax
  801d33:	31 d2                	xor    %edx,%edx
  801d35:	f7 f5                	div    %ebp
  801d37:	89 c8                	mov    %ecx,%eax
  801d39:	f7 f5                	div    %ebp
  801d3b:	89 d0                	mov    %edx,%eax
  801d3d:	eb 99                	jmp    801cd8 <__umoddi3+0x38>
  801d3f:	90                   	nop
  801d40:	89 c8                	mov    %ecx,%eax
  801d42:	89 f2                	mov    %esi,%edx
  801d44:	83 c4 1c             	add    $0x1c,%esp
  801d47:	5b                   	pop    %ebx
  801d48:	5e                   	pop    %esi
  801d49:	5f                   	pop    %edi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    
  801d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d50:	8b 34 24             	mov    (%esp),%esi
  801d53:	bf 20 00 00 00       	mov    $0x20,%edi
  801d58:	89 e9                	mov    %ebp,%ecx
  801d5a:	29 ef                	sub    %ebp,%edi
  801d5c:	d3 e0                	shl    %cl,%eax
  801d5e:	89 f9                	mov    %edi,%ecx
  801d60:	89 f2                	mov    %esi,%edx
  801d62:	d3 ea                	shr    %cl,%edx
  801d64:	89 e9                	mov    %ebp,%ecx
  801d66:	09 c2                	or     %eax,%edx
  801d68:	89 d8                	mov    %ebx,%eax
  801d6a:	89 14 24             	mov    %edx,(%esp)
  801d6d:	89 f2                	mov    %esi,%edx
  801d6f:	d3 e2                	shl    %cl,%edx
  801d71:	89 f9                	mov    %edi,%ecx
  801d73:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d7b:	d3 e8                	shr    %cl,%eax
  801d7d:	89 e9                	mov    %ebp,%ecx
  801d7f:	89 c6                	mov    %eax,%esi
  801d81:	d3 e3                	shl    %cl,%ebx
  801d83:	89 f9                	mov    %edi,%ecx
  801d85:	89 d0                	mov    %edx,%eax
  801d87:	d3 e8                	shr    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	09 d8                	or     %ebx,%eax
  801d8d:	89 d3                	mov    %edx,%ebx
  801d8f:	89 f2                	mov    %esi,%edx
  801d91:	f7 34 24             	divl   (%esp)
  801d94:	89 d6                	mov    %edx,%esi
  801d96:	d3 e3                	shl    %cl,%ebx
  801d98:	f7 64 24 04          	mull   0x4(%esp)
  801d9c:	39 d6                	cmp    %edx,%esi
  801d9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801da2:	89 d1                	mov    %edx,%ecx
  801da4:	89 c3                	mov    %eax,%ebx
  801da6:	72 08                	jb     801db0 <__umoddi3+0x110>
  801da8:	75 11                	jne    801dbb <__umoddi3+0x11b>
  801daa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dae:	73 0b                	jae    801dbb <__umoddi3+0x11b>
  801db0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801db4:	1b 14 24             	sbb    (%esp),%edx
  801db7:	89 d1                	mov    %edx,%ecx
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dbf:	29 da                	sub    %ebx,%edx
  801dc1:	19 ce                	sbb    %ecx,%esi
  801dc3:	89 f9                	mov    %edi,%ecx
  801dc5:	89 f0                	mov    %esi,%eax
  801dc7:	d3 e0                	shl    %cl,%eax
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	d3 ea                	shr    %cl,%edx
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	d3 ee                	shr    %cl,%esi
  801dd1:	09 d0                	or     %edx,%eax
  801dd3:	89 f2                	mov    %esi,%edx
  801dd5:	83 c4 1c             	add    $0x1c,%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5e                   	pop    %esi
  801dda:	5f                   	pop    %edi
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    
  801ddd:	8d 76 00             	lea    0x0(%esi),%esi
  801de0:	29 f9                	sub    %edi,%ecx
  801de2:	19 d6                	sbb    %edx,%esi
  801de4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801de8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dec:	e9 18 ff ff ff       	jmp    801d09 <__umoddi3+0x69>
