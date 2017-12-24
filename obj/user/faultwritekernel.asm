
obj/user/faultwritekernel.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	57                   	push   %edi
  800046:	56                   	push   %esi
  800047:	53                   	push   %ebx
  800048:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004b:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800052:	00 00 00 

	envid_t cur_env_id = sys_getenvid(); 
  800055:	e8 0e 01 00 00       	call   800168 <sys_getenvid>
  80005a:	8b 3d 04 40 80 00    	mov    0x804004,%edi
  800060:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800065:	be 00 00 00 00       	mov    $0x0,%esi
	size_t i;
	for (i = 0; i < NENV; i++) {
  80006a:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == cur_env_id) {
  80006f:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800072:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800078:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &envs[i];
  80007b:	39 c8                	cmp    %ecx,%eax
  80007d:	0f 44 fb             	cmove  %ebx,%edi
  800080:	b9 01 00 00 00       	mov    $0x1,%ecx
  800085:	0f 44 f1             	cmove  %ecx,%esi
	// LAB 3: Your code here.
	thisenv = 0;

	envid_t cur_env_id = sys_getenvid(); 
	size_t i;
	for (i = 0; i < NENV; i++) {
  800088:	83 c2 01             	add    $0x1,%edx
  80008b:	83 c3 7c             	add    $0x7c,%ebx
  80008e:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800094:	75 d9                	jne    80006f <libmain+0x2d>
  800096:	89 f0                	mov    %esi,%eax
  800098:	84 c0                	test   %al,%al
  80009a:	74 06                	je     8000a2 <libmain+0x60>
  80009c:	89 3d 04 40 80 00    	mov    %edi,0x804004
			thisenv = &envs[i];
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000a6:	7e 0a                	jle    8000b2 <libmain+0x70>
		binaryname = argv[0];
  8000a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ab:	8b 00                	mov    (%eax),%eax
  8000ad:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b2:	83 ec 08             	sub    $0x8,%esp
  8000b5:	ff 75 0c             	pushl  0xc(%ebp)
  8000b8:	ff 75 08             	pushl  0x8(%ebp)
  8000bb:	e8 73 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c0:	e8 0b 00 00 00       	call   8000d0 <exit>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cb:	5b                   	pop    %ebx
  8000cc:	5e                   	pop    %esi
  8000cd:	5f                   	pop    %edi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d6:	e8 87 04 00 00       	call   800562 <close_all>
	sys_env_destroy(0);
  8000db:	83 ec 0c             	sub    $0xc,%esp
  8000de:	6a 00                	push   $0x0
  8000e0:	e8 42 00 00 00       	call   800127 <sys_env_destroy>
}
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    

008000ea <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	89 c3                	mov    %eax,%ebx
  8000fd:	89 c7                	mov    %eax,%edi
  8000ff:	89 c6                	mov    %eax,%esi
  800101:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5f                   	pop    %edi
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    

00800108 <sys_cgetc>:

int
sys_cgetc(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	57                   	push   %edi
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010e:	ba 00 00 00 00       	mov    $0x0,%edx
  800113:	b8 01 00 00 00       	mov    $0x1,%eax
  800118:	89 d1                	mov    %edx,%ecx
  80011a:	89 d3                	mov    %edx,%ebx
  80011c:	89 d7                	mov    %edx,%edi
  80011e:	89 d6                	mov    %edx,%esi
  800120:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
  80012d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	b9 00 00 00 00       	mov    $0x0,%ecx
  800135:	b8 03 00 00 00       	mov    $0x3,%eax
  80013a:	8b 55 08             	mov    0x8(%ebp),%edx
  80013d:	89 cb                	mov    %ecx,%ebx
  80013f:	89 cf                	mov    %ecx,%edi
  800141:	89 ce                	mov    %ecx,%esi
  800143:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800145:	85 c0                	test   %eax,%eax
  800147:	7e 17                	jle    800160 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	50                   	push   %eax
  80014d:	6a 03                	push   $0x3
  80014f:	68 0a 1e 80 00       	push   $0x801e0a
  800154:	6a 23                	push   $0x23
  800156:	68 27 1e 80 00       	push   $0x801e27
  80015b:	e8 21 0f 00 00       	call   801081 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016e:	ba 00 00 00 00       	mov    $0x0,%edx
  800173:	b8 02 00 00 00       	mov    $0x2,%eax
  800178:	89 d1                	mov    %edx,%ecx
  80017a:	89 d3                	mov    %edx,%ebx
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	89 d6                	mov    %edx,%esi
  800180:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5f                   	pop    %edi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <sys_yield>:

void
sys_yield(void)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018d:	ba 00 00 00 00       	mov    $0x0,%edx
  800192:	b8 0b 00 00 00       	mov    $0xb,%eax
  800197:	89 d1                	mov    %edx,%ecx
  800199:	89 d3                	mov    %edx,%ebx
  80019b:	89 d7                	mov    %edx,%edi
  80019d:	89 d6                	mov    %edx,%esi
  80019f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	be 00 00 00 00       	mov    $0x0,%esi
  8001b4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	89 f7                	mov    %esi,%edi
  8001c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	7e 17                	jle    8001e1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	50                   	push   %eax
  8001ce:	6a 04                	push   $0x4
  8001d0:	68 0a 1e 80 00       	push   $0x801e0a
  8001d5:	6a 23                	push   $0x23
  8001d7:	68 27 1e 80 00       	push   $0x801e27
  8001dc:	e8 a0 0e 00 00       	call   801081 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5e                   	pop    %esi
  8001e6:	5f                   	pop    %edi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    

008001e9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	57                   	push   %edi
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800200:	8b 7d 14             	mov    0x14(%ebp),%edi
  800203:	8b 75 18             	mov    0x18(%ebp),%esi
  800206:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800208:	85 c0                	test   %eax,%eax
  80020a:	7e 17                	jle    800223 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	50                   	push   %eax
  800210:	6a 05                	push   $0x5
  800212:	68 0a 1e 80 00       	push   $0x801e0a
  800217:	6a 23                	push   $0x23
  800219:	68 27 1e 80 00       	push   $0x801e27
  80021e:	e8 5e 0e 00 00       	call   801081 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5f                   	pop    %edi
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800234:	bb 00 00 00 00       	mov    $0x0,%ebx
  800239:	b8 06 00 00 00       	mov    $0x6,%eax
  80023e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800241:	8b 55 08             	mov    0x8(%ebp),%edx
  800244:	89 df                	mov    %ebx,%edi
  800246:	89 de                	mov    %ebx,%esi
  800248:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024a:	85 c0                	test   %eax,%eax
  80024c:	7e 17                	jle    800265 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	50                   	push   %eax
  800252:	6a 06                	push   $0x6
  800254:	68 0a 1e 80 00       	push   $0x801e0a
  800259:	6a 23                	push   $0x23
  80025b:	68 27 1e 80 00       	push   $0x801e27
  800260:	e8 1c 0e 00 00       	call   801081 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800265:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800268:	5b                   	pop    %ebx
  800269:	5e                   	pop    %esi
  80026a:	5f                   	pop    %edi
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	57                   	push   %edi
  800271:	56                   	push   %esi
  800272:	53                   	push   %ebx
  800273:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800276:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027b:	b8 08 00 00 00       	mov    $0x8,%eax
  800280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
  800286:	89 df                	mov    %ebx,%edi
  800288:	89 de                	mov    %ebx,%esi
  80028a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028c:	85 c0                	test   %eax,%eax
  80028e:	7e 17                	jle    8002a7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800290:	83 ec 0c             	sub    $0xc,%esp
  800293:	50                   	push   %eax
  800294:	6a 08                	push   $0x8
  800296:	68 0a 1e 80 00       	push   $0x801e0a
  80029b:	6a 23                	push   $0x23
  80029d:	68 27 1e 80 00       	push   $0x801e27
  8002a2:	e8 da 0d 00 00       	call   801081 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bd:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	89 df                	mov    %ebx,%edi
  8002ca:	89 de                	mov    %ebx,%esi
  8002cc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7e 17                	jle    8002e9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d2:	83 ec 0c             	sub    $0xc,%esp
  8002d5:	50                   	push   %eax
  8002d6:	6a 09                	push   $0x9
  8002d8:	68 0a 1e 80 00       	push   $0x801e0a
  8002dd:	6a 23                	push   $0x23
  8002df:	68 27 1e 80 00       	push   $0x801e27
  8002e4:	e8 98 0d 00 00       	call   801081 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	57                   	push   %edi
  8002f5:	56                   	push   %esi
  8002f6:	53                   	push   %ebx
  8002f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800307:	8b 55 08             	mov    0x8(%ebp),%edx
  80030a:	89 df                	mov    %ebx,%edi
  80030c:	89 de                	mov    %ebx,%esi
  80030e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800310:	85 c0                	test   %eax,%eax
  800312:	7e 17                	jle    80032b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	50                   	push   %eax
  800318:	6a 0a                	push   $0xa
  80031a:	68 0a 1e 80 00       	push   $0x801e0a
  80031f:	6a 23                	push   $0x23
  800321:	68 27 1e 80 00       	push   $0x801e27
  800326:	e8 56 0d 00 00       	call   801081 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80032b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032e:	5b                   	pop    %ebx
  80032f:	5e                   	pop    %esi
  800330:	5f                   	pop    %edi
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    

00800333 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	57                   	push   %edi
  800337:	56                   	push   %esi
  800338:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800339:	be 00 00 00 00       	mov    $0x0,%esi
  80033e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800343:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800346:	8b 55 08             	mov    0x8(%ebp),%edx
  800349:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80034f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	57                   	push   %edi
  80035a:	56                   	push   %esi
  80035b:	53                   	push   %ebx
  80035c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800364:	b8 0d 00 00 00       	mov    $0xd,%eax
  800369:	8b 55 08             	mov    0x8(%ebp),%edx
  80036c:	89 cb                	mov    %ecx,%ebx
  80036e:	89 cf                	mov    %ecx,%edi
  800370:	89 ce                	mov    %ecx,%esi
  800372:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	7e 17                	jle    80038f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800378:	83 ec 0c             	sub    $0xc,%esp
  80037b:	50                   	push   %eax
  80037c:	6a 0d                	push   $0xd
  80037e:	68 0a 1e 80 00       	push   $0x801e0a
  800383:	6a 23                	push   $0x23
  800385:	68 27 1e 80 00       	push   $0x801e27
  80038a:	e8 f2 0c 00 00       	call   801081 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a2:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003bc:	5d                   	pop    %ebp
  8003bd:	c3                   	ret    

008003be <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c9:	89 c2                	mov    %eax,%edx
  8003cb:	c1 ea 16             	shr    $0x16,%edx
  8003ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d5:	f6 c2 01             	test   $0x1,%dl
  8003d8:	74 11                	je     8003eb <fd_alloc+0x2d>
  8003da:	89 c2                	mov    %eax,%edx
  8003dc:	c1 ea 0c             	shr    $0xc,%edx
  8003df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e6:	f6 c2 01             	test   $0x1,%dl
  8003e9:	75 09                	jne    8003f4 <fd_alloc+0x36>
			*fd_store = fd;
  8003eb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f2:	eb 17                	jmp    80040b <fd_alloc+0x4d>
  8003f4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003fe:	75 c9                	jne    8003c9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800400:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800406:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800413:	83 f8 1f             	cmp    $0x1f,%eax
  800416:	77 36                	ja     80044e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800418:	c1 e0 0c             	shl    $0xc,%eax
  80041b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800420:	89 c2                	mov    %eax,%edx
  800422:	c1 ea 16             	shr    $0x16,%edx
  800425:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042c:	f6 c2 01             	test   $0x1,%dl
  80042f:	74 24                	je     800455 <fd_lookup+0x48>
  800431:	89 c2                	mov    %eax,%edx
  800433:	c1 ea 0c             	shr    $0xc,%edx
  800436:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043d:	f6 c2 01             	test   $0x1,%dl
  800440:	74 1a                	je     80045c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800442:	8b 55 0c             	mov    0xc(%ebp),%edx
  800445:	89 02                	mov    %eax,(%edx)
	return 0;
  800447:	b8 00 00 00 00       	mov    $0x0,%eax
  80044c:	eb 13                	jmp    800461 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800453:	eb 0c                	jmp    800461 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045a:	eb 05                	jmp    800461 <fd_lookup+0x54>
  80045c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800461:	5d                   	pop    %ebp
  800462:	c3                   	ret    

00800463 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80046c:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800471:	eb 13                	jmp    800486 <dev_lookup+0x23>
  800473:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800476:	39 08                	cmp    %ecx,(%eax)
  800478:	75 0c                	jne    800486 <dev_lookup+0x23>
			*dev = devtab[i];
  80047a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80047d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80047f:	b8 00 00 00 00       	mov    $0x0,%eax
  800484:	eb 2e                	jmp    8004b4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800486:	8b 02                	mov    (%edx),%eax
  800488:	85 c0                	test   %eax,%eax
  80048a:	75 e7                	jne    800473 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80048c:	a1 04 40 80 00       	mov    0x804004,%eax
  800491:	8b 40 48             	mov    0x48(%eax),%eax
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	51                   	push   %ecx
  800498:	50                   	push   %eax
  800499:	68 38 1e 80 00       	push   $0x801e38
  80049e:	e8 b7 0c 00 00       	call   80115a <cprintf>
	*dev = 0;
  8004a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b4:	c9                   	leave  
  8004b5:	c3                   	ret    

008004b6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	56                   	push   %esi
  8004ba:	53                   	push   %ebx
  8004bb:	83 ec 10             	sub    $0x10,%esp
  8004be:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c7:	50                   	push   %eax
  8004c8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ce:	c1 e8 0c             	shr    $0xc,%eax
  8004d1:	50                   	push   %eax
  8004d2:	e8 36 ff ff ff       	call   80040d <fd_lookup>
  8004d7:	83 c4 08             	add    $0x8,%esp
  8004da:	85 c0                	test   %eax,%eax
  8004dc:	78 05                	js     8004e3 <fd_close+0x2d>
	    || fd != fd2)
  8004de:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e1:	74 0c                	je     8004ef <fd_close+0x39>
		return (must_exist ? r : 0);
  8004e3:	84 db                	test   %bl,%bl
  8004e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ea:	0f 44 c2             	cmove  %edx,%eax
  8004ed:	eb 41                	jmp    800530 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f5:	50                   	push   %eax
  8004f6:	ff 36                	pushl  (%esi)
  8004f8:	e8 66 ff ff ff       	call   800463 <dev_lookup>
  8004fd:	89 c3                	mov    %eax,%ebx
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	85 c0                	test   %eax,%eax
  800504:	78 1a                	js     800520 <fd_close+0x6a>
		if (dev->dev_close)
  800506:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800509:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80050c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800511:	85 c0                	test   %eax,%eax
  800513:	74 0b                	je     800520 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800515:	83 ec 0c             	sub    $0xc,%esp
  800518:	56                   	push   %esi
  800519:	ff d0                	call   *%eax
  80051b:	89 c3                	mov    %eax,%ebx
  80051d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	56                   	push   %esi
  800524:	6a 00                	push   $0x0
  800526:	e8 00 fd ff ff       	call   80022b <sys_page_unmap>
	return r;
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	89 d8                	mov    %ebx,%eax
}
  800530:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800533:	5b                   	pop    %ebx
  800534:	5e                   	pop    %esi
  800535:	5d                   	pop    %ebp
  800536:	c3                   	ret    

