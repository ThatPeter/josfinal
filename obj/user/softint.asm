
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
  8000a9:	e8 e8 09 00 00       	call   800a96 <close_all>
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
  80012e:	e8 94 14 00 00       	call   8015c7 <_panic>

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
  8001af:	e8 13 14 00 00       	call   8015c7 <_panic>

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
  8001f1:	e8 d1 13 00 00       	call   8015c7 <_panic>

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
  800233:	e8 8f 13 00 00       	call   8015c7 <_panic>

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
  800275:	e8 4d 13 00 00       	call   8015c7 <_panic>

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
  8002b7:	e8 0b 13 00 00       	call   8015c7 <_panic>
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
  8002f9:	e8 c9 12 00 00       	call   8015c7 <_panic>

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
  80035d:	e8 65 12 00 00       	call   8015c7 <_panic>

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
  8003fc:	e8 c6 11 00 00       	call   8015c7 <_panic>
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
  800426:	e8 9c 11 00 00       	call   8015c7 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80042b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800431:	83 ec 04             	sub    $0x4,%esp
  800434:	68 00 10 00 00       	push   $0x1000
  800439:	53                   	push   %ebx
  80043a:	68 00 f0 7f 00       	push   $0x7ff000
  80043f:	e8 db 19 00 00       	call   801e1f <memcpy>

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
  80046e:	e8 54 11 00 00       	call   8015c7 <_panic>
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
  800496:	e8 2c 11 00 00       	call   8015c7 <_panic>
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
  8004ae:	e8 b9 1a 00 00       	call   801f6c <set_pgfault_handler>
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
  8004d6:	e8 ec 10 00 00       	call   8015c7 <_panic>
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
  80058f:	e8 33 10 00 00       	call   8015c7 <_panic>
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
  8005d4:	e8 ee 0f 00 00       	call   8015c7 <_panic>
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
  800602:	e8 c0 0f 00 00       	call   8015c7 <_panic>
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
  80062c:	e8 96 0f 00 00       	call   8015c7 <_panic>
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
  8006ec:	e8 d6 0e 00 00       	call   8015c7 <_panic>
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
  800752:	e8 70 0e 00 00       	call   8015c7 <_panic>
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
  800763:	56                   	push   %esi
  800764:	53                   	push   %ebx
  800765:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800768:	b8 01 00 00 00       	mov    $0x1,%eax
  80076d:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800770:	85 c0                	test   %eax,%eax
  800772:	74 4a                	je     8007be <mutex_lock+0x5e>
  800774:	8b 73 04             	mov    0x4(%ebx),%esi
  800777:	83 3e 00             	cmpl   $0x0,(%esi)
  80077a:	75 42                	jne    8007be <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  80077c:	e8 ba f9 ff ff       	call   80013b <sys_getenvid>
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	56                   	push   %esi
  800785:	50                   	push   %eax
  800786:	e8 32 ff ff ff       	call   8006bd <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80078b:	e8 ab f9 ff ff       	call   80013b <sys_getenvid>
  800790:	83 c4 08             	add    $0x8,%esp
  800793:	6a 04                	push   $0x4
  800795:	50                   	push   %eax
  800796:	e8 a5 fa ff ff       	call   800240 <sys_env_set_status>

		if (r < 0) {
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	79 15                	jns    8007b7 <mutex_lock+0x57>
			panic("%e\n", r);
  8007a2:	50                   	push   %eax
  8007a3:	68 bd 24 80 00       	push   $0x8024bd
  8007a8:	68 02 01 00 00       	push   $0x102
  8007ad:	68 45 24 80 00       	push   $0x802445
  8007b2:	e8 10 0e 00 00       	call   8015c7 <_panic>
		}
		sys_yield();
  8007b7:	e8 9e f9 ff ff       	call   80015a <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007bc:	eb 08                	jmp    8007c6 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8007be:	e8 78 f9 ff ff       	call   80013b <sys_getenvid>
  8007c3:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8007c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007c9:	5b                   	pop    %ebx
  8007ca:	5e                   	pop    %esi
  8007cb:	5d                   	pop    %ebp
  8007cc:	c3                   	ret    

008007cd <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	53                   	push   %ebx
  8007d1:	83 ec 04             	sub    $0x4,%esp
  8007d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dc:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8007df:	8b 43 04             	mov    0x4(%ebx),%eax
  8007e2:	83 38 00             	cmpl   $0x0,(%eax)
  8007e5:	74 33                	je     80081a <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8007e7:	83 ec 0c             	sub    $0xc,%esp
  8007ea:	50                   	push   %eax
  8007eb:	e8 41 ff ff ff       	call   800731 <queue_pop>
  8007f0:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8007f3:	83 c4 08             	add    $0x8,%esp
  8007f6:	6a 02                	push   $0x2
  8007f8:	50                   	push   %eax
  8007f9:	e8 42 fa ff ff       	call   800240 <sys_env_set_status>
		if (r < 0) {
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	85 c0                	test   %eax,%eax
  800803:	79 15                	jns    80081a <mutex_unlock+0x4d>
			panic("%e\n", r);
  800805:	50                   	push   %eax
  800806:	68 bd 24 80 00       	push   $0x8024bd
  80080b:	68 16 01 00 00       	push   $0x116
  800810:	68 45 24 80 00       	push   $0x802445
  800815:	e8 ad 0d 00 00       	call   8015c7 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  80081a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081d:	c9                   	leave  
  80081e:	c3                   	ret    

0080081f <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800829:	e8 0d f9 ff ff       	call   80013b <sys_getenvid>
  80082e:	83 ec 04             	sub    $0x4,%esp
  800831:	6a 07                	push   $0x7
  800833:	53                   	push   %ebx
  800834:	50                   	push   %eax
  800835:	e8 3f f9 ff ff       	call   800179 <sys_page_alloc>
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	85 c0                	test   %eax,%eax
  80083f:	79 15                	jns    800856 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800841:	50                   	push   %eax
  800842:	68 a8 24 80 00       	push   $0x8024a8
  800847:	68 22 01 00 00       	push   $0x122
  80084c:	68 45 24 80 00       	push   $0x802445
  800851:	e8 71 0d 00 00       	call   8015c7 <_panic>
	}	
	mtx->locked = 0;
  800856:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80085c:	8b 43 04             	mov    0x4(%ebx),%eax
  80085f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800865:	8b 43 04             	mov    0x4(%ebx),%eax
  800868:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80086f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  800876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800879:	c9                   	leave  
  80087a:	c3                   	ret    

0080087b <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	83 ec 04             	sub    $0x4,%esp
  800882:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  800885:	eb 21                	jmp    8008a8 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  800887:	83 ec 0c             	sub    $0xc,%esp
  80088a:	50                   	push   %eax
  80088b:	e8 a1 fe ff ff       	call   800731 <queue_pop>
  800890:	83 c4 08             	add    $0x8,%esp
  800893:	6a 02                	push   $0x2
  800895:	50                   	push   %eax
  800896:	e8 a5 f9 ff ff       	call   800240 <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  80089b:	8b 43 04             	mov    0x4(%ebx),%eax
  80089e:	8b 10                	mov    (%eax),%edx
  8008a0:	8b 52 04             	mov    0x4(%edx),%edx
  8008a3:	89 10                	mov    %edx,(%eax)
  8008a5:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8008a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8008ab:	83 38 00             	cmpl   $0x0,(%eax)
  8008ae:	75 d7                	jne    800887 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008b0:	83 ec 04             	sub    $0x4,%esp
  8008b3:	68 00 10 00 00       	push   $0x1000
  8008b8:	6a 00                	push   $0x0
  8008ba:	53                   	push   %ebx
  8008bb:	e8 aa 14 00 00       	call   801d6a <memset>
	mtx = NULL;
}
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c6:	c9                   	leave  
  8008c7:	c3                   	ret    

008008c8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8008d3:	c1 e8 0c             	shr    $0xc,%eax
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	05 00 00 00 30       	add    $0x30000000,%eax
  8008e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008e8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
  8008f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8008fa:	89 c2                	mov    %eax,%edx
  8008fc:	c1 ea 16             	shr    $0x16,%edx
  8008ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800906:	f6 c2 01             	test   $0x1,%dl
  800909:	74 11                	je     80091c <fd_alloc+0x2d>
  80090b:	89 c2                	mov    %eax,%edx
  80090d:	c1 ea 0c             	shr    $0xc,%edx
  800910:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800917:	f6 c2 01             	test   $0x1,%dl
  80091a:	75 09                	jne    800925 <fd_alloc+0x36>
			*fd_store = fd;
  80091c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
  800923:	eb 17                	jmp    80093c <fd_alloc+0x4d>
  800925:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80092a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80092f:	75 c9                	jne    8008fa <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800931:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800937:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800944:	83 f8 1f             	cmp    $0x1f,%eax
  800947:	77 36                	ja     80097f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800949:	c1 e0 0c             	shl    $0xc,%eax
  80094c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800951:	89 c2                	mov    %eax,%edx
  800953:	c1 ea 16             	shr    $0x16,%edx
  800956:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80095d:	f6 c2 01             	test   $0x1,%dl
  800960:	74 24                	je     800986 <fd_lookup+0x48>
  800962:	89 c2                	mov    %eax,%edx
  800964:	c1 ea 0c             	shr    $0xc,%edx
  800967:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80096e:	f6 c2 01             	test   $0x1,%dl
  800971:	74 1a                	je     80098d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
  800976:	89 02                	mov    %eax,(%edx)
	return 0;
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
  80097d:	eb 13                	jmp    800992 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80097f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800984:	eb 0c                	jmp    800992 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800986:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80098b:	eb 05                	jmp    800992 <fd_lookup+0x54>
  80098d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	83 ec 08             	sub    $0x8,%esp
  80099a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099d:	ba 40 25 80 00       	mov    $0x802540,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009a2:	eb 13                	jmp    8009b7 <dev_lookup+0x23>
  8009a4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009a7:	39 08                	cmp    %ecx,(%eax)
  8009a9:	75 0c                	jne    8009b7 <dev_lookup+0x23>
			*dev = devtab[i];
  8009ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ae:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b5:	eb 31                	jmp    8009e8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009b7:	8b 02                	mov    (%edx),%eax
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	75 e7                	jne    8009a4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009c8:	83 ec 04             	sub    $0x4,%esp
  8009cb:	51                   	push   %ecx
  8009cc:	50                   	push   %eax
  8009cd:	68 c4 24 80 00       	push   $0x8024c4
  8009d2:	e8 c9 0c 00 00       	call   8016a0 <cprintf>
	*dev = 0;
  8009d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009da:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009e0:	83 c4 10             	add    $0x10,%esp
  8009e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	83 ec 10             	sub    $0x10,%esp
  8009f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8009f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009fb:	50                   	push   %eax
  8009fc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a02:	c1 e8 0c             	shr    $0xc,%eax
  800a05:	50                   	push   %eax
  800a06:	e8 33 ff ff ff       	call   80093e <fd_lookup>
  800a0b:	83 c4 08             	add    $0x8,%esp
  800a0e:	85 c0                	test   %eax,%eax
  800a10:	78 05                	js     800a17 <fd_close+0x2d>
	    || fd != fd2)
  800a12:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a15:	74 0c                	je     800a23 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a17:	84 db                	test   %bl,%bl
  800a19:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1e:	0f 44 c2             	cmove  %edx,%eax
  800a21:	eb 41                	jmp    800a64 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a23:	83 ec 08             	sub    $0x8,%esp
  800a26:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a29:	50                   	push   %eax
  800a2a:	ff 36                	pushl  (%esi)
  800a2c:	e8 63 ff ff ff       	call   800994 <dev_lookup>
  800a31:	89 c3                	mov    %eax,%ebx
  800a33:	83 c4 10             	add    $0x10,%esp
  800a36:	85 c0                	test   %eax,%eax
  800a38:	78 1a                	js     800a54 <fd_close+0x6a>
		if (dev->dev_close)
  800a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a3d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a40:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a45:	85 c0                	test   %eax,%eax
  800a47:	74 0b                	je     800a54 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a49:	83 ec 0c             	sub    $0xc,%esp
  800a4c:	56                   	push   %esi
  800a4d:	ff d0                	call   *%eax
  800a4f:	89 c3                	mov    %eax,%ebx
  800a51:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a54:	83 ec 08             	sub    $0x8,%esp
  800a57:	56                   	push   %esi
  800a58:	6a 00                	push   $0x0
  800a5a:	e8 9f f7 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800a5f:	83 c4 10             	add    $0x10,%esp
  800a62:	89 d8                	mov    %ebx,%eax
}
  800a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a74:	50                   	push   %eax
  800a75:	ff 75 08             	pushl  0x8(%ebp)
  800a78:	e8 c1 fe ff ff       	call   80093e <fd_lookup>
  800a7d:	83 c4 08             	add    $0x8,%esp
  800a80:	85 c0                	test   %eax,%eax
  800a82:	78 10                	js     800a94 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a84:	83 ec 08             	sub    $0x8,%esp
  800a87:	6a 01                	push   $0x1
  800a89:	ff 75 f4             	pushl  -0xc(%ebp)
  800a8c:	e8 59 ff ff ff       	call   8009ea <fd_close>
  800a91:	83 c4 10             	add    $0x10,%esp
}
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <close_all>:

void
close_all(void)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	53                   	push   %ebx
  800a9a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800a9d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800aa2:	83 ec 0c             	sub    $0xc,%esp
  800aa5:	53                   	push   %ebx
  800aa6:	e8 c0 ff ff ff       	call   800a6b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800aab:	83 c3 01             	add    $0x1,%ebx
  800aae:	83 c4 10             	add    $0x10,%esp
  800ab1:	83 fb 20             	cmp    $0x20,%ebx
  800ab4:	75 ec                	jne    800aa2 <close_all+0xc>
		close(i);
}
  800ab6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab9:	c9                   	leave  
  800aba:	c3                   	ret    

00800abb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	57                   	push   %edi
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	83 ec 2c             	sub    $0x2c,%esp
  800ac4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ac7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800aca:	50                   	push   %eax
  800acb:	ff 75 08             	pushl  0x8(%ebp)
  800ace:	e8 6b fe ff ff       	call   80093e <fd_lookup>
  800ad3:	83 c4 08             	add    $0x8,%esp
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	0f 88 c1 00 00 00    	js     800b9f <dup+0xe4>
		return r;
	close(newfdnum);
  800ade:	83 ec 0c             	sub    $0xc,%esp
  800ae1:	56                   	push   %esi
  800ae2:	e8 84 ff ff ff       	call   800a6b <close>

	newfd = INDEX2FD(newfdnum);
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	c1 e3 0c             	shl    $0xc,%ebx
  800aec:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800af2:	83 c4 04             	add    $0x4,%esp
  800af5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800af8:	e8 db fd ff ff       	call   8008d8 <fd2data>
  800afd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800aff:	89 1c 24             	mov    %ebx,(%esp)
  800b02:	e8 d1 fd ff ff       	call   8008d8 <fd2data>
  800b07:	83 c4 10             	add    $0x10,%esp
  800b0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b0d:	89 f8                	mov    %edi,%eax
  800b0f:	c1 e8 16             	shr    $0x16,%eax
  800b12:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b19:	a8 01                	test   $0x1,%al
  800b1b:	74 37                	je     800b54 <dup+0x99>
  800b1d:	89 f8                	mov    %edi,%eax
  800b1f:	c1 e8 0c             	shr    $0xc,%eax
  800b22:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b29:	f6 c2 01             	test   $0x1,%dl
  800b2c:	74 26                	je     800b54 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b2e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b35:	83 ec 0c             	sub    $0xc,%esp
  800b38:	25 07 0e 00 00       	and    $0xe07,%eax
  800b3d:	50                   	push   %eax
  800b3e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b41:	6a 00                	push   $0x0
  800b43:	57                   	push   %edi
  800b44:	6a 00                	push   $0x0
  800b46:	e8 71 f6 ff ff       	call   8001bc <sys_page_map>
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	83 c4 20             	add    $0x20,%esp
  800b50:	85 c0                	test   %eax,%eax
  800b52:	78 2e                	js     800b82 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b57:	89 d0                	mov    %edx,%eax
  800b59:	c1 e8 0c             	shr    $0xc,%eax
  800b5c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	25 07 0e 00 00       	and    $0xe07,%eax
  800b6b:	50                   	push   %eax
  800b6c:	53                   	push   %ebx
  800b6d:	6a 00                	push   $0x0
  800b6f:	52                   	push   %edx
  800b70:	6a 00                	push   $0x0
  800b72:	e8 45 f6 ff ff       	call   8001bc <sys_page_map>
  800b77:	89 c7                	mov    %eax,%edi
  800b79:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b7c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b7e:	85 ff                	test   %edi,%edi
  800b80:	79 1d                	jns    800b9f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b82:	83 ec 08             	sub    $0x8,%esp
  800b85:	53                   	push   %ebx
  800b86:	6a 00                	push   $0x0
  800b88:	e8 71 f6 ff ff       	call   8001fe <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b8d:	83 c4 08             	add    $0x8,%esp
  800b90:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b93:	6a 00                	push   $0x0
  800b95:	e8 64 f6 ff ff       	call   8001fe <sys_page_unmap>
	return r;
  800b9a:	83 c4 10             	add    $0x10,%esp
  800b9d:	89 f8                	mov    %edi,%eax
}
  800b9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	53                   	push   %ebx
  800bab:	83 ec 14             	sub    $0x14,%esp
  800bae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bb1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bb4:	50                   	push   %eax
  800bb5:	53                   	push   %ebx
  800bb6:	e8 83 fd ff ff       	call   80093e <fd_lookup>
  800bbb:	83 c4 08             	add    $0x8,%esp
  800bbe:	89 c2                	mov    %eax,%edx
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	78 70                	js     800c34 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bc4:	83 ec 08             	sub    $0x8,%esp
  800bc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bca:	50                   	push   %eax
  800bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bce:	ff 30                	pushl  (%eax)
  800bd0:	e8 bf fd ff ff       	call   800994 <dev_lookup>
  800bd5:	83 c4 10             	add    $0x10,%esp
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	78 4f                	js     800c2b <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800bdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bdf:	8b 42 08             	mov    0x8(%edx),%eax
  800be2:	83 e0 03             	and    $0x3,%eax
  800be5:	83 f8 01             	cmp    $0x1,%eax
  800be8:	75 24                	jne    800c0e <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bea:	a1 04 40 80 00       	mov    0x804004,%eax
  800bef:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800bf5:	83 ec 04             	sub    $0x4,%esp
  800bf8:	53                   	push   %ebx
  800bf9:	50                   	push   %eax
  800bfa:	68 05 25 80 00       	push   $0x802505
  800bff:	e8 9c 0a 00 00       	call   8016a0 <cprintf>
		return -E_INVAL;
  800c04:	83 c4 10             	add    $0x10,%esp
  800c07:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c0c:	eb 26                	jmp    800c34 <read+0x8d>
	}
	if (!dev->dev_read)
  800c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c11:	8b 40 08             	mov    0x8(%eax),%eax
  800c14:	85 c0                	test   %eax,%eax
  800c16:	74 17                	je     800c2f <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c18:	83 ec 04             	sub    $0x4,%esp
  800c1b:	ff 75 10             	pushl  0x10(%ebp)
  800c1e:	ff 75 0c             	pushl  0xc(%ebp)
  800c21:	52                   	push   %edx
  800c22:	ff d0                	call   *%eax
  800c24:	89 c2                	mov    %eax,%edx
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	eb 09                	jmp    800c34 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c2b:	89 c2                	mov    %eax,%edx
  800c2d:	eb 05                	jmp    800c34 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c2f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c34:	89 d0                	mov    %edx,%eax
  800c36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    

