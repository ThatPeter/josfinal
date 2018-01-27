
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
  80004f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8000a9:	e8 bb 07 00 00       	call   800869 <close_all>
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
  800122:	68 ca 21 80 00       	push   $0x8021ca
  800127:	6a 23                	push   $0x23
  800129:	68 e7 21 80 00       	push   $0x8021e7
  80012e:	e8 5e 12 00 00       	call   801391 <_panic>

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
  8001a3:	68 ca 21 80 00       	push   $0x8021ca
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 e7 21 80 00       	push   $0x8021e7
  8001af:	e8 dd 11 00 00       	call   801391 <_panic>

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
  8001e5:	68 ca 21 80 00       	push   $0x8021ca
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 e7 21 80 00       	push   $0x8021e7
  8001f1:	e8 9b 11 00 00       	call   801391 <_panic>

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
  800227:	68 ca 21 80 00       	push   $0x8021ca
  80022c:	6a 23                	push   $0x23
  80022e:	68 e7 21 80 00       	push   $0x8021e7
  800233:	e8 59 11 00 00       	call   801391 <_panic>

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
  800269:	68 ca 21 80 00       	push   $0x8021ca
  80026e:	6a 23                	push   $0x23
  800270:	68 e7 21 80 00       	push   $0x8021e7
  800275:	e8 17 11 00 00       	call   801391 <_panic>

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
  8002ab:	68 ca 21 80 00       	push   $0x8021ca
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 e7 21 80 00       	push   $0x8021e7
  8002b7:	e8 d5 10 00 00       	call   801391 <_panic>
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
  8002ed:	68 ca 21 80 00       	push   $0x8021ca
  8002f2:	6a 23                	push   $0x23
  8002f4:	68 e7 21 80 00       	push   $0x8021e7
  8002f9:	e8 93 10 00 00       	call   801391 <_panic>

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
  800351:	68 ca 21 80 00       	push   $0x8021ca
  800356:	6a 23                	push   $0x23
  800358:	68 e7 21 80 00       	push   $0x8021e7
  80035d:	e8 2f 10 00 00       	call   801391 <_panic>

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
  8003d0:	68 f5 21 80 00       	push   $0x8021f5
  8003d5:	6a 1e                	push   $0x1e
  8003d7:	68 05 22 80 00       	push   $0x802205
  8003dc:	e8 b0 0f 00 00       	call   801391 <_panic>
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
  8003fa:	68 10 22 80 00       	push   $0x802210
  8003ff:	6a 2c                	push   $0x2c
  800401:	68 05 22 80 00       	push   $0x802205
  800406:	e8 86 0f 00 00       	call   801391 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80040b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800411:	83 ec 04             	sub    $0x4,%esp
  800414:	68 00 10 00 00       	push   $0x1000
  800419:	53                   	push   %ebx
  80041a:	68 00 f0 7f 00       	push   $0x7ff000
  80041f:	e8 c5 17 00 00       	call   801be9 <memcpy>

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
  800442:	68 10 22 80 00       	push   $0x802210
  800447:	6a 33                	push   $0x33
  800449:	68 05 22 80 00       	push   $0x802205
  80044e:	e8 3e 0f 00 00       	call   801391 <_panic>
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
  80046a:	68 10 22 80 00       	push   $0x802210
  80046f:	6a 37                	push   $0x37
  800471:	68 05 22 80 00       	push   $0x802205
  800476:	e8 16 0f 00 00       	call   801391 <_panic>
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
  80048e:	e8 a3 18 00 00       	call   801d36 <set_pgfault_handler>
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
  8004a7:	68 29 22 80 00       	push   $0x802229
  8004ac:	68 84 00 00 00       	push   $0x84
  8004b1:	68 05 22 80 00       	push   $0x802205
  8004b6:	e8 d6 0e 00 00       	call   801391 <_panic>
  8004bb:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c1:	75 24                	jne    8004e7 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004c3:	e8 73 fc ff ff       	call   80013b <sys_getenvid>
  8004c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004cd:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8004d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004d8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e2:	e9 64 01 00 00       	jmp    80064b <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004e7:	83 ec 04             	sub    $0x4,%esp
  8004ea:	6a 07                	push   $0x7
  8004ec:	68 00 f0 bf ee       	push   $0xeebff000
  8004f1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004f4:	e8 80 fc ff ff       	call   800179 <sys_page_alloc>
  8004f9:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8004fc:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800501:	89 d8                	mov    %ebx,%eax
  800503:	c1 e8 16             	shr    $0x16,%eax
  800506:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80050d:	a8 01                	test   $0x1,%al
  80050f:	0f 84 fc 00 00 00    	je     800611 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800515:	89 d8                	mov    %ebx,%eax
  800517:	c1 e8 0c             	shr    $0xc,%eax
  80051a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800521:	f6 c2 01             	test   $0x1,%dl
  800524:	0f 84 e7 00 00 00    	je     800611 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80052a:	89 c6                	mov    %eax,%esi
  80052c:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80052f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800536:	f6 c6 04             	test   $0x4,%dh
  800539:	74 39                	je     800574 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80053b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800542:	83 ec 0c             	sub    $0xc,%esp
  800545:	25 07 0e 00 00       	and    $0xe07,%eax
  80054a:	50                   	push   %eax
  80054b:	56                   	push   %esi
  80054c:	57                   	push   %edi
  80054d:	56                   	push   %esi
  80054e:	6a 00                	push   $0x0
  800550:	e8 67 fc ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  800555:	83 c4 20             	add    $0x20,%esp
  800558:	85 c0                	test   %eax,%eax
  80055a:	0f 89 b1 00 00 00    	jns    800611 <fork+0x191>
		    	panic("sys page map fault %e");
  800560:	83 ec 04             	sub    $0x4,%esp
  800563:	68 37 22 80 00       	push   $0x802237
  800568:	6a 54                	push   $0x54
  80056a:	68 05 22 80 00       	push   $0x802205
  80056f:	e8 1d 0e 00 00       	call   801391 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800574:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80057b:	f6 c2 02             	test   $0x2,%dl
  80057e:	75 0c                	jne    80058c <fork+0x10c>
  800580:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800587:	f6 c4 08             	test   $0x8,%ah
  80058a:	74 5b                	je     8005e7 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80058c:	83 ec 0c             	sub    $0xc,%esp
  80058f:	68 05 08 00 00       	push   $0x805
  800594:	56                   	push   %esi
  800595:	57                   	push   %edi
  800596:	56                   	push   %esi
  800597:	6a 00                	push   $0x0
  800599:	e8 1e fc ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  80059e:	83 c4 20             	add    $0x20,%esp
  8005a1:	85 c0                	test   %eax,%eax
  8005a3:	79 14                	jns    8005b9 <fork+0x139>
		    	panic("sys page map fault %e");
  8005a5:	83 ec 04             	sub    $0x4,%esp
  8005a8:	68 37 22 80 00       	push   $0x802237
  8005ad:	6a 5b                	push   $0x5b
  8005af:	68 05 22 80 00       	push   $0x802205
  8005b4:	e8 d8 0d 00 00       	call   801391 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	68 05 08 00 00       	push   $0x805
  8005c1:	56                   	push   %esi
  8005c2:	6a 00                	push   $0x0
  8005c4:	56                   	push   %esi
  8005c5:	6a 00                	push   $0x0
  8005c7:	e8 f0 fb ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  8005cc:	83 c4 20             	add    $0x20,%esp
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	79 3e                	jns    800611 <fork+0x191>
		    	panic("sys page map fault %e");
  8005d3:	83 ec 04             	sub    $0x4,%esp
  8005d6:	68 37 22 80 00       	push   $0x802237
  8005db:	6a 5f                	push   $0x5f
  8005dd:	68 05 22 80 00       	push   $0x802205
  8005e2:	e8 aa 0d 00 00       	call   801391 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	6a 05                	push   $0x5
  8005ec:	56                   	push   %esi
  8005ed:	57                   	push   %edi
  8005ee:	56                   	push   %esi
  8005ef:	6a 00                	push   $0x0
  8005f1:	e8 c6 fb ff ff       	call   8001bc <sys_page_map>
		if (r < 0) {
  8005f6:	83 c4 20             	add    $0x20,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	79 14                	jns    800611 <fork+0x191>
		    	panic("sys page map fault %e");
  8005fd:	83 ec 04             	sub    $0x4,%esp
  800600:	68 37 22 80 00       	push   $0x802237
  800605:	6a 64                	push   $0x64
  800607:	68 05 22 80 00       	push   $0x802205
  80060c:	e8 80 0d 00 00       	call   801391 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800611:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800617:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80061d:	0f 85 de fe ff ff    	jne    800501 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800623:	a1 04 40 80 00       	mov    0x804004,%eax
  800628:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	50                   	push   %eax
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800635:	57                   	push   %edi
  800636:	e8 89 fc ff ff       	call   8002c4 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	6a 02                	push   $0x2
  800640:	57                   	push   %edi
  800641:	e8 fa fb ff ff       	call   800240 <sys_env_set_status>
	
	return envid;
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80064b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064e:	5b                   	pop    %ebx
  80064f:	5e                   	pop    %esi
  800650:	5f                   	pop    %edi
  800651:	5d                   	pop    %ebp
  800652:	c3                   	ret    

00800653 <sfork>:

envid_t
sfork(void)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800656:	b8 00 00 00 00       	mov    $0x0,%eax
  80065b:	5d                   	pop    %ebp
  80065c:	c3                   	ret    

0080065d <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80065d:	55                   	push   %ebp
  80065e:	89 e5                	mov    %esp,%ebp
  800660:	56                   	push   %esi
  800661:	53                   	push   %ebx
  800662:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800665:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	68 50 22 80 00       	push   $0x802250
  800674:	e8 f1 0d 00 00       	call   80146a <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800679:	c7 04 24 83 00 80 00 	movl   $0x800083,(%esp)
  800680:	e8 e5 fc ff ff       	call   80036a <sys_thread_create>
  800685:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800687:	83 c4 08             	add    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	68 50 22 80 00       	push   $0x802250
  800690:	e8 d5 0d 00 00       	call   80146a <cprintf>
	return id;
}
  800695:	89 f0                	mov    %esi,%eax
  800697:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80069a:	5b                   	pop    %ebx
  80069b:	5e                   	pop    %esi
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a4:	05 00 00 00 30       	add    $0x30000000,%eax
  8006a9:	c1 e8 0c             	shr    $0xc,%eax
}
  8006ac:	5d                   	pop    %ebp
  8006ad:	c3                   	ret    

008006ae <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006ae:	55                   	push   %ebp
  8006af:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b4:	05 00 00 00 30       	add    $0x30000000,%eax
  8006b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006be:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006c3:	5d                   	pop    %ebp
  8006c4:	c3                   	ret    

008006c5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006cb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006d0:	89 c2                	mov    %eax,%edx
  8006d2:	c1 ea 16             	shr    $0x16,%edx
  8006d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006dc:	f6 c2 01             	test   $0x1,%dl
  8006df:	74 11                	je     8006f2 <fd_alloc+0x2d>
  8006e1:	89 c2                	mov    %eax,%edx
  8006e3:	c1 ea 0c             	shr    $0xc,%edx
  8006e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006ed:	f6 c2 01             	test   $0x1,%dl
  8006f0:	75 09                	jne    8006fb <fd_alloc+0x36>
			*fd_store = fd;
  8006f2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8006f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f9:	eb 17                	jmp    800712 <fd_alloc+0x4d>
  8006fb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800700:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800705:	75 c9                	jne    8006d0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800707:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80070d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80071a:	83 f8 1f             	cmp    $0x1f,%eax
  80071d:	77 36                	ja     800755 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80071f:	c1 e0 0c             	shl    $0xc,%eax
  800722:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800727:	89 c2                	mov    %eax,%edx
  800729:	c1 ea 16             	shr    $0x16,%edx
  80072c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800733:	f6 c2 01             	test   $0x1,%dl
  800736:	74 24                	je     80075c <fd_lookup+0x48>
  800738:	89 c2                	mov    %eax,%edx
  80073a:	c1 ea 0c             	shr    $0xc,%edx
  80073d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800744:	f6 c2 01             	test   $0x1,%dl
  800747:	74 1a                	je     800763 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800749:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074c:	89 02                	mov    %eax,(%edx)
	return 0;
  80074e:	b8 00 00 00 00       	mov    $0x0,%eax
  800753:	eb 13                	jmp    800768 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800755:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075a:	eb 0c                	jmp    800768 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80075c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800761:	eb 05                	jmp    800768 <fd_lookup+0x54>
  800763:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800773:	ba f0 22 80 00       	mov    $0x8022f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800778:	eb 13                	jmp    80078d <dev_lookup+0x23>
  80077a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80077d:	39 08                	cmp    %ecx,(%eax)
  80077f:	75 0c                	jne    80078d <dev_lookup+0x23>
			*dev = devtab[i];
  800781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800784:	89 01                	mov    %eax,(%ecx)
			return 0;
  800786:	b8 00 00 00 00       	mov    $0x0,%eax
  80078b:	eb 2e                	jmp    8007bb <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80078d:	8b 02                	mov    (%edx),%eax
  80078f:	85 c0                	test   %eax,%eax
  800791:	75 e7                	jne    80077a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800793:	a1 04 40 80 00       	mov    0x804004,%eax
  800798:	8b 40 7c             	mov    0x7c(%eax),%eax
  80079b:	83 ec 04             	sub    $0x4,%esp
  80079e:	51                   	push   %ecx
  80079f:	50                   	push   %eax
  8007a0:	68 74 22 80 00       	push   $0x802274
  8007a5:	e8 c0 0c 00 00       	call   80146a <cprintf>
	*dev = 0;
  8007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	56                   	push   %esi
  8007c1:	53                   	push   %ebx
  8007c2:	83 ec 10             	sub    $0x10,%esp
  8007c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007ce:	50                   	push   %eax
  8007cf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007d5:	c1 e8 0c             	shr    $0xc,%eax
  8007d8:	50                   	push   %eax
  8007d9:	e8 36 ff ff ff       	call   800714 <fd_lookup>
  8007de:	83 c4 08             	add    $0x8,%esp
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	78 05                	js     8007ea <fd_close+0x2d>
	    || fd != fd2)
  8007e5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007e8:	74 0c                	je     8007f6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8007ea:	84 db                	test   %bl,%bl
  8007ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f1:	0f 44 c2             	cmove  %edx,%eax
  8007f4:	eb 41                	jmp    800837 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8007f6:	83 ec 08             	sub    $0x8,%esp
  8007f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fc:	50                   	push   %eax
  8007fd:	ff 36                	pushl  (%esi)
  8007ff:	e8 66 ff ff ff       	call   80076a <dev_lookup>
  800804:	89 c3                	mov    %eax,%ebx
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 1a                	js     800827 <fd_close+0x6a>
		if (dev->dev_close)
  80080d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800810:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800813:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800818:	85 c0                	test   %eax,%eax
  80081a:	74 0b                	je     800827 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80081c:	83 ec 0c             	sub    $0xc,%esp
  80081f:	56                   	push   %esi
  800820:	ff d0                	call   *%eax
  800822:	89 c3                	mov    %eax,%ebx
  800824:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800827:	83 ec 08             	sub    $0x8,%esp
  80082a:	56                   	push   %esi
  80082b:	6a 00                	push   $0x0
  80082d:	e8 cc f9 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	89 d8                	mov    %ebx,%eax
}
  800837:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800844:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 c4 fe ff ff       	call   800714 <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	85 c0                	test   %eax,%eax
  800855:	78 10                	js     800867 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	6a 01                	push   $0x1
  80085c:	ff 75 f4             	pushl  -0xc(%ebp)
  80085f:	e8 59 ff ff ff       	call   8007bd <fd_close>
  800864:	83 c4 10             	add    $0x10,%esp
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <close_all>:

