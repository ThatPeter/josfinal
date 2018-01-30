
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
  80004f:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 40 80 00       	mov    %eax,0x804004

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
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	83 ec 08             	sub    $0x8,%esp
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
  8000a9:	e8 e4 09 00 00       	call   800a92 <close_all>
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
  800122:	68 0a 24 80 00       	push   $0x80240a
  800127:	6a 23                	push   $0x23
  800129:	68 27 24 80 00       	push   $0x802427
  80012e:	e8 90 14 00 00       	call   8015c3 <_panic>

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
  8001a3:	68 0a 24 80 00       	push   $0x80240a
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 27 24 80 00       	push   $0x802427
  8001af:	e8 0f 14 00 00       	call   8015c3 <_panic>

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
  8001e5:	68 0a 24 80 00       	push   $0x80240a
  8001ea:	6a 23                	push   $0x23
  8001ec:	68 27 24 80 00       	push   $0x802427
  8001f1:	e8 cd 13 00 00       	call   8015c3 <_panic>

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
  800227:	68 0a 24 80 00       	push   $0x80240a
  80022c:	6a 23                	push   $0x23
  80022e:	68 27 24 80 00       	push   $0x802427
  800233:	e8 8b 13 00 00       	call   8015c3 <_panic>

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
  800269:	68 0a 24 80 00       	push   $0x80240a
  80026e:	6a 23                	push   $0x23
  800270:	68 27 24 80 00       	push   $0x802427
  800275:	e8 49 13 00 00       	call   8015c3 <_panic>

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
  8002ab:	68 0a 24 80 00       	push   $0x80240a
  8002b0:	6a 23                	push   $0x23
  8002b2:	68 27 24 80 00       	push   $0x802427
  8002b7:	e8 07 13 00 00       	call   8015c3 <_panic>
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
  8002ed:	68 0a 24 80 00       	push   $0x80240a
  8002f2:	6a 23                	push   $0x23
  8002f4:	68 27 24 80 00       	push   $0x802427
  8002f9:	e8 c5 12 00 00       	call   8015c3 <_panic>

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
  800351:	68 0a 24 80 00       	push   $0x80240a
  800356:	6a 23                	push   $0x23
  800358:	68 27 24 80 00       	push   $0x802427
  80035d:	e8 61 12 00 00       	call   8015c3 <_panic>

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
  8003f0:	68 35 24 80 00       	push   $0x802435
  8003f5:	6a 1f                	push   $0x1f
  8003f7:	68 45 24 80 00       	push   $0x802445
  8003fc:	e8 c2 11 00 00       	call   8015c3 <_panic>
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
  80041a:	68 50 24 80 00       	push   $0x802450
  80041f:	6a 2d                	push   $0x2d
  800421:	68 45 24 80 00       	push   $0x802445
  800426:	e8 98 11 00 00       	call   8015c3 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80042b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800431:	83 ec 04             	sub    $0x4,%esp
  800434:	68 00 10 00 00       	push   $0x1000
  800439:	53                   	push   %ebx
  80043a:	68 00 f0 7f 00       	push   $0x7ff000
  80043f:	e8 d7 19 00 00       	call   801e1b <memcpy>

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
  800462:	68 50 24 80 00       	push   $0x802450
  800467:	6a 34                	push   $0x34
  800469:	68 45 24 80 00       	push   $0x802445
  80046e:	e8 50 11 00 00       	call   8015c3 <_panic>
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
  80048a:	68 50 24 80 00       	push   $0x802450
  80048f:	6a 38                	push   $0x38
  800491:	68 45 24 80 00       	push   $0x802445
  800496:	e8 28 11 00 00       	call   8015c3 <_panic>
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
  8004ae:	e8 b5 1a 00 00       	call   801f68 <set_pgfault_handler>
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
  8004c7:	68 69 24 80 00       	push   $0x802469
  8004cc:	68 85 00 00 00       	push   $0x85
  8004d1:	68 45 24 80 00       	push   $0x802445
  8004d6:	e8 e8 10 00 00       	call   8015c3 <_panic>
  8004db:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e1:	75 24                	jne    800507 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004e3:	e8 53 fc ff ff       	call   80013b <sys_getenvid>
  8004e8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004ed:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
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
  800583:	68 77 24 80 00       	push   $0x802477
  800588:	6a 55                	push   $0x55
  80058a:	68 45 24 80 00       	push   $0x802445
  80058f:	e8 2f 10 00 00       	call   8015c3 <_panic>
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
  8005c8:	68 77 24 80 00       	push   $0x802477
  8005cd:	6a 5c                	push   $0x5c
  8005cf:	68 45 24 80 00       	push   $0x802445
  8005d4:	e8 ea 0f 00 00       	call   8015c3 <_panic>
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
  8005f6:	68 77 24 80 00       	push   $0x802477
  8005fb:	6a 60                	push   $0x60
  8005fd:	68 45 24 80 00       	push   $0x802445
  800602:	e8 bc 0f 00 00       	call   8015c3 <_panic>
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
  800620:	68 77 24 80 00       	push   $0x802477
  800625:	6a 65                	push   $0x65
  800627:	68 45 24 80 00       	push   $0x802445
  80062c:	e8 92 0f 00 00       	call   8015c3 <_panic>
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
  800648:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
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

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  800683:	8b 45 08             	mov    0x8(%ebp),%eax
  800686:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80068b:	68 83 00 80 00       	push   $0x800083
  800690:	e8 d5 fc ff ff       	call   80036a <sys_thread_create>

	return id;
}
  800695:	c9                   	leave  
  800696:	c3                   	ret    

00800697 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  80069d:	ff 75 08             	pushl  0x8(%ebp)
  8006a0:	e8 e5 fc ff ff       	call   80038a <sys_thread_free>
}
  8006a5:	83 c4 10             	add    $0x10,%esp
  8006a8:	c9                   	leave  
  8006a9:	c3                   	ret    

008006aa <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8006b0:	ff 75 08             	pushl  0x8(%ebp)
  8006b3:	e8 f2 fc ff ff       	call   8003aa <sys_thread_join>
}
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006c8:	83 ec 04             	sub    $0x4,%esp
  8006cb:	6a 07                	push   $0x7
  8006cd:	6a 00                	push   $0x0
  8006cf:	56                   	push   %esi
  8006d0:	e8 a4 fa ff ff       	call   800179 <sys_page_alloc>
	if (r < 0) {
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	79 15                	jns    8006f1 <queue_append+0x34>
		panic("%e\n", r);
  8006dc:	50                   	push   %eax
  8006dd:	68 bd 24 80 00       	push   $0x8024bd
  8006e2:	68 d5 00 00 00       	push   $0xd5
  8006e7:	68 45 24 80 00       	push   $0x802445
  8006ec:	e8 d2 0e 00 00       	call   8015c3 <_panic>
	}	

	wt->envid = envid;
  8006f1:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8006f7:	83 3b 00             	cmpl   $0x0,(%ebx)
  8006fa:	75 13                	jne    80070f <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8006fc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800703:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80070a:	00 00 00 
  80070d:	eb 1b                	jmp    80072a <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  80070f:	8b 43 04             	mov    0x4(%ebx),%eax
  800712:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800719:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800720:	00 00 00 
		queue->last = wt;
  800723:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80072a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  80073a:	8b 02                	mov    (%edx),%eax
  80073c:	85 c0                	test   %eax,%eax
  80073e:	75 17                	jne    800757 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  800740:	83 ec 04             	sub    $0x4,%esp
  800743:	68 8d 24 80 00       	push   $0x80248d
  800748:	68 ec 00 00 00       	push   $0xec
  80074d:	68 45 24 80 00       	push   $0x802445
  800752:	e8 6c 0e 00 00       	call   8015c3 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  800757:	8b 48 04             	mov    0x4(%eax),%ecx
  80075a:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80075c:	8b 00                	mov    (%eax),%eax
}
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	83 ec 04             	sub    $0x4,%esp
  800767:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80076a:	b8 01 00 00 00       	mov    $0x1,%eax
  80076f:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  800772:	85 c0                	test   %eax,%eax
  800774:	74 45                	je     8007bb <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  800776:	e8 c0 f9 ff ff       	call   80013b <sys_getenvid>
  80077b:	83 ec 08             	sub    $0x8,%esp
  80077e:	83 c3 04             	add    $0x4,%ebx
  800781:	53                   	push   %ebx
  800782:	50                   	push   %eax
  800783:	e8 35 ff ff ff       	call   8006bd <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800788:	e8 ae f9 ff ff       	call   80013b <sys_getenvid>
  80078d:	83 c4 08             	add    $0x8,%esp
  800790:	6a 04                	push   $0x4
  800792:	50                   	push   %eax
  800793:	e8 a8 fa ff ff       	call   800240 <sys_env_set_status>

		if (r < 0) {
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	85 c0                	test   %eax,%eax
  80079d:	79 15                	jns    8007b4 <mutex_lock+0x54>
			panic("%e\n", r);
  80079f:	50                   	push   %eax
  8007a0:	68 bd 24 80 00       	push   $0x8024bd
  8007a5:	68 02 01 00 00       	push   $0x102
  8007aa:	68 45 24 80 00       	push   $0x802445
  8007af:	e8 0f 0e 00 00       	call   8015c3 <_panic>
		}
		sys_yield();
  8007b4:	e8 a1 f9 ff ff       	call   80015a <sys_yield>
  8007b9:	eb 08                	jmp    8007c3 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8007bb:	e8 7b f9 ff ff       	call   80013b <sys_getenvid>
  8007c0:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8007c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	53                   	push   %ebx
  8007cc:	83 ec 04             	sub    $0x4,%esp
  8007cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8007d2:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8007d6:	74 36                	je     80080e <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8007d8:	83 ec 0c             	sub    $0xc,%esp
  8007db:	8d 43 04             	lea    0x4(%ebx),%eax
  8007de:	50                   	push   %eax
  8007df:	e8 4d ff ff ff       	call   800731 <queue_pop>
  8007e4:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8007e7:	83 c4 08             	add    $0x8,%esp
  8007ea:	6a 02                	push   $0x2
  8007ec:	50                   	push   %eax
  8007ed:	e8 4e fa ff ff       	call   800240 <sys_env_set_status>
		if (r < 0) {
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	85 c0                	test   %eax,%eax
  8007f7:	79 1d                	jns    800816 <mutex_unlock+0x4e>
			panic("%e\n", r);
  8007f9:	50                   	push   %eax
  8007fa:	68 bd 24 80 00       	push   $0x8024bd
  8007ff:	68 16 01 00 00       	push   $0x116
  800804:	68 45 24 80 00       	push   $0x802445
  800809:	e8 b5 0d 00 00       	call   8015c3 <_panic>
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
  800813:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  800816:	e8 3f f9 ff ff       	call   80015a <sys_yield>
}
  80081b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	53                   	push   %ebx
  800824:	83 ec 04             	sub    $0x4,%esp
  800827:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  80082a:	e8 0c f9 ff ff       	call   80013b <sys_getenvid>
  80082f:	83 ec 04             	sub    $0x4,%esp
  800832:	6a 07                	push   $0x7
  800834:	53                   	push   %ebx
  800835:	50                   	push   %eax
  800836:	e8 3e f9 ff ff       	call   800179 <sys_page_alloc>
  80083b:	83 c4 10             	add    $0x10,%esp
  80083e:	85 c0                	test   %eax,%eax
  800840:	79 15                	jns    800857 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800842:	50                   	push   %eax
  800843:	68 a8 24 80 00       	push   $0x8024a8
  800848:	68 23 01 00 00       	push   $0x123
  80084d:	68 45 24 80 00       	push   $0x802445
  800852:	e8 6c 0d 00 00       	call   8015c3 <_panic>
	}	
	mtx->locked = 0;
  800857:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  80085d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  800864:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80086b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  800872:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80087f:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  800882:	eb 20                	jmp    8008a4 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  800884:	83 ec 0c             	sub    $0xc,%esp
  800887:	56                   	push   %esi
  800888:	e8 a4 fe ff ff       	call   800731 <queue_pop>
  80088d:	83 c4 08             	add    $0x8,%esp
  800890:	6a 02                	push   $0x2
  800892:	50                   	push   %eax
  800893:	e8 a8 f9 ff ff       	call   800240 <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  800898:	8b 43 04             	mov    0x4(%ebx),%eax
  80089b:	8b 40 04             	mov    0x4(%eax),%eax
  80089e:	89 43 04             	mov    %eax,0x4(%ebx)
  8008a1:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8008a4:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8008a8:	75 da                	jne    800884 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008aa:	83 ec 04             	sub    $0x4,%esp
  8008ad:	68 00 10 00 00       	push   $0x1000
  8008b2:	6a 00                	push   $0x0
  8008b4:	53                   	push   %ebx
  8008b5:	e8 ac 14 00 00       	call   801d66 <memset>
	mtx = NULL;
}
  8008ba:	83 c4 10             	add    $0x10,%esp
  8008bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	05 00 00 00 30       	add    $0x30000000,%eax
  8008cf:	c1 e8 0c             	shr    $0xc,%eax
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	05 00 00 00 30       	add    $0x30000000,%eax
  8008df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8008e9:	5d                   	pop    %ebp
  8008ea:	c3                   	ret    

