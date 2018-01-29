
obj/user/softint.debug:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 f1 00 00 00       	call   80013b <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x30>
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
  8000a9:	e8 04 08 00 00       	call   8008b2 <close_all>
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
  800122:	68 2a 22 80 00       	push   $0x80222a
  800127:	6a 23                	push   $0x23
  800129:	68 47 22 80 00       	push   $0x802247
  80012e:	e8 b0 12 00 00       	call   8013e3 <_panic>

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
  8001a3:	68 2a 22 80 00       	push   $0x80222a
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 47 22 80 00       	push   $0x802247
  8001af:	e8 2f 12 00 00       	call   8013e3 <_panic>

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
  8001e5:	68 2a 22 80 00       	push   $0x80222a
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 47 22 80 00       	push   $0x802247
  8001f1:	e8 ed 11 00 00       	call   8013e3 <_panic>

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
  800227:	68 2a 22 80 00       	push   $0x80222a
  80022c:	6a 23                	push   $0x23
  80022e:	68 47 22 80 00       	push   $0x802247
  800233:	e8 ab 11 00 00       	call   8013e3 <_panic>

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
  800269:	68 2a 22 80 00       	push   $0x80222a
  80026e:	6a 23                	push   $0x23
  800270:	68 47 22 80 00       	push   $0x802247
  800275:	e8 69 11 00 00       	call   8013e3 <_panic>

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
  8002ab:	68 2a 22 80 00       	push   $0x80222a
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 47 22 80 00       	push   $0x802247
  8002b7:	e8 27 11 00 00       	call   8013e3 <_panic>
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
  8002ed:	68 2a 22 80 00       	push   $0x80222a
  8002f2:	6a 23                	push   $0x23
  8002f4:	68 47 22 80 00       	push   $0x802247
  8002f9:	e8 e5 10 00 00       	call   8013e3 <_panic>

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
  800351:	68 2a 22 80 00       	push   $0x80222a
  800356:	6a 23                	push   $0x23
  800358:	68 47 22 80 00       	push   $0x802247
  80035d:	e8 81 10 00 00       	call   8013e3 <_panic>

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

008003aa <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	57                   	push   %edi
  8003ae:	56                   	push   %esi
  8003af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b5:	b8 10 00 00 00       	mov    $0x10,%eax
  8003ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bd:	89 cb                	mov    %ecx,%ebx
  8003bf:	89 cf                	mov    %ecx,%edi
  8003c1:	89 ce                	mov    %ecx,%esi
  8003c3:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8003c5:	5b                   	pop    %ebx
  8003c6:	5e                   	pop    %esi
  8003c7:	5f                   	pop    %edi
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	53                   	push   %ebx
  8003ce:	83 ec 04             	sub    $0x4,%esp
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003d4:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003d6:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003da:	74 11                	je     8003ed <pgfault+0x23>
  8003dc:	89 d8                	mov    %ebx,%eax
  8003de:	c1 e8 0c             	shr    $0xc,%eax
  8003e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003e8:	f6 c4 08             	test   $0x8,%ah
  8003eb:	75 14                	jne    800401 <pgfault+0x37>
		panic("faulting access");
  8003ed:	83 ec 04             	sub    $0x4,%esp
  8003f0:	68 55 22 80 00       	push   $0x802255
  8003f5:	6a 1e                	push   $0x1e
  8003f7:	68 65 22 80 00       	push   $0x802265
  8003fc:	e8 e2 0f 00 00       	call   8013e3 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800401:	83 ec 04             	sub    $0x4,%esp
  800404:	6a 07                	push   $0x7
  800406:	68 00 f0 7f 00       	push   $0x7ff000
  80040b:	6a 00                	push   $0x0
  80040d:	e8 67 fd ff ff       	call   800179 <sys_page_alloc>
	if (r < 0) {
  800412:	83 c4 10             	add    $0x10,%esp
  800415:	85 c0                	test   %eax,%eax
  800417:	79 12                	jns    80042b <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800419:	50                   	push   %eax
  80041a:	68 70 22 80 00       	push   $0x802270
  80041f:	6a 2c                	push   $0x2c
  800421:	68 65 22 80 00       	push   $0x802265
  800426:	e8 b8 0f 00 00       	call   8013e3 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80042b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800431:	83 ec 04             	sub    $0x4,%esp
  800434:	68 00 10 00 00       	push   $0x1000
  800439:	53                   	push   %ebx
  80043a:	68 00 f0 7f 00       	push   $0x7ff000
  80043f:	e8 f7 17 00 00       	call   801c3b <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800444:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80044b:	53                   	push   %ebx
  80044c:	6a 00                	push   $0x0
  80044e:	68 00 f0 7f 00       	push   $0x7ff000
  800453:	6a 00                	push   $0x0
  800455:	e8 62 fd ff ff       	call   8001bc <sys_page_map>
	if (r < 0) {
  80045a:	83 c4 20             	add    $0x20,%esp
  80045d:	85 c0                	test   %eax,%eax
  80045f:	79 12                	jns    800473 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800461:	50                   	push   %eax
  800462:	68 70 22 80 00       	push   $0x802270
  800467:	6a 33                	push   $0x33
  800469:	68 65 22 80 00       	push   $0x802265
  80046e:	e8 70 0f 00 00       	call   8013e3 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800473:	83 ec 08             	sub    $0x8,%esp
  800476:	68 00 f0 7f 00       	push   $0x7ff000
  80047b:	6a 00                	push   $0x0
  80047d:	e8 7c fd ff ff       	call   8001fe <sys_page_unmap>
	if (r < 0) {
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	85 c0                	test   %eax,%eax
  800487:	79 12                	jns    80049b <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800489:	50                   	push   %eax
  80048a:	68 70 22 80 00       	push   $0x802270
  80048f:	6a 37                	push   $0x37
  800491:	68 65 22 80 00       	push   $0x802265
  800496:	e8 48 0f 00 00       	call   8013e3 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80049b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80049e:	c9                   	leave  
  80049f:	c3                   	ret    

008004a0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004a0:	55                   	push   %ebp
  8004a1:	89 e5                	mov    %esp,%ebp
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	53                   	push   %ebx
  8004a6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004a9:	68 ca 03 80 00       	push   $0x8003ca
  8004ae:	e8 d5 18 00 00       	call   801d88 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004b3:	b8 07 00 00 00       	mov    $0x7,%eax
  8004b8:	cd 30                	int    $0x30
  8004ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	85 c0                	test   %eax,%eax
  8004c2:	79 17                	jns    8004db <fork+0x3b>
		panic("fork fault %e");
  8004c4:	83 ec 04             	sub    $0x4,%esp
  8004c7:	68 89 22 80 00       	push   $0x802289
  8004cc:	68 84 00 00 00       	push   $0x84
  8004d1:	68 65 22 80 00       	push   $0x802265
  8004d6:	e8 08 0f 00 00       	call   8013e3 <_panic>
  8004db:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e1:	75 24                	jne    800507 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004e3:	e8 53 fc ff ff       	call   80013b <sys_getenvid>
  8004e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004ed:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8004f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004f8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800502:	e9 64 01 00 00       	jmp    80066b <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800507:	83 ec 04             	sub    $0x4,%esp
  80050a:	6a 07                	push   $0x7
  80050c:	68 00 f0 bf ee       	push   $0xeebff000
  800511:	ff 75 e4             	pushl  -0x1c(%ebp)
  800514:	e8 60 fc ff ff       	call   800179 <sys_page_alloc>
  800519:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80051c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800521:	89 d8                	mov    %ebx,%eax
  800523:	c1 e8 16             	shr    $0x16,%eax
  800526:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80052d:	a8 01                	test   $0x1,%al
  80052f:	0f 84 fc 00 00 00    	je     800631 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800535:	89 d8                	mov    %ebx,%eax
  800537:	c1 e8 0c             	shr    $0xc,%eax
  80053a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800541:	f6 c2 01             	test   $0x1,%dl
  800544:	0f 84 e7 00 00 00    	je     800631 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80054a:	89 c6                	mov    %eax,%esi
  80054c:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80054f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800556:	f6 c6 04             	test   $0x4,%dh
  800559:	74 39                	je     800594 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80055b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800562:	83 ec 0c             	sub    $0xc,%esp
  800565:	25 07 0e 00 00       	and    $0xe07,%eax
  80056a:	50                   	push   %eax
  80056b:	56                   	push   %esi
  80056c:	57                   	push   %edi
  80056d:	56                   	push   %esi
  80056e:	6a 00                	push   $0x0
  800570:	e8 47 fc ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  800575:	83 c4 20             	add    $0x20,%esp
  800578:	85 c0                	test   %eax,%eax
  80057a:	0f 89 b1 00 00 00    	jns    800631 <fork+0x191>
		    	panic("sys page map fault %e");
  800580:	83 ec 04             	sub    $0x4,%esp
  800583:	68 97 22 80 00       	push   $0x802297
  800588:	6a 54                	push   $0x54
  80058a:	68 65 22 80 00       	push   $0x802265
  80058f:	e8 4f 0e 00 00       	call   8013e3 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800594:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80059b:	f6 c2 02             	test   $0x2,%dl
  80059e:	75 0c                	jne    8005ac <fork+0x10c>
  8005a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005a7:	f6 c4 08             	test   $0x8,%ah
  8005aa:	74 5b                	je     800607 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005ac:	83 ec 0c             	sub    $0xc,%esp
  8005af:	68 05 08 00 00       	push   $0x805
  8005b4:	56                   	push   %esi
  8005b5:	57                   	push   %edi
  8005b6:	56                   	push   %esi
  8005b7:	6a 00                	push   $0x0
  8005b9:	e8 fe fb ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  8005be:	83 c4 20             	add    $0x20,%esp
  8005c1:	85 c0                	test   %eax,%eax
  8005c3:	79 14                	jns    8005d9 <fork+0x139>
		    	panic("sys page map fault %e");
  8005c5:	83 ec 04             	sub    $0x4,%esp
  8005c8:	68 97 22 80 00       	push   $0x802297
  8005cd:	6a 5b                	push   $0x5b
  8005cf:	68 65 22 80 00       	push   $0x802265
  8005d4:	e8 0a 0e 00 00       	call   8013e3 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005d9:	83 ec 0c             	sub    $0xc,%esp
  8005dc:	68 05 08 00 00       	push   $0x805
  8005e1:	56                   	push   %esi
  8005e2:	6a 00                	push   $0x0
  8005e4:	56                   	push   %esi
  8005e5:	6a 00                	push   $0x0
  8005e7:	e8 d0 fb ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  8005ec:	83 c4 20             	add    $0x20,%esp
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	79 3e                	jns    800631 <fork+0x191>
		    	panic("sys page map fault %e");
  8005f3:	83 ec 04             	sub    $0x4,%esp
  8005f6:	68 97 22 80 00       	push   $0x802297
  8005fb:	6a 5f                	push   $0x5f
  8005fd:	68 65 22 80 00       	push   $0x802265
  800602:	e8 dc 0d 00 00       	call   8013e3 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800607:	83 ec 0c             	sub    $0xc,%esp
  80060a:	6a 05                	push   $0x5
  80060c:	56                   	push   %esi
  80060d:	57                   	push   %edi
  80060e:	56                   	push   %esi
  80060f:	6a 00                	push   $0x0
  800611:	e8 a6 fb ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  800616:	83 c4 20             	add    $0x20,%esp
  800619:	85 c0                	test   %eax,%eax
  80061b:	79 14                	jns    800631 <fork+0x191>
		    	panic("sys page map fault %e");
  80061d:	83 ec 04             	sub    $0x4,%esp
  800620:	68 97 22 80 00       	push   $0x802297
  800625:	6a 64                	push   $0x64
  800627:	68 65 22 80 00       	push   $0x802265
  80062c:	e8 b2 0d 00 00       	call   8013e3 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800631:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800637:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80063d:	0f 85 de fe ff ff    	jne    800521 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800643:	a1 04 40 80 00       	mov    0x804004,%eax
  800648:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  80064e:	83 ec 08             	sub    $0x8,%esp
  800651:	50                   	push   %eax
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800655:	57                   	push   %edi
  800656:	e8 69 fc ff ff       	call   8002c4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80065b:	83 c4 08             	add    $0x8,%esp
  80065e:	6a 02                	push   $0x2
  800660:	57                   	push   %edi
  800661:	e8 da fb ff ff       	call   800240 <sys_env_set_status>
	
	return envid;
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80066b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066e:	5b                   	pop    %ebx
  80066f:	5e                   	pop    %esi
  800670:	5f                   	pop    %edi
  800671:	5d                   	pop    %ebp
  800672:	c3                   	ret    

00800673 <sfork>:

envid_t
sfork(void)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800676:	b8 00 00 00 00       	mov    $0x0,%eax
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    

0080067d <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	56                   	push   %esi
  800681:	53                   	push   %ebx
  800682:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800685:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	68 b0 22 80 00       	push   $0x8022b0
  800694:	e8 23 0e 00 00       	call   8014bc <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800699:	c7 04 24 83 00 80 00 	movl   $0x800083,(%esp)
  8006a0:	e8 c5 fc ff ff       	call   80036a <sys_thread_create>
  8006a5:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006a7:	83 c4 08             	add    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	68 b0 22 80 00       	push   $0x8022b0
  8006b0:	e8 07 0e 00 00       	call   8014bc <cprintf>
	return id;
}
  8006b5:	89 f0                	mov    %esi,%eax
  8006b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006ba:	5b                   	pop    %ebx
  8006bb:	5e                   	pop    %esi
  8006bc:	5d                   	pop    %ebp
  8006bd:	c3                   	ret    

008006be <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8006c4:	ff 75 08             	pushl  0x8(%ebp)
  8006c7:	e8 be fc ff ff       	call   80038a <sys_thread_free>
}
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    

008006d1 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8006d7:	ff 75 08             	pushl  0x8(%ebp)
  8006da:	e8 cb fc ff ff       	call   8003aa <sys_thread_join>
}
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8006ef:	c1 e8 0c             	shr    $0xc,%eax
}
  8006f2:	5d                   	pop    %ebp
  8006f3:	c3                   	ret    

