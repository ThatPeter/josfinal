
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
  8000a9:	e8 66 0a 00 00       	call   800b14 <close_all>
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
  800122:	68 8a 24 80 00       	push   $0x80248a
  800127:	6a 23                	push   $0x23
  800129:	68 a7 24 80 00       	push   $0x8024a7
  80012e:	e8 12 15 00 00       	call   801645 <_panic>

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
  8001a3:	68 8a 24 80 00       	push   $0x80248a
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 a7 24 80 00       	push   $0x8024a7
  8001af:	e8 91 14 00 00       	call   801645 <_panic>

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
  8001e5:	68 8a 24 80 00       	push   $0x80248a
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 a7 24 80 00       	push   $0x8024a7
  8001f1:	e8 4f 14 00 00       	call   801645 <_panic>

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
  800227:	68 8a 24 80 00       	push   $0x80248a
  80022c:	6a 23                	push   $0x23
  80022e:	68 a7 24 80 00       	push   $0x8024a7
  800233:	e8 0d 14 00 00       	call   801645 <_panic>

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
  800269:	68 8a 24 80 00       	push   $0x80248a
  80026e:	6a 23                	push   $0x23
  800270:	68 a7 24 80 00       	push   $0x8024a7
  800275:	e8 cb 13 00 00       	call   801645 <_panic>

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
  8002ab:	68 8a 24 80 00       	push   $0x80248a
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 a7 24 80 00       	push   $0x8024a7
  8002b7:	e8 89 13 00 00       	call   801645 <_panic>
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
  8002ed:	68 8a 24 80 00       	push   $0x80248a
  8002f2:	6a 23                	push   $0x23
  8002f4:	68 a7 24 80 00       	push   $0x8024a7
  8002f9:	e8 47 13 00 00       	call   801645 <_panic>

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
  800351:	68 8a 24 80 00       	push   $0x80248a
  800356:	6a 23                	push   $0x23
  800358:	68 a7 24 80 00       	push   $0x8024a7
  80035d:	e8 e3 12 00 00       	call   801645 <_panic>

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
  8003f0:	68 b5 24 80 00       	push   $0x8024b5
  8003f5:	6a 1f                	push   $0x1f
  8003f7:	68 c5 24 80 00       	push   $0x8024c5
  8003fc:	e8 44 12 00 00       	call   801645 <_panic>
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
  80041a:	68 d0 24 80 00       	push   $0x8024d0
  80041f:	6a 2d                	push   $0x2d
  800421:	68 c5 24 80 00       	push   $0x8024c5
  800426:	e8 1a 12 00 00       	call   801645 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80042b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800431:	83 ec 04             	sub    $0x4,%esp
  800434:	68 00 10 00 00       	push   $0x1000
  800439:	53                   	push   %ebx
  80043a:	68 00 f0 7f 00       	push   $0x7ff000
  80043f:	e8 59 1a 00 00       	call   801e9d <memcpy>

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
  800462:	68 d0 24 80 00       	push   $0x8024d0
  800467:	6a 34                	push   $0x34
  800469:	68 c5 24 80 00       	push   $0x8024c5
  80046e:	e8 d2 11 00 00       	call   801645 <_panic>
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
  80048a:	68 d0 24 80 00       	push   $0x8024d0
  80048f:	6a 38                	push   $0x38
  800491:	68 c5 24 80 00       	push   $0x8024c5
  800496:	e8 aa 11 00 00       	call   801645 <_panic>
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
  8004ae:	e8 37 1b 00 00       	call   801fea <set_pgfault_handler>
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
  8004c7:	68 e9 24 80 00       	push   $0x8024e9
  8004cc:	68 85 00 00 00       	push   $0x85
  8004d1:	68 c5 24 80 00       	push   $0x8024c5
  8004d6:	e8 6a 11 00 00       	call   801645 <_panic>
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
  800583:	68 f7 24 80 00       	push   $0x8024f7
  800588:	6a 55                	push   $0x55
  80058a:	68 c5 24 80 00       	push   $0x8024c5
  80058f:	e8 b1 10 00 00       	call   801645 <_panic>
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
  8005c8:	68 f7 24 80 00       	push   $0x8024f7
  8005cd:	6a 5c                	push   $0x5c
  8005cf:	68 c5 24 80 00       	push   $0x8024c5
  8005d4:	e8 6c 10 00 00       	call   801645 <_panic>
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
  8005f6:	68 f7 24 80 00       	push   $0x8024f7
  8005fb:	6a 60                	push   $0x60
  8005fd:	68 c5 24 80 00       	push   $0x8024c5
  800602:	e8 3e 10 00 00       	call   801645 <_panic>
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
  800620:	68 f7 24 80 00       	push   $0x8024f7
  800625:	6a 65                	push   $0x65
  800627:	68 c5 24 80 00       	push   $0x8024c5
  80062c:	e8 14 10 00 00       	call   801645 <_panic>
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
  80068f:	68 88 25 80 00       	push   $0x802588
  800694:	e8 85 10 00 00       	call   80171e <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800699:	c7 04 24 83 00 80 00 	movl   $0x800083,(%esp)
  8006a0:	e8 c5 fc ff ff       	call   80036a <sys_thread_create>
  8006a5:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006a7:	83 c4 08             	add    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	68 88 25 80 00       	push   $0x802588
  8006b0:	e8 69 10 00 00       	call   80171e <cprintf>
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

008006e4 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
  8006e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006ef:	83 ec 04             	sub    $0x4,%esp
  8006f2:	6a 07                	push   $0x7
  8006f4:	6a 00                	push   $0x0
  8006f6:	56                   	push   %esi
  8006f7:	e8 7d fa ff ff       	call   800179 <sys_page_alloc>
	if (r < 0) {
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	85 c0                	test   %eax,%eax
  800701:	79 15                	jns    800718 <queue_append+0x34>
		panic("%e\n", r);
  800703:	50                   	push   %eax
  800704:	68 83 25 80 00       	push   $0x802583
  800709:	68 c4 00 00 00       	push   $0xc4
  80070e:	68 c5 24 80 00       	push   $0x8024c5
  800713:	e8 2d 0f 00 00       	call   801645 <_panic>
	}	
	wt->envid = envid;
  800718:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  80071e:	83 ec 04             	sub    $0x4,%esp
  800721:	ff 33                	pushl  (%ebx)
  800723:	56                   	push   %esi
  800724:	68 ac 25 80 00       	push   $0x8025ac
  800729:	e8 f0 0f 00 00       	call   80171e <cprintf>
	if (queue->first == NULL) {
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	83 3b 00             	cmpl   $0x0,(%ebx)
  800734:	75 29                	jne    80075f <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  800736:	83 ec 0c             	sub    $0xc,%esp
  800739:	68 0d 25 80 00       	push   $0x80250d
  80073e:	e8 db 0f 00 00       	call   80171e <cprintf>
		queue->first = wt;
  800743:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  800749:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800750:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800757:	00 00 00 
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	eb 2b                	jmp    80078a <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  80075f:	83 ec 0c             	sub    $0xc,%esp
  800762:	68 27 25 80 00       	push   $0x802527
  800767:	e8 b2 0f 00 00       	call   80171e <cprintf>
		queue->last->next = wt;
  80076c:	8b 43 04             	mov    0x4(%ebx),%eax
  80076f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800776:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80077d:	00 00 00 
		queue->last = wt;
  800780:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  800787:	83 c4 10             	add    $0x10,%esp
	}
}
  80078a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80078d:	5b                   	pop    %ebx
  80078e:	5e                   	pop    %esi
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	53                   	push   %ebx
  800795:	83 ec 04             	sub    $0x4,%esp
  800798:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80079b:	8b 02                	mov    (%edx),%eax
  80079d:	85 c0                	test   %eax,%eax
  80079f:	75 17                	jne    8007b8 <queue_pop+0x27>
		panic("queue empty!\n");
  8007a1:	83 ec 04             	sub    $0x4,%esp
  8007a4:	68 45 25 80 00       	push   $0x802545
  8007a9:	68 d8 00 00 00       	push   $0xd8
  8007ae:	68 c5 24 80 00       	push   $0x8024c5
  8007b3:	e8 8d 0e 00 00       	call   801645 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8007b8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007bb:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8007bd:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	53                   	push   %ebx
  8007c3:	68 53 25 80 00       	push   $0x802553
  8007c8:	e8 51 0f 00 00       	call   80171e <cprintf>
	return envid;
}
  8007cd:	89 d8                	mov    %ebx,%eax
  8007cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	83 ec 04             	sub    $0x4,%esp
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8007de:	b8 01 00 00 00       	mov    $0x1,%eax
  8007e3:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	74 5a                	je     800844 <mutex_lock+0x70>
  8007ea:	8b 43 04             	mov    0x4(%ebx),%eax
  8007ed:	83 38 00             	cmpl   $0x0,(%eax)
  8007f0:	75 52                	jne    800844 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8007f2:	83 ec 0c             	sub    $0xc,%esp
  8007f5:	68 d4 25 80 00       	push   $0x8025d4
  8007fa:	e8 1f 0f 00 00       	call   80171e <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8007ff:	8b 5b 04             	mov    0x4(%ebx),%ebx
  800802:	e8 34 f9 ff ff       	call   80013b <sys_getenvid>
  800807:	83 c4 08             	add    $0x8,%esp
  80080a:	53                   	push   %ebx
  80080b:	50                   	push   %eax
  80080c:	e8 d3 fe ff ff       	call   8006e4 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800811:	e8 25 f9 ff ff       	call   80013b <sys_getenvid>
  800816:	83 c4 08             	add    $0x8,%esp
  800819:	6a 04                	push   $0x4
  80081b:	50                   	push   %eax
  80081c:	e8 1f fa ff ff       	call   800240 <sys_env_set_status>
		if (r < 0) {
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	85 c0                	test   %eax,%eax
  800826:	79 15                	jns    80083d <mutex_lock+0x69>
			panic("%e\n", r);
  800828:	50                   	push   %eax
  800829:	68 83 25 80 00       	push   $0x802583
  80082e:	68 eb 00 00 00       	push   $0xeb
  800833:	68 c5 24 80 00       	push   $0x8024c5
  800838:	e8 08 0e 00 00       	call   801645 <_panic>
		}
		sys_yield();
  80083d:	e8 18 f9 ff ff       	call   80015a <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800842:	eb 18                	jmp    80085c <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  800844:	83 ec 0c             	sub    $0xc,%esp
  800847:	68 f4 25 80 00       	push   $0x8025f4
  80084c:	e8 cd 0e 00 00       	call   80171e <cprintf>
	mtx->owner = sys_getenvid();}
  800851:	e8 e5 f8 ff ff       	call   80013b <sys_getenvid>
  800856:	89 43 08             	mov    %eax,0x8(%ebx)
  800859:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80085c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085f:	c9                   	leave  
  800860:	c3                   	ret    

00800861 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	83 ec 04             	sub    $0x4,%esp
  800868:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
  800870:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  800873:	8b 43 04             	mov    0x4(%ebx),%eax
  800876:	83 38 00             	cmpl   $0x0,(%eax)
  800879:	74 33                	je     8008ae <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80087b:	83 ec 0c             	sub    $0xc,%esp
  80087e:	50                   	push   %eax
  80087f:	e8 0d ff ff ff       	call   800791 <queue_pop>
  800884:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800887:	83 c4 08             	add    $0x8,%esp
  80088a:	6a 02                	push   $0x2
  80088c:	50                   	push   %eax
  80088d:	e8 ae f9 ff ff       	call   800240 <sys_env_set_status>
		if (r < 0) {
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	85 c0                	test   %eax,%eax
  800897:	79 15                	jns    8008ae <mutex_unlock+0x4d>
			panic("%e\n", r);
  800899:	50                   	push   %eax
  80089a:	68 83 25 80 00       	push   $0x802583
  80089f:	68 00 01 00 00       	push   $0x100
  8008a4:	68 c5 24 80 00       	push   $0x8024c5
  8008a9:	e8 97 0d 00 00       	call   801645 <_panic>
		}
	}

	asm volatile("pause");
  8008ae:	f3 90                	pause  
	//sys_yield();
}
  8008b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b3:	c9                   	leave  
  8008b4:	c3                   	ret    

008008b5 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	53                   	push   %ebx
  8008b9:	83 ec 04             	sub    $0x4,%esp
  8008bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8008bf:	e8 77 f8 ff ff       	call   80013b <sys_getenvid>
  8008c4:	83 ec 04             	sub    $0x4,%esp
  8008c7:	6a 07                	push   $0x7
  8008c9:	53                   	push   %ebx
  8008ca:	50                   	push   %eax
  8008cb:	e8 a9 f8 ff ff       	call   800179 <sys_page_alloc>
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	79 15                	jns    8008ec <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8008d7:	50                   	push   %eax
  8008d8:	68 6e 25 80 00       	push   $0x80256e
  8008dd:	68 0d 01 00 00       	push   $0x10d
  8008e2:	68 c5 24 80 00       	push   $0x8024c5
  8008e7:	e8 59 0d 00 00       	call   801645 <_panic>
	}	
	mtx->locked = 0;
  8008ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8008f2:	8b 43 04             	mov    0x4(%ebx),%eax
  8008f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8008fb:	8b 43 04             	mov    0x4(%ebx),%eax
  8008fe:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800905:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80090c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  800917:	e8 1f f8 ff ff       	call   80013b <sys_getenvid>
  80091c:	83 ec 08             	sub    $0x8,%esp
  80091f:	ff 75 08             	pushl  0x8(%ebp)
  800922:	50                   	push   %eax
  800923:	e8 d6 f8 ff ff       	call   8001fe <sys_page_unmap>
	if (r < 0) {
  800928:	83 c4 10             	add    $0x10,%esp
  80092b:	85 c0                	test   %eax,%eax
  80092d:	79 15                	jns    800944 <mutex_destroy+0x33>
		panic("%e\n", r);
  80092f:	50                   	push   %eax
  800930:	68 83 25 80 00       	push   $0x802583
  800935:	68 1a 01 00 00       	push   $0x11a
  80093a:	68 c5 24 80 00       	push   $0x8024c5
  80093f:	e8 01 0d 00 00       	call   801645 <_panic>
	}
}
  800944:	c9                   	leave  
  800945:	c3                   	ret    