void
close_all(void)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800870:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800875:	83 ec 0c             	sub    $0xc,%esp
  800878:	53                   	push   %ebx
  800879:	e8 c0 ff ff ff       	call   80083e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80087e:	83 c3 01             	add    $0x1,%ebx
  800881:	83 c4 10             	add    $0x10,%esp
  800884:	83 fb 20             	cmp    $0x20,%ebx
  800887:	75 ec                	jne    800875 <close_all+0xc>
		close(i);
}
  800889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	57                   	push   %edi
  800892:	56                   	push   %esi
  800893:	53                   	push   %ebx
  800894:	83 ec 2c             	sub    $0x2c,%esp
  800897:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80089a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80089d:	50                   	push   %eax
  80089e:	ff 75 08             	pushl  0x8(%ebp)
  8008a1:	e8 6e fe ff ff       	call   800714 <fd_lookup>
  8008a6:	83 c4 08             	add    $0x8,%esp
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	0f 88 c1 00 00 00    	js     800972 <dup+0xe4>
		return r;
	close(newfdnum);
  8008b1:	83 ec 0c             	sub    $0xc,%esp
  8008b4:	56                   	push   %esi
  8008b5:	e8 84 ff ff ff       	call   80083e <close>

	newfd = INDEX2FD(newfdnum);
  8008ba:	89 f3                	mov    %esi,%ebx
  8008bc:	c1 e3 0c             	shl    $0xc,%ebx
  8008bf:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008c5:	83 c4 04             	add    $0x4,%esp
  8008c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008cb:	e8 de fd ff ff       	call   8006ae <fd2data>
  8008d0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008d2:	89 1c 24             	mov    %ebx,(%esp)
  8008d5:	e8 d4 fd ff ff       	call   8006ae <fd2data>
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008e0:	89 f8                	mov    %edi,%eax
  8008e2:	c1 e8 16             	shr    $0x16,%eax
  8008e5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008ec:	a8 01                	test   $0x1,%al
  8008ee:	74 37                	je     800927 <dup+0x99>
  8008f0:	89 f8                	mov    %edi,%eax
  8008f2:	c1 e8 0c             	shr    $0xc,%eax
  8008f5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8008fc:	f6 c2 01             	test   $0x1,%dl
  8008ff:	74 26                	je     800927 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800901:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	25 07 0e 00 00       	and    $0xe07,%eax
  800910:	50                   	push   %eax
  800911:	ff 75 d4             	pushl  -0x2c(%ebp)
  800914:	6a 00                	push   $0x0
  800916:	57                   	push   %edi
  800917:	6a 00                	push   $0x0
  800919:	e8 9e f8 ff ff       	call   8001bc <sys_page_map>
  80091e:	89 c7                	mov    %eax,%edi
  800920:	83 c4 20             	add    $0x20,%esp
  800923:	85 c0                	test   %eax,%eax
  800925:	78 2e                	js     800955 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800927:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80092a:	89 d0                	mov    %edx,%eax
  80092c:	c1 e8 0c             	shr    $0xc,%eax
  80092f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800936:	83 ec 0c             	sub    $0xc,%esp
  800939:	25 07 0e 00 00       	and    $0xe07,%eax
  80093e:	50                   	push   %eax
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	52                   	push   %edx
  800943:	6a 00                	push   $0x0
  800945:	e8 72 f8 ff ff       	call   8001bc <sys_page_map>
  80094a:	89 c7                	mov    %eax,%edi
  80094c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80094f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800951:	85 ff                	test   %edi,%edi
  800953:	79 1d                	jns    800972 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800955:	83 ec 08             	sub    $0x8,%esp
  800958:	53                   	push   %ebx
  800959:	6a 00                	push   $0x0
  80095b:	e8 9e f8 ff ff       	call   8001fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  800960:	83 c4 08             	add    $0x8,%esp
  800963:	ff 75 d4             	pushl  -0x2c(%ebp)
  800966:	6a 00                	push   $0x0
  800968:	e8 91 f8 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  80096d:	83 c4 10             	add    $0x10,%esp
  800970:	89 f8                	mov    %edi,%eax
}
  800972:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	83 ec 14             	sub    $0x14,%esp
  800981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800984:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800987:	50                   	push   %eax
  800988:	53                   	push   %ebx
  800989:	e8 86 fd ff ff       	call   800714 <fd_lookup>
  80098e:	83 c4 08             	add    $0x8,%esp
  800991:	89 c2                	mov    %eax,%edx
  800993:	85 c0                	test   %eax,%eax
  800995:	78 6d                	js     800a04 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800997:	83 ec 08             	sub    $0x8,%esp
  80099a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80099d:	50                   	push   %eax
  80099e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a1:	ff 30                	pushl  (%eax)
  8009a3:	e8 c2 fd ff ff       	call   80076a <dev_lookup>
  8009a8:	83 c4 10             	add    $0x10,%esp
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	78 4c                	js     8009fb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009b2:	8b 42 08             	mov    0x8(%edx),%eax
  8009b5:	83 e0 03             	and    $0x3,%eax
  8009b8:	83 f8 01             	cmp    $0x1,%eax
  8009bb:	75 21                	jne    8009de <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c2:	8b 40 7c             	mov    0x7c(%eax),%eax
  8009c5:	83 ec 04             	sub    $0x4,%esp
  8009c8:	53                   	push   %ebx
  8009c9:	50                   	push   %eax
  8009ca:	68 b5 22 80 00       	push   $0x8022b5
  8009cf:	e8 96 0a 00 00       	call   80146a <cprintf>
		return -E_INVAL;
  8009d4:	83 c4 10             	add    $0x10,%esp
  8009d7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009dc:	eb 26                	jmp    800a04 <read+0x8a>
	}
	if (!dev->dev_read)
  8009de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e1:	8b 40 08             	mov    0x8(%eax),%eax
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	74 17                	je     8009ff <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009e8:	83 ec 04             	sub    $0x4,%esp
  8009eb:	ff 75 10             	pushl  0x10(%ebp)
  8009ee:	ff 75 0c             	pushl  0xc(%ebp)
  8009f1:	52                   	push   %edx
  8009f2:	ff d0                	call   *%eax
  8009f4:	89 c2                	mov    %eax,%edx
  8009f6:	83 c4 10             	add    $0x10,%esp
  8009f9:	eb 09                	jmp    800a04 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009fb:	89 c2                	mov    %eax,%edx
  8009fd:	eb 05                	jmp    800a04 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8009ff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	57                   	push   %edi
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	83 ec 0c             	sub    $0xc,%esp
  800a14:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a17:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a1f:	eb 21                	jmp    800a42 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a21:	83 ec 04             	sub    $0x4,%esp
  800a24:	89 f0                	mov    %esi,%eax
  800a26:	29 d8                	sub    %ebx,%eax
  800a28:	50                   	push   %eax
  800a29:	89 d8                	mov    %ebx,%eax
  800a2b:	03 45 0c             	add    0xc(%ebp),%eax
  800a2e:	50                   	push   %eax
  800a2f:	57                   	push   %edi
  800a30:	e8 45 ff ff ff       	call   80097a <read>
		if (m < 0)
  800a35:	83 c4 10             	add    $0x10,%esp
  800a38:	85 c0                	test   %eax,%eax
  800a3a:	78 10                	js     800a4c <readn+0x41>
			return m;
		if (m == 0)
  800a3c:	85 c0                	test   %eax,%eax
  800a3e:	74 0a                	je     800a4a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a40:	01 c3                	add    %eax,%ebx
  800a42:	39 f3                	cmp    %esi,%ebx
  800a44:	72 db                	jb     800a21 <readn+0x16>
  800a46:	89 d8                	mov    %ebx,%eax
  800a48:	eb 02                	jmp    800a4c <readn+0x41>
  800a4a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	53                   	push   %ebx
  800a58:	83 ec 14             	sub    $0x14,%esp
  800a5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a61:	50                   	push   %eax
  800a62:	53                   	push   %ebx
  800a63:	e8 ac fc ff ff       	call   800714 <fd_lookup>
  800a68:	83 c4 08             	add    $0x8,%esp
  800a6b:	89 c2                	mov    %eax,%edx
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	78 68                	js     800ad9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a71:	83 ec 08             	sub    $0x8,%esp
  800a74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a77:	50                   	push   %eax
  800a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a7b:	ff 30                	pushl  (%eax)
  800a7d:	e8 e8 fc ff ff       	call   80076a <dev_lookup>
  800a82:	83 c4 10             	add    $0x10,%esp
  800a85:	85 c0                	test   %eax,%eax
  800a87:	78 47                	js     800ad0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a90:	75 21                	jne    800ab3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a92:	a1 04 40 80 00       	mov    0x804004,%eax
  800a97:	8b 40 7c             	mov    0x7c(%eax),%eax
  800a9a:	83 ec 04             	sub    $0x4,%esp
  800a9d:	53                   	push   %ebx
  800a9e:	50                   	push   %eax
  800a9f:	68 d1 22 80 00       	push   $0x8022d1
  800aa4:	e8 c1 09 00 00       	call   80146a <cprintf>
		return -E_INVAL;
  800aa9:	83 c4 10             	add    $0x10,%esp
  800aac:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ab1:	eb 26                	jmp    800ad9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ab3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ab6:	8b 52 0c             	mov    0xc(%edx),%edx
  800ab9:	85 d2                	test   %edx,%edx
  800abb:	74 17                	je     800ad4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800abd:	83 ec 04             	sub    $0x4,%esp
  800ac0:	ff 75 10             	pushl  0x10(%ebp)
  800ac3:	ff 75 0c             	pushl  0xc(%ebp)
  800ac6:	50                   	push   %eax
  800ac7:	ff d2                	call   *%edx
  800ac9:	89 c2                	mov    %eax,%edx
  800acb:	83 c4 10             	add    $0x10,%esp
  800ace:	eb 09                	jmp    800ad9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ad0:	89 c2                	mov    %eax,%edx
  800ad2:	eb 05                	jmp    800ad9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ad4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ad9:	89 d0                	mov    %edx,%eax
  800adb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ade:	c9                   	leave  
  800adf:	c3                   	ret    

00800ae0 <seek>:

int
seek(int fdnum, off_t offset)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ae6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800ae9:	50                   	push   %eax
  800aea:	ff 75 08             	pushl  0x8(%ebp)
  800aed:	e8 22 fc ff ff       	call   800714 <fd_lookup>
  800af2:	83 c4 08             	add    $0x8,%esp
  800af5:	85 c0                	test   %eax,%eax
  800af7:	78 0e                	js     800b07 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800af9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800afc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aff:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	53                   	push   %ebx
  800b0d:	83 ec 14             	sub    $0x14,%esp
  800b10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b13:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b16:	50                   	push   %eax
  800b17:	53                   	push   %ebx
  800b18:	e8 f7 fb ff ff       	call   800714 <fd_lookup>
  800b1d:	83 c4 08             	add    $0x8,%esp
  800b20:	89 c2                	mov    %eax,%edx
  800b22:	85 c0                	test   %eax,%eax
  800b24:	78 65                	js     800b8b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b26:	83 ec 08             	sub    $0x8,%esp
  800b29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2c:	50                   	push   %eax
  800b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b30:	ff 30                	pushl  (%eax)
  800b32:	e8 33 fc ff ff       	call   80076a <dev_lookup>
  800b37:	83 c4 10             	add    $0x10,%esp
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	78 44                	js     800b82 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b3e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b41:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b45:	75 21                	jne    800b68 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b47:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b4c:	8b 40 7c             	mov    0x7c(%eax),%eax
  800b4f:	83 ec 04             	sub    $0x4,%esp
  800b52:	53                   	push   %ebx
  800b53:	50                   	push   %eax
  800b54:	68 94 22 80 00       	push   $0x802294
  800b59:	e8 0c 09 00 00       	call   80146a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b5e:	83 c4 10             	add    $0x10,%esp
  800b61:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b66:	eb 23                	jmp    800b8b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b68:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b6b:	8b 52 18             	mov    0x18(%edx),%edx
  800b6e:	85 d2                	test   %edx,%edx
  800b70:	74 14                	je     800b86 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b72:	83 ec 08             	sub    $0x8,%esp
  800b75:	ff 75 0c             	pushl  0xc(%ebp)
  800b78:	50                   	push   %eax
  800b79:	ff d2                	call   *%edx
  800b7b:	89 c2                	mov    %eax,%edx
  800b7d:	83 c4 10             	add    $0x10,%esp
  800b80:	eb 09                	jmp    800b8b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b82:	89 c2                	mov    %eax,%edx
  800b84:	eb 05                	jmp    800b8b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b86:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b8b:	89 d0                	mov    %edx,%eax
  800b8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	53                   	push   %ebx
  800b96:	83 ec 14             	sub    $0x14,%esp
  800b99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b9f:	50                   	push   %eax
  800ba0:	ff 75 08             	pushl  0x8(%ebp)
  800ba3:	e8 6c fb ff ff       	call   800714 <fd_lookup>
  800ba8:	83 c4 08             	add    $0x8,%esp
  800bab:	89 c2                	mov    %eax,%edx
  800bad:	85 c0                	test   %eax,%eax
  800baf:	78 58                	js     800c09 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bb1:	83 ec 08             	sub    $0x8,%esp
  800bb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bb7:	50                   	push   %eax
  800bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bbb:	ff 30                	pushl  (%eax)
  800bbd:	e8 a8 fb ff ff       	call   80076a <dev_lookup>
  800bc2:	83 c4 10             	add    $0x10,%esp
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	78 37                	js     800c00 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bcc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bd0:	74 32                	je     800c04 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bd2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800bd5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800bdc:	00 00 00 
	stat->st_isdir = 0;
  800bdf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be6:	00 00 00 
	stat->st_dev = dev;
  800be9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bef:	83 ec 08             	sub    $0x8,%esp
  800bf2:	53                   	push   %ebx
  800bf3:	ff 75 f0             	pushl  -0x10(%ebp)
  800bf6:	ff 50 14             	call   *0x14(%eax)
  800bf9:	89 c2                	mov    %eax,%edx
  800bfb:	83 c4 10             	add    $0x10,%esp
  800bfe:	eb 09                	jmp    800c09 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c00:	89 c2                	mov    %eax,%edx
  800c02:	eb 05                	jmp    800c09 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c04:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c09:	89 d0                	mov    %edx,%eax
  800c0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c15:	83 ec 08             	sub    $0x8,%esp
  800c18:	6a 00                	push   $0x0
  800c1a:	ff 75 08             	pushl  0x8(%ebp)
  800c1d:	e8 e3 01 00 00       	call   800e05 <open>
  800c22:	89 c3                	mov    %eax,%ebx
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	85 c0                	test   %eax,%eax
  800c29:	78 1b                	js     800c46 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c2b:	83 ec 08             	sub    $0x8,%esp
  800c2e:	ff 75 0c             	pushl  0xc(%ebp)
  800c31:	50                   	push   %eax
  800c32:	e8 5b ff ff ff       	call   800b92 <fstat>
  800c37:	89 c6                	mov    %eax,%esi
	close(fd);
  800c39:	89 1c 24             	mov    %ebx,(%esp)
  800c3c:	e8 fd fb ff ff       	call   80083e <close>
	return r;
  800c41:	83 c4 10             	add    $0x10,%esp
  800c44:	89 f0                	mov    %esi,%eax
}
  800c46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	89 c6                	mov    %eax,%esi
  800c54:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c56:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c5d:	75 12                	jne    800c71 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	6a 01                	push   $0x1
  800c64:	e8 39 12 00 00       	call   801ea2 <ipc_find_env>
  800c69:	a3 00 40 80 00       	mov    %eax,0x804000
  800c6e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c71:	6a 07                	push   $0x7
  800c73:	68 00 50 80 00       	push   $0x805000
  800c78:	56                   	push   %esi
  800c79:	ff 35 00 40 80 00    	pushl  0x804000
  800c7f:	e8 bc 11 00 00       	call   801e40 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c84:	83 c4 0c             	add    $0xc,%esp
  800c87:	6a 00                	push   $0x0
  800c89:	53                   	push   %ebx
  800c8a:	6a 00                	push   $0x0
  800c8c:	e8 34 11 00 00       	call   801dc5 <ipc_recv>
}
  800c91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ca4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cac:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800cbb:	e8 8d ff ff ff       	call   800c4d <fsipc>
}
  800cc0:	c9                   	leave  
  800cc1:	c3                   	ret    

00800cc2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	8b 40 0c             	mov    0xc(%eax),%eax
  800cce:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800cd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdd:	e8 6b ff ff ff       	call   800c4d <fsipc>
}
  800ce2:	c9                   	leave  
  800ce3:	c3                   	ret    

00800ce4 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 04             	sub    $0x4,%esp
  800ceb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	8b 40 0c             	mov    0xc(%eax),%eax
  800cf4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800cf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800d03:	e8 45 ff ff ff       	call   800c4d <fsipc>
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	78 2c                	js     800d38 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d0c:	83 ec 08             	sub    $0x8,%esp
  800d0f:	68 00 50 80 00       	push   $0x805000
  800d14:	53                   	push   %ebx
  800d15:	e8 d5 0c 00 00       	call   8019ef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d1a:	a1 80 50 80 00       	mov    0x805080,%eax
  800d1f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d25:	a1 84 50 80 00       	mov    0x805084,%eax
  800d2a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d30:	83 c4 10             	add    $0x10,%esp
  800d33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d3b:	c9                   	leave  
  800d3c:	c3                   	ret    

00800d3d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	83 ec 0c             	sub    $0xc,%esp
  800d43:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	8b 52 0c             	mov    0xc(%edx),%edx
  800d4c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d52:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d57:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d5c:	0f 47 c2             	cmova  %edx,%eax
  800d5f:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d64:	50                   	push   %eax
  800d65:	ff 75 0c             	pushl  0xc(%ebp)
  800d68:	68 08 50 80 00       	push   $0x805008
  800d6d:	e8 0f 0e 00 00       	call   801b81 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d72:	ba 00 00 00 00       	mov    $0x0,%edx
  800d77:	b8 04 00 00 00       	mov    $0x4,%eax
  800d7c:	e8 cc fe ff ff       	call   800c4d <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d81:	c9                   	leave  
  800d82:	c3                   	ret    

00800d83 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	8b 40 0c             	mov    0xc(%eax),%eax
  800d91:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800d96:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800d9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800da1:	b8 03 00 00 00       	mov    $0x3,%eax
  800da6:	e8 a2 fe ff ff       	call   800c4d <fsipc>
  800dab:	89 c3                	mov    %eax,%ebx
  800dad:	85 c0                	test   %eax,%eax
  800daf:	78 4b                	js     800dfc <devfile_read+0x79>
		return r;
	assert(r <= n);
  800db1:	39 c6                	cmp    %eax,%esi
  800db3:	73 16                	jae    800dcb <devfile_read+0x48>
  800db5:	68 00 23 80 00       	push   $0x802300
  800dba:	68 07 23 80 00       	push   $0x802307
  800dbf:	6a 7c                	push   $0x7c
  800dc1:	68 1c 23 80 00       	push   $0x80231c
  800dc6:	e8 c6 05 00 00       	call   801391 <_panic>
	assert(r <= PGSIZE);
  800dcb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800dd0:	7e 16                	jle    800de8 <devfile_read+0x65>
  800dd2:	68 27 23 80 00       	push   $0x802327
  800dd7:	68 07 23 80 00       	push   $0x802307
  800ddc:	6a 7d                	push   $0x7d
  800dde:	68 1c 23 80 00       	push   $0x80231c
  800de3:	e8 a9 05 00 00       	call   801391 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800de8:	83 ec 04             	sub    $0x4,%esp
  800deb:	50                   	push   %eax
  800dec:	68 00 50 80 00       	push   $0x805000
  800df1:	ff 75 0c             	pushl  0xc(%ebp)
  800df4:	e8 88 0d 00 00       	call   801b81 <memmove>
	return r;
  800df9:	83 c4 10             	add    $0x10,%esp
}
  800dfc:	89 d8                	mov    %ebx,%eax
  800dfe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	53                   	push   %ebx
  800e09:	83 ec 20             	sub    $0x20,%esp
  800e0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e0f:	53                   	push   %ebx
  800e10:	e8 a1 0b 00 00       	call   8019b6 <strlen>
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e1d:	7f 67                	jg     800e86 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e25:	50                   	push   %eax
  800e26:	e8 9a f8 ff ff       	call   8006c5 <fd_alloc>
  800e2b:	83 c4 10             	add    $0x10,%esp
		return r;
  800e2e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e30:	85 c0                	test   %eax,%eax
  800e32:	78 57                	js     800e8b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	53                   	push   %ebx
  800e38:	68 00 50 80 00       	push   $0x805000
  800e3d:	e8 ad 0b 00 00       	call   8019ef <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e45:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800e52:	e8 f6 fd ff ff       	call   800c4d <fsipc>
  800e57:	89 c3                	mov    %eax,%ebx
  800e59:	83 c4 10             	add    $0x10,%esp
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	79 14                	jns    800e74 <open+0x6f>
		fd_close(fd, 0);
  800e60:	83 ec 08             	sub    $0x8,%esp
  800e63:	6a 00                	push   $0x0
  800e65:	ff 75 f4             	pushl  -0xc(%ebp)
  800e68:	e8 50 f9 ff ff       	call   8007bd <fd_close>
		return r;
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	89 da                	mov    %ebx,%edx
  800e72:	eb 17                	jmp    800e8b <open+0x86>
	}

	return fd2num(fd);
  800e74:	83 ec 0c             	sub    $0xc,%esp
  800e77:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7a:	e8 1f f8 ff ff       	call   80069e <fd2num>
  800e7f:	89 c2                	mov    %eax,%edx
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	eb 05                	jmp    800e8b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e86:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e8b:	89 d0                	mov    %edx,%eax
  800e8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800e98:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9d:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea2:	e8 a6 fd ff ff       	call   800c4d <fsipc>
}
  800ea7:	c9                   	leave  
  800ea8:	c3                   	ret    

00800ea9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	ff 75 08             	pushl  0x8(%ebp)
  800eb7:	e8 f2 f7 ff ff       	call   8006ae <fd2data>
  800ebc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ebe:	83 c4 08             	add    $0x8,%esp
  800ec1:	68 33 23 80 00       	push   $0x802333
  800ec6:	53                   	push   %ebx
  800ec7:	e8 23 0b 00 00       	call   8019ef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ecc:	8b 46 04             	mov    0x4(%esi),%eax
  800ecf:	2b 06                	sub    (%esi),%eax
  800ed1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ed7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ede:	00 00 00 
	stat->st_dev = &devpipe;
  800ee1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ee8:	30 80 00 
	return 0;
}
  800eeb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	53                   	push   %ebx
  800efb:	83 ec 0c             	sub    $0xc,%esp
  800efe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f01:	53                   	push   %ebx
  800f02:	6a 00                	push   $0x0
  800f04:	e8 f5 f2 ff ff       	call   8001fe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f09:	89 1c 24             	mov    %ebx,(%esp)
  800f0c:	e8 9d f7 ff ff       	call   8006ae <fd2data>
  800f11:	83 c4 08             	add    $0x8,%esp
  800f14:	50                   	push   %eax
  800f15:	6a 00                	push   $0x0
  800f17:	e8 e2 f2 ff ff       	call   8001fe <sys_page_unmap>
}
  800f1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1f:	c9                   	leave  
  800f20:	c3                   	ret    