008008eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8008f6:	89 c2                	mov    %eax,%edx
  8008f8:	c1 ea 16             	shr    $0x16,%edx
  8008fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800902:	f6 c2 01             	test   $0x1,%dl
  800905:	74 11                	je     800918 <fd_alloc+0x2d>
  800907:	89 c2                	mov    %eax,%edx
  800909:	c1 ea 0c             	shr    $0xc,%edx
  80090c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800913:	f6 c2 01             	test   $0x1,%dl
  800916:	75 09                	jne    800921 <fd_alloc+0x36>
			*fd_store = fd;
  800918:	89 01                	mov    %eax,(%ecx)
			return 0;
  80091a:	b8 00 00 00 00       	mov    $0x0,%eax
  80091f:	eb 17                	jmp    800938 <fd_alloc+0x4d>
  800921:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800926:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80092b:	75 c9                	jne    8008f6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80092d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800933:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800940:	83 f8 1f             	cmp    $0x1f,%eax
  800943:	77 36                	ja     80097b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800945:	c1 e0 0c             	shl    $0xc,%eax
  800948:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80094d:	89 c2                	mov    %eax,%edx
  80094f:	c1 ea 16             	shr    $0x16,%edx
  800952:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800959:	f6 c2 01             	test   $0x1,%dl
  80095c:	74 24                	je     800982 <fd_lookup+0x48>
  80095e:	89 c2                	mov    %eax,%edx
  800960:	c1 ea 0c             	shr    $0xc,%edx
  800963:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80096a:	f6 c2 01             	test   $0x1,%dl
  80096d:	74 1a                	je     800989 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80096f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800972:	89 02                	mov    %eax,(%edx)
	return 0;
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
  800979:	eb 13                	jmp    80098e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80097b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800980:	eb 0c                	jmp    80098e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800982:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800987:	eb 05                	jmp    80098e <fd_lookup+0x54>
  800989:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	83 ec 08             	sub    $0x8,%esp
  800996:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800999:	ba 40 25 80 00       	mov    $0x802540,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80099e:	eb 13                	jmp    8009b3 <dev_lookup+0x23>
  8009a0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009a3:	39 08                	cmp    %ecx,(%eax)
  8009a5:	75 0c                	jne    8009b3 <dev_lookup+0x23>
			*dev = devtab[i];
  8009a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009aa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b1:	eb 31                	jmp    8009e4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009b3:	8b 02                	mov    (%edx),%eax
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	75 e7                	jne    8009a0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009b9:	a1 04 40 80 00       	mov    0x804004,%eax
  8009be:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009c4:	83 ec 04             	sub    $0x4,%esp
  8009c7:	51                   	push   %ecx
  8009c8:	50                   	push   %eax
  8009c9:	68 c4 24 80 00       	push   $0x8024c4
  8009ce:	e8 c9 0c 00 00       	call   80169c <cprintf>
	*dev = 0;
  8009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009dc:	83 c4 10             	add    $0x10,%esp
  8009df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	83 ec 10             	sub    $0x10,%esp
  8009ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8009f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009f7:	50                   	push   %eax
  8009f8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8009fe:	c1 e8 0c             	shr    $0xc,%eax
  800a01:	50                   	push   %eax
  800a02:	e8 33 ff ff ff       	call   80093a <fd_lookup>
  800a07:	83 c4 08             	add    $0x8,%esp
  800a0a:	85 c0                	test   %eax,%eax
  800a0c:	78 05                	js     800a13 <fd_close+0x2d>
	    || fd != fd2)
  800a0e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a11:	74 0c                	je     800a1f <fd_close+0x39>
		return (must_exist ? r : 0);
  800a13:	84 db                	test   %bl,%bl
  800a15:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1a:	0f 44 c2             	cmove  %edx,%eax
  800a1d:	eb 41                	jmp    800a60 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a1f:	83 ec 08             	sub    $0x8,%esp
  800a22:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a25:	50                   	push   %eax
  800a26:	ff 36                	pushl  (%esi)
  800a28:	e8 63 ff ff ff       	call   800990 <dev_lookup>
  800a2d:	89 c3                	mov    %eax,%ebx
  800a2f:	83 c4 10             	add    $0x10,%esp
  800a32:	85 c0                	test   %eax,%eax
  800a34:	78 1a                	js     800a50 <fd_close+0x6a>
		if (dev->dev_close)
  800a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a39:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a3c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a41:	85 c0                	test   %eax,%eax
  800a43:	74 0b                	je     800a50 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a45:	83 ec 0c             	sub    $0xc,%esp
  800a48:	56                   	push   %esi
  800a49:	ff d0                	call   *%eax
  800a4b:	89 c3                	mov    %eax,%ebx
  800a4d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a50:	83 ec 08             	sub    $0x8,%esp
  800a53:	56                   	push   %esi
  800a54:	6a 00                	push   $0x0
  800a56:	e8 a3 f7 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800a5b:	83 c4 10             	add    $0x10,%esp
  800a5e:	89 d8                	mov    %ebx,%eax
}
  800a60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a6d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a70:	50                   	push   %eax
  800a71:	ff 75 08             	pushl  0x8(%ebp)
  800a74:	e8 c1 fe ff ff       	call   80093a <fd_lookup>
  800a79:	83 c4 08             	add    $0x8,%esp
  800a7c:	85 c0                	test   %eax,%eax
  800a7e:	78 10                	js     800a90 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a80:	83 ec 08             	sub    $0x8,%esp
  800a83:	6a 01                	push   $0x1
  800a85:	ff 75 f4             	pushl  -0xc(%ebp)
  800a88:	e8 59 ff ff ff       	call   8009e6 <fd_close>
  800a8d:	83 c4 10             	add    $0x10,%esp
}
  800a90:	c9                   	leave  
  800a91:	c3                   	ret    

00800a92 <close_all>:

void
close_all(void)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	53                   	push   %ebx
  800a96:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800a99:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800a9e:	83 ec 0c             	sub    $0xc,%esp
  800aa1:	53                   	push   %ebx
  800aa2:	e8 c0 ff ff ff       	call   800a67 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800aa7:	83 c3 01             	add    $0x1,%ebx
  800aaa:	83 c4 10             	add    $0x10,%esp
  800aad:	83 fb 20             	cmp    $0x20,%ebx
  800ab0:	75 ec                	jne    800a9e <close_all+0xc>
		close(i);
}
  800ab2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    

00800ab7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	83 ec 2c             	sub    $0x2c,%esp
  800ac0:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ac3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ac6:	50                   	push   %eax
  800ac7:	ff 75 08             	pushl  0x8(%ebp)
  800aca:	e8 6b fe ff ff       	call   80093a <fd_lookup>
  800acf:	83 c4 08             	add    $0x8,%esp
  800ad2:	85 c0                	test   %eax,%eax
  800ad4:	0f 88 c1 00 00 00    	js     800b9b <dup+0xe4>
		return r;
	close(newfdnum);
  800ada:	83 ec 0c             	sub    $0xc,%esp
  800add:	56                   	push   %esi
  800ade:	e8 84 ff ff ff       	call   800a67 <close>

	newfd = INDEX2FD(newfdnum);
  800ae3:	89 f3                	mov    %esi,%ebx
  800ae5:	c1 e3 0c             	shl    $0xc,%ebx
  800ae8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800aee:	83 c4 04             	add    $0x4,%esp
  800af1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800af4:	e8 db fd ff ff       	call   8008d4 <fd2data>
  800af9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800afb:	89 1c 24             	mov    %ebx,(%esp)
  800afe:	e8 d1 fd ff ff       	call   8008d4 <fd2data>
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b09:	89 f8                	mov    %edi,%eax
  800b0b:	c1 e8 16             	shr    $0x16,%eax
  800b0e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b15:	a8 01                	test   $0x1,%al
  800b17:	74 37                	je     800b50 <dup+0x99>
  800b19:	89 f8                	mov    %edi,%eax
  800b1b:	c1 e8 0c             	shr    $0xc,%eax
  800b1e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b25:	f6 c2 01             	test   $0x1,%dl
  800b28:	74 26                	je     800b50 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b2a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	25 07 0e 00 00       	and    $0xe07,%eax
  800b39:	50                   	push   %eax
  800b3a:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b3d:	6a 00                	push   $0x0
  800b3f:	57                   	push   %edi
  800b40:	6a 00                	push   $0x0
  800b42:	e8 75 f6 ff ff       	call   8001bc <sys_page_map>
  800b47:	89 c7                	mov    %eax,%edi
  800b49:	83 c4 20             	add    $0x20,%esp
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	78 2e                	js     800b7e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b50:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b53:	89 d0                	mov    %edx,%eax
  800b55:	c1 e8 0c             	shr    $0xc,%eax
  800b58:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b5f:	83 ec 0c             	sub    $0xc,%esp
  800b62:	25 07 0e 00 00       	and    $0xe07,%eax
  800b67:	50                   	push   %eax
  800b68:	53                   	push   %ebx
  800b69:	6a 00                	push   $0x0
  800b6b:	52                   	push   %edx
  800b6c:	6a 00                	push   $0x0
  800b6e:	e8 49 f6 ff ff       	call   8001bc <sys_page_map>
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b78:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b7a:	85 ff                	test   %edi,%edi
  800b7c:	79 1d                	jns    800b9b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b7e:	83 ec 08             	sub    $0x8,%esp
  800b81:	53                   	push   %ebx
  800b82:	6a 00                	push   $0x0
  800b84:	e8 75 f6 ff ff       	call   8001fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b89:	83 c4 08             	add    $0x8,%esp
  800b8c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b8f:	6a 00                	push   $0x0
  800b91:	e8 68 f6 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800b96:	83 c4 10             	add    $0x10,%esp
  800b99:	89 f8                	mov    %edi,%eax
}
  800b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 14             	sub    $0x14,%esp
  800baa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bb0:	50                   	push   %eax
  800bb1:	53                   	push   %ebx
  800bb2:	e8 83 fd ff ff       	call   80093a <fd_lookup>
  800bb7:	83 c4 08             	add    $0x8,%esp
  800bba:	89 c2                	mov    %eax,%edx
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	78 70                	js     800c30 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bc0:	83 ec 08             	sub    $0x8,%esp
  800bc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc6:	50                   	push   %eax
  800bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bca:	ff 30                	pushl  (%eax)
  800bcc:	e8 bf fd ff ff       	call   800990 <dev_lookup>
  800bd1:	83 c4 10             	add    $0x10,%esp
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	78 4f                	js     800c27 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800bd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bdb:	8b 42 08             	mov    0x8(%edx),%eax
  800bde:	83 e0 03             	and    $0x3,%eax
  800be1:	83 f8 01             	cmp    $0x1,%eax
  800be4:	75 24                	jne    800c0a <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800be6:	a1 04 40 80 00       	mov    0x804004,%eax
  800beb:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800bf1:	83 ec 04             	sub    $0x4,%esp
  800bf4:	53                   	push   %ebx
  800bf5:	50                   	push   %eax
  800bf6:	68 05 25 80 00       	push   $0x802505
  800bfb:	e8 9c 0a 00 00       	call   80169c <cprintf>
		return -E_INVAL;
  800c00:	83 c4 10             	add    $0x10,%esp
  800c03:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c08:	eb 26                	jmp    800c30 <read+0x8d>
	}
	if (!dev->dev_read)
  800c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0d:	8b 40 08             	mov    0x8(%eax),%eax
  800c10:	85 c0                	test   %eax,%eax
  800c12:	74 17                	je     800c2b <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c14:	83 ec 04             	sub    $0x4,%esp
  800c17:	ff 75 10             	pushl  0x10(%ebp)
  800c1a:	ff 75 0c             	pushl  0xc(%ebp)
  800c1d:	52                   	push   %edx
  800c1e:	ff d0                	call   *%eax
  800c20:	89 c2                	mov    %eax,%edx
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	eb 09                	jmp    800c30 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c27:	89 c2                	mov    %eax,%edx
  800c29:	eb 05                	jmp    800c30 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c2b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c30:	89 d0                	mov    %edx,%eax
  800c32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c43:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	eb 21                	jmp    800c6e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c4d:	83 ec 04             	sub    $0x4,%esp
  800c50:	89 f0                	mov    %esi,%eax
  800c52:	29 d8                	sub    %ebx,%eax
  800c54:	50                   	push   %eax
  800c55:	89 d8                	mov    %ebx,%eax
  800c57:	03 45 0c             	add    0xc(%ebp),%eax
  800c5a:	50                   	push   %eax
  800c5b:	57                   	push   %edi
  800c5c:	e8 42 ff ff ff       	call   800ba3 <read>
		if (m < 0)
  800c61:	83 c4 10             	add    $0x10,%esp
  800c64:	85 c0                	test   %eax,%eax
  800c66:	78 10                	js     800c78 <readn+0x41>
			return m;
		if (m == 0)
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	74 0a                	je     800c76 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c6c:	01 c3                	add    %eax,%ebx
  800c6e:	39 f3                	cmp    %esi,%ebx
  800c70:	72 db                	jb     800c4d <readn+0x16>
  800c72:	89 d8                	mov    %ebx,%eax
  800c74:	eb 02                	jmp    800c78 <readn+0x41>
  800c76:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	53                   	push   %ebx
  800c84:	83 ec 14             	sub    $0x14,%esp
  800c87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c8a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c8d:	50                   	push   %eax
  800c8e:	53                   	push   %ebx
  800c8f:	e8 a6 fc ff ff       	call   80093a <fd_lookup>
  800c94:	83 c4 08             	add    $0x8,%esp
  800c97:	89 c2                	mov    %eax,%edx
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	78 6b                	js     800d08 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c9d:	83 ec 08             	sub    $0x8,%esp
  800ca0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca3:	50                   	push   %eax
  800ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca7:	ff 30                	pushl  (%eax)
  800ca9:	e8 e2 fc ff ff       	call   800990 <dev_lookup>
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	78 4a                	js     800cff <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cb8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cbc:	75 24                	jne    800ce2 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800cbe:	a1 04 40 80 00       	mov    0x804004,%eax
  800cc3:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800cc9:	83 ec 04             	sub    $0x4,%esp
  800ccc:	53                   	push   %ebx
  800ccd:	50                   	push   %eax
  800cce:	68 21 25 80 00       	push   $0x802521
  800cd3:	e8 c4 09 00 00       	call   80169c <cprintf>
		return -E_INVAL;
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ce0:	eb 26                	jmp    800d08 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ce2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ce5:	8b 52 0c             	mov    0xc(%edx),%edx
  800ce8:	85 d2                	test   %edx,%edx
  800cea:	74 17                	je     800d03 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800cec:	83 ec 04             	sub    $0x4,%esp
  800cef:	ff 75 10             	pushl  0x10(%ebp)
  800cf2:	ff 75 0c             	pushl  0xc(%ebp)
  800cf5:	50                   	push   %eax
  800cf6:	ff d2                	call   *%edx
  800cf8:	89 c2                	mov    %eax,%edx
  800cfa:	83 c4 10             	add    $0x10,%esp
  800cfd:	eb 09                	jmp    800d08 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cff:	89 c2                	mov    %eax,%edx
  800d01:	eb 05                	jmp    800d08 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d03:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d08:	89 d0                	mov    %edx,%eax
  800d0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d0d:	c9                   	leave  
  800d0e:	c3                   	ret    