00800c3b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c47:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4f:	eb 21                	jmp    800c72 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c51:	83 ec 04             	sub    $0x4,%esp
  800c54:	89 f0                	mov    %esi,%eax
  800c56:	29 d8                	sub    %ebx,%eax
  800c58:	50                   	push   %eax
  800c59:	89 d8                	mov    %ebx,%eax
  800c5b:	03 45 0c             	add    0xc(%ebp),%eax
  800c5e:	50                   	push   %eax
  800c5f:	57                   	push   %edi
  800c60:	e8 42 ff ff ff       	call   800ba7 <read>
		if (m < 0)
  800c65:	83 c4 10             	add    $0x10,%esp
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	78 10                	js     800c7c <readn+0x41>
			return m;
		if (m == 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	74 0a                	je     800c7a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c70:	01 c3                	add    %eax,%ebx
  800c72:	39 f3                	cmp    %esi,%ebx
  800c74:	72 db                	jb     800c51 <readn+0x16>
  800c76:	89 d8                	mov    %ebx,%eax
  800c78:	eb 02                	jmp    800c7c <readn+0x41>
  800c7a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7f:	5b                   	pop    %ebx
  800c80:	5e                   	pop    %esi
  800c81:	5f                   	pop    %edi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	53                   	push   %ebx
  800c88:	83 ec 14             	sub    $0x14,%esp
  800c8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c91:	50                   	push   %eax
  800c92:	53                   	push   %ebx
  800c93:	e8 a6 fc ff ff       	call   80093e <fd_lookup>
  800c98:	83 c4 08             	add    $0x8,%esp
  800c9b:	89 c2                	mov    %eax,%edx
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	78 6b                	js     800d0c <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ca1:	83 ec 08             	sub    $0x8,%esp
  800ca4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca7:	50                   	push   %eax
  800ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cab:	ff 30                	pushl  (%eax)
  800cad:	e8 e2 fc ff ff       	call   800994 <dev_lookup>
  800cb2:	83 c4 10             	add    $0x10,%esp
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	78 4a                	js     800d03 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cbc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cc0:	75 24                	jne    800ce6 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800cc2:	a1 04 40 80 00       	mov    0x804004,%eax
  800cc7:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800ccd:	83 ec 04             	sub    $0x4,%esp
  800cd0:	53                   	push   %ebx
  800cd1:	50                   	push   %eax
  800cd2:	68 21 25 80 00       	push   $0x802521
  800cd7:	e8 c4 09 00 00       	call   8016a0 <cprintf>
		return -E_INVAL;
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ce4:	eb 26                	jmp    800d0c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ce6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ce9:	8b 52 0c             	mov    0xc(%edx),%edx
  800cec:	85 d2                	test   %edx,%edx
  800cee:	74 17                	je     800d07 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800cf0:	83 ec 04             	sub    $0x4,%esp
  800cf3:	ff 75 10             	pushl  0x10(%ebp)
  800cf6:	ff 75 0c             	pushl  0xc(%ebp)
  800cf9:	50                   	push   %eax
  800cfa:	ff d2                	call   *%edx
  800cfc:	89 c2                	mov    %eax,%edx
  800cfe:	83 c4 10             	add    $0x10,%esp
  800d01:	eb 09                	jmp    800d0c <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d03:	89 c2                	mov    %eax,%edx
  800d05:	eb 05                	jmp    800d0c <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d07:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d0c:	89 d0                	mov    %edx,%eax
  800d0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    

00800d13 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d19:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d1c:	50                   	push   %eax
  800d1d:	ff 75 08             	pushl  0x8(%ebp)
  800d20:	e8 19 fc ff ff       	call   80093e <fd_lookup>
  800d25:	83 c4 08             	add    $0x8,%esp
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	78 0e                	js     800d3a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d32:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3a:	c9                   	leave  
  800d3b:	c3                   	ret    

00800d3c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 14             	sub    $0x14,%esp
  800d43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d49:	50                   	push   %eax
  800d4a:	53                   	push   %ebx
  800d4b:	e8 ee fb ff ff       	call   80093e <fd_lookup>
  800d50:	83 c4 08             	add    $0x8,%esp
  800d53:	89 c2                	mov    %eax,%edx
  800d55:	85 c0                	test   %eax,%eax
  800d57:	78 68                	js     800dc1 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d59:	83 ec 08             	sub    $0x8,%esp
  800d5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5f:	50                   	push   %eax
  800d60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d63:	ff 30                	pushl  (%eax)
  800d65:	e8 2a fc ff ff       	call   800994 <dev_lookup>
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	78 47                	js     800db8 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d74:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d78:	75 24                	jne    800d9e <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d7a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d7f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d85:	83 ec 04             	sub    $0x4,%esp
  800d88:	53                   	push   %ebx
  800d89:	50                   	push   %eax
  800d8a:	68 e4 24 80 00       	push   $0x8024e4
  800d8f:	e8 0c 09 00 00       	call   8016a0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d9c:	eb 23                	jmp    800dc1 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800d9e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800da1:	8b 52 18             	mov    0x18(%edx),%edx
  800da4:	85 d2                	test   %edx,%edx
  800da6:	74 14                	je     800dbc <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	ff 75 0c             	pushl  0xc(%ebp)
  800dae:	50                   	push   %eax
  800daf:	ff d2                	call   *%edx
  800db1:	89 c2                	mov    %eax,%edx
  800db3:	83 c4 10             	add    $0x10,%esp
  800db6:	eb 09                	jmp    800dc1 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800db8:	89 c2                	mov    %eax,%edx
  800dba:	eb 05                	jmp    800dc1 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dbc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dc1:	89 d0                	mov    %edx,%eax
  800dc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	53                   	push   %ebx
  800dcc:	83 ec 14             	sub    $0x14,%esp
  800dcf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dd2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd5:	50                   	push   %eax
  800dd6:	ff 75 08             	pushl  0x8(%ebp)
  800dd9:	e8 60 fb ff ff       	call   80093e <fd_lookup>
  800dde:	83 c4 08             	add    $0x8,%esp
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	85 c0                	test   %eax,%eax
  800de5:	78 58                	js     800e3f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800de7:	83 ec 08             	sub    $0x8,%esp
  800dea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ded:	50                   	push   %eax
  800dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df1:	ff 30                	pushl  (%eax)
  800df3:	e8 9c fb ff ff       	call   800994 <dev_lookup>
  800df8:	83 c4 10             	add    $0x10,%esp
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	78 37                	js     800e36 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e02:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e06:	74 32                	je     800e3a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e08:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e0b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e12:	00 00 00 
	stat->st_isdir = 0;
  800e15:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e1c:	00 00 00 
	stat->st_dev = dev;
  800e1f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e25:	83 ec 08             	sub    $0x8,%esp
  800e28:	53                   	push   %ebx
  800e29:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2c:	ff 50 14             	call   *0x14(%eax)
  800e2f:	89 c2                	mov    %eax,%edx
  800e31:	83 c4 10             	add    $0x10,%esp
  800e34:	eb 09                	jmp    800e3f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	eb 05                	jmp    800e3f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e3a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e3f:	89 d0                	mov    %edx,%eax
  800e41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e44:	c9                   	leave  
  800e45:	c3                   	ret    

00800e46 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e4b:	83 ec 08             	sub    $0x8,%esp
  800e4e:	6a 00                	push   $0x0
  800e50:	ff 75 08             	pushl  0x8(%ebp)
  800e53:	e8 e3 01 00 00       	call   80103b <open>
  800e58:	89 c3                	mov    %eax,%ebx
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	78 1b                	js     800e7c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e61:	83 ec 08             	sub    $0x8,%esp
  800e64:	ff 75 0c             	pushl  0xc(%ebp)
  800e67:	50                   	push   %eax
  800e68:	e8 5b ff ff ff       	call   800dc8 <fstat>
  800e6d:	89 c6                	mov    %eax,%esi
	close(fd);
  800e6f:	89 1c 24             	mov    %ebx,(%esp)
  800e72:	e8 f4 fb ff ff       	call   800a6b <close>
	return r;
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	89 f0                	mov    %esi,%eax
}
  800e7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	89 c6                	mov    %eax,%esi
  800e8a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e8c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e93:	75 12                	jne    800ea7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	6a 01                	push   $0x1
  800e9a:	e8 39 12 00 00       	call   8020d8 <ipc_find_env>
  800e9f:	a3 00 40 80 00       	mov    %eax,0x804000
  800ea4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ea7:	6a 07                	push   $0x7
  800ea9:	68 00 50 80 00       	push   $0x805000
  800eae:	56                   	push   %esi
  800eaf:	ff 35 00 40 80 00    	pushl  0x804000
  800eb5:	e8 bc 11 00 00       	call   802076 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800eba:	83 c4 0c             	add    $0xc,%esp
  800ebd:	6a 00                	push   $0x0
  800ebf:	53                   	push   %ebx
  800ec0:	6a 00                	push   $0x0
  800ec2:	e8 34 11 00 00       	call   801ffb <ipc_recv>
}
  800ec7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eca:	5b                   	pop    %ebx
  800ecb:	5e                   	pop    %esi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed7:	8b 40 0c             	mov    0xc(%eax),%eax
  800eda:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ee7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eec:	b8 02 00 00 00       	mov    $0x2,%eax
  800ef1:	e8 8d ff ff ff       	call   800e83 <fsipc>
}
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800efe:	8b 45 08             	mov    0x8(%ebp),%eax
  800f01:	8b 40 0c             	mov    0xc(%eax),%eax
  800f04:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f09:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f13:	e8 6b ff ff ff       	call   800e83 <fsipc>
}
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	53                   	push   %ebx
  800f1e:	83 ec 04             	sub    $0x4,%esp
  800f21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f24:	8b 45 08             	mov    0x8(%ebp),%eax
  800f27:	8b 40 0c             	mov    0xc(%eax),%eax
  800f2a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f34:	b8 05 00 00 00       	mov    $0x5,%eax
  800f39:	e8 45 ff ff ff       	call   800e83 <fsipc>
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	78 2c                	js     800f6e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f42:	83 ec 08             	sub    $0x8,%esp
  800f45:	68 00 50 80 00       	push   $0x805000
  800f4a:	53                   	push   %ebx
  800f4b:	e8 d5 0c 00 00       	call   801c25 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f50:	a1 80 50 80 00       	mov    0x805080,%eax
  800f55:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f5b:	a1 84 50 80 00       	mov    0x805084,%eax
  800f60:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	83 ec 0c             	sub    $0xc,%esp
  800f79:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7f:	8b 52 0c             	mov    0xc(%edx),%edx
  800f82:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f88:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f8d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800f92:	0f 47 c2             	cmova  %edx,%eax
  800f95:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800f9a:	50                   	push   %eax
  800f9b:	ff 75 0c             	pushl  0xc(%ebp)
  800f9e:	68 08 50 80 00       	push   $0x805008
  800fa3:	e8 0f 0e 00 00       	call   801db7 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fa8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fad:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb2:	e8 cc fe ff ff       	call   800e83 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	56                   	push   %esi
  800fbd:	53                   	push   %ebx
  800fbe:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc4:	8b 40 0c             	mov    0xc(%eax),%eax
  800fc7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fcc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd7:	b8 03 00 00 00       	mov    $0x3,%eax
  800fdc:	e8 a2 fe ff ff       	call   800e83 <fsipc>
  800fe1:	89 c3                	mov    %eax,%ebx
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	78 4b                	js     801032 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800fe7:	39 c6                	cmp    %eax,%esi
  800fe9:	73 16                	jae    801001 <devfile_read+0x48>
  800feb:	68 50 25 80 00       	push   $0x802550
  800ff0:	68 57 25 80 00       	push   $0x802557
  800ff5:	6a 7c                	push   $0x7c
  800ff7:	68 6c 25 80 00       	push   $0x80256c
  800ffc:	e8 c6 05 00 00       	call   8015c7 <_panic>
	assert(r <= PGSIZE);
  801001:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801006:	7e 16                	jle    80101e <devfile_read+0x65>
  801008:	68 77 25 80 00       	push   $0x802577
  80100d:	68 57 25 80 00       	push   $0x802557
  801012:	6a 7d                	push   $0x7d
  801014:	68 6c 25 80 00       	push   $0x80256c
  801019:	e8 a9 05 00 00       	call   8015c7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80101e:	83 ec 04             	sub    $0x4,%esp
  801021:	50                   	push   %eax
  801022:	68 00 50 80 00       	push   $0x805000
  801027:	ff 75 0c             	pushl  0xc(%ebp)
  80102a:	e8 88 0d 00 00       	call   801db7 <memmove>
	return r;
  80102f:	83 c4 10             	add    $0x10,%esp
}
  801032:	89 d8                	mov    %ebx,%eax
  801034:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801037:	5b                   	pop    %ebx
  801038:	5e                   	pop    %esi
  801039:	5d                   	pop    %ebp
  80103a:	c3                   	ret    

0080103b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	53                   	push   %ebx
  80103f:	83 ec 20             	sub    $0x20,%esp
  801042:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801045:	53                   	push   %ebx
  801046:	e8 a1 0b 00 00       	call   801bec <strlen>
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801053:	7f 67                	jg     8010bc <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105b:	50                   	push   %eax
  80105c:	e8 8e f8 ff ff       	call   8008ef <fd_alloc>
  801061:	83 c4 10             	add    $0x10,%esp
		return r;
  801064:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801066:	85 c0                	test   %eax,%eax
  801068:	78 57                	js     8010c1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80106a:	83 ec 08             	sub    $0x8,%esp
  80106d:	53                   	push   %ebx
  80106e:	68 00 50 80 00       	push   $0x805000
  801073:	e8 ad 0b 00 00       	call   801c25 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801078:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801080:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801083:	b8 01 00 00 00       	mov    $0x1,%eax
  801088:	e8 f6 fd ff ff       	call   800e83 <fsipc>
  80108d:	89 c3                	mov    %eax,%ebx
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	79 14                	jns    8010aa <open+0x6f>
		fd_close(fd, 0);
  801096:	83 ec 08             	sub    $0x8,%esp
  801099:	6a 00                	push   $0x0
  80109b:	ff 75 f4             	pushl  -0xc(%ebp)
  80109e:	e8 47 f9 ff ff       	call   8009ea <fd_close>
		return r;
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	89 da                	mov    %ebx,%edx
  8010a8:	eb 17                	jmp    8010c1 <open+0x86>
	}

	return fd2num(fd);
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b0:	e8 13 f8 ff ff       	call   8008c8 <fd2num>
  8010b5:	89 c2                	mov    %eax,%edx
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	eb 05                	jmp    8010c1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010bc:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010c1:	89 d0                	mov    %edx,%eax
  8010c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    

008010c8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d3:	b8 08 00 00 00       	mov    $0x8,%eax
  8010d8:	e8 a6 fd ff ff       	call   800e83 <fsipc>
}
  8010dd:	c9                   	leave  
  8010de:	c3                   	ret    

