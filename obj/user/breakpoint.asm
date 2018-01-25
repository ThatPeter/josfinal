
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
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 f2 00 00 00       	call   80013b <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	89 c2                	mov    %eax,%edx
  800050:	c1 e2 07             	shl    $0x7,%edx
  800053:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80005a:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x31>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 2a 00 00 00       	call   8000a3 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007f:	5b                   	pop    %ebx
  800080:	5e                   	pop    %esi
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  800089:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80008e:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800090:	e8 a6 00 00 00       	call   80013b <sys_getenvid>
  800095:	83 ec 0c             	sub    $0xc,%esp
  800098:	50                   	push   %eax
  800099:	e8 ec 02 00 00       	call   80038a <sys_thread_free>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	c9                   	leave  
  8000a2:	c3                   	ret    

008000a3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a9:	e8 b9 07 00 00       	call   800867 <close_all>
	sys_env_destroy(0);
  8000ae:	83 ec 0c             	sub    $0xc,%esp
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 42 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800103:	b9 00 00 00 00       	mov    $0x0,%ecx
  800108:	b8 03 00 00 00       	mov    $0x3,%eax
  80010d:	8b 55 08             	mov    0x8(%ebp),%edx
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	89 ce                	mov    %ecx,%esi
  800116:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800118:	85 c0                	test   %eax,%eax
  80011a:	7e 17                	jle    800133 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	50                   	push   %eax
  800120:	6a 03                	push   $0x3
  800122:	68 aa 21 80 00       	push   $0x8021aa
  800127:	6a 23                	push   $0x23
  800129:	68 c7 21 80 00       	push   $0x8021c7
  80012e:	e8 53 12 00 00       	call   801386 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 17                	jle    8001b4 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	50                   	push   %eax
  8001a1:	6a 04                	push   $0x4
  8001a3:	68 aa 21 80 00       	push   $0x8021aa
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 c7 21 80 00       	push   $0x8021c7
  8001af:	e8 d2 11 00 00       	call   801386 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7e 17                	jle    8001f6 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	50                   	push   %eax
  8001e3:	6a 05                	push   $0x5
  8001e5:	68 aa 21 80 00       	push   $0x8021aa
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 c7 21 80 00       	push   $0x8021c7
  8001f1:	e8 90 11 00 00       	call   801386 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	b8 06 00 00 00       	mov    $0x6,%eax
  800211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7e 17                	jle    800238 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800221:	83 ec 0c             	sub    $0xc,%esp
  800224:	50                   	push   %eax
  800225:	6a 06                	push   $0x6
  800227:	68 aa 21 80 00       	push   $0x8021aa
  80022c:	6a 23                	push   $0x23
  80022e:	68 c7 21 80 00       	push   $0x8021c7
  800233:	e8 4e 11 00 00       	call   801386 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	b8 08 00 00 00       	mov    $0x8,%eax
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 17                	jle    80027a <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	50                   	push   %eax
  800267:	6a 08                	push   $0x8
  800269:	68 aa 21 80 00       	push   $0x8021aa
  80026e:	6a 23                	push   $0x23
  800270:	68 c7 21 80 00       	push   $0x8021c7
  800275:	e8 0c 11 00 00       	call   801386 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800290:	b8 09 00 00 00       	mov    $0x9,%eax
  800295:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	89 de                	mov    %ebx,%esi
  80029f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7e 17                	jle    8002bc <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a5:	83 ec 0c             	sub    $0xc,%esp
  8002a8:	50                   	push   %eax
  8002a9:	6a 09                	push   $0x9
  8002ab:	68 aa 21 80 00       	push   $0x8021aa
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 c7 21 80 00       	push   $0x8021c7
  8002b7:	e8 ca 10 00 00       	call   801386 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	89 df                	mov    %ebx,%edi
  8002df:	89 de                	mov    %ebx,%esi
  8002e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	7e 17                	jle    8002fe <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e7:	83 ec 0c             	sub    $0xc,%esp
  8002ea:	50                   	push   %eax
  8002eb:	6a 0a                	push   $0xa
  8002ed:	68 aa 21 80 00       	push   $0x8021aa
  8002f2:	6a 23                	push   $0x23
  8002f4:	68 c7 21 80 00       	push   $0x8021c7
  8002f9:	e8 88 10 00 00       	call   801386 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030c:	be 00 00 00 00       	mov    $0x0,%esi
  800311:	b8 0c 00 00 00       	mov    $0xc,%eax
  800316:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800322:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800332:	b9 00 00 00 00       	mov    $0x0,%ecx
  800337:	b8 0d 00 00 00       	mov    $0xd,%eax
  80033c:	8b 55 08             	mov    0x8(%ebp),%edx
  80033f:	89 cb                	mov    %ecx,%ebx
  800341:	89 cf                	mov    %ecx,%edi
  800343:	89 ce                	mov    %ecx,%esi
  800345:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800347:	85 c0                	test   %eax,%eax
  800349:	7e 17                	jle    800362 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034b:	83 ec 0c             	sub    $0xc,%esp
  80034e:	50                   	push   %eax
  80034f:	6a 0d                	push   $0xd
  800351:	68 aa 21 80 00       	push   $0x8021aa
  800356:	6a 23                	push   $0x23
  800358:	68 c7 21 80 00       	push   $0x8021c7
  80035d:	e8 24 10 00 00       	call   801386 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800362:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	57                   	push   %edi
  80036e:	56                   	push   %esi
  80036f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800370:	b9 00 00 00 00       	mov    $0x0,%ecx
  800375:	b8 0e 00 00 00       	mov    $0xe,%eax
  80037a:	8b 55 08             	mov    0x8(%ebp),%edx
  80037d:	89 cb                	mov    %ecx,%ebx
  80037f:	89 cf                	mov    %ecx,%edi
  800381:	89 ce                	mov    %ecx,%esi
  800383:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800385:	5b                   	pop    %ebx
  800386:	5e                   	pop    %esi
  800387:	5f                   	pop    %edi
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	57                   	push   %edi
  80038e:	56                   	push   %esi
  80038f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800390:	b9 00 00 00 00       	mov    $0x0,%ecx
  800395:	b8 0f 00 00 00       	mov    $0xf,%eax
  80039a:	8b 55 08             	mov    0x8(%ebp),%edx
  80039d:	89 cb                	mov    %ecx,%ebx
  80039f:	89 cf                	mov    %ecx,%edi
  8003a1:	89 ce                	mov    %ecx,%esi
  8003a3:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003a5:	5b                   	pop    %ebx
  8003a6:	5e                   	pop    %esi
  8003a7:	5f                   	pop    %edi
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	53                   	push   %ebx
  8003ae:	83 ec 04             	sub    $0x4,%esp
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003b4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003b6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003ba:	74 11                	je     8003cd <pgfault+0x23>
  8003bc:	89 d8                	mov    %ebx,%eax
  8003be:	c1 e8 0c             	shr    $0xc,%eax
  8003c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003c8:	f6 c4 08             	test   $0x8,%ah
  8003cb:	75 14                	jne    8003e1 <pgfault+0x37>
		panic("faulting access");
  8003cd:	83 ec 04             	sub    $0x4,%esp
  8003d0:	68 d5 21 80 00       	push   $0x8021d5
  8003d5:	6a 1e                	push   $0x1e
  8003d7:	68 e5 21 80 00       	push   $0x8021e5
  8003dc:	e8 a5 0f 00 00       	call   801386 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003e1:	83 ec 04             	sub    $0x4,%esp
  8003e4:	6a 07                	push   $0x7
  8003e6:	68 00 f0 7f 00       	push   $0x7ff000
  8003eb:	6a 00                	push   $0x0
  8003ed:	e8 87 fd ff ff       	call   800179 <sys_page_alloc>
	if (r < 0) {
  8003f2:	83 c4 10             	add    $0x10,%esp
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	79 12                	jns    80040b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8003f9:	50                   	push   %eax
  8003fa:	68 f0 21 80 00       	push   $0x8021f0
  8003ff:	6a 2c                	push   $0x2c
  800401:	68 e5 21 80 00       	push   $0x8021e5
  800406:	e8 7b 0f 00 00       	call   801386 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80040b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800411:	83 ec 04             	sub    $0x4,%esp
  800414:	68 00 10 00 00       	push   $0x1000
  800419:	53                   	push   %ebx
  80041a:	68 00 f0 7f 00       	push   $0x7ff000
  80041f:	e8 ba 17 00 00       	call   801bde <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800424:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80042b:	53                   	push   %ebx
  80042c:	6a 00                	push   $0x0
  80042e:	68 00 f0 7f 00       	push   $0x7ff000
  800433:	6a 00                	push   $0x0
  800435:	e8 82 fd ff ff       	call   8001bc <sys_page_map>
	if (r < 0) {
  80043a:	83 c4 20             	add    $0x20,%esp
  80043d:	85 c0                	test   %eax,%eax
  80043f:	79 12                	jns    800453 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800441:	50                   	push   %eax
  800442:	68 f0 21 80 00       	push   $0x8021f0
  800447:	6a 33                	push   $0x33
  800449:	68 e5 21 80 00       	push   $0x8021e5
  80044e:	e8 33 0f 00 00       	call   801386 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	68 00 f0 7f 00       	push   $0x7ff000
  80045b:	6a 00                	push   $0x0
  80045d:	e8 9c fd ff ff       	call   8001fe <sys_page_unmap>
	if (r < 0) {
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	85 c0                	test   %eax,%eax
  800467:	79 12                	jns    80047b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800469:	50                   	push   %eax
  80046a:	68 f0 21 80 00       	push   $0x8021f0
  80046f:	6a 37                	push   $0x37
  800471:	68 e5 21 80 00       	push   $0x8021e5
  800476:	e8 0b 0f 00 00       	call   801386 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80047b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	57                   	push   %edi
  800484:	56                   	push   %esi
  800485:	53                   	push   %ebx
  800486:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800489:	68 aa 03 80 00       	push   $0x8003aa
  80048e:	e8 98 18 00 00       	call   801d2b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800493:	b8 07 00 00 00       	mov    $0x7,%eax
  800498:	cd 30                	int    $0x30
  80049a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	79 17                	jns    8004bb <fork+0x3b>
		panic("fork fault %e");
  8004a4:	83 ec 04             	sub    $0x4,%esp
  8004a7:	68 09 22 80 00       	push   $0x802209
  8004ac:	68 84 00 00 00       	push   $0x84
  8004b1:	68 e5 21 80 00       	push   $0x8021e5
  8004b6:	e8 cb 0e 00 00       	call   801386 <_panic>
  8004bb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c1:	75 25                	jne    8004e8 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004c3:	e8 73 fc ff ff       	call   80013b <sys_getenvid>
  8004c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004cd:	89 c2                	mov    %eax,%edx
  8004cf:	c1 e2 07             	shl    $0x7,%edx
  8004d2:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8004d9:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004de:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e3:	e9 61 01 00 00       	jmp    800649 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004e8:	83 ec 04             	sub    $0x4,%esp
  8004eb:	6a 07                	push   $0x7
  8004ed:	68 00 f0 bf ee       	push   $0xeebff000
  8004f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004f5:	e8 7f fc ff ff       	call   800179 <sys_page_alloc>
  8004fa:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8004fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800502:	89 d8                	mov    %ebx,%eax
  800504:	c1 e8 16             	shr    $0x16,%eax
  800507:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80050e:	a8 01                	test   $0x1,%al
  800510:	0f 84 fc 00 00 00    	je     800612 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800516:	89 d8                	mov    %ebx,%eax
  800518:	c1 e8 0c             	shr    $0xc,%eax
  80051b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800522:	f6 c2 01             	test   $0x1,%dl
  800525:	0f 84 e7 00 00 00    	je     800612 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80052b:	89 c6                	mov    %eax,%esi
  80052d:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800530:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800537:	f6 c6 04             	test   $0x4,%dh
  80053a:	74 39                	je     800575 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80053c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	25 07 0e 00 00       	and    $0xe07,%eax
  80054b:	50                   	push   %eax
  80054c:	56                   	push   %esi
  80054d:	57                   	push   %edi
  80054e:	56                   	push   %esi
  80054f:	6a 00                	push   $0x0
  800551:	e8 66 fc ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  800556:	83 c4 20             	add    $0x20,%esp
  800559:	85 c0                	test   %eax,%eax
  80055b:	0f 89 b1 00 00 00    	jns    800612 <fork+0x192>
		    	panic("sys page map fault %e");
  800561:	83 ec 04             	sub    $0x4,%esp
  800564:	68 17 22 80 00       	push   $0x802217
  800569:	6a 54                	push   $0x54
  80056b:	68 e5 21 80 00       	push   $0x8021e5
  800570:	e8 11 0e 00 00       	call   801386 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800575:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80057c:	f6 c2 02             	test   $0x2,%dl
  80057f:	75 0c                	jne    80058d <fork+0x10d>
  800581:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800588:	f6 c4 08             	test   $0x8,%ah
  80058b:	74 5b                	je     8005e8 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80058d:	83 ec 0c             	sub    $0xc,%esp
  800590:	68 05 08 00 00       	push   $0x805
  800595:	56                   	push   %esi
  800596:	57                   	push   %edi
  800597:	56                   	push   %esi
  800598:	6a 00                	push   $0x0
  80059a:	e8 1d fc ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  80059f:	83 c4 20             	add    $0x20,%esp
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	79 14                	jns    8005ba <fork+0x13a>
		    	panic("sys page map fault %e");
  8005a6:	83 ec 04             	sub    $0x4,%esp
  8005a9:	68 17 22 80 00       	push   $0x802217
  8005ae:	6a 5b                	push   $0x5b
  8005b0:	68 e5 21 80 00       	push   $0x8021e5
  8005b5:	e8 cc 0d 00 00       	call   801386 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005ba:	83 ec 0c             	sub    $0xc,%esp
  8005bd:	68 05 08 00 00       	push   $0x805
  8005c2:	56                   	push   %esi
  8005c3:	6a 00                	push   $0x0
  8005c5:	56                   	push   %esi
  8005c6:	6a 00                	push   $0x0
  8005c8:	e8 ef fb ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  8005cd:	83 c4 20             	add    $0x20,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	79 3e                	jns    800612 <fork+0x192>
		    	panic("sys page map fault %e");
  8005d4:	83 ec 04             	sub    $0x4,%esp
  8005d7:	68 17 22 80 00       	push   $0x802217
  8005dc:	6a 5f                	push   $0x5f
  8005de:	68 e5 21 80 00       	push   $0x8021e5
  8005e3:	e8 9e 0d 00 00       	call   801386 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	6a 05                	push   $0x5
  8005ed:	56                   	push   %esi
  8005ee:	57                   	push   %edi
  8005ef:	56                   	push   %esi
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 c5 fb ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  8005f7:	83 c4 20             	add    $0x20,%esp
  8005fa:	85 c0                	test   %eax,%eax
  8005fc:	79 14                	jns    800612 <fork+0x192>
		    	panic("sys page map fault %e");
  8005fe:	83 ec 04             	sub    $0x4,%esp
  800601:	68 17 22 80 00       	push   $0x802217
  800606:	6a 64                	push   $0x64
  800608:	68 e5 21 80 00       	push   $0x8021e5
  80060d:	e8 74 0d 00 00       	call   801386 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800612:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800618:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80061e:	0f 85 de fe ff ff    	jne    800502 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800624:	a1 04 40 80 00       	mov    0x804004,%eax
  800629:	8b 40 70             	mov    0x70(%eax),%eax
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	50                   	push   %eax
  800630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800633:	57                   	push   %edi
  800634:	e8 8b fc ff ff       	call   8002c4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800639:	83 c4 08             	add    $0x8,%esp
  80063c:	6a 02                	push   $0x2
  80063e:	57                   	push   %edi
  80063f:	e8 fc fb ff ff       	call   800240 <sys_env_set_status>
	
	return envid;
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800649:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064c:	5b                   	pop    %ebx
  80064d:	5e                   	pop    %esi
  80064e:	5f                   	pop    %edi
  80064f:	5d                   	pop    %ebp
  800650:	c3                   	ret    

00800651 <sfork>:

envid_t
sfork(void)
{
  800651:	55                   	push   %ebp
  800652:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800654:	b8 00 00 00 00       	mov    $0x0,%eax
  800659:	5d                   	pop    %ebp
  80065a:	c3                   	ret    

0080065b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80065b:	55                   	push   %ebp
  80065c:	89 e5                	mov    %esp,%ebp
  80065e:	56                   	push   %esi
  80065f:	53                   	push   %ebx
  800660:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800663:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	68 30 22 80 00       	push   $0x802230
  800672:	e8 e8 0d 00 00       	call   80145f <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800677:	c7 04 24 83 00 80 00 	movl   $0x800083,(%esp)
  80067e:	e8 e7 fc ff ff       	call   80036a <sys_thread_create>
  800683:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800685:	83 c4 08             	add    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	68 30 22 80 00       	push   $0x802230
  80068e:	e8 cc 0d 00 00       	call   80145f <cprintf>
	return id;
	//return 0;
}
  800693:	89 f0                	mov    %esi,%eax
  800695:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800698:	5b                   	pop    %ebx
  800699:	5e                   	pop    %esi
  80069a:	5d                   	pop    %ebp
  80069b:	c3                   	ret    

0080069c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80069f:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a2:	05 00 00 00 30       	add    $0x30000000,%eax
  8006a7:	c1 e8 0c             	shr    $0xc,%eax
}
  8006aa:	5d                   	pop    %ebp
  8006ab:	c3                   	ret    

008006ac <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006ac:	55                   	push   %ebp
  8006ad:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006af:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8006b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006bc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006c1:	5d                   	pop    %ebp
  8006c2:	c3                   	ret    

008006c3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006ce:	89 c2                	mov    %eax,%edx
  8006d0:	c1 ea 16             	shr    $0x16,%edx
  8006d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006da:	f6 c2 01             	test   $0x1,%dl
  8006dd:	74 11                	je     8006f0 <fd_alloc+0x2d>
  8006df:	89 c2                	mov    %eax,%edx
  8006e1:	c1 ea 0c             	shr    $0xc,%edx
  8006e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006eb:	f6 c2 01             	test   $0x1,%dl
  8006ee:	75 09                	jne    8006f9 <fd_alloc+0x36>
			*fd_store = fd;
  8006f0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f7:	eb 17                	jmp    800710 <fd_alloc+0x4d>
  8006f9:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8006fe:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800703:	75 c9                	jne    8006ce <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800705:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80070b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    

00800712 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800718:	83 f8 1f             	cmp    $0x1f,%eax
  80071b:	77 36                	ja     800753 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80071d:	c1 e0 0c             	shl    $0xc,%eax
  800720:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800725:	89 c2                	mov    %eax,%edx
  800727:	c1 ea 16             	shr    $0x16,%edx
  80072a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800731:	f6 c2 01             	test   $0x1,%dl
  800734:	74 24                	je     80075a <fd_lookup+0x48>
  800736:	89 c2                	mov    %eax,%edx
  800738:	c1 ea 0c             	shr    $0xc,%edx
  80073b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800742:	f6 c2 01             	test   $0x1,%dl
  800745:	74 1a                	je     800761 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800747:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074a:	89 02                	mov    %eax,(%edx)
	return 0;
  80074c:	b8 00 00 00 00       	mov    $0x0,%eax
  800751:	eb 13                	jmp    800766 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800753:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800758:	eb 0c                	jmp    800766 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80075a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075f:	eb 05                	jmp    800766 <fd_lookup+0x54>
  800761:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800771:	ba d0 22 80 00       	mov    $0x8022d0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800776:	eb 13                	jmp    80078b <dev_lookup+0x23>
  800778:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80077b:	39 08                	cmp    %ecx,(%eax)
  80077d:	75 0c                	jne    80078b <dev_lookup+0x23>
			*dev = devtab[i];
  80077f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800782:	89 01                	mov    %eax,(%ecx)
			return 0;
  800784:	b8 00 00 00 00       	mov    $0x0,%eax
  800789:	eb 2e                	jmp    8007b9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80078b:	8b 02                	mov    (%edx),%eax
  80078d:	85 c0                	test   %eax,%eax
  80078f:	75 e7                	jne    800778 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800791:	a1 04 40 80 00       	mov    0x804004,%eax
  800796:	8b 40 54             	mov    0x54(%eax),%eax
  800799:	83 ec 04             	sub    $0x4,%esp
  80079c:	51                   	push   %ecx
  80079d:	50                   	push   %eax
  80079e:	68 54 22 80 00       	push   $0x802254
  8007a3:	e8 b7 0c 00 00       	call   80145f <cprintf>
	*dev = 0;
  8007a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	83 ec 10             	sub    $0x10,%esp
  8007c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007d3:	c1 e8 0c             	shr    $0xc,%eax
  8007d6:	50                   	push   %eax
  8007d7:	e8 36 ff ff ff       	call   800712 <fd_lookup>
  8007dc:	83 c4 08             	add    $0x8,%esp
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 05                	js     8007e8 <fd_close+0x2d>
	    || fd != fd2)
  8007e3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007e6:	74 0c                	je     8007f4 <fd_close+0x39>
		return (must_exist ? r : 0);
  8007e8:	84 db                	test   %bl,%bl
  8007ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ef:	0f 44 c2             	cmove  %edx,%eax
  8007f2:	eb 41                	jmp    800835 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fa:	50                   	push   %eax
  8007fb:	ff 36                	pushl  (%esi)
  8007fd:	e8 66 ff ff ff       	call   800768 <dev_lookup>
  800802:	89 c3                	mov    %eax,%ebx
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	85 c0                	test   %eax,%eax
  800809:	78 1a                	js     800825 <fd_close+0x6a>
		if (dev->dev_close)
  80080b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800811:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800816:	85 c0                	test   %eax,%eax
  800818:	74 0b                	je     800825 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80081a:	83 ec 0c             	sub    $0xc,%esp
  80081d:	56                   	push   %esi
  80081e:	ff d0                	call   *%eax
  800820:	89 c3                	mov    %eax,%ebx
  800822:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800825:	83 ec 08             	sub    $0x8,%esp
  800828:	56                   	push   %esi
  800829:	6a 00                	push   $0x0
  80082b:	e8 ce f9 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800830:	83 c4 10             	add    $0x10,%esp
  800833:	89 d8                	mov    %ebx,%eax
}
  800835:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800838:	5b                   	pop    %ebx
  800839:	5e                   	pop    %esi
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800842:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800845:	50                   	push   %eax
  800846:	ff 75 08             	pushl  0x8(%ebp)
  800849:	e8 c4 fe ff ff       	call   800712 <fd_lookup>
  80084e:	83 c4 08             	add    $0x8,%esp
  800851:	85 c0                	test   %eax,%eax
  800853:	78 10                	js     800865 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	6a 01                	push   $0x1
  80085a:	ff 75 f4             	pushl  -0xc(%ebp)
  80085d:	e8 59 ff ff ff       	call   8007bb <fd_close>
  800862:	83 c4 10             	add    $0x10,%esp
}
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <close_all>:

void
close_all(void)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80086e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800873:	83 ec 0c             	sub    $0xc,%esp
  800876:	53                   	push   %ebx
  800877:	e8 c0 ff ff ff       	call   80083c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80087c:	83 c3 01             	add    $0x1,%ebx
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	83 fb 20             	cmp    $0x20,%ebx
  800885:	75 ec                	jne    800873 <close_all+0xc>
		close(i);
}
  800887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	57                   	push   %edi
  800890:	56                   	push   %esi
  800891:	53                   	push   %ebx
  800892:	83 ec 2c             	sub    $0x2c,%esp
  800895:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800898:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80089b:	50                   	push   %eax
  80089c:	ff 75 08             	pushl  0x8(%ebp)
  80089f:	e8 6e fe ff ff       	call   800712 <fd_lookup>
  8008a4:	83 c4 08             	add    $0x8,%esp
  8008a7:	85 c0                	test   %eax,%eax
  8008a9:	0f 88 c1 00 00 00    	js     800970 <dup+0xe4>
		return r;
	close(newfdnum);
  8008af:	83 ec 0c             	sub    $0xc,%esp
  8008b2:	56                   	push   %esi
  8008b3:	e8 84 ff ff ff       	call   80083c <close>

	newfd = INDEX2FD(newfdnum);
  8008b8:	89 f3                	mov    %esi,%ebx
  8008ba:	c1 e3 0c             	shl    $0xc,%ebx
  8008bd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008c3:	83 c4 04             	add    $0x4,%esp
  8008c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008c9:	e8 de fd ff ff       	call   8006ac <fd2data>
  8008ce:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008d0:	89 1c 24             	mov    %ebx,(%esp)
  8008d3:	e8 d4 fd ff ff       	call   8006ac <fd2data>
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008de:	89 f8                	mov    %edi,%eax
  8008e0:	c1 e8 16             	shr    $0x16,%eax
  8008e3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008ea:	a8 01                	test   $0x1,%al
  8008ec:	74 37                	je     800925 <dup+0x99>
  8008ee:	89 f8                	mov    %edi,%eax
  8008f0:	c1 e8 0c             	shr    $0xc,%eax
  8008f3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8008fa:	f6 c2 01             	test   $0x1,%dl
  8008fd:	74 26                	je     800925 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8008ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800906:	83 ec 0c             	sub    $0xc,%esp
  800909:	25 07 0e 00 00       	and    $0xe07,%eax
  80090e:	50                   	push   %eax
  80090f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800912:	6a 00                	push   $0x0
  800914:	57                   	push   %edi
  800915:	6a 00                	push   $0x0
  800917:	e8 a0 f8 ff ff       	call   8001bc <sys_page_map>
  80091c:	89 c7                	mov    %eax,%edi
  80091e:	83 c4 20             	add    $0x20,%esp
  800921:	85 c0                	test   %eax,%eax
  800923:	78 2e                	js     800953 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800925:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800928:	89 d0                	mov    %edx,%eax
  80092a:	c1 e8 0c             	shr    $0xc,%eax
  80092d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800934:	83 ec 0c             	sub    $0xc,%esp
  800937:	25 07 0e 00 00       	and    $0xe07,%eax
  80093c:	50                   	push   %eax
  80093d:	53                   	push   %ebx
  80093e:	6a 00                	push   $0x0
  800940:	52                   	push   %edx
  800941:	6a 00                	push   $0x0
  800943:	e8 74 f8 ff ff       	call   8001bc <sys_page_map>
  800948:	89 c7                	mov    %eax,%edi
  80094a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80094d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80094f:	85 ff                	test   %edi,%edi
  800951:	79 1d                	jns    800970 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800953:	83 ec 08             	sub    $0x8,%esp
  800956:	53                   	push   %ebx
  800957:	6a 00                	push   $0x0
  800959:	e8 a0 f8 ff ff       	call   8001fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  80095e:	83 c4 08             	add    $0x8,%esp
  800961:	ff 75 d4             	pushl  -0x2c(%ebp)
  800964:	6a 00                	push   $0x0
  800966:	e8 93 f8 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  80096b:	83 c4 10             	add    $0x10,%esp
  80096e:	89 f8                	mov    %edi,%eax
}
  800970:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800973:	5b                   	pop    %ebx
  800974:	5e                   	pop    %esi
  800975:	5f                   	pop    %edi
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	53                   	push   %ebx
  80097c:	83 ec 14             	sub    $0x14,%esp
  80097f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800982:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800985:	50                   	push   %eax
  800986:	53                   	push   %ebx
  800987:	e8 86 fd ff ff       	call   800712 <fd_lookup>
  80098c:	83 c4 08             	add    $0x8,%esp
  80098f:	89 c2                	mov    %eax,%edx
  800991:	85 c0                	test   %eax,%eax
  800993:	78 6d                	js     800a02 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800995:	83 ec 08             	sub    $0x8,%esp
  800998:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80099b:	50                   	push   %eax
  80099c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80099f:	ff 30                	pushl  (%eax)
  8009a1:	e8 c2 fd ff ff       	call   800768 <dev_lookup>
  8009a6:	83 c4 10             	add    $0x10,%esp
  8009a9:	85 c0                	test   %eax,%eax
  8009ab:	78 4c                	js     8009f9 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009b0:	8b 42 08             	mov    0x8(%edx),%eax
  8009b3:	83 e0 03             	and    $0x3,%eax
  8009b6:	83 f8 01             	cmp    $0x1,%eax
  8009b9:	75 21                	jne    8009dc <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009bb:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c0:	8b 40 54             	mov    0x54(%eax),%eax
  8009c3:	83 ec 04             	sub    $0x4,%esp
  8009c6:	53                   	push   %ebx
  8009c7:	50                   	push   %eax
  8009c8:	68 95 22 80 00       	push   $0x802295
  8009cd:	e8 8d 0a 00 00       	call   80145f <cprintf>
		return -E_INVAL;
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009da:	eb 26                	jmp    800a02 <read+0x8a>
	}
	if (!dev->dev_read)
  8009dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009df:	8b 40 08             	mov    0x8(%eax),%eax
  8009e2:	85 c0                	test   %eax,%eax
  8009e4:	74 17                	je     8009fd <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009e6:	83 ec 04             	sub    $0x4,%esp
  8009e9:	ff 75 10             	pushl  0x10(%ebp)
  8009ec:	ff 75 0c             	pushl  0xc(%ebp)
  8009ef:	52                   	push   %edx
  8009f0:	ff d0                	call   *%eax
  8009f2:	89 c2                	mov    %eax,%edx
  8009f4:	83 c4 10             	add    $0x10,%esp
  8009f7:	eb 09                	jmp    800a02 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	eb 05                	jmp    800a02 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8009fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a02:	89 d0                	mov    %edx,%eax
  800a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    