00800d0f <seek>:

int
seek(int fdnum, off_t offset)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d15:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d18:	50                   	push   %eax
  800d19:	ff 75 08             	pushl  0x8(%ebp)
  800d1c:	e8 19 fc ff ff       	call   80093a <fd_lookup>
  800d21:	83 c4 08             	add    $0x8,%esp
  800d24:	85 c0                	test   %eax,%eax
  800d26:	78 0e                	js     800d36 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d28:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d2e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 14             	sub    $0x14,%esp
  800d3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d45:	50                   	push   %eax
  800d46:	53                   	push   %ebx
  800d47:	e8 ee fb ff ff       	call   80093a <fd_lookup>
  800d4c:	83 c4 08             	add    $0x8,%esp
  800d4f:	89 c2                	mov    %eax,%edx
  800d51:	85 c0                	test   %eax,%eax
  800d53:	78 68                	js     800dbd <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d55:	83 ec 08             	sub    $0x8,%esp
  800d58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5b:	50                   	push   %eax
  800d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d5f:	ff 30                	pushl  (%eax)
  800d61:	e8 2a fc ff ff       	call   800990 <dev_lookup>
  800d66:	83 c4 10             	add    $0x10,%esp
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	78 47                	js     800db4 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d70:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d74:	75 24                	jne    800d9a <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d76:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d7b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d81:	83 ec 04             	sub    $0x4,%esp
  800d84:	53                   	push   %ebx
  800d85:	50                   	push   %eax
  800d86:	68 e4 24 80 00       	push   $0x8024e4
  800d8b:	e8 0c 09 00 00       	call   80169c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d90:	83 c4 10             	add    $0x10,%esp
  800d93:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d98:	eb 23                	jmp    800dbd <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800d9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d9d:	8b 52 18             	mov    0x18(%edx),%edx
  800da0:	85 d2                	test   %edx,%edx
  800da2:	74 14                	je     800db8 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800da4:	83 ec 08             	sub    $0x8,%esp
  800da7:	ff 75 0c             	pushl  0xc(%ebp)
  800daa:	50                   	push   %eax
  800dab:	ff d2                	call   *%edx
  800dad:	89 c2                	mov    %eax,%edx
  800daf:	83 c4 10             	add    $0x10,%esp
  800db2:	eb 09                	jmp    800dbd <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800db4:	89 c2                	mov    %eax,%edx
  800db6:	eb 05                	jmp    800dbd <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800db8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dbd:	89 d0                	mov    %edx,%eax
  800dbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc2:	c9                   	leave  
  800dc3:	c3                   	ret    

00800dc4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 14             	sub    $0x14,%esp
  800dcb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd1:	50                   	push   %eax
  800dd2:	ff 75 08             	pushl  0x8(%ebp)
  800dd5:	e8 60 fb ff ff       	call   80093a <fd_lookup>
  800dda:	83 c4 08             	add    $0x8,%esp
  800ddd:	89 c2                	mov    %eax,%edx
  800ddf:	85 c0                	test   %eax,%eax
  800de1:	78 58                	js     800e3b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800de3:	83 ec 08             	sub    $0x8,%esp
  800de6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800de9:	50                   	push   %eax
  800dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ded:	ff 30                	pushl  (%eax)
  800def:	e8 9c fb ff ff       	call   800990 <dev_lookup>
  800df4:	83 c4 10             	add    $0x10,%esp
  800df7:	85 c0                	test   %eax,%eax
  800df9:	78 37                	js     800e32 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e02:	74 32                	je     800e36 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e04:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e07:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e0e:	00 00 00 
	stat->st_isdir = 0;
  800e11:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e18:	00 00 00 
	stat->st_dev = dev;
  800e1b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e21:	83 ec 08             	sub    $0x8,%esp
  800e24:	53                   	push   %ebx
  800e25:	ff 75 f0             	pushl  -0x10(%ebp)
  800e28:	ff 50 14             	call   *0x14(%eax)
  800e2b:	89 c2                	mov    %eax,%edx
  800e2d:	83 c4 10             	add    $0x10,%esp
  800e30:	eb 09                	jmp    800e3b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e32:	89 c2                	mov    %eax,%edx
  800e34:	eb 05                	jmp    800e3b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e36:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e3b:	89 d0                	mov    %edx,%eax
  800e3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e47:	83 ec 08             	sub    $0x8,%esp
  800e4a:	6a 00                	push   $0x0
  800e4c:	ff 75 08             	pushl  0x8(%ebp)
  800e4f:	e8 e3 01 00 00       	call   801037 <open>
  800e54:	89 c3                	mov    %eax,%ebx
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	78 1b                	js     800e78 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	ff 75 0c             	pushl  0xc(%ebp)
  800e63:	50                   	push   %eax
  800e64:	e8 5b ff ff ff       	call   800dc4 <fstat>
  800e69:	89 c6                	mov    %eax,%esi
	close(fd);
  800e6b:	89 1c 24             	mov    %ebx,(%esp)
  800e6e:	e8 f4 fb ff ff       	call   800a67 <close>
	return r;
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	89 f0                	mov    %esi,%eax
}
  800e78:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7b:	5b                   	pop    %ebx
  800e7c:	5e                   	pop    %esi
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    

00800e7f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	89 c6                	mov    %eax,%esi
  800e86:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e88:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e8f:	75 12                	jne    800ea3 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e91:	83 ec 0c             	sub    $0xc,%esp
  800e94:	6a 01                	push   $0x1
  800e96:	e8 39 12 00 00       	call   8020d4 <ipc_find_env>
  800e9b:	a3 00 40 80 00       	mov    %eax,0x804000
  800ea0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ea3:	6a 07                	push   $0x7
  800ea5:	68 00 50 80 00       	push   $0x805000
  800eaa:	56                   	push   %esi
  800eab:	ff 35 00 40 80 00    	pushl  0x804000
  800eb1:	e8 bc 11 00 00       	call   802072 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800eb6:	83 c4 0c             	add    $0xc,%esp
  800eb9:	6a 00                	push   $0x0
  800ebb:	53                   	push   %ebx
  800ebc:	6a 00                	push   $0x0
  800ebe:	e8 34 11 00 00       	call   801ff7 <ipc_recv>
}
  800ec3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed3:	8b 40 0c             	mov    0xc(%eax),%eax
  800ed6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ede:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ee3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee8:	b8 02 00 00 00       	mov    $0x2,%eax
  800eed:	e8 8d ff ff ff       	call   800e7f <fsipc>
}
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800efa:	8b 45 08             	mov    0x8(%ebp),%eax
  800efd:	8b 40 0c             	mov    0xc(%eax),%eax
  800f00:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f05:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0f:	e8 6b ff ff ff       	call   800e7f <fsipc>
}
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    

00800f16 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 04             	sub    $0x4,%esp
  800f1d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f20:	8b 45 08             	mov    0x8(%ebp),%eax
  800f23:	8b 40 0c             	mov    0xc(%eax),%eax
  800f26:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f30:	b8 05 00 00 00       	mov    $0x5,%eax
  800f35:	e8 45 ff ff ff       	call   800e7f <fsipc>
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	78 2c                	js     800f6a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	68 00 50 80 00       	push   $0x805000
  800f46:	53                   	push   %ebx
  800f47:	e8 d5 0c 00 00       	call   801c21 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f4c:	a1 80 50 80 00       	mov    0x805080,%eax
  800f51:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f57:	a1 84 50 80 00       	mov    0x805084,%eax
  800f5c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f62:	83 c4 10             	add    $0x10,%esp
  800f65:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    

00800f6f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 0c             	sub    $0xc,%esp
  800f75:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f78:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7b:	8b 52 0c             	mov    0xc(%edx),%edx
  800f7e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f84:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f89:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800f8e:	0f 47 c2             	cmova  %edx,%eax
  800f91:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800f96:	50                   	push   %eax
  800f97:	ff 75 0c             	pushl  0xc(%ebp)
  800f9a:	68 08 50 80 00       	push   $0x805008
  800f9f:	e8 0f 0e 00 00       	call   801db3 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fa4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa9:	b8 04 00 00 00       	mov    $0x4,%eax
  800fae:	e8 cc fe ff ff       	call   800e7f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
  800fba:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc0:	8b 40 0c             	mov    0xc(%eax),%eax
  800fc3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fc8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fce:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800fd8:	e8 a2 fe ff ff       	call   800e7f <fsipc>
  800fdd:	89 c3                	mov    %eax,%ebx
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	78 4b                	js     80102e <devfile_read+0x79>
		return r;
	assert(r <= n);
  800fe3:	39 c6                	cmp    %eax,%esi
  800fe5:	73 16                	jae    800ffd <devfile_read+0x48>
  800fe7:	68 50 25 80 00       	push   $0x802550
  800fec:	68 57 25 80 00       	push   $0x802557
  800ff1:	6a 7c                	push   $0x7c
  800ff3:	68 6c 25 80 00       	push   $0x80256c
  800ff8:	e8 c6 05 00 00       	call   8015c3 <_panic>
	assert(r <= PGSIZE);
  800ffd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801002:	7e 16                	jle    80101a <devfile_read+0x65>
  801004:	68 77 25 80 00       	push   $0x802577
  801009:	68 57 25 80 00       	push   $0x802557
  80100e:	6a 7d                	push   $0x7d
  801010:	68 6c 25 80 00       	push   $0x80256c
  801015:	e8 a9 05 00 00       	call   8015c3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80101a:	83 ec 04             	sub    $0x4,%esp
  80101d:	50                   	push   %eax
  80101e:	68 00 50 80 00       	push   $0x805000
  801023:	ff 75 0c             	pushl  0xc(%ebp)
  801026:	e8 88 0d 00 00       	call   801db3 <memmove>
	return r;
  80102b:	83 c4 10             	add    $0x10,%esp
}
  80102e:	89 d8                	mov    %ebx,%eax
  801030:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	53                   	push   %ebx
  80103b:	83 ec 20             	sub    $0x20,%esp
  80103e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801041:	53                   	push   %ebx
  801042:	e8 a1 0b 00 00       	call   801be8 <strlen>
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80104f:	7f 67                	jg     8010b8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801057:	50                   	push   %eax
  801058:	e8 8e f8 ff ff       	call   8008eb <fd_alloc>
  80105d:	83 c4 10             	add    $0x10,%esp
		return r;
  801060:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801062:	85 c0                	test   %eax,%eax
  801064:	78 57                	js     8010bd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801066:	83 ec 08             	sub    $0x8,%esp
  801069:	53                   	push   %ebx
  80106a:	68 00 50 80 00       	push   $0x805000
  80106f:	e8 ad 0b 00 00       	call   801c21 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801074:	8b 45 0c             	mov    0xc(%ebp),%eax
  801077:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80107c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80107f:	b8 01 00 00 00       	mov    $0x1,%eax
  801084:	e8 f6 fd ff ff       	call   800e7f <fsipc>
  801089:	89 c3                	mov    %eax,%ebx
  80108b:	83 c4 10             	add    $0x10,%esp
  80108e:	85 c0                	test   %eax,%eax
  801090:	79 14                	jns    8010a6 <open+0x6f>
		fd_close(fd, 0);
  801092:	83 ec 08             	sub    $0x8,%esp
  801095:	6a 00                	push   $0x0
  801097:	ff 75 f4             	pushl  -0xc(%ebp)
  80109a:	e8 47 f9 ff ff       	call   8009e6 <fd_close>
		return r;
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	89 da                	mov    %ebx,%edx
  8010a4:	eb 17                	jmp    8010bd <open+0x86>
	}

	return fd2num(fd);
  8010a6:	83 ec 0c             	sub    $0xc,%esp
  8010a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ac:	e8 13 f8 ff ff       	call   8008c4 <fd2num>
  8010b1:	89 c2                	mov    %eax,%edx
  8010b3:	83 c4 10             	add    $0x10,%esp
  8010b6:	eb 05                	jmp    8010bd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010b8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010bd:	89 d0                	mov    %edx,%eax
  8010bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8010cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8010d4:	e8 a6 fd ff ff       	call   800e7f <fsipc>
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	56                   	push   %esi
  8010df:	53                   	push   %ebx
  8010e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	ff 75 08             	pushl  0x8(%ebp)
  8010e9:	e8 e6 f7 ff ff       	call   8008d4 <fd2data>
  8010ee:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010f0:	83 c4 08             	add    $0x8,%esp
  8010f3:	68 83 25 80 00       	push   $0x802583
  8010f8:	53                   	push   %ebx
  8010f9:	e8 23 0b 00 00       	call   801c21 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010fe:	8b 46 04             	mov    0x4(%esi),%eax
  801101:	2b 06                	sub    (%esi),%eax
  801103:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801109:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801110:	00 00 00 
	stat->st_dev = &devpipe;
  801113:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80111a:	30 80 00 
	return 0;
}
  80111d:	b8 00 00 00 00       	mov    $0x0,%eax
  801122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	53                   	push   %ebx
  80112d:	83 ec 0c             	sub    $0xc,%esp
  801130:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801133:	53                   	push   %ebx
  801134:	6a 00                	push   $0x0
  801136:	e8 c3 f0 ff ff       	call   8001fe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80113b:	89 1c 24             	mov    %ebx,(%esp)
  80113e:	e8 91 f7 ff ff       	call   8008d4 <fd2data>
  801143:	83 c4 08             	add    $0x8,%esp
  801146:	50                   	push   %eax
  801147:	6a 00                	push   $0x0
  801149:	e8 b0 f0 ff ff       	call   8001fe <sys_page_unmap>
}
  80114e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801151:	c9                   	leave  
  801152:	c3                   	ret    

