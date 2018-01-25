
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 f2 00 00 00       	call   800140 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	89 c2                	mov    %eax,%edx
  800055:	c1 e2 07             	shl    $0x7,%edx
  800058:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x31>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 2a 00 00 00       	call   8000a8 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80008e:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  800093:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800095:	e8 a6 00 00 00       	call   800140 <sys_getenvid>
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	50                   	push   %eax
  80009e:	e8 ec 02 00 00       	call   80038f <sys_thread_free>
}
  8000a3:	83 c4 10             	add    $0x10,%esp
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ae:	e8 b9 07 00 00       	call   80086c <close_all>
	sys_env_destroy(0);
  8000b3:	83 ec 0c             	sub    $0xc,%esp
  8000b6:	6a 00                	push   $0x0
  8000b8:	e8 42 00 00 00       	call   8000ff <sys_env_destroy>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	c9                   	leave  
  8000c1:	c3                   	ret    

008000c2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	89 c3                	mov    %eax,%ebx
  8000d5:	89 c7                	mov    %eax,%edi
  8000d7:	89 c6                	mov    %eax,%esi
  8000d9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000db:	5b                   	pop    %ebx
  8000dc:	5e                   	pop    %esi
  8000dd:	5f                   	pop    %edi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	57                   	push   %edi
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f0:	89 d1                	mov    %edx,%ecx
  8000f2:	89 d3                	mov    %edx,%ebx
  8000f4:	89 d7                	mov    %edx,%edi
  8000f6:	89 d6                	mov    %edx,%esi
  8000f8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    

008000ff <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	57                   	push   %edi
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800108:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010d:	b8 03 00 00 00       	mov    $0x3,%eax
  800112:	8b 55 08             	mov    0x8(%ebp),%edx
  800115:	89 cb                	mov    %ecx,%ebx
  800117:	89 cf                	mov    %ecx,%edi
  800119:	89 ce                	mov    %ecx,%esi
  80011b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011d:	85 c0                	test   %eax,%eax
  80011f:	7e 17                	jle    800138 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800121:	83 ec 0c             	sub    $0xc,%esp
  800124:	50                   	push   %eax
  800125:	6a 03                	push   $0x3
  800127:	68 ca 21 80 00       	push   $0x8021ca
  80012c:	6a 23                	push   $0x23
  80012e:	68 e7 21 80 00       	push   $0x8021e7
  800133:	e8 53 12 00 00       	call   80138b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013b:	5b                   	pop    %ebx
  80013c:	5e                   	pop    %esi
  80013d:	5f                   	pop    %edi
  80013e:	5d                   	pop    %ebp
  80013f:	c3                   	ret    

00800140 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	57                   	push   %edi
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800146:	ba 00 00 00 00       	mov    $0x0,%edx
  80014b:	b8 02 00 00 00       	mov    $0x2,%eax
  800150:	89 d1                	mov    %edx,%ecx
  800152:	89 d3                	mov    %edx,%ebx
  800154:	89 d7                	mov    %edx,%edi
  800156:	89 d6                	mov    %edx,%esi
  800158:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015a:	5b                   	pop    %ebx
  80015b:	5e                   	pop    %esi
  80015c:	5f                   	pop    %edi
  80015d:	5d                   	pop    %ebp
  80015e:	c3                   	ret    

0080015f <sys_yield>:

void
sys_yield(void)
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
  80016a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016f:	89 d1                	mov    %edx,%ecx
  800171:	89 d3                	mov    %edx,%ebx
  800173:	89 d7                	mov    %edx,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	57                   	push   %edi
  800182:	56                   	push   %esi
  800183:	53                   	push   %ebx
  800184:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800187:	be 00 00 00 00       	mov    $0x0,%esi
  80018c:	b8 04 00 00 00       	mov    $0x4,%eax
  800191:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800194:	8b 55 08             	mov    0x8(%ebp),%edx
  800197:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019a:	89 f7                	mov    %esi,%edi
  80019c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	7e 17                	jle    8001b9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	50                   	push   %eax
  8001a6:	6a 04                	push   $0x4
  8001a8:	68 ca 21 80 00       	push   $0x8021ca
  8001ad:	6a 23                	push   $0x23
  8001af:	68 e7 21 80 00       	push   $0x8021e7
  8001b4:	e8 d2 11 00 00       	call   80138b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bc:	5b                   	pop    %ebx
  8001bd:	5e                   	pop    %esi
  8001be:	5f                   	pop    %edi
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    

008001c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	57                   	push   %edi
  8001c5:	56                   	push   %esi
  8001c6:	53                   	push   %ebx
  8001c7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001db:	8b 75 18             	mov    0x18(%ebp),%esi
  8001de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e0:	85 c0                	test   %eax,%eax
  8001e2:	7e 17                	jle    8001fb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	50                   	push   %eax
  8001e8:	6a 05                	push   $0x5
  8001ea:	68 ca 21 80 00       	push   $0x8021ca
  8001ef:	6a 23                	push   $0x23
  8001f1:	68 e7 21 80 00       	push   $0x8021e7
  8001f6:	e8 90 11 00 00       	call   80138b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fe:	5b                   	pop    %ebx
  8001ff:	5e                   	pop    %esi
  800200:	5f                   	pop    %edi
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	57                   	push   %edi
  800207:	56                   	push   %esi
  800208:	53                   	push   %ebx
  800209:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800211:	b8 06 00 00 00       	mov    $0x6,%eax
  800216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800219:	8b 55 08             	mov    0x8(%ebp),%edx
  80021c:	89 df                	mov    %ebx,%edi
  80021e:	89 de                	mov    %ebx,%esi
  800220:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800222:	85 c0                	test   %eax,%eax
  800224:	7e 17                	jle    80023d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800226:	83 ec 0c             	sub    $0xc,%esp
  800229:	50                   	push   %eax
  80022a:	6a 06                	push   $0x6
  80022c:	68 ca 21 80 00       	push   $0x8021ca
  800231:	6a 23                	push   $0x23
  800233:	68 e7 21 80 00       	push   $0x8021e7
  800238:	e8 4e 11 00 00       	call   80138b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80023d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800240:	5b                   	pop    %ebx
  800241:	5e                   	pop    %esi
  800242:	5f                   	pop    %edi
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    

00800245 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800253:	b8 08 00 00 00       	mov    $0x8,%eax
  800258:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025b:	8b 55 08             	mov    0x8(%ebp),%edx
  80025e:	89 df                	mov    %ebx,%edi
  800260:	89 de                	mov    %ebx,%esi
  800262:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800264:	85 c0                	test   %eax,%eax
  800266:	7e 17                	jle    80027f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800268:	83 ec 0c             	sub    $0xc,%esp
  80026b:	50                   	push   %eax
  80026c:	6a 08                	push   $0x8
  80026e:	68 ca 21 80 00       	push   $0x8021ca
  800273:	6a 23                	push   $0x23
  800275:	68 e7 21 80 00       	push   $0x8021e7
  80027a:	e8 0c 11 00 00       	call   80138b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800282:	5b                   	pop    %ebx
  800283:	5e                   	pop    %esi
  800284:	5f                   	pop    %edi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	57                   	push   %edi
  80028b:	56                   	push   %esi
  80028c:	53                   	push   %ebx
  80028d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800290:	bb 00 00 00 00       	mov    $0x0,%ebx
  800295:	b8 09 00 00 00       	mov    $0x9,%eax
  80029a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029d:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a0:	89 df                	mov    %ebx,%edi
  8002a2:	89 de                	mov    %ebx,%esi
  8002a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	7e 17                	jle    8002c1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002aa:	83 ec 0c             	sub    $0xc,%esp
  8002ad:	50                   	push   %eax
  8002ae:	6a 09                	push   $0x9
  8002b0:	68 ca 21 80 00       	push   $0x8021ca
  8002b5:	6a 23                	push   $0x23
  8002b7:	68 e7 21 80 00       	push   $0x8021e7
  8002bc:	e8 ca 10 00 00       	call   80138b <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002df:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e2:	89 df                	mov    %ebx,%edi
  8002e4:	89 de                	mov    %ebx,%esi
  8002e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	7e 17                	jle    800303 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ec:	83 ec 0c             	sub    $0xc,%esp
  8002ef:	50                   	push   %eax
  8002f0:	6a 0a                	push   $0xa
  8002f2:	68 ca 21 80 00       	push   $0x8021ca
  8002f7:	6a 23                	push   $0x23
  8002f9:	68 e7 21 80 00       	push   $0x8021e7
  8002fe:	e8 88 10 00 00       	call   80138b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800303:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800306:	5b                   	pop    %ebx
  800307:	5e                   	pop    %esi
  800308:	5f                   	pop    %edi
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800311:	be 00 00 00 00       	mov    $0x0,%esi
  800316:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031e:	8b 55 08             	mov    0x8(%ebp),%edx
  800321:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800324:	8b 7d 14             	mov    0x14(%ebp),%edi
  800327:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800329:	5b                   	pop    %ebx
  80032a:	5e                   	pop    %esi
  80032b:	5f                   	pop    %edi
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800337:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800341:	8b 55 08             	mov    0x8(%ebp),%edx
  800344:	89 cb                	mov    %ecx,%ebx
  800346:	89 cf                	mov    %ecx,%edi
  800348:	89 ce                	mov    %ecx,%esi
  80034a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	7e 17                	jle    800367 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	50                   	push   %eax
  800354:	6a 0d                	push   $0xd
  800356:	68 ca 21 80 00       	push   $0x8021ca
  80035b:	6a 23                	push   $0x23
  80035d:	68 e7 21 80 00       	push   $0x8021e7
  800362:	e8 24 10 00 00       	call   80138b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800367:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036a:	5b                   	pop    %ebx
  80036b:	5e                   	pop    %esi
  80036c:	5f                   	pop    %edi
  80036d:	5d                   	pop    %ebp
  80036e:	c3                   	ret    