00800946 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	05 00 00 00 30       	add    $0x30000000,%eax
  800951:	c1 e8 0c             	shr    $0xc,%eax
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	05 00 00 00 30       	add    $0x30000000,%eax
  800961:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800966:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800973:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800978:	89 c2                	mov    %eax,%edx
  80097a:	c1 ea 16             	shr    $0x16,%edx
  80097d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800984:	f6 c2 01             	test   $0x1,%dl
  800987:	74 11                	je     80099a <fd_alloc+0x2d>
  800989:	89 c2                	mov    %eax,%edx
  80098b:	c1 ea 0c             	shr    $0xc,%edx
  80098e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800995:	f6 c2 01             	test   $0x1,%dl
  800998:	75 09                	jne    8009a3 <fd_alloc+0x36>
			*fd_store = fd;
  80099a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a1:	eb 17                	jmp    8009ba <fd_alloc+0x4d>
  8009a3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8009a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8009ad:	75 c9                	jne    800978 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8009af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8009b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8009c2:	83 f8 1f             	cmp    $0x1f,%eax
  8009c5:	77 36                	ja     8009fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8009c7:	c1 e0 0c             	shl    $0xc,%eax
  8009ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8009cf:	89 c2                	mov    %eax,%edx
  8009d1:	c1 ea 16             	shr    $0x16,%edx
  8009d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8009db:	f6 c2 01             	test   $0x1,%dl
  8009de:	74 24                	je     800a04 <fd_lookup+0x48>
  8009e0:	89 c2                	mov    %eax,%edx
  8009e2:	c1 ea 0c             	shr    $0xc,%edx
  8009e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009ec:	f6 c2 01             	test   $0x1,%dl
  8009ef:	74 1a                	je     800a0b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fb:	eb 13                	jmp    800a10 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8009fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a02:	eb 0c                	jmp    800a10 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a09:	eb 05                	jmp    800a10 <fd_lookup+0x54>
  800a0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1b:	ba 90 26 80 00       	mov    $0x802690,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800a20:	eb 13                	jmp    800a35 <dev_lookup+0x23>
  800a22:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800a25:	39 08                	cmp    %ecx,(%eax)
  800a27:	75 0c                	jne    800a35 <dev_lookup+0x23>
			*dev = devtab[i];
  800a29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	eb 31                	jmp    800a66 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800a35:	8b 02                	mov    (%edx),%eax
  800a37:	85 c0                	test   %eax,%eax
  800a39:	75 e7                	jne    800a22 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800a3b:	a1 04 40 80 00       	mov    0x804004,%eax
  800a40:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a46:	83 ec 04             	sub    $0x4,%esp
  800a49:	51                   	push   %ecx
  800a4a:	50                   	push   %eax
  800a4b:	68 14 26 80 00       	push   $0x802614
  800a50:	e8 c9 0c 00 00       	call   80171e <cprintf>
	*dev = 0;
  800a55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a5e:	83 c4 10             	add    $0x10,%esp
  800a61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	83 ec 10             	sub    $0x10,%esp
  800a70:	8b 75 08             	mov    0x8(%ebp),%esi
  800a73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a79:	50                   	push   %eax
  800a7a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a80:	c1 e8 0c             	shr    $0xc,%eax
  800a83:	50                   	push   %eax
  800a84:	e8 33 ff ff ff       	call   8009bc <fd_lookup>
  800a89:	83 c4 08             	add    $0x8,%esp
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	78 05                	js     800a95 <fd_close+0x2d>
	    || fd != fd2)
  800a90:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a93:	74 0c                	je     800aa1 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a95:	84 db                	test   %bl,%bl
  800a97:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9c:	0f 44 c2             	cmove  %edx,%eax
  800a9f:	eb 41                	jmp    800ae2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800aa1:	83 ec 08             	sub    $0x8,%esp
  800aa4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aa7:	50                   	push   %eax
  800aa8:	ff 36                	pushl  (%esi)
  800aaa:	e8 63 ff ff ff       	call   800a12 <dev_lookup>
  800aaf:	89 c3                	mov    %eax,%ebx
  800ab1:	83 c4 10             	add    $0x10,%esp
  800ab4:	85 c0                	test   %eax,%eax
  800ab6:	78 1a                	js     800ad2 <fd_close+0x6a>
		if (dev->dev_close)
  800ab8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800abb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800abe:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	74 0b                	je     800ad2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ac7:	83 ec 0c             	sub    $0xc,%esp
  800aca:	56                   	push   %esi
  800acb:	ff d0                	call   *%eax
  800acd:	89 c3                	mov    %eax,%ebx
  800acf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ad2:	83 ec 08             	sub    $0x8,%esp
  800ad5:	56                   	push   %esi
  800ad6:	6a 00                	push   $0x0
  800ad8:	e8 21 f7 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	89 d8                	mov    %ebx,%eax
}
  800ae2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800aef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af2:	50                   	push   %eax
  800af3:	ff 75 08             	pushl  0x8(%ebp)
  800af6:	e8 c1 fe ff ff       	call   8009bc <fd_lookup>
  800afb:	83 c4 08             	add    $0x8,%esp
  800afe:	85 c0                	test   %eax,%eax
  800b00:	78 10                	js     800b12 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800b02:	83 ec 08             	sub    $0x8,%esp
  800b05:	6a 01                	push   $0x1
  800b07:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0a:	e8 59 ff ff ff       	call   800a68 <fd_close>
  800b0f:	83 c4 10             	add    $0x10,%esp
}
  800b12:	c9                   	leave  
  800b13:	c3                   	ret    

00800b14 <close_all>:

void
close_all(void)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	53                   	push   %ebx
  800b18:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800b1b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800b20:	83 ec 0c             	sub    $0xc,%esp
  800b23:	53                   	push   %ebx
  800b24:	e8 c0 ff ff ff       	call   800ae9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b29:	83 c3 01             	add    $0x1,%ebx
  800b2c:	83 c4 10             	add    $0x10,%esp
  800b2f:	83 fb 20             	cmp    $0x20,%ebx
  800b32:	75 ec                	jne    800b20 <close_all+0xc>
		close(i);
}
  800b34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b37:	c9                   	leave  
  800b38:	c3                   	ret    

00800b39 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 2c             	sub    $0x2c,%esp
  800b42:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b45:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b48:	50                   	push   %eax
  800b49:	ff 75 08             	pushl  0x8(%ebp)
  800b4c:	e8 6b fe ff ff       	call   8009bc <fd_lookup>
  800b51:	83 c4 08             	add    $0x8,%esp
  800b54:	85 c0                	test   %eax,%eax
  800b56:	0f 88 c1 00 00 00    	js     800c1d <dup+0xe4>
		return r;
	close(newfdnum);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	56                   	push   %esi
  800b60:	e8 84 ff ff ff       	call   800ae9 <close>

	newfd = INDEX2FD(newfdnum);
  800b65:	89 f3                	mov    %esi,%ebx
  800b67:	c1 e3 0c             	shl    $0xc,%ebx
  800b6a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b70:	83 c4 04             	add    $0x4,%esp
  800b73:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b76:	e8 db fd ff ff       	call   800956 <fd2data>
  800b7b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b7d:	89 1c 24             	mov    %ebx,(%esp)
  800b80:	e8 d1 fd ff ff       	call   800956 <fd2data>
  800b85:	83 c4 10             	add    $0x10,%esp
  800b88:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b8b:	89 f8                	mov    %edi,%eax
  800b8d:	c1 e8 16             	shr    $0x16,%eax
  800b90:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b97:	a8 01                	test   $0x1,%al
  800b99:	74 37                	je     800bd2 <dup+0x99>
  800b9b:	89 f8                	mov    %edi,%eax
  800b9d:	c1 e8 0c             	shr    $0xc,%eax
  800ba0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ba7:	f6 c2 01             	test   $0x1,%dl
  800baa:	74 26                	je     800bd2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800bac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	25 07 0e 00 00       	and    $0xe07,%eax
  800bbb:	50                   	push   %eax
  800bbc:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bbf:	6a 00                	push   $0x0
  800bc1:	57                   	push   %edi
  800bc2:	6a 00                	push   $0x0
  800bc4:	e8 f3 f5 ff ff       	call   8001bc <sys_page_map>
  800bc9:	89 c7                	mov    %eax,%edi
  800bcb:	83 c4 20             	add    $0x20,%esp
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	78 2e                	js     800c00 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bd2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800bd5:	89 d0                	mov    %edx,%eax
  800bd7:	c1 e8 0c             	shr    $0xc,%eax
  800bda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	25 07 0e 00 00       	and    $0xe07,%eax
  800be9:	50                   	push   %eax
  800bea:	53                   	push   %ebx
  800beb:	6a 00                	push   $0x0
  800bed:	52                   	push   %edx
  800bee:	6a 00                	push   $0x0
  800bf0:	e8 c7 f5 ff ff       	call   8001bc <sys_page_map>
  800bf5:	89 c7                	mov    %eax,%edi
  800bf7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800bfa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bfc:	85 ff                	test   %edi,%edi
  800bfe:	79 1d                	jns    800c1d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c00:	83 ec 08             	sub    $0x8,%esp
  800c03:	53                   	push   %ebx
  800c04:	6a 00                	push   $0x0
  800c06:	e8 f3 f5 ff ff       	call   8001fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c0b:	83 c4 08             	add    $0x8,%esp
  800c0e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c11:	6a 00                	push   $0x0
  800c13:	e8 e6 f5 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800c18:	83 c4 10             	add    $0x10,%esp
  800c1b:	89 f8                	mov    %edi,%eax
}
  800c1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	53                   	push   %ebx
  800c29:	83 ec 14             	sub    $0x14,%esp
  800c2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c2f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c32:	50                   	push   %eax
  800c33:	53                   	push   %ebx
  800c34:	e8 83 fd ff ff       	call   8009bc <fd_lookup>
  800c39:	83 c4 08             	add    $0x8,%esp
  800c3c:	89 c2                	mov    %eax,%edx
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	78 70                	js     800cb2 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c42:	83 ec 08             	sub    $0x8,%esp
  800c45:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c48:	50                   	push   %eax
  800c49:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c4c:	ff 30                	pushl  (%eax)
  800c4e:	e8 bf fd ff ff       	call   800a12 <dev_lookup>
  800c53:	83 c4 10             	add    $0x10,%esp
  800c56:	85 c0                	test   %eax,%eax
  800c58:	78 4f                	js     800ca9 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c5a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c5d:	8b 42 08             	mov    0x8(%edx),%eax
  800c60:	83 e0 03             	and    $0x3,%eax
  800c63:	83 f8 01             	cmp    $0x1,%eax
  800c66:	75 24                	jne    800c8c <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c68:	a1 04 40 80 00       	mov    0x804004,%eax
  800c6d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800c73:	83 ec 04             	sub    $0x4,%esp
  800c76:	53                   	push   %ebx
  800c77:	50                   	push   %eax
  800c78:	68 55 26 80 00       	push   $0x802655
  800c7d:	e8 9c 0a 00 00       	call   80171e <cprintf>
		return -E_INVAL;
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c8a:	eb 26                	jmp    800cb2 <read+0x8d>
	}
	if (!dev->dev_read)
  800c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8f:	8b 40 08             	mov    0x8(%eax),%eax
  800c92:	85 c0                	test   %eax,%eax
  800c94:	74 17                	je     800cad <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c96:	83 ec 04             	sub    $0x4,%esp
  800c99:	ff 75 10             	pushl  0x10(%ebp)
  800c9c:	ff 75 0c             	pushl  0xc(%ebp)
  800c9f:	52                   	push   %edx
  800ca0:	ff d0                	call   *%eax
  800ca2:	89 c2                	mov    %eax,%edx
  800ca4:	83 c4 10             	add    $0x10,%esp
  800ca7:	eb 09                	jmp    800cb2 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	eb 05                	jmp    800cb2 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800cad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800cb2:	89 d0                	mov    %edx,%eax
  800cb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cb7:	c9                   	leave  
  800cb8:	c3                   	ret    