00801153 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	53                   	push   %ebx
  801159:	83 ec 1c             	sub    $0x1c,%esp
  80115c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80115f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801161:	a1 04 40 80 00       	mov    0x804004,%eax
  801166:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	ff 75 e0             	pushl  -0x20(%ebp)
  801172:	e8 a2 0f 00 00       	call   802119 <pageref>
  801177:	89 c3                	mov    %eax,%ebx
  801179:	89 3c 24             	mov    %edi,(%esp)
  80117c:	e8 98 0f 00 00       	call   802119 <pageref>
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	39 c3                	cmp    %eax,%ebx
  801186:	0f 94 c1             	sete   %cl
  801189:	0f b6 c9             	movzbl %cl,%ecx
  80118c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80118f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801195:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  80119b:	39 ce                	cmp    %ecx,%esi
  80119d:	74 1e                	je     8011bd <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  80119f:	39 c3                	cmp    %eax,%ebx
  8011a1:	75 be                	jne    801161 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011a3:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ac:	50                   	push   %eax
  8011ad:	56                   	push   %esi
  8011ae:	68 8a 25 80 00       	push   $0x80258a
  8011b3:	e8 e4 04 00 00       	call   80169c <cprintf>
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	eb a4                	jmp    801161 <_pipeisclosed+0xe>
	}
}
  8011bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	57                   	push   %edi
  8011cc:	56                   	push   %esi
  8011cd:	53                   	push   %ebx
  8011ce:	83 ec 28             	sub    $0x28,%esp
  8011d1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011d4:	56                   	push   %esi
  8011d5:	e8 fa f6 ff ff       	call   8008d4 <fd2data>
  8011da:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e4:	eb 4b                	jmp    801231 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011e6:	89 da                	mov    %ebx,%edx
  8011e8:	89 f0                	mov    %esi,%eax
  8011ea:	e8 64 ff ff ff       	call   801153 <_pipeisclosed>
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	75 48                	jne    80123b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011f3:	e8 62 ef ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011f8:	8b 43 04             	mov    0x4(%ebx),%eax
  8011fb:	8b 0b                	mov    (%ebx),%ecx
  8011fd:	8d 51 20             	lea    0x20(%ecx),%edx
  801200:	39 d0                	cmp    %edx,%eax
  801202:	73 e2                	jae    8011e6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801207:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80120b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80120e:	89 c2                	mov    %eax,%edx
  801210:	c1 fa 1f             	sar    $0x1f,%edx
  801213:	89 d1                	mov    %edx,%ecx
  801215:	c1 e9 1b             	shr    $0x1b,%ecx
  801218:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80121b:	83 e2 1f             	and    $0x1f,%edx
  80121e:	29 ca                	sub    %ecx,%edx
  801220:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801224:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801228:	83 c0 01             	add    $0x1,%eax
  80122b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80122e:	83 c7 01             	add    $0x1,%edi
  801231:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801234:	75 c2                	jne    8011f8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801236:	8b 45 10             	mov    0x10(%ebp),%eax
  801239:	eb 05                	jmp    801240 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801243:	5b                   	pop    %ebx
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	57                   	push   %edi
  80124c:	56                   	push   %esi
  80124d:	53                   	push   %ebx
  80124e:	83 ec 18             	sub    $0x18,%esp
  801251:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801254:	57                   	push   %edi
  801255:	e8 7a f6 ff ff       	call   8008d4 <fd2data>
  80125a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801264:	eb 3d                	jmp    8012a3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801266:	85 db                	test   %ebx,%ebx
  801268:	74 04                	je     80126e <devpipe_read+0x26>
				return i;
  80126a:	89 d8                	mov    %ebx,%eax
  80126c:	eb 44                	jmp    8012b2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80126e:	89 f2                	mov    %esi,%edx
  801270:	89 f8                	mov    %edi,%eax
  801272:	e8 dc fe ff ff       	call   801153 <_pipeisclosed>
  801277:	85 c0                	test   %eax,%eax
  801279:	75 32                	jne    8012ad <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80127b:	e8 da ee ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801280:	8b 06                	mov    (%esi),%eax
  801282:	3b 46 04             	cmp    0x4(%esi),%eax
  801285:	74 df                	je     801266 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801287:	99                   	cltd   
  801288:	c1 ea 1b             	shr    $0x1b,%edx
  80128b:	01 d0                	add    %edx,%eax
  80128d:	83 e0 1f             	and    $0x1f,%eax
  801290:	29 d0                	sub    %edx,%eax
  801292:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801297:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80129d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012a0:	83 c3 01             	add    $0x1,%ebx
  8012a3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012a6:	75 d8                	jne    801280 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ab:	eb 05                	jmp    8012b2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012ad:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5e                   	pop    %esi
  8012b7:	5f                   	pop    %edi
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    

008012ba <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	56                   	push   %esi
  8012be:	53                   	push   %ebx
  8012bf:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	e8 20 f6 ff ff       	call   8008eb <fd_alloc>
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	85 c0                	test   %eax,%eax
  8012d2:	0f 88 2c 01 00 00    	js     801404 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012d8:	83 ec 04             	sub    $0x4,%esp
  8012db:	68 07 04 00 00       	push   $0x407
  8012e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e3:	6a 00                	push   $0x0
  8012e5:	e8 8f ee ff ff       	call   800179 <sys_page_alloc>
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	89 c2                	mov    %eax,%edx
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	0f 88 0d 01 00 00    	js     801404 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012f7:	83 ec 0c             	sub    $0xc,%esp
  8012fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fd:	50                   	push   %eax
  8012fe:	e8 e8 f5 ff ff       	call   8008eb <fd_alloc>
  801303:	89 c3                	mov    %eax,%ebx
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	0f 88 e2 00 00 00    	js     8013f2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801310:	83 ec 04             	sub    $0x4,%esp
  801313:	68 07 04 00 00       	push   $0x407
  801318:	ff 75 f0             	pushl  -0x10(%ebp)
  80131b:	6a 00                	push   $0x0
  80131d:	e8 57 ee ff ff       	call   800179 <sys_page_alloc>
  801322:	89 c3                	mov    %eax,%ebx
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	0f 88 c3 00 00 00    	js     8013f2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80132f:	83 ec 0c             	sub    $0xc,%esp
  801332:	ff 75 f4             	pushl  -0xc(%ebp)
  801335:	e8 9a f5 ff ff       	call   8008d4 <fd2data>
  80133a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80133c:	83 c4 0c             	add    $0xc,%esp
  80133f:	68 07 04 00 00       	push   $0x407
  801344:	50                   	push   %eax
  801345:	6a 00                	push   $0x0
  801347:	e8 2d ee ff ff       	call   800179 <sys_page_alloc>
  80134c:	89 c3                	mov    %eax,%ebx
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	85 c0                	test   %eax,%eax
  801353:	0f 88 89 00 00 00    	js     8013e2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801359:	83 ec 0c             	sub    $0xc,%esp
  80135c:	ff 75 f0             	pushl  -0x10(%ebp)
  80135f:	e8 70 f5 ff ff       	call   8008d4 <fd2data>
  801364:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80136b:	50                   	push   %eax
  80136c:	6a 00                	push   $0x0
  80136e:	56                   	push   %esi
  80136f:	6a 00                	push   $0x0
  801371:	e8 46 ee ff ff       	call   8001bc <sys_page_map>
  801376:	89 c3                	mov    %eax,%ebx
  801378:	83 c4 20             	add    $0x20,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 55                	js     8013d4 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80137f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801385:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801388:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80138a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801394:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80139a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80139f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013a9:	83 ec 0c             	sub    $0xc,%esp
  8013ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8013af:	e8 10 f5 ff ff       	call   8008c4 <fd2num>
  8013b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013b9:	83 c4 04             	add    $0x4,%esp
  8013bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8013bf:	e8 00 f5 ff ff       	call   8008c4 <fd2num>
  8013c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c7:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d2:	eb 30                	jmp    801404 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	56                   	push   %esi
  8013d8:	6a 00                	push   $0x0
  8013da:	e8 1f ee ff ff       	call   8001fe <sys_page_unmap>
  8013df:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e8:	6a 00                	push   $0x0
  8013ea:	e8 0f ee ff ff       	call   8001fe <sys_page_unmap>
  8013ef:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8013f8:	6a 00                	push   $0x0
  8013fa:	e8 ff ed ff ff       	call   8001fe <sys_page_unmap>
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801404:	89 d0                	mov    %edx,%eax
  801406:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801409:	5b                   	pop    %ebx
  80140a:	5e                   	pop    %esi
  80140b:	5d                   	pop    %ebp
  80140c:	c3                   	ret    

0080140d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801413:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801416:	50                   	push   %eax
  801417:	ff 75 08             	pushl  0x8(%ebp)
  80141a:	e8 1b f5 ff ff       	call   80093a <fd_lookup>
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	78 18                	js     80143e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	ff 75 f4             	pushl  -0xc(%ebp)
  80142c:	e8 a3 f4 ff ff       	call   8008d4 <fd2data>
	return _pipeisclosed(fd, p);
  801431:	89 c2                	mov    %eax,%edx
  801433:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801436:	e8 18 fd ff ff       	call   801153 <_pipeisclosed>
  80143b:	83 c4 10             	add    $0x10,%esp
}
  80143e:	c9                   	leave  
  80143f:	c3                   	ret    

00801440 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801443:	b8 00 00 00 00       	mov    $0x0,%eax
  801448:	5d                   	pop    %ebp
  801449:	c3                   	ret    

0080144a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80144a:	55                   	push   %ebp
  80144b:	89 e5                	mov    %esp,%ebp
  80144d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801450:	68 a2 25 80 00       	push   $0x8025a2
  801455:	ff 75 0c             	pushl  0xc(%ebp)
  801458:	e8 c4 07 00 00       	call   801c21 <strcpy>
	return 0;
}
  80145d:	b8 00 00 00 00       	mov    $0x0,%eax
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	57                   	push   %edi
  801468:	56                   	push   %esi
  801469:	53                   	push   %ebx
  80146a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801470:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801475:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80147b:	eb 2d                	jmp    8014aa <devcons_write+0x46>
		m = n - tot;
  80147d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801480:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801482:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801485:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80148a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80148d:	83 ec 04             	sub    $0x4,%esp
  801490:	53                   	push   %ebx
  801491:	03 45 0c             	add    0xc(%ebp),%eax
  801494:	50                   	push   %eax
  801495:	57                   	push   %edi
  801496:	e8 18 09 00 00       	call   801db3 <memmove>
		sys_cputs(buf, m);
  80149b:	83 c4 08             	add    $0x8,%esp
  80149e:	53                   	push   %ebx
  80149f:	57                   	push   %edi
  8014a0:	e8 18 ec ff ff       	call   8000bd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014a5:	01 de                	add    %ebx,%esi
  8014a7:	83 c4 10             	add    $0x10,%esp
  8014aa:	89 f0                	mov    %esi,%eax
  8014ac:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014af:	72 cc                	jb     80147d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b4:	5b                   	pop    %ebx
  8014b5:	5e                   	pop    %esi
  8014b6:	5f                   	pop    %edi
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    

008014b9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014c4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014c8:	74 2a                	je     8014f4 <devcons_read+0x3b>
  8014ca:	eb 05                	jmp    8014d1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014cc:	e8 89 ec ff ff       	call   80015a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014d1:	e8 05 ec ff ff       	call   8000db <sys_cgetc>
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	74 f2                	je     8014cc <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 16                	js     8014f4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014de:	83 f8 04             	cmp    $0x4,%eax
  8014e1:	74 0c                	je     8014ef <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e6:	88 02                	mov    %al,(%edx)
	return 1;
  8014e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ed:	eb 05                	jmp    8014f4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014ef:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ff:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801502:	6a 01                	push   $0x1
  801504:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801507:	50                   	push   %eax
  801508:	e8 b0 eb ff ff       	call   8000bd <sys_cputs>
}
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	c9                   	leave  
  801511:	c3                   	ret    

00801512 <getchar>:

int
getchar(void)
{
  801512:	55                   	push   %ebp
  801513:	89 e5                	mov    %esp,%ebp
  801515:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801518:	6a 01                	push   $0x1
  80151a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	6a 00                	push   $0x0
  801520:	e8 7e f6 ff ff       	call   800ba3 <read>
	if (r < 0)
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 0f                	js     80153b <getchar+0x29>
		return r;
	if (r < 1)
  80152c:	85 c0                	test   %eax,%eax
  80152e:	7e 06                	jle    801536 <getchar+0x24>
		return -E_EOF;
	return c;
  801530:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801534:	eb 05                	jmp    80153b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801536:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801543:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801546:	50                   	push   %eax
  801547:	ff 75 08             	pushl  0x8(%ebp)
  80154a:	e8 eb f3 ff ff       	call   80093a <fd_lookup>
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	85 c0                	test   %eax,%eax
  801554:	78 11                	js     801567 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801556:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801559:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80155f:	39 10                	cmp    %edx,(%eax)
  801561:	0f 94 c0             	sete   %al
  801564:	0f b6 c0             	movzbl %al,%eax
}
  801567:	c9                   	leave  
  801568:	c3                   	ret    

00801569 <opencons>:

int
opencons(void)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80156f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801572:	50                   	push   %eax
  801573:	e8 73 f3 ff ff       	call   8008eb <fd_alloc>
  801578:	83 c4 10             	add    $0x10,%esp
		return r;
  80157b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 3e                	js     8015bf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801581:	83 ec 04             	sub    $0x4,%esp
  801584:	68 07 04 00 00       	push   $0x407
  801589:	ff 75 f4             	pushl  -0xc(%ebp)
  80158c:	6a 00                	push   $0x0
  80158e:	e8 e6 eb ff ff       	call   800179 <sys_page_alloc>
  801593:	83 c4 10             	add    $0x10,%esp
		return r;
  801596:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 23                	js     8015bf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80159c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015b1:	83 ec 0c             	sub    $0xc,%esp
  8015b4:	50                   	push   %eax
  8015b5:	e8 0a f3 ff ff       	call   8008c4 <fd2num>
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	83 c4 10             	add    $0x10,%esp
}
  8015bf:	89 d0                	mov    %edx,%eax
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015c8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015cb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015d1:	e8 65 eb ff ff       	call   80013b <sys_getenvid>
  8015d6:	83 ec 0c             	sub    $0xc,%esp
  8015d9:	ff 75 0c             	pushl  0xc(%ebp)
  8015dc:	ff 75 08             	pushl  0x8(%ebp)
  8015df:	56                   	push   %esi
  8015e0:	50                   	push   %eax
  8015e1:	68 b0 25 80 00       	push   $0x8025b0
  8015e6:	e8 b1 00 00 00       	call   80169c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015eb:	83 c4 18             	add    $0x18,%esp
  8015ee:	53                   	push   %ebx
  8015ef:	ff 75 10             	pushl  0x10(%ebp)
  8015f2:	e8 54 00 00 00       	call   80164b <vcprintf>
	cprintf("\n");
  8015f7:	c7 04 24 a6 24 80 00 	movl   $0x8024a6,(%esp)
  8015fe:	e8 99 00 00 00       	call   80169c <cprintf>
  801603:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801606:	cc                   	int3   
  801607:	eb fd                	jmp    801606 <_panic+0x43>

00801609 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	53                   	push   %ebx
  80160d:	83 ec 04             	sub    $0x4,%esp
  801610:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801613:	8b 13                	mov    (%ebx),%edx
  801615:	8d 42 01             	lea    0x1(%edx),%eax
  801618:	89 03                	mov    %eax,(%ebx)
  80161a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80161d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801621:	3d ff 00 00 00       	cmp    $0xff,%eax
  801626:	75 1a                	jne    801642 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	68 ff 00 00 00       	push   $0xff
  801630:	8d 43 08             	lea    0x8(%ebx),%eax
  801633:	50                   	push   %eax
  801634:	e8 84 ea ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  801639:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80163f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801642:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801646:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801649:	c9                   	leave  
  80164a:	c3                   	ret    

0080164b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801654:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80165b:	00 00 00 
	b.cnt = 0;
  80165e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801665:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801668:	ff 75 0c             	pushl  0xc(%ebp)
  80166b:	ff 75 08             	pushl  0x8(%ebp)
  80166e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801674:	50                   	push   %eax
  801675:	68 09 16 80 00       	push   $0x801609
  80167a:	e8 54 01 00 00       	call   8017d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80167f:	83 c4 08             	add    $0x8,%esp
  801682:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801688:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80168e:	50                   	push   %eax
  80168f:	e8 29 ea ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  801694:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016a2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016a5:	50                   	push   %eax
  8016a6:	ff 75 08             	pushl  0x8(%ebp)
  8016a9:	e8 9d ff ff ff       	call   80164b <vcprintf>
	va_end(ap);

	return cnt;
}
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	57                   	push   %edi
  8016b4:	56                   	push   %esi
  8016b5:	53                   	push   %ebx
  8016b6:	83 ec 1c             	sub    $0x1c,%esp
  8016b9:	89 c7                	mov    %eax,%edi
  8016bb:	89 d6                	mov    %edx,%esi
  8016bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016c9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016d4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016d7:	39 d3                	cmp    %edx,%ebx
  8016d9:	72 05                	jb     8016e0 <printnum+0x30>
  8016db:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016de:	77 45                	ja     801725 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016e0:	83 ec 0c             	sub    $0xc,%esp
  8016e3:	ff 75 18             	pushl  0x18(%ebp)
  8016e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016ec:	53                   	push   %ebx
  8016ed:	ff 75 10             	pushl  0x10(%ebp)
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8016f9:	ff 75 dc             	pushl  -0x24(%ebp)
  8016fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8016ff:	e8 5c 0a 00 00       	call   802160 <__udivdi3>
  801704:	83 c4 18             	add    $0x18,%esp
  801707:	52                   	push   %edx
  801708:	50                   	push   %eax
  801709:	89 f2                	mov    %esi,%edx
  80170b:	89 f8                	mov    %edi,%eax
  80170d:	e8 9e ff ff ff       	call   8016b0 <printnum>
  801712:	83 c4 20             	add    $0x20,%esp
  801715:	eb 18                	jmp    80172f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	56                   	push   %esi
  80171b:	ff 75 18             	pushl  0x18(%ebp)
  80171e:	ff d7                	call   *%edi
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	eb 03                	jmp    801728 <printnum+0x78>
  801725:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801728:	83 eb 01             	sub    $0x1,%ebx
  80172b:	85 db                	test   %ebx,%ebx
  80172d:	7f e8                	jg     801717 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80172f:	83 ec 08             	sub    $0x8,%esp
  801732:	56                   	push   %esi
  801733:	83 ec 04             	sub    $0x4,%esp
  801736:	ff 75 e4             	pushl  -0x1c(%ebp)
  801739:	ff 75 e0             	pushl  -0x20(%ebp)
  80173c:	ff 75 dc             	pushl  -0x24(%ebp)
  80173f:	ff 75 d8             	pushl  -0x28(%ebp)
  801742:	e8 49 0b 00 00       	call   802290 <__umoddi3>
  801747:	83 c4 14             	add    $0x14,%esp
  80174a:	0f be 80 d3 25 80 00 	movsbl 0x8025d3(%eax),%eax
  801751:	50                   	push   %eax
  801752:	ff d7                	call   *%edi
}
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175a:	5b                   	pop    %ebx
  80175b:	5e                   	pop    %esi
  80175c:	5f                   	pop    %edi
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801762:	83 fa 01             	cmp    $0x1,%edx
  801765:	7e 0e                	jle    801775 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801767:	8b 10                	mov    (%eax),%edx
  801769:	8d 4a 08             	lea    0x8(%edx),%ecx
  80176c:	89 08                	mov    %ecx,(%eax)
  80176e:	8b 02                	mov    (%edx),%eax
  801770:	8b 52 04             	mov    0x4(%edx),%edx
  801773:	eb 22                	jmp    801797 <getuint+0x38>
	else if (lflag)
  801775:	85 d2                	test   %edx,%edx
  801777:	74 10                	je     801789 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801779:	8b 10                	mov    (%eax),%edx
  80177b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80177e:	89 08                	mov    %ecx,(%eax)
  801780:	8b 02                	mov    (%edx),%eax
  801782:	ba 00 00 00 00       	mov    $0x0,%edx
  801787:	eb 0e                	jmp    801797 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801789:	8b 10                	mov    (%eax),%edx
  80178b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80178e:	89 08                	mov    %ecx,(%eax)
  801790:	8b 02                	mov    (%edx),%eax
  801792:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80179f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017a3:	8b 10                	mov    (%eax),%edx
  8017a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8017a8:	73 0a                	jae    8017b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017ad:	89 08                	mov    %ecx,(%eax)
  8017af:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b2:	88 02                	mov    %al,(%edx)
}
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017bf:	50                   	push   %eax
  8017c0:	ff 75 10             	pushl  0x10(%ebp)
  8017c3:	ff 75 0c             	pushl  0xc(%ebp)
  8017c6:	ff 75 08             	pushl  0x8(%ebp)
  8017c9:	e8 05 00 00 00       	call   8017d3 <vprintfmt>
	va_end(ap);
}
  8017ce:	83 c4 10             	add    $0x10,%esp
  8017d1:	c9                   	leave  
  8017d2:	c3                   	ret    