00800537 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80053d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800540:	50                   	push   %eax
  800541:	ff 75 08             	pushl  0x8(%ebp)
  800544:	e8 c4 fe ff ff       	call   80040d <fd_lookup>
  800549:	83 c4 08             	add    $0x8,%esp
  80054c:	85 c0                	test   %eax,%eax
  80054e:	78 10                	js     800560 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	6a 01                	push   $0x1
  800555:	ff 75 f4             	pushl  -0xc(%ebp)
  800558:	e8 59 ff ff ff       	call   8004b6 <fd_close>
  80055d:	83 c4 10             	add    $0x10,%esp
}
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <close_all>:

void
close_all(void)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	53                   	push   %ebx
  800566:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800569:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	53                   	push   %ebx
  800572:	e8 c0 ff ff ff       	call   800537 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800577:	83 c3 01             	add    $0x1,%ebx
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	83 fb 20             	cmp    $0x20,%ebx
  800580:	75 ec                	jne    80056e <close_all+0xc>
		close(i);
}
  800582:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800585:	c9                   	leave  
  800586:	c3                   	ret    

00800587 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800587:	55                   	push   %ebp
  800588:	89 e5                	mov    %esp,%ebp
  80058a:	57                   	push   %edi
  80058b:	56                   	push   %esi
  80058c:	53                   	push   %ebx
  80058d:	83 ec 2c             	sub    $0x2c,%esp
  800590:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800593:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800596:	50                   	push   %eax
  800597:	ff 75 08             	pushl  0x8(%ebp)
  80059a:	e8 6e fe ff ff       	call   80040d <fd_lookup>
  80059f:	83 c4 08             	add    $0x8,%esp
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	0f 88 c1 00 00 00    	js     80066b <dup+0xe4>
		return r;
	close(newfdnum);
  8005aa:	83 ec 0c             	sub    $0xc,%esp
  8005ad:	56                   	push   %esi
  8005ae:	e8 84 ff ff ff       	call   800537 <close>

	newfd = INDEX2FD(newfdnum);
  8005b3:	89 f3                	mov    %esi,%ebx
  8005b5:	c1 e3 0c             	shl    $0xc,%ebx
  8005b8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005be:	83 c4 04             	add    $0x4,%esp
  8005c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c4:	e8 de fd ff ff       	call   8003a7 <fd2data>
  8005c9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005cb:	89 1c 24             	mov    %ebx,(%esp)
  8005ce:	e8 d4 fd ff ff       	call   8003a7 <fd2data>
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d9:	89 f8                	mov    %edi,%eax
  8005db:	c1 e8 16             	shr    $0x16,%eax
  8005de:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e5:	a8 01                	test   $0x1,%al
  8005e7:	74 37                	je     800620 <dup+0x99>
  8005e9:	89 f8                	mov    %edi,%eax
  8005eb:	c1 e8 0c             	shr    $0xc,%eax
  8005ee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f5:	f6 c2 01             	test   $0x1,%dl
  8005f8:	74 26                	je     800620 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	25 07 0e 00 00       	and    $0xe07,%eax
  800609:	50                   	push   %eax
  80060a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060d:	6a 00                	push   $0x0
  80060f:	57                   	push   %edi
  800610:	6a 00                	push   $0x0
  800612:	e8 d2 fb ff ff       	call   8001e9 <sys_page_map>
  800617:	89 c7                	mov    %eax,%edi
  800619:	83 c4 20             	add    $0x20,%esp
  80061c:	85 c0                	test   %eax,%eax
  80061e:	78 2e                	js     80064e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800620:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800623:	89 d0                	mov    %edx,%eax
  800625:	c1 e8 0c             	shr    $0xc,%eax
  800628:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062f:	83 ec 0c             	sub    $0xc,%esp
  800632:	25 07 0e 00 00       	and    $0xe07,%eax
  800637:	50                   	push   %eax
  800638:	53                   	push   %ebx
  800639:	6a 00                	push   $0x0
  80063b:	52                   	push   %edx
  80063c:	6a 00                	push   $0x0
  80063e:	e8 a6 fb ff ff       	call   8001e9 <sys_page_map>
  800643:	89 c7                	mov    %eax,%edi
  800645:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800648:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80064a:	85 ff                	test   %edi,%edi
  80064c:	79 1d                	jns    80066b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	53                   	push   %ebx
  800652:	6a 00                	push   $0x0
  800654:	e8 d2 fb ff ff       	call   80022b <sys_page_unmap>
	sys_page_unmap(0, nva);
  800659:	83 c4 08             	add    $0x8,%esp
  80065c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065f:	6a 00                	push   $0x0
  800661:	e8 c5 fb ff ff       	call   80022b <sys_page_unmap>
	return r;
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	89 f8                	mov    %edi,%eax
}
  80066b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066e:	5b                   	pop    %ebx
  80066f:	5e                   	pop    %esi
  800670:	5f                   	pop    %edi
  800671:	5d                   	pop    %ebp
  800672:	c3                   	ret    