00800cb9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
  800cbf:	83 ec 0c             	sub    $0xc,%esp
  800cc2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccd:	eb 21                	jmp    800cf0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800ccf:	83 ec 04             	sub    $0x4,%esp
  800cd2:	89 f0                	mov    %esi,%eax
  800cd4:	29 d8                	sub    %ebx,%eax
  800cd6:	50                   	push   %eax
  800cd7:	89 d8                	mov    %ebx,%eax
  800cd9:	03 45 0c             	add    0xc(%ebp),%eax
  800cdc:	50                   	push   %eax
  800cdd:	57                   	push   %edi
  800cde:	e8 42 ff ff ff       	call   800c25 <read>
		if (m < 0)
  800ce3:	83 c4 10             	add    $0x10,%esp
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	78 10                	js     800cfa <readn+0x41>
			return m;
		if (m == 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	74 0a                	je     800cf8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cee:	01 c3                	add    %eax,%ebx
  800cf0:	39 f3                	cmp    %esi,%ebx
  800cf2:	72 db                	jb     800ccf <readn+0x16>
  800cf4:	89 d8                	mov    %ebx,%eax
  800cf6:	eb 02                	jmp    800cfa <readn+0x41>
  800cf8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	53                   	push   %ebx
  800d06:	83 ec 14             	sub    $0x14,%esp
  800d09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d0f:	50                   	push   %eax
  800d10:	53                   	push   %ebx
  800d11:	e8 a6 fc ff ff       	call   8009bc <fd_lookup>
  800d16:	83 c4 08             	add    $0x8,%esp
  800d19:	89 c2                	mov    %eax,%edx
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	78 6b                	js     800d8a <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d1f:	83 ec 08             	sub    $0x8,%esp
  800d22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d25:	50                   	push   %eax
  800d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d29:	ff 30                	pushl  (%eax)
  800d2b:	e8 e2 fc ff ff       	call   800a12 <dev_lookup>
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	85 c0                	test   %eax,%eax
  800d35:	78 4a                	js     800d81 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d3a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d3e:	75 24                	jne    800d64 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d40:	a1 04 40 80 00       	mov    0x804004,%eax
  800d45:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800d4b:	83 ec 04             	sub    $0x4,%esp
  800d4e:	53                   	push   %ebx
  800d4f:	50                   	push   %eax
  800d50:	68 71 26 80 00       	push   $0x802671
  800d55:	e8 c4 09 00 00       	call   80171e <cprintf>
		return -E_INVAL;
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d62:	eb 26                	jmp    800d8a <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d67:	8b 52 0c             	mov    0xc(%edx),%edx
  800d6a:	85 d2                	test   %edx,%edx
  800d6c:	74 17                	je     800d85 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d6e:	83 ec 04             	sub    $0x4,%esp
  800d71:	ff 75 10             	pushl  0x10(%ebp)
  800d74:	ff 75 0c             	pushl  0xc(%ebp)
  800d77:	50                   	push   %eax
  800d78:	ff d2                	call   *%edx
  800d7a:	89 c2                	mov    %eax,%edx
  800d7c:	83 c4 10             	add    $0x10,%esp
  800d7f:	eb 09                	jmp    800d8a <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d81:	89 c2                	mov    %eax,%edx
  800d83:	eb 05                	jmp    800d8a <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d85:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d8a:	89 d0                	mov    %edx,%eax
  800d8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d97:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d9a:	50                   	push   %eax
  800d9b:	ff 75 08             	pushl  0x8(%ebp)
  800d9e:	e8 19 fc ff ff       	call   8009bc <fd_lookup>
  800da3:	83 c4 08             	add    $0x8,%esp
  800da6:	85 c0                	test   %eax,%eax
  800da8:	78 0e                	js     800db8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800daa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800db3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db8:	c9                   	leave  
  800db9:	c3                   	ret    

00800dba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	53                   	push   %ebx
  800dbe:	83 ec 14             	sub    $0x14,%esp
  800dc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dc4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc7:	50                   	push   %eax
  800dc8:	53                   	push   %ebx
  800dc9:	e8 ee fb ff ff       	call   8009bc <fd_lookup>
  800dce:	83 c4 08             	add    $0x8,%esp
  800dd1:	89 c2                	mov    %eax,%edx
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	78 68                	js     800e3f <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dd7:	83 ec 08             	sub    $0x8,%esp
  800dda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ddd:	50                   	push   %eax
  800dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de1:	ff 30                	pushl  (%eax)
  800de3:	e8 2a fc ff ff       	call   800a12 <dev_lookup>
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	78 47                	js     800e36 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800def:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800df6:	75 24                	jne    800e1c <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800df8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800dfd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e03:	83 ec 04             	sub    $0x4,%esp
  800e06:	53                   	push   %ebx
  800e07:	50                   	push   %eax
  800e08:	68 34 26 80 00       	push   $0x802634
  800e0d:	e8 0c 09 00 00       	call   80171e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800e12:	83 c4 10             	add    $0x10,%esp
  800e15:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e1a:	eb 23                	jmp    800e3f <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800e1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e1f:	8b 52 18             	mov    0x18(%edx),%edx
  800e22:	85 d2                	test   %edx,%edx
  800e24:	74 14                	je     800e3a <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800e26:	83 ec 08             	sub    $0x8,%esp
  800e29:	ff 75 0c             	pushl  0xc(%ebp)
  800e2c:	50                   	push   %eax
  800e2d:	ff d2                	call   *%edx
  800e2f:	89 c2                	mov    %eax,%edx
  800e31:	83 c4 10             	add    $0x10,%esp
  800e34:	eb 09                	jmp    800e3f <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	eb 05                	jmp    800e3f <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800e3a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800e3f:	89 d0                	mov    %edx,%eax
  800e41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e44:	c9                   	leave  
  800e45:	c3                   	ret    

00800e46 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 14             	sub    $0x14,%esp
  800e4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e53:	50                   	push   %eax
  800e54:	ff 75 08             	pushl  0x8(%ebp)
  800e57:	e8 60 fb ff ff       	call   8009bc <fd_lookup>
  800e5c:	83 c4 08             	add    $0x8,%esp
  800e5f:	89 c2                	mov    %eax,%edx
  800e61:	85 c0                	test   %eax,%eax
  800e63:	78 58                	js     800ebd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e6b:	50                   	push   %eax
  800e6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6f:	ff 30                	pushl  (%eax)
  800e71:	e8 9c fb ff ff       	call   800a12 <dev_lookup>
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	78 37                	js     800eb4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e80:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e84:	74 32                	je     800eb8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e86:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e89:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e90:	00 00 00 
	stat->st_isdir = 0;
  800e93:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e9a:	00 00 00 
	stat->st_dev = dev;
  800e9d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ea3:	83 ec 08             	sub    $0x8,%esp
  800ea6:	53                   	push   %ebx
  800ea7:	ff 75 f0             	pushl  -0x10(%ebp)
  800eaa:	ff 50 14             	call   *0x14(%eax)
  800ead:	89 c2                	mov    %eax,%edx
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	eb 09                	jmp    800ebd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800eb4:	89 c2                	mov    %eax,%edx
  800eb6:	eb 05                	jmp    800ebd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800eb8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800ebd:	89 d0                	mov    %edx,%eax
  800ebf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ec9:	83 ec 08             	sub    $0x8,%esp
  800ecc:	6a 00                	push   $0x0
  800ece:	ff 75 08             	pushl  0x8(%ebp)
  800ed1:	e8 e3 01 00 00       	call   8010b9 <open>
  800ed6:	89 c3                	mov    %eax,%ebx
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	85 c0                	test   %eax,%eax
  800edd:	78 1b                	js     800efa <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800edf:	83 ec 08             	sub    $0x8,%esp
  800ee2:	ff 75 0c             	pushl  0xc(%ebp)
  800ee5:	50                   	push   %eax
  800ee6:	e8 5b ff ff ff       	call   800e46 <fstat>
  800eeb:	89 c6                	mov    %eax,%esi
	close(fd);
  800eed:	89 1c 24             	mov    %ebx,(%esp)
  800ef0:	e8 f4 fb ff ff       	call   800ae9 <close>
	return r;
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	89 f0                	mov    %esi,%eax
}
  800efa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
  800f06:	89 c6                	mov    %eax,%esi
  800f08:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800f0a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800f11:	75 12                	jne    800f25 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800f13:	83 ec 0c             	sub    $0xc,%esp
  800f16:	6a 01                	push   $0x1
  800f18:	e8 39 12 00 00       	call   802156 <ipc_find_env>
  800f1d:	a3 00 40 80 00       	mov    %eax,0x804000
  800f22:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800f25:	6a 07                	push   $0x7
  800f27:	68 00 50 80 00       	push   $0x805000
  800f2c:	56                   	push   %esi
  800f2d:	ff 35 00 40 80 00    	pushl  0x804000
  800f33:	e8 bc 11 00 00       	call   8020f4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800f38:	83 c4 0c             	add    $0xc,%esp
  800f3b:	6a 00                	push   $0x0
  800f3d:	53                   	push   %ebx
  800f3e:	6a 00                	push   $0x0
  800f40:	e8 34 11 00 00       	call   802079 <ipc_recv>
}
  800f45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f52:	8b 45 08             	mov    0x8(%ebp),%eax
  800f55:	8b 40 0c             	mov    0xc(%eax),%eax
  800f58:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f60:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f65:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800f6f:	e8 8d ff ff ff       	call   800f01 <fsipc>
}
  800f74:	c9                   	leave  
  800f75:	c3                   	ret    

00800f76 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7f:	8b 40 0c             	mov    0xc(%eax),%eax
  800f82:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f87:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8c:	b8 06 00 00 00       	mov    $0x6,%eax
  800f91:	e8 6b ff ff ff       	call   800f01 <fsipc>
}
  800f96:	c9                   	leave  
  800f97:	c3                   	ret    

00800f98 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 04             	sub    $0x4,%esp
  800f9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa5:	8b 40 0c             	mov    0xc(%eax),%eax
  800fa8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800fad:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800fb7:	e8 45 ff ff ff       	call   800f01 <fsipc>
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 2c                	js     800fec <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800fc0:	83 ec 08             	sub    $0x8,%esp
  800fc3:	68 00 50 80 00       	push   $0x805000
  800fc8:	53                   	push   %ebx
  800fc9:	e8 d5 0c 00 00       	call   801ca3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800fce:	a1 80 50 80 00       	mov    0x805080,%eax
  800fd3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800fd9:	a1 84 50 80 00       	mov    0x805084,%eax
  800fde:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ffa:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffd:	8b 52 0c             	mov    0xc(%edx),%edx
  801000:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801006:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80100b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801010:	0f 47 c2             	cmova  %edx,%eax
  801013:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801018:	50                   	push   %eax
  801019:	ff 75 0c             	pushl  0xc(%ebp)
  80101c:	68 08 50 80 00       	push   $0x805008
  801021:	e8 0f 0e 00 00       	call   801e35 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801026:	ba 00 00 00 00       	mov    $0x0,%edx
  80102b:	b8 04 00 00 00       	mov    $0x4,%eax
  801030:	e8 cc fe ff ff       	call   800f01 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
  80103c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80103f:	8b 45 08             	mov    0x8(%ebp),%eax
  801042:	8b 40 0c             	mov    0xc(%eax),%eax
  801045:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80104a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801050:	ba 00 00 00 00       	mov    $0x0,%edx
  801055:	b8 03 00 00 00       	mov    $0x3,%eax
  80105a:	e8 a2 fe ff ff       	call   800f01 <fsipc>
  80105f:	89 c3                	mov    %eax,%ebx
  801061:	85 c0                	test   %eax,%eax
  801063:	78 4b                	js     8010b0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801065:	39 c6                	cmp    %eax,%esi
  801067:	73 16                	jae    80107f <devfile_read+0x48>
  801069:	68 a0 26 80 00       	push   $0x8026a0
  80106e:	68 a7 26 80 00       	push   $0x8026a7
  801073:	6a 7c                	push   $0x7c
  801075:	68 bc 26 80 00       	push   $0x8026bc
  80107a:	e8 c6 05 00 00       	call   801645 <_panic>
	assert(r <= PGSIZE);
  80107f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801084:	7e 16                	jle    80109c <devfile_read+0x65>
  801086:	68 c7 26 80 00       	push   $0x8026c7
  80108b:	68 a7 26 80 00       	push   $0x8026a7
  801090:	6a 7d                	push   $0x7d
  801092:	68 bc 26 80 00       	push   $0x8026bc
  801097:	e8 a9 05 00 00       	call   801645 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80109c:	83 ec 04             	sub    $0x4,%esp
  80109f:	50                   	push   %eax
  8010a0:	68 00 50 80 00       	push   $0x805000
  8010a5:	ff 75 0c             	pushl  0xc(%ebp)
  8010a8:	e8 88 0d 00 00       	call   801e35 <memmove>
	return r;
  8010ad:	83 c4 10             	add    $0x10,%esp
}
  8010b0:	89 d8                	mov    %ebx,%eax
  8010b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5d                   	pop    %ebp
  8010b8:	c3                   	ret    

008010b9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 20             	sub    $0x20,%esp
  8010c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8010c3:	53                   	push   %ebx
  8010c4:	e8 a1 0b 00 00       	call   801c6a <strlen>
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010d1:	7f 67                	jg     80113a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010d3:	83 ec 0c             	sub    $0xc,%esp
  8010d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	e8 8e f8 ff ff       	call   80096d <fd_alloc>
  8010df:	83 c4 10             	add    $0x10,%esp
		return r;
  8010e2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	78 57                	js     80113f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8010e8:	83 ec 08             	sub    $0x8,%esp
  8010eb:	53                   	push   %ebx
  8010ec:	68 00 50 80 00       	push   $0x805000
  8010f1:	e8 ad 0b 00 00       	call   801ca3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8010f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8010fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801101:	b8 01 00 00 00       	mov    $0x1,%eax
  801106:	e8 f6 fd ff ff       	call   800f01 <fsipc>
  80110b:	89 c3                	mov    %eax,%ebx
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	85 c0                	test   %eax,%eax
  801112:	79 14                	jns    801128 <open+0x6f>
		fd_close(fd, 0);
  801114:	83 ec 08             	sub    $0x8,%esp
  801117:	6a 00                	push   $0x0
  801119:	ff 75 f4             	pushl  -0xc(%ebp)
  80111c:	e8 47 f9 ff ff       	call   800a68 <fd_close>
		return r;
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	89 da                	mov    %ebx,%edx
  801126:	eb 17                	jmp    80113f <open+0x86>
	}

	return fd2num(fd);
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	ff 75 f4             	pushl  -0xc(%ebp)
  80112e:	e8 13 f8 ff ff       	call   800946 <fd2num>
  801133:	89 c2                	mov    %eax,%edx
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	eb 05                	jmp    80113f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80113a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80113f:	89 d0                	mov    %edx,%eax
  801141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80114c:	ba 00 00 00 00       	mov    $0x0,%edx
  801151:	b8 08 00 00 00       	mov    $0x8,%eax
  801156:	e8 a6 fd ff ff       	call   800f01 <fsipc>
}
  80115b:	c9                   	leave  
  80115c:	c3                   	ret    