0080036f <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	57                   	push   %edi
  800373:	56                   	push   %esi
  800374:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800375:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80037f:	8b 55 08             	mov    0x8(%ebp),%edx
  800382:	89 cb                	mov    %ecx,%ebx
  800384:	89 cf                	mov    %ecx,%edi
  800386:	89 ce                	mov    %ecx,%esi
  800388:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	57                   	push   %edi
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800395:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80039f:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a2:	89 cb                	mov    %ecx,%ebx
  8003a4:	89 cf                	mov    %ecx,%edi
  8003a6:	89 ce                	mov    %ecx,%esi
  8003a8:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	53                   	push   %ebx
  8003b3:	83 ec 04             	sub    $0x4,%esp
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003b9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003bb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003bf:	74 11                	je     8003d2 <pgfault+0x23>
  8003c1:	89 d8                	mov    %ebx,%eax
  8003c3:	c1 e8 0c             	shr    $0xc,%eax
  8003c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003cd:	f6 c4 08             	test   $0x8,%ah
  8003d0:	75 14                	jne    8003e6 <pgfault+0x37>
		panic("faulting access");
  8003d2:	83 ec 04             	sub    $0x4,%esp
  8003d5:	68 f5 21 80 00       	push   $0x8021f5
  8003da:	6a 1e                	push   $0x1e
  8003dc:	68 05 22 80 00       	push   $0x802205
  8003e1:	e8 a5 0f 00 00       	call   80138b <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003e6:	83 ec 04             	sub    $0x4,%esp
  8003e9:	6a 07                	push   $0x7
  8003eb:	68 00 f0 7f 00       	push   $0x7ff000
  8003f0:	6a 00                	push   $0x0
  8003f2:	e8 87 fd ff ff       	call   80017e <sys_page_alloc>
	if (r < 0) {
  8003f7:	83 c4 10             	add    $0x10,%esp
  8003fa:	85 c0                	test   %eax,%eax
  8003fc:	79 12                	jns    800410 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8003fe:	50                   	push   %eax
  8003ff:	68 10 22 80 00       	push   $0x802210
  800404:	6a 2c                	push   $0x2c
  800406:	68 05 22 80 00       	push   $0x802205
  80040b:	e8 7b 0f 00 00       	call   80138b <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800410:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800416:	83 ec 04             	sub    $0x4,%esp
  800419:	68 00 10 00 00       	push   $0x1000
  80041e:	53                   	push   %ebx
  80041f:	68 00 f0 7f 00       	push   $0x7ff000
  800424:	e8 ba 17 00 00       	call   801be3 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800429:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800430:	53                   	push   %ebx
  800431:	6a 00                	push   $0x0
  800433:	68 00 f0 7f 00       	push   $0x7ff000
  800438:	6a 00                	push   $0x0
  80043a:	e8 82 fd ff ff       	call   8001c1 <sys_page_map>
	if (r < 0) {
  80043f:	83 c4 20             	add    $0x20,%esp
  800442:	85 c0                	test   %eax,%eax
  800444:	79 12                	jns    800458 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800446:	50                   	push   %eax
  800447:	68 10 22 80 00       	push   $0x802210
  80044c:	6a 33                	push   $0x33
  80044e:	68 05 22 80 00       	push   $0x802205
  800453:	e8 33 0f 00 00       	call   80138b <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	68 00 f0 7f 00       	push   $0x7ff000
  800460:	6a 00                	push   $0x0
  800462:	e8 9c fd ff ff       	call   800203 <sys_page_unmap>
	if (r < 0) {
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	85 c0                	test   %eax,%eax
  80046c:	79 12                	jns    800480 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80046e:	50                   	push   %eax
  80046f:	68 10 22 80 00       	push   $0x802210
  800474:	6a 37                	push   $0x37
  800476:	68 05 22 80 00       	push   $0x802205
  80047b:	e8 0b 0f 00 00       	call   80138b <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  800480:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	57                   	push   %edi
  800489:	56                   	push   %esi
  80048a:	53                   	push   %ebx
  80048b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80048e:	68 af 03 80 00       	push   $0x8003af
  800493:	e8 98 18 00 00       	call   801d30 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800498:	b8 07 00 00 00       	mov    $0x7,%eax
  80049d:	cd 30                	int    $0x30
  80049f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	79 17                	jns    8004c0 <fork+0x3b>
		panic("fork fault %e");
  8004a9:	83 ec 04             	sub    $0x4,%esp
  8004ac:	68 29 22 80 00       	push   $0x802229
  8004b1:	68 84 00 00 00       	push   $0x84
  8004b6:	68 05 22 80 00       	push   $0x802205
  8004bb:	e8 cb 0e 00 00       	call   80138b <_panic>
  8004c0:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c6:	75 25                	jne    8004ed <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004c8:	e8 73 fc ff ff       	call   800140 <sys_getenvid>
  8004cd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d2:	89 c2                	mov    %eax,%edx
  8004d4:	c1 e2 07             	shl    $0x7,%edx
  8004d7:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8004de:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e8:	e9 61 01 00 00       	jmp    80064e <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004ed:	83 ec 04             	sub    $0x4,%esp
  8004f0:	6a 07                	push   $0x7
  8004f2:	68 00 f0 bf ee       	push   $0xeebff000
  8004f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004fa:	e8 7f fc ff ff       	call   80017e <sys_page_alloc>
  8004ff:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800502:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800507:	89 d8                	mov    %ebx,%eax
  800509:	c1 e8 16             	shr    $0x16,%eax
  80050c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800513:	a8 01                	test   $0x1,%al
  800515:	0f 84 fc 00 00 00    	je     800617 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  80051b:	89 d8                	mov    %ebx,%eax
  80051d:	c1 e8 0c             	shr    $0xc,%eax
  800520:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800527:	f6 c2 01             	test   $0x1,%dl
  80052a:	0f 84 e7 00 00 00    	je     800617 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800530:	89 c6                	mov    %eax,%esi
  800532:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800535:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80053c:	f6 c6 04             	test   $0x4,%dh
  80053f:	74 39                	je     80057a <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800541:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800548:	83 ec 0c             	sub    $0xc,%esp
  80054b:	25 07 0e 00 00       	and    $0xe07,%eax
  800550:	50                   	push   %eax
  800551:	56                   	push   %esi
  800552:	57                   	push   %edi
  800553:	56                   	push   %esi
  800554:	6a 00                	push   $0x0
  800556:	e8 66 fc ff ff       	call   8001c1 <sys_page_map>
		if (r < 0) {
  80055b:	83 c4 20             	add    $0x20,%esp
  80055e:	85 c0                	test   %eax,%eax
  800560:	0f 89 b1 00 00 00    	jns    800617 <fork+0x192>
		    	panic("sys page map fault %e");
  800566:	83 ec 04             	sub    $0x4,%esp
  800569:	68 37 22 80 00       	push   $0x802237
  80056e:	6a 54                	push   $0x54
  800570:	68 05 22 80 00       	push   $0x802205
  800575:	e8 11 0e 00 00       	call   80138b <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80057a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800581:	f6 c2 02             	test   $0x2,%dl
  800584:	75 0c                	jne    800592 <fork+0x10d>
  800586:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80058d:	f6 c4 08             	test   $0x8,%ah
  800590:	74 5b                	je     8005ed <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  800592:	83 ec 0c             	sub    $0xc,%esp
  800595:	68 05 08 00 00       	push   $0x805
  80059a:	56                   	push   %esi
  80059b:	57                   	push   %edi
  80059c:	56                   	push   %esi
  80059d:	6a 00                	push   $0x0
  80059f:	e8 1d fc ff ff       	call   8001c1 <sys_page_map>
		if (r < 0) {
  8005a4:	83 c4 20             	add    $0x20,%esp
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	79 14                	jns    8005bf <fork+0x13a>
		    	panic("sys page map fault %e");
  8005ab:	83 ec 04             	sub    $0x4,%esp
  8005ae:	68 37 22 80 00       	push   $0x802237
  8005b3:	6a 5b                	push   $0x5b
  8005b5:	68 05 22 80 00       	push   $0x802205
  8005ba:	e8 cc 0d 00 00       	call   80138b <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005bf:	83 ec 0c             	sub    $0xc,%esp
  8005c2:	68 05 08 00 00       	push   $0x805
  8005c7:	56                   	push   %esi
  8005c8:	6a 00                	push   $0x0
  8005ca:	56                   	push   %esi
  8005cb:	6a 00                	push   $0x0
  8005cd:	e8 ef fb ff ff       	call   8001c1 <sys_page_map>
		if (r < 0) {
  8005d2:	83 c4 20             	add    $0x20,%esp
  8005d5:	85 c0                	test   %eax,%eax
  8005d7:	79 3e                	jns    800617 <fork+0x192>
		    	panic("sys page map fault %e");
  8005d9:	83 ec 04             	sub    $0x4,%esp
  8005dc:	68 37 22 80 00       	push   $0x802237
  8005e1:	6a 5f                	push   $0x5f
  8005e3:	68 05 22 80 00       	push   $0x802205
  8005e8:	e8 9e 0d 00 00       	call   80138b <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005ed:	83 ec 0c             	sub    $0xc,%esp
  8005f0:	6a 05                	push   $0x5
  8005f2:	56                   	push   %esi
  8005f3:	57                   	push   %edi
  8005f4:	56                   	push   %esi
  8005f5:	6a 00                	push   $0x0
  8005f7:	e8 c5 fb ff ff       	call   8001c1 <sys_page_map>
		if (r < 0) {
  8005fc:	83 c4 20             	add    $0x20,%esp
  8005ff:	85 c0                	test   %eax,%eax
  800601:	79 14                	jns    800617 <fork+0x192>
		    	panic("sys page map fault %e");
  800603:	83 ec 04             	sub    $0x4,%esp
  800606:	68 37 22 80 00       	push   $0x802237
  80060b:	6a 64                	push   $0x64
  80060d:	68 05 22 80 00       	push   $0x802205
  800612:	e8 74 0d 00 00       	call   80138b <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800617:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80061d:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800623:	0f 85 de fe ff ff    	jne    800507 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800629:	a1 04 40 80 00       	mov    0x804004,%eax
  80062e:	8b 40 70             	mov    0x70(%eax),%eax
  800631:	83 ec 08             	sub    $0x8,%esp
  800634:	50                   	push   %eax
  800635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800638:	57                   	push   %edi
  800639:	e8 8b fc ff ff       	call   8002c9 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80063e:	83 c4 08             	add    $0x8,%esp
  800641:	6a 02                	push   $0x2
  800643:	57                   	push   %edi
  800644:	e8 fc fb ff ff       	call   800245 <sys_env_set_status>
	
	return envid;
  800649:	83 c4 10             	add    $0x10,%esp
  80064c:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80064e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800651:	5b                   	pop    %ebx
  800652:	5e                   	pop    %esi
  800653:	5f                   	pop    %edi
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    

00800656 <sfork>:

envid_t
sfork(void)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800659:	b8 00 00 00 00       	mov    $0x0,%eax
  80065e:	5d                   	pop    %ebp
  80065f:	c3                   	ret    

00800660 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
  800663:	56                   	push   %esi
  800664:	53                   	push   %ebx
  800665:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800668:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	68 50 22 80 00       	push   $0x802250
  800677:	e8 e8 0d 00 00       	call   801464 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80067c:	c7 04 24 88 00 80 00 	movl   $0x800088,(%esp)
  800683:	e8 e7 fc ff ff       	call   80036f <sys_thread_create>
  800688:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  80068a:	83 c4 08             	add    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	68 50 22 80 00       	push   $0x802250
  800693:	e8 cc 0d 00 00       	call   801464 <cprintf>
	return id;
	//return 0;
}
  800698:	89 f0                	mov    %esi,%eax
  80069a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80069d:	5b                   	pop    %ebx
  80069e:	5e                   	pop    %esi
  80069f:	5d                   	pop    %ebp
  8006a0:	c3                   	ret    

008006a1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8006ac:	c1 e8 0c             	shr    $0xc,%eax
}
  8006af:	5d                   	pop    %ebp
  8006b0:	c3                   	ret    

008006b1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8006bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006c1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ce:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006d3:	89 c2                	mov    %eax,%edx
  8006d5:	c1 ea 16             	shr    $0x16,%edx
  8006d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006df:	f6 c2 01             	test   $0x1,%dl
  8006e2:	74 11                	je     8006f5 <fd_alloc+0x2d>
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	c1 ea 0c             	shr    $0xc,%edx
  8006e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006f0:	f6 c2 01             	test   $0x1,%dl
  8006f3:	75 09                	jne    8006fe <fd_alloc+0x36>
			*fd_store = fd;
  8006f5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8006f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fc:	eb 17                	jmp    800715 <fd_alloc+0x4d>
  8006fe:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800703:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800708:	75 c9                	jne    8006d3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80070a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800710:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80071d:	83 f8 1f             	cmp    $0x1f,%eax
  800720:	77 36                	ja     800758 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800722:	c1 e0 0c             	shl    $0xc,%eax
  800725:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80072a:	89 c2                	mov    %eax,%edx
  80072c:	c1 ea 16             	shr    $0x16,%edx
  80072f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800736:	f6 c2 01             	test   $0x1,%dl
  800739:	74 24                	je     80075f <fd_lookup+0x48>
  80073b:	89 c2                	mov    %eax,%edx
  80073d:	c1 ea 0c             	shr    $0xc,%edx
  800740:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800747:	f6 c2 01             	test   $0x1,%dl
  80074a:	74 1a                	je     800766 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074f:	89 02                	mov    %eax,(%edx)
	return 0;
  800751:	b8 00 00 00 00       	mov    $0x0,%eax
  800756:	eb 13                	jmp    80076b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800758:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075d:	eb 0c                	jmp    80076b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800764:	eb 05                	jmp    80076b <fd_lookup+0x54>
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800776:	ba f0 22 80 00       	mov    $0x8022f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80077b:	eb 13                	jmp    800790 <dev_lookup+0x23>
  80077d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800780:	39 08                	cmp    %ecx,(%eax)
  800782:	75 0c                	jne    800790 <dev_lookup+0x23>
			*dev = devtab[i];
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800787:	89 01                	mov    %eax,(%ecx)
			return 0;
  800789:	b8 00 00 00 00       	mov    $0x0,%eax
  80078e:	eb 2e                	jmp    8007be <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800790:	8b 02                	mov    (%edx),%eax
  800792:	85 c0                	test   %eax,%eax
  800794:	75 e7                	jne    80077d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800796:	a1 04 40 80 00       	mov    0x804004,%eax
  80079b:	8b 40 54             	mov    0x54(%eax),%eax
  80079e:	83 ec 04             	sub    $0x4,%esp
  8007a1:	51                   	push   %ecx
  8007a2:	50                   	push   %eax
  8007a3:	68 74 22 80 00       	push   $0x802274
  8007a8:	e8 b7 0c 00 00       	call   801464 <cprintf>
	*dev = 0;
  8007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	56                   	push   %esi
  8007c4:	53                   	push   %ebx
  8007c5:	83 ec 10             	sub    $0x10,%esp
  8007c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d1:	50                   	push   %eax
  8007d2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007d8:	c1 e8 0c             	shr    $0xc,%eax
  8007db:	50                   	push   %eax
  8007dc:	e8 36 ff ff ff       	call   800717 <fd_lookup>
  8007e1:	83 c4 08             	add    $0x8,%esp
  8007e4:	85 c0                	test   %eax,%eax
  8007e6:	78 05                	js     8007ed <fd_close+0x2d>
	    || fd != fd2)
  8007e8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007eb:	74 0c                	je     8007f9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8007ed:	84 db                	test   %bl,%bl
  8007ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f4:	0f 44 c2             	cmove  %edx,%eax
  8007f7:	eb 41                	jmp    80083a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ff:	50                   	push   %eax
  800800:	ff 36                	pushl  (%esi)
  800802:	e8 66 ff ff ff       	call   80076d <dev_lookup>
  800807:	89 c3                	mov    %eax,%ebx
  800809:	83 c4 10             	add    $0x10,%esp
  80080c:	85 c0                	test   %eax,%eax
  80080e:	78 1a                	js     80082a <fd_close+0x6a>
		if (dev->dev_close)
  800810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800813:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800816:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80081b:	85 c0                	test   %eax,%eax
  80081d:	74 0b                	je     80082a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80081f:	83 ec 0c             	sub    $0xc,%esp
  800822:	56                   	push   %esi
  800823:	ff d0                	call   *%eax
  800825:	89 c3                	mov    %eax,%ebx
  800827:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	56                   	push   %esi
  80082e:	6a 00                	push   $0x0
  800830:	e8 ce f9 ff ff       	call   800203 <sys_page_unmap>
	return r;
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	89 d8                	mov    %ebx,%eax
}
  80083a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800847:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084a:	50                   	push   %eax
  80084b:	ff 75 08             	pushl  0x8(%ebp)
  80084e:	e8 c4 fe ff ff       	call   800717 <fd_lookup>
  800853:	83 c4 08             	add    $0x8,%esp
  800856:	85 c0                	test   %eax,%eax
  800858:	78 10                	js     80086a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	6a 01                	push   $0x1
  80085f:	ff 75 f4             	pushl  -0xc(%ebp)
  800862:	e8 59 ff ff ff       	call   8007c0 <fd_close>
  800867:	83 c4 10             	add    $0x10,%esp
}
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <close_all>:

void
close_all(void)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	53                   	push   %ebx
  800870:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800873:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800878:	83 ec 0c             	sub    $0xc,%esp
  80087b:	53                   	push   %ebx
  80087c:	e8 c0 ff ff ff       	call   800841 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800881:	83 c3 01             	add    $0x1,%ebx
  800884:	83 c4 10             	add    $0x10,%esp
  800887:	83 fb 20             	cmp    $0x20,%ebx
  80088a:	75 ec                	jne    800878 <close_all+0xc>
		close(i);
}
  80088c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088f:	c9                   	leave  
  800890:	c3                   	ret    

00800891 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	57                   	push   %edi
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
  800897:	83 ec 2c             	sub    $0x2c,%esp
  80089a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80089d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008a0:	50                   	push   %eax
  8008a1:	ff 75 08             	pushl  0x8(%ebp)
  8008a4:	e8 6e fe ff ff       	call   800717 <fd_lookup>
  8008a9:	83 c4 08             	add    $0x8,%esp
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	0f 88 c1 00 00 00    	js     800975 <dup+0xe4>
		return r;
	close(newfdnum);
  8008b4:	83 ec 0c             	sub    $0xc,%esp
  8008b7:	56                   	push   %esi
  8008b8:	e8 84 ff ff ff       	call   800841 <close>

	newfd = INDEX2FD(newfdnum);
  8008bd:	89 f3                	mov    %esi,%ebx
  8008bf:	c1 e3 0c             	shl    $0xc,%ebx
  8008c2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008c8:	83 c4 04             	add    $0x4,%esp
  8008cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008ce:	e8 de fd ff ff       	call   8006b1 <fd2data>
  8008d3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008d5:	89 1c 24             	mov    %ebx,(%esp)
  8008d8:	e8 d4 fd ff ff       	call   8006b1 <fd2data>
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008e3:	89 f8                	mov    %edi,%eax
  8008e5:	c1 e8 16             	shr    $0x16,%eax
  8008e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008ef:	a8 01                	test   $0x1,%al
  8008f1:	74 37                	je     80092a <dup+0x99>
  8008f3:	89 f8                	mov    %edi,%eax
  8008f5:	c1 e8 0c             	shr    $0xc,%eax
  8008f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8008ff:	f6 c2 01             	test   $0x1,%dl
  800902:	74 26                	je     80092a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800904:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80090b:	83 ec 0c             	sub    $0xc,%esp
  80090e:	25 07 0e 00 00       	and    $0xe07,%eax
  800913:	50                   	push   %eax
  800914:	ff 75 d4             	pushl  -0x2c(%ebp)
  800917:	6a 00                	push   $0x0
  800919:	57                   	push   %edi
  80091a:	6a 00                	push   $0x0
  80091c:	e8 a0 f8 ff ff       	call   8001c1 <sys_page_map>
  800921:	89 c7                	mov    %eax,%edi
  800923:	83 c4 20             	add    $0x20,%esp
  800926:	85 c0                	test   %eax,%eax
  800928:	78 2e                	js     800958 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80092a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80092d:	89 d0                	mov    %edx,%eax
  80092f:	c1 e8 0c             	shr    $0xc,%eax
  800932:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800939:	83 ec 0c             	sub    $0xc,%esp
  80093c:	25 07 0e 00 00       	and    $0xe07,%eax
  800941:	50                   	push   %eax
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	52                   	push   %edx
  800946:	6a 00                	push   $0x0
  800948:	e8 74 f8 ff ff       	call   8001c1 <sys_page_map>
  80094d:	89 c7                	mov    %eax,%edi
  80094f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800952:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800954:	85 ff                	test   %edi,%edi
  800956:	79 1d                	jns    800975 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800958:	83 ec 08             	sub    $0x8,%esp
  80095b:	53                   	push   %ebx
  80095c:	6a 00                	push   $0x0
  80095e:	e8 a0 f8 ff ff       	call   800203 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800963:	83 c4 08             	add    $0x8,%esp
  800966:	ff 75 d4             	pushl  -0x2c(%ebp)
  800969:	6a 00                	push   $0x0
  80096b:	e8 93 f8 ff ff       	call   800203 <sys_page_unmap>
	return r;
  800970:	83 c4 10             	add    $0x10,%esp
  800973:	89 f8                	mov    %edi,%eax
}
  800975:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	53                   	push   %ebx
  800981:	83 ec 14             	sub    $0x14,%esp
  800984:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800987:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80098a:	50                   	push   %eax
  80098b:	53                   	push   %ebx
  80098c:	e8 86 fd ff ff       	call   800717 <fd_lookup>
  800991:	83 c4 08             	add    $0x8,%esp
  800994:	89 c2                	mov    %eax,%edx
  800996:	85 c0                	test   %eax,%eax
  800998:	78 6d                	js     800a07 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80099a:	83 ec 08             	sub    $0x8,%esp
  80099d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a0:	50                   	push   %eax
  8009a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a4:	ff 30                	pushl  (%eax)
  8009a6:	e8 c2 fd ff ff       	call   80076d <dev_lookup>
  8009ab:	83 c4 10             	add    $0x10,%esp
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	78 4c                	js     8009fe <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009b5:	8b 42 08             	mov    0x8(%edx),%eax
  8009b8:	83 e0 03             	and    $0x3,%eax
  8009bb:	83 f8 01             	cmp    $0x1,%eax
  8009be:	75 21                	jne    8009e1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009c0:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c5:	8b 40 54             	mov    0x54(%eax),%eax
  8009c8:	83 ec 04             	sub    $0x4,%esp
  8009cb:	53                   	push   %ebx
  8009cc:	50                   	push   %eax
  8009cd:	68 b5 22 80 00       	push   $0x8022b5
  8009d2:	e8 8d 0a 00 00       	call   801464 <cprintf>
		return -E_INVAL;
  8009d7:	83 c4 10             	add    $0x10,%esp
  8009da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009df:	eb 26                	jmp    800a07 <read+0x8a>
	}
	if (!dev->dev_read)
  8009e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e4:	8b 40 08             	mov    0x8(%eax),%eax
  8009e7:	85 c0                	test   %eax,%eax
  8009e9:	74 17                	je     800a02 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009eb:	83 ec 04             	sub    $0x4,%esp
  8009ee:	ff 75 10             	pushl  0x10(%ebp)
  8009f1:	ff 75 0c             	pushl  0xc(%ebp)
  8009f4:	52                   	push   %edx
  8009f5:	ff d0                	call   *%eax
  8009f7:	89 c2                	mov    %eax,%edx
  8009f9:	83 c4 10             	add    $0x10,%esp
  8009fc:	eb 09                	jmp    800a07 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009fe:	89 c2                	mov    %eax,%edx
  800a00:	eb 05                	jmp    800a07 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a02:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a07:	89 d0                	mov    %edx,%eax
  800a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	57                   	push   %edi
  800a12:	56                   	push   %esi
  800a13:	53                   	push   %ebx
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a22:	eb 21                	jmp    800a45 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a24:	83 ec 04             	sub    $0x4,%esp
  800a27:	89 f0                	mov    %esi,%eax
  800a29:	29 d8                	sub    %ebx,%eax
  800a2b:	50                   	push   %eax
  800a2c:	89 d8                	mov    %ebx,%eax
  800a2e:	03 45 0c             	add    0xc(%ebp),%eax
  800a31:	50                   	push   %eax
  800a32:	57                   	push   %edi
  800a33:	e8 45 ff ff ff       	call   80097d <read>
		if (m < 0)
  800a38:	83 c4 10             	add    $0x10,%esp
  800a3b:	85 c0                	test   %eax,%eax
  800a3d:	78 10                	js     800a4f <readn+0x41>
			return m;
		if (m == 0)
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	74 0a                	je     800a4d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a43:	01 c3                	add    %eax,%ebx
  800a45:	39 f3                	cmp    %esi,%ebx
  800a47:	72 db                	jb     800a24 <readn+0x16>
  800a49:	89 d8                	mov    %ebx,%eax
  800a4b:	eb 02                	jmp    800a4f <readn+0x41>
  800a4d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a52:	5b                   	pop    %ebx
  800a53:	5e                   	pop    %esi
  800a54:	5f                   	pop    %edi
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	83 ec 14             	sub    $0x14,%esp
  800a5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a64:	50                   	push   %eax
  800a65:	53                   	push   %ebx
  800a66:	e8 ac fc ff ff       	call   800717 <fd_lookup>
  800a6b:	83 c4 08             	add    $0x8,%esp
  800a6e:	89 c2                	mov    %eax,%edx
  800a70:	85 c0                	test   %eax,%eax
  800a72:	78 68                	js     800adc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a74:	83 ec 08             	sub    $0x8,%esp
  800a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a7a:	50                   	push   %eax
  800a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a7e:	ff 30                	pushl  (%eax)
  800a80:	e8 e8 fc ff ff       	call   80076d <dev_lookup>
  800a85:	83 c4 10             	add    $0x10,%esp
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	78 47                	js     800ad3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a93:	75 21                	jne    800ab6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a95:	a1 04 40 80 00       	mov    0x804004,%eax
  800a9a:	8b 40 54             	mov    0x54(%eax),%eax
  800a9d:	83 ec 04             	sub    $0x4,%esp
  800aa0:	53                   	push   %ebx
  800aa1:	50                   	push   %eax
  800aa2:	68 d1 22 80 00       	push   $0x8022d1
  800aa7:	e8 b8 09 00 00       	call   801464 <cprintf>
		return -E_INVAL;
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ab4:	eb 26                	jmp    800adc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ab6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ab9:	8b 52 0c             	mov    0xc(%edx),%edx
  800abc:	85 d2                	test   %edx,%edx
  800abe:	74 17                	je     800ad7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ac0:	83 ec 04             	sub    $0x4,%esp
  800ac3:	ff 75 10             	pushl  0x10(%ebp)
  800ac6:	ff 75 0c             	pushl  0xc(%ebp)
  800ac9:	50                   	push   %eax
  800aca:	ff d2                	call   *%edx
  800acc:	89 c2                	mov    %eax,%edx
  800ace:	83 c4 10             	add    $0x10,%esp
  800ad1:	eb 09                	jmp    800adc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ad3:	89 c2                	mov    %eax,%edx
  800ad5:	eb 05                	jmp    800adc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ad7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800adc:	89 d0                	mov    %edx,%eax
  800ade:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae1:	c9                   	leave  
  800ae2:	c3                   	ret    