008010df <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010df:	55                   	push   %ebp
  8010e0:	89 e5                	mov    %esp,%ebp
  8010e2:	56                   	push   %esi
  8010e3:	53                   	push   %ebx
  8010e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010e7:	83 ec 0c             	sub    $0xc,%esp
  8010ea:	ff 75 08             	pushl  0x8(%ebp)
  8010ed:	e8 e6 f7 ff ff       	call   8008d8 <fd2data>
  8010f2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010f4:	83 c4 08             	add    $0x8,%esp
  8010f7:	68 83 25 80 00       	push   $0x802583
  8010fc:	53                   	push   %ebx
  8010fd:	e8 23 0b 00 00       	call   801c25 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801102:	8b 46 04             	mov    0x4(%esi),%eax
  801105:	2b 06                	sub    (%esi),%eax
  801107:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80110d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801114:	00 00 00 
	stat->st_dev = &devpipe;
  801117:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80111e:	30 80 00 
	return 0;
}
  801121:	b8 00 00 00 00       	mov    $0x0,%eax
  801126:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	53                   	push   %ebx
  801131:	83 ec 0c             	sub    $0xc,%esp
  801134:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801137:	53                   	push   %ebx
  801138:	6a 00                	push   $0x0
  80113a:	e8 bf f0 ff ff       	call   8001fe <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80113f:	89 1c 24             	mov    %ebx,(%esp)
  801142:	e8 91 f7 ff ff       	call   8008d8 <fd2data>
  801147:	83 c4 08             	add    $0x8,%esp
  80114a:	50                   	push   %eax
  80114b:	6a 00                	push   $0x0
  80114d:	e8 ac f0 ff ff       	call   8001fe <sys_page_unmap>
}
  801152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 1c             	sub    $0x1c,%esp
  801160:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801163:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801165:	a1 04 40 80 00       	mov    0x804004,%eax
  80116a:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801170:	83 ec 0c             	sub    $0xc,%esp
  801173:	ff 75 e0             	pushl  -0x20(%ebp)
  801176:	e8 a2 0f 00 00       	call   80211d <pageref>
  80117b:	89 c3                	mov    %eax,%ebx
  80117d:	89 3c 24             	mov    %edi,(%esp)
  801180:	e8 98 0f 00 00       	call   80211d <pageref>
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	39 c3                	cmp    %eax,%ebx
  80118a:	0f 94 c1             	sete   %cl
  80118d:	0f b6 c9             	movzbl %cl,%ecx
  801190:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801193:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801199:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  80119f:	39 ce                	cmp    %ecx,%esi
  8011a1:	74 1e                	je     8011c1 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011a3:	39 c3                	cmp    %eax,%ebx
  8011a5:	75 be                	jne    801165 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011a7:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b0:	50                   	push   %eax
  8011b1:	56                   	push   %esi
  8011b2:	68 8a 25 80 00       	push   $0x80258a
  8011b7:	e8 e4 04 00 00       	call   8016a0 <cprintf>
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	eb a4                	jmp    801165 <_pipeisclosed+0xe>
	}
}
  8011c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c7:	5b                   	pop    %ebx
  8011c8:	5e                   	pop    %esi
  8011c9:	5f                   	pop    %edi
  8011ca:	5d                   	pop    %ebp
  8011cb:	c3                   	ret    

008011cc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	57                   	push   %edi
  8011d0:	56                   	push   %esi
  8011d1:	53                   	push   %ebx
  8011d2:	83 ec 28             	sub    $0x28,%esp
  8011d5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011d8:	56                   	push   %esi
  8011d9:	e8 fa f6 ff ff       	call   8008d8 <fd2data>
  8011de:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e8:	eb 4b                	jmp    801235 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011ea:	89 da                	mov    %ebx,%edx
  8011ec:	89 f0                	mov    %esi,%eax
  8011ee:	e8 64 ff ff ff       	call   801157 <_pipeisclosed>
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	75 48                	jne    80123f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011f7:	e8 5e ef ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011fc:	8b 43 04             	mov    0x4(%ebx),%eax
  8011ff:	8b 0b                	mov    (%ebx),%ecx
  801201:	8d 51 20             	lea    0x20(%ecx),%edx
  801204:	39 d0                	cmp    %edx,%eax
  801206:	73 e2                	jae    8011ea <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80120f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801212:	89 c2                	mov    %eax,%edx
  801214:	c1 fa 1f             	sar    $0x1f,%edx
  801217:	89 d1                	mov    %edx,%ecx
  801219:	c1 e9 1b             	shr    $0x1b,%ecx
  80121c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80121f:	83 e2 1f             	and    $0x1f,%edx
  801222:	29 ca                	sub    %ecx,%edx
  801224:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801228:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80122c:	83 c0 01             	add    $0x1,%eax
  80122f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801232:	83 c7 01             	add    $0x1,%edi
  801235:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801238:	75 c2                	jne    8011fc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80123a:	8b 45 10             	mov    0x10(%ebp),%eax
  80123d:	eb 05                	jmp    801244 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5f                   	pop    %edi
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	57                   	push   %edi
  801250:	56                   	push   %esi
  801251:	53                   	push   %ebx
  801252:	83 ec 18             	sub    $0x18,%esp
  801255:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801258:	57                   	push   %edi
  801259:	e8 7a f6 ff ff       	call   8008d8 <fd2data>
  80125e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	bb 00 00 00 00       	mov    $0x0,%ebx
  801268:	eb 3d                	jmp    8012a7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80126a:	85 db                	test   %ebx,%ebx
  80126c:	74 04                	je     801272 <devpipe_read+0x26>
				return i;
  80126e:	89 d8                	mov    %ebx,%eax
  801270:	eb 44                	jmp    8012b6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801272:	89 f2                	mov    %esi,%edx
  801274:	89 f8                	mov    %edi,%eax
  801276:	e8 dc fe ff ff       	call   801157 <_pipeisclosed>
  80127b:	85 c0                	test   %eax,%eax
  80127d:	75 32                	jne    8012b1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80127f:	e8 d6 ee ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801284:	8b 06                	mov    (%esi),%eax
  801286:	3b 46 04             	cmp    0x4(%esi),%eax
  801289:	74 df                	je     80126a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80128b:	99                   	cltd   
  80128c:	c1 ea 1b             	shr    $0x1b,%edx
  80128f:	01 d0                	add    %edx,%eax
  801291:	83 e0 1f             	and    $0x1f,%eax
  801294:	29 d0                	sub    %edx,%eax
  801296:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80129b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012a1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012a4:	83 c3 01             	add    $0x1,%ebx
  8012a7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012aa:	75 d8                	jne    801284 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8012af:	eb 05                	jmp    8012b6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012b1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5e                   	pop    %esi
  8012bb:	5f                   	pop    %edi
  8012bc:	5d                   	pop    %ebp
  8012bd:	c3                   	ret    

008012be <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	56                   	push   %esi
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	e8 20 f6 ff ff       	call   8008ef <fd_alloc>
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	89 c2                	mov    %eax,%edx
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	0f 88 2c 01 00 00    	js     801408 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012dc:	83 ec 04             	sub    $0x4,%esp
  8012df:	68 07 04 00 00       	push   $0x407
  8012e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e7:	6a 00                	push   $0x0
  8012e9:	e8 8b ee ff ff       	call   800179 <sys_page_alloc>
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	0f 88 0d 01 00 00    	js     801408 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	e8 e8 f5 ff ff       	call   8008ef <fd_alloc>
  801307:	89 c3                	mov    %eax,%ebx
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	85 c0                	test   %eax,%eax
  80130e:	0f 88 e2 00 00 00    	js     8013f6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801314:	83 ec 04             	sub    $0x4,%esp
  801317:	68 07 04 00 00       	push   $0x407
  80131c:	ff 75 f0             	pushl  -0x10(%ebp)
  80131f:	6a 00                	push   $0x0
  801321:	e8 53 ee ff ff       	call   800179 <sys_page_alloc>
  801326:	89 c3                	mov    %eax,%ebx
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	85 c0                	test   %eax,%eax
  80132d:	0f 88 c3 00 00 00    	js     8013f6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	ff 75 f4             	pushl  -0xc(%ebp)
  801339:	e8 9a f5 ff ff       	call   8008d8 <fd2data>
  80133e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801340:	83 c4 0c             	add    $0xc,%esp
  801343:	68 07 04 00 00       	push   $0x407
  801348:	50                   	push   %eax
  801349:	6a 00                	push   $0x0
  80134b:	e8 29 ee ff ff       	call   800179 <sys_page_alloc>
  801350:	89 c3                	mov    %eax,%ebx
  801352:	83 c4 10             	add    $0x10,%esp
  801355:	85 c0                	test   %eax,%eax
  801357:	0f 88 89 00 00 00    	js     8013e6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80135d:	83 ec 0c             	sub    $0xc,%esp
  801360:	ff 75 f0             	pushl  -0x10(%ebp)
  801363:	e8 70 f5 ff ff       	call   8008d8 <fd2data>
  801368:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80136f:	50                   	push   %eax
  801370:	6a 00                	push   $0x0
  801372:	56                   	push   %esi
  801373:	6a 00                	push   $0x0
  801375:	e8 42 ee ff ff       	call   8001bc <sys_page_map>
  80137a:	89 c3                	mov    %eax,%ebx
  80137c:	83 c4 20             	add    $0x20,%esp
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 55                	js     8013d8 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801383:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80138e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801391:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801398:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013ad:	83 ec 0c             	sub    $0xc,%esp
  8013b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b3:	e8 10 f5 ff ff       	call   8008c8 <fd2num>
  8013b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013bb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013bd:	83 c4 04             	add    $0x4,%esp
  8013c0:	ff 75 f0             	pushl  -0x10(%ebp)
  8013c3:	e8 00 f5 ff ff       	call   8008c8 <fd2num>
  8013c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013cb:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d6:	eb 30                	jmp    801408 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013d8:	83 ec 08             	sub    $0x8,%esp
  8013db:	56                   	push   %esi
  8013dc:	6a 00                	push   $0x0
  8013de:	e8 1b ee ff ff       	call   8001fe <sys_page_unmap>
  8013e3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ec:	6a 00                	push   $0x0
  8013ee:	e8 0b ee ff ff       	call   8001fe <sys_page_unmap>
  8013f3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8013fc:	6a 00                	push   $0x0
  8013fe:	e8 fb ed ff ff       	call   8001fe <sys_page_unmap>
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801408:	89 d0                	mov    %edx,%eax
  80140a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    

00801411 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801417:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	ff 75 08             	pushl  0x8(%ebp)
  80141e:	e8 1b f5 ff ff       	call   80093e <fd_lookup>
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	85 c0                	test   %eax,%eax
  801428:	78 18                	js     801442 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80142a:	83 ec 0c             	sub    $0xc,%esp
  80142d:	ff 75 f4             	pushl  -0xc(%ebp)
  801430:	e8 a3 f4 ff ff       	call   8008d8 <fd2data>
	return _pipeisclosed(fd, p);
  801435:	89 c2                	mov    %eax,%edx
  801437:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143a:	e8 18 fd ff ff       	call   801157 <_pipeisclosed>
  80143f:	83 c4 10             	add    $0x10,%esp
}
  801442:	c9                   	leave  
  801443:	c3                   	ret    

00801444 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801447:	b8 00 00 00 00       	mov    $0x0,%eax
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    

0080144e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801454:	68 a2 25 80 00       	push   $0x8025a2
  801459:	ff 75 0c             	pushl  0xc(%ebp)
  80145c:	e8 c4 07 00 00       	call   801c25 <strcpy>
	return 0;
}
  801461:	b8 00 00 00 00       	mov    $0x0,%eax
  801466:	c9                   	leave  
  801467:	c3                   	ret    

00801468 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	57                   	push   %edi
  80146c:	56                   	push   %esi
  80146d:	53                   	push   %ebx
  80146e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801474:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801479:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80147f:	eb 2d                	jmp    8014ae <devcons_write+0x46>
		m = n - tot;
  801481:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801484:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801486:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801489:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80148e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801491:	83 ec 04             	sub    $0x4,%esp
  801494:	53                   	push   %ebx
  801495:	03 45 0c             	add    0xc(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	57                   	push   %edi
  80149a:	e8 18 09 00 00       	call   801db7 <memmove>
		sys_cputs(buf, m);
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	53                   	push   %ebx
  8014a3:	57                   	push   %edi
  8014a4:	e8 14 ec ff ff       	call   8000bd <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014a9:	01 de                	add    %ebx,%esi
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	89 f0                	mov    %esi,%eax
  8014b0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014b3:	72 cc                	jb     801481 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b8:	5b                   	pop    %ebx
  8014b9:	5e                   	pop    %esi
  8014ba:	5f                   	pop    %edi
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    

008014bd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	83 ec 08             	sub    $0x8,%esp
  8014c3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014cc:	74 2a                	je     8014f8 <devcons_read+0x3b>
  8014ce:	eb 05                	jmp    8014d5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014d0:	e8 85 ec ff ff       	call   80015a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014d5:	e8 01 ec ff ff       	call   8000db <sys_cgetc>
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	74 f2                	je     8014d0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	78 16                	js     8014f8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014e2:	83 f8 04             	cmp    $0x4,%eax
  8014e5:	74 0c                	je     8014f3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ea:	88 02                	mov    %al,(%edx)
	return 1;
  8014ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f1:	eb 05                	jmp    8014f8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014f3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801500:	8b 45 08             	mov    0x8(%ebp),%eax
  801503:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801506:	6a 01                	push   $0x1
  801508:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80150b:	50                   	push   %eax
  80150c:	e8 ac eb ff ff       	call   8000bd <sys_cputs>
}
  801511:	83 c4 10             	add    $0x10,%esp
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <getchar>:

int
getchar(void)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80151c:	6a 01                	push   $0x1
  80151e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	6a 00                	push   $0x0
  801524:	e8 7e f6 ff ff       	call   800ba7 <read>
	if (r < 0)
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 0f                	js     80153f <getchar+0x29>
		return r;
	if (r < 1)
  801530:	85 c0                	test   %eax,%eax
  801532:	7e 06                	jle    80153a <getchar+0x24>
		return -E_EOF;
	return c;
  801534:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801538:	eb 05                	jmp    80153f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80153a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801547:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	ff 75 08             	pushl  0x8(%ebp)
  80154e:	e8 eb f3 ff ff       	call   80093e <fd_lookup>
  801553:	83 c4 10             	add    $0x10,%esp
  801556:	85 c0                	test   %eax,%eax
  801558:	78 11                	js     80156b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80155a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801563:	39 10                	cmp    %edx,(%eax)
  801565:	0f 94 c0             	sete   %al
  801568:	0f b6 c0             	movzbl %al,%eax
}
  80156b:	c9                   	leave  
  80156c:	c3                   	ret    

0080156d <opencons>:

int
opencons(void)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801573:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801576:	50                   	push   %eax
  801577:	e8 73 f3 ff ff       	call   8008ef <fd_alloc>
  80157c:	83 c4 10             	add    $0x10,%esp
		return r;
  80157f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801581:	85 c0                	test   %eax,%eax
  801583:	78 3e                	js     8015c3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801585:	83 ec 04             	sub    $0x4,%esp
  801588:	68 07 04 00 00       	push   $0x407
  80158d:	ff 75 f4             	pushl  -0xc(%ebp)
  801590:	6a 00                	push   $0x0
  801592:	e8 e2 eb ff ff       	call   800179 <sys_page_alloc>
  801597:	83 c4 10             	add    $0x10,%esp
		return r;
  80159a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 23                	js     8015c3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015a0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	50                   	push   %eax
  8015b9:	e8 0a f3 ff ff       	call   8008c8 <fd2num>
  8015be:	89 c2                	mov    %eax,%edx
  8015c0:	83 c4 10             	add    $0x10,%esp
}
  8015c3:	89 d0                	mov    %edx,%eax
  8015c5:	c9                   	leave  
  8015c6:	c3                   	ret    

008015c7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	56                   	push   %esi
  8015cb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015cc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015cf:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015d5:	e8 61 eb ff ff       	call   80013b <sys_getenvid>
  8015da:	83 ec 0c             	sub    $0xc,%esp
  8015dd:	ff 75 0c             	pushl  0xc(%ebp)
  8015e0:	ff 75 08             	pushl  0x8(%ebp)
  8015e3:	56                   	push   %esi
  8015e4:	50                   	push   %eax
  8015e5:	68 b0 25 80 00       	push   $0x8025b0
  8015ea:	e8 b1 00 00 00       	call   8016a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015ef:	83 c4 18             	add    $0x18,%esp
  8015f2:	53                   	push   %ebx
  8015f3:	ff 75 10             	pushl  0x10(%ebp)
  8015f6:	e8 54 00 00 00       	call   80164f <vcprintf>
	cprintf("\n");
  8015fb:	c7 04 24 a6 24 80 00 	movl   $0x8024a6,(%esp)
  801602:	e8 99 00 00 00       	call   8016a0 <cprintf>
  801607:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80160a:	cc                   	int3   
  80160b:	eb fd                	jmp    80160a <_panic+0x43>

0080160d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	53                   	push   %ebx
  801611:	83 ec 04             	sub    $0x4,%esp
  801614:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801617:	8b 13                	mov    (%ebx),%edx
  801619:	8d 42 01             	lea    0x1(%edx),%eax
  80161c:	89 03                	mov    %eax,(%ebx)
  80161e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801621:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801625:	3d ff 00 00 00       	cmp    $0xff,%eax
  80162a:	75 1a                	jne    801646 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	68 ff 00 00 00       	push   $0xff
  801634:	8d 43 08             	lea    0x8(%ebx),%eax
  801637:	50                   	push   %eax
  801638:	e8 80 ea ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  80163d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801643:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801646:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80164a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    

0080164f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801658:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80165f:	00 00 00 
	b.cnt = 0;
  801662:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801669:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80166c:	ff 75 0c             	pushl  0xc(%ebp)
  80166f:	ff 75 08             	pushl  0x8(%ebp)
  801672:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	68 0d 16 80 00       	push   $0x80160d
  80167e:	e8 54 01 00 00       	call   8017d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801683:	83 c4 08             	add    $0x8,%esp
  801686:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80168c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	e8 25 ea ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  801698:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80169e:	c9                   	leave  
  80169f:	c3                   	ret    

008016a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016a9:	50                   	push   %eax
  8016aa:	ff 75 08             	pushl  0x8(%ebp)
  8016ad:	e8 9d ff ff ff       	call   80164f <vcprintf>
	va_end(ap);

	return cnt;
}
  8016b2:	c9                   	leave  
  8016b3:	c3                   	ret    

008016b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	57                   	push   %edi
  8016b8:	56                   	push   %esi
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 1c             	sub    $0x1c,%esp
  8016bd:	89 c7                	mov    %eax,%edi
  8016bf:	89 d6                	mov    %edx,%esi
  8016c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016d8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016db:	39 d3                	cmp    %edx,%ebx
  8016dd:	72 05                	jb     8016e4 <printnum+0x30>
  8016df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016e2:	77 45                	ja     801729 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016e4:	83 ec 0c             	sub    $0xc,%esp
  8016e7:	ff 75 18             	pushl  0x18(%ebp)
  8016ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ed:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016f0:	53                   	push   %ebx
  8016f1:	ff 75 10             	pushl  0x10(%ebp)
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8016fd:	ff 75 dc             	pushl  -0x24(%ebp)
  801700:	ff 75 d8             	pushl  -0x28(%ebp)
  801703:	e8 58 0a 00 00       	call   802160 <__udivdi3>
  801708:	83 c4 18             	add    $0x18,%esp
  80170b:	52                   	push   %edx
  80170c:	50                   	push   %eax
  80170d:	89 f2                	mov    %esi,%edx
  80170f:	89 f8                	mov    %edi,%eax
  801711:	e8 9e ff ff ff       	call   8016b4 <printnum>
  801716:	83 c4 20             	add    $0x20,%esp
  801719:	eb 18                	jmp    801733 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	56                   	push   %esi
  80171f:	ff 75 18             	pushl  0x18(%ebp)
  801722:	ff d7                	call   *%edi
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	eb 03                	jmp    80172c <printnum+0x78>
  801729:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80172c:	83 eb 01             	sub    $0x1,%ebx
  80172f:	85 db                	test   %ebx,%ebx
  801731:	7f e8                	jg     80171b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801733:	83 ec 08             	sub    $0x8,%esp
  801736:	56                   	push   %esi
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80173d:	ff 75 e0             	pushl  -0x20(%ebp)
  801740:	ff 75 dc             	pushl  -0x24(%ebp)
  801743:	ff 75 d8             	pushl  -0x28(%ebp)
  801746:	e8 45 0b 00 00       	call   802290 <__umoddi3>
  80174b:	83 c4 14             	add    $0x14,%esp
  80174e:	0f be 80 d3 25 80 00 	movsbl 0x8025d3(%eax),%eax
  801755:	50                   	push   %eax
  801756:	ff d7                	call   *%edi
}
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5f                   	pop    %edi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    

00801763 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801766:	83 fa 01             	cmp    $0x1,%edx
  801769:	7e 0e                	jle    801779 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80176b:	8b 10                	mov    (%eax),%edx
  80176d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801770:	89 08                	mov    %ecx,(%eax)
  801772:	8b 02                	mov    (%edx),%eax
  801774:	8b 52 04             	mov    0x4(%edx),%edx
  801777:	eb 22                	jmp    80179b <getuint+0x38>
	else if (lflag)
  801779:	85 d2                	test   %edx,%edx
  80177b:	74 10                	je     80178d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80177d:	8b 10                	mov    (%eax),%edx
  80177f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801782:	89 08                	mov    %ecx,(%eax)
  801784:	8b 02                	mov    (%edx),%eax
  801786:	ba 00 00 00 00       	mov    $0x0,%edx
  80178b:	eb 0e                	jmp    80179b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80178d:	8b 10                	mov    (%eax),%edx
  80178f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801792:	89 08                	mov    %ecx,(%eax)
  801794:	8b 02                	mov    (%edx),%eax
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80179b:	5d                   	pop    %ebp
  80179c:	c3                   	ret    

0080179d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017a7:	8b 10                	mov    (%eax),%edx
  8017a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8017ac:	73 0a                	jae    8017b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017b1:	89 08                	mov    %ecx,(%eax)
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	88 02                	mov    %al,(%edx)
}
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017c3:	50                   	push   %eax
  8017c4:	ff 75 10             	pushl  0x10(%ebp)
  8017c7:	ff 75 0c             	pushl  0xc(%ebp)
  8017ca:	ff 75 08             	pushl  0x8(%ebp)
  8017cd:	e8 05 00 00 00       	call   8017d7 <vprintfmt>
	va_end(ap);
}
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	c9                   	leave  
  8017d6:	c3                   	ret    