00800673 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	53                   	push   %ebx
  800677:	83 ec 14             	sub    $0x14,%esp
  80067a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80067d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800680:	50                   	push   %eax
  800681:	53                   	push   %ebx
  800682:	e8 86 fd ff ff       	call   80040d <fd_lookup>
  800687:	83 c4 08             	add    $0x8,%esp
  80068a:	89 c2                	mov    %eax,%edx
  80068c:	85 c0                	test   %eax,%eax
  80068e:	78 6d                	js     8006fd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800696:	50                   	push   %eax
  800697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069a:	ff 30                	pushl  (%eax)
  80069c:	e8 c2 fd ff ff       	call   800463 <dev_lookup>
  8006a1:	83 c4 10             	add    $0x10,%esp
  8006a4:	85 c0                	test   %eax,%eax
  8006a6:	78 4c                	js     8006f4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006ab:	8b 42 08             	mov    0x8(%edx),%eax
  8006ae:	83 e0 03             	and    $0x3,%eax
  8006b1:	83 f8 01             	cmp    $0x1,%eax
  8006b4:	75 21                	jne    8006d7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8006bb:	8b 40 48             	mov    0x48(%eax),%eax
  8006be:	83 ec 04             	sub    $0x4,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	50                   	push   %eax
  8006c3:	68 79 1e 80 00       	push   $0x801e79
  8006c8:	e8 8d 0a 00 00       	call   80115a <cprintf>
		return -E_INVAL;
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006d5:	eb 26                	jmp    8006fd <read+0x8a>
	}
	if (!dev->dev_read)
  8006d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006da:	8b 40 08             	mov    0x8(%eax),%eax
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	74 17                	je     8006f8 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8006e1:	83 ec 04             	sub    $0x4,%esp
  8006e4:	ff 75 10             	pushl  0x10(%ebp)
  8006e7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ea:	52                   	push   %edx
  8006eb:	ff d0                	call   *%eax
  8006ed:	89 c2                	mov    %eax,%edx
  8006ef:	83 c4 10             	add    $0x10,%esp
  8006f2:	eb 09                	jmp    8006fd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f4:	89 c2                	mov    %eax,%edx
  8006f6:	eb 05                	jmp    8006fd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  8006fd:	89 d0                	mov    %edx,%eax
  8006ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	57                   	push   %edi
  800708:	56                   	push   %esi
  800709:	53                   	push   %ebx
  80070a:	83 ec 0c             	sub    $0xc,%esp
  80070d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800710:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800713:	bb 00 00 00 00       	mov    $0x0,%ebx
  800718:	eb 21                	jmp    80073b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80071a:	83 ec 04             	sub    $0x4,%esp
  80071d:	89 f0                	mov    %esi,%eax
  80071f:	29 d8                	sub    %ebx,%eax
  800721:	50                   	push   %eax
  800722:	89 d8                	mov    %ebx,%eax
  800724:	03 45 0c             	add    0xc(%ebp),%eax
  800727:	50                   	push   %eax
  800728:	57                   	push   %edi
  800729:	e8 45 ff ff ff       	call   800673 <read>
		if (m < 0)
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	85 c0                	test   %eax,%eax
  800733:	78 10                	js     800745 <readn+0x41>
			return m;
		if (m == 0)
  800735:	85 c0                	test   %eax,%eax
  800737:	74 0a                	je     800743 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800739:	01 c3                	add    %eax,%ebx
  80073b:	39 f3                	cmp    %esi,%ebx
  80073d:	72 db                	jb     80071a <readn+0x16>
  80073f:	89 d8                	mov    %ebx,%eax
  800741:	eb 02                	jmp    800745 <readn+0x41>
  800743:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800745:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800748:	5b                   	pop    %ebx
  800749:	5e                   	pop    %esi
  80074a:	5f                   	pop    %edi
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	53                   	push   %ebx
  800751:	83 ec 14             	sub    $0x14,%esp
  800754:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800757:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80075a:	50                   	push   %eax
  80075b:	53                   	push   %ebx
  80075c:	e8 ac fc ff ff       	call   80040d <fd_lookup>
  800761:	83 c4 08             	add    $0x8,%esp
  800764:	89 c2                	mov    %eax,%edx
  800766:	85 c0                	test   %eax,%eax
  800768:	78 68                	js     8007d2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80076a:	83 ec 08             	sub    $0x8,%esp
  80076d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800770:	50                   	push   %eax
  800771:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800774:	ff 30                	pushl  (%eax)
  800776:	e8 e8 fc ff ff       	call   800463 <dev_lookup>
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	85 c0                	test   %eax,%eax
  800780:	78 47                	js     8007c9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800782:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800785:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800789:	75 21                	jne    8007ac <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80078b:	a1 04 40 80 00       	mov    0x804004,%eax
  800790:	8b 40 48             	mov    0x48(%eax),%eax
  800793:	83 ec 04             	sub    $0x4,%esp
  800796:	53                   	push   %ebx
  800797:	50                   	push   %eax
  800798:	68 95 1e 80 00       	push   $0x801e95
  80079d:	e8 b8 09 00 00       	call   80115a <cprintf>
		return -E_INVAL;
  8007a2:	83 c4 10             	add    $0x10,%esp
  8007a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007aa:	eb 26                	jmp    8007d2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007af:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b2:	85 d2                	test   %edx,%edx
  8007b4:	74 17                	je     8007cd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b6:	83 ec 04             	sub    $0x4,%esp
  8007b9:	ff 75 10             	pushl  0x10(%ebp)
  8007bc:	ff 75 0c             	pushl  0xc(%ebp)
  8007bf:	50                   	push   %eax
  8007c0:	ff d2                	call   *%edx
  8007c2:	89 c2                	mov    %eax,%edx
  8007c4:	83 c4 10             	add    $0x10,%esp
  8007c7:	eb 09                	jmp    8007d2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	eb 05                	jmp    8007d2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007d2:	89 d0                	mov    %edx,%eax
  8007d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007df:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	ff 75 08             	pushl  0x8(%ebp)
  8007e6:	e8 22 fc ff ff       	call   80040d <fd_lookup>
  8007eb:	83 c4 08             	add    $0x8,%esp
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	78 0e                	js     800800 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	53                   	push   %ebx
  800806:	83 ec 14             	sub    $0x14,%esp
  800809:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080f:	50                   	push   %eax
  800810:	53                   	push   %ebx
  800811:	e8 f7 fb ff ff       	call   80040d <fd_lookup>
  800816:	83 c4 08             	add    $0x8,%esp
  800819:	89 c2                	mov    %eax,%edx
  80081b:	85 c0                	test   %eax,%eax
  80081d:	78 65                	js     800884 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800825:	50                   	push   %eax
  800826:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800829:	ff 30                	pushl  (%eax)
  80082b:	e8 33 fc ff ff       	call   800463 <dev_lookup>
  800830:	83 c4 10             	add    $0x10,%esp
  800833:	85 c0                	test   %eax,%eax
  800835:	78 44                	js     80087b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80083e:	75 21                	jne    800861 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800840:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800845:	8b 40 48             	mov    0x48(%eax),%eax
  800848:	83 ec 04             	sub    $0x4,%esp
  80084b:	53                   	push   %ebx
  80084c:	50                   	push   %eax
  80084d:	68 58 1e 80 00       	push   $0x801e58
  800852:	e8 03 09 00 00       	call   80115a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800857:	83 c4 10             	add    $0x10,%esp
  80085a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80085f:	eb 23                	jmp    800884 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800861:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800864:	8b 52 18             	mov    0x18(%edx),%edx
  800867:	85 d2                	test   %edx,%edx
  800869:	74 14                	je     80087f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	ff 75 0c             	pushl  0xc(%ebp)
  800871:	50                   	push   %eax
  800872:	ff d2                	call   *%edx
  800874:	89 c2                	mov    %eax,%edx
  800876:	83 c4 10             	add    $0x10,%esp
  800879:	eb 09                	jmp    800884 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087b:	89 c2                	mov    %eax,%edx
  80087d:	eb 05                	jmp    800884 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80087f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800884:	89 d0                	mov    %edx,%eax
  800886:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800889:	c9                   	leave  
  80088a:	c3                   	ret    

0080088b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	83 ec 14             	sub    $0x14,%esp
  800892:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800895:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800898:	50                   	push   %eax
  800899:	ff 75 08             	pushl  0x8(%ebp)
  80089c:	e8 6c fb ff ff       	call   80040d <fd_lookup>
  8008a1:	83 c4 08             	add    $0x8,%esp
  8008a4:	89 c2                	mov    %eax,%edx
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	78 58                	js     800902 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008aa:	83 ec 08             	sub    $0x8,%esp
  8008ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b0:	50                   	push   %eax
  8008b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b4:	ff 30                	pushl  (%eax)
  8008b6:	e8 a8 fb ff ff       	call   800463 <dev_lookup>
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	78 37                	js     8008f9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c9:	74 32                	je     8008fd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008cb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ce:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d5:	00 00 00 
	stat->st_isdir = 0;
  8008d8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008df:	00 00 00 
	stat->st_dev = dev;
  8008e2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	53                   	push   %ebx
  8008ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ef:	ff 50 14             	call   *0x14(%eax)
  8008f2:	89 c2                	mov    %eax,%edx
  8008f4:	83 c4 10             	add    $0x10,%esp
  8008f7:	eb 09                	jmp    800902 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f9:	89 c2                	mov    %eax,%edx
  8008fb:	eb 05                	jmp    800902 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800902:	89 d0                	mov    %edx,%eax
  800904:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800907:	c9                   	leave  
  800908:	c3                   	ret    

00800909 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	56                   	push   %esi
  80090d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	6a 00                	push   $0x0
  800913:	ff 75 08             	pushl  0x8(%ebp)
  800916:	e8 e3 01 00 00       	call   800afe <open>
  80091b:	89 c3                	mov    %eax,%ebx
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	85 c0                	test   %eax,%eax
  800922:	78 1b                	js     80093f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	ff 75 0c             	pushl  0xc(%ebp)
  80092a:	50                   	push   %eax
  80092b:	e8 5b ff ff ff       	call   80088b <fstat>
  800930:	89 c6                	mov    %eax,%esi
	close(fd);
  800932:	89 1c 24             	mov    %ebx,(%esp)
  800935:	e8 fd fb ff ff       	call   800537 <close>
	return r;
  80093a:	83 c4 10             	add    $0x10,%esp
  80093d:	89 f0                	mov    %esi,%eax
}
  80093f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	56                   	push   %esi
  80094a:	53                   	push   %ebx
  80094b:	89 c6                	mov    %eax,%esi
  80094d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80094f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800956:	75 12                	jne    80096a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800958:	83 ec 0c             	sub    $0xc,%esp
  80095b:	6a 01                	push   $0x1
  80095d:	e8 98 11 00 00       	call   801afa <ipc_find_env>
  800962:	a3 00 40 80 00       	mov    %eax,0x804000
  800967:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80096a:	6a 07                	push   $0x7
  80096c:	68 00 50 80 00       	push   $0x805000
  800971:	56                   	push   %esi
  800972:	ff 35 00 40 80 00    	pushl  0x804000
  800978:	e8 1b 11 00 00       	call   801a98 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80097d:	83 c4 0c             	add    $0xc,%esp
  800980:	6a 00                	push   $0x0
  800982:	53                   	push   %ebx
  800983:	6a 00                	push   $0x0
  800985:	e8 9c 10 00 00       	call   801a26 <ipc_recv>
}
  80098a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b4:	e8 8d ff ff ff       	call   800946 <fsipc>
}
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d6:	e8 6b ff ff ff       	call   800946 <fsipc>
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	53                   	push   %ebx
  8009e1:	83 ec 04             	sub    $0x4,%esp
  8009e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ed:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009fc:	e8 45 ff ff ff       	call   800946 <fsipc>
  800a01:	85 c0                	test   %eax,%eax
  800a03:	78 2c                	js     800a31 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a05:	83 ec 08             	sub    $0x8,%esp
  800a08:	68 00 50 80 00       	push   $0x805000
  800a0d:	53                   	push   %ebx
  800a0e:	e8 cc 0c 00 00       	call   8016df <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a13:	a1 80 50 80 00       	mov    0x805080,%eax
  800a18:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a1e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a23:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a29:	83 c4 10             	add    $0x10,%esp
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	83 ec 0c             	sub    $0xc,%esp
  800a3c:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a42:	8b 52 0c             	mov    0xc(%edx),%edx
  800a45:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800a4b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a50:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a55:	0f 47 c2             	cmova  %edx,%eax
  800a58:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a5d:	50                   	push   %eax
  800a5e:	ff 75 0c             	pushl  0xc(%ebp)
  800a61:	68 08 50 80 00       	push   $0x805008
  800a66:	e8 06 0e 00 00       	call   801871 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a70:	b8 04 00 00 00       	mov    $0x4,%eax
  800a75:	e8 cc fe ff ff       	call   800946 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a95:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9f:	e8 a2 fe ff ff       	call   800946 <fsipc>
  800aa4:	89 c3                	mov    %eax,%ebx
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	78 4b                	js     800af5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aaa:	39 c6                	cmp    %eax,%esi
  800aac:	73 16                	jae    800ac4 <devfile_read+0x48>
  800aae:	68 c4 1e 80 00       	push   $0x801ec4
  800ab3:	68 cb 1e 80 00       	push   $0x801ecb
  800ab8:	6a 7c                	push   $0x7c
  800aba:	68 e0 1e 80 00       	push   $0x801ee0
  800abf:	e8 bd 05 00 00       	call   801081 <_panic>
	assert(r <= PGSIZE);
  800ac4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac9:	7e 16                	jle    800ae1 <devfile_read+0x65>
  800acb:	68 eb 1e 80 00       	push   $0x801eeb
  800ad0:	68 cb 1e 80 00       	push   $0x801ecb
  800ad5:	6a 7d                	push   $0x7d
  800ad7:	68 e0 1e 80 00       	push   $0x801ee0
  800adc:	e8 a0 05 00 00       	call   801081 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae1:	83 ec 04             	sub    $0x4,%esp
  800ae4:	50                   	push   %eax
  800ae5:	68 00 50 80 00       	push   $0x805000
  800aea:	ff 75 0c             	pushl  0xc(%ebp)
  800aed:	e8 7f 0d 00 00       	call   801871 <memmove>
	return r;
  800af2:	83 c4 10             	add    $0x10,%esp
}
  800af5:	89 d8                	mov    %ebx,%eax
  800af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	53                   	push   %ebx
  800b02:	83 ec 20             	sub    $0x20,%esp
  800b05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b08:	53                   	push   %ebx
  800b09:	e8 98 0b 00 00       	call   8016a6 <strlen>
  800b0e:	83 c4 10             	add    $0x10,%esp
  800b11:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b16:	7f 67                	jg     800b7f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b18:	83 ec 0c             	sub    $0xc,%esp
  800b1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1e:	50                   	push   %eax
  800b1f:	e8 9a f8 ff ff       	call   8003be <fd_alloc>
  800b24:	83 c4 10             	add    $0x10,%esp
		return r;
  800b27:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	78 57                	js     800b84 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b2d:	83 ec 08             	sub    $0x8,%esp
  800b30:	53                   	push   %ebx
  800b31:	68 00 50 80 00       	push   $0x805000
  800b36:	e8 a4 0b 00 00       	call   8016df <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b43:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b46:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4b:	e8 f6 fd ff ff       	call   800946 <fsipc>
  800b50:	89 c3                	mov    %eax,%ebx
  800b52:	83 c4 10             	add    $0x10,%esp
  800b55:	85 c0                	test   %eax,%eax
  800b57:	79 14                	jns    800b6d <open+0x6f>
		fd_close(fd, 0);
  800b59:	83 ec 08             	sub    $0x8,%esp
  800b5c:	6a 00                	push   $0x0
  800b5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b61:	e8 50 f9 ff ff       	call   8004b6 <fd_close>
		return r;
  800b66:	83 c4 10             	add    $0x10,%esp
  800b69:	89 da                	mov    %ebx,%edx
  800b6b:	eb 17                	jmp    800b84 <open+0x86>
	}

	return fd2num(fd);
  800b6d:	83 ec 0c             	sub    $0xc,%esp
  800b70:	ff 75 f4             	pushl  -0xc(%ebp)
  800b73:	e8 1f f8 ff ff       	call   800397 <fd2num>
  800b78:	89 c2                	mov    %eax,%edx
  800b7a:	83 c4 10             	add    $0x10,%esp
  800b7d:	eb 05                	jmp    800b84 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b84:	89 d0                	mov    %edx,%eax
  800b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b91:	ba 00 00 00 00       	mov    $0x0,%edx
  800b96:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9b:	e8 a6 fd ff ff       	call   800946 <fsipc>
}
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
  800ba7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	ff 75 08             	pushl  0x8(%ebp)
  800bb0:	e8 f2 f7 ff ff       	call   8003a7 <fd2data>
  800bb5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bb7:	83 c4 08             	add    $0x8,%esp
  800bba:	68 f7 1e 80 00       	push   $0x801ef7
  800bbf:	53                   	push   %ebx
  800bc0:	e8 1a 0b 00 00       	call   8016df <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bc5:	8b 46 04             	mov    0x4(%esi),%eax
  800bc8:	2b 06                	sub    (%esi),%eax
  800bca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bd0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bd7:	00 00 00 
	stat->st_dev = &devpipe;
  800bda:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be1:	30 80 00 
	return 0;
}
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
  800be9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bfa:	53                   	push   %ebx
  800bfb:	6a 00                	push   $0x0
  800bfd:	e8 29 f6 ff ff       	call   80022b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c02:	89 1c 24             	mov    %ebx,(%esp)
  800c05:	e8 9d f7 ff ff       	call   8003a7 <fd2data>
  800c0a:	83 c4 08             	add    $0x8,%esp
  800c0d:	50                   	push   %eax
  800c0e:	6a 00                	push   $0x0
  800c10:	e8 16 f6 ff ff       	call   80022b <sys_page_unmap>
}
  800c15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c18:	c9                   	leave  
  800c19:	c3                   	ret    