008006f4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8006ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800704:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800711:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800716:	89 c2                	mov    %eax,%edx
  800718:	c1 ea 16             	shr    $0x16,%edx
  80071b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800722:	f6 c2 01             	test   $0x1,%dl
  800725:	74 11                	je     800738 <fd_alloc+0x2d>
  800727:	89 c2                	mov    %eax,%edx
  800729:	c1 ea 0c             	shr    $0xc,%edx
  80072c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800733:	f6 c2 01             	test   $0x1,%dl
  800736:	75 09                	jne    800741 <fd_alloc+0x36>
			*fd_store = fd;
  800738:	89 01                	mov    %eax,(%ecx)
			return 0;
  80073a:	b8 00 00 00 00       	mov    $0x0,%eax
  80073f:	eb 17                	jmp    800758 <fd_alloc+0x4d>
  800741:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800746:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80074b:	75 c9                	jne    800716 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80074d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800753:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800760:	83 f8 1f             	cmp    $0x1f,%eax
  800763:	77 36                	ja     80079b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800765:	c1 e0 0c             	shl    $0xc,%eax
  800768:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80076d:	89 c2                	mov    %eax,%edx
  80076f:	c1 ea 16             	shr    $0x16,%edx
  800772:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800779:	f6 c2 01             	test   $0x1,%dl
  80077c:	74 24                	je     8007a2 <fd_lookup+0x48>
  80077e:	89 c2                	mov    %eax,%edx
  800780:	c1 ea 0c             	shr    $0xc,%edx
  800783:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80078a:	f6 c2 01             	test   $0x1,%dl
  80078d:	74 1a                	je     8007a9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800792:	89 02                	mov    %eax,(%edx)
	return 0;
  800794:	b8 00 00 00 00       	mov    $0x0,%eax
  800799:	eb 13                	jmp    8007ae <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80079b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a0:	eb 0c                	jmp    8007ae <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a7:	eb 05                	jmp    8007ae <fd_lookup+0x54>
  8007a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b9:	ba 50 23 80 00       	mov    $0x802350,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007be:	eb 13                	jmp    8007d3 <dev_lookup+0x23>
  8007c0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007c3:	39 08                	cmp    %ecx,(%eax)
  8007c5:	75 0c                	jne    8007d3 <dev_lookup+0x23>
			*dev = devtab[i];
  8007c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	eb 31                	jmp    800804 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007d3:	8b 02                	mov    (%edx),%eax
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	75 e7                	jne    8007c0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8007de:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8007e4:	83 ec 04             	sub    $0x4,%esp
  8007e7:	51                   	push   %ecx
  8007e8:	50                   	push   %eax
  8007e9:	68 d4 22 80 00       	push   $0x8022d4
  8007ee:	e8 c9 0c 00 00       	call   8014bc <cprintf>
	*dev = 0;
  8007f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007fc:	83 c4 10             	add    $0x10,%esp
  8007ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	83 ec 10             	sub    $0x10,%esp
  80080e:	8b 75 08             	mov    0x8(%ebp),%esi
  800811:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800814:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800817:	50                   	push   %eax
  800818:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80081e:	c1 e8 0c             	shr    $0xc,%eax
  800821:	50                   	push   %eax
  800822:	e8 33 ff ff ff       	call   80075a <fd_lookup>
  800827:	83 c4 08             	add    $0x8,%esp
  80082a:	85 c0                	test   %eax,%eax
  80082c:	78 05                	js     800833 <fd_close+0x2d>
	    || fd != fd2)
  80082e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800831:	74 0c                	je     80083f <fd_close+0x39>
		return (must_exist ? r : 0);
  800833:	84 db                	test   %bl,%bl
  800835:	ba 00 00 00 00       	mov    $0x0,%edx
  80083a:	0f 44 c2             	cmove  %edx,%eax
  80083d:	eb 41                	jmp    800880 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80083f:	83 ec 08             	sub    $0x8,%esp
  800842:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800845:	50                   	push   %eax
  800846:	ff 36                	pushl  (%esi)
  800848:	e8 63 ff ff ff       	call   8007b0 <dev_lookup>
  80084d:	89 c3                	mov    %eax,%ebx
  80084f:	83 c4 10             	add    $0x10,%esp
  800852:	85 c0                	test   %eax,%eax
  800854:	78 1a                	js     800870 <fd_close+0x6a>
		if (dev->dev_close)
  800856:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800859:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80085c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800861:	85 c0                	test   %eax,%eax
  800863:	74 0b                	je     800870 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800865:	83 ec 0c             	sub    $0xc,%esp
  800868:	56                   	push   %esi
  800869:	ff d0                	call   *%eax
  80086b:	89 c3                	mov    %eax,%ebx
  80086d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	56                   	push   %esi
  800874:	6a 00                	push   $0x0
  800876:	e8 83 f9 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	89 d8                	mov    %ebx,%eax
}
  800880:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5d                   	pop    %ebp
  800886:	c3                   	ret    

00800887 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80088d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800890:	50                   	push   %eax
  800891:	ff 75 08             	pushl  0x8(%ebp)
  800894:	e8 c1 fe ff ff       	call   80075a <fd_lookup>
  800899:	83 c4 08             	add    $0x8,%esp
  80089c:	85 c0                	test   %eax,%eax
  80089e:	78 10                	js     8008b0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	6a 01                	push   $0x1
  8008a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8008a8:	e8 59 ff ff ff       	call   800806 <fd_close>
  8008ad:	83 c4 10             	add    $0x10,%esp
}
  8008b0:	c9                   	leave  
  8008b1:	c3                   	ret    

008008b2 <close_all>:

void
close_all(void)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	53                   	push   %ebx
  8008b6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008be:	83 ec 0c             	sub    $0xc,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	e8 c0 ff ff ff       	call   800887 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008c7:	83 c3 01             	add    $0x1,%ebx
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	83 fb 20             	cmp    $0x20,%ebx
  8008d0:	75 ec                	jne    8008be <close_all+0xc>
		close(i);
}
  8008d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	83 ec 2c             	sub    $0x2c,%esp
  8008e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008e6:	50                   	push   %eax
  8008e7:	ff 75 08             	pushl  0x8(%ebp)
  8008ea:	e8 6b fe ff ff       	call   80075a <fd_lookup>
  8008ef:	83 c4 08             	add    $0x8,%esp
  8008f2:	85 c0                	test   %eax,%eax
  8008f4:	0f 88 c1 00 00 00    	js     8009bb <dup+0xe4>
		return r;
	close(newfdnum);
  8008fa:	83 ec 0c             	sub    $0xc,%esp
  8008fd:	56                   	push   %esi
  8008fe:	e8 84 ff ff ff       	call   800887 <close>

	newfd = INDEX2FD(newfdnum);
  800903:	89 f3                	mov    %esi,%ebx
  800905:	c1 e3 0c             	shl    $0xc,%ebx
  800908:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80090e:	83 c4 04             	add    $0x4,%esp
  800911:	ff 75 e4             	pushl  -0x1c(%ebp)
  800914:	e8 db fd ff ff       	call   8006f4 <fd2data>
  800919:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80091b:	89 1c 24             	mov    %ebx,(%esp)
  80091e:	e8 d1 fd ff ff       	call   8006f4 <fd2data>
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800929:	89 f8                	mov    %edi,%eax
  80092b:	c1 e8 16             	shr    $0x16,%eax
  80092e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800935:	a8 01                	test   $0x1,%al
  800937:	74 37                	je     800970 <dup+0x99>
  800939:	89 f8                	mov    %edi,%eax
  80093b:	c1 e8 0c             	shr    $0xc,%eax
  80093e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800945:	f6 c2 01             	test   $0x1,%dl
  800948:	74 26                	je     800970 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80094a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800951:	83 ec 0c             	sub    $0xc,%esp
  800954:	25 07 0e 00 00       	and    $0xe07,%eax
  800959:	50                   	push   %eax
  80095a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80095d:	6a 00                	push   $0x0
  80095f:	57                   	push   %edi
  800960:	6a 00                	push   $0x0
  800962:	e8 55 f8 ff ff       	call   8001bc <sys_page_map>
  800967:	89 c7                	mov    %eax,%edi
  800969:	83 c4 20             	add    $0x20,%esp
  80096c:	85 c0                	test   %eax,%eax
  80096e:	78 2e                	js     80099e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800970:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800973:	89 d0                	mov    %edx,%eax
  800975:	c1 e8 0c             	shr    $0xc,%eax
  800978:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80097f:	83 ec 0c             	sub    $0xc,%esp
  800982:	25 07 0e 00 00       	and    $0xe07,%eax
  800987:	50                   	push   %eax
  800988:	53                   	push   %ebx
  800989:	6a 00                	push   $0x0
  80098b:	52                   	push   %edx
  80098c:	6a 00                	push   $0x0
  80098e:	e8 29 f8 ff ff       	call   8001bc <sys_page_map>
  800993:	89 c7                	mov    %eax,%edi
  800995:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800998:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80099a:	85 ff                	test   %edi,%edi
  80099c:	79 1d                	jns    8009bb <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	53                   	push   %ebx
  8009a2:	6a 00                	push   $0x0
  8009a4:	e8 55 f8 ff ff       	call   8001fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  8009a9:	83 c4 08             	add    $0x8,%esp
  8009ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009af:	6a 00                	push   $0x0
  8009b1:	e8 48 f8 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  8009b6:	83 c4 10             	add    $0x10,%esp
  8009b9:	89 f8                	mov    %edi,%eax
}
  8009bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5f                   	pop    %edi
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	53                   	push   %ebx
  8009c7:	83 ec 14             	sub    $0x14,%esp
  8009ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009d0:	50                   	push   %eax
  8009d1:	53                   	push   %ebx
  8009d2:	e8 83 fd ff ff       	call   80075a <fd_lookup>
  8009d7:	83 c4 08             	add    $0x8,%esp
  8009da:	89 c2                	mov    %eax,%edx
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 70                	js     800a50 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009e6:	50                   	push   %eax
  8009e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009ea:	ff 30                	pushl  (%eax)
  8009ec:	e8 bf fd ff ff       	call   8007b0 <dev_lookup>
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	85 c0                	test   %eax,%eax
  8009f6:	78 4f                	js     800a47 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009fb:	8b 42 08             	mov    0x8(%edx),%eax
  8009fe:	83 e0 03             	and    $0x3,%eax
  800a01:	83 f8 01             	cmp    $0x1,%eax
  800a04:	75 24                	jne    800a2a <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a06:	a1 04 40 80 00       	mov    0x804004,%eax
  800a0b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a11:	83 ec 04             	sub    $0x4,%esp
  800a14:	53                   	push   %ebx
  800a15:	50                   	push   %eax
  800a16:	68 15 23 80 00       	push   $0x802315
  800a1b:	e8 9c 0a 00 00       	call   8014bc <cprintf>
		return -E_INVAL;
  800a20:	83 c4 10             	add    $0x10,%esp
  800a23:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a28:	eb 26                	jmp    800a50 <read+0x8d>
	}
	if (!dev->dev_read)
  800a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a2d:	8b 40 08             	mov    0x8(%eax),%eax
  800a30:	85 c0                	test   %eax,%eax
  800a32:	74 17                	je     800a4b <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a34:	83 ec 04             	sub    $0x4,%esp
  800a37:	ff 75 10             	pushl  0x10(%ebp)
  800a3a:	ff 75 0c             	pushl  0xc(%ebp)
  800a3d:	52                   	push   %edx
  800a3e:	ff d0                	call   *%eax
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	83 c4 10             	add    $0x10,%esp
  800a45:	eb 09                	jmp    800a50 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a47:	89 c2                	mov    %eax,%edx
  800a49:	eb 05                	jmp    800a50 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a4b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a50:	89 d0                	mov    %edx,%eax
  800a52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	57                   	push   %edi
  800a5b:	56                   	push   %esi
  800a5c:	53                   	push   %ebx
  800a5d:	83 ec 0c             	sub    $0xc,%esp
  800a60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a63:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a6b:	eb 21                	jmp    800a8e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a6d:	83 ec 04             	sub    $0x4,%esp
  800a70:	89 f0                	mov    %esi,%eax
  800a72:	29 d8                	sub    %ebx,%eax
  800a74:	50                   	push   %eax
  800a75:	89 d8                	mov    %ebx,%eax
  800a77:	03 45 0c             	add    0xc(%ebp),%eax
  800a7a:	50                   	push   %eax
  800a7b:	57                   	push   %edi
  800a7c:	e8 42 ff ff ff       	call   8009c3 <read>
		if (m < 0)
  800a81:	83 c4 10             	add    $0x10,%esp
  800a84:	85 c0                	test   %eax,%eax
  800a86:	78 10                	js     800a98 <readn+0x41>
			return m;
		if (m == 0)
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	74 0a                	je     800a96 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a8c:	01 c3                	add    %eax,%ebx
  800a8e:	39 f3                	cmp    %esi,%ebx
  800a90:	72 db                	jb     800a6d <readn+0x16>
  800a92:	89 d8                	mov    %ebx,%eax
  800a94:	eb 02                	jmp    800a98 <readn+0x41>
  800a96:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5f                   	pop    %edi
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	53                   	push   %ebx
  800aa4:	83 ec 14             	sub    $0x14,%esp
  800aa7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800aaa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aad:	50                   	push   %eax
  800aae:	53                   	push   %ebx
  800aaf:	e8 a6 fc ff ff       	call   80075a <fd_lookup>
  800ab4:	83 c4 08             	add    $0x8,%esp
  800ab7:	89 c2                	mov    %eax,%edx
  800ab9:	85 c0                	test   %eax,%eax
  800abb:	78 6b                	js     800b28 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800abd:	83 ec 08             	sub    $0x8,%esp
  800ac0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac3:	50                   	push   %eax
  800ac4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac7:	ff 30                	pushl  (%eax)
  800ac9:	e8 e2 fc ff ff       	call   8007b0 <dev_lookup>
  800ace:	83 c4 10             	add    $0x10,%esp
  800ad1:	85 c0                	test   %eax,%eax
  800ad3:	78 4a                	js     800b1f <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800adc:	75 24                	jne    800b02 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800ade:	a1 04 40 80 00       	mov    0x804004,%eax
  800ae3:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800ae9:	83 ec 04             	sub    $0x4,%esp
  800aec:	53                   	push   %ebx
  800aed:	50                   	push   %eax
  800aee:	68 31 23 80 00       	push   $0x802331
  800af3:	e8 c4 09 00 00       	call   8014bc <cprintf>
		return -E_INVAL;
  800af8:	83 c4 10             	add    $0x10,%esp
  800afb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b00:	eb 26                	jmp    800b28 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b05:	8b 52 0c             	mov    0xc(%edx),%edx
  800b08:	85 d2                	test   %edx,%edx
  800b0a:	74 17                	je     800b23 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b0c:	83 ec 04             	sub    $0x4,%esp
  800b0f:	ff 75 10             	pushl  0x10(%ebp)
  800b12:	ff 75 0c             	pushl  0xc(%ebp)
  800b15:	50                   	push   %eax
  800b16:	ff d2                	call   *%edx
  800b18:	89 c2                	mov    %eax,%edx
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	eb 09                	jmp    800b28 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	eb 05                	jmp    800b28 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b23:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b28:	89 d0                	mov    %edx,%eax
  800b2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <seek>:

int
seek(int fdnum, off_t offset)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b35:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b38:	50                   	push   %eax
  800b39:	ff 75 08             	pushl  0x8(%ebp)
  800b3c:	e8 19 fc ff ff       	call   80075a <fd_lookup>
  800b41:	83 c4 08             	add    $0x8,%esp
  800b44:	85 c0                	test   %eax,%eax
  800b46:	78 0e                	js     800b56 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b48:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	53                   	push   %ebx
  800b5c:	83 ec 14             	sub    $0x14,%esp
  800b5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b65:	50                   	push   %eax
  800b66:	53                   	push   %ebx
  800b67:	e8 ee fb ff ff       	call   80075a <fd_lookup>
  800b6c:	83 c4 08             	add    $0x8,%esp
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	85 c0                	test   %eax,%eax
  800b73:	78 68                	js     800bdd <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b75:	83 ec 08             	sub    $0x8,%esp
  800b78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b7b:	50                   	push   %eax
  800b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b7f:	ff 30                	pushl  (%eax)
  800b81:	e8 2a fc ff ff       	call   8007b0 <dev_lookup>
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	85 c0                	test   %eax,%eax
  800b8b:	78 47                	js     800bd4 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b90:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b94:	75 24                	jne    800bba <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b96:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b9b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800ba1:	83 ec 04             	sub    $0x4,%esp
  800ba4:	53                   	push   %ebx
  800ba5:	50                   	push   %eax
  800ba6:	68 f4 22 80 00       	push   $0x8022f4
  800bab:	e8 0c 09 00 00       	call   8014bc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bb8:	eb 23                	jmp    800bdd <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bbd:	8b 52 18             	mov    0x18(%edx),%edx
  800bc0:	85 d2                	test   %edx,%edx
  800bc2:	74 14                	je     800bd8 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800bc4:	83 ec 08             	sub    $0x8,%esp
  800bc7:	ff 75 0c             	pushl  0xc(%ebp)
  800bca:	50                   	push   %eax
  800bcb:	ff d2                	call   *%edx
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	83 c4 10             	add    $0x10,%esp
  800bd2:	eb 09                	jmp    800bdd <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bd4:	89 c2                	mov    %eax,%edx
  800bd6:	eb 05                	jmp    800bdd <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800bd8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800bdd:	89 d0                	mov    %edx,%eax
  800bdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be2:	c9                   	leave  
  800be3:	c3                   	ret    

00800be4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	53                   	push   %ebx
  800be8:	83 ec 14             	sub    $0x14,%esp
  800beb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bf1:	50                   	push   %eax
  800bf2:	ff 75 08             	pushl  0x8(%ebp)
  800bf5:	e8 60 fb ff ff       	call   80075a <fd_lookup>
  800bfa:	83 c4 08             	add    $0x8,%esp
  800bfd:	89 c2                	mov    %eax,%edx
  800bff:	85 c0                	test   %eax,%eax
  800c01:	78 58                	js     800c5b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c03:	83 ec 08             	sub    $0x8,%esp
  800c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c09:	50                   	push   %eax
  800c0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c0d:	ff 30                	pushl  (%eax)
  800c0f:	e8 9c fb ff ff       	call   8007b0 <dev_lookup>
  800c14:	83 c4 10             	add    $0x10,%esp
  800c17:	85 c0                	test   %eax,%eax
  800c19:	78 37                	js     800c52 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c22:	74 32                	je     800c56 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c24:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c27:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c2e:	00 00 00 
	stat->st_isdir = 0;
  800c31:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c38:	00 00 00 
	stat->st_dev = dev;
  800c3b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	53                   	push   %ebx
  800c45:	ff 75 f0             	pushl  -0x10(%ebp)
  800c48:	ff 50 14             	call   *0x14(%eax)
  800c4b:	89 c2                	mov    %eax,%edx
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	eb 09                	jmp    800c5b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c52:	89 c2                	mov    %eax,%edx
  800c54:	eb 05                	jmp    800c5b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c56:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c5b:	89 d0                	mov    %edx,%eax
  800c5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c67:	83 ec 08             	sub    $0x8,%esp
  800c6a:	6a 00                	push   $0x0
  800c6c:	ff 75 08             	pushl  0x8(%ebp)
  800c6f:	e8 e3 01 00 00       	call   800e57 <open>
  800c74:	89 c3                	mov    %eax,%ebx
  800c76:	83 c4 10             	add    $0x10,%esp
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	78 1b                	js     800c98 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c7d:	83 ec 08             	sub    $0x8,%esp
  800c80:	ff 75 0c             	pushl  0xc(%ebp)
  800c83:	50                   	push   %eax
  800c84:	e8 5b ff ff ff       	call   800be4 <fstat>
  800c89:	89 c6                	mov    %eax,%esi
	close(fd);
  800c8b:	89 1c 24             	mov    %ebx,(%esp)
  800c8e:	e8 f4 fb ff ff       	call   800887 <close>
	return r;
  800c93:	83 c4 10             	add    $0x10,%esp
  800c96:	89 f0                	mov    %esi,%eax
}
  800c98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	89 c6                	mov    %eax,%esi
  800ca6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800ca8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800caf:	75 12                	jne    800cc3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	6a 01                	push   $0x1
  800cb6:	e8 39 12 00 00       	call   801ef4 <ipc_find_env>
  800cbb:	a3 00 40 80 00       	mov    %eax,0x804000
  800cc0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cc3:	6a 07                	push   $0x7
  800cc5:	68 00 50 80 00       	push   $0x805000
  800cca:	56                   	push   %esi
  800ccb:	ff 35 00 40 80 00    	pushl  0x804000
  800cd1:	e8 bc 11 00 00       	call   801e92 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800cd6:	83 c4 0c             	add    $0xc,%esp
  800cd9:	6a 00                	push   $0x0
  800cdb:	53                   	push   %ebx
  800cdc:	6a 00                	push   $0x0
  800cde:	e8 34 11 00 00       	call   801e17 <ipc_recv>
}
  800ce3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	8b 40 0c             	mov    0xc(%eax),%eax
  800cf6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfe:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d03:	ba 00 00 00 00       	mov    $0x0,%edx
  800d08:	b8 02 00 00 00       	mov    $0x2,%eax
  800d0d:	e8 8d ff ff ff       	call   800c9f <fsipc>
}
  800d12:	c9                   	leave  
  800d13:	c3                   	ret    

00800d14 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1d:	8b 40 0c             	mov    0xc(%eax),%eax
  800d20:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d25:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2f:	e8 6b ff ff ff       	call   800c9f <fsipc>
}
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 04             	sub    $0x4,%esp
  800d3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d40:	8b 45 08             	mov    0x8(%ebp),%eax
  800d43:	8b 40 0c             	mov    0xc(%eax),%eax
  800d46:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d50:	b8 05 00 00 00       	mov    $0x5,%eax
  800d55:	e8 45 ff ff ff       	call   800c9f <fsipc>
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	78 2c                	js     800d8a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d5e:	83 ec 08             	sub    $0x8,%esp
  800d61:	68 00 50 80 00       	push   $0x805000
  800d66:	53                   	push   %ebx
  800d67:	e8 d5 0c 00 00       	call   801a41 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d6c:	a1 80 50 80 00       	mov    0x805080,%eax
  800d71:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d77:	a1 84 50 80 00       	mov    0x805084,%eax
  800d7c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d82:	83 c4 10             	add    $0x10,%esp
  800d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 52 0c             	mov    0xc(%edx),%edx
  800d9e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800da4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800da9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800dae:	0f 47 c2             	cmova  %edx,%eax
  800db1:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800db6:	50                   	push   %eax
  800db7:	ff 75 0c             	pushl  0xc(%ebp)
  800dba:	68 08 50 80 00       	push   $0x805008
  800dbf:	e8 0f 0e 00 00       	call   801bd3 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800dc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc9:	b8 04 00 00 00       	mov    $0x4,%eax
  800dce:	e8 cc fe ff ff       	call   800c9f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800dd3:	c9                   	leave  
  800dd4:	c3                   	ret    

00800dd5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	56                   	push   %esi
  800dd9:	53                   	push   %ebx
  800dda:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  800de0:	8b 40 0c             	mov    0xc(%eax),%eax
  800de3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800de8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800dee:	ba 00 00 00 00       	mov    $0x0,%edx
  800df3:	b8 03 00 00 00       	mov    $0x3,%eax
  800df8:	e8 a2 fe ff ff       	call   800c9f <fsipc>
  800dfd:	89 c3                	mov    %eax,%ebx
  800dff:	85 c0                	test   %eax,%eax
  800e01:	78 4b                	js     800e4e <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e03:	39 c6                	cmp    %eax,%esi
  800e05:	73 16                	jae    800e1d <devfile_read+0x48>
  800e07:	68 60 23 80 00       	push   $0x802360
  800e0c:	68 67 23 80 00       	push   $0x802367
  800e11:	6a 7c                	push   $0x7c
  800e13:	68 7c 23 80 00       	push   $0x80237c
  800e18:	e8 c6 05 00 00       	call   8013e3 <_panic>
	assert(r <= PGSIZE);
  800e1d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e22:	7e 16                	jle    800e3a <devfile_read+0x65>
  800e24:	68 87 23 80 00       	push   $0x802387
  800e29:	68 67 23 80 00       	push   $0x802367
  800e2e:	6a 7d                	push   $0x7d
  800e30:	68 7c 23 80 00       	push   $0x80237c
  800e35:	e8 a9 05 00 00       	call   8013e3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e3a:	83 ec 04             	sub    $0x4,%esp
  800e3d:	50                   	push   %eax
  800e3e:	68 00 50 80 00       	push   $0x805000
  800e43:	ff 75 0c             	pushl  0xc(%ebp)
  800e46:	e8 88 0d 00 00       	call   801bd3 <memmove>
	return r;
  800e4b:	83 c4 10             	add    $0x10,%esp
}
  800e4e:	89 d8                	mov    %ebx,%eax
  800e50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    