00800a09 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	57                   	push   %edi
  800a0d:	56                   	push   %esi
  800a0e:	53                   	push   %ebx
  800a0f:	83 ec 0c             	sub    $0xc,%esp
  800a12:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a15:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a1d:	eb 21                	jmp    800a40 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a1f:	83 ec 04             	sub    $0x4,%esp
  800a22:	89 f0                	mov    %esi,%eax
  800a24:	29 d8                	sub    %ebx,%eax
  800a26:	50                   	push   %eax
  800a27:	89 d8                	mov    %ebx,%eax
  800a29:	03 45 0c             	add    0xc(%ebp),%eax
  800a2c:	50                   	push   %eax
  800a2d:	57                   	push   %edi
  800a2e:	e8 45 ff ff ff       	call   800978 <read>
		if (m < 0)
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	85 c0                	test   %eax,%eax
  800a38:	78 10                	js     800a4a <readn+0x41>
			return m;
		if (m == 0)
  800a3a:	85 c0                	test   %eax,%eax
  800a3c:	74 0a                	je     800a48 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a3e:	01 c3                	add    %eax,%ebx
  800a40:	39 f3                	cmp    %esi,%ebx
  800a42:	72 db                	jb     800a1f <readn+0x16>
  800a44:	89 d8                	mov    %ebx,%eax
  800a46:	eb 02                	jmp    800a4a <readn+0x41>
  800a48:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	53                   	push   %ebx
  800a56:	83 ec 14             	sub    $0x14,%esp
  800a59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a5f:	50                   	push   %eax
  800a60:	53                   	push   %ebx
  800a61:	e8 ac fc ff ff       	call   800712 <fd_lookup>
  800a66:	83 c4 08             	add    $0x8,%esp
  800a69:	89 c2                	mov    %eax,%edx
  800a6b:	85 c0                	test   %eax,%eax
  800a6d:	78 68                	js     800ad7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a6f:	83 ec 08             	sub    $0x8,%esp
  800a72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a75:	50                   	push   %eax
  800a76:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a79:	ff 30                	pushl  (%eax)
  800a7b:	e8 e8 fc ff ff       	call   800768 <dev_lookup>
  800a80:	83 c4 10             	add    $0x10,%esp
  800a83:	85 c0                	test   %eax,%eax
  800a85:	78 47                	js     800ace <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a8e:	75 21                	jne    800ab1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a90:	a1 04 40 80 00       	mov    0x804004,%eax
  800a95:	8b 40 54             	mov    0x54(%eax),%eax
  800a98:	83 ec 04             	sub    $0x4,%esp
  800a9b:	53                   	push   %ebx
  800a9c:	50                   	push   %eax
  800a9d:	68 b1 22 80 00       	push   $0x8022b1
  800aa2:	e8 b8 09 00 00       	call   80145f <cprintf>
		return -E_INVAL;
  800aa7:	83 c4 10             	add    $0x10,%esp
  800aaa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800aaf:	eb 26                	jmp    800ad7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ab1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ab4:	8b 52 0c             	mov    0xc(%edx),%edx
  800ab7:	85 d2                	test   %edx,%edx
  800ab9:	74 17                	je     800ad2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800abb:	83 ec 04             	sub    $0x4,%esp
  800abe:	ff 75 10             	pushl  0x10(%ebp)
  800ac1:	ff 75 0c             	pushl  0xc(%ebp)
  800ac4:	50                   	push   %eax
  800ac5:	ff d2                	call   *%edx
  800ac7:	89 c2                	mov    %eax,%edx
  800ac9:	83 c4 10             	add    $0x10,%esp
  800acc:	eb 09                	jmp    800ad7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ace:	89 c2                	mov    %eax,%edx
  800ad0:	eb 05                	jmp    800ad7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ad2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ad7:	89 d0                	mov    %edx,%eax
  800ad9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800adc:	c9                   	leave  
  800add:	c3                   	ret    

00800ade <seek>:

int
seek(int fdnum, off_t offset)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ae4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800ae7:	50                   	push   %eax
  800ae8:	ff 75 08             	pushl  0x8(%ebp)
  800aeb:	e8 22 fc ff ff       	call   800712 <fd_lookup>
  800af0:	83 c4 08             	add    $0x8,%esp
  800af3:	85 c0                	test   %eax,%eax
  800af5:	78 0e                	js     800b05 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800af7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800afa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	83 ec 14             	sub    $0x14,%esp
  800b0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b11:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b14:	50                   	push   %eax
  800b15:	53                   	push   %ebx
  800b16:	e8 f7 fb ff ff       	call   800712 <fd_lookup>
  800b1b:	83 c4 08             	add    $0x8,%esp
  800b1e:	89 c2                	mov    %eax,%edx
  800b20:	85 c0                	test   %eax,%eax
  800b22:	78 65                	js     800b89 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b24:	83 ec 08             	sub    $0x8,%esp
  800b27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2a:	50                   	push   %eax
  800b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b2e:	ff 30                	pushl  (%eax)
  800b30:	e8 33 fc ff ff       	call   800768 <dev_lookup>
  800b35:	83 c4 10             	add    $0x10,%esp
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	78 44                	js     800b80 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b43:	75 21                	jne    800b66 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b45:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b4a:	8b 40 54             	mov    0x54(%eax),%eax
  800b4d:	83 ec 04             	sub    $0x4,%esp
  800b50:	53                   	push   %ebx
  800b51:	50                   	push   %eax
  800b52:	68 74 22 80 00       	push   $0x802274
  800b57:	e8 03 09 00 00       	call   80145f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b5c:	83 c4 10             	add    $0x10,%esp
  800b5f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b64:	eb 23                	jmp    800b89 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b66:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b69:	8b 52 18             	mov    0x18(%edx),%edx
  800b6c:	85 d2                	test   %edx,%edx
  800b6e:	74 14                	je     800b84 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b70:	83 ec 08             	sub    $0x8,%esp
  800b73:	ff 75 0c             	pushl  0xc(%ebp)
  800b76:	50                   	push   %eax
  800b77:	ff d2                	call   *%edx
  800b79:	89 c2                	mov    %eax,%edx
  800b7b:	83 c4 10             	add    $0x10,%esp
  800b7e:	eb 09                	jmp    800b89 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	eb 05                	jmp    800b89 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b84:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b89:	89 d0                	mov    %edx,%eax
  800b8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	53                   	push   %ebx
  800b94:	83 ec 14             	sub    $0x14,%esp
  800b97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b9a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b9d:	50                   	push   %eax
  800b9e:	ff 75 08             	pushl  0x8(%ebp)
  800ba1:	e8 6c fb ff ff       	call   800712 <fd_lookup>
  800ba6:	83 c4 08             	add    $0x8,%esp
  800ba9:	89 c2                	mov    %eax,%edx
  800bab:	85 c0                	test   %eax,%eax
  800bad:	78 58                	js     800c07 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800baf:	83 ec 08             	sub    $0x8,%esp
  800bb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bb5:	50                   	push   %eax
  800bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bb9:	ff 30                	pushl  (%eax)
  800bbb:	e8 a8 fb ff ff       	call   800768 <dev_lookup>
  800bc0:	83 c4 10             	add    $0x10,%esp
  800bc3:	85 c0                	test   %eax,%eax
  800bc5:	78 37                	js     800bfe <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bca:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bce:	74 32                	je     800c02 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bd0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800bd3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800bda:	00 00 00 
	stat->st_isdir = 0;
  800bdd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be4:	00 00 00 
	stat->st_dev = dev;
  800be7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bed:	83 ec 08             	sub    $0x8,%esp
  800bf0:	53                   	push   %ebx
  800bf1:	ff 75 f0             	pushl  -0x10(%ebp)
  800bf4:	ff 50 14             	call   *0x14(%eax)
  800bf7:	89 c2                	mov    %eax,%edx
  800bf9:	83 c4 10             	add    $0x10,%esp
  800bfc:	eb 09                	jmp    800c07 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bfe:	89 c2                	mov    %eax,%edx
  800c00:	eb 05                	jmp    800c07 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c02:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c07:	89 d0                	mov    %edx,%eax
  800c09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c13:	83 ec 08             	sub    $0x8,%esp
  800c16:	6a 00                	push   $0x0
  800c18:	ff 75 08             	pushl  0x8(%ebp)
  800c1b:	e8 e3 01 00 00       	call   800e03 <open>
  800c20:	89 c3                	mov    %eax,%ebx
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	85 c0                	test   %eax,%eax
  800c27:	78 1b                	js     800c44 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c29:	83 ec 08             	sub    $0x8,%esp
  800c2c:	ff 75 0c             	pushl  0xc(%ebp)
  800c2f:	50                   	push   %eax
  800c30:	e8 5b ff ff ff       	call   800b90 <fstat>
  800c35:	89 c6                	mov    %eax,%esi
	close(fd);
  800c37:	89 1c 24             	mov    %ebx,(%esp)
  800c3a:	e8 fd fb ff ff       	call   80083c <close>
	return r;
  800c3f:	83 c4 10             	add    $0x10,%esp
  800c42:	89 f0                	mov    %esi,%eax
}
  800c44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	89 c6                	mov    %eax,%esi
  800c52:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c54:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c5b:	75 12                	jne    800c6f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	6a 01                	push   $0x1
  800c62:	e8 2d 12 00 00       	call   801e94 <ipc_find_env>
  800c67:	a3 00 40 80 00       	mov    %eax,0x804000
  800c6c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c6f:	6a 07                	push   $0x7
  800c71:	68 00 50 80 00       	push   $0x805000
  800c76:	56                   	push   %esi
  800c77:	ff 35 00 40 80 00    	pushl  0x804000
  800c7d:	e8 b0 11 00 00       	call   801e32 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c82:	83 c4 0c             	add    $0xc,%esp
  800c85:	6a 00                	push   $0x0
  800c87:	53                   	push   %ebx
  800c88:	6a 00                	push   $0x0
  800c8a:	e8 2b 11 00 00       	call   801dba <ipc_recv>
}
  800c8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9f:	8b 40 0c             	mov    0xc(%eax),%eax
  800ca2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800caa:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800caf:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb4:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb9:	e8 8d ff ff ff       	call   800c4b <fsipc>
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc9:	8b 40 0c             	mov    0xc(%eax),%eax
  800ccc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800cd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdb:	e8 6b ff ff ff       	call   800c4b <fsipc>
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 04             	sub    $0x4,%esp
  800ce9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	8b 40 0c             	mov    0xc(%eax),%eax
  800cf2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800cf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfc:	b8 05 00 00 00       	mov    $0x5,%eax
  800d01:	e8 45 ff ff ff       	call   800c4b <fsipc>
  800d06:	85 c0                	test   %eax,%eax
  800d08:	78 2c                	js     800d36 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d0a:	83 ec 08             	sub    $0x8,%esp
  800d0d:	68 00 50 80 00       	push   $0x805000
  800d12:	53                   	push   %ebx
  800d13:	e8 cc 0c 00 00       	call   8019e4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d18:	a1 80 50 80 00       	mov    0x805080,%eax
  800d1d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d23:	a1 84 50 80 00       	mov    0x805084,%eax
  800d28:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	8b 52 0c             	mov    0xc(%edx),%edx
  800d4a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d50:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d55:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d5a:	0f 47 c2             	cmova  %edx,%eax
  800d5d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d62:	50                   	push   %eax
  800d63:	ff 75 0c             	pushl  0xc(%ebp)
  800d66:	68 08 50 80 00       	push   $0x805008
  800d6b:	e8 06 0e 00 00       	call   801b76 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 04 00 00 00       	mov    $0x4,%eax
  800d7a:	e8 cc fe ff ff       	call   800c4b <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d7f:	c9                   	leave  
  800d80:	c3                   	ret    

00800d81 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d89:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8c:	8b 40 0c             	mov    0xc(%eax),%eax
  800d8f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800d94:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800da4:	e8 a2 fe ff ff       	call   800c4b <fsipc>
  800da9:	89 c3                	mov    %eax,%ebx
  800dab:	85 c0                	test   %eax,%eax
  800dad:	78 4b                	js     800dfa <devfile_read+0x79>
		return r;
	assert(r <= n);
  800daf:	39 c6                	cmp    %eax,%esi
  800db1:	73 16                	jae    800dc9 <devfile_read+0x48>
  800db3:	68 e0 22 80 00       	push   $0x8022e0
  800db8:	68 e7 22 80 00       	push   $0x8022e7
  800dbd:	6a 7c                	push   $0x7c
  800dbf:	68 fc 22 80 00       	push   $0x8022fc
  800dc4:	e8 bd 05 00 00       	call   801386 <_panic>
	assert(r <= PGSIZE);
  800dc9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800dce:	7e 16                	jle    800de6 <devfile_read+0x65>
  800dd0:	68 07 23 80 00       	push   $0x802307
  800dd5:	68 e7 22 80 00       	push   $0x8022e7
  800dda:	6a 7d                	push   $0x7d
  800ddc:	68 fc 22 80 00       	push   $0x8022fc
  800de1:	e8 a0 05 00 00       	call   801386 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800de6:	83 ec 04             	sub    $0x4,%esp
  800de9:	50                   	push   %eax
  800dea:	68 00 50 80 00       	push   $0x805000
  800def:	ff 75 0c             	pushl  0xc(%ebp)
  800df2:	e8 7f 0d 00 00       	call   801b76 <memmove>
	return r;
  800df7:	83 c4 10             	add    $0x10,%esp
}
  800dfa:	89 d8                	mov    %ebx,%eax
  800dfc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	53                   	push   %ebx
  800e07:	83 ec 20             	sub    $0x20,%esp
  800e0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e0d:	53                   	push   %ebx
  800e0e:	e8 98 0b 00 00       	call   8019ab <strlen>
  800e13:	83 c4 10             	add    $0x10,%esp
  800e16:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e1b:	7f 67                	jg     800e84 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e23:	50                   	push   %eax
  800e24:	e8 9a f8 ff ff       	call   8006c3 <fd_alloc>
  800e29:	83 c4 10             	add    $0x10,%esp
		return r;
  800e2c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	78 57                	js     800e89 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e32:	83 ec 08             	sub    $0x8,%esp
  800e35:	53                   	push   %ebx
  800e36:	68 00 50 80 00       	push   $0x805000
  800e3b:	e8 a4 0b 00 00       	call   8019e4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e43:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e48:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800e50:	e8 f6 fd ff ff       	call   800c4b <fsipc>
  800e55:	89 c3                	mov    %eax,%ebx
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	79 14                	jns    800e72 <open+0x6f>
		fd_close(fd, 0);
  800e5e:	83 ec 08             	sub    $0x8,%esp
  800e61:	6a 00                	push   $0x0
  800e63:	ff 75 f4             	pushl  -0xc(%ebp)
  800e66:	e8 50 f9 ff ff       	call   8007bb <fd_close>
		return r;
  800e6b:	83 c4 10             	add    $0x10,%esp
  800e6e:	89 da                	mov    %ebx,%edx
  800e70:	eb 17                	jmp    800e89 <open+0x86>
	}

	return fd2num(fd);
  800e72:	83 ec 0c             	sub    $0xc,%esp
  800e75:	ff 75 f4             	pushl  -0xc(%ebp)
  800e78:	e8 1f f8 ff ff       	call   80069c <fd2num>
  800e7d:	89 c2                	mov    %eax,%edx
  800e7f:	83 c4 10             	add    $0x10,%esp
  800e82:	eb 05                	jmp    800e89 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e84:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e89:	89 d0                	mov    %edx,%eax
  800e8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8e:	c9                   	leave  
  800e8f:	c3                   	ret    