008017d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017d7:	55                   	push   %ebp
  8017d8:	89 e5                	mov    %esp,%ebp
  8017da:	57                   	push   %edi
  8017db:	56                   	push   %esi
  8017dc:	53                   	push   %ebx
  8017dd:	83 ec 2c             	sub    $0x2c,%esp
  8017e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8017e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017e9:	eb 12                	jmp    8017fd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	0f 84 89 03 00 00    	je     801b7c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017f3:	83 ec 08             	sub    $0x8,%esp
  8017f6:	53                   	push   %ebx
  8017f7:	50                   	push   %eax
  8017f8:	ff d6                	call   *%esi
  8017fa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017fd:	83 c7 01             	add    $0x1,%edi
  801800:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801804:	83 f8 25             	cmp    $0x25,%eax
  801807:	75 e2                	jne    8017eb <vprintfmt+0x14>
  801809:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80180d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801814:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80181b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801822:	ba 00 00 00 00       	mov    $0x0,%edx
  801827:	eb 07                	jmp    801830 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801829:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80182c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801830:	8d 47 01             	lea    0x1(%edi),%eax
  801833:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801836:	0f b6 07             	movzbl (%edi),%eax
  801839:	0f b6 c8             	movzbl %al,%ecx
  80183c:	83 e8 23             	sub    $0x23,%eax
  80183f:	3c 55                	cmp    $0x55,%al
  801841:	0f 87 1a 03 00 00    	ja     801b61 <vprintfmt+0x38a>
  801847:	0f b6 c0             	movzbl %al,%eax
  80184a:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  801851:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801854:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801858:	eb d6                	jmp    801830 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80185d:	b8 00 00 00 00       	mov    $0x0,%eax
  801862:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801865:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801868:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80186c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80186f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801872:	83 fa 09             	cmp    $0x9,%edx
  801875:	77 39                	ja     8018b0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801877:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80187a:	eb e9                	jmp    801865 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80187c:	8b 45 14             	mov    0x14(%ebp),%eax
  80187f:	8d 48 04             	lea    0x4(%eax),%ecx
  801882:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801885:	8b 00                	mov    (%eax),%eax
  801887:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80188a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80188d:	eb 27                	jmp    8018b6 <vprintfmt+0xdf>
  80188f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801892:	85 c0                	test   %eax,%eax
  801894:	b9 00 00 00 00       	mov    $0x0,%ecx
  801899:	0f 49 c8             	cmovns %eax,%ecx
  80189c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018a2:	eb 8c                	jmp    801830 <vprintfmt+0x59>
  8018a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018a7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018ae:	eb 80                	jmp    801830 <vprintfmt+0x59>
  8018b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018ba:	0f 89 70 ff ff ff    	jns    801830 <vprintfmt+0x59>
				width = precision, precision = -1;
  8018c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018cd:	e9 5e ff ff ff       	jmp    801830 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018d2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018d8:	e9 53 ff ff ff       	jmp    801830 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e0:	8d 50 04             	lea    0x4(%eax),%edx
  8018e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	53                   	push   %ebx
  8018ea:	ff 30                	pushl  (%eax)
  8018ec:	ff d6                	call   *%esi
			break;
  8018ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018f4:	e9 04 ff ff ff       	jmp    8017fd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fc:	8d 50 04             	lea    0x4(%eax),%edx
  8018ff:	89 55 14             	mov    %edx,0x14(%ebp)
  801902:	8b 00                	mov    (%eax),%eax
  801904:	99                   	cltd   
  801905:	31 d0                	xor    %edx,%eax
  801907:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801909:	83 f8 0f             	cmp    $0xf,%eax
  80190c:	7f 0b                	jg     801919 <vprintfmt+0x142>
  80190e:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  801915:	85 d2                	test   %edx,%edx
  801917:	75 18                	jne    801931 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801919:	50                   	push   %eax
  80191a:	68 eb 25 80 00       	push   $0x8025eb
  80191f:	53                   	push   %ebx
  801920:	56                   	push   %esi
  801921:	e8 94 fe ff ff       	call   8017ba <printfmt>
  801926:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80192c:	e9 cc fe ff ff       	jmp    8017fd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801931:	52                   	push   %edx
  801932:	68 69 25 80 00       	push   $0x802569
  801937:	53                   	push   %ebx
  801938:	56                   	push   %esi
  801939:	e8 7c fe ff ff       	call   8017ba <printfmt>
  80193e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801941:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801944:	e9 b4 fe ff ff       	jmp    8017fd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801949:	8b 45 14             	mov    0x14(%ebp),%eax
  80194c:	8d 50 04             	lea    0x4(%eax),%edx
  80194f:	89 55 14             	mov    %edx,0x14(%ebp)
  801952:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801954:	85 ff                	test   %edi,%edi
  801956:	b8 e4 25 80 00       	mov    $0x8025e4,%eax
  80195b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80195e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801962:	0f 8e 94 00 00 00    	jle    8019fc <vprintfmt+0x225>
  801968:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80196c:	0f 84 98 00 00 00    	je     801a0a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801972:	83 ec 08             	sub    $0x8,%esp
  801975:	ff 75 d0             	pushl  -0x30(%ebp)
  801978:	57                   	push   %edi
  801979:	e8 86 02 00 00       	call   801c04 <strnlen>
  80197e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801981:	29 c1                	sub    %eax,%ecx
  801983:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801986:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801989:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80198d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801990:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801993:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801995:	eb 0f                	jmp    8019a6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801997:	83 ec 08             	sub    $0x8,%esp
  80199a:	53                   	push   %ebx
  80199b:	ff 75 e0             	pushl  -0x20(%ebp)
  80199e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a0:	83 ef 01             	sub    $0x1,%edi
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	85 ff                	test   %edi,%edi
  8019a8:	7f ed                	jg     801997 <vprintfmt+0x1c0>
  8019aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019ad:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019b0:	85 c9                	test   %ecx,%ecx
  8019b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b7:	0f 49 c1             	cmovns %ecx,%eax
  8019ba:	29 c1                	sub    %eax,%ecx
  8019bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8019bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019c5:	89 cb                	mov    %ecx,%ebx
  8019c7:	eb 4d                	jmp    801a16 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019cd:	74 1b                	je     8019ea <vprintfmt+0x213>
  8019cf:	0f be c0             	movsbl %al,%eax
  8019d2:	83 e8 20             	sub    $0x20,%eax
  8019d5:	83 f8 5e             	cmp    $0x5e,%eax
  8019d8:	76 10                	jbe    8019ea <vprintfmt+0x213>
					putch('?', putdat);
  8019da:	83 ec 08             	sub    $0x8,%esp
  8019dd:	ff 75 0c             	pushl  0xc(%ebp)
  8019e0:	6a 3f                	push   $0x3f
  8019e2:	ff 55 08             	call   *0x8(%ebp)
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	eb 0d                	jmp    8019f7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019ea:	83 ec 08             	sub    $0x8,%esp
  8019ed:	ff 75 0c             	pushl  0xc(%ebp)
  8019f0:	52                   	push   %edx
  8019f1:	ff 55 08             	call   *0x8(%ebp)
  8019f4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019f7:	83 eb 01             	sub    $0x1,%ebx
  8019fa:	eb 1a                	jmp    801a16 <vprintfmt+0x23f>
  8019fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8019ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a02:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a05:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a08:	eb 0c                	jmp    801a16 <vprintfmt+0x23f>
  801a0a:	89 75 08             	mov    %esi,0x8(%ebp)
  801a0d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a10:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a13:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a16:	83 c7 01             	add    $0x1,%edi
  801a19:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a1d:	0f be d0             	movsbl %al,%edx
  801a20:	85 d2                	test   %edx,%edx
  801a22:	74 23                	je     801a47 <vprintfmt+0x270>
  801a24:	85 f6                	test   %esi,%esi
  801a26:	78 a1                	js     8019c9 <vprintfmt+0x1f2>
  801a28:	83 ee 01             	sub    $0x1,%esi
  801a2b:	79 9c                	jns    8019c9 <vprintfmt+0x1f2>
  801a2d:	89 df                	mov    %ebx,%edi
  801a2f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a35:	eb 18                	jmp    801a4f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a37:	83 ec 08             	sub    $0x8,%esp
  801a3a:	53                   	push   %ebx
  801a3b:	6a 20                	push   $0x20
  801a3d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a3f:	83 ef 01             	sub    $0x1,%edi
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	eb 08                	jmp    801a4f <vprintfmt+0x278>
  801a47:	89 df                	mov    %ebx,%edi
  801a49:	8b 75 08             	mov    0x8(%ebp),%esi
  801a4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a4f:	85 ff                	test   %edi,%edi
  801a51:	7f e4                	jg     801a37 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a56:	e9 a2 fd ff ff       	jmp    8017fd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a5b:	83 fa 01             	cmp    $0x1,%edx
  801a5e:	7e 16                	jle    801a76 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a60:	8b 45 14             	mov    0x14(%ebp),%eax
  801a63:	8d 50 08             	lea    0x8(%eax),%edx
  801a66:	89 55 14             	mov    %edx,0x14(%ebp)
  801a69:	8b 50 04             	mov    0x4(%eax),%edx
  801a6c:	8b 00                	mov    (%eax),%eax
  801a6e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a71:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a74:	eb 32                	jmp    801aa8 <vprintfmt+0x2d1>
	else if (lflag)
  801a76:	85 d2                	test   %edx,%edx
  801a78:	74 18                	je     801a92 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a7a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7d:	8d 50 04             	lea    0x4(%eax),%edx
  801a80:	89 55 14             	mov    %edx,0x14(%ebp)
  801a83:	8b 00                	mov    (%eax),%eax
  801a85:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a88:	89 c1                	mov    %eax,%ecx
  801a8a:	c1 f9 1f             	sar    $0x1f,%ecx
  801a8d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a90:	eb 16                	jmp    801aa8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a92:	8b 45 14             	mov    0x14(%ebp),%eax
  801a95:	8d 50 04             	lea    0x4(%eax),%edx
  801a98:	89 55 14             	mov    %edx,0x14(%ebp)
  801a9b:	8b 00                	mov    (%eax),%eax
  801a9d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aa0:	89 c1                	mov    %eax,%ecx
  801aa2:	c1 f9 1f             	sar    $0x1f,%ecx
  801aa5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801aa8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aab:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801aae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ab3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ab7:	79 74                	jns    801b2d <vprintfmt+0x356>
				putch('-', putdat);
  801ab9:	83 ec 08             	sub    $0x8,%esp
  801abc:	53                   	push   %ebx
  801abd:	6a 2d                	push   $0x2d
  801abf:	ff d6                	call   *%esi
				num = -(long long) num;
  801ac1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ac4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ac7:	f7 d8                	neg    %eax
  801ac9:	83 d2 00             	adc    $0x0,%edx
  801acc:	f7 da                	neg    %edx
  801ace:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ad1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ad6:	eb 55                	jmp    801b2d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ad8:	8d 45 14             	lea    0x14(%ebp),%eax
  801adb:	e8 83 fc ff ff       	call   801763 <getuint>
			base = 10;
  801ae0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ae5:	eb 46                	jmp    801b2d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ae7:	8d 45 14             	lea    0x14(%ebp),%eax
  801aea:	e8 74 fc ff ff       	call   801763 <getuint>
			base = 8;
  801aef:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801af4:	eb 37                	jmp    801b2d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801af6:	83 ec 08             	sub    $0x8,%esp
  801af9:	53                   	push   %ebx
  801afa:	6a 30                	push   $0x30
  801afc:	ff d6                	call   *%esi
			putch('x', putdat);
  801afe:	83 c4 08             	add    $0x8,%esp
  801b01:	53                   	push   %ebx
  801b02:	6a 78                	push   $0x78
  801b04:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b06:	8b 45 14             	mov    0x14(%ebp),%eax
  801b09:	8d 50 04             	lea    0x4(%eax),%edx
  801b0c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b0f:	8b 00                	mov    (%eax),%eax
  801b11:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b16:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b19:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b1e:	eb 0d                	jmp    801b2d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b20:	8d 45 14             	lea    0x14(%ebp),%eax
  801b23:	e8 3b fc ff ff       	call   801763 <getuint>
			base = 16;
  801b28:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b34:	57                   	push   %edi
  801b35:	ff 75 e0             	pushl  -0x20(%ebp)
  801b38:	51                   	push   %ecx
  801b39:	52                   	push   %edx
  801b3a:	50                   	push   %eax
  801b3b:	89 da                	mov    %ebx,%edx
  801b3d:	89 f0                	mov    %esi,%eax
  801b3f:	e8 70 fb ff ff       	call   8016b4 <printnum>
			break;
  801b44:	83 c4 20             	add    $0x20,%esp
  801b47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b4a:	e9 ae fc ff ff       	jmp    8017fd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b4f:	83 ec 08             	sub    $0x8,%esp
  801b52:	53                   	push   %ebx
  801b53:	51                   	push   %ecx
  801b54:	ff d6                	call   *%esi
			break;
  801b56:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b5c:	e9 9c fc ff ff       	jmp    8017fd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b61:	83 ec 08             	sub    $0x8,%esp
  801b64:	53                   	push   %ebx
  801b65:	6a 25                	push   $0x25
  801b67:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	eb 03                	jmp    801b71 <vprintfmt+0x39a>
  801b6e:	83 ef 01             	sub    $0x1,%edi
  801b71:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b75:	75 f7                	jne    801b6e <vprintfmt+0x397>
  801b77:	e9 81 fc ff ff       	jmp    8017fd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7f:	5b                   	pop    %ebx
  801b80:	5e                   	pop    %esi
  801b81:	5f                   	pop    %edi
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	83 ec 18             	sub    $0x18,%esp
  801b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b90:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b93:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b97:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	74 26                	je     801bcb <vsnprintf+0x47>
  801ba5:	85 d2                	test   %edx,%edx
  801ba7:	7e 22                	jle    801bcb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ba9:	ff 75 14             	pushl  0x14(%ebp)
  801bac:	ff 75 10             	pushl  0x10(%ebp)
  801baf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bb2:	50                   	push   %eax
  801bb3:	68 9d 17 80 00       	push   $0x80179d
  801bb8:	e8 1a fc ff ff       	call   8017d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bc0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc6:	83 c4 10             	add    $0x10,%esp
  801bc9:	eb 05                	jmp    801bd0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bcb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bd8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bdb:	50                   	push   %eax
  801bdc:	ff 75 10             	pushl  0x10(%ebp)
  801bdf:	ff 75 0c             	pushl  0xc(%ebp)
  801be2:	ff 75 08             	pushl  0x8(%ebp)
  801be5:	e8 9a ff ff ff       	call   801b84 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bea:	c9                   	leave  
  801beb:	c3                   	ret    