00800e57 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 20             	sub    $0x20,%esp
  800e5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e61:	53                   	push   %ebx
  800e62:	e8 a1 0b 00 00       	call   801a08 <strlen>
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e6f:	7f 67                	jg     800ed8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e71:	83 ec 0c             	sub    $0xc,%esp
  800e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e77:	50                   	push   %eax
  800e78:	e8 8e f8 ff ff       	call   80070b <fd_alloc>
  800e7d:	83 c4 10             	add    $0x10,%esp
		return r;
  800e80:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e82:	85 c0                	test   %eax,%eax
  800e84:	78 57                	js     800edd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e86:	83 ec 08             	sub    $0x8,%esp
  800e89:	53                   	push   %ebx
  800e8a:	68 00 50 80 00       	push   $0x805000
  800e8f:	e8 ad 0b 00 00       	call   801a41 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e97:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e9f:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea4:	e8 f6 fd ff ff       	call   800c9f <fsipc>
  800ea9:	89 c3                	mov    %eax,%ebx
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	79 14                	jns    800ec6 <open+0x6f>
		fd_close(fd, 0);
  800eb2:	83 ec 08             	sub    $0x8,%esp
  800eb5:	6a 00                	push   $0x0
  800eb7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eba:	e8 47 f9 ff ff       	call   800806 <fd_close>
		return r;
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	89 da                	mov    %ebx,%edx
  800ec4:	eb 17                	jmp    800edd <open+0x86>
	}

	return fd2num(fd);
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	ff 75 f4             	pushl  -0xc(%ebp)
  800ecc:	e8 13 f8 ff ff       	call   8006e4 <fd2num>
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	eb 05                	jmp    800edd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ed8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800edd:	89 d0                	mov    %edx,%eax
  800edf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800eea:	ba 00 00 00 00       	mov    $0x0,%edx
  800eef:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef4:	e8 a6 fd ff ff       	call   800c9f <fsipc>
}
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	56                   	push   %esi
  800eff:	53                   	push   %ebx
  800f00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f03:	83 ec 0c             	sub    $0xc,%esp
  800f06:	ff 75 08             	pushl  0x8(%ebp)
  800f09:	e8 e6 f7 ff ff       	call   8006f4 <fd2data>
  800f0e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f10:	83 c4 08             	add    $0x8,%esp
  800f13:	68 93 23 80 00       	push   $0x802393
  800f18:	53                   	push   %ebx
  800f19:	e8 23 0b 00 00       	call   801a41 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f1e:	8b 46 04             	mov    0x4(%esi),%eax
  800f21:	2b 06                	sub    (%esi),%eax
  800f23:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f29:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f30:	00 00 00 
	stat->st_dev = &devpipe;
  800f33:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f3a:	30 80 00 
	return 0;
}
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	53                   	push   %ebx
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f53:	53                   	push   %ebx
  800f54:	6a 00                	push   $0x0
  800f56:	e8 a3 f2 ff ff       	call   8001fe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f5b:	89 1c 24             	mov    %ebx,(%esp)
  800f5e:	e8 91 f7 ff ff       	call   8006f4 <fd2data>
  800f63:	83 c4 08             	add    $0x8,%esp
  800f66:	50                   	push   %eax
  800f67:	6a 00                	push   $0x0
  800f69:	e8 90 f2 ff ff       	call   8001fe <sys_page_unmap>
}
  800f6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
  800f79:	83 ec 1c             	sub    $0x1c,%esp
  800f7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f7f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f81:	a1 04 40 80 00       	mov    0x804004,%eax
  800f86:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	ff 75 e0             	pushl  -0x20(%ebp)
  800f92:	e8 a2 0f 00 00       	call   801f39 <pageref>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	89 3c 24             	mov    %edi,(%esp)
  800f9c:	e8 98 0f 00 00       	call   801f39 <pageref>
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	39 c3                	cmp    %eax,%ebx
  800fa6:	0f 94 c1             	sete   %cl
  800fa9:	0f b6 c9             	movzbl %cl,%ecx
  800fac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800faf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fb5:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  800fbb:	39 ce                	cmp    %ecx,%esi
  800fbd:	74 1e                	je     800fdd <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800fbf:	39 c3                	cmp    %eax,%ebx
  800fc1:	75 be                	jne    800f81 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fc3:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  800fc9:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fcc:	50                   	push   %eax
  800fcd:	56                   	push   %esi
  800fce:	68 9a 23 80 00       	push   $0x80239a
  800fd3:	e8 e4 04 00 00       	call   8014bc <cprintf>
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	eb a4                	jmp    800f81 <_pipeisclosed+0xe>
	}
}
  800fdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe3:	5b                   	pop    %ebx
  800fe4:	5e                   	pop    %esi
  800fe5:	5f                   	pop    %edi
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	57                   	push   %edi
  800fec:	56                   	push   %esi
  800fed:	53                   	push   %ebx
  800fee:	83 ec 28             	sub    $0x28,%esp
  800ff1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800ff4:	56                   	push   %esi
  800ff5:	e8 fa f6 ff ff       	call   8006f4 <fd2data>
  800ffa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ffc:	83 c4 10             	add    $0x10,%esp
  800fff:	bf 00 00 00 00       	mov    $0x0,%edi
  801004:	eb 4b                	jmp    801051 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801006:	89 da                	mov    %ebx,%edx
  801008:	89 f0                	mov    %esi,%eax
  80100a:	e8 64 ff ff ff       	call   800f73 <_pipeisclosed>
  80100f:	85 c0                	test   %eax,%eax
  801011:	75 48                	jne    80105b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801013:	e8 42 f1 ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801018:	8b 43 04             	mov    0x4(%ebx),%eax
  80101b:	8b 0b                	mov    (%ebx),%ecx
  80101d:	8d 51 20             	lea    0x20(%ecx),%edx
  801020:	39 d0                	cmp    %edx,%eax
  801022:	73 e2                	jae    801006 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801024:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801027:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80102b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80102e:	89 c2                	mov    %eax,%edx
  801030:	c1 fa 1f             	sar    $0x1f,%edx
  801033:	89 d1                	mov    %edx,%ecx
  801035:	c1 e9 1b             	shr    $0x1b,%ecx
  801038:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80103b:	83 e2 1f             	and    $0x1f,%edx
  80103e:	29 ca                	sub    %ecx,%edx
  801040:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801044:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801048:	83 c0 01             	add    $0x1,%eax
  80104b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80104e:	83 c7 01             	add    $0x1,%edi
  801051:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801054:	75 c2                	jne    801018 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801056:	8b 45 10             	mov    0x10(%ebp),%eax
  801059:	eb 05                	jmp    801060 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80105b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801060:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801063:	5b                   	pop    %ebx
  801064:	5e                   	pop    %esi
  801065:	5f                   	pop    %edi
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    

00801068 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	57                   	push   %edi
  80106c:	56                   	push   %esi
  80106d:	53                   	push   %ebx
  80106e:	83 ec 18             	sub    $0x18,%esp
  801071:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801074:	57                   	push   %edi
  801075:	e8 7a f6 ff ff       	call   8006f4 <fd2data>
  80107a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80107c:	83 c4 10             	add    $0x10,%esp
  80107f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801084:	eb 3d                	jmp    8010c3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801086:	85 db                	test   %ebx,%ebx
  801088:	74 04                	je     80108e <devpipe_read+0x26>
				return i;
  80108a:	89 d8                	mov    %ebx,%eax
  80108c:	eb 44                	jmp    8010d2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80108e:	89 f2                	mov    %esi,%edx
  801090:	89 f8                	mov    %edi,%eax
  801092:	e8 dc fe ff ff       	call   800f73 <_pipeisclosed>
  801097:	85 c0                	test   %eax,%eax
  801099:	75 32                	jne    8010cd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80109b:	e8 ba f0 ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010a0:	8b 06                	mov    (%esi),%eax
  8010a2:	3b 46 04             	cmp    0x4(%esi),%eax
  8010a5:	74 df                	je     801086 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010a7:	99                   	cltd   
  8010a8:	c1 ea 1b             	shr    $0x1b,%edx
  8010ab:	01 d0                	add    %edx,%eax
  8010ad:	83 e0 1f             	and    $0x1f,%eax
  8010b0:	29 d0                	sub    %edx,%eax
  8010b2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ba:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010bd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010c0:	83 c3 01             	add    $0x1,%ebx
  8010c3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010c6:	75 d8                	jne    8010a0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8010cb:	eb 05                	jmp    8010d2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010cd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d5:	5b                   	pop    %ebx
  8010d6:	5e                   	pop    %esi
  8010d7:	5f                   	pop    %edi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    

008010da <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e5:	50                   	push   %eax
  8010e6:	e8 20 f6 ff ff       	call   80070b <fd_alloc>
  8010eb:	83 c4 10             	add    $0x10,%esp
  8010ee:	89 c2                	mov    %eax,%edx
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	0f 88 2c 01 00 00    	js     801224 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010f8:	83 ec 04             	sub    $0x4,%esp
  8010fb:	68 07 04 00 00       	push   $0x407
  801100:	ff 75 f4             	pushl  -0xc(%ebp)
  801103:	6a 00                	push   $0x0
  801105:	e8 6f f0 ff ff       	call   800179 <sys_page_alloc>
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	89 c2                	mov    %eax,%edx
  80110f:	85 c0                	test   %eax,%eax
  801111:	0f 88 0d 01 00 00    	js     801224 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111d:	50                   	push   %eax
  80111e:	e8 e8 f5 ff ff       	call   80070b <fd_alloc>
  801123:	89 c3                	mov    %eax,%ebx
  801125:	83 c4 10             	add    $0x10,%esp
  801128:	85 c0                	test   %eax,%eax
  80112a:	0f 88 e2 00 00 00    	js     801212 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801130:	83 ec 04             	sub    $0x4,%esp
  801133:	68 07 04 00 00       	push   $0x407
  801138:	ff 75 f0             	pushl  -0x10(%ebp)
  80113b:	6a 00                	push   $0x0
  80113d:	e8 37 f0 ff ff       	call   800179 <sys_page_alloc>
  801142:	89 c3                	mov    %eax,%ebx
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	85 c0                	test   %eax,%eax
  801149:	0f 88 c3 00 00 00    	js     801212 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	ff 75 f4             	pushl  -0xc(%ebp)
  801155:	e8 9a f5 ff ff       	call   8006f4 <fd2data>
  80115a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80115c:	83 c4 0c             	add    $0xc,%esp
  80115f:	68 07 04 00 00       	push   $0x407
  801164:	50                   	push   %eax
  801165:	6a 00                	push   $0x0
  801167:	e8 0d f0 ff ff       	call   800179 <sys_page_alloc>
  80116c:	89 c3                	mov    %eax,%ebx
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	85 c0                	test   %eax,%eax
  801173:	0f 88 89 00 00 00    	js     801202 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	ff 75 f0             	pushl  -0x10(%ebp)
  80117f:	e8 70 f5 ff ff       	call   8006f4 <fd2data>
  801184:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80118b:	50                   	push   %eax
  80118c:	6a 00                	push   $0x0
  80118e:	56                   	push   %esi
  80118f:	6a 00                	push   $0x0
  801191:	e8 26 f0 ff ff       	call   8001bc <sys_page_map>
  801196:	89 c3                	mov    %eax,%ebx
  801198:	83 c4 20             	add    $0x20,%esp
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 55                	js     8011f4 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80119f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011b4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011c9:	83 ec 0c             	sub    $0xc,%esp
  8011cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8011cf:	e8 10 f5 ff ff       	call   8006e4 <fd2num>
  8011d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011d9:	83 c4 04             	add    $0x4,%esp
  8011dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8011df:	e8 00 f5 ff ff       	call   8006e4 <fd2num>
  8011e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e7:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f2:	eb 30                	jmp    801224 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011f4:	83 ec 08             	sub    $0x8,%esp
  8011f7:	56                   	push   %esi
  8011f8:	6a 00                	push   $0x0
  8011fa:	e8 ff ef ff ff       	call   8001fe <sys_page_unmap>
  8011ff:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	ff 75 f0             	pushl  -0x10(%ebp)
  801208:	6a 00                	push   $0x0
  80120a:	e8 ef ef ff ff       	call   8001fe <sys_page_unmap>
  80120f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801212:	83 ec 08             	sub    $0x8,%esp
  801215:	ff 75 f4             	pushl  -0xc(%ebp)
  801218:	6a 00                	push   $0x0
  80121a:	e8 df ef ff ff       	call   8001fe <sys_page_unmap>
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801224:	89 d0                	mov    %edx,%eax
  801226:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801229:	5b                   	pop    %ebx
  80122a:	5e                   	pop    %esi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801233:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	ff 75 08             	pushl  0x8(%ebp)
  80123a:	e8 1b f5 ff ff       	call   80075a <fd_lookup>
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 18                	js     80125e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801246:	83 ec 0c             	sub    $0xc,%esp
  801249:	ff 75 f4             	pushl  -0xc(%ebp)
  80124c:	e8 a3 f4 ff ff       	call   8006f4 <fd2data>
	return _pipeisclosed(fd, p);
  801251:	89 c2                	mov    %eax,%edx
  801253:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801256:	e8 18 fd ff ff       	call   800f73 <_pipeisclosed>
  80125b:	83 c4 10             	add    $0x10,%esp
}
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801270:	68 b2 23 80 00       	push   $0x8023b2
  801275:	ff 75 0c             	pushl  0xc(%ebp)
  801278:	e8 c4 07 00 00       	call   801a41 <strcpy>
	return 0;
}
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
  801282:	c9                   	leave  
  801283:	c3                   	ret    

00801284 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	57                   	push   %edi
  801288:	56                   	push   %esi
  801289:	53                   	push   %ebx
  80128a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801290:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801295:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80129b:	eb 2d                	jmp    8012ca <devcons_write+0x46>
		m = n - tot;
  80129d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012a0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8012a2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012a5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8012aa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012ad:	83 ec 04             	sub    $0x4,%esp
  8012b0:	53                   	push   %ebx
  8012b1:	03 45 0c             	add    0xc(%ebp),%eax
  8012b4:	50                   	push   %eax
  8012b5:	57                   	push   %edi
  8012b6:	e8 18 09 00 00       	call   801bd3 <memmove>
		sys_cputs(buf, m);
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	53                   	push   %ebx
  8012bf:	57                   	push   %edi
  8012c0:	e8 f8 ed ff ff       	call   8000bd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012c5:	01 de                	add    %ebx,%esi
  8012c7:	83 c4 10             	add    $0x10,%esp
  8012ca:	89 f0                	mov    %esi,%eax
  8012cc:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012cf:	72 cc                	jb     80129d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d4:	5b                   	pop    %ebx
  8012d5:	5e                   	pop    %esi
  8012d6:	5f                   	pop    %edi
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    