00800f21 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	57                   	push   %edi
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	83 ec 1c             	sub    $0x1c,%esp
  800f2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f2d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f2f:	a1 04 40 80 00       	mov    0x804004,%eax
  800f34:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	ff 75 e0             	pushl  -0x20(%ebp)
  800f40:	e8 9f 0f 00 00       	call   801ee4 <pageref>
  800f45:	89 c3                	mov    %eax,%ebx
  800f47:	89 3c 24             	mov    %edi,(%esp)
  800f4a:	e8 95 0f 00 00       	call   801ee4 <pageref>
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	39 c3                	cmp    %eax,%ebx
  800f54:	0f 94 c1             	sete   %cl
  800f57:	0f b6 c9             	movzbl %cl,%ecx
  800f5a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f5d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f63:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  800f69:	39 ce                	cmp    %ecx,%esi
  800f6b:	74 1e                	je     800f8b <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800f6d:	39 c3                	cmp    %eax,%ebx
  800f6f:	75 be                	jne    800f2f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f71:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  800f77:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7a:	50                   	push   %eax
  800f7b:	56                   	push   %esi
  800f7c:	68 3a 23 80 00       	push   $0x80233a
  800f81:	e8 e4 04 00 00       	call   80146a <cprintf>
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	eb a4                	jmp    800f2f <_pipeisclosed+0xe>
	}
}
  800f8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 28             	sub    $0x28,%esp
  800f9f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fa2:	56                   	push   %esi
  800fa3:	e8 06 f7 ff ff       	call   8006ae <fd2data>
  800fa8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb2:	eb 4b                	jmp    800fff <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fb4:	89 da                	mov    %ebx,%edx
  800fb6:	89 f0                	mov    %esi,%eax
  800fb8:	e8 64 ff ff ff       	call   800f21 <_pipeisclosed>
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	75 48                	jne    801009 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fc1:	e8 94 f1 ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fc6:	8b 43 04             	mov    0x4(%ebx),%eax
  800fc9:	8b 0b                	mov    (%ebx),%ecx
  800fcb:	8d 51 20             	lea    0x20(%ecx),%edx
  800fce:	39 d0                	cmp    %edx,%eax
  800fd0:	73 e2                	jae    800fb4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fd9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fdc:	89 c2                	mov    %eax,%edx
  800fde:	c1 fa 1f             	sar    $0x1f,%edx
  800fe1:	89 d1                	mov    %edx,%ecx
  800fe3:	c1 e9 1b             	shr    $0x1b,%ecx
  800fe6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800fe9:	83 e2 1f             	and    $0x1f,%edx
  800fec:	29 ca                	sub    %ecx,%edx
  800fee:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ff2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ff6:	83 c0 01             	add    $0x1,%eax
  800ff9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ffc:	83 c7 01             	add    $0x1,%edi
  800fff:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801002:	75 c2                	jne    800fc6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801004:	8b 45 10             	mov    0x10(%ebp),%eax
  801007:	eb 05                	jmp    80100e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801009:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80100e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	57                   	push   %edi
  80101a:	56                   	push   %esi
  80101b:	53                   	push   %ebx
  80101c:	83 ec 18             	sub    $0x18,%esp
  80101f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801022:	57                   	push   %edi
  801023:	e8 86 f6 ff ff       	call   8006ae <fd2data>
  801028:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80102a:	83 c4 10             	add    $0x10,%esp
  80102d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801032:	eb 3d                	jmp    801071 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801034:	85 db                	test   %ebx,%ebx
  801036:	74 04                	je     80103c <devpipe_read+0x26>
				return i;
  801038:	89 d8                	mov    %ebx,%eax
  80103a:	eb 44                	jmp    801080 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80103c:	89 f2                	mov    %esi,%edx
  80103e:	89 f8                	mov    %edi,%eax
  801040:	e8 dc fe ff ff       	call   800f21 <_pipeisclosed>
  801045:	85 c0                	test   %eax,%eax
  801047:	75 32                	jne    80107b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801049:	e8 0c f1 ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80104e:	8b 06                	mov    (%esi),%eax
  801050:	3b 46 04             	cmp    0x4(%esi),%eax
  801053:	74 df                	je     801034 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801055:	99                   	cltd   
  801056:	c1 ea 1b             	shr    $0x1b,%edx
  801059:	01 d0                	add    %edx,%eax
  80105b:	83 e0 1f             	and    $0x1f,%eax
  80105e:	29 d0                	sub    %edx,%eax
  801060:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801065:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801068:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80106b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80106e:	83 c3 01             	add    $0x1,%ebx
  801071:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801074:	75 d8                	jne    80104e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801076:	8b 45 10             	mov    0x10(%ebp),%eax
  801079:	eb 05                	jmp    801080 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80107b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	56                   	push   %esi
  80108c:	53                   	push   %ebx
  80108d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801090:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801093:	50                   	push   %eax
  801094:	e8 2c f6 ff ff       	call   8006c5 <fd_alloc>
  801099:	83 c4 10             	add    $0x10,%esp
  80109c:	89 c2                	mov    %eax,%edx
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	0f 88 2c 01 00 00    	js     8011d2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	68 07 04 00 00       	push   $0x407
  8010ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b1:	6a 00                	push   $0x0
  8010b3:	e8 c1 f0 ff ff       	call   800179 <sys_page_alloc>
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	89 c2                	mov    %eax,%edx
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	0f 88 0d 01 00 00    	js     8011d2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010cb:	50                   	push   %eax
  8010cc:	e8 f4 f5 ff ff       	call   8006c5 <fd_alloc>
  8010d1:	89 c3                	mov    %eax,%ebx
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	0f 88 e2 00 00 00    	js     8011c0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010de:	83 ec 04             	sub    $0x4,%esp
  8010e1:	68 07 04 00 00       	push   $0x407
  8010e6:	ff 75 f0             	pushl  -0x10(%ebp)
  8010e9:	6a 00                	push   $0x0
  8010eb:	e8 89 f0 ff ff       	call   800179 <sys_page_alloc>
  8010f0:	89 c3                	mov    %eax,%ebx
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	0f 88 c3 00 00 00    	js     8011c0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8010fd:	83 ec 0c             	sub    $0xc,%esp
  801100:	ff 75 f4             	pushl  -0xc(%ebp)
  801103:	e8 a6 f5 ff ff       	call   8006ae <fd2data>
  801108:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80110a:	83 c4 0c             	add    $0xc,%esp
  80110d:	68 07 04 00 00       	push   $0x407
  801112:	50                   	push   %eax
  801113:	6a 00                	push   $0x0
  801115:	e8 5f f0 ff ff       	call   800179 <sys_page_alloc>
  80111a:	89 c3                	mov    %eax,%ebx
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	0f 88 89 00 00 00    	js     8011b0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	ff 75 f0             	pushl  -0x10(%ebp)
  80112d:	e8 7c f5 ff ff       	call   8006ae <fd2data>
  801132:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801139:	50                   	push   %eax
  80113a:	6a 00                	push   $0x0
  80113c:	56                   	push   %esi
  80113d:	6a 00                	push   $0x0
  80113f:	e8 78 f0 ff ff       	call   8001bc <sys_page_map>
  801144:	89 c3                	mov    %eax,%ebx
  801146:	83 c4 20             	add    $0x20,%esp
  801149:	85 c0                	test   %eax,%eax
  80114b:	78 55                	js     8011a2 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80114d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801153:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801156:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801162:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801168:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80116d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801170:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801177:	83 ec 0c             	sub    $0xc,%esp
  80117a:	ff 75 f4             	pushl  -0xc(%ebp)
  80117d:	e8 1c f5 ff ff       	call   80069e <fd2num>
  801182:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801185:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801187:	83 c4 04             	add    $0x4,%esp
  80118a:	ff 75 f0             	pushl  -0x10(%ebp)
  80118d:	e8 0c f5 ff ff       	call   80069e <fd2num>
  801192:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801195:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801198:	83 c4 10             	add    $0x10,%esp
  80119b:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a0:	eb 30                	jmp    8011d2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011a2:	83 ec 08             	sub    $0x8,%esp
  8011a5:	56                   	push   %esi
  8011a6:	6a 00                	push   $0x0
  8011a8:	e8 51 f0 ff ff       	call   8001fe <sys_page_unmap>
  8011ad:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	ff 75 f0             	pushl  -0x10(%ebp)
  8011b6:	6a 00                	push   $0x0
  8011b8:	e8 41 f0 ff ff       	call   8001fe <sys_page_unmap>
  8011bd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8011c6:	6a 00                	push   $0x0
  8011c8:	e8 31 f0 ff ff       	call   8001fe <sys_page_unmap>
  8011cd:	83 c4 10             	add    $0x10,%esp
  8011d0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011d2:	89 d0                	mov    %edx,%eax
  8011d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e4:	50                   	push   %eax
  8011e5:	ff 75 08             	pushl  0x8(%ebp)
  8011e8:	e8 27 f5 ff ff       	call   800714 <fd_lookup>
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	78 18                	js     80120c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011f4:	83 ec 0c             	sub    $0xc,%esp
  8011f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8011fa:	e8 af f4 ff ff       	call   8006ae <fd2data>
	return _pipeisclosed(fd, p);
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801204:	e8 18 fd ff ff       	call   800f21 <_pipeisclosed>
  801209:	83 c4 10             	add    $0x10,%esp
}
  80120c:	c9                   	leave  
  80120d:	c3                   	ret    

0080120e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
  801216:	5d                   	pop    %ebp
  801217:	c3                   	ret    

00801218 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80121e:	68 52 23 80 00       	push   $0x802352
  801223:	ff 75 0c             	pushl  0xc(%ebp)
  801226:	e8 c4 07 00 00       	call   8019ef <strcpy>
	return 0;
}
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	57                   	push   %edi
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
  801238:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80123e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801243:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801249:	eb 2d                	jmp    801278 <devcons_write+0x46>
		m = n - tot;
  80124b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80124e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801250:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801253:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801258:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80125b:	83 ec 04             	sub    $0x4,%esp
  80125e:	53                   	push   %ebx
  80125f:	03 45 0c             	add    0xc(%ebp),%eax
  801262:	50                   	push   %eax
  801263:	57                   	push   %edi
  801264:	e8 18 09 00 00       	call   801b81 <memmove>
		sys_cputs(buf, m);
  801269:	83 c4 08             	add    $0x8,%esp
  80126c:	53                   	push   %ebx
  80126d:	57                   	push   %edi
  80126e:	e8 4a ee ff ff       	call   8000bd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801273:	01 de                	add    %ebx,%esi
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	89 f0                	mov    %esi,%eax
  80127a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80127d:	72 cc                	jb     80124b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80127f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801282:	5b                   	pop    %ebx
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801292:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801296:	74 2a                	je     8012c2 <devcons_read+0x3b>
  801298:	eb 05                	jmp    80129f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80129a:	e8 bb ee ff ff       	call   80015a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80129f:	e8 37 ee ff ff       	call   8000db <sys_cgetc>
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	74 f2                	je     80129a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 16                	js     8012c2 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012ac:	83 f8 04             	cmp    $0x4,%eax
  8012af:	74 0c                	je     8012bd <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b4:	88 02                	mov    %al,(%edx)
	return 1;
  8012b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012bb:	eb 05                	jmp    8012c2 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012c2:	c9                   	leave  
  8012c3:	c3                   	ret    

008012c4 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cd:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012d0:	6a 01                	push   $0x1
  8012d2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012d5:	50                   	push   %eax
  8012d6:	e8 e2 ed ff ff       	call   8000bd <sys_cputs>
}
  8012db:	83 c4 10             	add    $0x10,%esp
  8012de:	c9                   	leave  
  8012df:	c3                   	ret    

008012e0 <getchar>:

int
getchar(void)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012e6:	6a 01                	push   $0x1
  8012e8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	6a 00                	push   $0x0
  8012ee:	e8 87 f6 ff ff       	call   80097a <read>
	if (r < 0)
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 0f                	js     801309 <getchar+0x29>
		return r;
	if (r < 1)
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	7e 06                	jle    801304 <getchar+0x24>
		return -E_EOF;
	return c;
  8012fe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801302:	eb 05                	jmp    801309 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801304:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	ff 75 08             	pushl  0x8(%ebp)
  801318:	e8 f7 f3 ff ff       	call   800714 <fd_lookup>
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 11                	js     801335 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801324:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801327:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80132d:	39 10                	cmp    %edx,(%eax)
  80132f:	0f 94 c0             	sete   %al
  801332:	0f b6 c0             	movzbl %al,%eax
}
  801335:	c9                   	leave  
  801336:	c3                   	ret    

00801337 <opencons>:

int
opencons(void)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80133d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	e8 7f f3 ff ff       	call   8006c5 <fd_alloc>
  801346:	83 c4 10             	add    $0x10,%esp
		return r;
  801349:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 3e                	js     80138d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80134f:	83 ec 04             	sub    $0x4,%esp
  801352:	68 07 04 00 00       	push   $0x407
  801357:	ff 75 f4             	pushl  -0xc(%ebp)
  80135a:	6a 00                	push   $0x0
  80135c:	e8 18 ee ff ff       	call   800179 <sys_page_alloc>
  801361:	83 c4 10             	add    $0x10,%esp
		return r;
  801364:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801366:	85 c0                	test   %eax,%eax
  801368:	78 23                	js     80138d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80136a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801370:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801373:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801375:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801378:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80137f:	83 ec 0c             	sub    $0xc,%esp
  801382:	50                   	push   %eax
  801383:	e8 16 f3 ff ff       	call   80069e <fd2num>
  801388:	89 c2                	mov    %eax,%edx
  80138a:	83 c4 10             	add    $0x10,%esp
}
  80138d:	89 d0                	mov    %edx,%eax
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	56                   	push   %esi
  801395:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801396:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801399:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80139f:	e8 97 ed ff ff       	call   80013b <sys_getenvid>
  8013a4:	83 ec 0c             	sub    $0xc,%esp
  8013a7:	ff 75 0c             	pushl  0xc(%ebp)
  8013aa:	ff 75 08             	pushl  0x8(%ebp)
  8013ad:	56                   	push   %esi
  8013ae:	50                   	push   %eax
  8013af:	68 60 23 80 00       	push   $0x802360
  8013b4:	e8 b1 00 00 00       	call   80146a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013b9:	83 c4 18             	add    $0x18,%esp
  8013bc:	53                   	push   %ebx
  8013bd:	ff 75 10             	pushl  0x10(%ebp)
  8013c0:	e8 54 00 00 00       	call   801419 <vcprintf>
	cprintf("\n");
  8013c5:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  8013cc:	e8 99 00 00 00       	call   80146a <cprintf>
  8013d1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013d4:	cc                   	int3   
  8013d5:	eb fd                	jmp    8013d4 <_panic+0x43>