00800ae3 <seek>:

int
seek(int fdnum, off_t offset)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ae9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800aec:	50                   	push   %eax
  800aed:	ff 75 08             	pushl  0x8(%ebp)
  800af0:	e8 22 fc ff ff       	call   800717 <fd_lookup>
  800af5:	83 c4 08             	add    $0x8,%esp
  800af8:	85 c0                	test   %eax,%eax
  800afa:	78 0e                	js     800b0a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800afc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b02:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	53                   	push   %ebx
  800b10:	83 ec 14             	sub    $0x14,%esp
  800b13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b16:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b19:	50                   	push   %eax
  800b1a:	53                   	push   %ebx
  800b1b:	e8 f7 fb ff ff       	call   800717 <fd_lookup>
  800b20:	83 c4 08             	add    $0x8,%esp
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	85 c0                	test   %eax,%eax
  800b27:	78 65                	js     800b8e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b29:	83 ec 08             	sub    $0x8,%esp
  800b2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2f:	50                   	push   %eax
  800b30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b33:	ff 30                	pushl  (%eax)
  800b35:	e8 33 fc ff ff       	call   80076d <dev_lookup>
  800b3a:	83 c4 10             	add    $0x10,%esp
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	78 44                	js     800b85 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b44:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b48:	75 21                	jne    800b6b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b4a:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b4f:	8b 40 54             	mov    0x54(%eax),%eax
  800b52:	83 ec 04             	sub    $0x4,%esp
  800b55:	53                   	push   %ebx
  800b56:	50                   	push   %eax
  800b57:	68 94 22 80 00       	push   $0x802294
  800b5c:	e8 03 09 00 00       	call   801464 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b61:	83 c4 10             	add    $0x10,%esp
  800b64:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b69:	eb 23                	jmp    800b8e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b6e:	8b 52 18             	mov    0x18(%edx),%edx
  800b71:	85 d2                	test   %edx,%edx
  800b73:	74 14                	je     800b89 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b75:	83 ec 08             	sub    $0x8,%esp
  800b78:	ff 75 0c             	pushl  0xc(%ebp)
  800b7b:	50                   	push   %eax
  800b7c:	ff d2                	call   *%edx
  800b7e:	89 c2                	mov    %eax,%edx
  800b80:	83 c4 10             	add    $0x10,%esp
  800b83:	eb 09                	jmp    800b8e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b85:	89 c2                	mov    %eax,%edx
  800b87:	eb 05                	jmp    800b8e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b89:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b8e:	89 d0                	mov    %edx,%eax
  800b90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b93:	c9                   	leave  
  800b94:	c3                   	ret    