008017d3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	57                   	push   %edi
  8017d7:	56                   	push   %esi
  8017d8:	53                   	push   %ebx
  8017d9:	83 ec 2c             	sub    $0x2c,%esp
  8017dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8017df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017e2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017e5:	eb 12                	jmp    8017f9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	0f 84 89 03 00 00    	je     801b78 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	53                   	push   %ebx
  8017f3:	50                   	push   %eax
  8017f4:	ff d6                	call   *%esi
  8017f6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017f9:	83 c7 01             	add    $0x1,%edi
  8017fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801800:	83 f8 25             	cmp    $0x25,%eax
  801803:	75 e2                	jne    8017e7 <vprintfmt+0x14>
  801805:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801809:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801810:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801817:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80181e:	ba 00 00 00 00       	mov    $0x0,%edx
  801823:	eb 07                	jmp    80182c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801825:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801828:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182c:	8d 47 01             	lea    0x1(%edi),%eax
  80182f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801832:	0f b6 07             	movzbl (%edi),%eax
  801835:	0f b6 c8             	movzbl %al,%ecx
  801838:	83 e8 23             	sub    $0x23,%eax
  80183b:	3c 55                	cmp    $0x55,%al
  80183d:	0f 87 1a 03 00 00    	ja     801b5d <vprintfmt+0x38a>
  801843:	0f b6 c0             	movzbl %al,%eax
  801846:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  80184d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801850:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801854:	eb d6                	jmp    80182c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801856:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801859:	b8 00 00 00 00       	mov    $0x0,%eax
  80185e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801861:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801864:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801868:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80186b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80186e:	83 fa 09             	cmp    $0x9,%edx
  801871:	77 39                	ja     8018ac <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801873:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801876:	eb e9                	jmp    801861 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801878:	8b 45 14             	mov    0x14(%ebp),%eax
  80187b:	8d 48 04             	lea    0x4(%eax),%ecx
  80187e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801881:	8b 00                	mov    (%eax),%eax
  801883:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801886:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801889:	eb 27                	jmp    8018b2 <vprintfmt+0xdf>
  80188b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80188e:	85 c0                	test   %eax,%eax
  801890:	b9 00 00 00 00       	mov    $0x0,%ecx
  801895:	0f 49 c8             	cmovns %eax,%ecx
  801898:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80189e:	eb 8c                	jmp    80182c <vprintfmt+0x59>
  8018a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018aa:	eb 80                	jmp    80182c <vprintfmt+0x59>
  8018ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018af:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018b6:	0f 89 70 ff ff ff    	jns    80182c <vprintfmt+0x59>
				width = precision, precision = -1;
  8018bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018c9:	e9 5e ff ff ff       	jmp    80182c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018ce:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018d4:	e9 53 ff ff ff       	jmp    80182c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8018dc:	8d 50 04             	lea    0x4(%eax),%edx
  8018df:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e2:	83 ec 08             	sub    $0x8,%esp
  8018e5:	53                   	push   %ebx
  8018e6:	ff 30                	pushl  (%eax)
  8018e8:	ff d6                	call   *%esi
			break;
  8018ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018f0:	e9 04 ff ff ff       	jmp    8017f9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f8:	8d 50 04             	lea    0x4(%eax),%edx
  8018fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8018fe:	8b 00                	mov    (%eax),%eax
  801900:	99                   	cltd   
  801901:	31 d0                	xor    %edx,%eax
  801903:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801905:	83 f8 0f             	cmp    $0xf,%eax
  801908:	7f 0b                	jg     801915 <vprintfmt+0x142>
  80190a:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  801911:	85 d2                	test   %edx,%edx
  801913:	75 18                	jne    80192d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801915:	50                   	push   %eax
  801916:	68 eb 25 80 00       	push   $0x8025eb
  80191b:	53                   	push   %ebx
  80191c:	56                   	push   %esi
  80191d:	e8 94 fe ff ff       	call   8017b6 <printfmt>
  801922:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801928:	e9 cc fe ff ff       	jmp    8017f9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80192d:	52                   	push   %edx
  80192e:	68 69 25 80 00       	push   $0x802569
  801933:	53                   	push   %ebx
  801934:	56                   	push   %esi
  801935:	e8 7c fe ff ff       	call   8017b6 <printfmt>
  80193a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80193d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801940:	e9 b4 fe ff ff       	jmp    8017f9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801945:	8b 45 14             	mov    0x14(%ebp),%eax
  801948:	8d 50 04             	lea    0x4(%eax),%edx
  80194b:	89 55 14             	mov    %edx,0x14(%ebp)
  80194e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801950:	85 ff                	test   %edi,%edi
  801952:	b8 e4 25 80 00       	mov    $0x8025e4,%eax
  801957:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80195a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80195e:	0f 8e 94 00 00 00    	jle    8019f8 <vprintfmt+0x225>
  801964:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801968:	0f 84 98 00 00 00    	je     801a06 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	ff 75 d0             	pushl  -0x30(%ebp)
  801974:	57                   	push   %edi
  801975:	e8 86 02 00 00       	call   801c00 <strnlen>
  80197a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80197d:	29 c1                	sub    %eax,%ecx
  80197f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801982:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801985:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801989:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80198c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80198f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801991:	eb 0f                	jmp    8019a2 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801993:	83 ec 08             	sub    $0x8,%esp
  801996:	53                   	push   %ebx
  801997:	ff 75 e0             	pushl  -0x20(%ebp)
  80199a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80199c:	83 ef 01             	sub    $0x1,%edi
  80199f:	83 c4 10             	add    $0x10,%esp
  8019a2:	85 ff                	test   %edi,%edi
  8019a4:	7f ed                	jg     801993 <vprintfmt+0x1c0>
  8019a6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019a9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019ac:	85 c9                	test   %ecx,%ecx
  8019ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b3:	0f 49 c1             	cmovns %ecx,%eax
  8019b6:	29 c1                	sub    %eax,%ecx
  8019b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8019bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019c1:	89 cb                	mov    %ecx,%ebx
  8019c3:	eb 4d                	jmp    801a12 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019c9:	74 1b                	je     8019e6 <vprintfmt+0x213>
  8019cb:	0f be c0             	movsbl %al,%eax
  8019ce:	83 e8 20             	sub    $0x20,%eax
  8019d1:	83 f8 5e             	cmp    $0x5e,%eax
  8019d4:	76 10                	jbe    8019e6 <vprintfmt+0x213>
					putch('?', putdat);
  8019d6:	83 ec 08             	sub    $0x8,%esp
  8019d9:	ff 75 0c             	pushl  0xc(%ebp)
  8019dc:	6a 3f                	push   $0x3f
  8019de:	ff 55 08             	call   *0x8(%ebp)
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	eb 0d                	jmp    8019f3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019e6:	83 ec 08             	sub    $0x8,%esp
  8019e9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ec:	52                   	push   %edx
  8019ed:	ff 55 08             	call   *0x8(%ebp)
  8019f0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019f3:	83 eb 01             	sub    $0x1,%ebx
  8019f6:	eb 1a                	jmp    801a12 <vprintfmt+0x23f>
  8019f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8019fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a01:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a04:	eb 0c                	jmp    801a12 <vprintfmt+0x23f>
  801a06:	89 75 08             	mov    %esi,0x8(%ebp)
  801a09:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a0c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a0f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a12:	83 c7 01             	add    $0x1,%edi
  801a15:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a19:	0f be d0             	movsbl %al,%edx
  801a1c:	85 d2                	test   %edx,%edx
  801a1e:	74 23                	je     801a43 <vprintfmt+0x270>
  801a20:	85 f6                	test   %esi,%esi
  801a22:	78 a1                	js     8019c5 <vprintfmt+0x1f2>
  801a24:	83 ee 01             	sub    $0x1,%esi
  801a27:	79 9c                	jns    8019c5 <vprintfmt+0x1f2>
  801a29:	89 df                	mov    %ebx,%edi
  801a2b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a31:	eb 18                	jmp    801a4b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a33:	83 ec 08             	sub    $0x8,%esp
  801a36:	53                   	push   %ebx
  801a37:	6a 20                	push   $0x20
  801a39:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a3b:	83 ef 01             	sub    $0x1,%edi
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	eb 08                	jmp    801a4b <vprintfmt+0x278>
  801a43:	89 df                	mov    %ebx,%edi
  801a45:	8b 75 08             	mov    0x8(%ebp),%esi
  801a48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a4b:	85 ff                	test   %edi,%edi
  801a4d:	7f e4                	jg     801a33 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a52:	e9 a2 fd ff ff       	jmp    8017f9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a57:	83 fa 01             	cmp    $0x1,%edx
  801a5a:	7e 16                	jle    801a72 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a5c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5f:	8d 50 08             	lea    0x8(%eax),%edx
  801a62:	89 55 14             	mov    %edx,0x14(%ebp)
  801a65:	8b 50 04             	mov    0x4(%eax),%edx
  801a68:	8b 00                	mov    (%eax),%eax
  801a6a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a6d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a70:	eb 32                	jmp    801aa4 <vprintfmt+0x2d1>
	else if (lflag)
  801a72:	85 d2                	test   %edx,%edx
  801a74:	74 18                	je     801a8e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a76:	8b 45 14             	mov    0x14(%ebp),%eax
  801a79:	8d 50 04             	lea    0x4(%eax),%edx
  801a7c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a7f:	8b 00                	mov    (%eax),%eax
  801a81:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a84:	89 c1                	mov    %eax,%ecx
  801a86:	c1 f9 1f             	sar    $0x1f,%ecx
  801a89:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a8c:	eb 16                	jmp    801aa4 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a8e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a91:	8d 50 04             	lea    0x4(%eax),%edx
  801a94:	89 55 14             	mov    %edx,0x14(%ebp)
  801a97:	8b 00                	mov    (%eax),%eax
  801a99:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a9c:	89 c1                	mov    %eax,%ecx
  801a9e:	c1 f9 1f             	sar    $0x1f,%ecx
  801aa1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801aa4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aa7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801aaa:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801aaf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ab3:	79 74                	jns    801b29 <vprintfmt+0x356>
				putch('-', putdat);
  801ab5:	83 ec 08             	sub    $0x8,%esp
  801ab8:	53                   	push   %ebx
  801ab9:	6a 2d                	push   $0x2d
  801abb:	ff d6                	call   *%esi
				num = -(long long) num;
  801abd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ac0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ac3:	f7 d8                	neg    %eax
  801ac5:	83 d2 00             	adc    $0x0,%edx
  801ac8:	f7 da                	neg    %edx
  801aca:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801acd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ad2:	eb 55                	jmp    801b29 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ad4:	8d 45 14             	lea    0x14(%ebp),%eax
  801ad7:	e8 83 fc ff ff       	call   80175f <getuint>
			base = 10;
  801adc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ae1:	eb 46                	jmp    801b29 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ae3:	8d 45 14             	lea    0x14(%ebp),%eax
  801ae6:	e8 74 fc ff ff       	call   80175f <getuint>
			base = 8;
  801aeb:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801af0:	eb 37                	jmp    801b29 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801af2:	83 ec 08             	sub    $0x8,%esp
  801af5:	53                   	push   %ebx
  801af6:	6a 30                	push   $0x30
  801af8:	ff d6                	call   *%esi
			putch('x', putdat);
  801afa:	83 c4 08             	add    $0x8,%esp
  801afd:	53                   	push   %ebx
  801afe:	6a 78                	push   $0x78
  801b00:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b02:	8b 45 14             	mov    0x14(%ebp),%eax
  801b05:	8d 50 04             	lea    0x4(%eax),%edx
  801b08:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b0b:	8b 00                	mov    (%eax),%eax
  801b0d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b12:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b15:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b1a:	eb 0d                	jmp    801b29 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b1c:	8d 45 14             	lea    0x14(%ebp),%eax
  801b1f:	e8 3b fc ff ff       	call   80175f <getuint>
			base = 16;
  801b24:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b30:	57                   	push   %edi
  801b31:	ff 75 e0             	pushl  -0x20(%ebp)
  801b34:	51                   	push   %ecx
  801b35:	52                   	push   %edx
  801b36:	50                   	push   %eax
  801b37:	89 da                	mov    %ebx,%edx
  801b39:	89 f0                	mov    %esi,%eax
  801b3b:	e8 70 fb ff ff       	call   8016b0 <printnum>
			break;
  801b40:	83 c4 20             	add    $0x20,%esp
  801b43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b46:	e9 ae fc ff ff       	jmp    8017f9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b4b:	83 ec 08             	sub    $0x8,%esp
  801b4e:	53                   	push   %ebx
  801b4f:	51                   	push   %ecx
  801b50:	ff d6                	call   *%esi
			break;
  801b52:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b58:	e9 9c fc ff ff       	jmp    8017f9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b5d:	83 ec 08             	sub    $0x8,%esp
  801b60:	53                   	push   %ebx
  801b61:	6a 25                	push   $0x25
  801b63:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	eb 03                	jmp    801b6d <vprintfmt+0x39a>
  801b6a:	83 ef 01             	sub    $0x1,%edi
  801b6d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b71:	75 f7                	jne    801b6a <vprintfmt+0x397>
  801b73:	e9 81 fc ff ff       	jmp    8017f9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5f                   	pop    %edi
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 18             	sub    $0x18,%esp
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b8c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b8f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b93:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	74 26                	je     801bc7 <vsnprintf+0x47>
  801ba1:	85 d2                	test   %edx,%edx
  801ba3:	7e 22                	jle    801bc7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ba5:	ff 75 14             	pushl  0x14(%ebp)
  801ba8:	ff 75 10             	pushl  0x10(%ebp)
  801bab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bae:	50                   	push   %eax
  801baf:	68 99 17 80 00       	push   $0x801799
  801bb4:	e8 1a fc ff ff       	call   8017d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bbc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc2:	83 c4 10             	add    $0x10,%esp
  801bc5:	eb 05                	jmp    801bcc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bce:	55                   	push   %ebp
  801bcf:	89 e5                	mov    %esp,%ebp
  801bd1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bd4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bd7:	50                   	push   %eax
  801bd8:	ff 75 10             	pushl  0x10(%ebp)
  801bdb:	ff 75 0c             	pushl  0xc(%ebp)
  801bde:	ff 75 08             	pushl  0x8(%ebp)
  801be1:	e8 9a ff ff ff       	call   801b80 <vsnprintf>
	va_end(ap);

	return rc;
}
  801be6:	c9                   	leave  
  801be7:	c3                   	ret    

00801be8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bee:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf3:	eb 03                	jmp    801bf8 <strlen+0x10>
		n++;
  801bf5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bf8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bfc:	75 f7                	jne    801bf5 <strlen+0xd>
		n++;
	return n;
}
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    

00801c00 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c06:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c09:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0e:	eb 03                	jmp    801c13 <strnlen+0x13>
		n++;
  801c10:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c13:	39 c2                	cmp    %eax,%edx
  801c15:	74 08                	je     801c1f <strnlen+0x1f>
  801c17:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c1b:	75 f3                	jne    801c10 <strnlen+0x10>
  801c1d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	53                   	push   %ebx
  801c25:	8b 45 08             	mov    0x8(%ebp),%eax
  801c28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c2b:	89 c2                	mov    %eax,%edx
  801c2d:	83 c2 01             	add    $0x1,%edx
  801c30:	83 c1 01             	add    $0x1,%ecx
  801c33:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c37:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c3a:	84 db                	test   %bl,%bl
  801c3c:	75 ef                	jne    801c2d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c3e:	5b                   	pop    %ebx
  801c3f:	5d                   	pop    %ebp
  801c40:	c3                   	ret    

00801c41 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	53                   	push   %ebx
  801c45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c48:	53                   	push   %ebx
  801c49:	e8 9a ff ff ff       	call   801be8 <strlen>
  801c4e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c51:	ff 75 0c             	pushl  0xc(%ebp)
  801c54:	01 d8                	add    %ebx,%eax
  801c56:	50                   	push   %eax
  801c57:	e8 c5 ff ff ff       	call   801c21 <strcpy>
	return dst;
}
  801c5c:	89 d8                	mov    %ebx,%eax
  801c5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	8b 75 08             	mov    0x8(%ebp),%esi
  801c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6e:	89 f3                	mov    %esi,%ebx
  801c70:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c73:	89 f2                	mov    %esi,%edx
  801c75:	eb 0f                	jmp    801c86 <strncpy+0x23>
		*dst++ = *src;
  801c77:	83 c2 01             	add    $0x1,%edx
  801c7a:	0f b6 01             	movzbl (%ecx),%eax
  801c7d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c80:	80 39 01             	cmpb   $0x1,(%ecx)
  801c83:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c86:	39 da                	cmp    %ebx,%edx
  801c88:	75 ed                	jne    801c77 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c8a:	89 f0                	mov    %esi,%eax
  801c8c:	5b                   	pop    %ebx
  801c8d:	5e                   	pop    %esi
  801c8e:	5d                   	pop    %ebp
  801c8f:	c3                   	ret    

00801c90 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	56                   	push   %esi
  801c94:	53                   	push   %ebx
  801c95:	8b 75 08             	mov    0x8(%ebp),%esi
  801c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9b:	8b 55 10             	mov    0x10(%ebp),%edx
  801c9e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ca0:	85 d2                	test   %edx,%edx
  801ca2:	74 21                	je     801cc5 <strlcpy+0x35>
  801ca4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ca8:	89 f2                	mov    %esi,%edx
  801caa:	eb 09                	jmp    801cb5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cac:	83 c2 01             	add    $0x1,%edx
  801caf:	83 c1 01             	add    $0x1,%ecx
  801cb2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cb5:	39 c2                	cmp    %eax,%edx
  801cb7:	74 09                	je     801cc2 <strlcpy+0x32>
  801cb9:	0f b6 19             	movzbl (%ecx),%ebx
  801cbc:	84 db                	test   %bl,%bl
  801cbe:	75 ec                	jne    801cac <strlcpy+0x1c>
  801cc0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cc2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cc5:	29 f0                	sub    %esi,%eax
}
  801cc7:	5b                   	pop    %ebx
  801cc8:	5e                   	pop    %esi
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    

00801ccb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cd4:	eb 06                	jmp    801cdc <strcmp+0x11>
		p++, q++;
  801cd6:	83 c1 01             	add    $0x1,%ecx
  801cd9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cdc:	0f b6 01             	movzbl (%ecx),%eax
  801cdf:	84 c0                	test   %al,%al
  801ce1:	74 04                	je     801ce7 <strcmp+0x1c>
  801ce3:	3a 02                	cmp    (%edx),%al
  801ce5:	74 ef                	je     801cd6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ce7:	0f b6 c0             	movzbl %al,%eax
  801cea:	0f b6 12             	movzbl (%edx),%edx
  801ced:	29 d0                	sub    %edx,%eax
}
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	53                   	push   %ebx
  801cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cfb:	89 c3                	mov    %eax,%ebx
  801cfd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d00:	eb 06                	jmp    801d08 <strncmp+0x17>
		n--, p++, q++;
  801d02:	83 c0 01             	add    $0x1,%eax
  801d05:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d08:	39 d8                	cmp    %ebx,%eax
  801d0a:	74 15                	je     801d21 <strncmp+0x30>
  801d0c:	0f b6 08             	movzbl (%eax),%ecx
  801d0f:	84 c9                	test   %cl,%cl
  801d11:	74 04                	je     801d17 <strncmp+0x26>
  801d13:	3a 0a                	cmp    (%edx),%cl
  801d15:	74 eb                	je     801d02 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d17:	0f b6 00             	movzbl (%eax),%eax
  801d1a:	0f b6 12             	movzbl (%edx),%edx
  801d1d:	29 d0                	sub    %edx,%eax
  801d1f:	eb 05                	jmp    801d26 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d26:	5b                   	pop    %ebx
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d33:	eb 07                	jmp    801d3c <strchr+0x13>
		if (*s == c)
  801d35:	38 ca                	cmp    %cl,%dl
  801d37:	74 0f                	je     801d48 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d39:	83 c0 01             	add    $0x1,%eax
  801d3c:	0f b6 10             	movzbl (%eax),%edx
  801d3f:	84 d2                	test   %dl,%dl
  801d41:	75 f2                	jne    801d35 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d48:	5d                   	pop    %ebp
  801d49:	c3                   	ret    