008013d7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	53                   	push   %ebx
  8013db:	83 ec 04             	sub    $0x4,%esp
  8013de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013e1:	8b 13                	mov    (%ebx),%edx
  8013e3:	8d 42 01             	lea    0x1(%edx),%eax
  8013e6:	89 03                	mov    %eax,(%ebx)
  8013e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013eb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013f4:	75 1a                	jne    801410 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	68 ff 00 00 00       	push   $0xff
  8013fe:	8d 43 08             	lea    0x8(%ebx),%eax
  801401:	50                   	push   %eax
  801402:	e8 b6 ec ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  801407:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80140d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801410:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801414:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801417:	c9                   	leave  
  801418:	c3                   	ret    

00801419 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801419:	55                   	push   %ebp
  80141a:	89 e5                	mov    %esp,%ebp
  80141c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801422:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801429:	00 00 00 
	b.cnt = 0;
  80142c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801433:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801436:	ff 75 0c             	pushl  0xc(%ebp)
  801439:	ff 75 08             	pushl  0x8(%ebp)
  80143c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801442:	50                   	push   %eax
  801443:	68 d7 13 80 00       	push   $0x8013d7
  801448:	e8 54 01 00 00       	call   8015a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80144d:	83 c4 08             	add    $0x8,%esp
  801450:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801456:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	e8 5b ec ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  801462:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801470:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801473:	50                   	push   %eax
  801474:	ff 75 08             	pushl  0x8(%ebp)
  801477:	e8 9d ff ff ff       	call   801419 <vcprintf>
	va_end(ap);

	return cnt;
}
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	57                   	push   %edi
  801482:	56                   	push   %esi
  801483:	53                   	push   %ebx
  801484:	83 ec 1c             	sub    $0x1c,%esp
  801487:	89 c7                	mov    %eax,%edi
  801489:	89 d6                	mov    %edx,%esi
  80148b:	8b 45 08             	mov    0x8(%ebp),%eax
  80148e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801491:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801494:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801497:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80149a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014a2:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014a5:	39 d3                	cmp    %edx,%ebx
  8014a7:	72 05                	jb     8014ae <printnum+0x30>
  8014a9:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014ac:	77 45                	ja     8014f3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014ae:	83 ec 0c             	sub    $0xc,%esp
  8014b1:	ff 75 18             	pushl  0x18(%ebp)
  8014b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b7:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014ba:	53                   	push   %ebx
  8014bb:	ff 75 10             	pushl  0x10(%ebp)
  8014be:	83 ec 08             	sub    $0x8,%esp
  8014c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8014c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8014ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8014cd:	e8 4e 0a 00 00       	call   801f20 <__udivdi3>
  8014d2:	83 c4 18             	add    $0x18,%esp
  8014d5:	52                   	push   %edx
  8014d6:	50                   	push   %eax
  8014d7:	89 f2                	mov    %esi,%edx
  8014d9:	89 f8                	mov    %edi,%eax
  8014db:	e8 9e ff ff ff       	call   80147e <printnum>
  8014e0:	83 c4 20             	add    $0x20,%esp
  8014e3:	eb 18                	jmp    8014fd <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	56                   	push   %esi
  8014e9:	ff 75 18             	pushl  0x18(%ebp)
  8014ec:	ff d7                	call   *%edi
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	eb 03                	jmp    8014f6 <printnum+0x78>
  8014f3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014f6:	83 eb 01             	sub    $0x1,%ebx
  8014f9:	85 db                	test   %ebx,%ebx
  8014fb:	7f e8                	jg     8014e5 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014fd:	83 ec 08             	sub    $0x8,%esp
  801500:	56                   	push   %esi
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	ff 75 e4             	pushl  -0x1c(%ebp)
  801507:	ff 75 e0             	pushl  -0x20(%ebp)
  80150a:	ff 75 dc             	pushl  -0x24(%ebp)
  80150d:	ff 75 d8             	pushl  -0x28(%ebp)
  801510:	e8 3b 0b 00 00       	call   802050 <__umoddi3>
  801515:	83 c4 14             	add    $0x14,%esp
  801518:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  80151f:	50                   	push   %eax
  801520:	ff d7                	call   *%edi
}
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801530:	83 fa 01             	cmp    $0x1,%edx
  801533:	7e 0e                	jle    801543 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801535:	8b 10                	mov    (%eax),%edx
  801537:	8d 4a 08             	lea    0x8(%edx),%ecx
  80153a:	89 08                	mov    %ecx,(%eax)
  80153c:	8b 02                	mov    (%edx),%eax
  80153e:	8b 52 04             	mov    0x4(%edx),%edx
  801541:	eb 22                	jmp    801565 <getuint+0x38>
	else if (lflag)
  801543:	85 d2                	test   %edx,%edx
  801545:	74 10                	je     801557 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801547:	8b 10                	mov    (%eax),%edx
  801549:	8d 4a 04             	lea    0x4(%edx),%ecx
  80154c:	89 08                	mov    %ecx,(%eax)
  80154e:	8b 02                	mov    (%edx),%eax
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	eb 0e                	jmp    801565 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801557:	8b 10                	mov    (%eax),%edx
  801559:	8d 4a 04             	lea    0x4(%edx),%ecx
  80155c:	89 08                	mov    %ecx,(%eax)
  80155e:	8b 02                	mov    (%edx),%eax
  801560:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801565:	5d                   	pop    %ebp
  801566:	c3                   	ret    

00801567 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80156d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801571:	8b 10                	mov    (%eax),%edx
  801573:	3b 50 04             	cmp    0x4(%eax),%edx
  801576:	73 0a                	jae    801582 <sprintputch+0x1b>
		*b->buf++ = ch;
  801578:	8d 4a 01             	lea    0x1(%edx),%ecx
  80157b:	89 08                	mov    %ecx,(%eax)
  80157d:	8b 45 08             	mov    0x8(%ebp),%eax
  801580:	88 02                	mov    %al,(%edx)
}
  801582:	5d                   	pop    %ebp
  801583:	c3                   	ret    