00800b95 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	53                   	push   %ebx
  800b99:	83 ec 14             	sub    $0x14,%esp
  800b9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ba2:	50                   	push   %eax
  800ba3:	ff 75 08             	pushl  0x8(%ebp)
  800ba6:	e8 6c fb ff ff       	call   800717 <fd_lookup>
  800bab:	83 c4 08             	add    $0x8,%esp
  800bae:	89 c2                	mov    %eax,%edx
  800bb0:	85 c0                	test   %eax,%eax
  800bb2:	78 58                	js     800c0c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bb4:	83 ec 08             	sub    $0x8,%esp
  800bb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bba:	50                   	push   %eax
  800bbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bbe:	ff 30                	pushl  (%eax)
  800bc0:	e8 a8 fb ff ff       	call   80076d <dev_lookup>
  800bc5:	83 c4 10             	add    $0x10,%esp
  800bc8:	85 c0                	test   %eax,%eax
  800bca:	78 37                	js     800c03 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bcf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bd3:	74 32                	je     800c07 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bd5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800bd8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800bdf:	00 00 00 
	stat->st_isdir = 0;
  800be2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be9:	00 00 00 
	stat->st_dev = dev;
  800bec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bf2:	83 ec 08             	sub    $0x8,%esp
  800bf5:	53                   	push   %ebx
  800bf6:	ff 75 f0             	pushl  -0x10(%ebp)
  800bf9:	ff 50 14             	call   *0x14(%eax)
  800bfc:	89 c2                	mov    %eax,%edx
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	eb 09                	jmp    800c0c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c03:	89 c2                	mov    %eax,%edx
  800c05:	eb 05                	jmp    800c0c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c07:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c0c:	89 d0                	mov    %edx,%eax
  800c0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c18:	83 ec 08             	sub    $0x8,%esp
  800c1b:	6a 00                	push   $0x0
  800c1d:	ff 75 08             	pushl  0x8(%ebp)
  800c20:	e8 e3 01 00 00       	call   800e08 <open>
  800c25:	89 c3                	mov    %eax,%ebx
  800c27:	83 c4 10             	add    $0x10,%esp
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	78 1b                	js     800c49 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c2e:	83 ec 08             	sub    $0x8,%esp
  800c31:	ff 75 0c             	pushl  0xc(%ebp)
  800c34:	50                   	push   %eax
  800c35:	e8 5b ff ff ff       	call   800b95 <fstat>
  800c3a:	89 c6                	mov    %eax,%esi
	close(fd);
  800c3c:	89 1c 24             	mov    %ebx,(%esp)
  800c3f:	e8 fd fb ff ff       	call   800841 <close>
	return r;
  800c44:	83 c4 10             	add    $0x10,%esp
  800c47:	89 f0                	mov    %esi,%eax
}
  800c49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	56                   	push   %esi
  800c54:	53                   	push   %ebx
  800c55:	89 c6                	mov    %eax,%esi
  800c57:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c59:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c60:	75 12                	jne    800c74 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c62:	83 ec 0c             	sub    $0xc,%esp
  800c65:	6a 01                	push   $0x1
  800c67:	e8 2d 12 00 00       	call   801e99 <ipc_find_env>
  800c6c:	a3 00 40 80 00       	mov    %eax,0x804000
  800c71:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c74:	6a 07                	push   $0x7
  800c76:	68 00 50 80 00       	push   $0x805000
  800c7b:	56                   	push   %esi
  800c7c:	ff 35 00 40 80 00    	pushl  0x804000
  800c82:	e8 b0 11 00 00       	call   801e37 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c87:	83 c4 0c             	add    $0xc,%esp
  800c8a:	6a 00                	push   $0x0
  800c8c:	53                   	push   %ebx
  800c8d:	6a 00                	push   $0x0
  800c8f:	e8 2b 11 00 00       	call   801dbf <ipc_recv>
}
  800c94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca4:	8b 40 0c             	mov    0xc(%eax),%eax
  800ca7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800caf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb9:	b8 02 00 00 00       	mov    $0x2,%eax
  800cbe:	e8 8d ff ff ff       	call   800c50 <fsipc>
}
  800cc3:	c9                   	leave  
  800cc4:	c3                   	ret    

00800cc5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	8b 40 0c             	mov    0xc(%eax),%eax
  800cd1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800cd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdb:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce0:	e8 6b ff ff ff       	call   800c50 <fsipc>
}
  800ce5:	c9                   	leave  
  800ce6:	c3                   	ret    

00800ce7 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 04             	sub    $0x4,%esp
  800cee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	8b 40 0c             	mov    0xc(%eax),%eax
  800cf7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800cfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800d01:	b8 05 00 00 00       	mov    $0x5,%eax
  800d06:	e8 45 ff ff ff       	call   800c50 <fsipc>
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	78 2c                	js     800d3b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d0f:	83 ec 08             	sub    $0x8,%esp
  800d12:	68 00 50 80 00       	push   $0x805000
  800d17:	53                   	push   %ebx
  800d18:	e8 cc 0c 00 00       	call   8019e9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d1d:	a1 80 50 80 00       	mov    0x805080,%eax
  800d22:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d28:	a1 84 50 80 00       	mov    0x805084,%eax
  800d2d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d33:	83 c4 10             	add    $0x10,%esp
  800d36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d49:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4c:	8b 52 0c             	mov    0xc(%edx),%edx
  800d4f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d55:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d5a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d5f:	0f 47 c2             	cmova  %edx,%eax
  800d62:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d67:	50                   	push   %eax
  800d68:	ff 75 0c             	pushl  0xc(%ebp)
  800d6b:	68 08 50 80 00       	push   $0x805008
  800d70:	e8 06 0e 00 00       	call   801b7b <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d75:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d7f:	e8 cc fe ff ff       	call   800c50 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d84:	c9                   	leave  
  800d85:	c3                   	ret    

00800d86 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	8b 40 0c             	mov    0xc(%eax),%eax
  800d94:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800d99:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800d9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800da4:	b8 03 00 00 00       	mov    $0x3,%eax
  800da9:	e8 a2 fe ff ff       	call   800c50 <fsipc>
  800dae:	89 c3                	mov    %eax,%ebx
  800db0:	85 c0                	test   %eax,%eax
  800db2:	78 4b                	js     800dff <devfile_read+0x79>
		return r;
	assert(r <= n);
  800db4:	39 c6                	cmp    %eax,%esi
  800db6:	73 16                	jae    800dce <devfile_read+0x48>
  800db8:	68 00 23 80 00       	push   $0x802300
  800dbd:	68 07 23 80 00       	push   $0x802307
  800dc2:	6a 7c                	push   $0x7c
  800dc4:	68 1c 23 80 00       	push   $0x80231c
  800dc9:	e8 bd 05 00 00       	call   80138b <_panic>
	assert(r <= PGSIZE);
  800dce:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800dd3:	7e 16                	jle    800deb <devfile_read+0x65>
  800dd5:	68 27 23 80 00       	push   $0x802327
  800dda:	68 07 23 80 00       	push   $0x802307
  800ddf:	6a 7d                	push   $0x7d
  800de1:	68 1c 23 80 00       	push   $0x80231c
  800de6:	e8 a0 05 00 00       	call   80138b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800deb:	83 ec 04             	sub    $0x4,%esp
  800dee:	50                   	push   %eax
  800def:	68 00 50 80 00       	push   $0x805000
  800df4:	ff 75 0c             	pushl  0xc(%ebp)
  800df7:	e8 7f 0d 00 00       	call   801b7b <memmove>
	return r;
  800dfc:	83 c4 10             	add    $0x10,%esp
}
  800dff:	89 d8                	mov    %ebx,%eax
  800e01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	53                   	push   %ebx
  800e0c:	83 ec 20             	sub    $0x20,%esp
  800e0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e12:	53                   	push   %ebx
  800e13:	e8 98 0b 00 00       	call   8019b0 <strlen>
  800e18:	83 c4 10             	add    $0x10,%esp
  800e1b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e20:	7f 67                	jg     800e89 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e28:	50                   	push   %eax
  800e29:	e8 9a f8 ff ff       	call   8006c8 <fd_alloc>
  800e2e:	83 c4 10             	add    $0x10,%esp
		return r;
  800e31:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e33:	85 c0                	test   %eax,%eax
  800e35:	78 57                	js     800e8e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e37:	83 ec 08             	sub    $0x8,%esp
  800e3a:	53                   	push   %ebx
  800e3b:	68 00 50 80 00       	push   $0x805000
  800e40:	e8 a4 0b 00 00       	call   8019e9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e48:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e50:	b8 01 00 00 00       	mov    $0x1,%eax
  800e55:	e8 f6 fd ff ff       	call   800c50 <fsipc>
  800e5a:	89 c3                	mov    %eax,%ebx
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	79 14                	jns    800e77 <open+0x6f>
		fd_close(fd, 0);
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	6a 00                	push   $0x0
  800e68:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6b:	e8 50 f9 ff ff       	call   8007c0 <fd_close>
		return r;
  800e70:	83 c4 10             	add    $0x10,%esp
  800e73:	89 da                	mov    %ebx,%edx
  800e75:	eb 17                	jmp    800e8e <open+0x86>
	}

	return fd2num(fd);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7d:	e8 1f f8 ff ff       	call   8006a1 <fd2num>
  800e82:	89 c2                	mov    %eax,%edx
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	eb 05                	jmp    800e8e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e89:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e8e:	89 d0                	mov    %edx,%eax
  800e90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800e9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea0:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea5:	e8 a6 fd ff ff       	call   800c50 <fsipc>
}
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800eb4:	83 ec 0c             	sub    $0xc,%esp
  800eb7:	ff 75 08             	pushl  0x8(%ebp)
  800eba:	e8 f2 f7 ff ff       	call   8006b1 <fd2data>
  800ebf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ec1:	83 c4 08             	add    $0x8,%esp
  800ec4:	68 33 23 80 00       	push   $0x802333
  800ec9:	53                   	push   %ebx
  800eca:	e8 1a 0b 00 00       	call   8019e9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ecf:	8b 46 04             	mov    0x4(%esi),%eax
  800ed2:	2b 06                	sub    (%esi),%eax
  800ed4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800eda:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ee1:	00 00 00 
	stat->st_dev = &devpipe;
  800ee4:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800eeb:	30 80 00 
	return 0;
}
  800eee:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	53                   	push   %ebx
  800efe:	83 ec 0c             	sub    $0xc,%esp
  800f01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f04:	53                   	push   %ebx
  800f05:	6a 00                	push   $0x0
  800f07:	e8 f7 f2 ff ff       	call   800203 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f0c:	89 1c 24             	mov    %ebx,(%esp)
  800f0f:	e8 9d f7 ff ff       	call   8006b1 <fd2data>
  800f14:	83 c4 08             	add    $0x8,%esp
  800f17:	50                   	push   %eax
  800f18:	6a 00                	push   $0x0
  800f1a:	e8 e4 f2 ff ff       	call   800203 <sys_page_unmap>
}
  800f1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f22:	c9                   	leave  
  800f23:	c3                   	ret    

00800f24 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	57                   	push   %edi
  800f28:	56                   	push   %esi
  800f29:	53                   	push   %ebx
  800f2a:	83 ec 1c             	sub    $0x1c,%esp
  800f2d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f30:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f32:	a1 04 40 80 00       	mov    0x804004,%eax
  800f37:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f3a:	83 ec 0c             	sub    $0xc,%esp
  800f3d:	ff 75 e0             	pushl  -0x20(%ebp)
  800f40:	e8 94 0f 00 00       	call   801ed9 <pageref>
  800f45:	89 c3                	mov    %eax,%ebx
  800f47:	89 3c 24             	mov    %edi,(%esp)
  800f4a:	e8 8a 0f 00 00       	call   801ed9 <pageref>
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	39 c3                	cmp    %eax,%ebx
  800f54:	0f 94 c1             	sete   %cl
  800f57:	0f b6 c9             	movzbl %cl,%ecx
  800f5a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f5d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f63:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  800f66:	39 ce                	cmp    %ecx,%esi
  800f68:	74 1b                	je     800f85 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800f6a:	39 c3                	cmp    %eax,%ebx
  800f6c:	75 c4                	jne    800f32 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f6e:	8b 42 64             	mov    0x64(%edx),%eax
  800f71:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f74:	50                   	push   %eax
  800f75:	56                   	push   %esi
  800f76:	68 3a 23 80 00       	push   $0x80233a
  800f7b:	e8 e4 04 00 00       	call   801464 <cprintf>
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	eb ad                	jmp    800f32 <_pipeisclosed+0xe>
	}
}
  800f85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f8b:	5b                   	pop    %ebx
  800f8c:	5e                   	pop    %esi
  800f8d:	5f                   	pop    %edi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	83 ec 28             	sub    $0x28,%esp
  800f99:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800f9c:	56                   	push   %esi
  800f9d:	e8 0f f7 ff ff       	call   8006b1 <fd2data>
  800fa2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	bf 00 00 00 00       	mov    $0x0,%edi
  800fac:	eb 4b                	jmp    800ff9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fae:	89 da                	mov    %ebx,%edx
  800fb0:	89 f0                	mov    %esi,%eax
  800fb2:	e8 6d ff ff ff       	call   800f24 <_pipeisclosed>
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	75 48                	jne    801003 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fbb:	e8 9f f1 ff ff       	call   80015f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fc0:	8b 43 04             	mov    0x4(%ebx),%eax
  800fc3:	8b 0b                	mov    (%ebx),%ecx
  800fc5:	8d 51 20             	lea    0x20(%ecx),%edx
  800fc8:	39 d0                	cmp    %edx,%eax
  800fca:	73 e2                	jae    800fae <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcf:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fd3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fd6:	89 c2                	mov    %eax,%edx
  800fd8:	c1 fa 1f             	sar    $0x1f,%edx
  800fdb:	89 d1                	mov    %edx,%ecx
  800fdd:	c1 e9 1b             	shr    $0x1b,%ecx
  800fe0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800fe3:	83 e2 1f             	and    $0x1f,%edx
  800fe6:	29 ca                	sub    %ecx,%edx
  800fe8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800fec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ff0:	83 c0 01             	add    $0x1,%eax
  800ff3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ff6:	83 c7 01             	add    $0x1,%edi
  800ff9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ffc:	75 c2                	jne    800fc0 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ffe:	8b 45 10             	mov    0x10(%ebp),%eax
  801001:	eb 05                	jmp    801008 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801008:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100b:	5b                   	pop    %ebx
  80100c:	5e                   	pop    %esi
  80100d:	5f                   	pop    %edi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	53                   	push   %ebx
  801016:	83 ec 18             	sub    $0x18,%esp
  801019:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80101c:	57                   	push   %edi
  80101d:	e8 8f f6 ff ff       	call   8006b1 <fd2data>
  801022:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	bb 00 00 00 00       	mov    $0x0,%ebx
  80102c:	eb 3d                	jmp    80106b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80102e:	85 db                	test   %ebx,%ebx
  801030:	74 04                	je     801036 <devpipe_read+0x26>
				return i;
  801032:	89 d8                	mov    %ebx,%eax
  801034:	eb 44                	jmp    80107a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801036:	89 f2                	mov    %esi,%edx
  801038:	89 f8                	mov    %edi,%eax
  80103a:	e8 e5 fe ff ff       	call   800f24 <_pipeisclosed>
  80103f:	85 c0                	test   %eax,%eax
  801041:	75 32                	jne    801075 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801043:	e8 17 f1 ff ff       	call   80015f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801048:	8b 06                	mov    (%esi),%eax
  80104a:	3b 46 04             	cmp    0x4(%esi),%eax
  80104d:	74 df                	je     80102e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80104f:	99                   	cltd   
  801050:	c1 ea 1b             	shr    $0x1b,%edx
  801053:	01 d0                	add    %edx,%eax
  801055:	83 e0 1f             	and    $0x1f,%eax
  801058:	29 d0                	sub    %edx,%eax
  80105a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80105f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801062:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801065:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801068:	83 c3 01             	add    $0x1,%ebx
  80106b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80106e:	75 d8                	jne    801048 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801070:	8b 45 10             	mov    0x10(%ebp),%eax
  801073:	eb 05                	jmp    80107a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801075:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80107a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107d:	5b                   	pop    %ebx
  80107e:	5e                   	pop    %esi
  80107f:	5f                   	pop    %edi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    