008012d9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012e8:	74 2a                	je     801314 <devcons_read+0x3b>
  8012ea:	eb 05                	jmp    8012f1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012ec:	e8 69 ee ff ff       	call   80015a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012f1:	e8 e5 ed ff ff       	call   8000db <sys_cgetc>
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	74 f2                	je     8012ec <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 16                	js     801314 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012fe:	83 f8 04             	cmp    $0x4,%eax
  801301:	74 0c                	je     80130f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801303:	8b 55 0c             	mov    0xc(%ebp),%edx
  801306:	88 02                	mov    %al,(%edx)
	return 1;
  801308:	b8 01 00 00 00       	mov    $0x1,%eax
  80130d:	eb 05                	jmp    801314 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80130f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80131c:	8b 45 08             	mov    0x8(%ebp),%eax
  80131f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801322:	6a 01                	push   $0x1
  801324:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801327:	50                   	push   %eax
  801328:	e8 90 ed ff ff       	call   8000bd <sys_cputs>
}
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	c9                   	leave  
  801331:	c3                   	ret    

00801332 <getchar>:

int
getchar(void)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801338:	6a 01                	push   $0x1
  80133a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80133d:	50                   	push   %eax
  80133e:	6a 00                	push   $0x0
  801340:	e8 7e f6 ff ff       	call   8009c3 <read>
	if (r < 0)
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	85 c0                	test   %eax,%eax
  80134a:	78 0f                	js     80135b <getchar+0x29>
		return r;
	if (r < 1)
  80134c:	85 c0                	test   %eax,%eax
  80134e:	7e 06                	jle    801356 <getchar+0x24>
		return -E_EOF;
	return c;
  801350:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801354:	eb 05                	jmp    80135b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801356:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801363:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801366:	50                   	push   %eax
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 eb f3 ff ff       	call   80075a <fd_lookup>
  80136f:	83 c4 10             	add    $0x10,%esp
  801372:	85 c0                	test   %eax,%eax
  801374:	78 11                	js     801387 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801376:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801379:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80137f:	39 10                	cmp    %edx,(%eax)
  801381:	0f 94 c0             	sete   %al
  801384:	0f b6 c0             	movzbl %al,%eax
}
  801387:	c9                   	leave  
  801388:	c3                   	ret    

00801389 <opencons>:

int
opencons(void)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80138f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801392:	50                   	push   %eax
  801393:	e8 73 f3 ff ff       	call   80070b <fd_alloc>
  801398:	83 c4 10             	add    $0x10,%esp
		return r;
  80139b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 3e                	js     8013df <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013a1:	83 ec 04             	sub    $0x4,%esp
  8013a4:	68 07 04 00 00       	push   $0x407
  8013a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ac:	6a 00                	push   $0x0
  8013ae:	e8 c6 ed ff ff       	call   800179 <sys_page_alloc>
  8013b3:	83 c4 10             	add    $0x10,%esp
		return r;
  8013b6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 23                	js     8013df <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013bc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013d1:	83 ec 0c             	sub    $0xc,%esp
  8013d4:	50                   	push   %eax
  8013d5:	e8 0a f3 ff ff       	call   8006e4 <fd2num>
  8013da:	89 c2                	mov    %eax,%edx
  8013dc:	83 c4 10             	add    $0x10,%esp
}
  8013df:	89 d0                	mov    %edx,%eax
  8013e1:	c9                   	leave  
  8013e2:	c3                   	ret    

008013e3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	56                   	push   %esi
  8013e7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013e8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013eb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013f1:	e8 45 ed ff ff       	call   80013b <sys_getenvid>
  8013f6:	83 ec 0c             	sub    $0xc,%esp
  8013f9:	ff 75 0c             	pushl  0xc(%ebp)
  8013fc:	ff 75 08             	pushl  0x8(%ebp)
  8013ff:	56                   	push   %esi
  801400:	50                   	push   %eax
  801401:	68 c0 23 80 00       	push   $0x8023c0
  801406:	e8 b1 00 00 00       	call   8014bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80140b:	83 c4 18             	add    $0x18,%esp
  80140e:	53                   	push   %ebx
  80140f:	ff 75 10             	pushl  0x10(%ebp)
  801412:	e8 54 00 00 00       	call   80146b <vcprintf>
	cprintf("\n");
  801417:	c7 04 24 ab 23 80 00 	movl   $0x8023ab,(%esp)
  80141e:	e8 99 00 00 00       	call   8014bc <cprintf>
  801423:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801426:	cc                   	int3   
  801427:	eb fd                	jmp    801426 <_panic+0x43>

00801429 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	53                   	push   %ebx
  80142d:	83 ec 04             	sub    $0x4,%esp
  801430:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801433:	8b 13                	mov    (%ebx),%edx
  801435:	8d 42 01             	lea    0x1(%edx),%eax
  801438:	89 03                	mov    %eax,(%ebx)
  80143a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801441:	3d ff 00 00 00       	cmp    $0xff,%eax
  801446:	75 1a                	jne    801462 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801448:	83 ec 08             	sub    $0x8,%esp
  80144b:	68 ff 00 00 00       	push   $0xff
  801450:	8d 43 08             	lea    0x8(%ebx),%eax
  801453:	50                   	push   %eax
  801454:	e8 64 ec ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  801459:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80145f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801462:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801466:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801474:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80147b:	00 00 00 
	b.cnt = 0;
  80147e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801485:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801488:	ff 75 0c             	pushl  0xc(%ebp)
  80148b:	ff 75 08             	pushl  0x8(%ebp)
  80148e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	68 29 14 80 00       	push   $0x801429
  80149a:	e8 54 01 00 00       	call   8015f3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	e8 09 ec ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  8014b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014c5:	50                   	push   %eax
  8014c6:	ff 75 08             	pushl  0x8(%ebp)
  8014c9:	e8 9d ff ff ff       	call   80146b <vcprintf>
	va_end(ap);

	return cnt;
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	57                   	push   %edi
  8014d4:	56                   	push   %esi
  8014d5:	53                   	push   %ebx
  8014d6:	83 ec 1c             	sub    $0x1c,%esp
  8014d9:	89 c7                	mov    %eax,%edi
  8014db:	89 d6                	mov    %edx,%esi
  8014dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014f4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014f7:	39 d3                	cmp    %edx,%ebx
  8014f9:	72 05                	jb     801500 <printnum+0x30>
  8014fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014fe:	77 45                	ja     801545 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801500:	83 ec 0c             	sub    $0xc,%esp
  801503:	ff 75 18             	pushl  0x18(%ebp)
  801506:	8b 45 14             	mov    0x14(%ebp),%eax
  801509:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80150c:	53                   	push   %ebx
  80150d:	ff 75 10             	pushl  0x10(%ebp)
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	ff 75 e4             	pushl  -0x1c(%ebp)
  801516:	ff 75 e0             	pushl  -0x20(%ebp)
  801519:	ff 75 dc             	pushl  -0x24(%ebp)
  80151c:	ff 75 d8             	pushl  -0x28(%ebp)
  80151f:	e8 5c 0a 00 00       	call   801f80 <__udivdi3>
  801524:	83 c4 18             	add    $0x18,%esp
  801527:	52                   	push   %edx
  801528:	50                   	push   %eax
  801529:	89 f2                	mov    %esi,%edx
  80152b:	89 f8                	mov    %edi,%eax
  80152d:	e8 9e ff ff ff       	call   8014d0 <printnum>
  801532:	83 c4 20             	add    $0x20,%esp
  801535:	eb 18                	jmp    80154f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	56                   	push   %esi
  80153b:	ff 75 18             	pushl  0x18(%ebp)
  80153e:	ff d7                	call   *%edi
  801540:	83 c4 10             	add    $0x10,%esp
  801543:	eb 03                	jmp    801548 <printnum+0x78>
  801545:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801548:	83 eb 01             	sub    $0x1,%ebx
  80154b:	85 db                	test   %ebx,%ebx
  80154d:	7f e8                	jg     801537 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	56                   	push   %esi
  801553:	83 ec 04             	sub    $0x4,%esp
  801556:	ff 75 e4             	pushl  -0x1c(%ebp)
  801559:	ff 75 e0             	pushl  -0x20(%ebp)
  80155c:	ff 75 dc             	pushl  -0x24(%ebp)
  80155f:	ff 75 d8             	pushl  -0x28(%ebp)
  801562:	e8 49 0b 00 00       	call   8020b0 <__umoddi3>
  801567:	83 c4 14             	add    $0x14,%esp
  80156a:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801571:	50                   	push   %eax
  801572:	ff d7                	call   *%edi
}
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157a:	5b                   	pop    %ebx
  80157b:	5e                   	pop    %esi
  80157c:	5f                   	pop    %edi
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    

0080157f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80157f:	55                   	push   %ebp
  801580:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801582:	83 fa 01             	cmp    $0x1,%edx
  801585:	7e 0e                	jle    801595 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801587:	8b 10                	mov    (%eax),%edx
  801589:	8d 4a 08             	lea    0x8(%edx),%ecx
  80158c:	89 08                	mov    %ecx,(%eax)
  80158e:	8b 02                	mov    (%edx),%eax
  801590:	8b 52 04             	mov    0x4(%edx),%edx
  801593:	eb 22                	jmp    8015b7 <getuint+0x38>
	else if (lflag)
  801595:	85 d2                	test   %edx,%edx
  801597:	74 10                	je     8015a9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801599:	8b 10                	mov    (%eax),%edx
  80159b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80159e:	89 08                	mov    %ecx,(%eax)
  8015a0:	8b 02                	mov    (%edx),%eax
  8015a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a7:	eb 0e                	jmp    8015b7 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015a9:	8b 10                	mov    (%eax),%edx
  8015ab:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015ae:	89 08                	mov    %ecx,(%eax)
  8015b0:	8b 02                	mov    (%edx),%eax
  8015b2:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015b7:	5d                   	pop    %ebp
  8015b8:	c3                   	ret    

008015b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015c3:	8b 10                	mov    (%eax),%edx
  8015c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8015c8:	73 0a                	jae    8015d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8015ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015cd:	89 08                	mov    %ecx,(%eax)
  8015cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d2:	88 02                	mov    %al,(%edx)
}
  8015d4:	5d                   	pop    %ebp
  8015d5:	c3                   	ret    

008015d6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015df:	50                   	push   %eax
  8015e0:	ff 75 10             	pushl  0x10(%ebp)
  8015e3:	ff 75 0c             	pushl  0xc(%ebp)
  8015e6:	ff 75 08             	pushl  0x8(%ebp)
  8015e9:	e8 05 00 00 00       	call   8015f3 <vprintfmt>
	va_end(ap);
}
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	c9                   	leave  
  8015f2:	c3                   	ret    