00800c1a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 1c             	sub    $0x1c,%esp
  800c23:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c26:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c28:	a1 04 40 80 00       	mov    0x804004,%eax
  800c2d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c30:	83 ec 0c             	sub    $0xc,%esp
  800c33:	ff 75 e0             	pushl  -0x20(%ebp)
  800c36:	e8 f8 0e 00 00       	call   801b33 <pageref>
  800c3b:	89 c3                	mov    %eax,%ebx
  800c3d:	89 3c 24             	mov    %edi,(%esp)
  800c40:	e8 ee 0e 00 00       	call   801b33 <pageref>
  800c45:	83 c4 10             	add    $0x10,%esp
  800c48:	39 c3                	cmp    %eax,%ebx
  800c4a:	0f 94 c1             	sete   %cl
  800c4d:	0f b6 c9             	movzbl %cl,%ecx
  800c50:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c53:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c59:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c5c:	39 ce                	cmp    %ecx,%esi
  800c5e:	74 1b                	je     800c7b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c60:	39 c3                	cmp    %eax,%ebx
  800c62:	75 c4                	jne    800c28 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c64:	8b 42 58             	mov    0x58(%edx),%eax
  800c67:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c6a:	50                   	push   %eax
  800c6b:	56                   	push   %esi
  800c6c:	68 fe 1e 80 00       	push   $0x801efe
  800c71:	e8 e4 04 00 00       	call   80115a <cprintf>
  800c76:	83 c4 10             	add    $0x10,%esp
  800c79:	eb ad                	jmp    800c28 <_pipeisclosed+0xe>
	}
}
  800c7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 28             	sub    $0x28,%esp
  800c8f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c92:	56                   	push   %esi
  800c93:	e8 0f f7 ff ff       	call   8003a7 <fd2data>
  800c98:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca2:	eb 4b                	jmp    800cef <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ca4:	89 da                	mov    %ebx,%edx
  800ca6:	89 f0                	mov    %esi,%eax
  800ca8:	e8 6d ff ff ff       	call   800c1a <_pipeisclosed>
  800cad:	85 c0                	test   %eax,%eax
  800caf:	75 48                	jne    800cf9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cb1:	e8 d1 f4 ff ff       	call   800187 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cb6:	8b 43 04             	mov    0x4(%ebx),%eax
  800cb9:	8b 0b                	mov    (%ebx),%ecx
  800cbb:	8d 51 20             	lea    0x20(%ecx),%edx
  800cbe:	39 d0                	cmp    %edx,%eax
  800cc0:	73 e2                	jae    800ca4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cc9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ccc:	89 c2                	mov    %eax,%edx
  800cce:	c1 fa 1f             	sar    $0x1f,%edx
  800cd1:	89 d1                	mov    %edx,%ecx
  800cd3:	c1 e9 1b             	shr    $0x1b,%ecx
  800cd6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cd9:	83 e2 1f             	and    $0x1f,%edx
  800cdc:	29 ca                	sub    %ecx,%edx
  800cde:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ce2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ce6:	83 c0 01             	add    $0x1,%eax
  800ce9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cec:	83 c7 01             	add    $0x1,%edi
  800cef:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cf2:	75 c2                	jne    800cb6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cf4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf7:	eb 05                	jmp    800cfe <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cf9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 18             	sub    $0x18,%esp
  800d0f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d12:	57                   	push   %edi
  800d13:	e8 8f f6 ff ff       	call   8003a7 <fd2data>
  800d18:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1a:	83 c4 10             	add    $0x10,%esp
  800d1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d22:	eb 3d                	jmp    800d61 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d24:	85 db                	test   %ebx,%ebx
  800d26:	74 04                	je     800d2c <devpipe_read+0x26>
				return i;
  800d28:	89 d8                	mov    %ebx,%eax
  800d2a:	eb 44                	jmp    800d70 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d2c:	89 f2                	mov    %esi,%edx
  800d2e:	89 f8                	mov    %edi,%eax
  800d30:	e8 e5 fe ff ff       	call   800c1a <_pipeisclosed>
  800d35:	85 c0                	test   %eax,%eax
  800d37:	75 32                	jne    800d6b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d39:	e8 49 f4 ff ff       	call   800187 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d3e:	8b 06                	mov    (%esi),%eax
  800d40:	3b 46 04             	cmp    0x4(%esi),%eax
  800d43:	74 df                	je     800d24 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d45:	99                   	cltd   
  800d46:	c1 ea 1b             	shr    $0x1b,%edx
  800d49:	01 d0                	add    %edx,%eax
  800d4b:	83 e0 1f             	and    $0x1f,%eax
  800d4e:	29 d0                	sub    %edx,%eax
  800d50:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d5b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d5e:	83 c3 01             	add    $0x1,%ebx
  800d61:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d64:	75 d8                	jne    800d3e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d66:	8b 45 10             	mov    0x10(%ebp),%eax
  800d69:	eb 05                	jmp    800d70 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
  800d7d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d83:	50                   	push   %eax
  800d84:	e8 35 f6 ff ff       	call   8003be <fd_alloc>
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	89 c2                	mov    %eax,%edx
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	0f 88 2c 01 00 00    	js     800ec2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d96:	83 ec 04             	sub    $0x4,%esp
  800d99:	68 07 04 00 00       	push   $0x407
  800d9e:	ff 75 f4             	pushl  -0xc(%ebp)
  800da1:	6a 00                	push   $0x0
  800da3:	e8 fe f3 ff ff       	call   8001a6 <sys_page_alloc>
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	89 c2                	mov    %eax,%edx
  800dad:	85 c0                	test   %eax,%eax
  800daf:	0f 88 0d 01 00 00    	js     800ec2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dbb:	50                   	push   %eax
  800dbc:	e8 fd f5 ff ff       	call   8003be <fd_alloc>
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	0f 88 e2 00 00 00    	js     800eb0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dce:	83 ec 04             	sub    $0x4,%esp
  800dd1:	68 07 04 00 00       	push   $0x407
  800dd6:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd9:	6a 00                	push   $0x0
  800ddb:	e8 c6 f3 ff ff       	call   8001a6 <sys_page_alloc>
  800de0:	89 c3                	mov    %eax,%ebx
  800de2:	83 c4 10             	add    $0x10,%esp
  800de5:	85 c0                	test   %eax,%eax
  800de7:	0f 88 c3 00 00 00    	js     800eb0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ded:	83 ec 0c             	sub    $0xc,%esp
  800df0:	ff 75 f4             	pushl  -0xc(%ebp)
  800df3:	e8 af f5 ff ff       	call   8003a7 <fd2data>
  800df8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dfa:	83 c4 0c             	add    $0xc,%esp
  800dfd:	68 07 04 00 00       	push   $0x407
  800e02:	50                   	push   %eax
  800e03:	6a 00                	push   $0x0
  800e05:	e8 9c f3 ff ff       	call   8001a6 <sys_page_alloc>
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	83 c4 10             	add    $0x10,%esp
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	0f 88 89 00 00 00    	js     800ea0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e1d:	e8 85 f5 ff ff       	call   8003a7 <fd2data>
  800e22:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e29:	50                   	push   %eax
  800e2a:	6a 00                	push   $0x0
  800e2c:	56                   	push   %esi
  800e2d:	6a 00                	push   $0x0
  800e2f:	e8 b5 f3 ff ff       	call   8001e9 <sys_page_map>
  800e34:	89 c3                	mov    %eax,%ebx
  800e36:	83 c4 20             	add    $0x20,%esp
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	78 55                	js     800e92 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e3d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e46:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e52:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e5b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e60:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e67:	83 ec 0c             	sub    $0xc,%esp
  800e6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6d:	e8 25 f5 ff ff       	call   800397 <fd2num>
  800e72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e75:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e77:	83 c4 04             	add    $0x4,%esp
  800e7a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7d:	e8 15 f5 ff ff       	call   800397 <fd2num>
  800e82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e85:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e90:	eb 30                	jmp    800ec2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e92:	83 ec 08             	sub    $0x8,%esp
  800e95:	56                   	push   %esi
  800e96:	6a 00                	push   $0x0
  800e98:	e8 8e f3 ff ff       	call   80022b <sys_page_unmap>
  800e9d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea0:	83 ec 08             	sub    $0x8,%esp
  800ea3:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea6:	6a 00                	push   $0x0
  800ea8:	e8 7e f3 ff ff       	call   80022b <sys_page_unmap>
  800ead:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb6:	6a 00                	push   $0x0
  800eb8:	e8 6e f3 ff ff       	call   80022b <sys_page_unmap>
  800ebd:	83 c4 10             	add    $0x10,%esp
  800ec0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ec2:	89 d0                	mov    %edx,%eax
  800ec4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ed1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ed4:	50                   	push   %eax
  800ed5:	ff 75 08             	pushl  0x8(%ebp)
  800ed8:	e8 30 f5 ff ff       	call   80040d <fd_lookup>
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	85 c0                	test   %eax,%eax
  800ee2:	78 18                	js     800efc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ee4:	83 ec 0c             	sub    $0xc,%esp
  800ee7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eea:	e8 b8 f4 ff ff       	call   8003a7 <fd2data>
	return _pipeisclosed(fd, p);
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef4:	e8 21 fd ff ff       	call   800c1a <_pipeisclosed>
  800ef9:	83 c4 10             	add    $0x10,%esp
}
  800efc:	c9                   	leave  
  800efd:	c3                   	ret    