00801d4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d54:	eb 03                	jmp    801d59 <strfind+0xf>
  801d56:	83 c0 01             	add    $0x1,%eax
  801d59:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d5c:	38 ca                	cmp    %cl,%dl
  801d5e:	74 04                	je     801d64 <strfind+0x1a>
  801d60:	84 d2                	test   %dl,%dl
  801d62:	75 f2                	jne    801d56 <strfind+0xc>
			break;
	return (char *) s;
}
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	57                   	push   %edi
  801d6a:	56                   	push   %esi
  801d6b:	53                   	push   %ebx
  801d6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d72:	85 c9                	test   %ecx,%ecx
  801d74:	74 36                	je     801dac <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d76:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d7c:	75 28                	jne    801da6 <memset+0x40>
  801d7e:	f6 c1 03             	test   $0x3,%cl
  801d81:	75 23                	jne    801da6 <memset+0x40>
		c &= 0xFF;
  801d83:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d87:	89 d3                	mov    %edx,%ebx
  801d89:	c1 e3 08             	shl    $0x8,%ebx
  801d8c:	89 d6                	mov    %edx,%esi
  801d8e:	c1 e6 18             	shl    $0x18,%esi
  801d91:	89 d0                	mov    %edx,%eax
  801d93:	c1 e0 10             	shl    $0x10,%eax
  801d96:	09 f0                	or     %esi,%eax
  801d98:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d9a:	89 d8                	mov    %ebx,%eax
  801d9c:	09 d0                	or     %edx,%eax
  801d9e:	c1 e9 02             	shr    $0x2,%ecx
  801da1:	fc                   	cld    
  801da2:	f3 ab                	rep stos %eax,%es:(%edi)
  801da4:	eb 06                	jmp    801dac <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801da6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da9:	fc                   	cld    
  801daa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dac:	89 f8                	mov    %edi,%eax
  801dae:	5b                   	pop    %ebx
  801daf:	5e                   	pop    %esi
  801db0:	5f                   	pop    %edi
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    

00801db3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	57                   	push   %edi
  801db7:	56                   	push   %esi
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbb:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dc1:	39 c6                	cmp    %eax,%esi
  801dc3:	73 35                	jae    801dfa <memmove+0x47>
  801dc5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dc8:	39 d0                	cmp    %edx,%eax
  801dca:	73 2e                	jae    801dfa <memmove+0x47>
		s += n;
		d += n;
  801dcc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dcf:	89 d6                	mov    %edx,%esi
  801dd1:	09 fe                	or     %edi,%esi
  801dd3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801dd9:	75 13                	jne    801dee <memmove+0x3b>
  801ddb:	f6 c1 03             	test   $0x3,%cl
  801dde:	75 0e                	jne    801dee <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801de0:	83 ef 04             	sub    $0x4,%edi
  801de3:	8d 72 fc             	lea    -0x4(%edx),%esi
  801de6:	c1 e9 02             	shr    $0x2,%ecx
  801de9:	fd                   	std    
  801dea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dec:	eb 09                	jmp    801df7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dee:	83 ef 01             	sub    $0x1,%edi
  801df1:	8d 72 ff             	lea    -0x1(%edx),%esi
  801df4:	fd                   	std    
  801df5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801df7:	fc                   	cld    
  801df8:	eb 1d                	jmp    801e17 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dfa:	89 f2                	mov    %esi,%edx
  801dfc:	09 c2                	or     %eax,%edx
  801dfe:	f6 c2 03             	test   $0x3,%dl
  801e01:	75 0f                	jne    801e12 <memmove+0x5f>
  801e03:	f6 c1 03             	test   $0x3,%cl
  801e06:	75 0a                	jne    801e12 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e08:	c1 e9 02             	shr    $0x2,%ecx
  801e0b:	89 c7                	mov    %eax,%edi
  801e0d:	fc                   	cld    
  801e0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e10:	eb 05                	jmp    801e17 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e12:	89 c7                	mov    %eax,%edi
  801e14:	fc                   	cld    
  801e15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e17:	5e                   	pop    %esi
  801e18:	5f                   	pop    %edi
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    

00801e1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e1e:	ff 75 10             	pushl  0x10(%ebp)
  801e21:	ff 75 0c             	pushl  0xc(%ebp)
  801e24:	ff 75 08             	pushl  0x8(%ebp)
  801e27:	e8 87 ff ff ff       	call   801db3 <memmove>
}
  801e2c:	c9                   	leave  
  801e2d:	c3                   	ret    

00801e2e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e2e:	55                   	push   %ebp
  801e2f:	89 e5                	mov    %esp,%ebp
  801e31:	56                   	push   %esi
  801e32:	53                   	push   %ebx
  801e33:	8b 45 08             	mov    0x8(%ebp),%eax
  801e36:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e39:	89 c6                	mov    %eax,%esi
  801e3b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e3e:	eb 1a                	jmp    801e5a <memcmp+0x2c>
		if (*s1 != *s2)
  801e40:	0f b6 08             	movzbl (%eax),%ecx
  801e43:	0f b6 1a             	movzbl (%edx),%ebx
  801e46:	38 d9                	cmp    %bl,%cl
  801e48:	74 0a                	je     801e54 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e4a:	0f b6 c1             	movzbl %cl,%eax
  801e4d:	0f b6 db             	movzbl %bl,%ebx
  801e50:	29 d8                	sub    %ebx,%eax
  801e52:	eb 0f                	jmp    801e63 <memcmp+0x35>
		s1++, s2++;
  801e54:	83 c0 01             	add    $0x1,%eax
  801e57:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e5a:	39 f0                	cmp    %esi,%eax
  801e5c:	75 e2                	jne    801e40 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	53                   	push   %ebx
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e6e:	89 c1                	mov    %eax,%ecx
  801e70:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e73:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e77:	eb 0a                	jmp    801e83 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e79:	0f b6 10             	movzbl (%eax),%edx
  801e7c:	39 da                	cmp    %ebx,%edx
  801e7e:	74 07                	je     801e87 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e80:	83 c0 01             	add    $0x1,%eax
  801e83:	39 c8                	cmp    %ecx,%eax
  801e85:	72 f2                	jb     801e79 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e87:	5b                   	pop    %ebx
  801e88:	5d                   	pop    %ebp
  801e89:	c3                   	ret    

00801e8a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e8a:	55                   	push   %ebp
  801e8b:	89 e5                	mov    %esp,%ebp
  801e8d:	57                   	push   %edi
  801e8e:	56                   	push   %esi
  801e8f:	53                   	push   %ebx
  801e90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e96:	eb 03                	jmp    801e9b <strtol+0x11>
		s++;
  801e98:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e9b:	0f b6 01             	movzbl (%ecx),%eax
  801e9e:	3c 20                	cmp    $0x20,%al
  801ea0:	74 f6                	je     801e98 <strtol+0xe>
  801ea2:	3c 09                	cmp    $0x9,%al
  801ea4:	74 f2                	je     801e98 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ea6:	3c 2b                	cmp    $0x2b,%al
  801ea8:	75 0a                	jne    801eb4 <strtol+0x2a>
		s++;
  801eaa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ead:	bf 00 00 00 00       	mov    $0x0,%edi
  801eb2:	eb 11                	jmp    801ec5 <strtol+0x3b>
  801eb4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801eb9:	3c 2d                	cmp    $0x2d,%al
  801ebb:	75 08                	jne    801ec5 <strtol+0x3b>
		s++, neg = 1;
  801ebd:	83 c1 01             	add    $0x1,%ecx
  801ec0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ec5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ecb:	75 15                	jne    801ee2 <strtol+0x58>
  801ecd:	80 39 30             	cmpb   $0x30,(%ecx)
  801ed0:	75 10                	jne    801ee2 <strtol+0x58>
  801ed2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ed6:	75 7c                	jne    801f54 <strtol+0xca>
		s += 2, base = 16;
  801ed8:	83 c1 02             	add    $0x2,%ecx
  801edb:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ee0:	eb 16                	jmp    801ef8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ee2:	85 db                	test   %ebx,%ebx
  801ee4:	75 12                	jne    801ef8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ee6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eeb:	80 39 30             	cmpb   $0x30,(%ecx)
  801eee:	75 08                	jne    801ef8 <strtol+0x6e>
		s++, base = 8;
  801ef0:	83 c1 01             	add    $0x1,%ecx
  801ef3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  801efd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f00:	0f b6 11             	movzbl (%ecx),%edx
  801f03:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f06:	89 f3                	mov    %esi,%ebx
  801f08:	80 fb 09             	cmp    $0x9,%bl
  801f0b:	77 08                	ja     801f15 <strtol+0x8b>
			dig = *s - '0';
  801f0d:	0f be d2             	movsbl %dl,%edx
  801f10:	83 ea 30             	sub    $0x30,%edx
  801f13:	eb 22                	jmp    801f37 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f15:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f18:	89 f3                	mov    %esi,%ebx
  801f1a:	80 fb 19             	cmp    $0x19,%bl
  801f1d:	77 08                	ja     801f27 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f1f:	0f be d2             	movsbl %dl,%edx
  801f22:	83 ea 57             	sub    $0x57,%edx
  801f25:	eb 10                	jmp    801f37 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f27:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f2a:	89 f3                	mov    %esi,%ebx
  801f2c:	80 fb 19             	cmp    $0x19,%bl
  801f2f:	77 16                	ja     801f47 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f31:	0f be d2             	movsbl %dl,%edx
  801f34:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f37:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f3a:	7d 0b                	jge    801f47 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f3c:	83 c1 01             	add    $0x1,%ecx
  801f3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f43:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f45:	eb b9                	jmp    801f00 <strtol+0x76>

	if (endptr)
  801f47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f4b:	74 0d                	je     801f5a <strtol+0xd0>
		*endptr = (char *) s;
  801f4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f50:	89 0e                	mov    %ecx,(%esi)
  801f52:	eb 06                	jmp    801f5a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f54:	85 db                	test   %ebx,%ebx
  801f56:	74 98                	je     801ef0 <strtol+0x66>
  801f58:	eb 9e                	jmp    801ef8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f5a:	89 c2                	mov    %eax,%edx
  801f5c:	f7 da                	neg    %edx
  801f5e:	85 ff                	test   %edi,%edi
  801f60:	0f 45 c2             	cmovne %edx,%eax
}
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    

00801f68 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f68:	55                   	push   %ebp
  801f69:	89 e5                	mov    %esp,%ebp
  801f6b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f6e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f75:	75 2a                	jne    801fa1 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f77:	83 ec 04             	sub    $0x4,%esp
  801f7a:	6a 07                	push   $0x7
  801f7c:	68 00 f0 bf ee       	push   $0xeebff000
  801f81:	6a 00                	push   $0x0
  801f83:	e8 f1 e1 ff ff       	call   800179 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f88:	83 c4 10             	add    $0x10,%esp
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	79 12                	jns    801fa1 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f8f:	50                   	push   %eax
  801f90:	68 bd 24 80 00       	push   $0x8024bd
  801f95:	6a 23                	push   $0x23
  801f97:	68 e0 28 80 00       	push   $0x8028e0
  801f9c:	e8 22 f6 ff ff       	call   8015c3 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa4:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fa9:	83 ec 08             	sub    $0x8,%esp
  801fac:	68 d3 1f 80 00       	push   $0x801fd3
  801fb1:	6a 00                	push   $0x0
  801fb3:	e8 0c e3 ff ff       	call   8002c4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fb8:	83 c4 10             	add    $0x10,%esp
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	79 12                	jns    801fd1 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fbf:	50                   	push   %eax
  801fc0:	68 bd 24 80 00       	push   $0x8024bd
  801fc5:	6a 2c                	push   $0x2c
  801fc7:	68 e0 28 80 00       	push   $0x8028e0
  801fcc:	e8 f2 f5 ff ff       	call   8015c3 <_panic>
	}
}
  801fd1:	c9                   	leave  
  801fd2:	c3                   	ret    

00801fd3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fd3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fd4:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fd9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fdb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fde:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fe2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fe7:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801feb:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801fed:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ff0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ff1:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ff4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ff5:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ff6:	c3                   	ret    

00801ff7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	56                   	push   %esi
  801ffb:	53                   	push   %ebx
  801ffc:	8b 75 08             	mov    0x8(%ebp),%esi
  801fff:	8b 45 0c             	mov    0xc(%ebp),%eax
  802002:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802005:	85 c0                	test   %eax,%eax
  802007:	75 12                	jne    80201b <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802009:	83 ec 0c             	sub    $0xc,%esp
  80200c:	68 00 00 c0 ee       	push   $0xeec00000
  802011:	e8 13 e3 ff ff       	call   800329 <sys_ipc_recv>
  802016:	83 c4 10             	add    $0x10,%esp
  802019:	eb 0c                	jmp    802027 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80201b:	83 ec 0c             	sub    $0xc,%esp
  80201e:	50                   	push   %eax
  80201f:	e8 05 e3 ff ff       	call   800329 <sys_ipc_recv>
  802024:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802027:	85 f6                	test   %esi,%esi
  802029:	0f 95 c1             	setne  %cl
  80202c:	85 db                	test   %ebx,%ebx
  80202e:	0f 95 c2             	setne  %dl
  802031:	84 d1                	test   %dl,%cl
  802033:	74 09                	je     80203e <ipc_recv+0x47>
  802035:	89 c2                	mov    %eax,%edx
  802037:	c1 ea 1f             	shr    $0x1f,%edx
  80203a:	84 d2                	test   %dl,%dl
  80203c:	75 2d                	jne    80206b <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80203e:	85 f6                	test   %esi,%esi
  802040:	74 0d                	je     80204f <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802042:	a1 04 40 80 00       	mov    0x804004,%eax
  802047:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80204d:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80204f:	85 db                	test   %ebx,%ebx
  802051:	74 0d                	je     802060 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802053:	a1 04 40 80 00       	mov    0x804004,%eax
  802058:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80205e:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802060:	a1 04 40 80 00       	mov    0x804004,%eax
  802065:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80206b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206e:	5b                   	pop    %ebx
  80206f:	5e                   	pop    %esi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    