00801082 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	56                   	push   %esi
  801086:	53                   	push   %ebx
  801087:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80108a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80108d:	50                   	push   %eax
  80108e:	e8 35 f6 ff ff       	call   8006c8 <fd_alloc>
  801093:	83 c4 10             	add    $0x10,%esp
  801096:	89 c2                	mov    %eax,%edx
  801098:	85 c0                	test   %eax,%eax
  80109a:	0f 88 2c 01 00 00    	js     8011cc <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010a0:	83 ec 04             	sub    $0x4,%esp
  8010a3:	68 07 04 00 00       	push   $0x407
  8010a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ab:	6a 00                	push   $0x0
  8010ad:	e8 cc f0 ff ff       	call   80017e <sys_page_alloc>
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	89 c2                	mov    %eax,%edx
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	0f 88 0d 01 00 00    	js     8011cc <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010bf:	83 ec 0c             	sub    $0xc,%esp
  8010c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c5:	50                   	push   %eax
  8010c6:	e8 fd f5 ff ff       	call   8006c8 <fd_alloc>
  8010cb:	89 c3                	mov    %eax,%ebx
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	0f 88 e2 00 00 00    	js     8011ba <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	68 07 04 00 00       	push   $0x407
  8010e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8010e3:	6a 00                	push   $0x0
  8010e5:	e8 94 f0 ff ff       	call   80017e <sys_page_alloc>
  8010ea:	89 c3                	mov    %eax,%ebx
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	0f 88 c3 00 00 00    	js     8011ba <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8010f7:	83 ec 0c             	sub    $0xc,%esp
  8010fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8010fd:	e8 af f5 ff ff       	call   8006b1 <fd2data>
  801102:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801104:	83 c4 0c             	add    $0xc,%esp
  801107:	68 07 04 00 00       	push   $0x407
  80110c:	50                   	push   %eax
  80110d:	6a 00                	push   $0x0
  80110f:	e8 6a f0 ff ff       	call   80017e <sys_page_alloc>
  801114:	89 c3                	mov    %eax,%ebx
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	85 c0                	test   %eax,%eax
  80111b:	0f 88 89 00 00 00    	js     8011aa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	ff 75 f0             	pushl  -0x10(%ebp)
  801127:	e8 85 f5 ff ff       	call   8006b1 <fd2data>
  80112c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801133:	50                   	push   %eax
  801134:	6a 00                	push   $0x0
  801136:	56                   	push   %esi
  801137:	6a 00                	push   $0x0
  801139:	e8 83 f0 ff ff       	call   8001c1 <sys_page_map>
  80113e:	89 c3                	mov    %eax,%ebx
  801140:	83 c4 20             	add    $0x20,%esp
  801143:	85 c0                	test   %eax,%eax
  801145:	78 55                	js     80119c <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801147:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80114d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801150:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801152:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801155:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80115c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801167:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801171:	83 ec 0c             	sub    $0xc,%esp
  801174:	ff 75 f4             	pushl  -0xc(%ebp)
  801177:	e8 25 f5 ff ff       	call   8006a1 <fd2num>
  80117c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801181:	83 c4 04             	add    $0x4,%esp
  801184:	ff 75 f0             	pushl  -0x10(%ebp)
  801187:	e8 15 f5 ff ff       	call   8006a1 <fd2num>
  80118c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118f:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801192:	83 c4 10             	add    $0x10,%esp
  801195:	ba 00 00 00 00       	mov    $0x0,%edx
  80119a:	eb 30                	jmp    8011cc <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	56                   	push   %esi
  8011a0:	6a 00                	push   $0x0
  8011a2:	e8 5c f0 ff ff       	call   800203 <sys_page_unmap>
  8011a7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 4c f0 ff ff       	call   800203 <sys_page_unmap>
  8011b7:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8011c0:	6a 00                	push   $0x0
  8011c2:	e8 3c f0 ff ff       	call   800203 <sys_page_unmap>
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011cc:	89 d0                	mov    %edx,%eax
  8011ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	ff 75 08             	pushl  0x8(%ebp)
  8011e2:	e8 30 f5 ff ff       	call   800717 <fd_lookup>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	85 c0                	test   %eax,%eax
  8011ec:	78 18                	js     801206 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011ee:	83 ec 0c             	sub    $0xc,%esp
  8011f1:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f4:	e8 b8 f4 ff ff       	call   8006b1 <fd2data>
	return _pipeisclosed(fd, p);
  8011f9:	89 c2                	mov    %eax,%edx
  8011fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fe:	e8 21 fd ff ff       	call   800f24 <_pipeisclosed>
  801203:	83 c4 10             	add    $0x10,%esp
}
  801206:	c9                   	leave  
  801207:	c3                   	ret    

00801208 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80120b:	b8 00 00 00 00       	mov    $0x0,%eax
  801210:	5d                   	pop    %ebp
  801211:	c3                   	ret    

00801212 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801212:	55                   	push   %ebp
  801213:	89 e5                	mov    %esp,%ebp
  801215:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801218:	68 52 23 80 00       	push   $0x802352
  80121d:	ff 75 0c             	pushl  0xc(%ebp)
  801220:	e8 c4 07 00 00       	call   8019e9 <strcpy>
	return 0;
}
  801225:	b8 00 00 00 00       	mov    $0x0,%eax
  80122a:	c9                   	leave  
  80122b:	c3                   	ret    

0080122c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	57                   	push   %edi
  801230:	56                   	push   %esi
  801231:	53                   	push   %ebx
  801232:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801238:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80123d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801243:	eb 2d                	jmp    801272 <devcons_write+0x46>
		m = n - tot;
  801245:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801248:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80124a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80124d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801252:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801255:	83 ec 04             	sub    $0x4,%esp
  801258:	53                   	push   %ebx
  801259:	03 45 0c             	add    0xc(%ebp),%eax
  80125c:	50                   	push   %eax
  80125d:	57                   	push   %edi
  80125e:	e8 18 09 00 00       	call   801b7b <memmove>
		sys_cputs(buf, m);
  801263:	83 c4 08             	add    $0x8,%esp
  801266:	53                   	push   %ebx
  801267:	57                   	push   %edi
  801268:	e8 55 ee ff ff       	call   8000c2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80126d:	01 de                	add    %ebx,%esi
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	89 f0                	mov    %esi,%eax
  801274:	3b 75 10             	cmp    0x10(%ebp),%esi
  801277:	72 cc                	jb     801245 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127c:	5b                   	pop    %ebx
  80127d:	5e                   	pop    %esi
  80127e:	5f                   	pop    %edi
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80128c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801290:	74 2a                	je     8012bc <devcons_read+0x3b>
  801292:	eb 05                	jmp    801299 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801294:	e8 c6 ee ff ff       	call   80015f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801299:	e8 42 ee ff ff       	call   8000e0 <sys_cgetc>
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	74 f2                	je     801294 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 16                	js     8012bc <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012a6:	83 f8 04             	cmp    $0x4,%eax
  8012a9:	74 0c                	je     8012b7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ae:	88 02                	mov    %al,(%edx)
	return 1;
  8012b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b5:	eb 05                	jmp    8012bc <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012b7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012bc:	c9                   	leave  
  8012bd:	c3                   	ret    

008012be <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012be:	55                   	push   %ebp
  8012bf:	89 e5                	mov    %esp,%ebp
  8012c1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012ca:	6a 01                	push   $0x1
  8012cc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	e8 ed ed ff ff       	call   8000c2 <sys_cputs>
}
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	c9                   	leave  
  8012d9:	c3                   	ret    

008012da <getchar>:

int
getchar(void)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012e0:	6a 01                	push   $0x1
  8012e2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	6a 00                	push   $0x0
  8012e8:	e8 90 f6 ff ff       	call   80097d <read>
	if (r < 0)
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	78 0f                	js     801303 <getchar+0x29>
		return r;
	if (r < 1)
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	7e 06                	jle    8012fe <getchar+0x24>
		return -E_EOF;
	return c;
  8012f8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8012fc:	eb 05                	jmp    801303 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8012fe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801303:	c9                   	leave  
  801304:	c3                   	ret    

00801305 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80130b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130e:	50                   	push   %eax
  80130f:	ff 75 08             	pushl  0x8(%ebp)
  801312:	e8 00 f4 ff ff       	call   800717 <fd_lookup>
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 11                	js     80132f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80131e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801321:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801327:	39 10                	cmp    %edx,(%eax)
  801329:	0f 94 c0             	sete   %al
  80132c:	0f b6 c0             	movzbl %al,%eax
}
  80132f:	c9                   	leave  
  801330:	c3                   	ret    

00801331 <opencons>:

int
opencons(void)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801337:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	e8 88 f3 ff ff       	call   8006c8 <fd_alloc>
  801340:	83 c4 10             	add    $0x10,%esp
		return r;
  801343:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801345:	85 c0                	test   %eax,%eax
  801347:	78 3e                	js     801387 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801349:	83 ec 04             	sub    $0x4,%esp
  80134c:	68 07 04 00 00       	push   $0x407
  801351:	ff 75 f4             	pushl  -0xc(%ebp)
  801354:	6a 00                	push   $0x0
  801356:	e8 23 ee ff ff       	call   80017e <sys_page_alloc>
  80135b:	83 c4 10             	add    $0x10,%esp
		return r;
  80135e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801360:	85 c0                	test   %eax,%eax
  801362:	78 23                	js     801387 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801364:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80136a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801372:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801379:	83 ec 0c             	sub    $0xc,%esp
  80137c:	50                   	push   %eax
  80137d:	e8 1f f3 ff ff       	call   8006a1 <fd2num>
  801382:	89 c2                	mov    %eax,%edx
  801384:	83 c4 10             	add    $0x10,%esp
}
  801387:	89 d0                	mov    %edx,%eax
  801389:	c9                   	leave  
  80138a:	c3                   	ret    

0080138b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	56                   	push   %esi
  80138f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801390:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801393:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801399:	e8 a2 ed ff ff       	call   800140 <sys_getenvid>
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	ff 75 0c             	pushl  0xc(%ebp)
  8013a4:	ff 75 08             	pushl  0x8(%ebp)
  8013a7:	56                   	push   %esi
  8013a8:	50                   	push   %eax
  8013a9:	68 60 23 80 00       	push   $0x802360
  8013ae:	e8 b1 00 00 00       	call   801464 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013b3:	83 c4 18             	add    $0x18,%esp
  8013b6:	53                   	push   %ebx
  8013b7:	ff 75 10             	pushl  0x10(%ebp)
  8013ba:	e8 54 00 00 00       	call   801413 <vcprintf>
	cprintf("\n");
  8013bf:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  8013c6:	e8 99 00 00 00       	call   801464 <cprintf>
  8013cb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013ce:	cc                   	int3   
  8013cf:	eb fd                	jmp    8013ce <_panic+0x43>