00800e90 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800e96:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea0:	e8 a6 fd ff ff       	call   800c4b <fsipc>
}
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    

00800ea7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800eaf:	83 ec 0c             	sub    $0xc,%esp
  800eb2:	ff 75 08             	pushl  0x8(%ebp)
  800eb5:	e8 f2 f7 ff ff       	call   8006ac <fd2data>
  800eba:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ebc:	83 c4 08             	add    $0x8,%esp
  800ebf:	68 13 23 80 00       	push   $0x802313
  800ec4:	53                   	push   %ebx
  800ec5:	e8 1a 0b 00 00       	call   8019e4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800eca:	8b 46 04             	mov    0x4(%esi),%eax
  800ecd:	2b 06                	sub    (%esi),%eax
  800ecf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ed5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800edc:	00 00 00 
	stat->st_dev = &devpipe;
  800edf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ee6:	30 80 00 
	return 0;
}
  800ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 0c             	sub    $0xc,%esp
  800efc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800eff:	53                   	push   %ebx
  800f00:	6a 00                	push   $0x0
  800f02:	e8 f7 f2 ff ff       	call   8001fe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f07:	89 1c 24             	mov    %ebx,(%esp)
  800f0a:	e8 9d f7 ff ff       	call   8006ac <fd2data>
  800f0f:	83 c4 08             	add    $0x8,%esp
  800f12:	50                   	push   %eax
  800f13:	6a 00                	push   $0x0
  800f15:	e8 e4 f2 ff ff       	call   8001fe <sys_page_unmap>
}
  800f1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	83 ec 1c             	sub    $0x1c,%esp
  800f28:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f2b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f2d:	a1 04 40 80 00       	mov    0x804004,%eax
  800f32:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f35:	83 ec 0c             	sub    $0xc,%esp
  800f38:	ff 75 e0             	pushl  -0x20(%ebp)
  800f3b:	e8 94 0f 00 00       	call   801ed4 <pageref>
  800f40:	89 c3                	mov    %eax,%ebx
  800f42:	89 3c 24             	mov    %edi,(%esp)
  800f45:	e8 8a 0f 00 00       	call   801ed4 <pageref>
  800f4a:	83 c4 10             	add    $0x10,%esp
  800f4d:	39 c3                	cmp    %eax,%ebx
  800f4f:	0f 94 c1             	sete   %cl
  800f52:	0f b6 c9             	movzbl %cl,%ecx
  800f55:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f58:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f5e:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  800f61:	39 ce                	cmp    %ecx,%esi
  800f63:	74 1b                	je     800f80 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800f65:	39 c3                	cmp    %eax,%ebx
  800f67:	75 c4                	jne    800f2d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f69:	8b 42 64             	mov    0x64(%edx),%eax
  800f6c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f6f:	50                   	push   %eax
  800f70:	56                   	push   %esi
  800f71:	68 1a 23 80 00       	push   $0x80231a
  800f76:	e8 e4 04 00 00       	call   80145f <cprintf>
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	eb ad                	jmp    800f2d <_pipeisclosed+0xe>
	}
}
  800f80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f86:	5b                   	pop    %ebx
  800f87:	5e                   	pop    %esi
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	57                   	push   %edi
  800f8f:	56                   	push   %esi
  800f90:	53                   	push   %ebx
  800f91:	83 ec 28             	sub    $0x28,%esp
  800f94:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800f97:	56                   	push   %esi
  800f98:	e8 0f f7 ff ff       	call   8006ac <fd2data>
  800f9d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	bf 00 00 00 00       	mov    $0x0,%edi
  800fa7:	eb 4b                	jmp    800ff4 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fa9:	89 da                	mov    %ebx,%edx
  800fab:	89 f0                	mov    %esi,%eax
  800fad:	e8 6d ff ff ff       	call   800f1f <_pipeisclosed>
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	75 48                	jne    800ffe <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fb6:	e8 9f f1 ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fbb:	8b 43 04             	mov    0x4(%ebx),%eax
  800fbe:	8b 0b                	mov    (%ebx),%ecx
  800fc0:	8d 51 20             	lea    0x20(%ecx),%edx
  800fc3:	39 d0                	cmp    %edx,%eax
  800fc5:	73 e2                	jae    800fa9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fca:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fce:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fd1:	89 c2                	mov    %eax,%edx
  800fd3:	c1 fa 1f             	sar    $0x1f,%edx
  800fd6:	89 d1                	mov    %edx,%ecx
  800fd8:	c1 e9 1b             	shr    $0x1b,%ecx
  800fdb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800fde:	83 e2 1f             	and    $0x1f,%edx
  800fe1:	29 ca                	sub    %ecx,%edx
  800fe3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800fe7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800feb:	83 c0 01             	add    $0x1,%eax
  800fee:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ff1:	83 c7 01             	add    $0x1,%edi
  800ff4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ff7:	75 c2                	jne    800fbb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ff9:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffc:	eb 05                	jmp    801003 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ffe:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	83 ec 18             	sub    $0x18,%esp
  801014:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801017:	57                   	push   %edi
  801018:	e8 8f f6 ff ff       	call   8006ac <fd2data>
  80101d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	bb 00 00 00 00       	mov    $0x0,%ebx
  801027:	eb 3d                	jmp    801066 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801029:	85 db                	test   %ebx,%ebx
  80102b:	74 04                	je     801031 <devpipe_read+0x26>
				return i;
  80102d:	89 d8                	mov    %ebx,%eax
  80102f:	eb 44                	jmp    801075 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801031:	89 f2                	mov    %esi,%edx
  801033:	89 f8                	mov    %edi,%eax
  801035:	e8 e5 fe ff ff       	call   800f1f <_pipeisclosed>
  80103a:	85 c0                	test   %eax,%eax
  80103c:	75 32                	jne    801070 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80103e:	e8 17 f1 ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801043:	8b 06                	mov    (%esi),%eax
  801045:	3b 46 04             	cmp    0x4(%esi),%eax
  801048:	74 df                	je     801029 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80104a:	99                   	cltd   
  80104b:	c1 ea 1b             	shr    $0x1b,%edx
  80104e:	01 d0                	add    %edx,%eax
  801050:	83 e0 1f             	and    $0x1f,%eax
  801053:	29 d0                	sub    %edx,%eax
  801055:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80105a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801060:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801063:	83 c3 01             	add    $0x1,%ebx
  801066:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801069:	75 d8                	jne    801043 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80106b:	8b 45 10             	mov    0x10(%ebp),%eax
  80106e:	eb 05                	jmp    801075 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801070:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801075:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	56                   	push   %esi
  801081:	53                   	push   %ebx
  801082:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801085:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801088:	50                   	push   %eax
  801089:	e8 35 f6 ff ff       	call   8006c3 <fd_alloc>
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	89 c2                	mov    %eax,%edx
  801093:	85 c0                	test   %eax,%eax
  801095:	0f 88 2c 01 00 00    	js     8011c7 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80109b:	83 ec 04             	sub    $0x4,%esp
  80109e:	68 07 04 00 00       	push   $0x407
  8010a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a6:	6a 00                	push   $0x0
  8010a8:	e8 cc f0 ff ff       	call   800179 <sys_page_alloc>
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	89 c2                	mov    %eax,%edx
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	0f 88 0d 01 00 00    	js     8011c7 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c0:	50                   	push   %eax
  8010c1:	e8 fd f5 ff ff       	call   8006c3 <fd_alloc>
  8010c6:	89 c3                	mov    %eax,%ebx
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	0f 88 e2 00 00 00    	js     8011b5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	68 07 04 00 00       	push   $0x407
  8010db:	ff 75 f0             	pushl  -0x10(%ebp)
  8010de:	6a 00                	push   $0x0
  8010e0:	e8 94 f0 ff ff       	call   800179 <sys_page_alloc>
  8010e5:	89 c3                	mov    %eax,%ebx
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	0f 88 c3 00 00 00    	js     8011b5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8010f2:	83 ec 0c             	sub    $0xc,%esp
  8010f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8010f8:	e8 af f5 ff ff       	call   8006ac <fd2data>
  8010fd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010ff:	83 c4 0c             	add    $0xc,%esp
  801102:	68 07 04 00 00       	push   $0x407
  801107:	50                   	push   %eax
  801108:	6a 00                	push   $0x0
  80110a:	e8 6a f0 ff ff       	call   800179 <sys_page_alloc>
  80110f:	89 c3                	mov    %eax,%ebx
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	0f 88 89 00 00 00    	js     8011a5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80111c:	83 ec 0c             	sub    $0xc,%esp
  80111f:	ff 75 f0             	pushl  -0x10(%ebp)
  801122:	e8 85 f5 ff ff       	call   8006ac <fd2data>
  801127:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80112e:	50                   	push   %eax
  80112f:	6a 00                	push   $0x0
  801131:	56                   	push   %esi
  801132:	6a 00                	push   $0x0
  801134:	e8 83 f0 ff ff       	call   8001bc <sys_page_map>
  801139:	89 c3                	mov    %eax,%ebx
  80113b:	83 c4 20             	add    $0x20,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 55                	js     801197 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801142:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80114d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801150:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801157:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80115d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801160:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	ff 75 f4             	pushl  -0xc(%ebp)
  801172:	e8 25 f5 ff ff       	call   80069c <fd2num>
  801177:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80117c:	83 c4 04             	add    $0x4,%esp
  80117f:	ff 75 f0             	pushl  -0x10(%ebp)
  801182:	e8 15 f5 ff ff       	call   80069c <fd2num>
  801187:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118a:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	ba 00 00 00 00       	mov    $0x0,%edx
  801195:	eb 30                	jmp    8011c7 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801197:	83 ec 08             	sub    $0x8,%esp
  80119a:	56                   	push   %esi
  80119b:	6a 00                	push   $0x0
  80119d:	e8 5c f0 ff ff       	call   8001fe <sys_page_unmap>
  8011a2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	ff 75 f0             	pushl  -0x10(%ebp)
  8011ab:	6a 00                	push   $0x0
  8011ad:	e8 4c f0 ff ff       	call   8001fe <sys_page_unmap>
  8011b2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011b5:	83 ec 08             	sub    $0x8,%esp
  8011b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8011bb:	6a 00                	push   $0x0
  8011bd:	e8 3c f0 ff ff       	call   8001fe <sys_page_unmap>
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011c7:	89 d0                	mov    %edx,%eax
  8011c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    

008011d0 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	ff 75 08             	pushl  0x8(%ebp)
  8011dd:	e8 30 f5 ff ff       	call   800712 <fd_lookup>
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	78 18                	js     801201 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ef:	e8 b8 f4 ff ff       	call   8006ac <fd2data>
	return _pipeisclosed(fd, p);
  8011f4:	89 c2                	mov    %eax,%edx
  8011f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f9:	e8 21 fd ff ff       	call   800f1f <_pipeisclosed>
  8011fe:	83 c4 10             	add    $0x10,%esp
}
  801201:	c9                   	leave  
  801202:	c3                   	ret    

00801203 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801206:	b8 00 00 00 00       	mov    $0x0,%eax
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801213:	68 32 23 80 00       	push   $0x802332
  801218:	ff 75 0c             	pushl  0xc(%ebp)
  80121b:	e8 c4 07 00 00       	call   8019e4 <strcpy>
	return 0;
}
  801220:	b8 00 00 00 00       	mov    $0x0,%eax
  801225:	c9                   	leave  
  801226:	c3                   	ret    

00801227 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	57                   	push   %edi
  80122b:	56                   	push   %esi
  80122c:	53                   	push   %ebx
  80122d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801233:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801238:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80123e:	eb 2d                	jmp    80126d <devcons_write+0x46>
		m = n - tot;
  801240:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801243:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801245:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801248:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80124d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801250:	83 ec 04             	sub    $0x4,%esp
  801253:	53                   	push   %ebx
  801254:	03 45 0c             	add    0xc(%ebp),%eax
  801257:	50                   	push   %eax
  801258:	57                   	push   %edi
  801259:	e8 18 09 00 00       	call   801b76 <memmove>
		sys_cputs(buf, m);
  80125e:	83 c4 08             	add    $0x8,%esp
  801261:	53                   	push   %ebx
  801262:	57                   	push   %edi
  801263:	e8 55 ee ff ff       	call   8000bd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801268:	01 de                	add    %ebx,%esi
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	89 f0                	mov    %esi,%eax
  80126f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801272:	72 cc                	jb     801240 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801274:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801277:	5b                   	pop    %ebx
  801278:	5e                   	pop    %esi
  801279:	5f                   	pop    %edi
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801287:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80128b:	74 2a                	je     8012b7 <devcons_read+0x3b>
  80128d:	eb 05                	jmp    801294 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80128f:	e8 c6 ee ff ff       	call   80015a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801294:	e8 42 ee ff ff       	call   8000db <sys_cgetc>
  801299:	85 c0                	test   %eax,%eax
  80129b:	74 f2                	je     80128f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 16                	js     8012b7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012a1:	83 f8 04             	cmp    $0x4,%eax
  8012a4:	74 0c                	je     8012b2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a9:	88 02                	mov    %al,(%edx)
	return 1;
  8012ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b0:	eb 05                	jmp    8012b7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012b2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012c5:	6a 01                	push   $0x1
  8012c7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012ca:	50                   	push   %eax
  8012cb:	e8 ed ed ff ff       	call   8000bd <sys_cputs>
}
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    