00801584 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
  801587:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80158a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80158d:	50                   	push   %eax
  80158e:	ff 75 10             	pushl  0x10(%ebp)
  801591:	ff 75 0c             	pushl  0xc(%ebp)
  801594:	ff 75 08             	pushl  0x8(%ebp)
  801597:	e8 05 00 00 00       	call   8015a1 <vprintfmt>
	va_end(ap);
}
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	57                   	push   %edi
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 2c             	sub    $0x2c,%esp
  8015aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015b3:	eb 12                	jmp    8015c7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	0f 84 89 03 00 00    	je     801946 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	53                   	push   %ebx
  8015c1:	50                   	push   %eax
  8015c2:	ff d6                	call   *%esi
  8015c4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015c7:	83 c7 01             	add    $0x1,%edi
  8015ca:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015ce:	83 f8 25             	cmp    $0x25,%eax
  8015d1:	75 e2                	jne    8015b5 <vprintfmt+0x14>
  8015d3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015d7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015de:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015e5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f1:	eb 07                	jmp    8015fa <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015f6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015fa:	8d 47 01             	lea    0x1(%edi),%eax
  8015fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801600:	0f b6 07             	movzbl (%edi),%eax
  801603:	0f b6 c8             	movzbl %al,%ecx
  801606:	83 e8 23             	sub    $0x23,%eax
  801609:	3c 55                	cmp    $0x55,%al
  80160b:	0f 87 1a 03 00 00    	ja     80192b <vprintfmt+0x38a>
  801611:	0f b6 c0             	movzbl %al,%eax
  801614:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  80161b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80161e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801622:	eb d6                	jmp    8015fa <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801627:	b8 00 00 00 00       	mov    $0x0,%eax
  80162c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80162f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801632:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801636:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801639:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80163c:	83 fa 09             	cmp    $0x9,%edx
  80163f:	77 39                	ja     80167a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801641:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801644:	eb e9                	jmp    80162f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801646:	8b 45 14             	mov    0x14(%ebp),%eax
  801649:	8d 48 04             	lea    0x4(%eax),%ecx
  80164c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80164f:	8b 00                	mov    (%eax),%eax
  801651:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801654:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801657:	eb 27                	jmp    801680 <vprintfmt+0xdf>
  801659:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80165c:	85 c0                	test   %eax,%eax
  80165e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801663:	0f 49 c8             	cmovns %eax,%ecx
  801666:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801669:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80166c:	eb 8c                	jmp    8015fa <vprintfmt+0x59>
  80166e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801671:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801678:	eb 80                	jmp    8015fa <vprintfmt+0x59>
  80167a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80167d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801680:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801684:	0f 89 70 ff ff ff    	jns    8015fa <vprintfmt+0x59>
				width = precision, precision = -1;
  80168a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80168d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801690:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801697:	e9 5e ff ff ff       	jmp    8015fa <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80169c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80169f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016a2:	e9 53 ff ff ff       	jmp    8015fa <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8016aa:	8d 50 04             	lea    0x4(%eax),%edx
  8016ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8016b0:	83 ec 08             	sub    $0x8,%esp
  8016b3:	53                   	push   %ebx
  8016b4:	ff 30                	pushl  (%eax)
  8016b6:	ff d6                	call   *%esi
			break;
  8016b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016be:	e9 04 ff ff ff       	jmp    8015c7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c6:	8d 50 04             	lea    0x4(%eax),%edx
  8016c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8016cc:	8b 00                	mov    (%eax),%eax
  8016ce:	99                   	cltd   
  8016cf:	31 d0                	xor    %edx,%eax
  8016d1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016d3:	83 f8 0f             	cmp    $0xf,%eax
  8016d6:	7f 0b                	jg     8016e3 <vprintfmt+0x142>
  8016d8:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8016df:	85 d2                	test   %edx,%edx
  8016e1:	75 18                	jne    8016fb <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016e3:	50                   	push   %eax
  8016e4:	68 9b 23 80 00       	push   $0x80239b
  8016e9:	53                   	push   %ebx
  8016ea:	56                   	push   %esi
  8016eb:	e8 94 fe ff ff       	call   801584 <printfmt>
  8016f0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016f6:	e9 cc fe ff ff       	jmp    8015c7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8016fb:	52                   	push   %edx
  8016fc:	68 19 23 80 00       	push   $0x802319
  801701:	53                   	push   %ebx
  801702:	56                   	push   %esi
  801703:	e8 7c fe ff ff       	call   801584 <printfmt>
  801708:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80170e:	e9 b4 fe ff ff       	jmp    8015c7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801713:	8b 45 14             	mov    0x14(%ebp),%eax
  801716:	8d 50 04             	lea    0x4(%eax),%edx
  801719:	89 55 14             	mov    %edx,0x14(%ebp)
  80171c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80171e:	85 ff                	test   %edi,%edi
  801720:	b8 94 23 80 00       	mov    $0x802394,%eax
  801725:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801728:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80172c:	0f 8e 94 00 00 00    	jle    8017c6 <vprintfmt+0x225>
  801732:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801736:	0f 84 98 00 00 00    	je     8017d4 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80173c:	83 ec 08             	sub    $0x8,%esp
  80173f:	ff 75 d0             	pushl  -0x30(%ebp)
  801742:	57                   	push   %edi
  801743:	e8 86 02 00 00       	call   8019ce <strnlen>
  801748:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80174b:	29 c1                	sub    %eax,%ecx
  80174d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801750:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801753:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801757:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80175a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80175d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80175f:	eb 0f                	jmp    801770 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	53                   	push   %ebx
  801765:	ff 75 e0             	pushl  -0x20(%ebp)
  801768:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80176a:	83 ef 01             	sub    $0x1,%edi
  80176d:	83 c4 10             	add    $0x10,%esp
  801770:	85 ff                	test   %edi,%edi
  801772:	7f ed                	jg     801761 <vprintfmt+0x1c0>
  801774:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801777:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80177a:	85 c9                	test   %ecx,%ecx
  80177c:	b8 00 00 00 00       	mov    $0x0,%eax
  801781:	0f 49 c1             	cmovns %ecx,%eax
  801784:	29 c1                	sub    %eax,%ecx
  801786:	89 75 08             	mov    %esi,0x8(%ebp)
  801789:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80178c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80178f:	89 cb                	mov    %ecx,%ebx
  801791:	eb 4d                	jmp    8017e0 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801793:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801797:	74 1b                	je     8017b4 <vprintfmt+0x213>
  801799:	0f be c0             	movsbl %al,%eax
  80179c:	83 e8 20             	sub    $0x20,%eax
  80179f:	83 f8 5e             	cmp    $0x5e,%eax
  8017a2:	76 10                	jbe    8017b4 <vprintfmt+0x213>
					putch('?', putdat);
  8017a4:	83 ec 08             	sub    $0x8,%esp
  8017a7:	ff 75 0c             	pushl  0xc(%ebp)
  8017aa:	6a 3f                	push   $0x3f
  8017ac:	ff 55 08             	call   *0x8(%ebp)
  8017af:	83 c4 10             	add    $0x10,%esp
  8017b2:	eb 0d                	jmp    8017c1 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017b4:	83 ec 08             	sub    $0x8,%esp
  8017b7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ba:	52                   	push   %edx
  8017bb:	ff 55 08             	call   *0x8(%ebp)
  8017be:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017c1:	83 eb 01             	sub    $0x1,%ebx
  8017c4:	eb 1a                	jmp    8017e0 <vprintfmt+0x23f>
  8017c6:	89 75 08             	mov    %esi,0x8(%ebp)
  8017c9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017cc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017cf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017d2:	eb 0c                	jmp    8017e0 <vprintfmt+0x23f>
  8017d4:	89 75 08             	mov    %esi,0x8(%ebp)
  8017d7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017da:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017dd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017e0:	83 c7 01             	add    $0x1,%edi
  8017e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017e7:	0f be d0             	movsbl %al,%edx
  8017ea:	85 d2                	test   %edx,%edx
  8017ec:	74 23                	je     801811 <vprintfmt+0x270>
  8017ee:	85 f6                	test   %esi,%esi
  8017f0:	78 a1                	js     801793 <vprintfmt+0x1f2>
  8017f2:	83 ee 01             	sub    $0x1,%esi
  8017f5:	79 9c                	jns    801793 <vprintfmt+0x1f2>
  8017f7:	89 df                	mov    %ebx,%edi
  8017f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8017fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017ff:	eb 18                	jmp    801819 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801801:	83 ec 08             	sub    $0x8,%esp
  801804:	53                   	push   %ebx
  801805:	6a 20                	push   $0x20
  801807:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801809:	83 ef 01             	sub    $0x1,%edi
  80180c:	83 c4 10             	add    $0x10,%esp
  80180f:	eb 08                	jmp    801819 <vprintfmt+0x278>
  801811:	89 df                	mov    %ebx,%edi
  801813:	8b 75 08             	mov    0x8(%ebp),%esi
  801816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801819:	85 ff                	test   %edi,%edi
  80181b:	7f e4                	jg     801801 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801820:	e9 a2 fd ff ff       	jmp    8015c7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801825:	83 fa 01             	cmp    $0x1,%edx
  801828:	7e 16                	jle    801840 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80182a:	8b 45 14             	mov    0x14(%ebp),%eax
  80182d:	8d 50 08             	lea    0x8(%eax),%edx
  801830:	89 55 14             	mov    %edx,0x14(%ebp)
  801833:	8b 50 04             	mov    0x4(%eax),%edx
  801836:	8b 00                	mov    (%eax),%eax
  801838:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80183b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80183e:	eb 32                	jmp    801872 <vprintfmt+0x2d1>
	else if (lflag)
  801840:	85 d2                	test   %edx,%edx
  801842:	74 18                	je     80185c <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801844:	8b 45 14             	mov    0x14(%ebp),%eax
  801847:	8d 50 04             	lea    0x4(%eax),%edx
  80184a:	89 55 14             	mov    %edx,0x14(%ebp)
  80184d:	8b 00                	mov    (%eax),%eax
  80184f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801852:	89 c1                	mov    %eax,%ecx
  801854:	c1 f9 1f             	sar    $0x1f,%ecx
  801857:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80185a:	eb 16                	jmp    801872 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80185c:	8b 45 14             	mov    0x14(%ebp),%eax
  80185f:	8d 50 04             	lea    0x4(%eax),%edx
  801862:	89 55 14             	mov    %edx,0x14(%ebp)
  801865:	8b 00                	mov    (%eax),%eax
  801867:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80186a:	89 c1                	mov    %eax,%ecx
  80186c:	c1 f9 1f             	sar    $0x1f,%ecx
  80186f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801872:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801875:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801878:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80187d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801881:	79 74                	jns    8018f7 <vprintfmt+0x356>
				putch('-', putdat);
  801883:	83 ec 08             	sub    $0x8,%esp
  801886:	53                   	push   %ebx
  801887:	6a 2d                	push   $0x2d
  801889:	ff d6                	call   *%esi
				num = -(long long) num;
  80188b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80188e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801891:	f7 d8                	neg    %eax
  801893:	83 d2 00             	adc    $0x0,%edx
  801896:	f7 da                	neg    %edx
  801898:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80189b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018a0:	eb 55                	jmp    8018f7 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8018a5:	e8 83 fc ff ff       	call   80152d <getuint>
			base = 10;
  8018aa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018af:	eb 46                	jmp    8018f7 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018b1:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b4:	e8 74 fc ff ff       	call   80152d <getuint>
			base = 8;
  8018b9:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018be:	eb 37                	jmp    8018f7 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	53                   	push   %ebx
  8018c4:	6a 30                	push   $0x30
  8018c6:	ff d6                	call   *%esi
			putch('x', putdat);
  8018c8:	83 c4 08             	add    $0x8,%esp
  8018cb:	53                   	push   %ebx
  8018cc:	6a 78                	push   $0x78
  8018ce:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d3:	8d 50 04             	lea    0x4(%eax),%edx
  8018d6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018d9:	8b 00                	mov    (%eax),%eax
  8018db:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018e0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018e3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018e8:	eb 0d                	jmp    8018f7 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018ea:	8d 45 14             	lea    0x14(%ebp),%eax
  8018ed:	e8 3b fc ff ff       	call   80152d <getuint>
			base = 16;
  8018f2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018f7:	83 ec 0c             	sub    $0xc,%esp
  8018fa:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8018fe:	57                   	push   %edi
  8018ff:	ff 75 e0             	pushl  -0x20(%ebp)
  801902:	51                   	push   %ecx
  801903:	52                   	push   %edx
  801904:	50                   	push   %eax
  801905:	89 da                	mov    %ebx,%edx
  801907:	89 f0                	mov    %esi,%eax
  801909:	e8 70 fb ff ff       	call   80147e <printnum>
			break;
  80190e:	83 c4 20             	add    $0x20,%esp
  801911:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801914:	e9 ae fc ff ff       	jmp    8015c7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801919:	83 ec 08             	sub    $0x8,%esp
  80191c:	53                   	push   %ebx
  80191d:	51                   	push   %ecx
  80191e:	ff d6                	call   *%esi
			break;
  801920:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801926:	e9 9c fc ff ff       	jmp    8015c7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	53                   	push   %ebx
  80192f:	6a 25                	push   $0x25
  801931:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801933:	83 c4 10             	add    $0x10,%esp
  801936:	eb 03                	jmp    80193b <vprintfmt+0x39a>
  801938:	83 ef 01             	sub    $0x1,%edi
  80193b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80193f:	75 f7                	jne    801938 <vprintfmt+0x397>
  801941:	e9 81 fc ff ff       	jmp    8015c7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801946:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801949:	5b                   	pop    %ebx
  80194a:	5e                   	pop    %esi
  80194b:	5f                   	pop    %edi
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	83 ec 18             	sub    $0x18,%esp
  801954:	8b 45 08             	mov    0x8(%ebp),%eax
  801957:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80195a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80195d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801961:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801964:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80196b:	85 c0                	test   %eax,%eax
  80196d:	74 26                	je     801995 <vsnprintf+0x47>
  80196f:	85 d2                	test   %edx,%edx
  801971:	7e 22                	jle    801995 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801973:	ff 75 14             	pushl  0x14(%ebp)
  801976:	ff 75 10             	pushl  0x10(%ebp)
  801979:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80197c:	50                   	push   %eax
  80197d:	68 67 15 80 00       	push   $0x801567
  801982:	e8 1a fc ff ff       	call   8015a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801987:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80198a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80198d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801990:	83 c4 10             	add    $0x10,%esp
  801993:	eb 05                	jmp    80199a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801995:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80199a:	c9                   	leave  
  80199b:	c3                   	ret    

0080199c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019a5:	50                   	push   %eax
  8019a6:	ff 75 10             	pushl  0x10(%ebp)
  8019a9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ac:	ff 75 08             	pushl  0x8(%ebp)
  8019af:	e8 9a ff ff ff       	call   80194e <vsnprintf>
	va_end(ap);

	return rc;
}
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c1:	eb 03                	jmp    8019c6 <strlen+0x10>
		n++;
  8019c3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019ca:	75 f7                	jne    8019c3 <strlen+0xd>
		n++;
	return n;
}
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019dc:	eb 03                	jmp    8019e1 <strnlen+0x13>
		n++;
  8019de:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019e1:	39 c2                	cmp    %eax,%edx
  8019e3:	74 08                	je     8019ed <strnlen+0x1f>
  8019e5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019e9:	75 f3                	jne    8019de <strnlen+0x10>
  8019eb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019ed:	5d                   	pop    %ebp
  8019ee:	c3                   	ret    

008019ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	53                   	push   %ebx
  8019f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019f9:	89 c2                	mov    %eax,%edx
  8019fb:	83 c2 01             	add    $0x1,%edx
  8019fe:	83 c1 01             	add    $0x1,%ecx
  801a01:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a05:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a08:	84 db                	test   %bl,%bl
  801a0a:	75 ef                	jne    8019fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a0c:	5b                   	pop    %ebx
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    

00801a0f <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	53                   	push   %ebx
  801a13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a16:	53                   	push   %ebx
  801a17:	e8 9a ff ff ff       	call   8019b6 <strlen>
  801a1c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a1f:	ff 75 0c             	pushl  0xc(%ebp)
  801a22:	01 d8                	add    %ebx,%eax
  801a24:	50                   	push   %eax
  801a25:	e8 c5 ff ff ff       	call   8019ef <strcpy>
	return dst;
}
  801a2a:	89 d8                	mov    %ebx,%eax
  801a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2f:	c9                   	leave  
  801a30:	c3                   	ret    

00801a31 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
  801a36:	8b 75 08             	mov    0x8(%ebp),%esi
  801a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3c:	89 f3                	mov    %esi,%ebx
  801a3e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a41:	89 f2                	mov    %esi,%edx
  801a43:	eb 0f                	jmp    801a54 <strncpy+0x23>
		*dst++ = *src;
  801a45:	83 c2 01             	add    $0x1,%edx
  801a48:	0f b6 01             	movzbl (%ecx),%eax
  801a4b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a4e:	80 39 01             	cmpb   $0x1,(%ecx)
  801a51:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a54:	39 da                	cmp    %ebx,%edx
  801a56:	75 ed                	jne    801a45 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a58:	89 f0                	mov    %esi,%eax
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	56                   	push   %esi
  801a62:	53                   	push   %ebx
  801a63:	8b 75 08             	mov    0x8(%ebp),%esi
  801a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a69:	8b 55 10             	mov    0x10(%ebp),%edx
  801a6c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a6e:	85 d2                	test   %edx,%edx
  801a70:	74 21                	je     801a93 <strlcpy+0x35>
  801a72:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a76:	89 f2                	mov    %esi,%edx
  801a78:	eb 09                	jmp    801a83 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a7a:	83 c2 01             	add    $0x1,%edx
  801a7d:	83 c1 01             	add    $0x1,%ecx
  801a80:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a83:	39 c2                	cmp    %eax,%edx
  801a85:	74 09                	je     801a90 <strlcpy+0x32>
  801a87:	0f b6 19             	movzbl (%ecx),%ebx
  801a8a:	84 db                	test   %bl,%bl
  801a8c:	75 ec                	jne    801a7a <strlcpy+0x1c>
  801a8e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a90:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a93:	29 f0                	sub    %esi,%eax
}
  801a95:	5b                   	pop    %ebx
  801a96:	5e                   	pop    %esi
  801a97:	5d                   	pop    %ebp
  801a98:	c3                   	ret    

00801a99 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a99:	55                   	push   %ebp
  801a9a:	89 e5                	mov    %esp,%ebp
  801a9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801aa2:	eb 06                	jmp    801aaa <strcmp+0x11>
		p++, q++;
  801aa4:	83 c1 01             	add    $0x1,%ecx
  801aa7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801aaa:	0f b6 01             	movzbl (%ecx),%eax
  801aad:	84 c0                	test   %al,%al
  801aaf:	74 04                	je     801ab5 <strcmp+0x1c>
  801ab1:	3a 02                	cmp    (%edx),%al
  801ab3:	74 ef                	je     801aa4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ab5:	0f b6 c0             	movzbl %al,%eax
  801ab8:	0f b6 12             	movzbl (%edx),%edx
  801abb:	29 d0                	sub    %edx,%eax
}
  801abd:	5d                   	pop    %ebp
  801abe:	c3                   	ret    