0080115d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
  801162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	ff 75 08             	pushl  0x8(%ebp)
  80116b:	e8 e6 f7 ff ff       	call   800956 <fd2data>
  801170:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801172:	83 c4 08             	add    $0x8,%esp
  801175:	68 d3 26 80 00       	push   $0x8026d3
  80117a:	53                   	push   %ebx
  80117b:	e8 23 0b 00 00       	call   801ca3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801180:	8b 46 04             	mov    0x4(%esi),%eax
  801183:	2b 06                	sub    (%esi),%eax
  801185:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80118b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801192:	00 00 00 
	stat->st_dev = &devpipe;
  801195:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80119c:	30 80 00 
	return 0;
}
  80119f:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011a7:	5b                   	pop    %ebx
  8011a8:	5e                   	pop    %esi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	53                   	push   %ebx
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8011b5:	53                   	push   %ebx
  8011b6:	6a 00                	push   $0x0
  8011b8:	e8 41 f0 ff ff       	call   8001fe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8011bd:	89 1c 24             	mov    %ebx,(%esp)
  8011c0:	e8 91 f7 ff ff       	call   800956 <fd2data>
  8011c5:	83 c4 08             	add    $0x8,%esp
  8011c8:	50                   	push   %eax
  8011c9:	6a 00                	push   $0x0
  8011cb:	e8 2e f0 ff ff       	call   8001fe <sys_page_unmap>
}
  8011d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    

008011d5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	57                   	push   %edi
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 1c             	sub    $0x1c,%esp
  8011de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011e1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8011e3:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e8:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8011ee:	83 ec 0c             	sub    $0xc,%esp
  8011f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f4:	e8 a2 0f 00 00       	call   80219b <pageref>
  8011f9:	89 c3                	mov    %eax,%ebx
  8011fb:	89 3c 24             	mov    %edi,(%esp)
  8011fe:	e8 98 0f 00 00       	call   80219b <pageref>
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	39 c3                	cmp    %eax,%ebx
  801208:	0f 94 c1             	sete   %cl
  80120b:	0f b6 c9             	movzbl %cl,%ecx
  80120e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801211:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801217:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  80121d:	39 ce                	cmp    %ecx,%esi
  80121f:	74 1e                	je     80123f <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801221:	39 c3                	cmp    %eax,%ebx
  801223:	75 be                	jne    8011e3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801225:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80122b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122e:	50                   	push   %eax
  80122f:	56                   	push   %esi
  801230:	68 da 26 80 00       	push   $0x8026da
  801235:	e8 e4 04 00 00       	call   80171e <cprintf>
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	eb a4                	jmp    8011e3 <_pipeisclosed+0xe>
	}
}
  80123f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	57                   	push   %edi
  80124e:	56                   	push   %esi
  80124f:	53                   	push   %ebx
  801250:	83 ec 28             	sub    $0x28,%esp
  801253:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801256:	56                   	push   %esi
  801257:	e8 fa f6 ff ff       	call   800956 <fd2data>
  80125c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	bf 00 00 00 00       	mov    $0x0,%edi
  801266:	eb 4b                	jmp    8012b3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801268:	89 da                	mov    %ebx,%edx
  80126a:	89 f0                	mov    %esi,%eax
  80126c:	e8 64 ff ff ff       	call   8011d5 <_pipeisclosed>
  801271:	85 c0                	test   %eax,%eax
  801273:	75 48                	jne    8012bd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801275:	e8 e0 ee ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80127a:	8b 43 04             	mov    0x4(%ebx),%eax
  80127d:	8b 0b                	mov    (%ebx),%ecx
  80127f:	8d 51 20             	lea    0x20(%ecx),%edx
  801282:	39 d0                	cmp    %edx,%eax
  801284:	73 e2                	jae    801268 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801289:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80128d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801290:	89 c2                	mov    %eax,%edx
  801292:	c1 fa 1f             	sar    $0x1f,%edx
  801295:	89 d1                	mov    %edx,%ecx
  801297:	c1 e9 1b             	shr    $0x1b,%ecx
  80129a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80129d:	83 e2 1f             	and    $0x1f,%edx
  8012a0:	29 ca                	sub    %ecx,%edx
  8012a2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8012a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8012aa:	83 c0 01             	add    $0x1,%eax
  8012ad:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012b0:	83 c7 01             	add    $0x1,%edi
  8012b3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8012b6:	75 c2                	jne    80127a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8012b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8012bb:	eb 05                	jmp    8012c2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8012c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c5:	5b                   	pop    %ebx
  8012c6:	5e                   	pop    %esi
  8012c7:	5f                   	pop    %edi
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	57                   	push   %edi
  8012ce:	56                   	push   %esi
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 18             	sub    $0x18,%esp
  8012d3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8012d6:	57                   	push   %edi
  8012d7:	e8 7a f6 ff ff       	call   800956 <fd2data>
  8012dc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e6:	eb 3d                	jmp    801325 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8012e8:	85 db                	test   %ebx,%ebx
  8012ea:	74 04                	je     8012f0 <devpipe_read+0x26>
				return i;
  8012ec:	89 d8                	mov    %ebx,%eax
  8012ee:	eb 44                	jmp    801334 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8012f0:	89 f2                	mov    %esi,%edx
  8012f2:	89 f8                	mov    %edi,%eax
  8012f4:	e8 dc fe ff ff       	call   8011d5 <_pipeisclosed>
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	75 32                	jne    80132f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8012fd:	e8 58 ee ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801302:	8b 06                	mov    (%esi),%eax
  801304:	3b 46 04             	cmp    0x4(%esi),%eax
  801307:	74 df                	je     8012e8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801309:	99                   	cltd   
  80130a:	c1 ea 1b             	shr    $0x1b,%edx
  80130d:	01 d0                	add    %edx,%eax
  80130f:	83 e0 1f             	and    $0x1f,%eax
  801312:	29 d0                	sub    %edx,%eax
  801314:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801319:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80131f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801322:	83 c3 01             	add    $0x1,%ebx
  801325:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801328:	75 d8                	jne    801302 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80132a:	8b 45 10             	mov    0x10(%ebp),%eax
  80132d:	eb 05                	jmp    801334 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80132f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801334:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801337:	5b                   	pop    %ebx
  801338:	5e                   	pop    %esi
  801339:	5f                   	pop    %edi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    

0080133c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	56                   	push   %esi
  801340:	53                   	push   %ebx
  801341:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	e8 20 f6 ff ff       	call   80096d <fd_alloc>
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	89 c2                	mov    %eax,%edx
  801352:	85 c0                	test   %eax,%eax
  801354:	0f 88 2c 01 00 00    	js     801486 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80135a:	83 ec 04             	sub    $0x4,%esp
  80135d:	68 07 04 00 00       	push   $0x407
  801362:	ff 75 f4             	pushl  -0xc(%ebp)
  801365:	6a 00                	push   $0x0
  801367:	e8 0d ee ff ff       	call   800179 <sys_page_alloc>
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	89 c2                	mov    %eax,%edx
  801371:	85 c0                	test   %eax,%eax
  801373:	0f 88 0d 01 00 00    	js     801486 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801379:	83 ec 0c             	sub    $0xc,%esp
  80137c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	e8 e8 f5 ff ff       	call   80096d <fd_alloc>
  801385:	89 c3                	mov    %eax,%ebx
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	85 c0                	test   %eax,%eax
  80138c:	0f 88 e2 00 00 00    	js     801474 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801392:	83 ec 04             	sub    $0x4,%esp
  801395:	68 07 04 00 00       	push   $0x407
  80139a:	ff 75 f0             	pushl  -0x10(%ebp)
  80139d:	6a 00                	push   $0x0
  80139f:	e8 d5 ed ff ff       	call   800179 <sys_page_alloc>
  8013a4:	89 c3                	mov    %eax,%ebx
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	0f 88 c3 00 00 00    	js     801474 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8013b1:	83 ec 0c             	sub    $0xc,%esp
  8013b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b7:	e8 9a f5 ff ff       	call   800956 <fd2data>
  8013bc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013be:	83 c4 0c             	add    $0xc,%esp
  8013c1:	68 07 04 00 00       	push   $0x407
  8013c6:	50                   	push   %eax
  8013c7:	6a 00                	push   $0x0
  8013c9:	e8 ab ed ff ff       	call   800179 <sys_page_alloc>
  8013ce:	89 c3                	mov    %eax,%ebx
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	0f 88 89 00 00 00    	js     801464 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013db:	83 ec 0c             	sub    $0xc,%esp
  8013de:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e1:	e8 70 f5 ff ff       	call   800956 <fd2data>
  8013e6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8013ed:	50                   	push   %eax
  8013ee:	6a 00                	push   $0x0
  8013f0:	56                   	push   %esi
  8013f1:	6a 00                	push   $0x0
  8013f3:	e8 c4 ed ff ff       	call   8001bc <sys_page_map>
  8013f8:	89 c3                	mov    %eax,%ebx
  8013fa:	83 c4 20             	add    $0x20,%esp
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 55                	js     801456 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801401:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801407:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80140c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801416:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80141c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801421:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801424:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80142b:	83 ec 0c             	sub    $0xc,%esp
  80142e:	ff 75 f4             	pushl  -0xc(%ebp)
  801431:	e8 10 f5 ff ff       	call   800946 <fd2num>
  801436:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801439:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80143b:	83 c4 04             	add    $0x4,%esp
  80143e:	ff 75 f0             	pushl  -0x10(%ebp)
  801441:	e8 00 f5 ff ff       	call   800946 <fd2num>
  801446:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801449:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	ba 00 00 00 00       	mov    $0x0,%edx
  801454:	eb 30                	jmp    801486 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	56                   	push   %esi
  80145a:	6a 00                	push   $0x0
  80145c:	e8 9d ed ff ff       	call   8001fe <sys_page_unmap>
  801461:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	ff 75 f0             	pushl  -0x10(%ebp)
  80146a:	6a 00                	push   $0x0
  80146c:	e8 8d ed ff ff       	call   8001fe <sys_page_unmap>
  801471:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	ff 75 f4             	pushl  -0xc(%ebp)
  80147a:	6a 00                	push   $0x0
  80147c:	e8 7d ed ff ff       	call   8001fe <sys_page_unmap>
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801486:	89 d0                	mov    %edx,%eax
  801488:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148b:	5b                   	pop    %ebx
  80148c:	5e                   	pop    %esi
  80148d:	5d                   	pop    %ebp
  80148e:	c3                   	ret    

0080148f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801495:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	ff 75 08             	pushl  0x8(%ebp)
  80149c:	e8 1b f5 ff ff       	call   8009bc <fd_lookup>
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 18                	js     8014c0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8014a8:	83 ec 0c             	sub    $0xc,%esp
  8014ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ae:	e8 a3 f4 ff ff       	call   800956 <fd2data>
	return _pipeisclosed(fd, p);
  8014b3:	89 c2                	mov    %eax,%edx
  8014b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b8:	e8 18 fd ff ff       	call   8011d5 <_pipeisclosed>
  8014bd:	83 c4 10             	add    $0x10,%esp
}
  8014c0:	c9                   	leave  
  8014c1:	c3                   	ret    

008014c2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8014c2:	55                   	push   %ebp
  8014c3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8014c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8014d2:	68 f2 26 80 00       	push   $0x8026f2
  8014d7:	ff 75 0c             	pushl  0xc(%ebp)
  8014da:	e8 c4 07 00 00       	call   801ca3 <strcpy>
	return 0;
}
  8014df:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e4:	c9                   	leave  
  8014e5:	c3                   	ret    

008014e6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8014e6:	55                   	push   %ebp
  8014e7:	89 e5                	mov    %esp,%ebp
  8014e9:	57                   	push   %edi
  8014ea:	56                   	push   %esi
  8014eb:	53                   	push   %ebx
  8014ec:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014f2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014f7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014fd:	eb 2d                	jmp    80152c <devcons_write+0x46>
		m = n - tot;
  8014ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801502:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801504:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801507:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80150c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80150f:	83 ec 04             	sub    $0x4,%esp
  801512:	53                   	push   %ebx
  801513:	03 45 0c             	add    0xc(%ebp),%eax
  801516:	50                   	push   %eax
  801517:	57                   	push   %edi
  801518:	e8 18 09 00 00       	call   801e35 <memmove>
		sys_cputs(buf, m);
  80151d:	83 c4 08             	add    $0x8,%esp
  801520:	53                   	push   %ebx
  801521:	57                   	push   %edi
  801522:	e8 96 eb ff ff       	call   8000bd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801527:	01 de                	add    %ebx,%esi
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	89 f0                	mov    %esi,%eax
  80152e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801531:	72 cc                	jb     8014ff <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801533:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801536:	5b                   	pop    %ebx
  801537:	5e                   	pop    %esi
  801538:	5f                   	pop    %edi
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801546:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80154a:	74 2a                	je     801576 <devcons_read+0x3b>
  80154c:	eb 05                	jmp    801553 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80154e:	e8 07 ec ff ff       	call   80015a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801553:	e8 83 eb ff ff       	call   8000db <sys_cgetc>
  801558:	85 c0                	test   %eax,%eax
  80155a:	74 f2                	je     80154e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 16                	js     801576 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801560:	83 f8 04             	cmp    $0x4,%eax
  801563:	74 0c                	je     801571 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801565:	8b 55 0c             	mov    0xc(%ebp),%edx
  801568:	88 02                	mov    %al,(%edx)
	return 1;
  80156a:	b8 01 00 00 00       	mov    $0x1,%eax
  80156f:	eb 05                	jmp    801576 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801571:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80157e:	8b 45 08             	mov    0x8(%ebp),%eax
  801581:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801584:	6a 01                	push   $0x1
  801586:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	e8 2e eb ff ff       	call   8000bd <sys_cputs>
}
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <getchar>:

int
getchar(void)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80159a:	6a 01                	push   $0x1
  80159c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	6a 00                	push   $0x0
  8015a2:	e8 7e f6 ff ff       	call   800c25 <read>
	if (r < 0)
  8015a7:	83 c4 10             	add    $0x10,%esp
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 0f                	js     8015bd <getchar+0x29>
		return r;
	if (r < 1)
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	7e 06                	jle    8015b8 <getchar+0x24>
		return -E_EOF;
	return c;
  8015b2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8015b6:	eb 05                	jmp    8015bd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8015b8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	ff 75 08             	pushl  0x8(%ebp)
  8015cc:	e8 eb f3 ff ff       	call   8009bc <fd_lookup>
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 11                	js     8015e9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015db:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015e1:	39 10                	cmp    %edx,(%eax)
  8015e3:	0f 94 c0             	sete   %al
  8015e6:	0f b6 c0             	movzbl %al,%eax
}
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <opencons>:

int
opencons(void)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f4:	50                   	push   %eax
  8015f5:	e8 73 f3 ff ff       	call   80096d <fd_alloc>
  8015fa:	83 c4 10             	add    $0x10,%esp
		return r;
  8015fd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 3e                	js     801641 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801603:	83 ec 04             	sub    $0x4,%esp
  801606:	68 07 04 00 00       	push   $0x407
  80160b:	ff 75 f4             	pushl  -0xc(%ebp)
  80160e:	6a 00                	push   $0x0
  801610:	e8 64 eb ff ff       	call   800179 <sys_page_alloc>
  801615:	83 c4 10             	add    $0x10,%esp
		return r;
  801618:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 23                	js     801641 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80161e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801624:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801627:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801633:	83 ec 0c             	sub    $0xc,%esp
  801636:	50                   	push   %eax
  801637:	e8 0a f3 ff ff       	call   800946 <fd2num>
  80163c:	89 c2                	mov    %eax,%edx
  80163e:	83 c4 10             	add    $0x10,%esp
}
  801641:	89 d0                	mov    %edx,%eax
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	56                   	push   %esi
  801649:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80164a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80164d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801653:	e8 e3 ea ff ff       	call   80013b <sys_getenvid>
  801658:	83 ec 0c             	sub    $0xc,%esp
  80165b:	ff 75 0c             	pushl  0xc(%ebp)
  80165e:	ff 75 08             	pushl  0x8(%ebp)
  801661:	56                   	push   %esi
  801662:	50                   	push   %eax
  801663:	68 00 27 80 00       	push   $0x802700
  801668:	e8 b1 00 00 00       	call   80171e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80166d:	83 c4 18             	add    $0x18,%esp
  801670:	53                   	push   %ebx
  801671:	ff 75 10             	pushl  0x10(%ebp)
  801674:	e8 54 00 00 00       	call   8016cd <vcprintf>
	cprintf("\n");
  801679:	c7 04 24 51 25 80 00 	movl   $0x802551,(%esp)
  801680:	e8 99 00 00 00       	call   80171e <cprintf>
  801685:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801688:	cc                   	int3   
  801689:	eb fd                	jmp    801688 <_panic+0x43>

0080168b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	53                   	push   %ebx
  80168f:	83 ec 04             	sub    $0x4,%esp
  801692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801695:	8b 13                	mov    (%ebx),%edx
  801697:	8d 42 01             	lea    0x1(%edx),%eax
  80169a:	89 03                	mov    %eax,(%ebx)
  80169c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8016a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8016a8:	75 1a                	jne    8016c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	68 ff 00 00 00       	push   $0xff
  8016b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8016b5:	50                   	push   %eax
  8016b6:	e8 02 ea ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  8016bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8016c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8016c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cb:	c9                   	leave  
  8016cc:	c3                   	ret    

008016cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8016d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016dd:	00 00 00 
	b.cnt = 0;
  8016e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016ea:	ff 75 0c             	pushl  0xc(%ebp)
  8016ed:	ff 75 08             	pushl  0x8(%ebp)
  8016f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8016f6:	50                   	push   %eax
  8016f7:	68 8b 16 80 00       	push   $0x80168b
  8016fc:	e8 54 01 00 00       	call   801855 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801701:	83 c4 08             	add    $0x8,%esp
  801704:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80170a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801710:	50                   	push   %eax
  801711:	e8 a7 e9 ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  801716:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80171c:	c9                   	leave  
  80171d:	c3                   	ret    

0080171e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801724:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801727:	50                   	push   %eax
  801728:	ff 75 08             	pushl  0x8(%ebp)
  80172b:	e8 9d ff ff ff       	call   8016cd <vcprintf>
	va_end(ap);

	return cnt;
}
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	57                   	push   %edi
  801736:	56                   	push   %esi
  801737:	53                   	push   %ebx
  801738:	83 ec 1c             	sub    $0x1c,%esp
  80173b:	89 c7                	mov    %eax,%edi
  80173d:	89 d6                	mov    %edx,%esi
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	8b 55 0c             	mov    0xc(%ebp),%edx
  801745:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801748:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80174b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80174e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801753:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801756:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801759:	39 d3                	cmp    %edx,%ebx
  80175b:	72 05                	jb     801762 <printnum+0x30>
  80175d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801760:	77 45                	ja     8017a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801762:	83 ec 0c             	sub    $0xc,%esp
  801765:	ff 75 18             	pushl  0x18(%ebp)
  801768:	8b 45 14             	mov    0x14(%ebp),%eax
  80176b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80176e:	53                   	push   %ebx
  80176f:	ff 75 10             	pushl  0x10(%ebp)
  801772:	83 ec 08             	sub    $0x8,%esp
  801775:	ff 75 e4             	pushl  -0x1c(%ebp)
  801778:	ff 75 e0             	pushl  -0x20(%ebp)
  80177b:	ff 75 dc             	pushl  -0x24(%ebp)
  80177e:	ff 75 d8             	pushl  -0x28(%ebp)
  801781:	e8 5a 0a 00 00       	call   8021e0 <__udivdi3>
  801786:	83 c4 18             	add    $0x18,%esp
  801789:	52                   	push   %edx
  80178a:	50                   	push   %eax
  80178b:	89 f2                	mov    %esi,%edx
  80178d:	89 f8                	mov    %edi,%eax
  80178f:	e8 9e ff ff ff       	call   801732 <printnum>
  801794:	83 c4 20             	add    $0x20,%esp
  801797:	eb 18                	jmp    8017b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	56                   	push   %esi
  80179d:	ff 75 18             	pushl  0x18(%ebp)
  8017a0:	ff d7                	call   *%edi
  8017a2:	83 c4 10             	add    $0x10,%esp
  8017a5:	eb 03                	jmp    8017aa <printnum+0x78>
  8017a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017aa:	83 eb 01             	sub    $0x1,%ebx
  8017ad:	85 db                	test   %ebx,%ebx
  8017af:	7f e8                	jg     801799 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017b1:	83 ec 08             	sub    $0x8,%esp
  8017b4:	56                   	push   %esi
  8017b5:	83 ec 04             	sub    $0x4,%esp
  8017b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8017be:	ff 75 dc             	pushl  -0x24(%ebp)
  8017c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8017c4:	e8 47 0b 00 00       	call   802310 <__umoddi3>
  8017c9:	83 c4 14             	add    $0x14,%esp
  8017cc:	0f be 80 23 27 80 00 	movsbl 0x802723(%eax),%eax
  8017d3:	50                   	push   %eax
  8017d4:	ff d7                	call   *%edi
}
  8017d6:	83 c4 10             	add    $0x10,%esp
  8017d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017dc:	5b                   	pop    %ebx
  8017dd:	5e                   	pop    %esi
  8017de:	5f                   	pop    %edi
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017e4:	83 fa 01             	cmp    $0x1,%edx
  8017e7:	7e 0e                	jle    8017f7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017e9:	8b 10                	mov    (%eax),%edx
  8017eb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017ee:	89 08                	mov    %ecx,(%eax)
  8017f0:	8b 02                	mov    (%edx),%eax
  8017f2:	8b 52 04             	mov    0x4(%edx),%edx
  8017f5:	eb 22                	jmp    801819 <getuint+0x38>
	else if (lflag)
  8017f7:	85 d2                	test   %edx,%edx
  8017f9:	74 10                	je     80180b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8017fb:	8b 10                	mov    (%eax),%edx
  8017fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  801800:	89 08                	mov    %ecx,(%eax)
  801802:	8b 02                	mov    (%edx),%eax
  801804:	ba 00 00 00 00       	mov    $0x0,%edx
  801809:	eb 0e                	jmp    801819 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80180b:	8b 10                	mov    (%eax),%edx
  80180d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801810:	89 08                	mov    %ecx,(%eax)
  801812:	8b 02                	mov    (%edx),%eax
  801814:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801821:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801825:	8b 10                	mov    (%eax),%edx
  801827:	3b 50 04             	cmp    0x4(%eax),%edx
  80182a:	73 0a                	jae    801836 <sprintputch+0x1b>
		*b->buf++ = ch;
  80182c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80182f:	89 08                	mov    %ecx,(%eax)
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	88 02                	mov    %al,(%edx)
}
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80183e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801841:	50                   	push   %eax
  801842:	ff 75 10             	pushl  0x10(%ebp)
  801845:	ff 75 0c             	pushl  0xc(%ebp)
  801848:	ff 75 08             	pushl  0x8(%ebp)
  80184b:	e8 05 00 00 00       	call   801855 <vprintfmt>
	va_end(ap);
}
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	c9                   	leave  
  801854:	c3                   	ret    