008015f3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	57                   	push   %edi
  8015f7:	56                   	push   %esi
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 2c             	sub    $0x2c,%esp
  8015fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801602:	8b 7d 10             	mov    0x10(%ebp),%edi
  801605:	eb 12                	jmp    801619 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801607:	85 c0                	test   %eax,%eax
  801609:	0f 84 89 03 00 00    	je     801998 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	53                   	push   %ebx
  801613:	50                   	push   %eax
  801614:	ff d6                	call   *%esi
  801616:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801619:	83 c7 01             	add    $0x1,%edi
  80161c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801620:	83 f8 25             	cmp    $0x25,%eax
  801623:	75 e2                	jne    801607 <vprintfmt+0x14>
  801625:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801629:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801630:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801637:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80163e:	ba 00 00 00 00       	mov    $0x0,%edx
  801643:	eb 07                	jmp    80164c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801645:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801648:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164c:	8d 47 01             	lea    0x1(%edi),%eax
  80164f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801652:	0f b6 07             	movzbl (%edi),%eax
  801655:	0f b6 c8             	movzbl %al,%ecx
  801658:	83 e8 23             	sub    $0x23,%eax
  80165b:	3c 55                	cmp    $0x55,%al
  80165d:	0f 87 1a 03 00 00    	ja     80197d <vprintfmt+0x38a>
  801663:	0f b6 c0             	movzbl %al,%eax
  801666:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80166d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801670:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801674:	eb d6                	jmp    80164c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801679:	b8 00 00 00 00       	mov    $0x0,%eax
  80167e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801681:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801684:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801688:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80168b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80168e:	83 fa 09             	cmp    $0x9,%edx
  801691:	77 39                	ja     8016cc <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801693:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801696:	eb e9                	jmp    801681 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801698:	8b 45 14             	mov    0x14(%ebp),%eax
  80169b:	8d 48 04             	lea    0x4(%eax),%ecx
  80169e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8016a1:	8b 00                	mov    (%eax),%eax
  8016a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016a9:	eb 27                	jmp    8016d2 <vprintfmt+0xdf>
  8016ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016b5:	0f 49 c8             	cmovns %eax,%ecx
  8016b8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016be:	eb 8c                	jmp    80164c <vprintfmt+0x59>
  8016c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8016c3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016ca:	eb 80                	jmp    80164c <vprintfmt+0x59>
  8016cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016cf:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016d2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016d6:	0f 89 70 ff ff ff    	jns    80164c <vprintfmt+0x59>
				width = precision, precision = -1;
  8016dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016e9:	e9 5e ff ff ff       	jmp    80164c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016ee:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016f4:	e9 53 ff ff ff       	jmp    80164c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8016fc:	8d 50 04             	lea    0x4(%eax),%edx
  8016ff:	89 55 14             	mov    %edx,0x14(%ebp)
  801702:	83 ec 08             	sub    $0x8,%esp
  801705:	53                   	push   %ebx
  801706:	ff 30                	pushl  (%eax)
  801708:	ff d6                	call   *%esi
			break;
  80170a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801710:	e9 04 ff ff ff       	jmp    801619 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801715:	8b 45 14             	mov    0x14(%ebp),%eax
  801718:	8d 50 04             	lea    0x4(%eax),%edx
  80171b:	89 55 14             	mov    %edx,0x14(%ebp)
  80171e:	8b 00                	mov    (%eax),%eax
  801720:	99                   	cltd   
  801721:	31 d0                	xor    %edx,%eax
  801723:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801725:	83 f8 0f             	cmp    $0xf,%eax
  801728:	7f 0b                	jg     801735 <vprintfmt+0x142>
  80172a:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801731:	85 d2                	test   %edx,%edx
  801733:	75 18                	jne    80174d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801735:	50                   	push   %eax
  801736:	68 fb 23 80 00       	push   $0x8023fb
  80173b:	53                   	push   %ebx
  80173c:	56                   	push   %esi
  80173d:	e8 94 fe ff ff       	call   8015d6 <printfmt>
  801742:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801745:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801748:	e9 cc fe ff ff       	jmp    801619 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80174d:	52                   	push   %edx
  80174e:	68 79 23 80 00       	push   $0x802379
  801753:	53                   	push   %ebx
  801754:	56                   	push   %esi
  801755:	e8 7c fe ff ff       	call   8015d6 <printfmt>
  80175a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801760:	e9 b4 fe ff ff       	jmp    801619 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801765:	8b 45 14             	mov    0x14(%ebp),%eax
  801768:	8d 50 04             	lea    0x4(%eax),%edx
  80176b:	89 55 14             	mov    %edx,0x14(%ebp)
  80176e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801770:	85 ff                	test   %edi,%edi
  801772:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801777:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80177a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80177e:	0f 8e 94 00 00 00    	jle    801818 <vprintfmt+0x225>
  801784:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801788:	0f 84 98 00 00 00    	je     801826 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80178e:	83 ec 08             	sub    $0x8,%esp
  801791:	ff 75 d0             	pushl  -0x30(%ebp)
  801794:	57                   	push   %edi
  801795:	e8 86 02 00 00       	call   801a20 <strnlen>
  80179a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80179d:	29 c1                	sub    %eax,%ecx
  80179f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8017a2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017a5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ac:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017af:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017b1:	eb 0f                	jmp    8017c2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8017b3:	83 ec 08             	sub    $0x8,%esp
  8017b6:	53                   	push   %ebx
  8017b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8017ba:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017bc:	83 ef 01             	sub    $0x1,%edi
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	85 ff                	test   %edi,%edi
  8017c4:	7f ed                	jg     8017b3 <vprintfmt+0x1c0>
  8017c6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017cc:	85 c9                	test   %ecx,%ecx
  8017ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d3:	0f 49 c1             	cmovns %ecx,%eax
  8017d6:	29 c1                	sub    %eax,%ecx
  8017d8:	89 75 08             	mov    %esi,0x8(%ebp)
  8017db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017de:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017e1:	89 cb                	mov    %ecx,%ebx
  8017e3:	eb 4d                	jmp    801832 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017e5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017e9:	74 1b                	je     801806 <vprintfmt+0x213>
  8017eb:	0f be c0             	movsbl %al,%eax
  8017ee:	83 e8 20             	sub    $0x20,%eax
  8017f1:	83 f8 5e             	cmp    $0x5e,%eax
  8017f4:	76 10                	jbe    801806 <vprintfmt+0x213>
					putch('?', putdat);
  8017f6:	83 ec 08             	sub    $0x8,%esp
  8017f9:	ff 75 0c             	pushl  0xc(%ebp)
  8017fc:	6a 3f                	push   $0x3f
  8017fe:	ff 55 08             	call   *0x8(%ebp)
  801801:	83 c4 10             	add    $0x10,%esp
  801804:	eb 0d                	jmp    801813 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801806:	83 ec 08             	sub    $0x8,%esp
  801809:	ff 75 0c             	pushl  0xc(%ebp)
  80180c:	52                   	push   %edx
  80180d:	ff 55 08             	call   *0x8(%ebp)
  801810:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801813:	83 eb 01             	sub    $0x1,%ebx
  801816:	eb 1a                	jmp    801832 <vprintfmt+0x23f>
  801818:	89 75 08             	mov    %esi,0x8(%ebp)
  80181b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80181e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801821:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801824:	eb 0c                	jmp    801832 <vprintfmt+0x23f>
  801826:	89 75 08             	mov    %esi,0x8(%ebp)
  801829:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80182c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80182f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801832:	83 c7 01             	add    $0x1,%edi
  801835:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801839:	0f be d0             	movsbl %al,%edx
  80183c:	85 d2                	test   %edx,%edx
  80183e:	74 23                	je     801863 <vprintfmt+0x270>
  801840:	85 f6                	test   %esi,%esi
  801842:	78 a1                	js     8017e5 <vprintfmt+0x1f2>
  801844:	83 ee 01             	sub    $0x1,%esi
  801847:	79 9c                	jns    8017e5 <vprintfmt+0x1f2>
  801849:	89 df                	mov    %ebx,%edi
  80184b:	8b 75 08             	mov    0x8(%ebp),%esi
  80184e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801851:	eb 18                	jmp    80186b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	53                   	push   %ebx
  801857:	6a 20                	push   $0x20
  801859:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80185b:	83 ef 01             	sub    $0x1,%edi
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	eb 08                	jmp    80186b <vprintfmt+0x278>
  801863:	89 df                	mov    %ebx,%edi
  801865:	8b 75 08             	mov    0x8(%ebp),%esi
  801868:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80186b:	85 ff                	test   %edi,%edi
  80186d:	7f e4                	jg     801853 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801872:	e9 a2 fd ff ff       	jmp    801619 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801877:	83 fa 01             	cmp    $0x1,%edx
  80187a:	7e 16                	jle    801892 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80187c:	8b 45 14             	mov    0x14(%ebp),%eax
  80187f:	8d 50 08             	lea    0x8(%eax),%edx
  801882:	89 55 14             	mov    %edx,0x14(%ebp)
  801885:	8b 50 04             	mov    0x4(%eax),%edx
  801888:	8b 00                	mov    (%eax),%eax
  80188a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80188d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801890:	eb 32                	jmp    8018c4 <vprintfmt+0x2d1>
	else if (lflag)
  801892:	85 d2                	test   %edx,%edx
  801894:	74 18                	je     8018ae <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801896:	8b 45 14             	mov    0x14(%ebp),%eax
  801899:	8d 50 04             	lea    0x4(%eax),%edx
  80189c:	89 55 14             	mov    %edx,0x14(%ebp)
  80189f:	8b 00                	mov    (%eax),%eax
  8018a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018a4:	89 c1                	mov    %eax,%ecx
  8018a6:	c1 f9 1f             	sar    $0x1f,%ecx
  8018a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018ac:	eb 16                	jmp    8018c4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8018ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b1:	8d 50 04             	lea    0x4(%eax),%edx
  8018b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b7:	8b 00                	mov    (%eax),%eax
  8018b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018bc:	89 c1                	mov    %eax,%ecx
  8018be:	c1 f9 1f             	sar    $0x1f,%ecx
  8018c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018cf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018d3:	79 74                	jns    801949 <vprintfmt+0x356>
				putch('-', putdat);
  8018d5:	83 ec 08             	sub    $0x8,%esp
  8018d8:	53                   	push   %ebx
  8018d9:	6a 2d                	push   $0x2d
  8018db:	ff d6                	call   *%esi
				num = -(long long) num;
  8018dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018e3:	f7 d8                	neg    %eax
  8018e5:	83 d2 00             	adc    $0x0,%edx
  8018e8:	f7 da                	neg    %edx
  8018ea:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018f2:	eb 55                	jmp    801949 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8018f7:	e8 83 fc ff ff       	call   80157f <getuint>
			base = 10;
  8018fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801901:	eb 46                	jmp    801949 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801903:	8d 45 14             	lea    0x14(%ebp),%eax
  801906:	e8 74 fc ff ff       	call   80157f <getuint>
			base = 8;
  80190b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801910:	eb 37                	jmp    801949 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801912:	83 ec 08             	sub    $0x8,%esp
  801915:	53                   	push   %ebx
  801916:	6a 30                	push   $0x30
  801918:	ff d6                	call   *%esi
			putch('x', putdat);
  80191a:	83 c4 08             	add    $0x8,%esp
  80191d:	53                   	push   %ebx
  80191e:	6a 78                	push   $0x78
  801920:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801922:	8b 45 14             	mov    0x14(%ebp),%eax
  801925:	8d 50 04             	lea    0x4(%eax),%edx
  801928:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80192b:	8b 00                	mov    (%eax),%eax
  80192d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801932:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801935:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80193a:	eb 0d                	jmp    801949 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80193c:	8d 45 14             	lea    0x14(%ebp),%eax
  80193f:	e8 3b fc ff ff       	call   80157f <getuint>
			base = 16;
  801944:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801949:	83 ec 0c             	sub    $0xc,%esp
  80194c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801950:	57                   	push   %edi
  801951:	ff 75 e0             	pushl  -0x20(%ebp)
  801954:	51                   	push   %ecx
  801955:	52                   	push   %edx
  801956:	50                   	push   %eax
  801957:	89 da                	mov    %ebx,%edx
  801959:	89 f0                	mov    %esi,%eax
  80195b:	e8 70 fb ff ff       	call   8014d0 <printnum>
			break;
  801960:	83 c4 20             	add    $0x20,%esp
  801963:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801966:	e9 ae fc ff ff       	jmp    801619 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80196b:	83 ec 08             	sub    $0x8,%esp
  80196e:	53                   	push   %ebx
  80196f:	51                   	push   %ecx
  801970:	ff d6                	call   *%esi
			break;
  801972:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801975:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801978:	e9 9c fc ff ff       	jmp    801619 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	53                   	push   %ebx
  801981:	6a 25                	push   $0x25
  801983:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	eb 03                	jmp    80198d <vprintfmt+0x39a>
  80198a:	83 ef 01             	sub    $0x1,%edi
  80198d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801991:	75 f7                	jne    80198a <vprintfmt+0x397>
  801993:	e9 81 fc ff ff       	jmp    801619 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801998:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199b:	5b                   	pop    %ebx
  80199c:	5e                   	pop    %esi
  80199d:	5f                   	pop    %edi
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 18             	sub    $0x18,%esp
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019af:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019b3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	74 26                	je     8019e7 <vsnprintf+0x47>
  8019c1:	85 d2                	test   %edx,%edx
  8019c3:	7e 22                	jle    8019e7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019c5:	ff 75 14             	pushl  0x14(%ebp)
  8019c8:	ff 75 10             	pushl  0x10(%ebp)
  8019cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019ce:	50                   	push   %eax
  8019cf:	68 b9 15 80 00       	push   $0x8015b9
  8019d4:	e8 1a fc ff ff       	call   8015f3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019dc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	eb 05                	jmp    8019ec <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019ec:	c9                   	leave  
  8019ed:	c3                   	ret    

008019ee <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019f4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019f7:	50                   	push   %eax
  8019f8:	ff 75 10             	pushl  0x10(%ebp)
  8019fb:	ff 75 0c             	pushl  0xc(%ebp)
  8019fe:	ff 75 08             	pushl  0x8(%ebp)
  801a01:	e8 9a ff ff ff       	call   8019a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a13:	eb 03                	jmp    801a18 <strlen+0x10>
		n++;
  801a15:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a18:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a1c:	75 f7                	jne    801a15 <strlen+0xd>
		n++;
	return n;
}
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    

00801a20 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a26:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a29:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2e:	eb 03                	jmp    801a33 <strnlen+0x13>
		n++;
  801a30:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a33:	39 c2                	cmp    %eax,%edx
  801a35:	74 08                	je     801a3f <strnlen+0x1f>
  801a37:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a3b:	75 f3                	jne    801a30 <strnlen+0x10>
  801a3d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    

00801a41 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	53                   	push   %ebx
  801a45:	8b 45 08             	mov    0x8(%ebp),%eax
  801a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a4b:	89 c2                	mov    %eax,%edx
  801a4d:	83 c2 01             	add    $0x1,%edx
  801a50:	83 c1 01             	add    $0x1,%ecx
  801a53:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a57:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a5a:	84 db                	test   %bl,%bl
  801a5c:	75 ef                	jne    801a4d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a5e:	5b                   	pop    %ebx
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    

00801a61 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	53                   	push   %ebx
  801a65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a68:	53                   	push   %ebx
  801a69:	e8 9a ff ff ff       	call   801a08 <strlen>
  801a6e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a71:	ff 75 0c             	pushl  0xc(%ebp)
  801a74:	01 d8                	add    %ebx,%eax
  801a76:	50                   	push   %eax
  801a77:	e8 c5 ff ff ff       	call   801a41 <strcpy>
	return dst;
}
  801a7c:	89 d8                	mov    %ebx,%eax
  801a7e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	56                   	push   %esi
  801a87:	53                   	push   %ebx
  801a88:	8b 75 08             	mov    0x8(%ebp),%esi
  801a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8e:	89 f3                	mov    %esi,%ebx
  801a90:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a93:	89 f2                	mov    %esi,%edx
  801a95:	eb 0f                	jmp    801aa6 <strncpy+0x23>
		*dst++ = *src;
  801a97:	83 c2 01             	add    $0x1,%edx
  801a9a:	0f b6 01             	movzbl (%ecx),%eax
  801a9d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801aa0:	80 39 01             	cmpb   $0x1,(%ecx)
  801aa3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801aa6:	39 da                	cmp    %ebx,%edx
  801aa8:	75 ed                	jne    801a97 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801aaa:	89 f0                	mov    %esi,%eax
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	56                   	push   %esi
  801ab4:	53                   	push   %ebx
  801ab5:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801abb:	8b 55 10             	mov    0x10(%ebp),%edx
  801abe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ac0:	85 d2                	test   %edx,%edx
  801ac2:	74 21                	je     801ae5 <strlcpy+0x35>
  801ac4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ac8:	89 f2                	mov    %esi,%edx
  801aca:	eb 09                	jmp    801ad5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801acc:	83 c2 01             	add    $0x1,%edx
  801acf:	83 c1 01             	add    $0x1,%ecx
  801ad2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ad5:	39 c2                	cmp    %eax,%edx
  801ad7:	74 09                	je     801ae2 <strlcpy+0x32>
  801ad9:	0f b6 19             	movzbl (%ecx),%ebx
  801adc:	84 db                	test   %bl,%bl
  801ade:	75 ec                	jne    801acc <strlcpy+0x1c>
  801ae0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ae2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801ae5:	29 f0                	sub    %esi,%eax
}
  801ae7:	5b                   	pop    %ebx
  801ae8:	5e                   	pop    %esi
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801af4:	eb 06                	jmp    801afc <strcmp+0x11>
		p++, q++;
  801af6:	83 c1 01             	add    $0x1,%ecx
  801af9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801afc:	0f b6 01             	movzbl (%ecx),%eax
  801aff:	84 c0                	test   %al,%al
  801b01:	74 04                	je     801b07 <strcmp+0x1c>
  801b03:	3a 02                	cmp    (%edx),%al
  801b05:	74 ef                	je     801af6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b07:	0f b6 c0             	movzbl %al,%eax
  801b0a:	0f b6 12             	movzbl (%edx),%edx
  801b0d:	29 d0                	sub    %edx,%eax
}
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    