00801abf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	53                   	push   %ebx
  801ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac9:	89 c3                	mov    %eax,%ebx
  801acb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ace:	eb 06                	jmp    801ad6 <strncmp+0x17>
		n--, p++, q++;
  801ad0:	83 c0 01             	add    $0x1,%eax
  801ad3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ad6:	39 d8                	cmp    %ebx,%eax
  801ad8:	74 15                	je     801aef <strncmp+0x30>
  801ada:	0f b6 08             	movzbl (%eax),%ecx
  801add:	84 c9                	test   %cl,%cl
  801adf:	74 04                	je     801ae5 <strncmp+0x26>
  801ae1:	3a 0a                	cmp    (%edx),%cl
  801ae3:	74 eb                	je     801ad0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ae5:	0f b6 00             	movzbl (%eax),%eax
  801ae8:	0f b6 12             	movzbl (%edx),%edx
  801aeb:	29 d0                	sub    %edx,%eax
  801aed:	eb 05                	jmp    801af4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801af4:	5b                   	pop    %ebx
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	8b 45 08             	mov    0x8(%ebp),%eax
  801afd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b01:	eb 07                	jmp    801b0a <strchr+0x13>
		if (*s == c)
  801b03:	38 ca                	cmp    %cl,%dl
  801b05:	74 0f                	je     801b16 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b07:	83 c0 01             	add    $0x1,%eax
  801b0a:	0f b6 10             	movzbl (%eax),%edx
  801b0d:	84 d2                	test   %dl,%dl
  801b0f:	75 f2                	jne    801b03 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b22:	eb 03                	jmp    801b27 <strfind+0xf>
  801b24:	83 c0 01             	add    $0x1,%eax
  801b27:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b2a:	38 ca                	cmp    %cl,%dl
  801b2c:	74 04                	je     801b32 <strfind+0x1a>
  801b2e:	84 d2                	test   %dl,%dl
  801b30:	75 f2                	jne    801b24 <strfind+0xc>
			break;
	return (char *) s;
}
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	57                   	push   %edi
  801b38:	56                   	push   %esi
  801b39:	53                   	push   %ebx
  801b3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b40:	85 c9                	test   %ecx,%ecx
  801b42:	74 36                	je     801b7a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b4a:	75 28                	jne    801b74 <memset+0x40>
  801b4c:	f6 c1 03             	test   $0x3,%cl
  801b4f:	75 23                	jne    801b74 <memset+0x40>
		c &= 0xFF;
  801b51:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b55:	89 d3                	mov    %edx,%ebx
  801b57:	c1 e3 08             	shl    $0x8,%ebx
  801b5a:	89 d6                	mov    %edx,%esi
  801b5c:	c1 e6 18             	shl    $0x18,%esi
  801b5f:	89 d0                	mov    %edx,%eax
  801b61:	c1 e0 10             	shl    $0x10,%eax
  801b64:	09 f0                	or     %esi,%eax
  801b66:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b68:	89 d8                	mov    %ebx,%eax
  801b6a:	09 d0                	or     %edx,%eax
  801b6c:	c1 e9 02             	shr    $0x2,%ecx
  801b6f:	fc                   	cld    
  801b70:	f3 ab                	rep stos %eax,%es:(%edi)
  801b72:	eb 06                	jmp    801b7a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b77:	fc                   	cld    
  801b78:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b7a:	89 f8                	mov    %edi,%eax
  801b7c:	5b                   	pop    %ebx
  801b7d:	5e                   	pop    %esi
  801b7e:	5f                   	pop    %edi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	57                   	push   %edi
  801b85:	56                   	push   %esi
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b8f:	39 c6                	cmp    %eax,%esi
  801b91:	73 35                	jae    801bc8 <memmove+0x47>
  801b93:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b96:	39 d0                	cmp    %edx,%eax
  801b98:	73 2e                	jae    801bc8 <memmove+0x47>
		s += n;
		d += n;
  801b9a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b9d:	89 d6                	mov    %edx,%esi
  801b9f:	09 fe                	or     %edi,%esi
  801ba1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801ba7:	75 13                	jne    801bbc <memmove+0x3b>
  801ba9:	f6 c1 03             	test   $0x3,%cl
  801bac:	75 0e                	jne    801bbc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bae:	83 ef 04             	sub    $0x4,%edi
  801bb1:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bb4:	c1 e9 02             	shr    $0x2,%ecx
  801bb7:	fd                   	std    
  801bb8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bba:	eb 09                	jmp    801bc5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bbc:	83 ef 01             	sub    $0x1,%edi
  801bbf:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bc2:	fd                   	std    
  801bc3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bc5:	fc                   	cld    
  801bc6:	eb 1d                	jmp    801be5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bc8:	89 f2                	mov    %esi,%edx
  801bca:	09 c2                	or     %eax,%edx
  801bcc:	f6 c2 03             	test   $0x3,%dl
  801bcf:	75 0f                	jne    801be0 <memmove+0x5f>
  801bd1:	f6 c1 03             	test   $0x3,%cl
  801bd4:	75 0a                	jne    801be0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bd6:	c1 e9 02             	shr    $0x2,%ecx
  801bd9:	89 c7                	mov    %eax,%edi
  801bdb:	fc                   	cld    
  801bdc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bde:	eb 05                	jmp    801be5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801be0:	89 c7                	mov    %eax,%edi
  801be2:	fc                   	cld    
  801be3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801be5:	5e                   	pop    %esi
  801be6:	5f                   	pop    %edi
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801bec:	ff 75 10             	pushl  0x10(%ebp)
  801bef:	ff 75 0c             	pushl  0xc(%ebp)
  801bf2:	ff 75 08             	pushl  0x8(%ebp)
  801bf5:	e8 87 ff ff ff       	call   801b81 <memmove>
}
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	8b 45 08             	mov    0x8(%ebp),%eax
  801c04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c07:	89 c6                	mov    %eax,%esi
  801c09:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c0c:	eb 1a                	jmp    801c28 <memcmp+0x2c>
		if (*s1 != *s2)
  801c0e:	0f b6 08             	movzbl (%eax),%ecx
  801c11:	0f b6 1a             	movzbl (%edx),%ebx
  801c14:	38 d9                	cmp    %bl,%cl
  801c16:	74 0a                	je     801c22 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c18:	0f b6 c1             	movzbl %cl,%eax
  801c1b:	0f b6 db             	movzbl %bl,%ebx
  801c1e:	29 d8                	sub    %ebx,%eax
  801c20:	eb 0f                	jmp    801c31 <memcmp+0x35>
		s1++, s2++;
  801c22:	83 c0 01             	add    $0x1,%eax
  801c25:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c28:	39 f0                	cmp    %esi,%eax
  801c2a:	75 e2                	jne    801c0e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	53                   	push   %ebx
  801c39:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c3c:	89 c1                	mov    %eax,%ecx
  801c3e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c41:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c45:	eb 0a                	jmp    801c51 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c47:	0f b6 10             	movzbl (%eax),%edx
  801c4a:	39 da                	cmp    %ebx,%edx
  801c4c:	74 07                	je     801c55 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c4e:	83 c0 01             	add    $0x1,%eax
  801c51:	39 c8                	cmp    %ecx,%eax
  801c53:	72 f2                	jb     801c47 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c55:	5b                   	pop    %ebx
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    

00801c58 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	57                   	push   %edi
  801c5c:	56                   	push   %esi
  801c5d:	53                   	push   %ebx
  801c5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c64:	eb 03                	jmp    801c69 <strtol+0x11>
		s++;
  801c66:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c69:	0f b6 01             	movzbl (%ecx),%eax
  801c6c:	3c 20                	cmp    $0x20,%al
  801c6e:	74 f6                	je     801c66 <strtol+0xe>
  801c70:	3c 09                	cmp    $0x9,%al
  801c72:	74 f2                	je     801c66 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c74:	3c 2b                	cmp    $0x2b,%al
  801c76:	75 0a                	jne    801c82 <strtol+0x2a>
		s++;
  801c78:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  801c80:	eb 11                	jmp    801c93 <strtol+0x3b>
  801c82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c87:	3c 2d                	cmp    $0x2d,%al
  801c89:	75 08                	jne    801c93 <strtol+0x3b>
		s++, neg = 1;
  801c8b:	83 c1 01             	add    $0x1,%ecx
  801c8e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c93:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c99:	75 15                	jne    801cb0 <strtol+0x58>
  801c9b:	80 39 30             	cmpb   $0x30,(%ecx)
  801c9e:	75 10                	jne    801cb0 <strtol+0x58>
  801ca0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ca4:	75 7c                	jne    801d22 <strtol+0xca>
		s += 2, base = 16;
  801ca6:	83 c1 02             	add    $0x2,%ecx
  801ca9:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cae:	eb 16                	jmp    801cc6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cb0:	85 db                	test   %ebx,%ebx
  801cb2:	75 12                	jne    801cc6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cb4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cb9:	80 39 30             	cmpb   $0x30,(%ecx)
  801cbc:	75 08                	jne    801cc6 <strtol+0x6e>
		s++, base = 8;
  801cbe:	83 c1 01             	add    $0x1,%ecx
  801cc1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cce:	0f b6 11             	movzbl (%ecx),%edx
  801cd1:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cd4:	89 f3                	mov    %esi,%ebx
  801cd6:	80 fb 09             	cmp    $0x9,%bl
  801cd9:	77 08                	ja     801ce3 <strtol+0x8b>
			dig = *s - '0';
  801cdb:	0f be d2             	movsbl %dl,%edx
  801cde:	83 ea 30             	sub    $0x30,%edx
  801ce1:	eb 22                	jmp    801d05 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ce3:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ce6:	89 f3                	mov    %esi,%ebx
  801ce8:	80 fb 19             	cmp    $0x19,%bl
  801ceb:	77 08                	ja     801cf5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ced:	0f be d2             	movsbl %dl,%edx
  801cf0:	83 ea 57             	sub    $0x57,%edx
  801cf3:	eb 10                	jmp    801d05 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801cf5:	8d 72 bf             	lea    -0x41(%edx),%esi
  801cf8:	89 f3                	mov    %esi,%ebx
  801cfa:	80 fb 19             	cmp    $0x19,%bl
  801cfd:	77 16                	ja     801d15 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801cff:	0f be d2             	movsbl %dl,%edx
  801d02:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d05:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d08:	7d 0b                	jge    801d15 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d0a:	83 c1 01             	add    $0x1,%ecx
  801d0d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d11:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d13:	eb b9                	jmp    801cce <strtol+0x76>

	if (endptr)
  801d15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d19:	74 0d                	je     801d28 <strtol+0xd0>
		*endptr = (char *) s;
  801d1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d1e:	89 0e                	mov    %ecx,(%esi)
  801d20:	eb 06                	jmp    801d28 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d22:	85 db                	test   %ebx,%ebx
  801d24:	74 98                	je     801cbe <strtol+0x66>
  801d26:	eb 9e                	jmp    801cc6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d28:	89 c2                	mov    %eax,%edx
  801d2a:	f7 da                	neg    %edx
  801d2c:	85 ff                	test   %edi,%edi
  801d2e:	0f 45 c2             	cmovne %edx,%eax
}
  801d31:	5b                   	pop    %ebx
  801d32:	5e                   	pop    %esi
  801d33:	5f                   	pop    %edi
  801d34:	5d                   	pop    %ebp
  801d35:	c3                   	ret    

00801d36 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d36:	55                   	push   %ebp
  801d37:	89 e5                	mov    %esp,%ebp
  801d39:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d3c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d43:	75 2a                	jne    801d6f <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d45:	83 ec 04             	sub    $0x4,%esp
  801d48:	6a 07                	push   $0x7
  801d4a:	68 00 f0 bf ee       	push   $0xeebff000
  801d4f:	6a 00                	push   $0x0
  801d51:	e8 23 e4 ff ff       	call   800179 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d56:	83 c4 10             	add    $0x10,%esp
  801d59:	85 c0                	test   %eax,%eax
  801d5b:	79 12                	jns    801d6f <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d5d:	50                   	push   %eax
  801d5e:	68 80 26 80 00       	push   $0x802680
  801d63:	6a 23                	push   $0x23
  801d65:	68 84 26 80 00       	push   $0x802684
  801d6a:	e8 22 f6 ff ff       	call   801391 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d77:	83 ec 08             	sub    $0x8,%esp
  801d7a:	68 a1 1d 80 00       	push   $0x801da1
  801d7f:	6a 00                	push   $0x0
  801d81:	e8 3e e5 ff ff       	call   8002c4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	85 c0                	test   %eax,%eax
  801d8b:	79 12                	jns    801d9f <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d8d:	50                   	push   %eax
  801d8e:	68 80 26 80 00       	push   $0x802680
  801d93:	6a 2c                	push   $0x2c
  801d95:	68 84 26 80 00       	push   $0x802684
  801d9a:	e8 f2 f5 ff ff       	call   801391 <_panic>
	}
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    

00801da1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801da1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801da2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801da7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801da9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dac:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801db0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801db5:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801db9:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dbb:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dbe:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dbf:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dc2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dc3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dc4:	c3                   	ret    

00801dc5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	56                   	push   %esi
  801dc9:	53                   	push   %ebx
  801dca:	8b 75 08             	mov    0x8(%ebp),%esi
  801dcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dd3:	85 c0                	test   %eax,%eax
  801dd5:	75 12                	jne    801de9 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801dd7:	83 ec 0c             	sub    $0xc,%esp
  801dda:	68 00 00 c0 ee       	push   $0xeec00000
  801ddf:	e8 45 e5 ff ff       	call   800329 <sys_ipc_recv>
  801de4:	83 c4 10             	add    $0x10,%esp
  801de7:	eb 0c                	jmp    801df5 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801de9:	83 ec 0c             	sub    $0xc,%esp
  801dec:	50                   	push   %eax
  801ded:	e8 37 e5 ff ff       	call   800329 <sys_ipc_recv>
  801df2:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801df5:	85 f6                	test   %esi,%esi
  801df7:	0f 95 c1             	setne  %cl
  801dfa:	85 db                	test   %ebx,%ebx
  801dfc:	0f 95 c2             	setne  %dl
  801dff:	84 d1                	test   %dl,%cl
  801e01:	74 09                	je     801e0c <ipc_recv+0x47>
  801e03:	89 c2                	mov    %eax,%edx
  801e05:	c1 ea 1f             	shr    $0x1f,%edx
  801e08:	84 d2                	test   %dl,%dl
  801e0a:	75 2d                	jne    801e39 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e0c:	85 f6                	test   %esi,%esi
  801e0e:	74 0d                	je     801e1d <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e10:	a1 04 40 80 00       	mov    0x804004,%eax
  801e15:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e1b:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e1d:	85 db                	test   %ebx,%ebx
  801e1f:	74 0d                	je     801e2e <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e21:	a1 04 40 80 00       	mov    0x804004,%eax
  801e26:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e2c:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e2e:	a1 04 40 80 00       	mov    0x804004,%eax
  801e33:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3c:	5b                   	pop    %ebx
  801e3d:	5e                   	pop    %esi
  801e3e:	5d                   	pop    %ebp
  801e3f:	c3                   	ret    