008013d1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	53                   	push   %ebx
  8013d5:	83 ec 04             	sub    $0x4,%esp
  8013d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013db:	8b 13                	mov    (%ebx),%edx
  8013dd:	8d 42 01             	lea    0x1(%edx),%eax
  8013e0:	89 03                	mov    %eax,(%ebx)
  8013e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013e9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013ee:	75 1a                	jne    80140a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013f0:	83 ec 08             	sub    $0x8,%esp
  8013f3:	68 ff 00 00 00       	push   $0xff
  8013f8:	8d 43 08             	lea    0x8(%ebx),%eax
  8013fb:	50                   	push   %eax
  8013fc:	e8 c1 ec ff ff       	call   8000c2 <sys_cputs>
		b->idx = 0;
  801401:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801407:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80140a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80140e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80141c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801423:	00 00 00 
	b.cnt = 0;
  801426:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80142d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801430:	ff 75 0c             	pushl  0xc(%ebp)
  801433:	ff 75 08             	pushl  0x8(%ebp)
  801436:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80143c:	50                   	push   %eax
  80143d:	68 d1 13 80 00       	push   $0x8013d1
  801442:	e8 54 01 00 00       	call   80159b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801447:	83 c4 08             	add    $0x8,%esp
  80144a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801450:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801456:	50                   	push   %eax
  801457:	e8 66 ec ff ff       	call   8000c2 <sys_cputs>

	return b.cnt;
}
  80145c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80146a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80146d:	50                   	push   %eax
  80146e:	ff 75 08             	pushl  0x8(%ebp)
  801471:	e8 9d ff ff ff       	call   801413 <vcprintf>
	va_end(ap);

	return cnt;
}
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	57                   	push   %edi
  80147c:	56                   	push   %esi
  80147d:	53                   	push   %ebx
  80147e:	83 ec 1c             	sub    $0x1c,%esp
  801481:	89 c7                	mov    %eax,%edi
  801483:	89 d6                	mov    %edx,%esi
  801485:	8b 45 08             	mov    0x8(%ebp),%eax
  801488:	8b 55 0c             	mov    0xc(%ebp),%edx
  80148b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80148e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801491:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801494:	bb 00 00 00 00       	mov    $0x0,%ebx
  801499:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80149c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80149f:	39 d3                	cmp    %edx,%ebx
  8014a1:	72 05                	jb     8014a8 <printnum+0x30>
  8014a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014a6:	77 45                	ja     8014ed <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014a8:	83 ec 0c             	sub    $0xc,%esp
  8014ab:	ff 75 18             	pushl  0x18(%ebp)
  8014ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014b4:	53                   	push   %ebx
  8014b5:	ff 75 10             	pushl  0x10(%ebp)
  8014b8:	83 ec 08             	sub    $0x8,%esp
  8014bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014be:	ff 75 e0             	pushl  -0x20(%ebp)
  8014c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8014c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8014c7:	e8 54 0a 00 00       	call   801f20 <__udivdi3>
  8014cc:	83 c4 18             	add    $0x18,%esp
  8014cf:	52                   	push   %edx
  8014d0:	50                   	push   %eax
  8014d1:	89 f2                	mov    %esi,%edx
  8014d3:	89 f8                	mov    %edi,%eax
  8014d5:	e8 9e ff ff ff       	call   801478 <printnum>
  8014da:	83 c4 20             	add    $0x20,%esp
  8014dd:	eb 18                	jmp    8014f7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	56                   	push   %esi
  8014e3:	ff 75 18             	pushl  0x18(%ebp)
  8014e6:	ff d7                	call   *%edi
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	eb 03                	jmp    8014f0 <printnum+0x78>
  8014ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014f0:	83 eb 01             	sub    $0x1,%ebx
  8014f3:	85 db                	test   %ebx,%ebx
  8014f5:	7f e8                	jg     8014df <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014f7:	83 ec 08             	sub    $0x8,%esp
  8014fa:	56                   	push   %esi
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	ff 75 e4             	pushl  -0x1c(%ebp)
  801501:	ff 75 e0             	pushl  -0x20(%ebp)
  801504:	ff 75 dc             	pushl  -0x24(%ebp)
  801507:	ff 75 d8             	pushl  -0x28(%ebp)
  80150a:	e8 41 0b 00 00       	call   802050 <__umoddi3>
  80150f:	83 c4 14             	add    $0x14,%esp
  801512:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  801519:	50                   	push   %eax
  80151a:	ff d7                	call   *%edi
}
  80151c:	83 c4 10             	add    $0x10,%esp
  80151f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801522:	5b                   	pop    %ebx
  801523:	5e                   	pop    %esi
  801524:	5f                   	pop    %edi
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    

00801527 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80152a:	83 fa 01             	cmp    $0x1,%edx
  80152d:	7e 0e                	jle    80153d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80152f:	8b 10                	mov    (%eax),%edx
  801531:	8d 4a 08             	lea    0x8(%edx),%ecx
  801534:	89 08                	mov    %ecx,(%eax)
  801536:	8b 02                	mov    (%edx),%eax
  801538:	8b 52 04             	mov    0x4(%edx),%edx
  80153b:	eb 22                	jmp    80155f <getuint+0x38>
	else if (lflag)
  80153d:	85 d2                	test   %edx,%edx
  80153f:	74 10                	je     801551 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801541:	8b 10                	mov    (%eax),%edx
  801543:	8d 4a 04             	lea    0x4(%edx),%ecx
  801546:	89 08                	mov    %ecx,(%eax)
  801548:	8b 02                	mov    (%edx),%eax
  80154a:	ba 00 00 00 00       	mov    $0x0,%edx
  80154f:	eb 0e                	jmp    80155f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801551:	8b 10                	mov    (%eax),%edx
  801553:	8d 4a 04             	lea    0x4(%edx),%ecx
  801556:	89 08                	mov    %ecx,(%eax)
  801558:	8b 02                	mov    (%edx),%eax
  80155a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80155f:	5d                   	pop    %ebp
  801560:	c3                   	ret    

00801561 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801567:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80156b:	8b 10                	mov    (%eax),%edx
  80156d:	3b 50 04             	cmp    0x4(%eax),%edx
  801570:	73 0a                	jae    80157c <sprintputch+0x1b>
		*b->buf++ = ch;
  801572:	8d 4a 01             	lea    0x1(%edx),%ecx
  801575:	89 08                	mov    %ecx,(%eax)
  801577:	8b 45 08             	mov    0x8(%ebp),%eax
  80157a:	88 02                	mov    %al,(%edx)
}
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801584:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801587:	50                   	push   %eax
  801588:	ff 75 10             	pushl  0x10(%ebp)
  80158b:	ff 75 0c             	pushl  0xc(%ebp)
  80158e:	ff 75 08             	pushl  0x8(%ebp)
  801591:	e8 05 00 00 00       	call   80159b <vprintfmt>
	va_end(ap);
}
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	57                   	push   %edi
  80159f:	56                   	push   %esi
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 2c             	sub    $0x2c,%esp
  8015a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8015a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015aa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015ad:	eb 12                	jmp    8015c1 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	0f 84 89 03 00 00    	je     801940 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	53                   	push   %ebx
  8015bb:	50                   	push   %eax
  8015bc:	ff d6                	call   *%esi
  8015be:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015c1:	83 c7 01             	add    $0x1,%edi
  8015c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015c8:	83 f8 25             	cmp    $0x25,%eax
  8015cb:	75 e2                	jne    8015af <vprintfmt+0x14>
  8015cd:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015d1:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015d8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015df:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015eb:	eb 07                	jmp    8015f4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015f0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f4:	8d 47 01             	lea    0x1(%edi),%eax
  8015f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015fa:	0f b6 07             	movzbl (%edi),%eax
  8015fd:	0f b6 c8             	movzbl %al,%ecx
  801600:	83 e8 23             	sub    $0x23,%eax
  801603:	3c 55                	cmp    $0x55,%al
  801605:	0f 87 1a 03 00 00    	ja     801925 <vprintfmt+0x38a>
  80160b:	0f b6 c0             	movzbl %al,%eax
  80160e:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  801615:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801618:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80161c:	eb d6                	jmp    8015f4 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801621:	b8 00 00 00 00       	mov    $0x0,%eax
  801626:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801629:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80162c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801630:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801633:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801636:	83 fa 09             	cmp    $0x9,%edx
  801639:	77 39                	ja     801674 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80163b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80163e:	eb e9                	jmp    801629 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801640:	8b 45 14             	mov    0x14(%ebp),%eax
  801643:	8d 48 04             	lea    0x4(%eax),%ecx
  801646:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801649:	8b 00                	mov    (%eax),%eax
  80164b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801651:	eb 27                	jmp    80167a <vprintfmt+0xdf>
  801653:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801656:	85 c0                	test   %eax,%eax
  801658:	b9 00 00 00 00       	mov    $0x0,%ecx
  80165d:	0f 49 c8             	cmovns %eax,%ecx
  801660:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801666:	eb 8c                	jmp    8015f4 <vprintfmt+0x59>
  801668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80166b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801672:	eb 80                	jmp    8015f4 <vprintfmt+0x59>
  801674:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801677:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80167a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80167e:	0f 89 70 ff ff ff    	jns    8015f4 <vprintfmt+0x59>
				width = precision, precision = -1;
  801684:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801687:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80168a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801691:	e9 5e ff ff ff       	jmp    8015f4 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801696:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80169c:	e9 53 ff ff ff       	jmp    8015f4 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a4:	8d 50 04             	lea    0x4(%eax),%edx
  8016a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8016aa:	83 ec 08             	sub    $0x8,%esp
  8016ad:	53                   	push   %ebx
  8016ae:	ff 30                	pushl  (%eax)
  8016b0:	ff d6                	call   *%esi
			break;
  8016b2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016b8:	e9 04 ff ff ff       	jmp    8015c1 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c0:	8d 50 04             	lea    0x4(%eax),%edx
  8016c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c6:	8b 00                	mov    (%eax),%eax
  8016c8:	99                   	cltd   
  8016c9:	31 d0                	xor    %edx,%eax
  8016cb:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016cd:	83 f8 0f             	cmp    $0xf,%eax
  8016d0:	7f 0b                	jg     8016dd <vprintfmt+0x142>
  8016d2:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8016d9:	85 d2                	test   %edx,%edx
  8016db:	75 18                	jne    8016f5 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016dd:	50                   	push   %eax
  8016de:	68 9b 23 80 00       	push   $0x80239b
  8016e3:	53                   	push   %ebx
  8016e4:	56                   	push   %esi
  8016e5:	e8 94 fe ff ff       	call   80157e <printfmt>
  8016ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016f0:	e9 cc fe ff ff       	jmp    8015c1 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8016f5:	52                   	push   %edx
  8016f6:	68 19 23 80 00       	push   $0x802319
  8016fb:	53                   	push   %ebx
  8016fc:	56                   	push   %esi
  8016fd:	e8 7c fe ff ff       	call   80157e <printfmt>
  801702:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801705:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801708:	e9 b4 fe ff ff       	jmp    8015c1 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80170d:	8b 45 14             	mov    0x14(%ebp),%eax
  801710:	8d 50 04             	lea    0x4(%eax),%edx
  801713:	89 55 14             	mov    %edx,0x14(%ebp)
  801716:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801718:	85 ff                	test   %edi,%edi
  80171a:	b8 94 23 80 00       	mov    $0x802394,%eax
  80171f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801722:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801726:	0f 8e 94 00 00 00    	jle    8017c0 <vprintfmt+0x225>
  80172c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801730:	0f 84 98 00 00 00    	je     8017ce <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801736:	83 ec 08             	sub    $0x8,%esp
  801739:	ff 75 d0             	pushl  -0x30(%ebp)
  80173c:	57                   	push   %edi
  80173d:	e8 86 02 00 00       	call   8019c8 <strnlen>
  801742:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801745:	29 c1                	sub    %eax,%ecx
  801747:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80174a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80174d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801751:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801754:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801757:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801759:	eb 0f                	jmp    80176a <vprintfmt+0x1cf>
					putch(padc, putdat);
  80175b:	83 ec 08             	sub    $0x8,%esp
  80175e:	53                   	push   %ebx
  80175f:	ff 75 e0             	pushl  -0x20(%ebp)
  801762:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801764:	83 ef 01             	sub    $0x1,%edi
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	85 ff                	test   %edi,%edi
  80176c:	7f ed                	jg     80175b <vprintfmt+0x1c0>
  80176e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801771:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801774:	85 c9                	test   %ecx,%ecx
  801776:	b8 00 00 00 00       	mov    $0x0,%eax
  80177b:	0f 49 c1             	cmovns %ecx,%eax
  80177e:	29 c1                	sub    %eax,%ecx
  801780:	89 75 08             	mov    %esi,0x8(%ebp)
  801783:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801786:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801789:	89 cb                	mov    %ecx,%ebx
  80178b:	eb 4d                	jmp    8017da <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80178d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801791:	74 1b                	je     8017ae <vprintfmt+0x213>
  801793:	0f be c0             	movsbl %al,%eax
  801796:	83 e8 20             	sub    $0x20,%eax
  801799:	83 f8 5e             	cmp    $0x5e,%eax
  80179c:	76 10                	jbe    8017ae <vprintfmt+0x213>
					putch('?', putdat);
  80179e:	83 ec 08             	sub    $0x8,%esp
  8017a1:	ff 75 0c             	pushl  0xc(%ebp)
  8017a4:	6a 3f                	push   $0x3f
  8017a6:	ff 55 08             	call   *0x8(%ebp)
  8017a9:	83 c4 10             	add    $0x10,%esp
  8017ac:	eb 0d                	jmp    8017bb <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017ae:	83 ec 08             	sub    $0x8,%esp
  8017b1:	ff 75 0c             	pushl  0xc(%ebp)
  8017b4:	52                   	push   %edx
  8017b5:	ff 55 08             	call   *0x8(%ebp)
  8017b8:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017bb:	83 eb 01             	sub    $0x1,%ebx
  8017be:	eb 1a                	jmp    8017da <vprintfmt+0x23f>
  8017c0:	89 75 08             	mov    %esi,0x8(%ebp)
  8017c3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017c9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017cc:	eb 0c                	jmp    8017da <vprintfmt+0x23f>
  8017ce:	89 75 08             	mov    %esi,0x8(%ebp)
  8017d1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017d4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017d7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017da:	83 c7 01             	add    $0x1,%edi
  8017dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017e1:	0f be d0             	movsbl %al,%edx
  8017e4:	85 d2                	test   %edx,%edx
  8017e6:	74 23                	je     80180b <vprintfmt+0x270>
  8017e8:	85 f6                	test   %esi,%esi
  8017ea:	78 a1                	js     80178d <vprintfmt+0x1f2>
  8017ec:	83 ee 01             	sub    $0x1,%esi
  8017ef:	79 9c                	jns    80178d <vprintfmt+0x1f2>
  8017f1:	89 df                	mov    %ebx,%edi
  8017f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017f9:	eb 18                	jmp    801813 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8017fb:	83 ec 08             	sub    $0x8,%esp
  8017fe:	53                   	push   %ebx
  8017ff:	6a 20                	push   $0x20
  801801:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801803:	83 ef 01             	sub    $0x1,%edi
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	eb 08                	jmp    801813 <vprintfmt+0x278>
  80180b:	89 df                	mov    %ebx,%edi
  80180d:	8b 75 08             	mov    0x8(%ebp),%esi
  801810:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801813:	85 ff                	test   %edi,%edi
  801815:	7f e4                	jg     8017fb <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801817:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80181a:	e9 a2 fd ff ff       	jmp    8015c1 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80181f:	83 fa 01             	cmp    $0x1,%edx
  801822:	7e 16                	jle    80183a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801824:	8b 45 14             	mov    0x14(%ebp),%eax
  801827:	8d 50 08             	lea    0x8(%eax),%edx
  80182a:	89 55 14             	mov    %edx,0x14(%ebp)
  80182d:	8b 50 04             	mov    0x4(%eax),%edx
  801830:	8b 00                	mov    (%eax),%eax
  801832:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801835:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801838:	eb 32                	jmp    80186c <vprintfmt+0x2d1>
	else if (lflag)
  80183a:	85 d2                	test   %edx,%edx
  80183c:	74 18                	je     801856 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80183e:	8b 45 14             	mov    0x14(%ebp),%eax
  801841:	8d 50 04             	lea    0x4(%eax),%edx
  801844:	89 55 14             	mov    %edx,0x14(%ebp)
  801847:	8b 00                	mov    (%eax),%eax
  801849:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80184c:	89 c1                	mov    %eax,%ecx
  80184e:	c1 f9 1f             	sar    $0x1f,%ecx
  801851:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801854:	eb 16                	jmp    80186c <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801856:	8b 45 14             	mov    0x14(%ebp),%eax
  801859:	8d 50 04             	lea    0x4(%eax),%edx
  80185c:	89 55 14             	mov    %edx,0x14(%ebp)
  80185f:	8b 00                	mov    (%eax),%eax
  801861:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801864:	89 c1                	mov    %eax,%ecx
  801866:	c1 f9 1f             	sar    $0x1f,%ecx
  801869:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80186c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80186f:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801872:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801877:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80187b:	79 74                	jns    8018f1 <vprintfmt+0x356>
				putch('-', putdat);
  80187d:	83 ec 08             	sub    $0x8,%esp
  801880:	53                   	push   %ebx
  801881:	6a 2d                	push   $0x2d
  801883:	ff d6                	call   *%esi
				num = -(long long) num;
  801885:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801888:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80188b:	f7 d8                	neg    %eax
  80188d:	83 d2 00             	adc    $0x0,%edx
  801890:	f7 da                	neg    %edx
  801892:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801895:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80189a:	eb 55                	jmp    8018f1 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80189c:	8d 45 14             	lea    0x14(%ebp),%eax
  80189f:	e8 83 fc ff ff       	call   801527 <getuint>
			base = 10;
  8018a4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018a9:	eb 46                	jmp    8018f1 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8018ae:	e8 74 fc ff ff       	call   801527 <getuint>
			base = 8;
  8018b3:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018b8:	eb 37                	jmp    8018f1 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018ba:	83 ec 08             	sub    $0x8,%esp
  8018bd:	53                   	push   %ebx
  8018be:	6a 30                	push   $0x30
  8018c0:	ff d6                	call   *%esi
			putch('x', putdat);
  8018c2:	83 c4 08             	add    $0x8,%esp
  8018c5:	53                   	push   %ebx
  8018c6:	6a 78                	push   $0x78
  8018c8:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8018cd:	8d 50 04             	lea    0x4(%eax),%edx
  8018d0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018d3:	8b 00                	mov    (%eax),%eax
  8018d5:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018da:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018dd:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018e2:	eb 0d                	jmp    8018f1 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018e4:	8d 45 14             	lea    0x14(%ebp),%eax
  8018e7:	e8 3b fc ff ff       	call   801527 <getuint>
			base = 16;
  8018ec:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018f1:	83 ec 0c             	sub    $0xc,%esp
  8018f4:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8018f8:	57                   	push   %edi
  8018f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8018fc:	51                   	push   %ecx
  8018fd:	52                   	push   %edx
  8018fe:	50                   	push   %eax
  8018ff:	89 da                	mov    %ebx,%edx
  801901:	89 f0                	mov    %esi,%eax
  801903:	e8 70 fb ff ff       	call   801478 <printnum>
			break;
  801908:	83 c4 20             	add    $0x20,%esp
  80190b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80190e:	e9 ae fc ff ff       	jmp    8015c1 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	53                   	push   %ebx
  801917:	51                   	push   %ecx
  801918:	ff d6                	call   *%esi
			break;
  80191a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80191d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801920:	e9 9c fc ff ff       	jmp    8015c1 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801925:	83 ec 08             	sub    $0x8,%esp
  801928:	53                   	push   %ebx
  801929:	6a 25                	push   $0x25
  80192b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	eb 03                	jmp    801935 <vprintfmt+0x39a>
  801932:	83 ef 01             	sub    $0x1,%edi
  801935:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801939:	75 f7                	jne    801932 <vprintfmt+0x397>
  80193b:	e9 81 fc ff ff       	jmp    8015c1 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801940:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801943:	5b                   	pop    %ebx
  801944:	5e                   	pop    %esi
  801945:	5f                   	pop    %edi
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	83 ec 18             	sub    $0x18,%esp
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801954:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801957:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80195b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80195e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801965:	85 c0                	test   %eax,%eax
  801967:	74 26                	je     80198f <vsnprintf+0x47>
  801969:	85 d2                	test   %edx,%edx
  80196b:	7e 22                	jle    80198f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80196d:	ff 75 14             	pushl  0x14(%ebp)
  801970:	ff 75 10             	pushl  0x10(%ebp)
  801973:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801976:	50                   	push   %eax
  801977:	68 61 15 80 00       	push   $0x801561
  80197c:	e8 1a fc ff ff       	call   80159b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801981:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801984:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801987:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	eb 05                	jmp    801994 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80198f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80199c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80199f:	50                   	push   %eax
  8019a0:	ff 75 10             	pushl  0x10(%ebp)
  8019a3:	ff 75 0c             	pushl  0xc(%ebp)
  8019a6:	ff 75 08             	pushl  0x8(%ebp)
  8019a9:	e8 9a ff ff ff       	call   801948 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bb:	eb 03                	jmp    8019c0 <strlen+0x10>
		n++;
  8019bd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019c0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019c4:	75 f7                	jne    8019bd <strlen+0xd>
		n++;
	return n;
}
  8019c6:	5d                   	pop    %ebp
  8019c7:	c3                   	ret    