008012d5 <getchar>:

int
getchar(void)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012db:	6a 01                	push   $0x1
  8012dd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	6a 00                	push   $0x0
  8012e3:	e8 90 f6 ff ff       	call   800978 <read>
	if (r < 0)
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 0f                	js     8012fe <getchar+0x29>
		return r;
	if (r < 1)
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	7e 06                	jle    8012f9 <getchar+0x24>
		return -E_EOF;
	return c;
  8012f3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8012f7:	eb 05                	jmp    8012fe <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8012f9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	ff 75 08             	pushl  0x8(%ebp)
  80130d:	e8 00 f4 ff ff       	call   800712 <fd_lookup>
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 11                	js     80132a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801319:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801322:	39 10                	cmp    %edx,(%eax)
  801324:	0f 94 c0             	sete   %al
  801327:	0f b6 c0             	movzbl %al,%eax
}
  80132a:	c9                   	leave  
  80132b:	c3                   	ret    

0080132c <opencons>:

int
opencons(void)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801332:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	e8 88 f3 ff ff       	call   8006c3 <fd_alloc>
  80133b:	83 c4 10             	add    $0x10,%esp
		return r;
  80133e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801340:	85 c0                	test   %eax,%eax
  801342:	78 3e                	js     801382 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801344:	83 ec 04             	sub    $0x4,%esp
  801347:	68 07 04 00 00       	push   $0x407
  80134c:	ff 75 f4             	pushl  -0xc(%ebp)
  80134f:	6a 00                	push   $0x0
  801351:	e8 23 ee ff ff       	call   800179 <sys_page_alloc>
  801356:	83 c4 10             	add    $0x10,%esp
		return r;
  801359:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 23                	js     801382 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80135f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801368:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80136a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801374:	83 ec 0c             	sub    $0xc,%esp
  801377:	50                   	push   %eax
  801378:	e8 1f f3 ff ff       	call   80069c <fd2num>
  80137d:	89 c2                	mov    %eax,%edx
  80137f:	83 c4 10             	add    $0x10,%esp
}
  801382:	89 d0                	mov    %edx,%eax
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	56                   	push   %esi
  80138a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80138b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80138e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801394:	e8 a2 ed ff ff       	call   80013b <sys_getenvid>
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	ff 75 0c             	pushl  0xc(%ebp)
  80139f:	ff 75 08             	pushl  0x8(%ebp)
  8013a2:	56                   	push   %esi
  8013a3:	50                   	push   %eax
  8013a4:	68 40 23 80 00       	push   $0x802340
  8013a9:	e8 b1 00 00 00       	call   80145f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013ae:	83 c4 18             	add    $0x18,%esp
  8013b1:	53                   	push   %ebx
  8013b2:	ff 75 10             	pushl  0x10(%ebp)
  8013b5:	e8 54 00 00 00       	call   80140e <vcprintf>
	cprintf("\n");
  8013ba:	c7 04 24 2b 23 80 00 	movl   $0x80232b,(%esp)
  8013c1:	e8 99 00 00 00       	call   80145f <cprintf>
  8013c6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013c9:	cc                   	int3   
  8013ca:	eb fd                	jmp    8013c9 <_panic+0x43>

008013cc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	53                   	push   %ebx
  8013d0:	83 ec 04             	sub    $0x4,%esp
  8013d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013d6:	8b 13                	mov    (%ebx),%edx
  8013d8:	8d 42 01             	lea    0x1(%edx),%eax
  8013db:	89 03                	mov    %eax,(%ebx)
  8013dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013e4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013e9:	75 1a                	jne    801405 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	68 ff 00 00 00       	push   $0xff
  8013f3:	8d 43 08             	lea    0x8(%ebx),%eax
  8013f6:	50                   	push   %eax
  8013f7:	e8 c1 ec ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  8013fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801402:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801405:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801409:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801417:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80141e:	00 00 00 
	b.cnt = 0;
  801421:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801428:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80142b:	ff 75 0c             	pushl  0xc(%ebp)
  80142e:	ff 75 08             	pushl  0x8(%ebp)
  801431:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801437:	50                   	push   %eax
  801438:	68 cc 13 80 00       	push   $0x8013cc
  80143d:	e8 54 01 00 00       	call   801596 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801442:	83 c4 08             	add    $0x8,%esp
  801445:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80144b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	e8 66 ec ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  801457:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80145d:	c9                   	leave  
  80145e:	c3                   	ret    

0080145f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801465:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801468:	50                   	push   %eax
  801469:	ff 75 08             	pushl  0x8(%ebp)
  80146c:	e8 9d ff ff ff       	call   80140e <vcprintf>
	va_end(ap);

	return cnt;
}
  801471:	c9                   	leave  
  801472:	c3                   	ret    

00801473 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	57                   	push   %edi
  801477:	56                   	push   %esi
  801478:	53                   	push   %ebx
  801479:	83 ec 1c             	sub    $0x1c,%esp
  80147c:	89 c7                	mov    %eax,%edi
  80147e:	89 d6                	mov    %edx,%esi
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
  801483:	8b 55 0c             	mov    0xc(%ebp),%edx
  801486:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801489:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80148c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80148f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801494:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801497:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80149a:	39 d3                	cmp    %edx,%ebx
  80149c:	72 05                	jb     8014a3 <printnum+0x30>
  80149e:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014a1:	77 45                	ja     8014e8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	ff 75 18             	pushl  0x18(%ebp)
  8014a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ac:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014af:	53                   	push   %ebx
  8014b0:	ff 75 10             	pushl  0x10(%ebp)
  8014b3:	83 ec 08             	sub    $0x8,%esp
  8014b6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014b9:	ff 75 e0             	pushl  -0x20(%ebp)
  8014bc:	ff 75 dc             	pushl  -0x24(%ebp)
  8014bf:	ff 75 d8             	pushl  -0x28(%ebp)
  8014c2:	e8 49 0a 00 00       	call   801f10 <__udivdi3>
  8014c7:	83 c4 18             	add    $0x18,%esp
  8014ca:	52                   	push   %edx
  8014cb:	50                   	push   %eax
  8014cc:	89 f2                	mov    %esi,%edx
  8014ce:	89 f8                	mov    %edi,%eax
  8014d0:	e8 9e ff ff ff       	call   801473 <printnum>
  8014d5:	83 c4 20             	add    $0x20,%esp
  8014d8:	eb 18                	jmp    8014f2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	56                   	push   %esi
  8014de:	ff 75 18             	pushl  0x18(%ebp)
  8014e1:	ff d7                	call   *%edi
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	eb 03                	jmp    8014eb <printnum+0x78>
  8014e8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014eb:	83 eb 01             	sub    $0x1,%ebx
  8014ee:	85 db                	test   %ebx,%ebx
  8014f0:	7f e8                	jg     8014da <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014f2:	83 ec 08             	sub    $0x8,%esp
  8014f5:	56                   	push   %esi
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8014ff:	ff 75 dc             	pushl  -0x24(%ebp)
  801502:	ff 75 d8             	pushl  -0x28(%ebp)
  801505:	e8 36 0b 00 00       	call   802040 <__umoddi3>
  80150a:	83 c4 14             	add    $0x14,%esp
  80150d:	0f be 80 63 23 80 00 	movsbl 0x802363(%eax),%eax
  801514:	50                   	push   %eax
  801515:	ff d7                	call   *%edi
}
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80151d:	5b                   	pop    %ebx
  80151e:	5e                   	pop    %esi
  80151f:	5f                   	pop    %edi
  801520:	5d                   	pop    %ebp
  801521:	c3                   	ret    

00801522 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801522:	55                   	push   %ebp
  801523:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801525:	83 fa 01             	cmp    $0x1,%edx
  801528:	7e 0e                	jle    801538 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80152a:	8b 10                	mov    (%eax),%edx
  80152c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80152f:	89 08                	mov    %ecx,(%eax)
  801531:	8b 02                	mov    (%edx),%eax
  801533:	8b 52 04             	mov    0x4(%edx),%edx
  801536:	eb 22                	jmp    80155a <getuint+0x38>
	else if (lflag)
  801538:	85 d2                	test   %edx,%edx
  80153a:	74 10                	je     80154c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80153c:	8b 10                	mov    (%eax),%edx
  80153e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801541:	89 08                	mov    %ecx,(%eax)
  801543:	8b 02                	mov    (%edx),%eax
  801545:	ba 00 00 00 00       	mov    $0x0,%edx
  80154a:	eb 0e                	jmp    80155a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80154c:	8b 10                	mov    (%eax),%edx
  80154e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801551:	89 08                	mov    %ecx,(%eax)
  801553:	8b 02                	mov    (%edx),%eax
  801555:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80155a:	5d                   	pop    %ebp
  80155b:	c3                   	ret    

0080155c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801562:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801566:	8b 10                	mov    (%eax),%edx
  801568:	3b 50 04             	cmp    0x4(%eax),%edx
  80156b:	73 0a                	jae    801577 <sprintputch+0x1b>
		*b->buf++ = ch;
  80156d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801570:	89 08                	mov    %ecx,(%eax)
  801572:	8b 45 08             	mov    0x8(%ebp),%eax
  801575:	88 02                	mov    %al,(%edx)
}
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    

00801579 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80157f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801582:	50                   	push   %eax
  801583:	ff 75 10             	pushl  0x10(%ebp)
  801586:	ff 75 0c             	pushl  0xc(%ebp)
  801589:	ff 75 08             	pushl  0x8(%ebp)
  80158c:	e8 05 00 00 00       	call   801596 <vprintfmt>
	va_end(ap);
}
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	c9                   	leave  
  801595:	c3                   	ret    