00801bec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bf2:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf7:	eb 03                	jmp    801bfc <strlen+0x10>
		n++;
  801bf9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bfc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c00:	75 f7                	jne    801bf9 <strlen+0xd>
		n++;
	return n;
}
  801c02:	5d                   	pop    %ebp
  801c03:	c3                   	ret    

00801c04 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c12:	eb 03                	jmp    801c17 <strnlen+0x13>
		n++;
  801c14:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c17:	39 c2                	cmp    %eax,%edx
  801c19:	74 08                	je     801c23 <strnlen+0x1f>
  801c1b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c1f:	75 f3                	jne    801c14 <strnlen+0x10>
  801c21:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    

00801c25 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	53                   	push   %ebx
  801c29:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c2f:	89 c2                	mov    %eax,%edx
  801c31:	83 c2 01             	add    $0x1,%edx
  801c34:	83 c1 01             	add    $0x1,%ecx
  801c37:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c3b:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c3e:	84 db                	test   %bl,%bl
  801c40:	75 ef                	jne    801c31 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c42:	5b                   	pop    %ebx
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	53                   	push   %ebx
  801c49:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c4c:	53                   	push   %ebx
  801c4d:	e8 9a ff ff ff       	call   801bec <strlen>
  801c52:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c55:	ff 75 0c             	pushl  0xc(%ebp)
  801c58:	01 d8                	add    %ebx,%eax
  801c5a:	50                   	push   %eax
  801c5b:	e8 c5 ff ff ff       	call   801c25 <strcpy>
	return dst;
}
  801c60:	89 d8                	mov    %ebx,%eax
  801c62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	56                   	push   %esi
  801c6b:	53                   	push   %ebx
  801c6c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c72:	89 f3                	mov    %esi,%ebx
  801c74:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c77:	89 f2                	mov    %esi,%edx
  801c79:	eb 0f                	jmp    801c8a <strncpy+0x23>
		*dst++ = *src;
  801c7b:	83 c2 01             	add    $0x1,%edx
  801c7e:	0f b6 01             	movzbl (%ecx),%eax
  801c81:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c84:	80 39 01             	cmpb   $0x1,(%ecx)
  801c87:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c8a:	39 da                	cmp    %ebx,%edx
  801c8c:	75 ed                	jne    801c7b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c8e:	89 f0                	mov    %esi,%eax
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    

00801c94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	56                   	push   %esi
  801c98:	53                   	push   %ebx
  801c99:	8b 75 08             	mov    0x8(%ebp),%esi
  801c9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9f:	8b 55 10             	mov    0x10(%ebp),%edx
  801ca2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ca4:	85 d2                	test   %edx,%edx
  801ca6:	74 21                	je     801cc9 <strlcpy+0x35>
  801ca8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cac:	89 f2                	mov    %esi,%edx
  801cae:	eb 09                	jmp    801cb9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cb0:	83 c2 01             	add    $0x1,%edx
  801cb3:	83 c1 01             	add    $0x1,%ecx
  801cb6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cb9:	39 c2                	cmp    %eax,%edx
  801cbb:	74 09                	je     801cc6 <strlcpy+0x32>
  801cbd:	0f b6 19             	movzbl (%ecx),%ebx
  801cc0:	84 db                	test   %bl,%bl
  801cc2:	75 ec                	jne    801cb0 <strlcpy+0x1c>
  801cc4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cc6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cc9:	29 f0                	sub    %esi,%eax
}
  801ccb:	5b                   	pop    %ebx
  801ccc:	5e                   	pop    %esi
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cd8:	eb 06                	jmp    801ce0 <strcmp+0x11>
		p++, q++;
  801cda:	83 c1 01             	add    $0x1,%ecx
  801cdd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ce0:	0f b6 01             	movzbl (%ecx),%eax
  801ce3:	84 c0                	test   %al,%al
  801ce5:	74 04                	je     801ceb <strcmp+0x1c>
  801ce7:	3a 02                	cmp    (%edx),%al
  801ce9:	74 ef                	je     801cda <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ceb:	0f b6 c0             	movzbl %al,%eax
  801cee:	0f b6 12             	movzbl (%edx),%edx
  801cf1:	29 d0                	sub    %edx,%eax
}
  801cf3:	5d                   	pop    %ebp
  801cf4:	c3                   	ret    

00801cf5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cf5:	55                   	push   %ebp
  801cf6:	89 e5                	mov    %esp,%ebp
  801cf8:	53                   	push   %ebx
  801cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cff:	89 c3                	mov    %eax,%ebx
  801d01:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d04:	eb 06                	jmp    801d0c <strncmp+0x17>
		n--, p++, q++;
  801d06:	83 c0 01             	add    $0x1,%eax
  801d09:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d0c:	39 d8                	cmp    %ebx,%eax
  801d0e:	74 15                	je     801d25 <strncmp+0x30>
  801d10:	0f b6 08             	movzbl (%eax),%ecx
  801d13:	84 c9                	test   %cl,%cl
  801d15:	74 04                	je     801d1b <strncmp+0x26>
  801d17:	3a 0a                	cmp    (%edx),%cl
  801d19:	74 eb                	je     801d06 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d1b:	0f b6 00             	movzbl (%eax),%eax
  801d1e:	0f b6 12             	movzbl (%edx),%edx
  801d21:	29 d0                	sub    %edx,%eax
  801d23:	eb 05                	jmp    801d2a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d2a:	5b                   	pop    %ebx
  801d2b:	5d                   	pop    %ebp
  801d2c:	c3                   	ret    

00801d2d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	8b 45 08             	mov    0x8(%ebp),%eax
  801d33:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d37:	eb 07                	jmp    801d40 <strchr+0x13>
		if (*s == c)
  801d39:	38 ca                	cmp    %cl,%dl
  801d3b:	74 0f                	je     801d4c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d3d:	83 c0 01             	add    $0x1,%eax
  801d40:	0f b6 10             	movzbl (%eax),%edx
  801d43:	84 d2                	test   %dl,%dl
  801d45:	75 f2                	jne    801d39 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	8b 45 08             	mov    0x8(%ebp),%eax
  801d54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d58:	eb 03                	jmp    801d5d <strfind+0xf>
  801d5a:	83 c0 01             	add    $0x1,%eax
  801d5d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d60:	38 ca                	cmp    %cl,%dl
  801d62:	74 04                	je     801d68 <strfind+0x1a>
  801d64:	84 d2                	test   %dl,%dl
  801d66:	75 f2                	jne    801d5a <strfind+0xc>
			break;
	return (char *) s;
}
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	57                   	push   %edi
  801d6e:	56                   	push   %esi
  801d6f:	53                   	push   %ebx
  801d70:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d76:	85 c9                	test   %ecx,%ecx
  801d78:	74 36                	je     801db0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d7a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d80:	75 28                	jne    801daa <memset+0x40>
  801d82:	f6 c1 03             	test   $0x3,%cl
  801d85:	75 23                	jne    801daa <memset+0x40>
		c &= 0xFF;
  801d87:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d8b:	89 d3                	mov    %edx,%ebx
  801d8d:	c1 e3 08             	shl    $0x8,%ebx
  801d90:	89 d6                	mov    %edx,%esi
  801d92:	c1 e6 18             	shl    $0x18,%esi
  801d95:	89 d0                	mov    %edx,%eax
  801d97:	c1 e0 10             	shl    $0x10,%eax
  801d9a:	09 f0                	or     %esi,%eax
  801d9c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d9e:	89 d8                	mov    %ebx,%eax
  801da0:	09 d0                	or     %edx,%eax
  801da2:	c1 e9 02             	shr    $0x2,%ecx
  801da5:	fc                   	cld    
  801da6:	f3 ab                	rep stos %eax,%es:(%edi)
  801da8:	eb 06                	jmp    801db0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801daa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dad:	fc                   	cld    
  801dae:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801db0:	89 f8                	mov    %edi,%eax
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	57                   	push   %edi
  801dbb:	56                   	push   %esi
  801dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dc2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dc5:	39 c6                	cmp    %eax,%esi
  801dc7:	73 35                	jae    801dfe <memmove+0x47>
  801dc9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dcc:	39 d0                	cmp    %edx,%eax
  801dce:	73 2e                	jae    801dfe <memmove+0x47>
		s += n;
		d += n;
  801dd0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dd3:	89 d6                	mov    %edx,%esi
  801dd5:	09 fe                	or     %edi,%esi
  801dd7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801ddd:	75 13                	jne    801df2 <memmove+0x3b>
  801ddf:	f6 c1 03             	test   $0x3,%cl
  801de2:	75 0e                	jne    801df2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801de4:	83 ef 04             	sub    $0x4,%edi
  801de7:	8d 72 fc             	lea    -0x4(%edx),%esi
  801dea:	c1 e9 02             	shr    $0x2,%ecx
  801ded:	fd                   	std    
  801dee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801df0:	eb 09                	jmp    801dfb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801df2:	83 ef 01             	sub    $0x1,%edi
  801df5:	8d 72 ff             	lea    -0x1(%edx),%esi
  801df8:	fd                   	std    
  801df9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801dfb:	fc                   	cld    
  801dfc:	eb 1d                	jmp    801e1b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dfe:	89 f2                	mov    %esi,%edx
  801e00:	09 c2                	or     %eax,%edx
  801e02:	f6 c2 03             	test   $0x3,%dl
  801e05:	75 0f                	jne    801e16 <memmove+0x5f>
  801e07:	f6 c1 03             	test   $0x3,%cl
  801e0a:	75 0a                	jne    801e16 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e0c:	c1 e9 02             	shr    $0x2,%ecx
  801e0f:	89 c7                	mov    %eax,%edi
  801e11:	fc                   	cld    
  801e12:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e14:	eb 05                	jmp    801e1b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e16:	89 c7                	mov    %eax,%edi
  801e18:	fc                   	cld    
  801e19:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e1b:	5e                   	pop    %esi
  801e1c:	5f                   	pop    %edi
  801e1d:	5d                   	pop    %ebp
  801e1e:	c3                   	ret    

00801e1f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e22:	ff 75 10             	pushl  0x10(%ebp)
  801e25:	ff 75 0c             	pushl  0xc(%ebp)
  801e28:	ff 75 08             	pushl  0x8(%ebp)
  801e2b:	e8 87 ff ff ff       	call   801db7 <memmove>
}
  801e30:	c9                   	leave  
  801e31:	c3                   	ret    