00800efe <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    

00800f08 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f0e:	68 16 1f 80 00       	push   $0x801f16
  800f13:	ff 75 0c             	pushl  0xc(%ebp)
  800f16:	e8 c4 07 00 00       	call   8016df <strcpy>
	return 0;
}
  800f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	57                   	push   %edi
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f33:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f39:	eb 2d                	jmp    800f68 <devcons_write+0x46>
		m = n - tot;
  800f3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f40:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f43:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f48:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	53                   	push   %ebx
  800f4f:	03 45 0c             	add    0xc(%ebp),%eax
  800f52:	50                   	push   %eax
  800f53:	57                   	push   %edi
  800f54:	e8 18 09 00 00       	call   801871 <memmove>
		sys_cputs(buf, m);
  800f59:	83 c4 08             	add    $0x8,%esp
  800f5c:	53                   	push   %ebx
  800f5d:	57                   	push   %edi
  800f5e:	e8 87 f1 ff ff       	call   8000ea <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f63:	01 de                	add    %ebx,%esi
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	89 f0                	mov    %esi,%eax
  800f6a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f6d:	72 cc                	jb     800f3b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5f                   	pop    %edi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 08             	sub    $0x8,%esp
  800f7d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f86:	74 2a                	je     800fb2 <devcons_read+0x3b>
  800f88:	eb 05                	jmp    800f8f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f8a:	e8 f8 f1 ff ff       	call   800187 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f8f:	e8 74 f1 ff ff       	call   800108 <sys_cgetc>
  800f94:	85 c0                	test   %eax,%eax
  800f96:	74 f2                	je     800f8a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 16                	js     800fb2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f9c:	83 f8 04             	cmp    $0x4,%eax
  800f9f:	74 0c                	je     800fad <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fa1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa4:	88 02                	mov    %al,(%edx)
	return 1;
  800fa6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fab:	eb 05                	jmp    800fb2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fad:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fc0:	6a 01                	push   $0x1
  800fc2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc5:	50                   	push   %eax
  800fc6:	e8 1f f1 ff ff       	call   8000ea <sys_cputs>
}
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	c9                   	leave  
  800fcf:	c3                   	ret    

00800fd0 <getchar>:

int
getchar(void)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fd6:	6a 01                	push   $0x1
  800fd8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 90 f6 ff ff       	call   800673 <read>
	if (r < 0)
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 0f                	js     800ff9 <getchar+0x29>
		return r;
	if (r < 1)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	7e 06                	jle    800ff4 <getchar+0x24>
		return -E_EOF;
	return c;
  800fee:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ff2:	eb 05                	jmp    800ff9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800ff4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801001:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	e8 00 f4 ff ff       	call   80040d <fd_lookup>
  80100d:	83 c4 10             	add    $0x10,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	78 11                	js     801025 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801014:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801017:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101d:	39 10                	cmp    %edx,(%eax)
  80101f:	0f 94 c0             	sete   %al
  801022:	0f b6 c0             	movzbl %al,%eax
}
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <opencons>:

int
opencons(void)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80102d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801030:	50                   	push   %eax
  801031:	e8 88 f3 ff ff       	call   8003be <fd_alloc>
  801036:	83 c4 10             	add    $0x10,%esp
		return r;
  801039:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80103b:	85 c0                	test   %eax,%eax
  80103d:	78 3e                	js     80107d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	68 07 04 00 00       	push   $0x407
  801047:	ff 75 f4             	pushl  -0xc(%ebp)
  80104a:	6a 00                	push   $0x0
  80104c:	e8 55 f1 ff ff       	call   8001a6 <sys_page_alloc>
  801051:	83 c4 10             	add    $0x10,%esp
		return r;
  801054:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801056:	85 c0                	test   %eax,%eax
  801058:	78 23                	js     80107d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80105a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801060:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801063:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801068:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	50                   	push   %eax
  801073:	e8 1f f3 ff ff       	call   800397 <fd2num>
  801078:	89 c2                	mov    %eax,%edx
  80107a:	83 c4 10             	add    $0x10,%esp
}
  80107d:	89 d0                	mov    %edx,%eax
  80107f:	c9                   	leave  
  801080:	c3                   	ret    

00801081 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801086:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801089:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80108f:	e8 d4 f0 ff ff       	call   800168 <sys_getenvid>
  801094:	83 ec 0c             	sub    $0xc,%esp
  801097:	ff 75 0c             	pushl  0xc(%ebp)
  80109a:	ff 75 08             	pushl  0x8(%ebp)
  80109d:	56                   	push   %esi
  80109e:	50                   	push   %eax
  80109f:	68 24 1f 80 00       	push   $0x801f24
  8010a4:	e8 b1 00 00 00       	call   80115a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010a9:	83 c4 18             	add    $0x18,%esp
  8010ac:	53                   	push   %ebx
  8010ad:	ff 75 10             	pushl  0x10(%ebp)
  8010b0:	e8 54 00 00 00       	call   801109 <vcprintf>
	cprintf("\n");
  8010b5:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  8010bc:	e8 99 00 00 00       	call   80115a <cprintf>
  8010c1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010c4:	cc                   	int3   
  8010c5:	eb fd                	jmp    8010c4 <_panic+0x43>

008010c7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 04             	sub    $0x4,%esp
  8010ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010d1:	8b 13                	mov    (%ebx),%edx
  8010d3:	8d 42 01             	lea    0x1(%edx),%eax
  8010d6:	89 03                	mov    %eax,(%ebx)
  8010d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010db:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010e4:	75 1a                	jne    801100 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010e6:	83 ec 08             	sub    $0x8,%esp
  8010e9:	68 ff 00 00 00       	push   $0xff
  8010ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f1:	50                   	push   %eax
  8010f2:	e8 f3 ef ff ff       	call   8000ea <sys_cputs>
		b->idx = 0;
  8010f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010fd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801100:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801104:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801107:	c9                   	leave  
  801108:	c3                   	ret    

00801109 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801112:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801119:	00 00 00 
	b.cnt = 0;
  80111c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801123:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801126:	ff 75 0c             	pushl  0xc(%ebp)
  801129:	ff 75 08             	pushl  0x8(%ebp)
  80112c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801132:	50                   	push   %eax
  801133:	68 c7 10 80 00       	push   $0x8010c7
  801138:	e8 54 01 00 00       	call   801291 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80113d:	83 c4 08             	add    $0x8,%esp
  801140:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801146:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80114c:	50                   	push   %eax
  80114d:	e8 98 ef ff ff       	call   8000ea <sys_cputs>

	return b.cnt;
}
  801152:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801158:	c9                   	leave  
  801159:	c3                   	ret    

0080115a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801160:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801163:	50                   	push   %eax
  801164:	ff 75 08             	pushl  0x8(%ebp)
  801167:	e8 9d ff ff ff       	call   801109 <vcprintf>
	va_end(ap);

	return cnt;
}
  80116c:	c9                   	leave  
  80116d:	c3                   	ret    

0080116e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 1c             	sub    $0x1c,%esp
  801177:	89 c7                	mov    %eax,%edi
  801179:	89 d6                	mov    %edx,%esi
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801181:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801184:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801187:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80118a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801192:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801195:	39 d3                	cmp    %edx,%ebx
  801197:	72 05                	jb     80119e <printnum+0x30>
  801199:	39 45 10             	cmp    %eax,0x10(%ebp)
  80119c:	77 45                	ja     8011e3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80119e:	83 ec 0c             	sub    $0xc,%esp
  8011a1:	ff 75 18             	pushl  0x18(%ebp)
  8011a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8011aa:	53                   	push   %ebx
  8011ab:	ff 75 10             	pushl  0x10(%ebp)
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8011bd:	e8 ae 09 00 00       	call   801b70 <__udivdi3>
  8011c2:	83 c4 18             	add    $0x18,%esp
  8011c5:	52                   	push   %edx
  8011c6:	50                   	push   %eax
  8011c7:	89 f2                	mov    %esi,%edx
  8011c9:	89 f8                	mov    %edi,%eax
  8011cb:	e8 9e ff ff ff       	call   80116e <printnum>
  8011d0:	83 c4 20             	add    $0x20,%esp
  8011d3:	eb 18                	jmp    8011ed <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011d5:	83 ec 08             	sub    $0x8,%esp
  8011d8:	56                   	push   %esi
  8011d9:	ff 75 18             	pushl  0x18(%ebp)
  8011dc:	ff d7                	call   *%edi
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	eb 03                	jmp    8011e6 <printnum+0x78>
  8011e3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011e6:	83 eb 01             	sub    $0x1,%ebx
  8011e9:	85 db                	test   %ebx,%ebx
  8011eb:	7f e8                	jg     8011d5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ed:	83 ec 08             	sub    $0x8,%esp
  8011f0:	56                   	push   %esi
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011fa:	ff 75 dc             	pushl  -0x24(%ebp)
  8011fd:	ff 75 d8             	pushl  -0x28(%ebp)
  801200:	e8 9b 0a 00 00       	call   801ca0 <__umoddi3>
  801205:	83 c4 14             	add    $0x14,%esp
  801208:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  80120f:	50                   	push   %eax
  801210:	ff d7                	call   *%edi
}
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801218:	5b                   	pop    %ebx
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801220:	83 fa 01             	cmp    $0x1,%edx
  801223:	7e 0e                	jle    801233 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801225:	8b 10                	mov    (%eax),%edx
  801227:	8d 4a 08             	lea    0x8(%edx),%ecx
  80122a:	89 08                	mov    %ecx,(%eax)
  80122c:	8b 02                	mov    (%edx),%eax
  80122e:	8b 52 04             	mov    0x4(%edx),%edx
  801231:	eb 22                	jmp    801255 <getuint+0x38>
	else if (lflag)
  801233:	85 d2                	test   %edx,%edx
  801235:	74 10                	je     801247 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801237:	8b 10                	mov    (%eax),%edx
  801239:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123c:	89 08                	mov    %ecx,(%eax)
  80123e:	8b 02                	mov    (%edx),%eax
  801240:	ba 00 00 00 00       	mov    $0x0,%edx
  801245:	eb 0e                	jmp    801255 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801247:	8b 10                	mov    (%eax),%edx
  801249:	8d 4a 04             	lea    0x4(%edx),%ecx
  80124c:	89 08                	mov    %ecx,(%eax)
  80124e:	8b 02                	mov    (%edx),%eax
  801250:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80125d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801261:	8b 10                	mov    (%eax),%edx
  801263:	3b 50 04             	cmp    0x4(%eax),%edx
  801266:	73 0a                	jae    801272 <sprintputch+0x1b>
		*b->buf++ = ch;
  801268:	8d 4a 01             	lea    0x1(%edx),%ecx
  80126b:	89 08                	mov    %ecx,(%eax)
  80126d:	8b 45 08             	mov    0x8(%ebp),%eax
  801270:	88 02                	mov    %al,(%edx)
}
  801272:	5d                   	pop    %ebp
  801273:	c3                   	ret    