008019c8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ce:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d6:	eb 03                	jmp    8019db <strnlen+0x13>
		n++;
  8019d8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019db:	39 c2                	cmp    %eax,%edx
  8019dd:	74 08                	je     8019e7 <strnlen+0x1f>
  8019df:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019e3:	75 f3                	jne    8019d8 <strnlen+0x10>
  8019e5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	53                   	push   %ebx
  8019ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019f3:	89 c2                	mov    %eax,%edx
  8019f5:	83 c2 01             	add    $0x1,%edx
  8019f8:	83 c1 01             	add    $0x1,%ecx
  8019fb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8019ff:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a02:	84 db                	test   %bl,%bl
  801a04:	75 ef                	jne    8019f5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a06:	5b                   	pop    %ebx
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	53                   	push   %ebx
  801a0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a10:	53                   	push   %ebx
  801a11:	e8 9a ff ff ff       	call   8019b0 <strlen>
  801a16:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a19:	ff 75 0c             	pushl  0xc(%ebp)
  801a1c:	01 d8                	add    %ebx,%eax
  801a1e:	50                   	push   %eax
  801a1f:	e8 c5 ff ff ff       	call   8019e9 <strcpy>
	return dst;
}
  801a24:	89 d8                	mov    %ebx,%eax
  801a26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	56                   	push   %esi
  801a2f:	53                   	push   %ebx
  801a30:	8b 75 08             	mov    0x8(%ebp),%esi
  801a33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a36:	89 f3                	mov    %esi,%ebx
  801a38:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a3b:	89 f2                	mov    %esi,%edx
  801a3d:	eb 0f                	jmp    801a4e <strncpy+0x23>
		*dst++ = *src;
  801a3f:	83 c2 01             	add    $0x1,%edx
  801a42:	0f b6 01             	movzbl (%ecx),%eax
  801a45:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a48:	80 39 01             	cmpb   $0x1,(%ecx)
  801a4b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a4e:	39 da                	cmp    %ebx,%edx
  801a50:	75 ed                	jne    801a3f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a52:	89 f0                	mov    %esi,%eax
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	56                   	push   %esi
  801a5c:	53                   	push   %ebx
  801a5d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a63:	8b 55 10             	mov    0x10(%ebp),%edx
  801a66:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a68:	85 d2                	test   %edx,%edx
  801a6a:	74 21                	je     801a8d <strlcpy+0x35>
  801a6c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a70:	89 f2                	mov    %esi,%edx
  801a72:	eb 09                	jmp    801a7d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a74:	83 c2 01             	add    $0x1,%edx
  801a77:	83 c1 01             	add    $0x1,%ecx
  801a7a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a7d:	39 c2                	cmp    %eax,%edx
  801a7f:	74 09                	je     801a8a <strlcpy+0x32>
  801a81:	0f b6 19             	movzbl (%ecx),%ebx
  801a84:	84 db                	test   %bl,%bl
  801a86:	75 ec                	jne    801a74 <strlcpy+0x1c>
  801a88:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a8a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a8d:	29 f0                	sub    %esi,%eax
}
  801a8f:	5b                   	pop    %ebx
  801a90:	5e                   	pop    %esi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    

00801a93 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a99:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801a9c:	eb 06                	jmp    801aa4 <strcmp+0x11>
		p++, q++;
  801a9e:	83 c1 01             	add    $0x1,%ecx
  801aa1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801aa4:	0f b6 01             	movzbl (%ecx),%eax
  801aa7:	84 c0                	test   %al,%al
  801aa9:	74 04                	je     801aaf <strcmp+0x1c>
  801aab:	3a 02                	cmp    (%edx),%al
  801aad:	74 ef                	je     801a9e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801aaf:	0f b6 c0             	movzbl %al,%eax
  801ab2:	0f b6 12             	movzbl (%edx),%edx
  801ab5:	29 d0                	sub    %edx,%eax
}
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	53                   	push   %ebx
  801abd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac3:	89 c3                	mov    %eax,%ebx
  801ac5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ac8:	eb 06                	jmp    801ad0 <strncmp+0x17>
		n--, p++, q++;
  801aca:	83 c0 01             	add    $0x1,%eax
  801acd:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ad0:	39 d8                	cmp    %ebx,%eax
  801ad2:	74 15                	je     801ae9 <strncmp+0x30>
  801ad4:	0f b6 08             	movzbl (%eax),%ecx
  801ad7:	84 c9                	test   %cl,%cl
  801ad9:	74 04                	je     801adf <strncmp+0x26>
  801adb:	3a 0a                	cmp    (%edx),%cl
  801add:	74 eb                	je     801aca <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801adf:	0f b6 00             	movzbl (%eax),%eax
  801ae2:	0f b6 12             	movzbl (%edx),%edx
  801ae5:	29 d0                	sub    %edx,%eax
  801ae7:	eb 05                	jmp    801aee <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801ae9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801aee:	5b                   	pop    %ebx
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	8b 45 08             	mov    0x8(%ebp),%eax
  801af7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801afb:	eb 07                	jmp    801b04 <strchr+0x13>
		if (*s == c)
  801afd:	38 ca                	cmp    %cl,%dl
  801aff:	74 0f                	je     801b10 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b01:	83 c0 01             	add    $0x1,%eax
  801b04:	0f b6 10             	movzbl (%eax),%edx
  801b07:	84 d2                	test   %dl,%dl
  801b09:	75 f2                	jne    801afd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b10:	5d                   	pop    %ebp
  801b11:	c3                   	ret    

00801b12 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	8b 45 08             	mov    0x8(%ebp),%eax
  801b18:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b1c:	eb 03                	jmp    801b21 <strfind+0xf>
  801b1e:	83 c0 01             	add    $0x1,%eax
  801b21:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b24:	38 ca                	cmp    %cl,%dl
  801b26:	74 04                	je     801b2c <strfind+0x1a>
  801b28:	84 d2                	test   %dl,%dl
  801b2a:	75 f2                	jne    801b1e <strfind+0xc>
			break;
	return (char *) s;
}
  801b2c:	5d                   	pop    %ebp
  801b2d:	c3                   	ret    

00801b2e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	57                   	push   %edi
  801b32:	56                   	push   %esi
  801b33:	53                   	push   %ebx
  801b34:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b3a:	85 c9                	test   %ecx,%ecx
  801b3c:	74 36                	je     801b74 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b44:	75 28                	jne    801b6e <memset+0x40>
  801b46:	f6 c1 03             	test   $0x3,%cl
  801b49:	75 23                	jne    801b6e <memset+0x40>
		c &= 0xFF;
  801b4b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b4f:	89 d3                	mov    %edx,%ebx
  801b51:	c1 e3 08             	shl    $0x8,%ebx
  801b54:	89 d6                	mov    %edx,%esi
  801b56:	c1 e6 18             	shl    $0x18,%esi
  801b59:	89 d0                	mov    %edx,%eax
  801b5b:	c1 e0 10             	shl    $0x10,%eax
  801b5e:	09 f0                	or     %esi,%eax
  801b60:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b62:	89 d8                	mov    %ebx,%eax
  801b64:	09 d0                	or     %edx,%eax
  801b66:	c1 e9 02             	shr    $0x2,%ecx
  801b69:	fc                   	cld    
  801b6a:	f3 ab                	rep stos %eax,%es:(%edi)
  801b6c:	eb 06                	jmp    801b74 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b71:	fc                   	cld    
  801b72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b74:	89 f8                	mov    %edi,%eax
  801b76:	5b                   	pop    %ebx
  801b77:	5e                   	pop    %esi
  801b78:	5f                   	pop    %edi
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	57                   	push   %edi
  801b7f:	56                   	push   %esi
  801b80:	8b 45 08             	mov    0x8(%ebp),%eax
  801b83:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b86:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b89:	39 c6                	cmp    %eax,%esi
  801b8b:	73 35                	jae    801bc2 <memmove+0x47>
  801b8d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b90:	39 d0                	cmp    %edx,%eax
  801b92:	73 2e                	jae    801bc2 <memmove+0x47>
		s += n;
		d += n;
  801b94:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b97:	89 d6                	mov    %edx,%esi
  801b99:	09 fe                	or     %edi,%esi
  801b9b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801ba1:	75 13                	jne    801bb6 <memmove+0x3b>
  801ba3:	f6 c1 03             	test   $0x3,%cl
  801ba6:	75 0e                	jne    801bb6 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801ba8:	83 ef 04             	sub    $0x4,%edi
  801bab:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bae:	c1 e9 02             	shr    $0x2,%ecx
  801bb1:	fd                   	std    
  801bb2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bb4:	eb 09                	jmp    801bbf <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bb6:	83 ef 01             	sub    $0x1,%edi
  801bb9:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bbc:	fd                   	std    
  801bbd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bbf:	fc                   	cld    
  801bc0:	eb 1d                	jmp    801bdf <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bc2:	89 f2                	mov    %esi,%edx
  801bc4:	09 c2                	or     %eax,%edx
  801bc6:	f6 c2 03             	test   $0x3,%dl
  801bc9:	75 0f                	jne    801bda <memmove+0x5f>
  801bcb:	f6 c1 03             	test   $0x3,%cl
  801bce:	75 0a                	jne    801bda <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bd0:	c1 e9 02             	shr    $0x2,%ecx
  801bd3:	89 c7                	mov    %eax,%edi
  801bd5:	fc                   	cld    
  801bd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bd8:	eb 05                	jmp    801bdf <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bda:	89 c7                	mov    %eax,%edi
  801bdc:	fc                   	cld    
  801bdd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801bdf:	5e                   	pop    %esi
  801be0:	5f                   	pop    %edi
  801be1:	5d                   	pop    %ebp
  801be2:	c3                   	ret    