00801855 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	57                   	push   %edi
  801859:	56                   	push   %esi
  80185a:	53                   	push   %ebx
  80185b:	83 ec 2c             	sub    $0x2c,%esp
  80185e:	8b 75 08             	mov    0x8(%ebp),%esi
  801861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801864:	8b 7d 10             	mov    0x10(%ebp),%edi
  801867:	eb 12                	jmp    80187b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801869:	85 c0                	test   %eax,%eax
  80186b:	0f 84 89 03 00 00    	je     801bfa <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	53                   	push   %ebx
  801875:	50                   	push   %eax
  801876:	ff d6                	call   *%esi
  801878:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80187b:	83 c7 01             	add    $0x1,%edi
  80187e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801882:	83 f8 25             	cmp    $0x25,%eax
  801885:	75 e2                	jne    801869 <vprintfmt+0x14>
  801887:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80188b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801892:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801899:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8018a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a5:	eb 07                	jmp    8018ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018aa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ae:	8d 47 01             	lea    0x1(%edi),%eax
  8018b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018b4:	0f b6 07             	movzbl (%edi),%eax
  8018b7:	0f b6 c8             	movzbl %al,%ecx
  8018ba:	83 e8 23             	sub    $0x23,%eax
  8018bd:	3c 55                	cmp    $0x55,%al
  8018bf:	0f 87 1a 03 00 00    	ja     801bdf <vprintfmt+0x38a>
  8018c5:	0f b6 c0             	movzbl %al,%eax
  8018c8:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  8018cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8018d2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8018d6:	eb d6                	jmp    8018ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8018e6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8018ea:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8018ed:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8018f0:	83 fa 09             	cmp    $0x9,%edx
  8018f3:	77 39                	ja     80192e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018f5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8018f8:	eb e9                	jmp    8018e3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fd:	8d 48 04             	lea    0x4(%eax),%ecx
  801900:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801903:	8b 00                	mov    (%eax),%eax
  801905:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801908:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80190b:	eb 27                	jmp    801934 <vprintfmt+0xdf>
  80190d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801910:	85 c0                	test   %eax,%eax
  801912:	b9 00 00 00 00       	mov    $0x0,%ecx
  801917:	0f 49 c8             	cmovns %eax,%ecx
  80191a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80191d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801920:	eb 8c                	jmp    8018ae <vprintfmt+0x59>
  801922:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801925:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80192c:	eb 80                	jmp    8018ae <vprintfmt+0x59>
  80192e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801931:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801934:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801938:	0f 89 70 ff ff ff    	jns    8018ae <vprintfmt+0x59>
				width = precision, precision = -1;
  80193e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801941:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801944:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80194b:	e9 5e ff ff ff       	jmp    8018ae <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801950:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801953:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801956:	e9 53 ff ff ff       	jmp    8018ae <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80195b:	8b 45 14             	mov    0x14(%ebp),%eax
  80195e:	8d 50 04             	lea    0x4(%eax),%edx
  801961:	89 55 14             	mov    %edx,0x14(%ebp)
  801964:	83 ec 08             	sub    $0x8,%esp
  801967:	53                   	push   %ebx
  801968:	ff 30                	pushl  (%eax)
  80196a:	ff d6                	call   *%esi
			break;
  80196c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80196f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801972:	e9 04 ff ff ff       	jmp    80187b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801977:	8b 45 14             	mov    0x14(%ebp),%eax
  80197a:	8d 50 04             	lea    0x4(%eax),%edx
  80197d:	89 55 14             	mov    %edx,0x14(%ebp)
  801980:	8b 00                	mov    (%eax),%eax
  801982:	99                   	cltd   
  801983:	31 d0                	xor    %edx,%eax
  801985:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801987:	83 f8 0f             	cmp    $0xf,%eax
  80198a:	7f 0b                	jg     801997 <vprintfmt+0x142>
  80198c:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  801993:	85 d2                	test   %edx,%edx
  801995:	75 18                	jne    8019af <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801997:	50                   	push   %eax
  801998:	68 3b 27 80 00       	push   $0x80273b
  80199d:	53                   	push   %ebx
  80199e:	56                   	push   %esi
  80199f:	e8 94 fe ff ff       	call   801838 <printfmt>
  8019a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019aa:	e9 cc fe ff ff       	jmp    80187b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8019af:	52                   	push   %edx
  8019b0:	68 b9 26 80 00       	push   $0x8026b9
  8019b5:	53                   	push   %ebx
  8019b6:	56                   	push   %esi
  8019b7:	e8 7c fe ff ff       	call   801838 <printfmt>
  8019bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019c2:	e9 b4 fe ff ff       	jmp    80187b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8019c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ca:	8d 50 04             	lea    0x4(%eax),%edx
  8019cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8019d0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8019d2:	85 ff                	test   %edi,%edi
  8019d4:	b8 34 27 80 00       	mov    $0x802734,%eax
  8019d9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8019dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019e0:	0f 8e 94 00 00 00    	jle    801a7a <vprintfmt+0x225>
  8019e6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8019ea:	0f 84 98 00 00 00    	je     801a88 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8019f0:	83 ec 08             	sub    $0x8,%esp
  8019f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8019f6:	57                   	push   %edi
  8019f7:	e8 86 02 00 00       	call   801c82 <strnlen>
  8019fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8019ff:	29 c1                	sub    %eax,%ecx
  801a01:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801a04:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801a07:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801a0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a0e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801a11:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a13:	eb 0f                	jmp    801a24 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801a15:	83 ec 08             	sub    $0x8,%esp
  801a18:	53                   	push   %ebx
  801a19:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a1e:	83 ef 01             	sub    $0x1,%edi
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	85 ff                	test   %edi,%edi
  801a26:	7f ed                	jg     801a15 <vprintfmt+0x1c0>
  801a28:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801a2b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801a2e:	85 c9                	test   %ecx,%ecx
  801a30:	b8 00 00 00 00       	mov    $0x0,%eax
  801a35:	0f 49 c1             	cmovns %ecx,%eax
  801a38:	29 c1                	sub    %eax,%ecx
  801a3a:	89 75 08             	mov    %esi,0x8(%ebp)
  801a3d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a40:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a43:	89 cb                	mov    %ecx,%ebx
  801a45:	eb 4d                	jmp    801a94 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a47:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a4b:	74 1b                	je     801a68 <vprintfmt+0x213>
  801a4d:	0f be c0             	movsbl %al,%eax
  801a50:	83 e8 20             	sub    $0x20,%eax
  801a53:	83 f8 5e             	cmp    $0x5e,%eax
  801a56:	76 10                	jbe    801a68 <vprintfmt+0x213>
					putch('?', putdat);
  801a58:	83 ec 08             	sub    $0x8,%esp
  801a5b:	ff 75 0c             	pushl  0xc(%ebp)
  801a5e:	6a 3f                	push   $0x3f
  801a60:	ff 55 08             	call   *0x8(%ebp)
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	eb 0d                	jmp    801a75 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a68:	83 ec 08             	sub    $0x8,%esp
  801a6b:	ff 75 0c             	pushl  0xc(%ebp)
  801a6e:	52                   	push   %edx
  801a6f:	ff 55 08             	call   *0x8(%ebp)
  801a72:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a75:	83 eb 01             	sub    $0x1,%ebx
  801a78:	eb 1a                	jmp    801a94 <vprintfmt+0x23f>
  801a7a:	89 75 08             	mov    %esi,0x8(%ebp)
  801a7d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a80:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a83:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a86:	eb 0c                	jmp    801a94 <vprintfmt+0x23f>
  801a88:	89 75 08             	mov    %esi,0x8(%ebp)
  801a8b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a8e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a91:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a94:	83 c7 01             	add    $0x1,%edi
  801a97:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a9b:	0f be d0             	movsbl %al,%edx
  801a9e:	85 d2                	test   %edx,%edx
  801aa0:	74 23                	je     801ac5 <vprintfmt+0x270>
  801aa2:	85 f6                	test   %esi,%esi
  801aa4:	78 a1                	js     801a47 <vprintfmt+0x1f2>
  801aa6:	83 ee 01             	sub    $0x1,%esi
  801aa9:	79 9c                	jns    801a47 <vprintfmt+0x1f2>
  801aab:	89 df                	mov    %ebx,%edi
  801aad:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ab3:	eb 18                	jmp    801acd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801ab5:	83 ec 08             	sub    $0x8,%esp
  801ab8:	53                   	push   %ebx
  801ab9:	6a 20                	push   $0x20
  801abb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801abd:	83 ef 01             	sub    $0x1,%edi
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	eb 08                	jmp    801acd <vprintfmt+0x278>
  801ac5:	89 df                	mov    %ebx,%edi
  801ac7:	8b 75 08             	mov    0x8(%ebp),%esi
  801aca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801acd:	85 ff                	test   %edi,%edi
  801acf:	7f e4                	jg     801ab5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ad1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ad4:	e9 a2 fd ff ff       	jmp    80187b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801ad9:	83 fa 01             	cmp    $0x1,%edx
  801adc:	7e 16                	jle    801af4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801ade:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae1:	8d 50 08             	lea    0x8(%eax),%edx
  801ae4:	89 55 14             	mov    %edx,0x14(%ebp)
  801ae7:	8b 50 04             	mov    0x4(%eax),%edx
  801aea:	8b 00                	mov    (%eax),%eax
  801aec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801af2:	eb 32                	jmp    801b26 <vprintfmt+0x2d1>
	else if (lflag)
  801af4:	85 d2                	test   %edx,%edx
  801af6:	74 18                	je     801b10 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801af8:	8b 45 14             	mov    0x14(%ebp),%eax
  801afb:	8d 50 04             	lea    0x4(%eax),%edx
  801afe:	89 55 14             	mov    %edx,0x14(%ebp)
  801b01:	8b 00                	mov    (%eax),%eax
  801b03:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b06:	89 c1                	mov    %eax,%ecx
  801b08:	c1 f9 1f             	sar    $0x1f,%ecx
  801b0b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801b0e:	eb 16                	jmp    801b26 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801b10:	8b 45 14             	mov    0x14(%ebp),%eax
  801b13:	8d 50 04             	lea    0x4(%eax),%edx
  801b16:	89 55 14             	mov    %edx,0x14(%ebp)
  801b19:	8b 00                	mov    (%eax),%eax
  801b1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b1e:	89 c1                	mov    %eax,%ecx
  801b20:	c1 f9 1f             	sar    $0x1f,%ecx
  801b23:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b26:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b29:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801b2c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b31:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b35:	79 74                	jns    801bab <vprintfmt+0x356>
				putch('-', putdat);
  801b37:	83 ec 08             	sub    $0x8,%esp
  801b3a:	53                   	push   %ebx
  801b3b:	6a 2d                	push   $0x2d
  801b3d:	ff d6                	call   *%esi
				num = -(long long) num;
  801b3f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b42:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b45:	f7 d8                	neg    %eax
  801b47:	83 d2 00             	adc    $0x0,%edx
  801b4a:	f7 da                	neg    %edx
  801b4c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b4f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b54:	eb 55                	jmp    801bab <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b56:	8d 45 14             	lea    0x14(%ebp),%eax
  801b59:	e8 83 fc ff ff       	call   8017e1 <getuint>
			base = 10;
  801b5e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b63:	eb 46                	jmp    801bab <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b65:	8d 45 14             	lea    0x14(%ebp),%eax
  801b68:	e8 74 fc ff ff       	call   8017e1 <getuint>
			base = 8;
  801b6d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b72:	eb 37                	jmp    801bab <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b74:	83 ec 08             	sub    $0x8,%esp
  801b77:	53                   	push   %ebx
  801b78:	6a 30                	push   $0x30
  801b7a:	ff d6                	call   *%esi
			putch('x', putdat);
  801b7c:	83 c4 08             	add    $0x8,%esp
  801b7f:	53                   	push   %ebx
  801b80:	6a 78                	push   $0x78
  801b82:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b84:	8b 45 14             	mov    0x14(%ebp),%eax
  801b87:	8d 50 04             	lea    0x4(%eax),%edx
  801b8a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b8d:	8b 00                	mov    (%eax),%eax
  801b8f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b94:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b97:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b9c:	eb 0d                	jmp    801bab <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b9e:	8d 45 14             	lea    0x14(%ebp),%eax
  801ba1:	e8 3b fc ff ff       	call   8017e1 <getuint>
			base = 16;
  801ba6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801bb2:	57                   	push   %edi
  801bb3:	ff 75 e0             	pushl  -0x20(%ebp)
  801bb6:	51                   	push   %ecx
  801bb7:	52                   	push   %edx
  801bb8:	50                   	push   %eax
  801bb9:	89 da                	mov    %ebx,%edx
  801bbb:	89 f0                	mov    %esi,%eax
  801bbd:	e8 70 fb ff ff       	call   801732 <printnum>
			break;
  801bc2:	83 c4 20             	add    $0x20,%esp
  801bc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bc8:	e9 ae fc ff ff       	jmp    80187b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801bcd:	83 ec 08             	sub    $0x8,%esp
  801bd0:	53                   	push   %ebx
  801bd1:	51                   	push   %ecx
  801bd2:	ff d6                	call   *%esi
			break;
  801bd4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bd7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801bda:	e9 9c fc ff ff       	jmp    80187b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801bdf:	83 ec 08             	sub    $0x8,%esp
  801be2:	53                   	push   %ebx
  801be3:	6a 25                	push   $0x25
  801be5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801be7:	83 c4 10             	add    $0x10,%esp
  801bea:	eb 03                	jmp    801bef <vprintfmt+0x39a>
  801bec:	83 ef 01             	sub    $0x1,%edi
  801bef:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801bf3:	75 f7                	jne    801bec <vprintfmt+0x397>
  801bf5:	e9 81 fc ff ff       	jmp    80187b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5f                   	pop    %edi
  801c00:	5d                   	pop    %ebp
  801c01:	c3                   	ret    

00801c02 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	83 ec 18             	sub    $0x18,%esp
  801c08:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c11:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c15:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c18:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	74 26                	je     801c49 <vsnprintf+0x47>
  801c23:	85 d2                	test   %edx,%edx
  801c25:	7e 22                	jle    801c49 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c27:	ff 75 14             	pushl  0x14(%ebp)
  801c2a:	ff 75 10             	pushl  0x10(%ebp)
  801c2d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c30:	50                   	push   %eax
  801c31:	68 1b 18 80 00       	push   $0x80181b
  801c36:	e8 1a fc ff ff       	call   801855 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c3e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c44:	83 c4 10             	add    $0x10,%esp
  801c47:	eb 05                	jmp    801c4e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c4e:	c9                   	leave  
  801c4f:	c3                   	ret    

00801c50 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c56:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c59:	50                   	push   %eax
  801c5a:	ff 75 10             	pushl  0x10(%ebp)
  801c5d:	ff 75 0c             	pushl  0xc(%ebp)
  801c60:	ff 75 08             	pushl  0x8(%ebp)
  801c63:	e8 9a ff ff ff       	call   801c02 <vsnprintf>
	va_end(ap);

	return rc;
}
  801c68:	c9                   	leave  
  801c69:	c3                   	ret    

00801c6a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c70:	b8 00 00 00 00       	mov    $0x0,%eax
  801c75:	eb 03                	jmp    801c7a <strlen+0x10>
		n++;
  801c77:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c7a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c7e:	75 f7                	jne    801c77 <strlen+0xd>
		n++;
	return n;
}
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c88:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c90:	eb 03                	jmp    801c95 <strnlen+0x13>
		n++;
  801c92:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c95:	39 c2                	cmp    %eax,%edx
  801c97:	74 08                	je     801ca1 <strnlen+0x1f>
  801c99:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c9d:	75 f3                	jne    801c92 <strnlen+0x10>
  801c9f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	53                   	push   %ebx
  801ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  801caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801cad:	89 c2                	mov    %eax,%edx
  801caf:	83 c2 01             	add    $0x1,%edx
  801cb2:	83 c1 01             	add    $0x1,%ecx
  801cb5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801cb9:	88 5a ff             	mov    %bl,-0x1(%edx)
  801cbc:	84 db                	test   %bl,%bl
  801cbe:	75 ef                	jne    801caf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801cc0:	5b                   	pop    %ebx
  801cc1:	5d                   	pop    %ebp
  801cc2:	c3                   	ret    

00801cc3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	53                   	push   %ebx
  801cc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801cca:	53                   	push   %ebx
  801ccb:	e8 9a ff ff ff       	call   801c6a <strlen>
  801cd0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801cd3:	ff 75 0c             	pushl  0xc(%ebp)
  801cd6:	01 d8                	add    %ebx,%eax
  801cd8:	50                   	push   %eax
  801cd9:	e8 c5 ff ff ff       	call   801ca3 <strcpy>
	return dst;
}
  801cde:	89 d8                	mov    %ebx,%eax
  801ce0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    