00801274 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80127a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80127d:	50                   	push   %eax
  80127e:	ff 75 10             	pushl  0x10(%ebp)
  801281:	ff 75 0c             	pushl  0xc(%ebp)
  801284:	ff 75 08             	pushl  0x8(%ebp)
  801287:	e8 05 00 00 00       	call   801291 <vprintfmt>
	va_end(ap);
}
  80128c:	83 c4 10             	add    $0x10,%esp
  80128f:	c9                   	leave  
  801290:	c3                   	ret    

00801291 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	57                   	push   %edi
  801295:	56                   	push   %esi
  801296:	53                   	push   %ebx
  801297:	83 ec 2c             	sub    $0x2c,%esp
  80129a:	8b 75 08             	mov    0x8(%ebp),%esi
  80129d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a3:	eb 12                	jmp    8012b7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	0f 84 89 03 00 00    	je     801636 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8012ad:	83 ec 08             	sub    $0x8,%esp
  8012b0:	53                   	push   %ebx
  8012b1:	50                   	push   %eax
  8012b2:	ff d6                	call   *%esi
  8012b4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012b7:	83 c7 01             	add    $0x1,%edi
  8012ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012be:	83 f8 25             	cmp    $0x25,%eax
  8012c1:	75 e2                	jne    8012a5 <vprintfmt+0x14>
  8012c3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e1:	eb 07                	jmp    8012ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012e6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ea:	8d 47 01             	lea    0x1(%edi),%eax
  8012ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f0:	0f b6 07             	movzbl (%edi),%eax
  8012f3:	0f b6 c8             	movzbl %al,%ecx
  8012f6:	83 e8 23             	sub    $0x23,%eax
  8012f9:	3c 55                	cmp    $0x55,%al
  8012fb:	0f 87 1a 03 00 00    	ja     80161b <vprintfmt+0x38a>
  801301:	0f b6 c0             	movzbl %al,%eax
  801304:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  80130b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80130e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801312:	eb d6                	jmp    8012ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801317:	b8 00 00 00 00       	mov    $0x0,%eax
  80131c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80131f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801322:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801326:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801329:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80132c:	83 fa 09             	cmp    $0x9,%edx
  80132f:	77 39                	ja     80136a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801331:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801334:	eb e9                	jmp    80131f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801336:	8b 45 14             	mov    0x14(%ebp),%eax
  801339:	8d 48 04             	lea    0x4(%eax),%ecx
  80133c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80133f:	8b 00                	mov    (%eax),%eax
  801341:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801347:	eb 27                	jmp    801370 <vprintfmt+0xdf>
  801349:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134c:	85 c0                	test   %eax,%eax
  80134e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801353:	0f 49 c8             	cmovns %eax,%ecx
  801356:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80135c:	eb 8c                	jmp    8012ea <vprintfmt+0x59>
  80135e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801361:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801368:	eb 80                	jmp    8012ea <vprintfmt+0x59>
  80136a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80136d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801370:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801374:	0f 89 70 ff ff ff    	jns    8012ea <vprintfmt+0x59>
				width = precision, precision = -1;
  80137a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80137d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801380:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801387:	e9 5e ff ff ff       	jmp    8012ea <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80138c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801392:	e9 53 ff ff ff       	jmp    8012ea <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801397:	8b 45 14             	mov    0x14(%ebp),%eax
  80139a:	8d 50 04             	lea    0x4(%eax),%edx
  80139d:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a0:	83 ec 08             	sub    $0x8,%esp
  8013a3:	53                   	push   %ebx
  8013a4:	ff 30                	pushl  (%eax)
  8013a6:	ff d6                	call   *%esi
			break;
  8013a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013ae:	e9 04 ff ff ff       	jmp    8012b7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b6:	8d 50 04             	lea    0x4(%eax),%edx
  8013b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8013bc:	8b 00                	mov    (%eax),%eax
  8013be:	99                   	cltd   
  8013bf:	31 d0                	xor    %edx,%eax
  8013c1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013c3:	83 f8 0f             	cmp    $0xf,%eax
  8013c6:	7f 0b                	jg     8013d3 <vprintfmt+0x142>
  8013c8:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013cf:	85 d2                	test   %edx,%edx
  8013d1:	75 18                	jne    8013eb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013d3:	50                   	push   %eax
  8013d4:	68 5f 1f 80 00       	push   $0x801f5f
  8013d9:	53                   	push   %ebx
  8013da:	56                   	push   %esi
  8013db:	e8 94 fe ff ff       	call   801274 <printfmt>
  8013e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013e6:	e9 cc fe ff ff       	jmp    8012b7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013eb:	52                   	push   %edx
  8013ec:	68 dd 1e 80 00       	push   $0x801edd
  8013f1:	53                   	push   %ebx
  8013f2:	56                   	push   %esi
  8013f3:	e8 7c fe ff ff       	call   801274 <printfmt>
  8013f8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013fe:	e9 b4 fe ff ff       	jmp    8012b7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801403:	8b 45 14             	mov    0x14(%ebp),%eax
  801406:	8d 50 04             	lea    0x4(%eax),%edx
  801409:	89 55 14             	mov    %edx,0x14(%ebp)
  80140c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80140e:	85 ff                	test   %edi,%edi
  801410:	b8 58 1f 80 00       	mov    $0x801f58,%eax
  801415:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801418:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80141c:	0f 8e 94 00 00 00    	jle    8014b6 <vprintfmt+0x225>
  801422:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801426:	0f 84 98 00 00 00    	je     8014c4 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80142c:	83 ec 08             	sub    $0x8,%esp
  80142f:	ff 75 d0             	pushl  -0x30(%ebp)
  801432:	57                   	push   %edi
  801433:	e8 86 02 00 00       	call   8016be <strnlen>
  801438:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80143b:	29 c1                	sub    %eax,%ecx
  80143d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801440:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801443:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801447:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80144a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80144d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80144f:	eb 0f                	jmp    801460 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	53                   	push   %ebx
  801455:	ff 75 e0             	pushl  -0x20(%ebp)
  801458:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80145a:	83 ef 01             	sub    $0x1,%edi
  80145d:	83 c4 10             	add    $0x10,%esp
  801460:	85 ff                	test   %edi,%edi
  801462:	7f ed                	jg     801451 <vprintfmt+0x1c0>
  801464:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801467:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80146a:	85 c9                	test   %ecx,%ecx
  80146c:	b8 00 00 00 00       	mov    $0x0,%eax
  801471:	0f 49 c1             	cmovns %ecx,%eax
  801474:	29 c1                	sub    %eax,%ecx
  801476:	89 75 08             	mov    %esi,0x8(%ebp)
  801479:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80147c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147f:	89 cb                	mov    %ecx,%ebx
  801481:	eb 4d                	jmp    8014d0 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801483:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801487:	74 1b                	je     8014a4 <vprintfmt+0x213>
  801489:	0f be c0             	movsbl %al,%eax
  80148c:	83 e8 20             	sub    $0x20,%eax
  80148f:	83 f8 5e             	cmp    $0x5e,%eax
  801492:	76 10                	jbe    8014a4 <vprintfmt+0x213>
					putch('?', putdat);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	ff 75 0c             	pushl  0xc(%ebp)
  80149a:	6a 3f                	push   $0x3f
  80149c:	ff 55 08             	call   *0x8(%ebp)
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	eb 0d                	jmp    8014b1 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8014a4:	83 ec 08             	sub    $0x8,%esp
  8014a7:	ff 75 0c             	pushl  0xc(%ebp)
  8014aa:	52                   	push   %edx
  8014ab:	ff 55 08             	call   *0x8(%ebp)
  8014ae:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014b1:	83 eb 01             	sub    $0x1,%ebx
  8014b4:	eb 1a                	jmp    8014d0 <vprintfmt+0x23f>
  8014b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8014b9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014bc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014bf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c2:	eb 0c                	jmp    8014d0 <vprintfmt+0x23f>
  8014c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014cd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014d0:	83 c7 01             	add    $0x1,%edi
  8014d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014d7:	0f be d0             	movsbl %al,%edx
  8014da:	85 d2                	test   %edx,%edx
  8014dc:	74 23                	je     801501 <vprintfmt+0x270>
  8014de:	85 f6                	test   %esi,%esi
  8014e0:	78 a1                	js     801483 <vprintfmt+0x1f2>
  8014e2:	83 ee 01             	sub    $0x1,%esi
  8014e5:	79 9c                	jns    801483 <vprintfmt+0x1f2>
  8014e7:	89 df                	mov    %ebx,%edi
  8014e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ef:	eb 18                	jmp    801509 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014f1:	83 ec 08             	sub    $0x8,%esp
  8014f4:	53                   	push   %ebx
  8014f5:	6a 20                	push   $0x20
  8014f7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014f9:	83 ef 01             	sub    $0x1,%edi
  8014fc:	83 c4 10             	add    $0x10,%esp
  8014ff:	eb 08                	jmp    801509 <vprintfmt+0x278>
  801501:	89 df                	mov    %ebx,%edi
  801503:	8b 75 08             	mov    0x8(%ebp),%esi
  801506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801509:	85 ff                	test   %edi,%edi
  80150b:	7f e4                	jg     8014f1 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80150d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801510:	e9 a2 fd ff ff       	jmp    8012b7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801515:	83 fa 01             	cmp    $0x1,%edx
  801518:	7e 16                	jle    801530 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80151a:	8b 45 14             	mov    0x14(%ebp),%eax
  80151d:	8d 50 08             	lea    0x8(%eax),%edx
  801520:	89 55 14             	mov    %edx,0x14(%ebp)
  801523:	8b 50 04             	mov    0x4(%eax),%edx
  801526:	8b 00                	mov    (%eax),%eax
  801528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80152e:	eb 32                	jmp    801562 <vprintfmt+0x2d1>
	else if (lflag)
  801530:	85 d2                	test   %edx,%edx
  801532:	74 18                	je     80154c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801534:	8b 45 14             	mov    0x14(%ebp),%eax
  801537:	8d 50 04             	lea    0x4(%eax),%edx
  80153a:	89 55 14             	mov    %edx,0x14(%ebp)
  80153d:	8b 00                	mov    (%eax),%eax
  80153f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801542:	89 c1                	mov    %eax,%ecx
  801544:	c1 f9 1f             	sar    $0x1f,%ecx
  801547:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80154a:	eb 16                	jmp    801562 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80154c:	8b 45 14             	mov    0x14(%ebp),%eax
  80154f:	8d 50 04             	lea    0x4(%eax),%edx
  801552:	89 55 14             	mov    %edx,0x14(%ebp)
  801555:	8b 00                	mov    (%eax),%eax
  801557:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80155a:	89 c1                	mov    %eax,%ecx
  80155c:	c1 f9 1f             	sar    $0x1f,%ecx
  80155f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801562:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801565:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801568:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80156d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801571:	79 74                	jns    8015e7 <vprintfmt+0x356>
				putch('-', putdat);
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	53                   	push   %ebx
  801577:	6a 2d                	push   $0x2d
  801579:	ff d6                	call   *%esi
				num = -(long long) num;
  80157b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80157e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801581:	f7 d8                	neg    %eax
  801583:	83 d2 00             	adc    $0x0,%edx
  801586:	f7 da                	neg    %edx
  801588:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80158b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801590:	eb 55                	jmp    8015e7 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801592:	8d 45 14             	lea    0x14(%ebp),%eax
  801595:	e8 83 fc ff ff       	call   80121d <getuint>
			base = 10;
  80159a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80159f:	eb 46                	jmp    8015e7 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a4:	e8 74 fc ff ff       	call   80121d <getuint>
			base = 8;
  8015a9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015ae:	eb 37                	jmp    8015e7 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	53                   	push   %ebx
  8015b4:	6a 30                	push   $0x30
  8015b6:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b8:	83 c4 08             	add    $0x8,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	6a 78                	push   $0x78
  8015be:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c3:	8d 50 04             	lea    0x4(%eax),%edx
  8015c6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015c9:	8b 00                	mov    (%eax),%eax
  8015cb:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015d3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015d8:	eb 0d                	jmp    8015e7 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015da:	8d 45 14             	lea    0x14(%ebp),%eax
  8015dd:	e8 3b fc ff ff       	call   80121d <getuint>
			base = 16;
  8015e2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015ee:	57                   	push   %edi
  8015ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f2:	51                   	push   %ecx
  8015f3:	52                   	push   %edx
  8015f4:	50                   	push   %eax
  8015f5:	89 da                	mov    %ebx,%edx
  8015f7:	89 f0                	mov    %esi,%eax
  8015f9:	e8 70 fb ff ff       	call   80116e <printnum>
			break;
  8015fe:	83 c4 20             	add    $0x20,%esp
  801601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801604:	e9 ae fc ff ff       	jmp    8012b7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	53                   	push   %ebx
  80160d:	51                   	push   %ecx
  80160e:	ff d6                	call   *%esi
			break;
  801610:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801616:	e9 9c fc ff ff       	jmp    8012b7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	53                   	push   %ebx
  80161f:	6a 25                	push   $0x25
  801621:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	eb 03                	jmp    80162b <vprintfmt+0x39a>
  801628:	83 ef 01             	sub    $0x1,%edi
  80162b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80162f:	75 f7                	jne    801628 <vprintfmt+0x397>
  801631:	e9 81 fc ff ff       	jmp    8012b7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801636:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801639:	5b                   	pop    %ebx
  80163a:	5e                   	pop    %esi
  80163b:	5f                   	pop    %edi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	83 ec 18             	sub    $0x18,%esp
  801644:	8b 45 08             	mov    0x8(%ebp),%eax
  801647:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80164a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80164d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801651:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801654:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80165b:	85 c0                	test   %eax,%eax
  80165d:	74 26                	je     801685 <vsnprintf+0x47>
  80165f:	85 d2                	test   %edx,%edx
  801661:	7e 22                	jle    801685 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801663:	ff 75 14             	pushl  0x14(%ebp)
  801666:	ff 75 10             	pushl  0x10(%ebp)
  801669:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	68 57 12 80 00       	push   $0x801257
  801672:	e8 1a fc ff ff       	call   801291 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801677:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80167a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80167d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	eb 05                	jmp    80168a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801685:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801692:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801695:	50                   	push   %eax
  801696:	ff 75 10             	pushl  0x10(%ebp)
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	e8 9a ff ff ff       	call   80163e <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b1:	eb 03                	jmp    8016b6 <strlen+0x10>
		n++;
  8016b3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016ba:	75 f7                	jne    8016b3 <strlen+0xd>
		n++;
	return n;
}
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cc:	eb 03                	jmp    8016d1 <strnlen+0x13>
		n++;
  8016ce:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d1:	39 c2                	cmp    %eax,%edx
  8016d3:	74 08                	je     8016dd <strnlen+0x1f>
  8016d5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d9:	75 f3                	jne    8016ce <strnlen+0x10>
  8016db:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016dd:	5d                   	pop    %ebp
  8016de:	c3                   	ret    