00801596 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	57                   	push   %edi
  80159a:	56                   	push   %esi
  80159b:	53                   	push   %ebx
  80159c:	83 ec 2c             	sub    $0x2c,%esp
  80159f:	8b 75 08             	mov    0x8(%ebp),%esi
  8015a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015a5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015a8:	eb 12                	jmp    8015bc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	0f 84 89 03 00 00    	je     80193b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	50                   	push   %eax
  8015b7:	ff d6                	call   *%esi
  8015b9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015bc:	83 c7 01             	add    $0x1,%edi
  8015bf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015c3:	83 f8 25             	cmp    $0x25,%eax
  8015c6:	75 e2                	jne    8015aa <vprintfmt+0x14>
  8015c8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015cc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015d3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015da:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e6:	eb 07                	jmp    8015ef <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015eb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ef:	8d 47 01             	lea    0x1(%edi),%eax
  8015f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015f5:	0f b6 07             	movzbl (%edi),%eax
  8015f8:	0f b6 c8             	movzbl %al,%ecx
  8015fb:	83 e8 23             	sub    $0x23,%eax
  8015fe:	3c 55                	cmp    $0x55,%al
  801600:	0f 87 1a 03 00 00    	ja     801920 <vprintfmt+0x38a>
  801606:	0f b6 c0             	movzbl %al,%eax
  801609:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
  801610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801613:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801617:	eb d6                	jmp    8015ef <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801619:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80161c:	b8 00 00 00 00       	mov    $0x0,%eax
  801621:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801624:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801627:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80162b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80162e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801631:	83 fa 09             	cmp    $0x9,%edx
  801634:	77 39                	ja     80166f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801636:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801639:	eb e9                	jmp    801624 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80163b:	8b 45 14             	mov    0x14(%ebp),%eax
  80163e:	8d 48 04             	lea    0x4(%eax),%ecx
  801641:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801644:	8b 00                	mov    (%eax),%eax
  801646:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801649:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80164c:	eb 27                	jmp    801675 <vprintfmt+0xdf>
  80164e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801651:	85 c0                	test   %eax,%eax
  801653:	b9 00 00 00 00       	mov    $0x0,%ecx
  801658:	0f 49 c8             	cmovns %eax,%ecx
  80165b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80165e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801661:	eb 8c                	jmp    8015ef <vprintfmt+0x59>
  801663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801666:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80166d:	eb 80                	jmp    8015ef <vprintfmt+0x59>
  80166f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801672:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801675:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801679:	0f 89 70 ff ff ff    	jns    8015ef <vprintfmt+0x59>
				width = precision, precision = -1;
  80167f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801682:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801685:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80168c:	e9 5e ff ff ff       	jmp    8015ef <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801691:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801697:	e9 53 ff ff ff       	jmp    8015ef <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80169c:	8b 45 14             	mov    0x14(%ebp),%eax
  80169f:	8d 50 04             	lea    0x4(%eax),%edx
  8016a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8016a5:	83 ec 08             	sub    $0x8,%esp
  8016a8:	53                   	push   %ebx
  8016a9:	ff 30                	pushl  (%eax)
  8016ab:	ff d6                	call   *%esi
			break;
  8016ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016b3:	e9 04 ff ff ff       	jmp    8015bc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016bb:	8d 50 04             	lea    0x4(%eax),%edx
  8016be:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c1:	8b 00                	mov    (%eax),%eax
  8016c3:	99                   	cltd   
  8016c4:	31 d0                	xor    %edx,%eax
  8016c6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016c8:	83 f8 0f             	cmp    $0xf,%eax
  8016cb:	7f 0b                	jg     8016d8 <vprintfmt+0x142>
  8016cd:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  8016d4:	85 d2                	test   %edx,%edx
  8016d6:	75 18                	jne    8016f0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016d8:	50                   	push   %eax
  8016d9:	68 7b 23 80 00       	push   $0x80237b
  8016de:	53                   	push   %ebx
  8016df:	56                   	push   %esi
  8016e0:	e8 94 fe ff ff       	call   801579 <printfmt>
  8016e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016eb:	e9 cc fe ff ff       	jmp    8015bc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8016f0:	52                   	push   %edx
  8016f1:	68 f9 22 80 00       	push   $0x8022f9
  8016f6:	53                   	push   %ebx
  8016f7:	56                   	push   %esi
  8016f8:	e8 7c fe ff ff       	call   801579 <printfmt>
  8016fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801700:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801703:	e9 b4 fe ff ff       	jmp    8015bc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801708:	8b 45 14             	mov    0x14(%ebp),%eax
  80170b:	8d 50 04             	lea    0x4(%eax),%edx
  80170e:	89 55 14             	mov    %edx,0x14(%ebp)
  801711:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801713:	85 ff                	test   %edi,%edi
  801715:	b8 74 23 80 00       	mov    $0x802374,%eax
  80171a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80171d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801721:	0f 8e 94 00 00 00    	jle    8017bb <vprintfmt+0x225>
  801727:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80172b:	0f 84 98 00 00 00    	je     8017c9 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	ff 75 d0             	pushl  -0x30(%ebp)
  801737:	57                   	push   %edi
  801738:	e8 86 02 00 00       	call   8019c3 <strnlen>
  80173d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801740:	29 c1                	sub    %eax,%ecx
  801742:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801745:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801748:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80174c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80174f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801752:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801754:	eb 0f                	jmp    801765 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	53                   	push   %ebx
  80175a:	ff 75 e0             	pushl  -0x20(%ebp)
  80175d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80175f:	83 ef 01             	sub    $0x1,%edi
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 ff                	test   %edi,%edi
  801767:	7f ed                	jg     801756 <vprintfmt+0x1c0>
  801769:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80176c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80176f:	85 c9                	test   %ecx,%ecx
  801771:	b8 00 00 00 00       	mov    $0x0,%eax
  801776:	0f 49 c1             	cmovns %ecx,%eax
  801779:	29 c1                	sub    %eax,%ecx
  80177b:	89 75 08             	mov    %esi,0x8(%ebp)
  80177e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801781:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801784:	89 cb                	mov    %ecx,%ebx
  801786:	eb 4d                	jmp    8017d5 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801788:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80178c:	74 1b                	je     8017a9 <vprintfmt+0x213>
  80178e:	0f be c0             	movsbl %al,%eax
  801791:	83 e8 20             	sub    $0x20,%eax
  801794:	83 f8 5e             	cmp    $0x5e,%eax
  801797:	76 10                	jbe    8017a9 <vprintfmt+0x213>
					putch('?', putdat);
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	ff 75 0c             	pushl  0xc(%ebp)
  80179f:	6a 3f                	push   $0x3f
  8017a1:	ff 55 08             	call   *0x8(%ebp)
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	eb 0d                	jmp    8017b6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017a9:	83 ec 08             	sub    $0x8,%esp
  8017ac:	ff 75 0c             	pushl  0xc(%ebp)
  8017af:	52                   	push   %edx
  8017b0:	ff 55 08             	call   *0x8(%ebp)
  8017b3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017b6:	83 eb 01             	sub    $0x1,%ebx
  8017b9:	eb 1a                	jmp    8017d5 <vprintfmt+0x23f>
  8017bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8017be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017c4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017c7:	eb 0c                	jmp    8017d5 <vprintfmt+0x23f>
  8017c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8017cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017d5:	83 c7 01             	add    $0x1,%edi
  8017d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017dc:	0f be d0             	movsbl %al,%edx
  8017df:	85 d2                	test   %edx,%edx
  8017e1:	74 23                	je     801806 <vprintfmt+0x270>
  8017e3:	85 f6                	test   %esi,%esi
  8017e5:	78 a1                	js     801788 <vprintfmt+0x1f2>
  8017e7:	83 ee 01             	sub    $0x1,%esi
  8017ea:	79 9c                	jns    801788 <vprintfmt+0x1f2>
  8017ec:	89 df                	mov    %ebx,%edi
  8017ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017f4:	eb 18                	jmp    80180e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	53                   	push   %ebx
  8017fa:	6a 20                	push   $0x20
  8017fc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8017fe:	83 ef 01             	sub    $0x1,%edi
  801801:	83 c4 10             	add    $0x10,%esp
  801804:	eb 08                	jmp    80180e <vprintfmt+0x278>
  801806:	89 df                	mov    %ebx,%edi
  801808:	8b 75 08             	mov    0x8(%ebp),%esi
  80180b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80180e:	85 ff                	test   %edi,%edi
  801810:	7f e4                	jg     8017f6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801812:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801815:	e9 a2 fd ff ff       	jmp    8015bc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80181a:	83 fa 01             	cmp    $0x1,%edx
  80181d:	7e 16                	jle    801835 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80181f:	8b 45 14             	mov    0x14(%ebp),%eax
  801822:	8d 50 08             	lea    0x8(%eax),%edx
  801825:	89 55 14             	mov    %edx,0x14(%ebp)
  801828:	8b 50 04             	mov    0x4(%eax),%edx
  80182b:	8b 00                	mov    (%eax),%eax
  80182d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801830:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801833:	eb 32                	jmp    801867 <vprintfmt+0x2d1>
	else if (lflag)
  801835:	85 d2                	test   %edx,%edx
  801837:	74 18                	je     801851 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801839:	8b 45 14             	mov    0x14(%ebp),%eax
  80183c:	8d 50 04             	lea    0x4(%eax),%edx
  80183f:	89 55 14             	mov    %edx,0x14(%ebp)
  801842:	8b 00                	mov    (%eax),%eax
  801844:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801847:	89 c1                	mov    %eax,%ecx
  801849:	c1 f9 1f             	sar    $0x1f,%ecx
  80184c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80184f:	eb 16                	jmp    801867 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801851:	8b 45 14             	mov    0x14(%ebp),%eax
  801854:	8d 50 04             	lea    0x4(%eax),%edx
  801857:	89 55 14             	mov    %edx,0x14(%ebp)
  80185a:	8b 00                	mov    (%eax),%eax
  80185c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80185f:	89 c1                	mov    %eax,%ecx
  801861:	c1 f9 1f             	sar    $0x1f,%ecx
  801864:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801867:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80186a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80186d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801872:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801876:	79 74                	jns    8018ec <vprintfmt+0x356>
				putch('-', putdat);
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	53                   	push   %ebx
  80187c:	6a 2d                	push   $0x2d
  80187e:	ff d6                	call   *%esi
				num = -(long long) num;
  801880:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801883:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801886:	f7 d8                	neg    %eax
  801888:	83 d2 00             	adc    $0x0,%edx
  80188b:	f7 da                	neg    %edx
  80188d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801890:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801895:	eb 55                	jmp    8018ec <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801897:	8d 45 14             	lea    0x14(%ebp),%eax
  80189a:	e8 83 fc ff ff       	call   801522 <getuint>
			base = 10;
  80189f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018a4:	eb 46                	jmp    8018ec <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8018a9:	e8 74 fc ff ff       	call   801522 <getuint>
			base = 8;
  8018ae:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018b3:	eb 37                	jmp    8018ec <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018b5:	83 ec 08             	sub    $0x8,%esp
  8018b8:	53                   	push   %ebx
  8018b9:	6a 30                	push   $0x30
  8018bb:	ff d6                	call   *%esi
			putch('x', putdat);
  8018bd:	83 c4 08             	add    $0x8,%esp
  8018c0:	53                   	push   %ebx
  8018c1:	6a 78                	push   $0x78
  8018c3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c8:	8d 50 04             	lea    0x4(%eax),%edx
  8018cb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018ce:	8b 00                	mov    (%eax),%eax
  8018d0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018d5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018d8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018dd:	eb 0d                	jmp    8018ec <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018df:	8d 45 14             	lea    0x14(%ebp),%eax
  8018e2:	e8 3b fc ff ff       	call   801522 <getuint>
			base = 16;
  8018e7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018ec:	83 ec 0c             	sub    $0xc,%esp
  8018ef:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8018f3:	57                   	push   %edi
  8018f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8018f7:	51                   	push   %ecx
  8018f8:	52                   	push   %edx
  8018f9:	50                   	push   %eax
  8018fa:	89 da                	mov    %ebx,%edx
  8018fc:	89 f0                	mov    %esi,%eax
  8018fe:	e8 70 fb ff ff       	call   801473 <printnum>
			break;
  801903:	83 c4 20             	add    $0x20,%esp
  801906:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801909:	e9 ae fc ff ff       	jmp    8015bc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80190e:	83 ec 08             	sub    $0x8,%esp
  801911:	53                   	push   %ebx
  801912:	51                   	push   %ecx
  801913:	ff d6                	call   *%esi
			break;
  801915:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801918:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80191b:	e9 9c fc ff ff       	jmp    8015bc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801920:	83 ec 08             	sub    $0x8,%esp
  801923:	53                   	push   %ebx
  801924:	6a 25                	push   $0x25
  801926:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	eb 03                	jmp    801930 <vprintfmt+0x39a>
  80192d:	83 ef 01             	sub    $0x1,%edi
  801930:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801934:	75 f7                	jne    80192d <vprintfmt+0x397>
  801936:	e9 81 fc ff ff       	jmp    8015bc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80193b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80193e:	5b                   	pop    %ebx
  80193f:	5e                   	pop    %esi
  801940:	5f                   	pop    %edi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 18             	sub    $0x18,%esp
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80194f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801952:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801956:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801959:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801960:	85 c0                	test   %eax,%eax
  801962:	74 26                	je     80198a <vsnprintf+0x47>
  801964:	85 d2                	test   %edx,%edx
  801966:	7e 22                	jle    80198a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801968:	ff 75 14             	pushl  0x14(%ebp)
  80196b:	ff 75 10             	pushl  0x10(%ebp)
  80196e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801971:	50                   	push   %eax
  801972:	68 5c 15 80 00       	push   $0x80155c
  801977:	e8 1a fc ff ff       	call   801596 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80197c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80197f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801982:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	eb 05                	jmp    80198f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80198a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801997:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80199a:	50                   	push   %eax
  80199b:	ff 75 10             	pushl  0x10(%ebp)
  80199e:	ff 75 0c             	pushl  0xc(%ebp)
  8019a1:	ff 75 08             	pushl  0x8(%ebp)
  8019a4:	e8 9a ff ff ff       	call   801943 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019a9:	c9                   	leave  
  8019aa:	c3                   	ret    

008019ab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019ab:	55                   	push   %ebp
  8019ac:	89 e5                	mov    %esp,%ebp
  8019ae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b6:	eb 03                	jmp    8019bb <strlen+0x10>
		n++;
  8019b8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019bf:	75 f7                	jne    8019b8 <strlen+0xd>
		n++;
	return n;
}
  8019c1:	5d                   	pop    %ebp
  8019c2:	c3                   	ret    

008019c3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d1:	eb 03                	jmp    8019d6 <strnlen+0x13>
		n++;
  8019d3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019d6:	39 c2                	cmp    %eax,%edx
  8019d8:	74 08                	je     8019e2 <strnlen+0x1f>
  8019da:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019de:	75 f3                	jne    8019d3 <strnlen+0x10>
  8019e0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    

008019e4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	53                   	push   %ebx
  8019e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019ee:	89 c2                	mov    %eax,%edx
  8019f0:	83 c2 01             	add    $0x1,%edx
  8019f3:	83 c1 01             	add    $0x1,%ecx
  8019f6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8019fa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8019fd:	84 db                	test   %bl,%bl
  8019ff:	75 ef                	jne    8019f0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a01:	5b                   	pop    %ebx
  801a02:	5d                   	pop    %ebp
  801a03:	c3                   	ret    

00801a04 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	53                   	push   %ebx
  801a08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a0b:	53                   	push   %ebx
  801a0c:	e8 9a ff ff ff       	call   8019ab <strlen>
  801a11:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a14:	ff 75 0c             	pushl  0xc(%ebp)
  801a17:	01 d8                	add    %ebx,%eax
  801a19:	50                   	push   %eax
  801a1a:	e8 c5 ff ff ff       	call   8019e4 <strcpy>
	return dst;
}
  801a1f:	89 d8                	mov    %ebx,%eax
  801a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a24:	c9                   	leave  
  801a25:	c3                   	ret    

00801a26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	56                   	push   %esi
  801a2a:	53                   	push   %ebx
  801a2b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a31:	89 f3                	mov    %esi,%ebx
  801a33:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a36:	89 f2                	mov    %esi,%edx
  801a38:	eb 0f                	jmp    801a49 <strncpy+0x23>
		*dst++ = *src;
  801a3a:	83 c2 01             	add    $0x1,%edx
  801a3d:	0f b6 01             	movzbl (%ecx),%eax
  801a40:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a43:	80 39 01             	cmpb   $0x1,(%ecx)
  801a46:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a49:	39 da                	cmp    %ebx,%edx
  801a4b:	75 ed                	jne    801a3a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a4d:	89 f0                	mov    %esi,%eax
  801a4f:	5b                   	pop    %ebx
  801a50:	5e                   	pop    %esi
  801a51:	5d                   	pop    %ebp
  801a52:	c3                   	ret    

00801a53 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	56                   	push   %esi
  801a57:	53                   	push   %ebx
  801a58:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5e:	8b 55 10             	mov    0x10(%ebp),%edx
  801a61:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a63:	85 d2                	test   %edx,%edx
  801a65:	74 21                	je     801a88 <strlcpy+0x35>
  801a67:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a6b:	89 f2                	mov    %esi,%edx
  801a6d:	eb 09                	jmp    801a78 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a6f:	83 c2 01             	add    $0x1,%edx
  801a72:	83 c1 01             	add    $0x1,%ecx
  801a75:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a78:	39 c2                	cmp    %eax,%edx
  801a7a:	74 09                	je     801a85 <strlcpy+0x32>
  801a7c:	0f b6 19             	movzbl (%ecx),%ebx
  801a7f:	84 db                	test   %bl,%bl
  801a81:	75 ec                	jne    801a6f <strlcpy+0x1c>
  801a83:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a85:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a88:	29 f0                	sub    %esi,%eax
}
  801a8a:	5b                   	pop    %ebx
  801a8b:	5e                   	pop    %esi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a94:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801a97:	eb 06                	jmp    801a9f <strcmp+0x11>
		p++, q++;
  801a99:	83 c1 01             	add    $0x1,%ecx
  801a9c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801a9f:	0f b6 01             	movzbl (%ecx),%eax
  801aa2:	84 c0                	test   %al,%al
  801aa4:	74 04                	je     801aaa <strcmp+0x1c>
  801aa6:	3a 02                	cmp    (%edx),%al
  801aa8:	74 ef                	je     801a99 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801aaa:	0f b6 c0             	movzbl %al,%eax
  801aad:	0f b6 12             	movzbl (%edx),%edx
  801ab0:	29 d0                	sub    %edx,%eax
}
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	53                   	push   %ebx
  801ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  801abb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801abe:	89 c3                	mov    %eax,%ebx
  801ac0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ac3:	eb 06                	jmp    801acb <strncmp+0x17>
		n--, p++, q++;
  801ac5:	83 c0 01             	add    $0x1,%eax
  801ac8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801acb:	39 d8                	cmp    %ebx,%eax
  801acd:	74 15                	je     801ae4 <strncmp+0x30>
  801acf:	0f b6 08             	movzbl (%eax),%ecx
  801ad2:	84 c9                	test   %cl,%cl
  801ad4:	74 04                	je     801ada <strncmp+0x26>
  801ad6:	3a 0a                	cmp    (%edx),%cl
  801ad8:	74 eb                	je     801ac5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ada:	0f b6 00             	movzbl (%eax),%eax
  801add:	0f b6 12             	movzbl (%edx),%edx
  801ae0:	29 d0                	sub    %edx,%eax
  801ae2:	eb 05                	jmp    801ae9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801ae4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ae9:	5b                   	pop    %ebx
  801aea:	5d                   	pop    %ebp
  801aeb:	c3                   	ret    