00801b11 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	53                   	push   %ebx
  801b15:	8b 45 08             	mov    0x8(%ebp),%eax
  801b18:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1b:	89 c3                	mov    %eax,%ebx
  801b1d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b20:	eb 06                	jmp    801b28 <strncmp+0x17>
		n--, p++, q++;
  801b22:	83 c0 01             	add    $0x1,%eax
  801b25:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b28:	39 d8                	cmp    %ebx,%eax
  801b2a:	74 15                	je     801b41 <strncmp+0x30>
  801b2c:	0f b6 08             	movzbl (%eax),%ecx
  801b2f:	84 c9                	test   %cl,%cl
  801b31:	74 04                	je     801b37 <strncmp+0x26>
  801b33:	3a 0a                	cmp    (%edx),%cl
  801b35:	74 eb                	je     801b22 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b37:	0f b6 00             	movzbl (%eax),%eax
  801b3a:	0f b6 12             	movzbl (%edx),%edx
  801b3d:	29 d0                	sub    %edx,%eax
  801b3f:	eb 05                	jmp    801b46 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b41:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b46:	5b                   	pop    %ebx
  801b47:	5d                   	pop    %ebp
  801b48:	c3                   	ret    

00801b49 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b49:	55                   	push   %ebp
  801b4a:	89 e5                	mov    %esp,%ebp
  801b4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b53:	eb 07                	jmp    801b5c <strchr+0x13>
		if (*s == c)
  801b55:	38 ca                	cmp    %cl,%dl
  801b57:	74 0f                	je     801b68 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b59:	83 c0 01             	add    $0x1,%eax
  801b5c:	0f b6 10             	movzbl (%eax),%edx
  801b5f:	84 d2                	test   %dl,%dl
  801b61:	75 f2                	jne    801b55 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b74:	eb 03                	jmp    801b79 <strfind+0xf>
  801b76:	83 c0 01             	add    $0x1,%eax
  801b79:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b7c:	38 ca                	cmp    %cl,%dl
  801b7e:	74 04                	je     801b84 <strfind+0x1a>
  801b80:	84 d2                	test   %dl,%dl
  801b82:	75 f2                	jne    801b76 <strfind+0xc>
			break;
	return (char *) s;
}
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    

00801b86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	57                   	push   %edi
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b92:	85 c9                	test   %ecx,%ecx
  801b94:	74 36                	je     801bcc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b96:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b9c:	75 28                	jne    801bc6 <memset+0x40>
  801b9e:	f6 c1 03             	test   $0x3,%cl
  801ba1:	75 23                	jne    801bc6 <memset+0x40>
		c &= 0xFF;
  801ba3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ba7:	89 d3                	mov    %edx,%ebx
  801ba9:	c1 e3 08             	shl    $0x8,%ebx
  801bac:	89 d6                	mov    %edx,%esi
  801bae:	c1 e6 18             	shl    $0x18,%esi
  801bb1:	89 d0                	mov    %edx,%eax
  801bb3:	c1 e0 10             	shl    $0x10,%eax
  801bb6:	09 f0                	or     %esi,%eax
  801bb8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801bba:	89 d8                	mov    %ebx,%eax
  801bbc:	09 d0                	or     %edx,%eax
  801bbe:	c1 e9 02             	shr    $0x2,%ecx
  801bc1:	fc                   	cld    
  801bc2:	f3 ab                	rep stos %eax,%es:(%edi)
  801bc4:	eb 06                	jmp    801bcc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc9:	fc                   	cld    
  801bca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bcc:	89 f8                	mov    %edi,%eax
  801bce:	5b                   	pop    %ebx
  801bcf:	5e                   	pop    %esi
  801bd0:	5f                   	pop    %edi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	57                   	push   %edi
  801bd7:	56                   	push   %esi
  801bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801be1:	39 c6                	cmp    %eax,%esi
  801be3:	73 35                	jae    801c1a <memmove+0x47>
  801be5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801be8:	39 d0                	cmp    %edx,%eax
  801bea:	73 2e                	jae    801c1a <memmove+0x47>
		s += n;
		d += n;
  801bec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bef:	89 d6                	mov    %edx,%esi
  801bf1:	09 fe                	or     %edi,%esi
  801bf3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bf9:	75 13                	jne    801c0e <memmove+0x3b>
  801bfb:	f6 c1 03             	test   $0x3,%cl
  801bfe:	75 0e                	jne    801c0e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801c00:	83 ef 04             	sub    $0x4,%edi
  801c03:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c06:	c1 e9 02             	shr    $0x2,%ecx
  801c09:	fd                   	std    
  801c0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c0c:	eb 09                	jmp    801c17 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c0e:	83 ef 01             	sub    $0x1,%edi
  801c11:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c14:	fd                   	std    
  801c15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c17:	fc                   	cld    
  801c18:	eb 1d                	jmp    801c37 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c1a:	89 f2                	mov    %esi,%edx
  801c1c:	09 c2                	or     %eax,%edx
  801c1e:	f6 c2 03             	test   $0x3,%dl
  801c21:	75 0f                	jne    801c32 <memmove+0x5f>
  801c23:	f6 c1 03             	test   $0x3,%cl
  801c26:	75 0a                	jne    801c32 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c28:	c1 e9 02             	shr    $0x2,%ecx
  801c2b:	89 c7                	mov    %eax,%edi
  801c2d:	fc                   	cld    
  801c2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c30:	eb 05                	jmp    801c37 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c32:	89 c7                	mov    %eax,%edi
  801c34:	fc                   	cld    
  801c35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c37:	5e                   	pop    %esi
  801c38:	5f                   	pop    %edi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c3e:	ff 75 10             	pushl  0x10(%ebp)
  801c41:	ff 75 0c             	pushl  0xc(%ebp)
  801c44:	ff 75 08             	pushl  0x8(%ebp)
  801c47:	e8 87 ff ff ff       	call   801bd3 <memmove>
}
  801c4c:	c9                   	leave  
  801c4d:	c3                   	ret    

00801c4e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	8b 45 08             	mov    0x8(%ebp),%eax
  801c56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c59:	89 c6                	mov    %eax,%esi
  801c5b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c5e:	eb 1a                	jmp    801c7a <memcmp+0x2c>
		if (*s1 != *s2)
  801c60:	0f b6 08             	movzbl (%eax),%ecx
  801c63:	0f b6 1a             	movzbl (%edx),%ebx
  801c66:	38 d9                	cmp    %bl,%cl
  801c68:	74 0a                	je     801c74 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c6a:	0f b6 c1             	movzbl %cl,%eax
  801c6d:	0f b6 db             	movzbl %bl,%ebx
  801c70:	29 d8                	sub    %ebx,%eax
  801c72:	eb 0f                	jmp    801c83 <memcmp+0x35>
		s1++, s2++;
  801c74:	83 c0 01             	add    $0x1,%eax
  801c77:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c7a:	39 f0                	cmp    %esi,%eax
  801c7c:	75 e2                	jne    801c60 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5d                   	pop    %ebp
  801c86:	c3                   	ret    

00801c87 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c87:	55                   	push   %ebp
  801c88:	89 e5                	mov    %esp,%ebp
  801c8a:	53                   	push   %ebx
  801c8b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c8e:	89 c1                	mov    %eax,%ecx
  801c90:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c93:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c97:	eb 0a                	jmp    801ca3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c99:	0f b6 10             	movzbl (%eax),%edx
  801c9c:	39 da                	cmp    %ebx,%edx
  801c9e:	74 07                	je     801ca7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ca0:	83 c0 01             	add    $0x1,%eax
  801ca3:	39 c8                	cmp    %ecx,%eax
  801ca5:	72 f2                	jb     801c99 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801ca7:	5b                   	pop    %ebx
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    

00801caa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	57                   	push   %edi
  801cae:	56                   	push   %esi
  801caf:	53                   	push   %ebx
  801cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cb6:	eb 03                	jmp    801cbb <strtol+0x11>
		s++;
  801cb8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cbb:	0f b6 01             	movzbl (%ecx),%eax
  801cbe:	3c 20                	cmp    $0x20,%al
  801cc0:	74 f6                	je     801cb8 <strtol+0xe>
  801cc2:	3c 09                	cmp    $0x9,%al
  801cc4:	74 f2                	je     801cb8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801cc6:	3c 2b                	cmp    $0x2b,%al
  801cc8:	75 0a                	jne    801cd4 <strtol+0x2a>
		s++;
  801cca:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ccd:	bf 00 00 00 00       	mov    $0x0,%edi
  801cd2:	eb 11                	jmp    801ce5 <strtol+0x3b>
  801cd4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801cd9:	3c 2d                	cmp    $0x2d,%al
  801cdb:	75 08                	jne    801ce5 <strtol+0x3b>
		s++, neg = 1;
  801cdd:	83 c1 01             	add    $0x1,%ecx
  801ce0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ce5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ceb:	75 15                	jne    801d02 <strtol+0x58>
  801ced:	80 39 30             	cmpb   $0x30,(%ecx)
  801cf0:	75 10                	jne    801d02 <strtol+0x58>
  801cf2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cf6:	75 7c                	jne    801d74 <strtol+0xca>
		s += 2, base = 16;
  801cf8:	83 c1 02             	add    $0x2,%ecx
  801cfb:	bb 10 00 00 00       	mov    $0x10,%ebx
  801d00:	eb 16                	jmp    801d18 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801d02:	85 db                	test   %ebx,%ebx
  801d04:	75 12                	jne    801d18 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d06:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d0b:	80 39 30             	cmpb   $0x30,(%ecx)
  801d0e:	75 08                	jne    801d18 <strtol+0x6e>
		s++, base = 8;
  801d10:	83 c1 01             	add    $0x1,%ecx
  801d13:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d18:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d20:	0f b6 11             	movzbl (%ecx),%edx
  801d23:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d26:	89 f3                	mov    %esi,%ebx
  801d28:	80 fb 09             	cmp    $0x9,%bl
  801d2b:	77 08                	ja     801d35 <strtol+0x8b>
			dig = *s - '0';
  801d2d:	0f be d2             	movsbl %dl,%edx
  801d30:	83 ea 30             	sub    $0x30,%edx
  801d33:	eb 22                	jmp    801d57 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d35:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d38:	89 f3                	mov    %esi,%ebx
  801d3a:	80 fb 19             	cmp    $0x19,%bl
  801d3d:	77 08                	ja     801d47 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d3f:	0f be d2             	movsbl %dl,%edx
  801d42:	83 ea 57             	sub    $0x57,%edx
  801d45:	eb 10                	jmp    801d57 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d47:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d4a:	89 f3                	mov    %esi,%ebx
  801d4c:	80 fb 19             	cmp    $0x19,%bl
  801d4f:	77 16                	ja     801d67 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d51:	0f be d2             	movsbl %dl,%edx
  801d54:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d57:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d5a:	7d 0b                	jge    801d67 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d5c:	83 c1 01             	add    $0x1,%ecx
  801d5f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d63:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d65:	eb b9                	jmp    801d20 <strtol+0x76>

	if (endptr)
  801d67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d6b:	74 0d                	je     801d7a <strtol+0xd0>
		*endptr = (char *) s;
  801d6d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d70:	89 0e                	mov    %ecx,(%esi)
  801d72:	eb 06                	jmp    801d7a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d74:	85 db                	test   %ebx,%ebx
  801d76:	74 98                	je     801d10 <strtol+0x66>
  801d78:	eb 9e                	jmp    801d18 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d7a:	89 c2                	mov    %eax,%edx
  801d7c:	f7 da                	neg    %edx
  801d7e:	85 ff                	test   %edi,%edi
  801d80:	0f 45 c2             	cmovne %edx,%eax
}
  801d83:	5b                   	pop    %ebx
  801d84:	5e                   	pop    %esi
  801d85:	5f                   	pop    %edi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d8e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d95:	75 2a                	jne    801dc1 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d97:	83 ec 04             	sub    $0x4,%esp
  801d9a:	6a 07                	push   $0x7
  801d9c:	68 00 f0 bf ee       	push   $0xeebff000
  801da1:	6a 00                	push   $0x0
  801da3:	e8 d1 e3 ff ff       	call   800179 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	79 12                	jns    801dc1 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801daf:	50                   	push   %eax
  801db0:	68 e0 26 80 00       	push   $0x8026e0
  801db5:	6a 23                	push   $0x23
  801db7:	68 e4 26 80 00       	push   $0x8026e4
  801dbc:	e8 22 f6 ff ff       	call   8013e3 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc4:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	68 f3 1d 80 00       	push   $0x801df3
  801dd1:	6a 00                	push   $0x0
  801dd3:	e8 ec e4 ff ff       	call   8002c4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801dd8:	83 c4 10             	add    $0x10,%esp
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	79 12                	jns    801df1 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801ddf:	50                   	push   %eax
  801de0:	68 e0 26 80 00       	push   $0x8026e0
  801de5:	6a 2c                	push   $0x2c
  801de7:	68 e4 26 80 00       	push   $0x8026e4
  801dec:	e8 f2 f5 ff ff       	call   8013e3 <_panic>
	}
}
  801df1:	c9                   	leave  
  801df2:	c3                   	ret    