008016df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	53                   	push   %ebx
  8016e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	83 c2 01             	add    $0x1,%edx
  8016ee:	83 c1 01             	add    $0x1,%ecx
  8016f1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016f5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f8:	84 db                	test   %bl,%bl
  8016fa:	75 ef                	jne    8016eb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016fc:	5b                   	pop    %ebx
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	53                   	push   %ebx
  801703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801706:	53                   	push   %ebx
  801707:	e8 9a ff ff ff       	call   8016a6 <strlen>
  80170c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80170f:	ff 75 0c             	pushl  0xc(%ebp)
  801712:	01 d8                	add    %ebx,%eax
  801714:	50                   	push   %eax
  801715:	e8 c5 ff ff ff       	call   8016df <strcpy>
	return dst;
}
  80171a:	89 d8                	mov    %ebx,%eax
  80171c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	56                   	push   %esi
  801725:	53                   	push   %ebx
  801726:	8b 75 08             	mov    0x8(%ebp),%esi
  801729:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172c:	89 f3                	mov    %esi,%ebx
  80172e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801731:	89 f2                	mov    %esi,%edx
  801733:	eb 0f                	jmp    801744 <strncpy+0x23>
		*dst++ = *src;
  801735:	83 c2 01             	add    $0x1,%edx
  801738:	0f b6 01             	movzbl (%ecx),%eax
  80173b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80173e:	80 39 01             	cmpb   $0x1,(%ecx)
  801741:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801744:	39 da                	cmp    %ebx,%edx
  801746:	75 ed                	jne    801735 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801748:	89 f0                	mov    %esi,%eax
  80174a:	5b                   	pop    %ebx
  80174b:	5e                   	pop    %esi
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
  801753:	8b 75 08             	mov    0x8(%ebp),%esi
  801756:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801759:	8b 55 10             	mov    0x10(%ebp),%edx
  80175c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80175e:	85 d2                	test   %edx,%edx
  801760:	74 21                	je     801783 <strlcpy+0x35>
  801762:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801766:	89 f2                	mov    %esi,%edx
  801768:	eb 09                	jmp    801773 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80176a:	83 c2 01             	add    $0x1,%edx
  80176d:	83 c1 01             	add    $0x1,%ecx
  801770:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801773:	39 c2                	cmp    %eax,%edx
  801775:	74 09                	je     801780 <strlcpy+0x32>
  801777:	0f b6 19             	movzbl (%ecx),%ebx
  80177a:	84 db                	test   %bl,%bl
  80177c:	75 ec                	jne    80176a <strlcpy+0x1c>
  80177e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801780:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801783:	29 f0                	sub    %esi,%eax
}
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801792:	eb 06                	jmp    80179a <strcmp+0x11>
		p++, q++;
  801794:	83 c1 01             	add    $0x1,%ecx
  801797:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80179a:	0f b6 01             	movzbl (%ecx),%eax
  80179d:	84 c0                	test   %al,%al
  80179f:	74 04                	je     8017a5 <strcmp+0x1c>
  8017a1:	3a 02                	cmp    (%edx),%al
  8017a3:	74 ef                	je     801794 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a5:	0f b6 c0             	movzbl %al,%eax
  8017a8:	0f b6 12             	movzbl (%edx),%edx
  8017ab:	29 d0                	sub    %edx,%eax
}
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	53                   	push   %ebx
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b9:	89 c3                	mov    %eax,%ebx
  8017bb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017be:	eb 06                	jmp    8017c6 <strncmp+0x17>
		n--, p++, q++;
  8017c0:	83 c0 01             	add    $0x1,%eax
  8017c3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017c6:	39 d8                	cmp    %ebx,%eax
  8017c8:	74 15                	je     8017df <strncmp+0x30>
  8017ca:	0f b6 08             	movzbl (%eax),%ecx
  8017cd:	84 c9                	test   %cl,%cl
  8017cf:	74 04                	je     8017d5 <strncmp+0x26>
  8017d1:	3a 0a                	cmp    (%edx),%cl
  8017d3:	74 eb                	je     8017c0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d5:	0f b6 00             	movzbl (%eax),%eax
  8017d8:	0f b6 12             	movzbl (%edx),%edx
  8017db:	29 d0                	sub    %edx,%eax
  8017dd:	eb 05                	jmp    8017e4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017df:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017e4:	5b                   	pop    %ebx
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f1:	eb 07                	jmp    8017fa <strchr+0x13>
		if (*s == c)
  8017f3:	38 ca                	cmp    %cl,%dl
  8017f5:	74 0f                	je     801806 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f7:	83 c0 01             	add    $0x1,%eax
  8017fa:	0f b6 10             	movzbl (%eax),%edx
  8017fd:	84 d2                	test   %dl,%dl
  8017ff:	75 f2                	jne    8017f3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801801:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801812:	eb 03                	jmp    801817 <strfind+0xf>
  801814:	83 c0 01             	add    $0x1,%eax
  801817:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80181a:	38 ca                	cmp    %cl,%dl
  80181c:	74 04                	je     801822 <strfind+0x1a>
  80181e:	84 d2                	test   %dl,%dl
  801820:	75 f2                	jne    801814 <strfind+0xc>
			break;
	return (char *) s;
}
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	57                   	push   %edi
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801830:	85 c9                	test   %ecx,%ecx
  801832:	74 36                	je     80186a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801834:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183a:	75 28                	jne    801864 <memset+0x40>
  80183c:	f6 c1 03             	test   $0x3,%cl
  80183f:	75 23                	jne    801864 <memset+0x40>
		c &= 0xFF;
  801841:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801845:	89 d3                	mov    %edx,%ebx
  801847:	c1 e3 08             	shl    $0x8,%ebx
  80184a:	89 d6                	mov    %edx,%esi
  80184c:	c1 e6 18             	shl    $0x18,%esi
  80184f:	89 d0                	mov    %edx,%eax
  801851:	c1 e0 10             	shl    $0x10,%eax
  801854:	09 f0                	or     %esi,%eax
  801856:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801858:	89 d8                	mov    %ebx,%eax
  80185a:	09 d0                	or     %edx,%eax
  80185c:	c1 e9 02             	shr    $0x2,%ecx
  80185f:	fc                   	cld    
  801860:	f3 ab                	rep stos %eax,%es:(%edi)
  801862:	eb 06                	jmp    80186a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801864:	8b 45 0c             	mov    0xc(%ebp),%eax
  801867:	fc                   	cld    
  801868:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186a:	89 f8                	mov    %edi,%eax
  80186c:	5b                   	pop    %ebx
  80186d:	5e                   	pop    %esi
  80186e:	5f                   	pop    %edi
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	57                   	push   %edi
  801875:	56                   	push   %esi
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80187f:	39 c6                	cmp    %eax,%esi
  801881:	73 35                	jae    8018b8 <memmove+0x47>
  801883:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801886:	39 d0                	cmp    %edx,%eax
  801888:	73 2e                	jae    8018b8 <memmove+0x47>
		s += n;
		d += n;
  80188a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188d:	89 d6                	mov    %edx,%esi
  80188f:	09 fe                	or     %edi,%esi
  801891:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801897:	75 13                	jne    8018ac <memmove+0x3b>
  801899:	f6 c1 03             	test   $0x3,%cl
  80189c:	75 0e                	jne    8018ac <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80189e:	83 ef 04             	sub    $0x4,%edi
  8018a1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a4:	c1 e9 02             	shr    $0x2,%ecx
  8018a7:	fd                   	std    
  8018a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018aa:	eb 09                	jmp    8018b5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ac:	83 ef 01             	sub    $0x1,%edi
  8018af:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b2:	fd                   	std    
  8018b3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b5:	fc                   	cld    
  8018b6:	eb 1d                	jmp    8018d5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b8:	89 f2                	mov    %esi,%edx
  8018ba:	09 c2                	or     %eax,%edx
  8018bc:	f6 c2 03             	test   $0x3,%dl
  8018bf:	75 0f                	jne    8018d0 <memmove+0x5f>
  8018c1:	f6 c1 03             	test   $0x3,%cl
  8018c4:	75 0a                	jne    8018d0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018c6:	c1 e9 02             	shr    $0x2,%ecx
  8018c9:	89 c7                	mov    %eax,%edi
  8018cb:	fc                   	cld    
  8018cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ce:	eb 05                	jmp    8018d5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d0:	89 c7                	mov    %eax,%edi
  8018d2:	fc                   	cld    
  8018d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d5:	5e                   	pop    %esi
  8018d6:	5f                   	pop    %edi
  8018d7:	5d                   	pop    %ebp
  8018d8:	c3                   	ret    