00801aec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	8b 45 08             	mov    0x8(%ebp),%eax
  801af2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801af6:	eb 07                	jmp    801aff <strchr+0x13>
		if (*s == c)
  801af8:	38 ca                	cmp    %cl,%dl
  801afa:	74 0f                	je     801b0b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801afc:	83 c0 01             	add    $0x1,%eax
  801aff:	0f b6 10             	movzbl (%eax),%edx
  801b02:	84 d2                	test   %dl,%dl
  801b04:	75 f2                	jne    801af8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0b:	5d                   	pop    %ebp
  801b0c:	c3                   	ret    

00801b0d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	8b 45 08             	mov    0x8(%ebp),%eax
  801b13:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b17:	eb 03                	jmp    801b1c <strfind+0xf>
  801b19:	83 c0 01             	add    $0x1,%eax
  801b1c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b1f:	38 ca                	cmp    %cl,%dl
  801b21:	74 04                	je     801b27 <strfind+0x1a>
  801b23:	84 d2                	test   %dl,%dl
  801b25:	75 f2                	jne    801b19 <strfind+0xc>
			break;
	return (char *) s;
}
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	57                   	push   %edi
  801b2d:	56                   	push   %esi
  801b2e:	53                   	push   %ebx
  801b2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b35:	85 c9                	test   %ecx,%ecx
  801b37:	74 36                	je     801b6f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b3f:	75 28                	jne    801b69 <memset+0x40>
  801b41:	f6 c1 03             	test   $0x3,%cl
  801b44:	75 23                	jne    801b69 <memset+0x40>
		c &= 0xFF;
  801b46:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b4a:	89 d3                	mov    %edx,%ebx
  801b4c:	c1 e3 08             	shl    $0x8,%ebx
  801b4f:	89 d6                	mov    %edx,%esi
  801b51:	c1 e6 18             	shl    $0x18,%esi
  801b54:	89 d0                	mov    %edx,%eax
  801b56:	c1 e0 10             	shl    $0x10,%eax
  801b59:	09 f0                	or     %esi,%eax
  801b5b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b5d:	89 d8                	mov    %ebx,%eax
  801b5f:	09 d0                	or     %edx,%eax
  801b61:	c1 e9 02             	shr    $0x2,%ecx
  801b64:	fc                   	cld    
  801b65:	f3 ab                	rep stos %eax,%es:(%edi)
  801b67:	eb 06                	jmp    801b6f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6c:	fc                   	cld    
  801b6d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b6f:	89 f8                	mov    %edi,%eax
  801b71:	5b                   	pop    %ebx
  801b72:	5e                   	pop    %esi
  801b73:	5f                   	pop    %edi
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	57                   	push   %edi
  801b7a:	56                   	push   %esi
  801b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b81:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b84:	39 c6                	cmp    %eax,%esi
  801b86:	73 35                	jae    801bbd <memmove+0x47>
  801b88:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b8b:	39 d0                	cmp    %edx,%eax
  801b8d:	73 2e                	jae    801bbd <memmove+0x47>
		s += n;
		d += n;
  801b8f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b92:	89 d6                	mov    %edx,%esi
  801b94:	09 fe                	or     %edi,%esi
  801b96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801b9c:	75 13                	jne    801bb1 <memmove+0x3b>
  801b9e:	f6 c1 03             	test   $0x3,%cl
  801ba1:	75 0e                	jne    801bb1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801ba3:	83 ef 04             	sub    $0x4,%edi
  801ba6:	8d 72 fc             	lea    -0x4(%edx),%esi
  801ba9:	c1 e9 02             	shr    $0x2,%ecx
  801bac:	fd                   	std    
  801bad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801baf:	eb 09                	jmp    801bba <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bb1:	83 ef 01             	sub    $0x1,%edi
  801bb4:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bb7:	fd                   	std    
  801bb8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bba:	fc                   	cld    
  801bbb:	eb 1d                	jmp    801bda <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bbd:	89 f2                	mov    %esi,%edx
  801bbf:	09 c2                	or     %eax,%edx
  801bc1:	f6 c2 03             	test   $0x3,%dl
  801bc4:	75 0f                	jne    801bd5 <memmove+0x5f>
  801bc6:	f6 c1 03             	test   $0x3,%cl
  801bc9:	75 0a                	jne    801bd5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bcb:	c1 e9 02             	shr    $0x2,%ecx
  801bce:	89 c7                	mov    %eax,%edi
  801bd0:	fc                   	cld    
  801bd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bd3:	eb 05                	jmp    801bda <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bd5:	89 c7                	mov    %eax,%edi
  801bd7:	fc                   	cld    
  801bd8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801bda:	5e                   	pop    %esi
  801bdb:	5f                   	pop    %edi
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801be1:	ff 75 10             	pushl  0x10(%ebp)
  801be4:	ff 75 0c             	pushl  0xc(%ebp)
  801be7:	ff 75 08             	pushl  0x8(%ebp)
  801bea:	e8 87 ff ff ff       	call   801b76 <memmove>
}
  801bef:	c9                   	leave  
  801bf0:	c3                   	ret    

00801bf1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bfc:	89 c6                	mov    %eax,%esi
  801bfe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c01:	eb 1a                	jmp    801c1d <memcmp+0x2c>
		if (*s1 != *s2)
  801c03:	0f b6 08             	movzbl (%eax),%ecx
  801c06:	0f b6 1a             	movzbl (%edx),%ebx
  801c09:	38 d9                	cmp    %bl,%cl
  801c0b:	74 0a                	je     801c17 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c0d:	0f b6 c1             	movzbl %cl,%eax
  801c10:	0f b6 db             	movzbl %bl,%ebx
  801c13:	29 d8                	sub    %ebx,%eax
  801c15:	eb 0f                	jmp    801c26 <memcmp+0x35>
		s1++, s2++;
  801c17:	83 c0 01             	add    $0x1,%eax
  801c1a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c1d:	39 f0                	cmp    %esi,%eax
  801c1f:	75 e2                	jne    801c03 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	53                   	push   %ebx
  801c2e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c31:	89 c1                	mov    %eax,%ecx
  801c33:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c36:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c3a:	eb 0a                	jmp    801c46 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c3c:	0f b6 10             	movzbl (%eax),%edx
  801c3f:	39 da                	cmp    %ebx,%edx
  801c41:	74 07                	je     801c4a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c43:	83 c0 01             	add    $0x1,%eax
  801c46:	39 c8                	cmp    %ecx,%eax
  801c48:	72 f2                	jb     801c3c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c4a:	5b                   	pop    %ebx
  801c4b:	5d                   	pop    %ebp
  801c4c:	c3                   	ret    

00801c4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	57                   	push   %edi
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c59:	eb 03                	jmp    801c5e <strtol+0x11>
		s++;
  801c5b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c5e:	0f b6 01             	movzbl (%ecx),%eax
  801c61:	3c 20                	cmp    $0x20,%al
  801c63:	74 f6                	je     801c5b <strtol+0xe>
  801c65:	3c 09                	cmp    $0x9,%al
  801c67:	74 f2                	je     801c5b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c69:	3c 2b                	cmp    $0x2b,%al
  801c6b:	75 0a                	jne    801c77 <strtol+0x2a>
		s++;
  801c6d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c70:	bf 00 00 00 00       	mov    $0x0,%edi
  801c75:	eb 11                	jmp    801c88 <strtol+0x3b>
  801c77:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c7c:	3c 2d                	cmp    $0x2d,%al
  801c7e:	75 08                	jne    801c88 <strtol+0x3b>
		s++, neg = 1;
  801c80:	83 c1 01             	add    $0x1,%ecx
  801c83:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c88:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c8e:	75 15                	jne    801ca5 <strtol+0x58>
  801c90:	80 39 30             	cmpb   $0x30,(%ecx)
  801c93:	75 10                	jne    801ca5 <strtol+0x58>
  801c95:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801c99:	75 7c                	jne    801d17 <strtol+0xca>
		s += 2, base = 16;
  801c9b:	83 c1 02             	add    $0x2,%ecx
  801c9e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ca3:	eb 16                	jmp    801cbb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ca5:	85 db                	test   %ebx,%ebx
  801ca7:	75 12                	jne    801cbb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ca9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cae:	80 39 30             	cmpb   $0x30,(%ecx)
  801cb1:	75 08                	jne    801cbb <strtol+0x6e>
		s++, base = 8;
  801cb3:	83 c1 01             	add    $0x1,%ecx
  801cb6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cbb:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cc3:	0f b6 11             	movzbl (%ecx),%edx
  801cc6:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cc9:	89 f3                	mov    %esi,%ebx
  801ccb:	80 fb 09             	cmp    $0x9,%bl
  801cce:	77 08                	ja     801cd8 <strtol+0x8b>
			dig = *s - '0';
  801cd0:	0f be d2             	movsbl %dl,%edx
  801cd3:	83 ea 30             	sub    $0x30,%edx
  801cd6:	eb 22                	jmp    801cfa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801cd8:	8d 72 9f             	lea    -0x61(%edx),%esi
  801cdb:	89 f3                	mov    %esi,%ebx
  801cdd:	80 fb 19             	cmp    $0x19,%bl
  801ce0:	77 08                	ja     801cea <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ce2:	0f be d2             	movsbl %dl,%edx
  801ce5:	83 ea 57             	sub    $0x57,%edx
  801ce8:	eb 10                	jmp    801cfa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801cea:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ced:	89 f3                	mov    %esi,%ebx
  801cef:	80 fb 19             	cmp    $0x19,%bl
  801cf2:	77 16                	ja     801d0a <strtol+0xbd>
			dig = *s - 'A' + 10;
  801cf4:	0f be d2             	movsbl %dl,%edx
  801cf7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801cfa:	3b 55 10             	cmp    0x10(%ebp),%edx
  801cfd:	7d 0b                	jge    801d0a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801cff:	83 c1 01             	add    $0x1,%ecx
  801d02:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d06:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d08:	eb b9                	jmp    801cc3 <strtol+0x76>

	if (endptr)
  801d0a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d0e:	74 0d                	je     801d1d <strtol+0xd0>
		*endptr = (char *) s;
  801d10:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d13:	89 0e                	mov    %ecx,(%esi)
  801d15:	eb 06                	jmp    801d1d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d17:	85 db                	test   %ebx,%ebx
  801d19:	74 98                	je     801cb3 <strtol+0x66>
  801d1b:	eb 9e                	jmp    801cbb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d1d:	89 c2                	mov    %eax,%edx
  801d1f:	f7 da                	neg    %edx
  801d21:	85 ff                	test   %edi,%edi
  801d23:	0f 45 c2             	cmovne %edx,%eax
}
  801d26:	5b                   	pop    %ebx
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    

00801d2b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d31:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d38:	75 2a                	jne    801d64 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d3a:	83 ec 04             	sub    $0x4,%esp
  801d3d:	6a 07                	push   $0x7
  801d3f:	68 00 f0 bf ee       	push   $0xeebff000
  801d44:	6a 00                	push   $0x0
  801d46:	e8 2e e4 ff ff       	call   800179 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	79 12                	jns    801d64 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d52:	50                   	push   %eax
  801d53:	68 60 26 80 00       	push   $0x802660
  801d58:	6a 23                	push   $0x23
  801d5a:	68 64 26 80 00       	push   $0x802664
  801d5f:	e8 22 f6 ff ff       	call   801386 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d64:	8b 45 08             	mov    0x8(%ebp),%eax
  801d67:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d6c:	83 ec 08             	sub    $0x8,%esp
  801d6f:	68 96 1d 80 00       	push   $0x801d96
  801d74:	6a 00                	push   $0x0
  801d76:	e8 49 e5 ff ff       	call   8002c4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	79 12                	jns    801d94 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d82:	50                   	push   %eax
  801d83:	68 60 26 80 00       	push   $0x802660
  801d88:	6a 2c                	push   $0x2c
  801d8a:	68 64 26 80 00       	push   $0x802664
  801d8f:	e8 f2 f5 ff ff       	call   801386 <_panic>
	}
}
  801d94:	c9                   	leave  
  801d95:	c3                   	ret    

00801d96 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d96:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d97:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d9c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d9e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801da1:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801da5:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801daa:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dae:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801db0:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801db3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801db4:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801db7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801db8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801db9:	c3                   	ret    

00801dba <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dba:	55                   	push   %ebp
  801dbb:	89 e5                	mov    %esp,%ebp
  801dbd:	56                   	push   %esi
  801dbe:	53                   	push   %ebx
  801dbf:	8b 75 08             	mov    0x8(%ebp),%esi
  801dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	75 12                	jne    801dde <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801dcc:	83 ec 0c             	sub    $0xc,%esp
  801dcf:	68 00 00 c0 ee       	push   $0xeec00000
  801dd4:	e8 50 e5 ff ff       	call   800329 <sys_ipc_recv>
  801dd9:	83 c4 10             	add    $0x10,%esp
  801ddc:	eb 0c                	jmp    801dea <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	50                   	push   %eax
  801de2:	e8 42 e5 ff ff       	call   800329 <sys_ipc_recv>
  801de7:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801dea:	85 f6                	test   %esi,%esi
  801dec:	0f 95 c1             	setne  %cl
  801def:	85 db                	test   %ebx,%ebx
  801df1:	0f 95 c2             	setne  %dl
  801df4:	84 d1                	test   %dl,%cl
  801df6:	74 09                	je     801e01 <ipc_recv+0x47>
  801df8:	89 c2                	mov    %eax,%edx
  801dfa:	c1 ea 1f             	shr    $0x1f,%edx
  801dfd:	84 d2                	test   %dl,%dl
  801dff:	75 2a                	jne    801e2b <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e01:	85 f6                	test   %esi,%esi
  801e03:	74 0d                	je     801e12 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e05:	a1 04 40 80 00       	mov    0x804004,%eax
  801e0a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e10:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e12:	85 db                	test   %ebx,%ebx
  801e14:	74 0d                	je     801e23 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e16:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1b:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e21:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e23:	a1 04 40 80 00       	mov    0x804004,%eax
  801e28:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5e                   	pop    %esi
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    