00801df3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801df3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801df4:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801df9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dfb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dfe:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e02:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e07:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e0b:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e0d:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e10:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e11:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e14:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e15:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e16:	c3                   	ret    

00801e17 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
  801e1c:	8b 75 08             	mov    0x8(%ebp),%esi
  801e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e25:	85 c0                	test   %eax,%eax
  801e27:	75 12                	jne    801e3b <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e29:	83 ec 0c             	sub    $0xc,%esp
  801e2c:	68 00 00 c0 ee       	push   $0xeec00000
  801e31:	e8 f3 e4 ff ff       	call   800329 <sys_ipc_recv>
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	eb 0c                	jmp    801e47 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e3b:	83 ec 0c             	sub    $0xc,%esp
  801e3e:	50                   	push   %eax
  801e3f:	e8 e5 e4 ff ff       	call   800329 <sys_ipc_recv>
  801e44:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e47:	85 f6                	test   %esi,%esi
  801e49:	0f 95 c1             	setne  %cl
  801e4c:	85 db                	test   %ebx,%ebx
  801e4e:	0f 95 c2             	setne  %dl
  801e51:	84 d1                	test   %dl,%cl
  801e53:	74 09                	je     801e5e <ipc_recv+0x47>
  801e55:	89 c2                	mov    %eax,%edx
  801e57:	c1 ea 1f             	shr    $0x1f,%edx
  801e5a:	84 d2                	test   %dl,%dl
  801e5c:	75 2d                	jne    801e8b <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e5e:	85 f6                	test   %esi,%esi
  801e60:	74 0d                	je     801e6f <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e62:	a1 04 40 80 00       	mov    0x804004,%eax
  801e67:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801e6d:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e6f:	85 db                	test   %ebx,%ebx
  801e71:	74 0d                	je     801e80 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e73:	a1 04 40 80 00       	mov    0x804004,%eax
  801e78:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801e7e:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e80:	a1 04 40 80 00       	mov    0x804004,%eax
  801e85:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801e8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8e:	5b                   	pop    %ebx
  801e8f:	5e                   	pop    %esi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    

00801e92 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	57                   	push   %edi
  801e96:	56                   	push   %esi
  801e97:	53                   	push   %ebx
  801e98:	83 ec 0c             	sub    $0xc,%esp
  801e9b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ea1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ea4:	85 db                	test   %ebx,%ebx
  801ea6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eab:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801eae:	ff 75 14             	pushl  0x14(%ebp)
  801eb1:	53                   	push   %ebx
  801eb2:	56                   	push   %esi
  801eb3:	57                   	push   %edi
  801eb4:	e8 4d e4 ff ff       	call   800306 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801eb9:	89 c2                	mov    %eax,%edx
  801ebb:	c1 ea 1f             	shr    $0x1f,%edx
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	84 d2                	test   %dl,%dl
  801ec3:	74 17                	je     801edc <ipc_send+0x4a>
  801ec5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec8:	74 12                	je     801edc <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801eca:	50                   	push   %eax
  801ecb:	68 f2 26 80 00       	push   $0x8026f2
  801ed0:	6a 47                	push   $0x47
  801ed2:	68 00 27 80 00       	push   $0x802700
  801ed7:	e8 07 f5 ff ff       	call   8013e3 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801edc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801edf:	75 07                	jne    801ee8 <ipc_send+0x56>
			sys_yield();
  801ee1:	e8 74 e2 ff ff       	call   80015a <sys_yield>
  801ee6:	eb c6                	jmp    801eae <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	75 c2                	jne    801eae <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eef:	5b                   	pop    %ebx
  801ef0:	5e                   	pop    %esi
  801ef1:	5f                   	pop    %edi
  801ef2:	5d                   	pop    %ebp
  801ef3:	c3                   	ret    

00801ef4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801efa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eff:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f05:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f0b:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f11:	39 ca                	cmp    %ecx,%edx
  801f13:	75 13                	jne    801f28 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f15:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f1b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f20:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f26:	eb 0f                	jmp    801f37 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f28:	83 c0 01             	add    $0x1,%eax
  801f2b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f30:	75 cd                	jne    801eff <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    

00801f39 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f39:	55                   	push   %ebp
  801f3a:	89 e5                	mov    %esp,%ebp
  801f3c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3f:	89 d0                	mov    %edx,%eax
  801f41:	c1 e8 16             	shr    $0x16,%eax
  801f44:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f4b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f50:	f6 c1 01             	test   $0x1,%cl
  801f53:	74 1d                	je     801f72 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f55:	c1 ea 0c             	shr    $0xc,%edx
  801f58:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f5f:	f6 c2 01             	test   $0x1,%dl
  801f62:	74 0e                	je     801f72 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f64:	c1 ea 0c             	shr    $0xc,%edx
  801f67:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f6e:	ef 
  801f6f:	0f b7 c0             	movzwl %ax,%eax
}
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    
  801f74:	66 90                	xchg   %ax,%ax
  801f76:	66 90                	xchg   %ax,%ax
  801f78:	66 90                	xchg   %ax,%ax
  801f7a:	66 90                	xchg   %ax,%ax
  801f7c:	66 90                	xchg   %ax,%ax
  801f7e:	66 90                	xchg   %ax,%ax

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 f6                	test   %esi,%esi
  801f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9d:	89 ca                	mov    %ecx,%edx
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	75 3d                	jne    801fe0 <__udivdi3+0x60>
  801fa3:	39 cf                	cmp    %ecx,%edi
  801fa5:	0f 87 c5 00 00 00    	ja     802070 <__udivdi3+0xf0>
  801fab:	85 ff                	test   %edi,%edi
  801fad:	89 fd                	mov    %edi,%ebp
  801faf:	75 0b                	jne    801fbc <__udivdi3+0x3c>
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	31 d2                	xor    %edx,%edx
  801fb8:	f7 f7                	div    %edi
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	89 c8                	mov    %ecx,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f5                	div    %ebp
  801fc2:	89 c1                	mov    %eax,%ecx
  801fc4:	89 d8                	mov    %ebx,%eax
  801fc6:	89 cf                	mov    %ecx,%edi
  801fc8:	f7 f5                	div    %ebp
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	89 fa                	mov    %edi,%edx
  801fd0:	83 c4 1c             	add    $0x1c,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
  801fd8:	90                   	nop
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	39 ce                	cmp    %ecx,%esi
  801fe2:	77 74                	ja     802058 <__udivdi3+0xd8>
  801fe4:	0f bd fe             	bsr    %esi,%edi
  801fe7:	83 f7 1f             	xor    $0x1f,%edi
  801fea:	0f 84 98 00 00 00    	je     802088 <__udivdi3+0x108>
  801ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	89 c5                	mov    %eax,%ebp
  801ff9:	29 fb                	sub    %edi,%ebx
  801ffb:	d3 e6                	shl    %cl,%esi
  801ffd:	89 d9                	mov    %ebx,%ecx
  801fff:	d3 ed                	shr    %cl,%ebp
  802001:	89 f9                	mov    %edi,%ecx
  802003:	d3 e0                	shl    %cl,%eax
  802005:	09 ee                	or     %ebp,%esi
  802007:	89 d9                	mov    %ebx,%ecx
  802009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200d:	89 d5                	mov    %edx,%ebp
  80200f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802013:	d3 ed                	shr    %cl,%ebp
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 d9                	mov    %ebx,%ecx
  80201b:	d3 e8                	shr    %cl,%eax
  80201d:	09 c2                	or     %eax,%edx
  80201f:	89 d0                	mov    %edx,%eax
  802021:	89 ea                	mov    %ebp,%edx
  802023:	f7 f6                	div    %esi
  802025:	89 d5                	mov    %edx,%ebp
  802027:	89 c3                	mov    %eax,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	72 10                	jb     802041 <__udivdi3+0xc1>
  802031:	8b 74 24 08          	mov    0x8(%esp),%esi
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e6                	shl    %cl,%esi
  802039:	39 c6                	cmp    %eax,%esi
  80203b:	73 07                	jae    802044 <__udivdi3+0xc4>
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	75 03                	jne    802044 <__udivdi3+0xc4>
  802041:	83 eb 01             	sub    $0x1,%ebx
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 d8                	mov    %ebx,%eax
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	31 ff                	xor    %edi,%edi
  80205a:	31 db                	xor    %ebx,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d8                	mov    %ebx,%eax
  802072:	f7 f7                	div    %edi
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 c3                	mov    %eax,%ebx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 fa                	mov    %edi,%edx
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	39 ce                	cmp    %ecx,%esi
  80208a:	72 0c                	jb     802098 <__udivdi3+0x118>
  80208c:	31 db                	xor    %ebx,%ebx
  80208e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802092:	0f 87 34 ff ff ff    	ja     801fcc <__udivdi3+0x4c>
  802098:	bb 01 00 00 00       	mov    $0x1,%ebx
  80209d:	e9 2a ff ff ff       	jmp    801fcc <__udivdi3+0x4c>
  8020a2:	66 90                	xchg   %ax,%ax
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 d2                	test   %edx,%edx
  8020c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f3                	mov    %esi,%ebx
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	75 1c                	jne    8020f8 <__umoddi3+0x48>
  8020dc:	39 f7                	cmp    %esi,%edi
  8020de:	76 50                	jbe    802130 <__umoddi3+0x80>
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	f7 f7                	div    %edi
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	31 d2                	xor    %edx,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	89 d0                	mov    %edx,%eax
  8020fc:	77 52                	ja     802150 <__umoddi3+0xa0>
  8020fe:	0f bd ea             	bsr    %edx,%ebp
  802101:	83 f5 1f             	xor    $0x1f,%ebp
  802104:	75 5a                	jne    802160 <__umoddi3+0xb0>
  802106:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80210a:	0f 82 e0 00 00 00    	jb     8021f0 <__umoddi3+0x140>
  802110:	39 0c 24             	cmp    %ecx,(%esp)
  802113:	0f 86 d7 00 00 00    	jbe    8021f0 <__umoddi3+0x140>
  802119:	8b 44 24 08          	mov    0x8(%esp),%eax
  80211d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	85 ff                	test   %edi,%edi
  802132:	89 fd                	mov    %edi,%ebp
  802134:	75 0b                	jne    802141 <__umoddi3+0x91>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f7                	div    %edi
  80213f:	89 c5                	mov    %eax,%ebp
  802141:	89 f0                	mov    %esi,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	f7 f5                	div    %ebp
  802147:	89 c8                	mov    %ecx,%eax
  802149:	f7 f5                	div    %ebp
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	eb 99                	jmp    8020e8 <__umoddi3+0x38>
  80214f:	90                   	nop
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	83 c4 1c             	add    $0x1c,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	8b 34 24             	mov    (%esp),%esi
  802163:	bf 20 00 00 00       	mov    $0x20,%edi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	29 ef                	sub    %ebp,%edi
  80216c:	d3 e0                	shl    %cl,%eax
  80216e:	89 f9                	mov    %edi,%ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	d3 ea                	shr    %cl,%edx
  802174:	89 e9                	mov    %ebp,%ecx
  802176:	09 c2                	or     %eax,%edx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 14 24             	mov    %edx,(%esp)
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	d3 e2                	shl    %cl,%edx
  802181:	89 f9                	mov    %edi,%ecx
  802183:	89 54 24 04          	mov    %edx,0x4(%esp)
  802187:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	89 c6                	mov    %eax,%esi
  802191:	d3 e3                	shl    %cl,%ebx
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 d0                	mov    %edx,%eax
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	09 d8                	or     %ebx,%eax
  80219d:	89 d3                	mov    %edx,%ebx
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	f7 34 24             	divl   (%esp)
  8021a4:	89 d6                	mov    %edx,%esi
  8021a6:	d3 e3                	shl    %cl,%ebx
  8021a8:	f7 64 24 04          	mull   0x4(%esp)
  8021ac:	39 d6                	cmp    %edx,%esi
  8021ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b2:	89 d1                	mov    %edx,%ecx
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	72 08                	jb     8021c0 <__umoddi3+0x110>
  8021b8:	75 11                	jne    8021cb <__umoddi3+0x11b>
  8021ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021be:	73 0b                	jae    8021cb <__umoddi3+0x11b>
  8021c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021c4:	1b 14 24             	sbb    (%esp),%edx
  8021c7:	89 d1                	mov    %edx,%ecx
  8021c9:	89 c3                	mov    %eax,%ebx
  8021cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021cf:	29 da                	sub    %ebx,%edx
  8021d1:	19 ce                	sbb    %ecx,%esi
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e0                	shl    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	d3 ea                	shr    %cl,%edx
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	09 d0                	or     %edx,%eax
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	83 c4 1c             	add    $0x1c,%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	29 f9                	sub    %edi,%ecx
  8021f2:	19 d6                	sbb    %edx,%esi
  8021f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021fc:	e9 18 ff ff ff       	jmp    802119 <__umoddi3+0x69>