00802072 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	57                   	push   %edi
  802076:	56                   	push   %esi
  802077:	53                   	push   %ebx
  802078:	83 ec 0c             	sub    $0xc,%esp
  80207b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80207e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802081:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802084:	85 db                	test   %ebx,%ebx
  802086:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80208b:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80208e:	ff 75 14             	pushl  0x14(%ebp)
  802091:	53                   	push   %ebx
  802092:	56                   	push   %esi
  802093:	57                   	push   %edi
  802094:	e8 6d e2 ff ff       	call   800306 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802099:	89 c2                	mov    %eax,%edx
  80209b:	c1 ea 1f             	shr    $0x1f,%edx
  80209e:	83 c4 10             	add    $0x10,%esp
  8020a1:	84 d2                	test   %dl,%dl
  8020a3:	74 17                	je     8020bc <ipc_send+0x4a>
  8020a5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020a8:	74 12                	je     8020bc <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020aa:	50                   	push   %eax
  8020ab:	68 ee 28 80 00       	push   $0x8028ee
  8020b0:	6a 47                	push   $0x47
  8020b2:	68 fc 28 80 00       	push   $0x8028fc
  8020b7:	e8 07 f5 ff ff       	call   8015c3 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020bc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020bf:	75 07                	jne    8020c8 <ipc_send+0x56>
			sys_yield();
  8020c1:	e8 94 e0 ff ff       	call   80015a <sys_yield>
  8020c6:	eb c6                	jmp    80208e <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020c8:	85 c0                	test   %eax,%eax
  8020ca:	75 c2                	jne    80208e <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020cf:	5b                   	pop    %ebx
  8020d0:	5e                   	pop    %esi
  8020d1:	5f                   	pop    %edi
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    

008020d4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020da:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020df:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020e5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020eb:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8020f1:	39 ca                	cmp    %ecx,%edx
  8020f3:	75 13                	jne    802108 <ipc_find_env+0x34>
			return envs[i].env_id;
  8020f5:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8020fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802100:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802106:	eb 0f                	jmp    802117 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802108:	83 c0 01             	add    $0x1,%eax
  80210b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802110:	75 cd                	jne    8020df <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802112:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    

00802119 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211f:	89 d0                	mov    %edx,%eax
  802121:	c1 e8 16             	shr    $0x16,%eax
  802124:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80212b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802130:	f6 c1 01             	test   $0x1,%cl
  802133:	74 1d                	je     802152 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802135:	c1 ea 0c             	shr    $0xc,%edx
  802138:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80213f:	f6 c2 01             	test   $0x1,%dl
  802142:	74 0e                	je     802152 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802144:	c1 ea 0c             	shr    $0xc,%edx
  802147:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80214e:	ef 
  80214f:	0f b7 c0             	movzwl %ax,%eax
}
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__udivdi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80216b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80216f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 f6                	test   %esi,%esi
  802179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80217d:	89 ca                	mov    %ecx,%edx
  80217f:	89 f8                	mov    %edi,%eax
  802181:	75 3d                	jne    8021c0 <__udivdi3+0x60>
  802183:	39 cf                	cmp    %ecx,%edi
  802185:	0f 87 c5 00 00 00    	ja     802250 <__udivdi3+0xf0>
  80218b:	85 ff                	test   %edi,%edi
  80218d:	89 fd                	mov    %edi,%ebp
  80218f:	75 0b                	jne    80219c <__udivdi3+0x3c>
  802191:	b8 01 00 00 00       	mov    $0x1,%eax
  802196:	31 d2                	xor    %edx,%edx
  802198:	f7 f7                	div    %edi
  80219a:	89 c5                	mov    %eax,%ebp
  80219c:	89 c8                	mov    %ecx,%eax
  80219e:	31 d2                	xor    %edx,%edx
  8021a0:	f7 f5                	div    %ebp
  8021a2:	89 c1                	mov    %eax,%ecx
  8021a4:	89 d8                	mov    %ebx,%eax
  8021a6:	89 cf                	mov    %ecx,%edi
  8021a8:	f7 f5                	div    %ebp
  8021aa:	89 c3                	mov    %eax,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	39 ce                	cmp    %ecx,%esi
  8021c2:	77 74                	ja     802238 <__udivdi3+0xd8>
  8021c4:	0f bd fe             	bsr    %esi,%edi
  8021c7:	83 f7 1f             	xor    $0x1f,%edi
  8021ca:	0f 84 98 00 00 00    	je     802268 <__udivdi3+0x108>
  8021d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	89 c5                	mov    %eax,%ebp
  8021d9:	29 fb                	sub    %edi,%ebx
  8021db:	d3 e6                	shl    %cl,%esi
  8021dd:	89 d9                	mov    %ebx,%ecx
  8021df:	d3 ed                	shr    %cl,%ebp
  8021e1:	89 f9                	mov    %edi,%ecx
  8021e3:	d3 e0                	shl    %cl,%eax
  8021e5:	09 ee                	or     %ebp,%esi
  8021e7:	89 d9                	mov    %ebx,%ecx
  8021e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ed:	89 d5                	mov    %edx,%ebp
  8021ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021f3:	d3 ed                	shr    %cl,%ebp
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	d3 e2                	shl    %cl,%edx
  8021f9:	89 d9                	mov    %ebx,%ecx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	09 c2                	or     %eax,%edx
  8021ff:	89 d0                	mov    %edx,%eax
  802201:	89 ea                	mov    %ebp,%edx
  802203:	f7 f6                	div    %esi
  802205:	89 d5                	mov    %edx,%ebp
  802207:	89 c3                	mov    %eax,%ebx
  802209:	f7 64 24 0c          	mull   0xc(%esp)
  80220d:	39 d5                	cmp    %edx,%ebp
  80220f:	72 10                	jb     802221 <__udivdi3+0xc1>
  802211:	8b 74 24 08          	mov    0x8(%esp),%esi
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e6                	shl    %cl,%esi
  802219:	39 c6                	cmp    %eax,%esi
  80221b:	73 07                	jae    802224 <__udivdi3+0xc4>
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	75 03                	jne    802224 <__udivdi3+0xc4>
  802221:	83 eb 01             	sub    $0x1,%ebx
  802224:	31 ff                	xor    %edi,%edi
  802226:	89 d8                	mov    %ebx,%eax
  802228:	89 fa                	mov    %edi,%edx
  80222a:	83 c4 1c             	add    $0x1c,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5f                   	pop    %edi
  802230:	5d                   	pop    %ebp
  802231:	c3                   	ret    
  802232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802238:	31 ff                	xor    %edi,%edi
  80223a:	31 db                	xor    %ebx,%ebx
  80223c:	89 d8                	mov    %ebx,%eax
  80223e:	89 fa                	mov    %edi,%edx
  802240:	83 c4 1c             	add    $0x1c,%esp
  802243:	5b                   	pop    %ebx
  802244:	5e                   	pop    %esi
  802245:	5f                   	pop    %edi
  802246:	5d                   	pop    %ebp
  802247:	c3                   	ret    
  802248:	90                   	nop
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 d8                	mov    %ebx,%eax
  802252:	f7 f7                	div    %edi
  802254:	31 ff                	xor    %edi,%edi
  802256:	89 c3                	mov    %eax,%ebx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 fa                	mov    %edi,%edx
  80225c:	83 c4 1c             	add    $0x1c,%esp
  80225f:	5b                   	pop    %ebx
  802260:	5e                   	pop    %esi
  802261:	5f                   	pop    %edi
  802262:	5d                   	pop    %ebp
  802263:	c3                   	ret    
  802264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802268:	39 ce                	cmp    %ecx,%esi
  80226a:	72 0c                	jb     802278 <__udivdi3+0x118>
  80226c:	31 db                	xor    %ebx,%ebx
  80226e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802272:	0f 87 34 ff ff ff    	ja     8021ac <__udivdi3+0x4c>
  802278:	bb 01 00 00 00       	mov    $0x1,%ebx
  80227d:	e9 2a ff ff ff       	jmp    8021ac <__udivdi3+0x4c>
  802282:	66 90                	xchg   %ax,%ax
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	55                   	push   %ebp
  802291:	57                   	push   %edi
  802292:	56                   	push   %esi
  802293:	53                   	push   %ebx
  802294:	83 ec 1c             	sub    $0x1c,%esp
  802297:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80229b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80229f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022a7:	85 d2                	test   %edx,%edx
  8022a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b1:	89 f3                	mov    %esi,%ebx
  8022b3:	89 3c 24             	mov    %edi,(%esp)
  8022b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ba:	75 1c                	jne    8022d8 <__umoddi3+0x48>
  8022bc:	39 f7                	cmp    %esi,%edi
  8022be:	76 50                	jbe    802310 <__umoddi3+0x80>
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	f7 f7                	div    %edi
  8022c6:	89 d0                	mov    %edx,%eax
  8022c8:	31 d2                	xor    %edx,%edx
  8022ca:	83 c4 1c             	add    $0x1c,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5e                   	pop    %esi
  8022cf:	5f                   	pop    %edi
  8022d0:	5d                   	pop    %ebp
  8022d1:	c3                   	ret    
  8022d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	89 d0                	mov    %edx,%eax
  8022dc:	77 52                	ja     802330 <__umoddi3+0xa0>
  8022de:	0f bd ea             	bsr    %edx,%ebp
  8022e1:	83 f5 1f             	xor    $0x1f,%ebp
  8022e4:	75 5a                	jne    802340 <__umoddi3+0xb0>
  8022e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022ea:	0f 82 e0 00 00 00    	jb     8023d0 <__umoddi3+0x140>
  8022f0:	39 0c 24             	cmp    %ecx,(%esp)
  8022f3:	0f 86 d7 00 00 00    	jbe    8023d0 <__umoddi3+0x140>
  8022f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802301:	83 c4 1c             	add    $0x1c,%esp
  802304:	5b                   	pop    %ebx
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	85 ff                	test   %edi,%edi
  802312:	89 fd                	mov    %edi,%ebp
  802314:	75 0b                	jne    802321 <__umoddi3+0x91>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f7                	div    %edi
  80231f:	89 c5                	mov    %eax,%ebp
  802321:	89 f0                	mov    %esi,%eax
  802323:	31 d2                	xor    %edx,%edx
  802325:	f7 f5                	div    %ebp
  802327:	89 c8                	mov    %ecx,%eax
  802329:	f7 f5                	div    %ebp
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	eb 99                	jmp    8022c8 <__umoddi3+0x38>
  80232f:	90                   	nop
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	83 c4 1c             	add    $0x1c,%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5f                   	pop    %edi
  80233a:	5d                   	pop    %ebp
  80233b:	c3                   	ret    
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	8b 34 24             	mov    (%esp),%esi
  802343:	bf 20 00 00 00       	mov    $0x20,%edi
  802348:	89 e9                	mov    %ebp,%ecx
  80234a:	29 ef                	sub    %ebp,%edi
  80234c:	d3 e0                	shl    %cl,%eax
  80234e:	89 f9                	mov    %edi,%ecx
  802350:	89 f2                	mov    %esi,%edx
  802352:	d3 ea                	shr    %cl,%edx
  802354:	89 e9                	mov    %ebp,%ecx
  802356:	09 c2                	or     %eax,%edx
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	89 14 24             	mov    %edx,(%esp)
  80235d:	89 f2                	mov    %esi,%edx
  80235f:	d3 e2                	shl    %cl,%edx
  802361:	89 f9                	mov    %edi,%ecx
  802363:	89 54 24 04          	mov    %edx,0x4(%esp)
  802367:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80236b:	d3 e8                	shr    %cl,%eax
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	89 c6                	mov    %eax,%esi
  802371:	d3 e3                	shl    %cl,%ebx
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 d0                	mov    %edx,%eax
  802377:	d3 e8                	shr    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	09 d8                	or     %ebx,%eax
  80237d:	89 d3                	mov    %edx,%ebx
  80237f:	89 f2                	mov    %esi,%edx
  802381:	f7 34 24             	divl   (%esp)
  802384:	89 d6                	mov    %edx,%esi
  802386:	d3 e3                	shl    %cl,%ebx
  802388:	f7 64 24 04          	mull   0x4(%esp)
  80238c:	39 d6                	cmp    %edx,%esi
  80238e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802392:	89 d1                	mov    %edx,%ecx
  802394:	89 c3                	mov    %eax,%ebx
  802396:	72 08                	jb     8023a0 <__umoddi3+0x110>
  802398:	75 11                	jne    8023ab <__umoddi3+0x11b>
  80239a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80239e:	73 0b                	jae    8023ab <__umoddi3+0x11b>
  8023a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023a4:	1b 14 24             	sbb    (%esp),%edx
  8023a7:	89 d1                	mov    %edx,%ecx
  8023a9:	89 c3                	mov    %eax,%ebx
  8023ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023af:	29 da                	sub    %ebx,%edx
  8023b1:	19 ce                	sbb    %ecx,%esi
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	89 f0                	mov    %esi,%eax
  8023b7:	d3 e0                	shl    %cl,%eax
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	d3 ea                	shr    %cl,%edx
  8023bd:	89 e9                	mov    %ebp,%ecx
  8023bf:	d3 ee                	shr    %cl,%esi
  8023c1:	09 d0                	or     %edx,%eax
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	83 c4 1c             	add    $0x1c,%esp
  8023c8:	5b                   	pop    %ebx
  8023c9:	5e                   	pop    %esi
  8023ca:	5f                   	pop    %edi
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    
  8023cd:	8d 76 00             	lea    0x0(%esi),%esi
  8023d0:	29 f9                	sub    %edi,%ecx
  8023d2:	19 d6                	sbb    %edx,%esi
  8023d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023dc:	e9 18 ff ff ff       	jmp    8022f9 <__umoddi3+0x69>