00801be3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801be6:	ff 75 10             	pushl  0x10(%ebp)
  801be9:	ff 75 0c             	pushl  0xc(%ebp)
  801bec:	ff 75 08             	pushl  0x8(%ebp)
  801bef:	e8 87 ff ff ff       	call   801b7b <memmove>
}
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	56                   	push   %esi
  801bfa:	53                   	push   %ebx
  801bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c01:	89 c6                	mov    %eax,%esi
  801c03:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c06:	eb 1a                	jmp    801c22 <memcmp+0x2c>
		if (*s1 != *s2)
  801c08:	0f b6 08             	movzbl (%eax),%ecx
  801c0b:	0f b6 1a             	movzbl (%edx),%ebx
  801c0e:	38 d9                	cmp    %bl,%cl
  801c10:	74 0a                	je     801c1c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c12:	0f b6 c1             	movzbl %cl,%eax
  801c15:	0f b6 db             	movzbl %bl,%ebx
  801c18:	29 d8                	sub    %ebx,%eax
  801c1a:	eb 0f                	jmp    801c2b <memcmp+0x35>
		s1++, s2++;
  801c1c:	83 c0 01             	add    $0x1,%eax
  801c1f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c22:	39 f0                	cmp    %esi,%eax
  801c24:	75 e2                	jne    801c08 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c2b:	5b                   	pop    %ebx
  801c2c:	5e                   	pop    %esi
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    

00801c2f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	53                   	push   %ebx
  801c33:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c36:	89 c1                	mov    %eax,%ecx
  801c38:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c3b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c3f:	eb 0a                	jmp    801c4b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c41:	0f b6 10             	movzbl (%eax),%edx
  801c44:	39 da                	cmp    %ebx,%edx
  801c46:	74 07                	je     801c4f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c48:	83 c0 01             	add    $0x1,%eax
  801c4b:	39 c8                	cmp    %ecx,%eax
  801c4d:	72 f2                	jb     801c41 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c4f:	5b                   	pop    %ebx
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	57                   	push   %edi
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c5e:	eb 03                	jmp    801c63 <strtol+0x11>
		s++;
  801c60:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c63:	0f b6 01             	movzbl (%ecx),%eax
  801c66:	3c 20                	cmp    $0x20,%al
  801c68:	74 f6                	je     801c60 <strtol+0xe>
  801c6a:	3c 09                	cmp    $0x9,%al
  801c6c:	74 f2                	je     801c60 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c6e:	3c 2b                	cmp    $0x2b,%al
  801c70:	75 0a                	jne    801c7c <strtol+0x2a>
		s++;
  801c72:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c75:	bf 00 00 00 00       	mov    $0x0,%edi
  801c7a:	eb 11                	jmp    801c8d <strtol+0x3b>
  801c7c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c81:	3c 2d                	cmp    $0x2d,%al
  801c83:	75 08                	jne    801c8d <strtol+0x3b>
		s++, neg = 1;
  801c85:	83 c1 01             	add    $0x1,%ecx
  801c88:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c8d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c93:	75 15                	jne    801caa <strtol+0x58>
  801c95:	80 39 30             	cmpb   $0x30,(%ecx)
  801c98:	75 10                	jne    801caa <strtol+0x58>
  801c9a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801c9e:	75 7c                	jne    801d1c <strtol+0xca>
		s += 2, base = 16;
  801ca0:	83 c1 02             	add    $0x2,%ecx
  801ca3:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ca8:	eb 16                	jmp    801cc0 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801caa:	85 db                	test   %ebx,%ebx
  801cac:	75 12                	jne    801cc0 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cae:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cb3:	80 39 30             	cmpb   $0x30,(%ecx)
  801cb6:	75 08                	jne    801cc0 <strtol+0x6e>
		s++, base = 8;
  801cb8:	83 c1 01             	add    $0x1,%ecx
  801cbb:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc5:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cc8:	0f b6 11             	movzbl (%ecx),%edx
  801ccb:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cce:	89 f3                	mov    %esi,%ebx
  801cd0:	80 fb 09             	cmp    $0x9,%bl
  801cd3:	77 08                	ja     801cdd <strtol+0x8b>
			dig = *s - '0';
  801cd5:	0f be d2             	movsbl %dl,%edx
  801cd8:	83 ea 30             	sub    $0x30,%edx
  801cdb:	eb 22                	jmp    801cff <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801cdd:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ce0:	89 f3                	mov    %esi,%ebx
  801ce2:	80 fb 19             	cmp    $0x19,%bl
  801ce5:	77 08                	ja     801cef <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ce7:	0f be d2             	movsbl %dl,%edx
  801cea:	83 ea 57             	sub    $0x57,%edx
  801ced:	eb 10                	jmp    801cff <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801cef:	8d 72 bf             	lea    -0x41(%edx),%esi
  801cf2:	89 f3                	mov    %esi,%ebx
  801cf4:	80 fb 19             	cmp    $0x19,%bl
  801cf7:	77 16                	ja     801d0f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801cf9:	0f be d2             	movsbl %dl,%edx
  801cfc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801cff:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d02:	7d 0b                	jge    801d0f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d04:	83 c1 01             	add    $0x1,%ecx
  801d07:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d0b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d0d:	eb b9                	jmp    801cc8 <strtol+0x76>

	if (endptr)
  801d0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d13:	74 0d                	je     801d22 <strtol+0xd0>
		*endptr = (char *) s;
  801d15:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d18:	89 0e                	mov    %ecx,(%esi)
  801d1a:	eb 06                	jmp    801d22 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d1c:	85 db                	test   %ebx,%ebx
  801d1e:	74 98                	je     801cb8 <strtol+0x66>
  801d20:	eb 9e                	jmp    801cc0 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d22:	89 c2                	mov    %eax,%edx
  801d24:	f7 da                	neg    %edx
  801d26:	85 ff                	test   %edi,%edi
  801d28:	0f 45 c2             	cmovne %edx,%eax
}
  801d2b:	5b                   	pop    %ebx
  801d2c:	5e                   	pop    %esi
  801d2d:	5f                   	pop    %edi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    

00801d30 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d36:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d3d:	75 2a                	jne    801d69 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d3f:	83 ec 04             	sub    $0x4,%esp
  801d42:	6a 07                	push   $0x7
  801d44:	68 00 f0 bf ee       	push   $0xeebff000
  801d49:	6a 00                	push   $0x0
  801d4b:	e8 2e e4 ff ff       	call   80017e <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d50:	83 c4 10             	add    $0x10,%esp
  801d53:	85 c0                	test   %eax,%eax
  801d55:	79 12                	jns    801d69 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d57:	50                   	push   %eax
  801d58:	68 80 26 80 00       	push   $0x802680
  801d5d:	6a 23                	push   $0x23
  801d5f:	68 84 26 80 00       	push   $0x802684
  801d64:	e8 22 f6 ff ff       	call   80138b <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d69:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6c:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d71:	83 ec 08             	sub    $0x8,%esp
  801d74:	68 9b 1d 80 00       	push   $0x801d9b
  801d79:	6a 00                	push   $0x0
  801d7b:	e8 49 e5 ff ff       	call   8002c9 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d80:	83 c4 10             	add    $0x10,%esp
  801d83:	85 c0                	test   %eax,%eax
  801d85:	79 12                	jns    801d99 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d87:	50                   	push   %eax
  801d88:	68 80 26 80 00       	push   $0x802680
  801d8d:	6a 2c                	push   $0x2c
  801d8f:	68 84 26 80 00       	push   $0x802684
  801d94:	e8 f2 f5 ff ff       	call   80138b <_panic>
	}
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d9b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d9c:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801da1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801da3:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801da6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801daa:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801daf:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801db3:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801db5:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801db8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801db9:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dbc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dbd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dbe:	c3                   	ret    

00801dbf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	8b 75 08             	mov    0x8(%ebp),%esi
  801dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	75 12                	jne    801de3 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801dd1:	83 ec 0c             	sub    $0xc,%esp
  801dd4:	68 00 00 c0 ee       	push   $0xeec00000
  801dd9:	e8 50 e5 ff ff       	call   80032e <sys_ipc_recv>
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	eb 0c                	jmp    801def <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801de3:	83 ec 0c             	sub    $0xc,%esp
  801de6:	50                   	push   %eax
  801de7:	e8 42 e5 ff ff       	call   80032e <sys_ipc_recv>
  801dec:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801def:	85 f6                	test   %esi,%esi
  801df1:	0f 95 c1             	setne  %cl
  801df4:	85 db                	test   %ebx,%ebx
  801df6:	0f 95 c2             	setne  %dl
  801df9:	84 d1                	test   %dl,%cl
  801dfb:	74 09                	je     801e06 <ipc_recv+0x47>
  801dfd:	89 c2                	mov    %eax,%edx
  801dff:	c1 ea 1f             	shr    $0x1f,%edx
  801e02:	84 d2                	test   %dl,%dl
  801e04:	75 2a                	jne    801e30 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e06:	85 f6                	test   %esi,%esi
  801e08:	74 0d                	je     801e17 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e0a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e0f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e15:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e17:	85 db                	test   %ebx,%ebx
  801e19:	74 0d                	je     801e28 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e1b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e20:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e26:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e28:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2d:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5d                   	pop    %ebp
  801e36:	c3                   	ret    

00801e37 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	57                   	push   %edi
  801e3b:	56                   	push   %esi
  801e3c:	53                   	push   %ebx
  801e3d:	83 ec 0c             	sub    $0xc,%esp
  801e40:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e43:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e49:	85 db                	test   %ebx,%ebx
  801e4b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e50:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e53:	ff 75 14             	pushl  0x14(%ebp)
  801e56:	53                   	push   %ebx
  801e57:	56                   	push   %esi
  801e58:	57                   	push   %edi
  801e59:	e8 ad e4 ff ff       	call   80030b <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e5e:	89 c2                	mov    %eax,%edx
  801e60:	c1 ea 1f             	shr    $0x1f,%edx
  801e63:	83 c4 10             	add    $0x10,%esp
  801e66:	84 d2                	test   %dl,%dl
  801e68:	74 17                	je     801e81 <ipc_send+0x4a>
  801e6a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e6d:	74 12                	je     801e81 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e6f:	50                   	push   %eax
  801e70:	68 92 26 80 00       	push   $0x802692
  801e75:	6a 47                	push   $0x47
  801e77:	68 a0 26 80 00       	push   $0x8026a0
  801e7c:	e8 0a f5 ff ff       	call   80138b <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e81:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e84:	75 07                	jne    801e8d <ipc_send+0x56>
			sys_yield();
  801e86:	e8 d4 e2 ff ff       	call   80015f <sys_yield>
  801e8b:	eb c6                	jmp    801e53 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e8d:	85 c0                	test   %eax,%eax
  801e8f:	75 c2                	jne    801e53 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e94:	5b                   	pop    %ebx
  801e95:	5e                   	pop    %esi
  801e96:	5f                   	pop    %edi
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    

00801e99 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e9f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ea4:	89 c2                	mov    %eax,%edx
  801ea6:	c1 e2 07             	shl    $0x7,%edx
  801ea9:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801eb0:	8b 52 5c             	mov    0x5c(%edx),%edx
  801eb3:	39 ca                	cmp    %ecx,%edx
  801eb5:	75 11                	jne    801ec8 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801eb7:	89 c2                	mov    %eax,%edx
  801eb9:	c1 e2 07             	shl    $0x7,%edx
  801ebc:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ec3:	8b 40 54             	mov    0x54(%eax),%eax
  801ec6:	eb 0f                	jmp    801ed7 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ec8:	83 c0 01             	add    $0x1,%eax
  801ecb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ed0:	75 d2                	jne    801ea4 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ed2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801edf:	89 d0                	mov    %edx,%eax
  801ee1:	c1 e8 16             	shr    $0x16,%eax
  801ee4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eeb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef0:	f6 c1 01             	test   $0x1,%cl
  801ef3:	74 1d                	je     801f12 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ef5:	c1 ea 0c             	shr    $0xc,%edx
  801ef8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801eff:	f6 c2 01             	test   $0x1,%dl
  801f02:	74 0e                	je     801f12 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f04:	c1 ea 0c             	shr    $0xc,%edx
  801f07:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f0e:	ef 
  801f0f:	0f b7 c0             	movzwl %ax,%eax
}
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    
  801f14:	66 90                	xchg   %ax,%ax
  801f16:	66 90                	xchg   %ax,%ax
  801f18:	66 90                	xchg   %ax,%ax
  801f1a:	66 90                	xchg   %ax,%ax
  801f1c:	66 90                	xchg   %ax,%ax
  801f1e:	66 90                	xchg   %ax,%ax

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