00801e32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	56                   	push   %esi
  801e36:	53                   	push   %ebx
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e3d:	89 c6                	mov    %eax,%esi
  801e3f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e42:	eb 1a                	jmp    801e5e <memcmp+0x2c>
		if (*s1 != *s2)
  801e44:	0f b6 08             	movzbl (%eax),%ecx
  801e47:	0f b6 1a             	movzbl (%edx),%ebx
  801e4a:	38 d9                	cmp    %bl,%cl
  801e4c:	74 0a                	je     801e58 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e4e:	0f b6 c1             	movzbl %cl,%eax
  801e51:	0f b6 db             	movzbl %bl,%ebx
  801e54:	29 d8                	sub    %ebx,%eax
  801e56:	eb 0f                	jmp    801e67 <memcmp+0x35>
		s1++, s2++;
  801e58:	83 c0 01             	add    $0x1,%eax
  801e5b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e5e:	39 f0                	cmp    %esi,%eax
  801e60:	75 e2                	jne    801e44 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    

00801e6b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	53                   	push   %ebx
  801e6f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e72:	89 c1                	mov    %eax,%ecx
  801e74:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e77:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e7b:	eb 0a                	jmp    801e87 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e7d:	0f b6 10             	movzbl (%eax),%edx
  801e80:	39 da                	cmp    %ebx,%edx
  801e82:	74 07                	je     801e8b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e84:	83 c0 01             	add    $0x1,%eax
  801e87:	39 c8                	cmp    %ecx,%eax
  801e89:	72 f2                	jb     801e7d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e8b:	5b                   	pop    %ebx
  801e8c:	5d                   	pop    %ebp
  801e8d:	c3                   	ret    

00801e8e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	57                   	push   %edi
  801e92:	56                   	push   %esi
  801e93:	53                   	push   %ebx
  801e94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e9a:	eb 03                	jmp    801e9f <strtol+0x11>
		s++;
  801e9c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e9f:	0f b6 01             	movzbl (%ecx),%eax
  801ea2:	3c 20                	cmp    $0x20,%al
  801ea4:	74 f6                	je     801e9c <strtol+0xe>
  801ea6:	3c 09                	cmp    $0x9,%al
  801ea8:	74 f2                	je     801e9c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801eaa:	3c 2b                	cmp    $0x2b,%al
  801eac:	75 0a                	jne    801eb8 <strtol+0x2a>
		s++;
  801eae:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801eb1:	bf 00 00 00 00       	mov    $0x0,%edi
  801eb6:	eb 11                	jmp    801ec9 <strtol+0x3b>
  801eb8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ebd:	3c 2d                	cmp    $0x2d,%al
  801ebf:	75 08                	jne    801ec9 <strtol+0x3b>
		s++, neg = 1;
  801ec1:	83 c1 01             	add    $0x1,%ecx
  801ec4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ec9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ecf:	75 15                	jne    801ee6 <strtol+0x58>
  801ed1:	80 39 30             	cmpb   $0x30,(%ecx)
  801ed4:	75 10                	jne    801ee6 <strtol+0x58>
  801ed6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801eda:	75 7c                	jne    801f58 <strtol+0xca>
		s += 2, base = 16;
  801edc:	83 c1 02             	add    $0x2,%ecx
  801edf:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ee4:	eb 16                	jmp    801efc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ee6:	85 db                	test   %ebx,%ebx
  801ee8:	75 12                	jne    801efc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801eea:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eef:	80 39 30             	cmpb   $0x30,(%ecx)
  801ef2:	75 08                	jne    801efc <strtol+0x6e>
		s++, base = 8;
  801ef4:	83 c1 01             	add    $0x1,%ecx
  801ef7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801efc:	b8 00 00 00 00       	mov    $0x0,%eax
  801f01:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f04:	0f b6 11             	movzbl (%ecx),%edx
  801f07:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f0a:	89 f3                	mov    %esi,%ebx
  801f0c:	80 fb 09             	cmp    $0x9,%bl
  801f0f:	77 08                	ja     801f19 <strtol+0x8b>
			dig = *s - '0';
  801f11:	0f be d2             	movsbl %dl,%edx
  801f14:	83 ea 30             	sub    $0x30,%edx
  801f17:	eb 22                	jmp    801f3b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f19:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f1c:	89 f3                	mov    %esi,%ebx
  801f1e:	80 fb 19             	cmp    $0x19,%bl
  801f21:	77 08                	ja     801f2b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f23:	0f be d2             	movsbl %dl,%edx
  801f26:	83 ea 57             	sub    $0x57,%edx
  801f29:	eb 10                	jmp    801f3b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f2b:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f2e:	89 f3                	mov    %esi,%ebx
  801f30:	80 fb 19             	cmp    $0x19,%bl
  801f33:	77 16                	ja     801f4b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f35:	0f be d2             	movsbl %dl,%edx
  801f38:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f3b:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f3e:	7d 0b                	jge    801f4b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f40:	83 c1 01             	add    $0x1,%ecx
  801f43:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f47:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f49:	eb b9                	jmp    801f04 <strtol+0x76>

	if (endptr)
  801f4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f4f:	74 0d                	je     801f5e <strtol+0xd0>
		*endptr = (char *) s;
  801f51:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f54:	89 0e                	mov    %ecx,(%esi)
  801f56:	eb 06                	jmp    801f5e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f58:	85 db                	test   %ebx,%ebx
  801f5a:	74 98                	je     801ef4 <strtol+0x66>
  801f5c:	eb 9e                	jmp    801efc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f5e:	89 c2                	mov    %eax,%edx
  801f60:	f7 da                	neg    %edx
  801f62:	85 ff                	test   %edi,%edi
  801f64:	0f 45 c2             	cmovne %edx,%eax
}
  801f67:	5b                   	pop    %ebx
  801f68:	5e                   	pop    %esi
  801f69:	5f                   	pop    %edi
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    

00801f6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f72:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f79:	75 2a                	jne    801fa5 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f7b:	83 ec 04             	sub    $0x4,%esp
  801f7e:	6a 07                	push   $0x7
  801f80:	68 00 f0 bf ee       	push   $0xeebff000
  801f85:	6a 00                	push   $0x0
  801f87:	e8 ed e1 ff ff       	call   800179 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f8c:	83 c4 10             	add    $0x10,%esp
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	79 12                	jns    801fa5 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f93:	50                   	push   %eax
  801f94:	68 bd 24 80 00       	push   $0x8024bd
  801f99:	6a 23                	push   $0x23
  801f9b:	68 e0 28 80 00       	push   $0x8028e0
  801fa0:	e8 22 f6 ff ff       	call   8015c7 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa8:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fad:	83 ec 08             	sub    $0x8,%esp
  801fb0:	68 d7 1f 80 00       	push   $0x801fd7
  801fb5:	6a 00                	push   $0x0
  801fb7:	e8 08 e3 ff ff       	call   8002c4 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fbc:	83 c4 10             	add    $0x10,%esp
  801fbf:	85 c0                	test   %eax,%eax
  801fc1:	79 12                	jns    801fd5 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fc3:	50                   	push   %eax
  801fc4:	68 bd 24 80 00       	push   $0x8024bd
  801fc9:	6a 2c                	push   $0x2c
  801fcb:	68 e0 28 80 00       	push   $0x8028e0
  801fd0:	e8 f2 f5 ff ff       	call   8015c7 <_panic>
	}
}
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fd7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fd8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fdd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fdf:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fe2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fe6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801feb:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801fef:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ff1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ff4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ff5:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ff8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ff9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ffa:	c3                   	ret    

00801ffb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	56                   	push   %esi
  801fff:	53                   	push   %ebx
  802000:	8b 75 08             	mov    0x8(%ebp),%esi
  802003:	8b 45 0c             	mov    0xc(%ebp),%eax
  802006:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802009:	85 c0                	test   %eax,%eax
  80200b:	75 12                	jne    80201f <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80200d:	83 ec 0c             	sub    $0xc,%esp
  802010:	68 00 00 c0 ee       	push   $0xeec00000
  802015:	e8 0f e3 ff ff       	call   800329 <sys_ipc_recv>
  80201a:	83 c4 10             	add    $0x10,%esp
  80201d:	eb 0c                	jmp    80202b <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80201f:	83 ec 0c             	sub    $0xc,%esp
  802022:	50                   	push   %eax
  802023:	e8 01 e3 ff ff       	call   800329 <sys_ipc_recv>
  802028:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80202b:	85 f6                	test   %esi,%esi
  80202d:	0f 95 c1             	setne  %cl
  802030:	85 db                	test   %ebx,%ebx
  802032:	0f 95 c2             	setne  %dl
  802035:	84 d1                	test   %dl,%cl
  802037:	74 09                	je     802042 <ipc_recv+0x47>
  802039:	89 c2                	mov    %eax,%edx
  80203b:	c1 ea 1f             	shr    $0x1f,%edx
  80203e:	84 d2                	test   %dl,%dl
  802040:	75 2d                	jne    80206f <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802042:	85 f6                	test   %esi,%esi
  802044:	74 0d                	je     802053 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802046:	a1 04 40 80 00       	mov    0x804004,%eax
  80204b:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802051:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802053:	85 db                	test   %ebx,%ebx
  802055:	74 0d                	je     802064 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802057:	a1 04 40 80 00       	mov    0x804004,%eax
  80205c:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802062:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802064:	a1 04 40 80 00       	mov    0x804004,%eax
  802069:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80206f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802072:	5b                   	pop    %ebx
  802073:	5e                   	pop    %esi
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    

00802076 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	57                   	push   %edi
  80207a:	56                   	push   %esi
  80207b:	53                   	push   %ebx
  80207c:	83 ec 0c             	sub    $0xc,%esp
  80207f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802082:	8b 75 0c             	mov    0xc(%ebp),%esi
  802085:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802088:	85 db                	test   %ebx,%ebx
  80208a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80208f:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802092:	ff 75 14             	pushl  0x14(%ebp)
  802095:	53                   	push   %ebx
  802096:	56                   	push   %esi
  802097:	57                   	push   %edi
  802098:	e8 69 e2 ff ff       	call   800306 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80209d:	89 c2                	mov    %eax,%edx
  80209f:	c1 ea 1f             	shr    $0x1f,%edx
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	84 d2                	test   %dl,%dl
  8020a7:	74 17                	je     8020c0 <ipc_send+0x4a>
  8020a9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ac:	74 12                	je     8020c0 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020ae:	50                   	push   %eax
  8020af:	68 ee 28 80 00       	push   $0x8028ee
  8020b4:	6a 47                	push   $0x47
  8020b6:	68 fc 28 80 00       	push   $0x8028fc
  8020bb:	e8 07 f5 ff ff       	call   8015c7 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020c0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c3:	75 07                	jne    8020cc <ipc_send+0x56>
			sys_yield();
  8020c5:	e8 90 e0 ff ff       	call   80015a <sys_yield>
  8020ca:	eb c6                	jmp    802092 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020cc:	85 c0                	test   %eax,%eax
  8020ce:	75 c2                	jne    802092 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    

008020d8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020de:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020e3:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020e9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ef:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8020f5:	39 ca                	cmp    %ecx,%edx
  8020f7:	75 13                	jne    80210c <ipc_find_env+0x34>
			return envs[i].env_id;
  8020f9:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8020ff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802104:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  80210a:	eb 0f                	jmp    80211b <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80210c:	83 c0 01             	add    $0x1,%eax
  80210f:	3d 00 04 00 00       	cmp    $0x400,%eax
  802114:	75 cd                	jne    8020e3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802116:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80211b:	5d                   	pop    %ebp
  80211c:	c3                   	ret    

0080211d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80211d:	55                   	push   %ebp
  80211e:	89 e5                	mov    %esp,%ebp
  802120:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802123:	89 d0                	mov    %edx,%eax
  802125:	c1 e8 16             	shr    $0x16,%eax
  802128:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80212f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802134:	f6 c1 01             	test   $0x1,%cl
  802137:	74 1d                	je     802156 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802139:	c1 ea 0c             	shr    $0xc,%edx
  80213c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802143:	f6 c2 01             	test   $0x1,%dl
  802146:	74 0e                	je     802156 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802148:	c1 ea 0c             	shr    $0xc,%edx
  80214b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802152:	ef 
  802153:	0f b7 c0             	movzwl %ax,%eax
}
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
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