00801e32 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	57                   	push   %edi
  801e36:	56                   	push   %esi
  801e37:	53                   	push   %ebx
  801e38:	83 ec 0c             	sub    $0xc,%esp
  801e3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e44:	85 db                	test   %ebx,%ebx
  801e46:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e4b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e4e:	ff 75 14             	pushl  0x14(%ebp)
  801e51:	53                   	push   %ebx
  801e52:	56                   	push   %esi
  801e53:	57                   	push   %edi
  801e54:	e8 ad e4 ff ff       	call   800306 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e59:	89 c2                	mov    %eax,%edx
  801e5b:	c1 ea 1f             	shr    $0x1f,%edx
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	84 d2                	test   %dl,%dl
  801e63:	74 17                	je     801e7c <ipc_send+0x4a>
  801e65:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e68:	74 12                	je     801e7c <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e6a:	50                   	push   %eax
  801e6b:	68 72 26 80 00       	push   $0x802672
  801e70:	6a 47                	push   $0x47
  801e72:	68 80 26 80 00       	push   $0x802680
  801e77:	e8 0a f5 ff ff       	call   801386 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e7c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e7f:	75 07                	jne    801e88 <ipc_send+0x56>
			sys_yield();
  801e81:	e8 d4 e2 ff ff       	call   80015a <sys_yield>
  801e86:	eb c6                	jmp    801e4e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	75 c2                	jne    801e4e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8f:	5b                   	pop    %ebx
  801e90:	5e                   	pop    %esi
  801e91:	5f                   	pop    %edi
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    

00801e94 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e9a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e9f:	89 c2                	mov    %eax,%edx
  801ea1:	c1 e2 07             	shl    $0x7,%edx
  801ea4:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801eab:	8b 52 5c             	mov    0x5c(%edx),%edx
  801eae:	39 ca                	cmp    %ecx,%edx
  801eb0:	75 11                	jne    801ec3 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801eb2:	89 c2                	mov    %eax,%edx
  801eb4:	c1 e2 07             	shl    $0x7,%edx
  801eb7:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ebe:	8b 40 54             	mov    0x54(%eax),%eax
  801ec1:	eb 0f                	jmp    801ed2 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ec3:	83 c0 01             	add    $0x1,%eax
  801ec6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ecb:	75 d2                	jne    801e9f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ecd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eda:	89 d0                	mov    %edx,%eax
  801edc:	c1 e8 16             	shr    $0x16,%eax
  801edf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ee6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eeb:	f6 c1 01             	test   $0x1,%cl
  801eee:	74 1d                	je     801f0d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ef0:	c1 ea 0c             	shr    $0xc,%edx
  801ef3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801efa:	f6 c2 01             	test   $0x1,%dl
  801efd:	74 0e                	je     801f0d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801eff:	c1 ea 0c             	shr    $0xc,%edx
  801f02:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f09:	ef 
  801f0a:	0f b7 c0             	movzwl %ax,%eax
}
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    
  801f0f:	90                   	nop

00801f10 <__udivdi3>:
  801f10:	55                   	push   %ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	53                   	push   %ebx
  801f14:	83 ec 1c             	sub    $0x1c,%esp
  801f17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f27:	85 f6                	test   %esi,%esi
  801f29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f2d:	89 ca                	mov    %ecx,%edx
  801f2f:	89 f8                	mov    %edi,%eax
  801f31:	75 3d                	jne    801f70 <__udivdi3+0x60>
  801f33:	39 cf                	cmp    %ecx,%edi
  801f35:	0f 87 c5 00 00 00    	ja     802000 <__udivdi3+0xf0>
  801f3b:	85 ff                	test   %edi,%edi
  801f3d:	89 fd                	mov    %edi,%ebp
  801f3f:	75 0b                	jne    801f4c <__udivdi3+0x3c>
  801f41:	b8 01 00 00 00       	mov    $0x1,%eax
  801f46:	31 d2                	xor    %edx,%edx
  801f48:	f7 f7                	div    %edi
  801f4a:	89 c5                	mov    %eax,%ebp
  801f4c:	89 c8                	mov    %ecx,%eax
  801f4e:	31 d2                	xor    %edx,%edx
  801f50:	f7 f5                	div    %ebp
  801f52:	89 c1                	mov    %eax,%ecx
  801f54:	89 d8                	mov    %ebx,%eax
  801f56:	89 cf                	mov    %ecx,%edi
  801f58:	f7 f5                	div    %ebp
  801f5a:	89 c3                	mov    %eax,%ebx
  801f5c:	89 d8                	mov    %ebx,%eax
  801f5e:	89 fa                	mov    %edi,%edx
  801f60:	83 c4 1c             	add    $0x1c,%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
  801f68:	90                   	nop
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	39 ce                	cmp    %ecx,%esi
  801f72:	77 74                	ja     801fe8 <__udivdi3+0xd8>
  801f74:	0f bd fe             	bsr    %esi,%edi
  801f77:	83 f7 1f             	xor    $0x1f,%edi
  801f7a:	0f 84 98 00 00 00    	je     802018 <__udivdi3+0x108>
  801f80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f85:	89 f9                	mov    %edi,%ecx
  801f87:	89 c5                	mov    %eax,%ebp
  801f89:	29 fb                	sub    %edi,%ebx
  801f8b:	d3 e6                	shl    %cl,%esi
  801f8d:	89 d9                	mov    %ebx,%ecx
  801f8f:	d3 ed                	shr    %cl,%ebp
  801f91:	89 f9                	mov    %edi,%ecx
  801f93:	d3 e0                	shl    %cl,%eax
  801f95:	09 ee                	or     %ebp,%esi
  801f97:	89 d9                	mov    %ebx,%ecx
  801f99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f9d:	89 d5                	mov    %edx,%ebp
  801f9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fa3:	d3 ed                	shr    %cl,%ebp
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	d3 e2                	shl    %cl,%edx
  801fa9:	89 d9                	mov    %ebx,%ecx
  801fab:	d3 e8                	shr    %cl,%eax
  801fad:	09 c2                	or     %eax,%edx
  801faf:	89 d0                	mov    %edx,%eax
  801fb1:	89 ea                	mov    %ebp,%edx
  801fb3:	f7 f6                	div    %esi
  801fb5:	89 d5                	mov    %edx,%ebp
  801fb7:	89 c3                	mov    %eax,%ebx
  801fb9:	f7 64 24 0c          	mull   0xc(%esp)
  801fbd:	39 d5                	cmp    %edx,%ebp
  801fbf:	72 10                	jb     801fd1 <__udivdi3+0xc1>
  801fc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e6                	shl    %cl,%esi
  801fc9:	39 c6                	cmp    %eax,%esi
  801fcb:	73 07                	jae    801fd4 <__udivdi3+0xc4>
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	75 03                	jne    801fd4 <__udivdi3+0xc4>
  801fd1:	83 eb 01             	sub    $0x1,%ebx
  801fd4:	31 ff                	xor    %edi,%edi
  801fd6:	89 d8                	mov    %ebx,%eax
  801fd8:	89 fa                	mov    %edi,%edx
  801fda:	83 c4 1c             	add    $0x1c,%esp
  801fdd:	5b                   	pop    %ebx
  801fde:	5e                   	pop    %esi
  801fdf:	5f                   	pop    %edi
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    
  801fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fe8:	31 ff                	xor    %edi,%edi
  801fea:	31 db                	xor    %ebx,%ebx
  801fec:	89 d8                	mov    %ebx,%eax
  801fee:	89 fa                	mov    %edi,%edx
  801ff0:	83 c4 1c             	add    $0x1c,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    
  801ff8:	90                   	nop
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	89 d8                	mov    %ebx,%eax
  802002:	f7 f7                	div    %edi
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 c3                	mov    %eax,%ebx
  802008:	89 d8                	mov    %ebx,%eax
  80200a:	89 fa                	mov    %edi,%edx
  80200c:	83 c4 1c             	add    $0x1c,%esp
  80200f:	5b                   	pop    %ebx
  802010:	5e                   	pop    %esi
  802011:	5f                   	pop    %edi
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    
  802014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802018:	39 ce                	cmp    %ecx,%esi
  80201a:	72 0c                	jb     802028 <__udivdi3+0x118>
  80201c:	31 db                	xor    %ebx,%ebx
  80201e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802022:	0f 87 34 ff ff ff    	ja     801f5c <__udivdi3+0x4c>
  802028:	bb 01 00 00 00       	mov    $0x1,%ebx
  80202d:	e9 2a ff ff ff       	jmp    801f5c <__udivdi3+0x4c>
  802032:	66 90                	xchg   %ax,%ax
  802034:	66 90                	xchg   %ax,%ax
  802036:	66 90                	xchg   %ax,%ax
  802038:	66 90                	xchg   %ax,%ax
  80203a:	66 90                	xchg   %ax,%ax
  80203c:	66 90                	xchg   %ax,%ax
  80203e:	66 90                	xchg   %ax,%ax

00802040 <__umoddi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80204b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80204f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 d2                	test   %edx,%edx
  802059:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80205d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802061:	89 f3                	mov    %esi,%ebx
  802063:	89 3c 24             	mov    %edi,(%esp)
  802066:	89 74 24 04          	mov    %esi,0x4(%esp)
  80206a:	75 1c                	jne    802088 <__umoddi3+0x48>
  80206c:	39 f7                	cmp    %esi,%edi
  80206e:	76 50                	jbe    8020c0 <__umoddi3+0x80>
  802070:	89 c8                	mov    %ecx,%eax
  802072:	89 f2                	mov    %esi,%edx
  802074:	f7 f7                	div    %edi
  802076:	89 d0                	mov    %edx,%eax
  802078:	31 d2                	xor    %edx,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	39 f2                	cmp    %esi,%edx
  80208a:	89 d0                	mov    %edx,%eax
  80208c:	77 52                	ja     8020e0 <__umoddi3+0xa0>
  80208e:	0f bd ea             	bsr    %edx,%ebp
  802091:	83 f5 1f             	xor    $0x1f,%ebp
  802094:	75 5a                	jne    8020f0 <__umoddi3+0xb0>
  802096:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80209a:	0f 82 e0 00 00 00    	jb     802180 <__umoddi3+0x140>
  8020a0:	39 0c 24             	cmp    %ecx,(%esp)
  8020a3:	0f 86 d7 00 00 00    	jbe    802180 <__umoddi3+0x140>
  8020a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020b1:	83 c4 1c             	add    $0x1c,%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	85 ff                	test   %edi,%edi
  8020c2:	89 fd                	mov    %edi,%ebp
  8020c4:	75 0b                	jne    8020d1 <__umoddi3+0x91>
  8020c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020cb:	31 d2                	xor    %edx,%edx
  8020cd:	f7 f7                	div    %edi
  8020cf:	89 c5                	mov    %eax,%ebp
  8020d1:	89 f0                	mov    %esi,%eax
  8020d3:	31 d2                	xor    %edx,%edx
  8020d5:	f7 f5                	div    %ebp
  8020d7:	89 c8                	mov    %ecx,%eax
  8020d9:	f7 f5                	div    %ebp
  8020db:	89 d0                	mov    %edx,%eax
  8020dd:	eb 99                	jmp    802078 <__umoddi3+0x38>
  8020df:	90                   	nop
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	83 c4 1c             	add    $0x1c,%esp
  8020e7:	5b                   	pop    %ebx
  8020e8:	5e                   	pop    %esi
  8020e9:	5f                   	pop    %edi
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    
  8020ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	8b 34 24             	mov    (%esp),%esi
  8020f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020f8:	89 e9                	mov    %ebp,%ecx
  8020fa:	29 ef                	sub    %ebp,%edi
  8020fc:	d3 e0                	shl    %cl,%eax
  8020fe:	89 f9                	mov    %edi,%ecx
  802100:	89 f2                	mov    %esi,%edx
  802102:	d3 ea                	shr    %cl,%edx
  802104:	89 e9                	mov    %ebp,%ecx
  802106:	09 c2                	or     %eax,%edx
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	89 14 24             	mov    %edx,(%esp)
  80210d:	89 f2                	mov    %esi,%edx
  80210f:	d3 e2                	shl    %cl,%edx
  802111:	89 f9                	mov    %edi,%ecx
  802113:	89 54 24 04          	mov    %edx,0x4(%esp)
  802117:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	89 e9                	mov    %ebp,%ecx
  80211f:	89 c6                	mov    %eax,%esi
  802121:	d3 e3                	shl    %cl,%ebx
  802123:	89 f9                	mov    %edi,%ecx
  802125:	89 d0                	mov    %edx,%eax
  802127:	d3 e8                	shr    %cl,%eax
  802129:	89 e9                	mov    %ebp,%ecx
  80212b:	09 d8                	or     %ebx,%eax
  80212d:	89 d3                	mov    %edx,%ebx
  80212f:	89 f2                	mov    %esi,%edx
  802131:	f7 34 24             	divl   (%esp)
  802134:	89 d6                	mov    %edx,%esi
  802136:	d3 e3                	shl    %cl,%ebx
  802138:	f7 64 24 04          	mull   0x4(%esp)
  80213c:	39 d6                	cmp    %edx,%esi
  80213e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802142:	89 d1                	mov    %edx,%ecx
  802144:	89 c3                	mov    %eax,%ebx
  802146:	72 08                	jb     802150 <__umoddi3+0x110>
  802148:	75 11                	jne    80215b <__umoddi3+0x11b>
  80214a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80214e:	73 0b                	jae    80215b <__umoddi3+0x11b>
  802150:	2b 44 24 04          	sub    0x4(%esp),%eax
  802154:	1b 14 24             	sbb    (%esp),%edx
  802157:	89 d1                	mov    %edx,%ecx
  802159:	89 c3                	mov    %eax,%ebx
  80215b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80215f:	29 da                	sub    %ebx,%edx
  802161:	19 ce                	sbb    %ecx,%esi
  802163:	89 f9                	mov    %edi,%ecx
  802165:	89 f0                	mov    %esi,%eax
  802167:	d3 e0                	shl    %cl,%eax
  802169:	89 e9                	mov    %ebp,%ecx
  80216b:	d3 ea                	shr    %cl,%edx
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	d3 ee                	shr    %cl,%esi
  802171:	09 d0                	or     %edx,%eax
  802173:	89 f2                	mov    %esi,%edx
  802175:	83 c4 1c             	add    $0x1c,%esp
  802178:	5b                   	pop    %ebx
  802179:	5e                   	pop    %esi
  80217a:	5f                   	pop    %edi
  80217b:	5d                   	pop    %ebp
  80217c:	c3                   	ret    
  80217d:	8d 76 00             	lea    0x0(%esi),%esi
  802180:	29 f9                	sub    %edi,%ecx
  802182:	19 d6                	sbb    %edx,%esi
  802184:	89 74 24 04          	mov    %esi,0x4(%esp)
  802188:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80218c:	e9 18 ff ff ff       	jmp    8020a9 <__umoddi3+0x69>