00801ce5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	56                   	push   %esi
  801ce9:	53                   	push   %ebx
  801cea:	8b 75 08             	mov    0x8(%ebp),%esi
  801ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf0:	89 f3                	mov    %esi,%ebx
  801cf2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cf5:	89 f2                	mov    %esi,%edx
  801cf7:	eb 0f                	jmp    801d08 <strncpy+0x23>
		*dst++ = *src;
  801cf9:	83 c2 01             	add    $0x1,%edx
  801cfc:	0f b6 01             	movzbl (%ecx),%eax
  801cff:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d02:	80 39 01             	cmpb   $0x1,(%ecx)
  801d05:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d08:	39 da                	cmp    %ebx,%edx
  801d0a:	75 ed                	jne    801cf9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d0c:	89 f0                	mov    %esi,%eax
  801d0e:	5b                   	pop    %ebx
  801d0f:	5e                   	pop    %esi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	56                   	push   %esi
  801d16:	53                   	push   %ebx
  801d17:	8b 75 08             	mov    0x8(%ebp),%esi
  801d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d1d:	8b 55 10             	mov    0x10(%ebp),%edx
  801d20:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d22:	85 d2                	test   %edx,%edx
  801d24:	74 21                	je     801d47 <strlcpy+0x35>
  801d26:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801d2a:	89 f2                	mov    %esi,%edx
  801d2c:	eb 09                	jmp    801d37 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d2e:	83 c2 01             	add    $0x1,%edx
  801d31:	83 c1 01             	add    $0x1,%ecx
  801d34:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801d37:	39 c2                	cmp    %eax,%edx
  801d39:	74 09                	je     801d44 <strlcpy+0x32>
  801d3b:	0f b6 19             	movzbl (%ecx),%ebx
  801d3e:	84 db                	test   %bl,%bl
  801d40:	75 ec                	jne    801d2e <strlcpy+0x1c>
  801d42:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d44:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d47:	29 f0                	sub    %esi,%eax
}
  801d49:	5b                   	pop    %ebx
  801d4a:	5e                   	pop    %esi
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    

00801d4d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d53:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d56:	eb 06                	jmp    801d5e <strcmp+0x11>
		p++, q++;
  801d58:	83 c1 01             	add    $0x1,%ecx
  801d5b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d5e:	0f b6 01             	movzbl (%ecx),%eax
  801d61:	84 c0                	test   %al,%al
  801d63:	74 04                	je     801d69 <strcmp+0x1c>
  801d65:	3a 02                	cmp    (%edx),%al
  801d67:	74 ef                	je     801d58 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d69:	0f b6 c0             	movzbl %al,%eax
  801d6c:	0f b6 12             	movzbl (%edx),%edx
  801d6f:	29 d0                	sub    %edx,%eax
}
  801d71:	5d                   	pop    %ebp
  801d72:	c3                   	ret    

00801d73 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	53                   	push   %ebx
  801d77:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d7d:	89 c3                	mov    %eax,%ebx
  801d7f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d82:	eb 06                	jmp    801d8a <strncmp+0x17>
		n--, p++, q++;
  801d84:	83 c0 01             	add    $0x1,%eax
  801d87:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d8a:	39 d8                	cmp    %ebx,%eax
  801d8c:	74 15                	je     801da3 <strncmp+0x30>
  801d8e:	0f b6 08             	movzbl (%eax),%ecx
  801d91:	84 c9                	test   %cl,%cl
  801d93:	74 04                	je     801d99 <strncmp+0x26>
  801d95:	3a 0a                	cmp    (%edx),%cl
  801d97:	74 eb                	je     801d84 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d99:	0f b6 00             	movzbl (%eax),%eax
  801d9c:	0f b6 12             	movzbl (%edx),%edx
  801d9f:	29 d0                	sub    %edx,%eax
  801da1:	eb 05                	jmp    801da8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801da3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801da8:	5b                   	pop    %ebx
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	8b 45 08             	mov    0x8(%ebp),%eax
  801db1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801db5:	eb 07                	jmp    801dbe <strchr+0x13>
		if (*s == c)
  801db7:	38 ca                	cmp    %cl,%dl
  801db9:	74 0f                	je     801dca <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801dbb:	83 c0 01             	add    $0x1,%eax
  801dbe:	0f b6 10             	movzbl (%eax),%edx
  801dc1:	84 d2                	test   %dl,%dl
  801dc3:	75 f2                	jne    801db7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801dc5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    

00801dcc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801dd6:	eb 03                	jmp    801ddb <strfind+0xf>
  801dd8:	83 c0 01             	add    $0x1,%eax
  801ddb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801dde:	38 ca                	cmp    %cl,%dl
  801de0:	74 04                	je     801de6 <strfind+0x1a>
  801de2:	84 d2                	test   %dl,%dl
  801de4:	75 f2                	jne    801dd8 <strfind+0xc>
			break;
	return (char *) s;
}
  801de6:	5d                   	pop    %ebp
  801de7:	c3                   	ret    

00801de8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	57                   	push   %edi
  801dec:	56                   	push   %esi
  801ded:	53                   	push   %ebx
  801dee:	8b 7d 08             	mov    0x8(%ebp),%edi
  801df1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801df4:	85 c9                	test   %ecx,%ecx
  801df6:	74 36                	je     801e2e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801df8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801dfe:	75 28                	jne    801e28 <memset+0x40>
  801e00:	f6 c1 03             	test   $0x3,%cl
  801e03:	75 23                	jne    801e28 <memset+0x40>
		c &= 0xFF;
  801e05:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e09:	89 d3                	mov    %edx,%ebx
  801e0b:	c1 e3 08             	shl    $0x8,%ebx
  801e0e:	89 d6                	mov    %edx,%esi
  801e10:	c1 e6 18             	shl    $0x18,%esi
  801e13:	89 d0                	mov    %edx,%eax
  801e15:	c1 e0 10             	shl    $0x10,%eax
  801e18:	09 f0                	or     %esi,%eax
  801e1a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801e1c:	89 d8                	mov    %ebx,%eax
  801e1e:	09 d0                	or     %edx,%eax
  801e20:	c1 e9 02             	shr    $0x2,%ecx
  801e23:	fc                   	cld    
  801e24:	f3 ab                	rep stos %eax,%es:(%edi)
  801e26:	eb 06                	jmp    801e2e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2b:	fc                   	cld    
  801e2c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e2e:	89 f8                	mov    %edi,%eax
  801e30:	5b                   	pop    %ebx
  801e31:	5e                   	pop    %esi
  801e32:	5f                   	pop    %edi
  801e33:	5d                   	pop    %ebp
  801e34:	c3                   	ret    

00801e35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e35:	55                   	push   %ebp
  801e36:	89 e5                	mov    %esp,%ebp
  801e38:	57                   	push   %edi
  801e39:	56                   	push   %esi
  801e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e43:	39 c6                	cmp    %eax,%esi
  801e45:	73 35                	jae    801e7c <memmove+0x47>
  801e47:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e4a:	39 d0                	cmp    %edx,%eax
  801e4c:	73 2e                	jae    801e7c <memmove+0x47>
		s += n;
		d += n;
  801e4e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e51:	89 d6                	mov    %edx,%esi
  801e53:	09 fe                	or     %edi,%esi
  801e55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e5b:	75 13                	jne    801e70 <memmove+0x3b>
  801e5d:	f6 c1 03             	test   $0x3,%cl
  801e60:	75 0e                	jne    801e70 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e62:	83 ef 04             	sub    $0x4,%edi
  801e65:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e68:	c1 e9 02             	shr    $0x2,%ecx
  801e6b:	fd                   	std    
  801e6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e6e:	eb 09                	jmp    801e79 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e70:	83 ef 01             	sub    $0x1,%edi
  801e73:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e76:	fd                   	std    
  801e77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e79:	fc                   	cld    
  801e7a:	eb 1d                	jmp    801e99 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e7c:	89 f2                	mov    %esi,%edx
  801e7e:	09 c2                	or     %eax,%edx
  801e80:	f6 c2 03             	test   $0x3,%dl
  801e83:	75 0f                	jne    801e94 <memmove+0x5f>
  801e85:	f6 c1 03             	test   $0x3,%cl
  801e88:	75 0a                	jne    801e94 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e8a:	c1 e9 02             	shr    $0x2,%ecx
  801e8d:	89 c7                	mov    %eax,%edi
  801e8f:	fc                   	cld    
  801e90:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e92:	eb 05                	jmp    801e99 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e94:	89 c7                	mov    %eax,%edi
  801e96:	fc                   	cld    
  801e97:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801ea0:	ff 75 10             	pushl  0x10(%ebp)
  801ea3:	ff 75 0c             	pushl  0xc(%ebp)
  801ea6:	ff 75 08             	pushl  0x8(%ebp)
  801ea9:	e8 87 ff ff ff       	call   801e35 <memmove>
}
  801eae:	c9                   	leave  
  801eaf:	c3                   	ret    

00801eb0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	56                   	push   %esi
  801eb4:	53                   	push   %ebx
  801eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ebb:	89 c6                	mov    %eax,%esi
  801ebd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ec0:	eb 1a                	jmp    801edc <memcmp+0x2c>
		if (*s1 != *s2)
  801ec2:	0f b6 08             	movzbl (%eax),%ecx
  801ec5:	0f b6 1a             	movzbl (%edx),%ebx
  801ec8:	38 d9                	cmp    %bl,%cl
  801eca:	74 0a                	je     801ed6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ecc:	0f b6 c1             	movzbl %cl,%eax
  801ecf:	0f b6 db             	movzbl %bl,%ebx
  801ed2:	29 d8                	sub    %ebx,%eax
  801ed4:	eb 0f                	jmp    801ee5 <memcmp+0x35>
		s1++, s2++;
  801ed6:	83 c0 01             	add    $0x1,%eax
  801ed9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801edc:	39 f0                	cmp    %esi,%eax
  801ede:	75 e2                	jne    801ec2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ee0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee5:	5b                   	pop    %ebx
  801ee6:	5e                   	pop    %esi
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	53                   	push   %ebx
  801eed:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801ef0:	89 c1                	mov    %eax,%ecx
  801ef2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801ef5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ef9:	eb 0a                	jmp    801f05 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801efb:	0f b6 10             	movzbl (%eax),%edx
  801efe:	39 da                	cmp    %ebx,%edx
  801f00:	74 07                	je     801f09 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f02:	83 c0 01             	add    $0x1,%eax
  801f05:	39 c8                	cmp    %ecx,%eax
  801f07:	72 f2                	jb     801efb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801f09:	5b                   	pop    %ebx
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	57                   	push   %edi
  801f10:	56                   	push   %esi
  801f11:	53                   	push   %ebx
  801f12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f18:	eb 03                	jmp    801f1d <strtol+0x11>
		s++;
  801f1a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f1d:	0f b6 01             	movzbl (%ecx),%eax
  801f20:	3c 20                	cmp    $0x20,%al
  801f22:	74 f6                	je     801f1a <strtol+0xe>
  801f24:	3c 09                	cmp    $0x9,%al
  801f26:	74 f2                	je     801f1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801f28:	3c 2b                	cmp    $0x2b,%al
  801f2a:	75 0a                	jne    801f36 <strtol+0x2a>
		s++;
  801f2c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f2f:	bf 00 00 00 00       	mov    $0x0,%edi
  801f34:	eb 11                	jmp    801f47 <strtol+0x3b>
  801f36:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801f3b:	3c 2d                	cmp    $0x2d,%al
  801f3d:	75 08                	jne    801f47 <strtol+0x3b>
		s++, neg = 1;
  801f3f:	83 c1 01             	add    $0x1,%ecx
  801f42:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f47:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f4d:	75 15                	jne    801f64 <strtol+0x58>
  801f4f:	80 39 30             	cmpb   $0x30,(%ecx)
  801f52:	75 10                	jne    801f64 <strtol+0x58>
  801f54:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f58:	75 7c                	jne    801fd6 <strtol+0xca>
		s += 2, base = 16;
  801f5a:	83 c1 02             	add    $0x2,%ecx
  801f5d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f62:	eb 16                	jmp    801f7a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f64:	85 db                	test   %ebx,%ebx
  801f66:	75 12                	jne    801f7a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f68:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f6d:	80 39 30             	cmpb   $0x30,(%ecx)
  801f70:	75 08                	jne    801f7a <strtol+0x6e>
		s++, base = 8;
  801f72:	83 c1 01             	add    $0x1,%ecx
  801f75:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f82:	0f b6 11             	movzbl (%ecx),%edx
  801f85:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f88:	89 f3                	mov    %esi,%ebx
  801f8a:	80 fb 09             	cmp    $0x9,%bl
  801f8d:	77 08                	ja     801f97 <strtol+0x8b>
			dig = *s - '0';
  801f8f:	0f be d2             	movsbl %dl,%edx
  801f92:	83 ea 30             	sub    $0x30,%edx
  801f95:	eb 22                	jmp    801fb9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f97:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f9a:	89 f3                	mov    %esi,%ebx
  801f9c:	80 fb 19             	cmp    $0x19,%bl
  801f9f:	77 08                	ja     801fa9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801fa1:	0f be d2             	movsbl %dl,%edx
  801fa4:	83 ea 57             	sub    $0x57,%edx
  801fa7:	eb 10                	jmp    801fb9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801fa9:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fac:	89 f3                	mov    %esi,%ebx
  801fae:	80 fb 19             	cmp    $0x19,%bl
  801fb1:	77 16                	ja     801fc9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801fb3:	0f be d2             	movsbl %dl,%edx
  801fb6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801fb9:	3b 55 10             	cmp    0x10(%ebp),%edx
  801fbc:	7d 0b                	jge    801fc9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801fbe:	83 c1 01             	add    $0x1,%ecx
  801fc1:	0f af 45 10          	imul   0x10(%ebp),%eax
  801fc5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801fc7:	eb b9                	jmp    801f82 <strtol+0x76>

	if (endptr)
  801fc9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801fcd:	74 0d                	je     801fdc <strtol+0xd0>
		*endptr = (char *) s;
  801fcf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd2:	89 0e                	mov    %ecx,(%esi)
  801fd4:	eb 06                	jmp    801fdc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801fd6:	85 db                	test   %ebx,%ebx
  801fd8:	74 98                	je     801f72 <strtol+0x66>
  801fda:	eb 9e                	jmp    801f7a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801fdc:	89 c2                	mov    %eax,%edx
  801fde:	f7 da                	neg    %edx
  801fe0:	85 ff                	test   %edi,%edi
  801fe2:	0f 45 c2             	cmovne %edx,%eax
}
  801fe5:	5b                   	pop    %ebx
  801fe6:	5e                   	pop    %esi
  801fe7:	5f                   	pop    %edi
  801fe8:	5d                   	pop    %ebp
  801fe9:	c3                   	ret    