00801e40 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	57                   	push   %edi
  801e44:	56                   	push   %esi
  801e45:	53                   	push   %ebx
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e52:	85 db                	test   %ebx,%ebx
  801e54:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e59:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e5c:	ff 75 14             	pushl  0x14(%ebp)
  801e5f:	53                   	push   %ebx
  801e60:	56                   	push   %esi
  801e61:	57                   	push   %edi
  801e62:	e8 9f e4 ff ff       	call   800306 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e67:	89 c2                	mov    %eax,%edx
  801e69:	c1 ea 1f             	shr    $0x1f,%edx
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	84 d2                	test   %dl,%dl
  801e71:	74 17                	je     801e8a <ipc_send+0x4a>
  801e73:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e76:	74 12                	je     801e8a <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e78:	50                   	push   %eax
  801e79:	68 92 26 80 00       	push   $0x802692
  801e7e:	6a 47                	push   $0x47
  801e80:	68 a0 26 80 00       	push   $0x8026a0
  801e85:	e8 07 f5 ff ff       	call   801391 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e8a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e8d:	75 07                	jne    801e96 <ipc_send+0x56>
			sys_yield();
  801e8f:	e8 c6 e2 ff ff       	call   80015a <sys_yield>
  801e94:	eb c6                	jmp    801e5c <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e96:	85 c0                	test   %eax,%eax
  801e98:	75 c2                	jne    801e5c <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9d:	5b                   	pop    %ebx
  801e9e:	5e                   	pop    %esi
  801e9f:	5f                   	pop    %edi
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ea8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ead:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801eb3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801eb9:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ebf:	39 ca                	cmp    %ecx,%edx
  801ec1:	75 10                	jne    801ed3 <ipc_find_env+0x31>
			return envs[i].env_id;
  801ec3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801ec9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ece:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ed1:	eb 0f                	jmp    801ee2 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed3:	83 c0 01             	add    $0x1,%eax
  801ed6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801edb:	75 d0                	jne    801ead <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801edd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee2:	5d                   	pop    %ebp
  801ee3:	c3                   	ret    

00801ee4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eea:	89 d0                	mov    %edx,%eax
  801eec:	c1 e8 16             	shr    $0x16,%eax
  801eef:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ef6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801efb:	f6 c1 01             	test   $0x1,%cl
  801efe:	74 1d                	je     801f1d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f00:	c1 ea 0c             	shr    $0xc,%edx
  801f03:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f0a:	f6 c2 01             	test   $0x1,%dl
  801f0d:	74 0e                	je     801f1d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f0f:	c1 ea 0c             	shr    $0xc,%edx
  801f12:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f19:	ef 
  801f1a:	0f b7 c0             	movzwl %ax,%eax
}
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    
  801f1f:	90                   	nop

00801f20 <__udivdi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
  801f27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f37:	85 f6                	test   %esi,%esi
  801f39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f3d:	89 ca                	mov    %ecx,%edx
  801f3f:	89 f8                	mov    %edi,%eax
  801f41:	75 3d                	jne    801f80 <__udivdi3+0x60>
  801f43:	39 cf                	cmp    %ecx,%edi
  801f45:	0f 87 c5 00 00 00    	ja     802010 <__udivdi3+0xf0>
  801f4b:	85 ff                	test   %edi,%edi
  801f4d:	89 fd                	mov    %edi,%ebp
  801f4f:	75 0b                	jne    801f5c <__udivdi3+0x3c>
  801f51:	b8 01 00 00 00       	mov    $0x1,%eax
  801f56:	31 d2                	xor    %edx,%edx
  801f58:	f7 f7                	div    %edi
  801f5a:	89 c5                	mov    %eax,%ebp
  801f5c:	89 c8                	mov    %ecx,%eax
  801f5e:	31 d2                	xor    %edx,%edx
  801f60:	f7 f5                	div    %ebp
  801f62:	89 c1                	mov    %eax,%ecx
  801f64:	89 d8                	mov    %ebx,%eax
  801f66:	89 cf                	mov    %ecx,%edi
  801f68:	f7 f5                	div    %ebp
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	89 d8                	mov    %ebx,%eax
  801f6e:	89 fa                	mov    %edi,%edx
  801f70:	83 c4 1c             	add    $0x1c,%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
  801f78:	90                   	nop
  801f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f80:	39 ce                	cmp    %ecx,%esi
  801f82:	77 74                	ja     801ff8 <__udivdi3+0xd8>
  801f84:	0f bd fe             	bsr    %esi,%edi
  801f87:	83 f7 1f             	xor    $0x1f,%edi
  801f8a:	0f 84 98 00 00 00    	je     802028 <__udivdi3+0x108>
  801f90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	89 c5                	mov    %eax,%ebp
  801f99:	29 fb                	sub    %edi,%ebx
  801f9b:	d3 e6                	shl    %cl,%esi
  801f9d:	89 d9                	mov    %ebx,%ecx
  801f9f:	d3 ed                	shr    %cl,%ebp
  801fa1:	89 f9                	mov    %edi,%ecx
  801fa3:	d3 e0                	shl    %cl,%eax
  801fa5:	09 ee                	or     %ebp,%esi
  801fa7:	89 d9                	mov    %ebx,%ecx
  801fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fad:	89 d5                	mov    %edx,%ebp
  801faf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fb3:	d3 ed                	shr    %cl,%ebp
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e2                	shl    %cl,%edx
  801fb9:	89 d9                	mov    %ebx,%ecx
  801fbb:	d3 e8                	shr    %cl,%eax
  801fbd:	09 c2                	or     %eax,%edx
  801fbf:	89 d0                	mov    %edx,%eax
  801fc1:	89 ea                	mov    %ebp,%edx
  801fc3:	f7 f6                	div    %esi
  801fc5:	89 d5                	mov    %edx,%ebp
  801fc7:	89 c3                	mov    %eax,%ebx
  801fc9:	f7 64 24 0c          	mull   0xc(%esp)
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	72 10                	jb     801fe1 <__udivdi3+0xc1>
  801fd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e6                	shl    %cl,%esi
  801fd9:	39 c6                	cmp    %eax,%esi
  801fdb:	73 07                	jae    801fe4 <__udivdi3+0xc4>
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	75 03                	jne    801fe4 <__udivdi3+0xc4>
  801fe1:	83 eb 01             	sub    $0x1,%ebx
  801fe4:	31 ff                	xor    %edi,%edi
  801fe6:	89 d8                	mov    %ebx,%eax
  801fe8:	89 fa                	mov    %edi,%edx
  801fea:	83 c4 1c             	add    $0x1c,%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
  801ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff8:	31 ff                	xor    %edi,%edi
  801ffa:	31 db                	xor    %ebx,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	89 d8                	mov    %ebx,%eax
  802012:	f7 f7                	div    %edi
  802014:	31 ff                	xor    %edi,%edi
  802016:	89 c3                	mov    %eax,%ebx
  802018:	89 d8                	mov    %ebx,%eax
  80201a:	89 fa                	mov    %edi,%edx
  80201c:	83 c4 1c             	add    $0x1c,%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    
  802024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802028:	39 ce                	cmp    %ecx,%esi
  80202a:	72 0c                	jb     802038 <__udivdi3+0x118>
  80202c:	31 db                	xor    %ebx,%ebx
  80202e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802032:	0f 87 34 ff ff ff    	ja     801f6c <__udivdi3+0x4c>
  802038:	bb 01 00 00 00       	mov    $0x1,%ebx
  80203d:	e9 2a ff ff ff       	jmp    801f6c <__udivdi3+0x4c>
  802042:	66 90                	xchg   %ax,%ax
  802044:	66 90                	xchg   %ax,%ax
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__umoddi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80205b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80205f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 d2                	test   %edx,%edx
  802069:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80206d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802071:	89 f3                	mov    %esi,%ebx
  802073:	89 3c 24             	mov    %edi,(%esp)
  802076:	89 74 24 04          	mov    %esi,0x4(%esp)
  80207a:	75 1c                	jne    802098 <__umoddi3+0x48>
  80207c:	39 f7                	cmp    %esi,%edi
  80207e:	76 50                	jbe    8020d0 <__umoddi3+0x80>
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	f7 f7                	div    %edi
  802086:	89 d0                	mov    %edx,%eax
  802088:	31 d2                	xor    %edx,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	39 f2                	cmp    %esi,%edx
  80209a:	89 d0                	mov    %edx,%eax
  80209c:	77 52                	ja     8020f0 <__umoddi3+0xa0>
  80209e:	0f bd ea             	bsr    %edx,%ebp
  8020a1:	83 f5 1f             	xor    $0x1f,%ebp
  8020a4:	75 5a                	jne    802100 <__umoddi3+0xb0>
  8020a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020aa:	0f 82 e0 00 00 00    	jb     802190 <__umoddi3+0x140>
  8020b0:	39 0c 24             	cmp    %ecx,(%esp)
  8020b3:	0f 86 d7 00 00 00    	jbe    802190 <__umoddi3+0x140>
  8020b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020c1:	83 c4 1c             	add    $0x1c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	85 ff                	test   %edi,%edi
  8020d2:	89 fd                	mov    %edi,%ebp
  8020d4:	75 0b                	jne    8020e1 <__umoddi3+0x91>
  8020d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	f7 f7                	div    %edi
  8020df:	89 c5                	mov    %eax,%ebp
  8020e1:	89 f0                	mov    %esi,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  8020e5:	f7 f5                	div    %ebp
  8020e7:	89 c8                	mov    %ecx,%eax
  8020e9:	f7 f5                	div    %ebp
  8020eb:	89 d0                	mov    %edx,%eax
  8020ed:	eb 99                	jmp    802088 <__umoddi3+0x38>
  8020ef:	90                   	nop
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	83 c4 1c             	add    $0x1c,%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    
  8020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802100:	8b 34 24             	mov    (%esp),%esi
  802103:	bf 20 00 00 00       	mov    $0x20,%edi
  802108:	89 e9                	mov    %ebp,%ecx
  80210a:	29 ef                	sub    %ebp,%edi
  80210c:	d3 e0                	shl    %cl,%eax
  80210e:	89 f9                	mov    %edi,%ecx
  802110:	89 f2                	mov    %esi,%edx
  802112:	d3 ea                	shr    %cl,%edx
  802114:	89 e9                	mov    %ebp,%ecx
  802116:	09 c2                	or     %eax,%edx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 14 24             	mov    %edx,(%esp)
  80211d:	89 f2                	mov    %esi,%edx
  80211f:	d3 e2                	shl    %cl,%edx
  802121:	89 f9                	mov    %edi,%ecx
  802123:	89 54 24 04          	mov    %edx,0x4(%esp)
  802127:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	89 e9                	mov    %ebp,%ecx
  80212f:	89 c6                	mov    %eax,%esi
  802131:	d3 e3                	shl    %cl,%ebx
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 d0                	mov    %edx,%eax
  802137:	d3 e8                	shr    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	09 d8                	or     %ebx,%eax
  80213d:	89 d3                	mov    %edx,%ebx
  80213f:	89 f2                	mov    %esi,%edx
  802141:	f7 34 24             	divl   (%esp)
  802144:	89 d6                	mov    %edx,%esi
  802146:	d3 e3                	shl    %cl,%ebx
  802148:	f7 64 24 04          	mull   0x4(%esp)
  80214c:	39 d6                	cmp    %edx,%esi
  80214e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802152:	89 d1                	mov    %edx,%ecx
  802154:	89 c3                	mov    %eax,%ebx
  802156:	72 08                	jb     802160 <__umoddi3+0x110>
  802158:	75 11                	jne    80216b <__umoddi3+0x11b>
  80215a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80215e:	73 0b                	jae    80216b <__umoddi3+0x11b>
  802160:	2b 44 24 04          	sub    0x4(%esp),%eax
  802164:	1b 14 24             	sbb    (%esp),%edx
  802167:	89 d1                	mov    %edx,%ecx
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80216f:	29 da                	sub    %ebx,%edx
  802171:	19 ce                	sbb    %ecx,%esi
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 f0                	mov    %esi,%eax
  802177:	d3 e0                	shl    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	d3 ea                	shr    %cl,%edx
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	d3 ee                	shr    %cl,%esi
  802181:	09 d0                	or     %edx,%eax
  802183:	89 f2                	mov    %esi,%edx
  802185:	83 c4 1c             	add    $0x1c,%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    
  80218d:	8d 76 00             	lea    0x0(%esi),%esi
  802190:	29 f9                	sub    %edi,%ecx
  802192:	19 d6                	sbb    %edx,%esi
  802194:	89 74 24 04          	mov    %esi,0x4(%esp)
  802198:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80219c:	e9 18 ff ff ff       	jmp    8020b9 <__umoddi3+0x69>