008018d9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018dc:	ff 75 10             	pushl  0x10(%ebp)
  8018df:	ff 75 0c             	pushl  0xc(%ebp)
  8018e2:	ff 75 08             	pushl  0x8(%ebp)
  8018e5:	e8 87 ff ff ff       	call   801871 <memmove>
}
  8018ea:	c9                   	leave  
  8018eb:	c3                   	ret    

008018ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f7:	89 c6                	mov    %eax,%esi
  8018f9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fc:	eb 1a                	jmp    801918 <memcmp+0x2c>
		if (*s1 != *s2)
  8018fe:	0f b6 08             	movzbl (%eax),%ecx
  801901:	0f b6 1a             	movzbl (%edx),%ebx
  801904:	38 d9                	cmp    %bl,%cl
  801906:	74 0a                	je     801912 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801908:	0f b6 c1             	movzbl %cl,%eax
  80190b:	0f b6 db             	movzbl %bl,%ebx
  80190e:	29 d8                	sub    %ebx,%eax
  801910:	eb 0f                	jmp    801921 <memcmp+0x35>
		s1++, s2++;
  801912:	83 c0 01             	add    $0x1,%eax
  801915:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801918:	39 f0                	cmp    %esi,%eax
  80191a:	75 e2                	jne    8018fe <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80191c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801921:	5b                   	pop    %ebx
  801922:	5e                   	pop    %esi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	53                   	push   %ebx
  801929:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80192c:	89 c1                	mov    %eax,%ecx
  80192e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801931:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801935:	eb 0a                	jmp    801941 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801937:	0f b6 10             	movzbl (%eax),%edx
  80193a:	39 da                	cmp    %ebx,%edx
  80193c:	74 07                	je     801945 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193e:	83 c0 01             	add    $0x1,%eax
  801941:	39 c8                	cmp    %ecx,%eax
  801943:	72 f2                	jb     801937 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801945:	5b                   	pop    %ebx
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	57                   	push   %edi
  80194c:	56                   	push   %esi
  80194d:	53                   	push   %ebx
  80194e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801951:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801954:	eb 03                	jmp    801959 <strtol+0x11>
		s++;
  801956:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801959:	0f b6 01             	movzbl (%ecx),%eax
  80195c:	3c 20                	cmp    $0x20,%al
  80195e:	74 f6                	je     801956 <strtol+0xe>
  801960:	3c 09                	cmp    $0x9,%al
  801962:	74 f2                	je     801956 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801964:	3c 2b                	cmp    $0x2b,%al
  801966:	75 0a                	jne    801972 <strtol+0x2a>
		s++;
  801968:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80196b:	bf 00 00 00 00       	mov    $0x0,%edi
  801970:	eb 11                	jmp    801983 <strtol+0x3b>
  801972:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801977:	3c 2d                	cmp    $0x2d,%al
  801979:	75 08                	jne    801983 <strtol+0x3b>
		s++, neg = 1;
  80197b:	83 c1 01             	add    $0x1,%ecx
  80197e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801983:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801989:	75 15                	jne    8019a0 <strtol+0x58>
  80198b:	80 39 30             	cmpb   $0x30,(%ecx)
  80198e:	75 10                	jne    8019a0 <strtol+0x58>
  801990:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801994:	75 7c                	jne    801a12 <strtol+0xca>
		s += 2, base = 16;
  801996:	83 c1 02             	add    $0x2,%ecx
  801999:	bb 10 00 00 00       	mov    $0x10,%ebx
  80199e:	eb 16                	jmp    8019b6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019a0:	85 db                	test   %ebx,%ebx
  8019a2:	75 12                	jne    8019b6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a9:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ac:	75 08                	jne    8019b6 <strtol+0x6e>
		s++, base = 8;
  8019ae:	83 c1 01             	add    $0x1,%ecx
  8019b1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019be:	0f b6 11             	movzbl (%ecx),%edx
  8019c1:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c4:	89 f3                	mov    %esi,%ebx
  8019c6:	80 fb 09             	cmp    $0x9,%bl
  8019c9:	77 08                	ja     8019d3 <strtol+0x8b>
			dig = *s - '0';
  8019cb:	0f be d2             	movsbl %dl,%edx
  8019ce:	83 ea 30             	sub    $0x30,%edx
  8019d1:	eb 22                	jmp    8019f5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019d3:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d6:	89 f3                	mov    %esi,%ebx
  8019d8:	80 fb 19             	cmp    $0x19,%bl
  8019db:	77 08                	ja     8019e5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019dd:	0f be d2             	movsbl %dl,%edx
  8019e0:	83 ea 57             	sub    $0x57,%edx
  8019e3:	eb 10                	jmp    8019f5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019e5:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e8:	89 f3                	mov    %esi,%ebx
  8019ea:	80 fb 19             	cmp    $0x19,%bl
  8019ed:	77 16                	ja     801a05 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019ef:	0f be d2             	movsbl %dl,%edx
  8019f2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019f5:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f8:	7d 0b                	jge    801a05 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019fa:	83 c1 01             	add    $0x1,%ecx
  8019fd:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a01:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a03:	eb b9                	jmp    8019be <strtol+0x76>

	if (endptr)
  801a05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a09:	74 0d                	je     801a18 <strtol+0xd0>
		*endptr = (char *) s;
  801a0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a0e:	89 0e                	mov    %ecx,(%esi)
  801a10:	eb 06                	jmp    801a18 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a12:	85 db                	test   %ebx,%ebx
  801a14:	74 98                	je     8019ae <strtol+0x66>
  801a16:	eb 9e                	jmp    8019b6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a18:	89 c2                	mov    %eax,%edx
  801a1a:	f7 da                	neg    %edx
  801a1c:	85 ff                	test   %edi,%edi
  801a1e:	0f 45 c2             	cmovne %edx,%eax
}
  801a21:	5b                   	pop    %ebx
  801a22:	5e                   	pop    %esi
  801a23:	5f                   	pop    %edi
  801a24:	5d                   	pop    %ebp
  801a25:	c3                   	ret    

00801a26 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	56                   	push   %esi
  801a2a:	53                   	push   %ebx
  801a2b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801a34:	85 c0                	test   %eax,%eax
  801a36:	75 12                	jne    801a4a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	68 00 00 c0 ee       	push   $0xeec00000
  801a40:	e8 11 e9 ff ff       	call   800356 <sys_ipc_recv>
  801a45:	83 c4 10             	add    $0x10,%esp
  801a48:	eb 0c                	jmp    801a56 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	50                   	push   %eax
  801a4e:	e8 03 e9 ff ff       	call   800356 <sys_ipc_recv>
  801a53:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801a56:	85 f6                	test   %esi,%esi
  801a58:	0f 95 c1             	setne  %cl
  801a5b:	85 db                	test   %ebx,%ebx
  801a5d:	0f 95 c2             	setne  %dl
  801a60:	84 d1                	test   %dl,%cl
  801a62:	74 09                	je     801a6d <ipc_recv+0x47>
  801a64:	89 c2                	mov    %eax,%edx
  801a66:	c1 ea 1f             	shr    $0x1f,%edx
  801a69:	84 d2                	test   %dl,%dl
  801a6b:	75 24                	jne    801a91 <ipc_recv+0x6b>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801a6d:	85 f6                	test   %esi,%esi
  801a6f:	74 0a                	je     801a7b <ipc_recv+0x55>
		*from_env_store = thisenv->env_ipc_from;
  801a71:	a1 04 40 80 00       	mov    0x804004,%eax
  801a76:	8b 40 74             	mov    0x74(%eax),%eax
  801a79:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801a7b:	85 db                	test   %ebx,%ebx
  801a7d:	74 0a                	je     801a89 <ipc_recv+0x63>
		*perm_store = thisenv->env_ipc_perm;
  801a7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a84:	8b 40 78             	mov    0x78(%eax),%eax
  801a87:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a89:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a94:	5b                   	pop    %ebx
  801a95:	5e                   	pop    %esi
  801a96:	5d                   	pop    %ebp
  801a97:	c3                   	ret    

00801a98 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	57                   	push   %edi
  801a9c:	56                   	push   %esi
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801aaa:	85 db                	test   %ebx,%ebx
  801aac:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ab1:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ab4:	ff 75 14             	pushl  0x14(%ebp)
  801ab7:	53                   	push   %ebx
  801ab8:	56                   	push   %esi
  801ab9:	57                   	push   %edi
  801aba:	e8 74 e8 ff ff       	call   800333 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801abf:	89 c2                	mov    %eax,%edx
  801ac1:	c1 ea 1f             	shr    $0x1f,%edx
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	84 d2                	test   %dl,%dl
  801ac9:	74 17                	je     801ae2 <ipc_send+0x4a>
  801acb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ace:	74 12                	je     801ae2 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ad0:	50                   	push   %eax
  801ad1:	68 40 22 80 00       	push   $0x802240
  801ad6:	6a 47                	push   $0x47
  801ad8:	68 4e 22 80 00       	push   $0x80224e
  801add:	e8 9f f5 ff ff       	call   801081 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ae2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae5:	75 07                	jne    801aee <ipc_send+0x56>
			sys_yield();
  801ae7:	e8 9b e6 ff ff       	call   800187 <sys_yield>
  801aec:	eb c6                	jmp    801ab4 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801aee:	85 c0                	test   %eax,%eax
  801af0:	75 c2                	jne    801ab4 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801af2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af5:	5b                   	pop    %ebx
  801af6:	5e                   	pop    %esi
  801af7:	5f                   	pop    %edi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b00:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b05:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b08:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b0e:	8b 52 50             	mov    0x50(%edx),%edx
  801b11:	39 ca                	cmp    %ecx,%edx
  801b13:	75 0d                	jne    801b22 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b15:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b18:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b1d:	8b 40 48             	mov    0x48(%eax),%eax
  801b20:	eb 0f                	jmp    801b31 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b22:	83 c0 01             	add    $0x1,%eax
  801b25:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b2a:	75 d9                	jne    801b05 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b39:	89 d0                	mov    %edx,%eax
  801b3b:	c1 e8 16             	shr    $0x16,%eax
  801b3e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b45:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b4a:	f6 c1 01             	test   $0x1,%cl
  801b4d:	74 1d                	je     801b6c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b4f:	c1 ea 0c             	shr    $0xc,%edx
  801b52:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b59:	f6 c2 01             	test   $0x1,%dl
  801b5c:	74 0e                	je     801b6c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b5e:	c1 ea 0c             	shr    $0xc,%edx
  801b61:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b68:	ef 
  801b69:	0f b7 c0             	movzwl %ax,%eax
}
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    
  801b6e:	66 90                	xchg   %ax,%ax

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