00801fea <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ff0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ff7:	75 2a                	jne    802023 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ff9:	83 ec 04             	sub    $0x4,%esp
  801ffc:	6a 07                	push   $0x7
  801ffe:	68 00 f0 bf ee       	push   $0xeebff000
  802003:	6a 00                	push   $0x0
  802005:	e8 6f e1 ff ff       	call   800179 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  80200a:	83 c4 10             	add    $0x10,%esp
  80200d:	85 c0                	test   %eax,%eax
  80200f:	79 12                	jns    802023 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802011:	50                   	push   %eax
  802012:	68 83 25 80 00       	push   $0x802583
  802017:	6a 23                	push   $0x23
  802019:	68 20 2a 80 00       	push   $0x802a20
  80201e:	e8 22 f6 ff ff       	call   801645 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802023:	8b 45 08             	mov    0x8(%ebp),%eax
  802026:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80202b:	83 ec 08             	sub    $0x8,%esp
  80202e:	68 55 20 80 00       	push   $0x802055
  802033:	6a 00                	push   $0x0
  802035:	e8 8a e2 ff ff       	call   8002c4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  80203a:	83 c4 10             	add    $0x10,%esp
  80203d:	85 c0                	test   %eax,%eax
  80203f:	79 12                	jns    802053 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802041:	50                   	push   %eax
  802042:	68 83 25 80 00       	push   $0x802583
  802047:	6a 2c                	push   $0x2c
  802049:	68 20 2a 80 00       	push   $0x802a20
  80204e:	e8 f2 f5 ff ff       	call   801645 <_panic>
	}
}
  802053:	c9                   	leave  
  802054:	c3                   	ret    

00802055 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802055:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802056:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80205b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80205d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802060:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802064:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802069:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80206d:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80206f:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802072:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802073:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802076:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802077:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802078:	c3                   	ret    

00802079 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	56                   	push   %esi
  80207d:	53                   	push   %ebx
  80207e:	8b 75 08             	mov    0x8(%ebp),%esi
  802081:	8b 45 0c             	mov    0xc(%ebp),%eax
  802084:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802087:	85 c0                	test   %eax,%eax
  802089:	75 12                	jne    80209d <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80208b:	83 ec 0c             	sub    $0xc,%esp
  80208e:	68 00 00 c0 ee       	push   $0xeec00000
  802093:	e8 91 e2 ff ff       	call   800329 <sys_ipc_recv>
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	eb 0c                	jmp    8020a9 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80209d:	83 ec 0c             	sub    $0xc,%esp
  8020a0:	50                   	push   %eax
  8020a1:	e8 83 e2 ff ff       	call   800329 <sys_ipc_recv>
  8020a6:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020a9:	85 f6                	test   %esi,%esi
  8020ab:	0f 95 c1             	setne  %cl
  8020ae:	85 db                	test   %ebx,%ebx
  8020b0:	0f 95 c2             	setne  %dl
  8020b3:	84 d1                	test   %dl,%cl
  8020b5:	74 09                	je     8020c0 <ipc_recv+0x47>
  8020b7:	89 c2                	mov    %eax,%edx
  8020b9:	c1 ea 1f             	shr    $0x1f,%edx
  8020bc:	84 d2                	test   %dl,%dl
  8020be:	75 2d                	jne    8020ed <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020c0:	85 f6                	test   %esi,%esi
  8020c2:	74 0d                	je     8020d1 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020c4:	a1 04 40 80 00       	mov    0x804004,%eax
  8020c9:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020cf:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020d1:	85 db                	test   %ebx,%ebx
  8020d3:	74 0d                	je     8020e2 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020d5:	a1 04 40 80 00       	mov    0x804004,%eax
  8020da:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8020e0:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e7:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8020ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f0:	5b                   	pop    %ebx
  8020f1:	5e                   	pop    %esi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    

008020f4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	57                   	push   %edi
  8020f8:	56                   	push   %esi
  8020f9:	53                   	push   %ebx
  8020fa:	83 ec 0c             	sub    $0xc,%esp
  8020fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  802100:	8b 75 0c             	mov    0xc(%ebp),%esi
  802103:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802106:	85 db                	test   %ebx,%ebx
  802108:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80210d:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802110:	ff 75 14             	pushl  0x14(%ebp)
  802113:	53                   	push   %ebx
  802114:	56                   	push   %esi
  802115:	57                   	push   %edi
  802116:	e8 eb e1 ff ff       	call   800306 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80211b:	89 c2                	mov    %eax,%edx
  80211d:	c1 ea 1f             	shr    $0x1f,%edx
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	84 d2                	test   %dl,%dl
  802125:	74 17                	je     80213e <ipc_send+0x4a>
  802127:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80212a:	74 12                	je     80213e <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80212c:	50                   	push   %eax
  80212d:	68 2e 2a 80 00       	push   $0x802a2e
  802132:	6a 47                	push   $0x47
  802134:	68 3c 2a 80 00       	push   $0x802a3c
  802139:	e8 07 f5 ff ff       	call   801645 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80213e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802141:	75 07                	jne    80214a <ipc_send+0x56>
			sys_yield();
  802143:	e8 12 e0 ff ff       	call   80015a <sys_yield>
  802148:	eb c6                	jmp    802110 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  80214a:	85 c0                	test   %eax,%eax
  80214c:	75 c2                	jne    802110 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80214e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802151:	5b                   	pop    %ebx
  802152:	5e                   	pop    %esi
  802153:	5f                   	pop    %edi
  802154:	5d                   	pop    %ebp
  802155:	c3                   	ret    

00802156 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802156:	55                   	push   %ebp
  802157:	89 e5                	mov    %esp,%ebp
  802159:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80215c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802161:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802167:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80216d:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802173:	39 ca                	cmp    %ecx,%edx
  802175:	75 13                	jne    80218a <ipc_find_env+0x34>
			return envs[i].env_id;
  802177:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80217d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802182:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802188:	eb 0f                	jmp    802199 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80218a:	83 c0 01             	add    $0x1,%eax
  80218d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802192:	75 cd                	jne    802161 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802194:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802199:	5d                   	pop    %ebp
  80219a:	c3                   	ret    

0080219b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80219b:	55                   	push   %ebp
  80219c:	89 e5                	mov    %esp,%ebp
  80219e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a1:	89 d0                	mov    %edx,%eax
  8021a3:	c1 e8 16             	shr    $0x16,%eax
  8021a6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021ad:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b2:	f6 c1 01             	test   $0x1,%cl
  8021b5:	74 1d                	je     8021d4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021b7:	c1 ea 0c             	shr    $0xc,%edx
  8021ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021c1:	f6 c2 01             	test   $0x1,%dl
  8021c4:	74 0e                	je     8021d4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021c6:	c1 ea 0c             	shr    $0xc,%edx
  8021c9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021d0:	ef 
  8021d1:	0f b7 c0             	movzwl %ax,%eax
}
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    
  8021d6:	66 90                	xchg   %ax,%ax
  8021d8:	66 90                	xchg   %ax,%ax
  8021da:	66 90                	xchg   %ax,%ax
  8021dc:	66 90                	xchg   %ax,%ax
  8021de:	66 90                	xchg   %ax,%ax

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 ca                	mov    %ecx,%edx
  8021ff:	89 f8                	mov    %edi,%eax
  802201:	75 3d                	jne    802240 <__udivdi3+0x60>
  802203:	39 cf                	cmp    %ecx,%edi
  802205:	0f 87 c5 00 00 00    	ja     8022d0 <__udivdi3+0xf0>
  80220b:	85 ff                	test   %edi,%edi
  80220d:	89 fd                	mov    %edi,%ebp
  80220f:	75 0b                	jne    80221c <__udivdi3+0x3c>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	31 d2                	xor    %edx,%edx
  802218:	f7 f7                	div    %edi
  80221a:	89 c5                	mov    %eax,%ebp
  80221c:	89 c8                	mov    %ecx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f5                	div    %ebp
  802222:	89 c1                	mov    %eax,%ecx
  802224:	89 d8                	mov    %ebx,%eax
  802226:	89 cf                	mov    %ecx,%edi
  802228:	f7 f5                	div    %ebp
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 ce                	cmp    %ecx,%esi
  802242:	77 74                	ja     8022b8 <__udivdi3+0xd8>
  802244:	0f bd fe             	bsr    %esi,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0x108>
  802250:	bb 20 00 00 00       	mov    $0x20,%ebx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	89 c5                	mov    %eax,%ebp
  802259:	29 fb                	sub    %edi,%ebx
  80225b:	d3 e6                	shl    %cl,%esi
  80225d:	89 d9                	mov    %ebx,%ecx
  80225f:	d3 ed                	shr    %cl,%ebp
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e0                	shl    %cl,%eax
  802265:	09 ee                	or     %ebp,%esi
  802267:	89 d9                	mov    %ebx,%ecx
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 d5                	mov    %edx,%ebp
  80226f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802273:	d3 ed                	shr    %cl,%ebp
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e2                	shl    %cl,%edx
  802279:	89 d9                	mov    %ebx,%ecx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	09 c2                	or     %eax,%edx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	89 ea                	mov    %ebp,%edx
  802283:	f7 f6                	div    %esi
  802285:	89 d5                	mov    %edx,%ebp
  802287:	89 c3                	mov    %eax,%ebx
  802289:	f7 64 24 0c          	mull   0xc(%esp)
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	72 10                	jb     8022a1 <__udivdi3+0xc1>
  802291:	8b 74 24 08          	mov    0x8(%esp),%esi
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e6                	shl    %cl,%esi
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 07                	jae    8022a4 <__udivdi3+0xc4>
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	75 03                	jne    8022a4 <__udivdi3+0xc4>
  8022a1:	83 eb 01             	sub    $0x1,%ebx
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 db                	xor    %ebx,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	f7 f7                	div    %edi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 fa                	mov    %edi,%edx
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 ce                	cmp    %ecx,%esi
  8022ea:	72 0c                	jb     8022f8 <__udivdi3+0x118>
  8022ec:	31 db                	xor    %ebx,%ebx
  8022ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022f2:	0f 87 34 ff ff ff    	ja     80222c <__udivdi3+0x4c>
  8022f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022fd:	e9 2a ff ff ff       	jmp    80222c <__udivdi3+0x4c>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80231b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80231f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 d2                	test   %edx,%edx
  802329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f3                	mov    %esi,%ebx
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	75 1c                	jne    802358 <__umoddi3+0x48>
  80233c:	39 f7                	cmp    %esi,%edi
  80233e:	76 50                	jbe    802390 <__umoddi3+0x80>
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	f7 f7                	div    %edi
  802346:	89 d0                	mov    %edx,%eax
  802348:	31 d2                	xor    %edx,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	77 52                	ja     8023b0 <__umoddi3+0xa0>
  80235e:	0f bd ea             	bsr    %edx,%ebp
  802361:	83 f5 1f             	xor    $0x1f,%ebp
  802364:	75 5a                	jne    8023c0 <__umoddi3+0xb0>
  802366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	39 0c 24             	cmp    %ecx,(%esp)
  802373:	0f 86 d7 00 00 00    	jbe    802450 <__umoddi3+0x140>
  802379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	85 ff                	test   %edi,%edi
  802392:	89 fd                	mov    %edi,%ebp
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 c8                	mov    %ecx,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	eb 99                	jmp    802348 <__umoddi3+0x38>
  8023af:	90                   	nop
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	83 c4 1c             	add    $0x1c,%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	8b 34 24             	mov    (%esp),%esi
  8023c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	29 ef                	sub    %ebp,%edi
  8023cc:	d3 e0                	shl    %cl,%eax
  8023ce:	89 f9                	mov    %edi,%ecx
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	d3 ea                	shr    %cl,%edx
  8023d4:	89 e9                	mov    %ebp,%ecx
  8023d6:	09 c2                	or     %eax,%edx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 14 24             	mov    %edx,(%esp)
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	d3 e2                	shl    %cl,%edx
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	d3 e3                	shl    %cl,%ebx
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	09 d8                	or     %ebx,%eax
  8023fd:	89 d3                	mov    %edx,%ebx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	f7 34 24             	divl   (%esp)
  802404:	89 d6                	mov    %edx,%esi
  802406:	d3 e3                	shl    %cl,%ebx
  802408:	f7 64 24 04          	mull   0x4(%esp)
  80240c:	39 d6                	cmp    %edx,%esi
  80240e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802412:	89 d1                	mov    %edx,%ecx
  802414:	89 c3                	mov    %eax,%ebx
  802416:	72 08                	jb     802420 <__umoddi3+0x110>
  802418:	75 11                	jne    80242b <__umoddi3+0x11b>
  80241a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80241e:	73 0b                	jae    80242b <__umoddi3+0x11b>
  802420:	2b 44 24 04          	sub    0x4(%esp),%eax
  802424:	1b 14 24             	sbb    (%esp),%edx
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80242f:	29 da                	sub    %ebx,%edx
  802431:	19 ce                	sbb    %ecx,%esi
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 f0                	mov    %esi,%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	d3 ea                	shr    %cl,%edx
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	09 d0                	or     %edx,%eax
  802443:	89 f2                	mov    %esi,%edx
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 f9                	sub    %edi,%ecx
  802452:	19 d6                	sbb    %edx,%esi
  802454:	89 74 24 04          	mov    %esi,0x4(%esp)
  802458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245c:	e9 18 ff ff ff       	jmp    802379 <__umoddi3+0x69>
