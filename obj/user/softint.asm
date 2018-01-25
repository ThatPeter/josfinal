
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
  800045:	e8 f2 00 00 00       	call   80013c <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	89 c2                	mov    %eax,%edx
  800051:	c1 e2 07             	shl    $0x7,%edx
  800054:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x31>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 2a 00 00 00       	call   8000a4 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  80008a:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80008f:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  800091:	e8 a6 00 00 00       	call   80013c <sys_getenvid>
  800096:	83 ec 0c             	sub    $0xc,%esp
  800099:	50                   	push   %eax
  80009a:	e8 ec 02 00 00       	call   80038b <sys_thread_free>
}
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 b9 07 00 00       	call   800868 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 42 00 00 00       	call   8000fb <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cf:	89 c3                	mov    %eax,%ebx
  8000d1:	89 c7                	mov    %eax,%edi
  8000d3:	89 c6                	mov    %eax,%esi
  8000d5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ec:	89 d1                	mov    %edx,%ecx
  8000ee:	89 d3                	mov    %edx,%ebx
  8000f0:	89 d7                	mov    %edx,%edi
  8000f2:	89 d6                	mov    %edx,%esi
  8000f4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f6:	5b                   	pop    %ebx
  8000f7:	5e                   	pop    %esi
  8000f8:	5f                   	pop    %edi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	57                   	push   %edi
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800104:	b9 00 00 00 00       	mov    $0x0,%ecx
  800109:	b8 03 00 00 00       	mov    $0x3,%eax
  80010e:	8b 55 08             	mov    0x8(%ebp),%edx
  800111:	89 cb                	mov    %ecx,%ebx
  800113:	89 cf                	mov    %ecx,%edi
  800115:	89 ce                	mov    %ecx,%esi
  800117:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800119:	85 c0                	test   %eax,%eax
  80011b:	7e 17                	jle    800134 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	50                   	push   %eax
  800121:	6a 03                	push   $0x3
  800123:	68 aa 21 80 00       	push   $0x8021aa
  800128:	6a 23                	push   $0x23
  80012a:	68 c7 21 80 00       	push   $0x8021c7
  80012f:	e8 53 12 00 00       	call   801387 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800134:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 02 00 00 00       	mov    $0x2,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_yield>:

void
sys_yield(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016b:	89 d1                	mov    %edx,%ecx
  80016d:	89 d3                	mov    %edx,%ebx
  80016f:	89 d7                	mov    %edx,%edi
  800171:	89 d6                	mov    %edx,%esi
  800173:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
  800180:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800183:	be 00 00 00 00       	mov    $0x0,%esi
  800188:	b8 04 00 00 00       	mov    $0x4,%eax
  80018d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800190:	8b 55 08             	mov    0x8(%ebp),%edx
  800193:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800196:	89 f7                	mov    %esi,%edi
  800198:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80019a:	85 c0                	test   %eax,%eax
  80019c:	7e 17                	jle    8001b5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	50                   	push   %eax
  8001a2:	6a 04                	push   $0x4
  8001a4:	68 aa 21 80 00       	push   $0x8021aa
  8001a9:	6a 23                	push   $0x23
  8001ab:	68 c7 21 80 00       	push   $0x8021c7
  8001b0:	e8 d2 11 00 00       	call   801387 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b8:	5b                   	pop    %ebx
  8001b9:	5e                   	pop    %esi
  8001ba:	5f                   	pop    %edi
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    

008001bd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001da:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001dc:	85 c0                	test   %eax,%eax
  8001de:	7e 17                	jle    8001f7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e0:	83 ec 0c             	sub    $0xc,%esp
  8001e3:	50                   	push   %eax
  8001e4:	6a 05                	push   $0x5
  8001e6:	68 aa 21 80 00       	push   $0x8021aa
  8001eb:	6a 23                	push   $0x23
  8001ed:	68 c7 21 80 00       	push   $0x8021c7
  8001f2:	e8 90 11 00 00       	call   801387 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5f                   	pop    %edi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	57                   	push   %edi
  800203:	56                   	push   %esi
  800204:	53                   	push   %ebx
  800205:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800208:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020d:	b8 06 00 00 00       	mov    $0x6,%eax
  800212:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800215:	8b 55 08             	mov    0x8(%ebp),%edx
  800218:	89 df                	mov    %ebx,%edi
  80021a:	89 de                	mov    %ebx,%esi
  80021c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80021e:	85 c0                	test   %eax,%eax
  800220:	7e 17                	jle    800239 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800222:	83 ec 0c             	sub    $0xc,%esp
  800225:	50                   	push   %eax
  800226:	6a 06                	push   $0x6
  800228:	68 aa 21 80 00       	push   $0x8021aa
  80022d:	6a 23                	push   $0x23
  80022f:	68 c7 21 80 00       	push   $0x8021c7
  800234:	e8 4e 11 00 00       	call   801387 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023c:	5b                   	pop    %ebx
  80023d:	5e                   	pop    %esi
  80023e:	5f                   	pop    %edi
  80023f:	5d                   	pop    %ebp
  800240:	c3                   	ret    

00800241 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	57                   	push   %edi
  800245:	56                   	push   %esi
  800246:	53                   	push   %ebx
  800247:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024f:	b8 08 00 00 00       	mov    $0x8,%eax
  800254:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800257:	8b 55 08             	mov    0x8(%ebp),%edx
  80025a:	89 df                	mov    %ebx,%edi
  80025c:	89 de                	mov    %ebx,%esi
  80025e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800260:	85 c0                	test   %eax,%eax
  800262:	7e 17                	jle    80027b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	50                   	push   %eax
  800268:	6a 08                	push   $0x8
  80026a:	68 aa 21 80 00       	push   $0x8021aa
  80026f:	6a 23                	push   $0x23
  800271:	68 c7 21 80 00       	push   $0x8021c7
  800276:	e8 0c 11 00 00       	call   801387 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800291:	b8 09 00 00 00       	mov    $0x9,%eax
  800296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	89 df                	mov    %ebx,%edi
  80029e:	89 de                	mov    %ebx,%esi
  8002a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a2:	85 c0                	test   %eax,%eax
  8002a4:	7e 17                	jle    8002bd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a6:	83 ec 0c             	sub    $0xc,%esp
  8002a9:	50                   	push   %eax
  8002aa:	6a 09                	push   $0x9
  8002ac:	68 aa 21 80 00       	push   $0x8021aa
  8002b1:	6a 23                	push   $0x23
  8002b3:	68 c7 21 80 00       	push   $0x8021c7
  8002b8:	e8 ca 10 00 00       	call   801387 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c0:	5b                   	pop    %ebx
  8002c1:	5e                   	pop    %esi
  8002c2:	5f                   	pop    %edi
  8002c3:	5d                   	pop    %ebp
  8002c4:	c3                   	ret    

008002c5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002db:	8b 55 08             	mov    0x8(%ebp),%edx
  8002de:	89 df                	mov    %ebx,%edi
  8002e0:	89 de                	mov    %ebx,%esi
  8002e2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	7e 17                	jle    8002ff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	50                   	push   %eax
  8002ec:	6a 0a                	push   $0xa
  8002ee:	68 aa 21 80 00       	push   $0x8021aa
  8002f3:	6a 23                	push   $0x23
  8002f5:	68 c7 21 80 00       	push   $0x8021c7
  8002fa:	e8 88 10 00 00       	call   801387 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800302:	5b                   	pop    %ebx
  800303:	5e                   	pop    %esi
  800304:	5f                   	pop    %edi
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	57                   	push   %edi
  80030b:	56                   	push   %esi
  80030c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030d:	be 00 00 00 00       	mov    $0x0,%esi
  800312:	b8 0c 00 00 00       	mov    $0xc,%eax
  800317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031a:	8b 55 08             	mov    0x8(%ebp),%edx
  80031d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800320:	8b 7d 14             	mov    0x14(%ebp),%edi
  800323:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800325:	5b                   	pop    %ebx
  800326:	5e                   	pop    %esi
  800327:	5f                   	pop    %edi
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	57                   	push   %edi
  80032e:	56                   	push   %esi
  80032f:	53                   	push   %ebx
  800330:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800333:	b9 00 00 00 00       	mov    $0x0,%ecx
  800338:	b8 0d 00 00 00       	mov    $0xd,%eax
  80033d:	8b 55 08             	mov    0x8(%ebp),%edx
  800340:	89 cb                	mov    %ecx,%ebx
  800342:	89 cf                	mov    %ecx,%edi
  800344:	89 ce                	mov    %ecx,%esi
  800346:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800348:	85 c0                	test   %eax,%eax
  80034a:	7e 17                	jle    800363 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034c:	83 ec 0c             	sub    $0xc,%esp
  80034f:	50                   	push   %eax
  800350:	6a 0d                	push   $0xd
  800352:	68 aa 21 80 00       	push   $0x8021aa
  800357:	6a 23                	push   $0x23
  800359:	68 c7 21 80 00       	push   $0x8021c7
  80035e:	e8 24 10 00 00       	call   801387 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800363:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800366:	5b                   	pop    %ebx
  800367:	5e                   	pop    %esi
  800368:	5f                   	pop    %edi
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	57                   	push   %edi
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800371:	b9 00 00 00 00       	mov    $0x0,%ecx
  800376:	b8 0e 00 00 00       	mov    $0xe,%eax
  80037b:	8b 55 08             	mov    0x8(%ebp),%edx
  80037e:	89 cb                	mov    %ecx,%ebx
  800380:	89 cf                	mov    %ecx,%edi
  800382:	89 ce                	mov    %ecx,%esi
  800384:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800386:	5b                   	pop    %ebx
  800387:	5e                   	pop    %esi
  800388:	5f                   	pop    %edi
  800389:	5d                   	pop    %ebp
  80038a:	c3                   	ret    

0080038b <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	57                   	push   %edi
  80038f:	56                   	push   %esi
  800390:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800391:	b9 00 00 00 00       	mov    $0x0,%ecx
  800396:	b8 0f 00 00 00       	mov    $0xf,%eax
  80039b:	8b 55 08             	mov    0x8(%ebp),%edx
  80039e:	89 cb                	mov    %ecx,%ebx
  8003a0:	89 cf                	mov    %ecx,%edi
  8003a2:	89 ce                	mov    %ecx,%esi
  8003a4:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003a6:	5b                   	pop    %ebx
  8003a7:	5e                   	pop    %esi
  8003a8:	5f                   	pop    %edi
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	53                   	push   %ebx
  8003af:	83 ec 04             	sub    $0x4,%esp
  8003b2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003b5:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003b7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003bb:	74 11                	je     8003ce <pgfault+0x23>
  8003bd:	89 d8                	mov    %ebx,%eax
  8003bf:	c1 e8 0c             	shr    $0xc,%eax
  8003c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003c9:	f6 c4 08             	test   $0x8,%ah
  8003cc:	75 14                	jne    8003e2 <pgfault+0x37>
		panic("faulting access");
  8003ce:	83 ec 04             	sub    $0x4,%esp
  8003d1:	68 d5 21 80 00       	push   $0x8021d5
  8003d6:	6a 1e                	push   $0x1e
  8003d8:	68 e5 21 80 00       	push   $0x8021e5
  8003dd:	e8 a5 0f 00 00       	call   801387 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003e2:	83 ec 04             	sub    $0x4,%esp
  8003e5:	6a 07                	push   $0x7
  8003e7:	68 00 f0 7f 00       	push   $0x7ff000
  8003ec:	6a 00                	push   $0x0
  8003ee:	e8 87 fd ff ff       	call   80017a <sys_page_alloc>
	if (r < 0) {
  8003f3:	83 c4 10             	add    $0x10,%esp
  8003f6:	85 c0                	test   %eax,%eax
  8003f8:	79 12                	jns    80040c <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8003fa:	50                   	push   %eax
  8003fb:	68 f0 21 80 00       	push   $0x8021f0
  800400:	6a 2c                	push   $0x2c
  800402:	68 e5 21 80 00       	push   $0x8021e5
  800407:	e8 7b 0f 00 00       	call   801387 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80040c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800412:	83 ec 04             	sub    $0x4,%esp
  800415:	68 00 10 00 00       	push   $0x1000
  80041a:	53                   	push   %ebx
  80041b:	68 00 f0 7f 00       	push   $0x7ff000
  800420:	e8 ba 17 00 00       	call   801bdf <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800425:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80042c:	53                   	push   %ebx
  80042d:	6a 00                	push   $0x0
  80042f:	68 00 f0 7f 00       	push   $0x7ff000
  800434:	6a 00                	push   $0x0
  800436:	e8 82 fd ff ff       	call   8001bd <sys_page_map>
	if (r < 0) {
  80043b:	83 c4 20             	add    $0x20,%esp
  80043e:	85 c0                	test   %eax,%eax
  800440:	79 12                	jns    800454 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800442:	50                   	push   %eax
  800443:	68 f0 21 80 00       	push   $0x8021f0
  800448:	6a 33                	push   $0x33
  80044a:	68 e5 21 80 00       	push   $0x8021e5
  80044f:	e8 33 0f 00 00       	call   801387 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	68 00 f0 7f 00       	push   $0x7ff000
  80045c:	6a 00                	push   $0x0
  80045e:	e8 9c fd ff ff       	call   8001ff <sys_page_unmap>
	if (r < 0) {
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	85 c0                	test   %eax,%eax
  800468:	79 12                	jns    80047c <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  80046a:	50                   	push   %eax
  80046b:	68 f0 21 80 00       	push   $0x8021f0
  800470:	6a 37                	push   $0x37
  800472:	68 e5 21 80 00       	push   $0x8021e5
  800477:	e8 0b 0f 00 00       	call   801387 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80047c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80047f:	c9                   	leave  
  800480:	c3                   	ret    

00800481 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800481:	55                   	push   %ebp
  800482:	89 e5                	mov    %esp,%ebp
  800484:	57                   	push   %edi
  800485:	56                   	push   %esi
  800486:	53                   	push   %ebx
  800487:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  80048a:	68 ab 03 80 00       	push   $0x8003ab
  80048f:	e8 98 18 00 00       	call   801d2c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800494:	b8 07 00 00 00       	mov    $0x7,%eax
  800499:	cd 30                	int    $0x30
  80049b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	85 c0                	test   %eax,%eax
  8004a3:	79 17                	jns    8004bc <fork+0x3b>
		panic("fork fault %e");
  8004a5:	83 ec 04             	sub    $0x4,%esp
  8004a8:	68 09 22 80 00       	push   $0x802209
  8004ad:	68 84 00 00 00       	push   $0x84
  8004b2:	68 e5 21 80 00       	push   $0x8021e5
  8004b7:	e8 cb 0e 00 00       	call   801387 <_panic>
  8004bc:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004be:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c2:	75 25                	jne    8004e9 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004c4:	e8 73 fc ff ff       	call   80013c <sys_getenvid>
  8004c9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004ce:	89 c2                	mov    %eax,%edx
  8004d0:	c1 e2 07             	shl    $0x7,%edx
  8004d3:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  8004da:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004df:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e4:	e9 61 01 00 00       	jmp    80064a <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004e9:	83 ec 04             	sub    $0x4,%esp
  8004ec:	6a 07                	push   $0x7
  8004ee:	68 00 f0 bf ee       	push   $0xeebff000
  8004f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004f6:	e8 7f fc ff ff       	call   80017a <sys_page_alloc>
  8004fb:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8004fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800503:	89 d8                	mov    %ebx,%eax
  800505:	c1 e8 16             	shr    $0x16,%eax
  800508:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80050f:	a8 01                	test   $0x1,%al
  800511:	0f 84 fc 00 00 00    	je     800613 <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800517:	89 d8                	mov    %ebx,%eax
  800519:	c1 e8 0c             	shr    $0xc,%eax
  80051c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800523:	f6 c2 01             	test   $0x1,%dl
  800526:	0f 84 e7 00 00 00    	je     800613 <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  80052c:	89 c6                	mov    %eax,%esi
  80052e:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  800531:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800538:	f6 c6 04             	test   $0x4,%dh
  80053b:	74 39                	je     800576 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80053d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800544:	83 ec 0c             	sub    $0xc,%esp
  800547:	25 07 0e 00 00       	and    $0xe07,%eax
  80054c:	50                   	push   %eax
  80054d:	56                   	push   %esi
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	6a 00                	push   $0x0
  800552:	e8 66 fc ff ff       	call   8001bd <sys_page_map>
		if (r < 0) {
  800557:	83 c4 20             	add    $0x20,%esp
  80055a:	85 c0                	test   %eax,%eax
  80055c:	0f 89 b1 00 00 00    	jns    800613 <fork+0x192>
		    	panic("sys page map fault %e");
  800562:	83 ec 04             	sub    $0x4,%esp
  800565:	68 17 22 80 00       	push   $0x802217
  80056a:	6a 54                	push   $0x54
  80056c:	68 e5 21 80 00       	push   $0x8021e5
  800571:	e8 11 0e 00 00       	call   801387 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800576:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80057d:	f6 c2 02             	test   $0x2,%dl
  800580:	75 0c                	jne    80058e <fork+0x10d>
  800582:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800589:	f6 c4 08             	test   $0x8,%ah
  80058c:	74 5b                	je     8005e9 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80058e:	83 ec 0c             	sub    $0xc,%esp
  800591:	68 05 08 00 00       	push   $0x805
  800596:	56                   	push   %esi
  800597:	57                   	push   %edi
  800598:	56                   	push   %esi
  800599:	6a 00                	push   $0x0
  80059b:	e8 1d fc ff ff       	call   8001bd <sys_page_map>
		if (r < 0) {
  8005a0:	83 c4 20             	add    $0x20,%esp
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	79 14                	jns    8005bb <fork+0x13a>
		    	panic("sys page map fault %e");
  8005a7:	83 ec 04             	sub    $0x4,%esp
  8005aa:	68 17 22 80 00       	push   $0x802217
  8005af:	6a 5b                	push   $0x5b
  8005b1:	68 e5 21 80 00       	push   $0x8021e5
  8005b6:	e8 cc 0d 00 00       	call   801387 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005bb:	83 ec 0c             	sub    $0xc,%esp
  8005be:	68 05 08 00 00       	push   $0x805
  8005c3:	56                   	push   %esi
  8005c4:	6a 00                	push   $0x0
  8005c6:	56                   	push   %esi
  8005c7:	6a 00                	push   $0x0
  8005c9:	e8 ef fb ff ff       	call   8001bd <sys_page_map>
		if (r < 0) {
  8005ce:	83 c4 20             	add    $0x20,%esp
  8005d1:	85 c0                	test   %eax,%eax
  8005d3:	79 3e                	jns    800613 <fork+0x192>
		    	panic("sys page map fault %e");
  8005d5:	83 ec 04             	sub    $0x4,%esp
  8005d8:	68 17 22 80 00       	push   $0x802217
  8005dd:	6a 5f                	push   $0x5f
  8005df:	68 e5 21 80 00       	push   $0x8021e5
  8005e4:	e8 9e 0d 00 00       	call   801387 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005e9:	83 ec 0c             	sub    $0xc,%esp
  8005ec:	6a 05                	push   $0x5
  8005ee:	56                   	push   %esi
  8005ef:	57                   	push   %edi
  8005f0:	56                   	push   %esi
  8005f1:	6a 00                	push   $0x0
  8005f3:	e8 c5 fb ff ff       	call   8001bd <sys_page_map>
		if (r < 0) {
  8005f8:	83 c4 20             	add    $0x20,%esp
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	79 14                	jns    800613 <fork+0x192>
		    	panic("sys page map fault %e");
  8005ff:	83 ec 04             	sub    $0x4,%esp
  800602:	68 17 22 80 00       	push   $0x802217
  800607:	6a 64                	push   $0x64
  800609:	68 e5 21 80 00       	push   $0x8021e5
  80060e:	e8 74 0d 00 00       	call   801387 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800613:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800619:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80061f:	0f 85 de fe ff ff    	jne    800503 <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800625:	a1 04 40 80 00       	mov    0x804004,%eax
  80062a:	8b 40 70             	mov    0x70(%eax),%eax
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	50                   	push   %eax
  800631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800634:	57                   	push   %edi
  800635:	e8 8b fc ff ff       	call   8002c5 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80063a:	83 c4 08             	add    $0x8,%esp
  80063d:	6a 02                	push   $0x2
  80063f:	57                   	push   %edi
  800640:	e8 fc fb ff ff       	call   800241 <sys_env_set_status>
	
	return envid;
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80064a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <sfork>:

envid_t
sfork(void)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800655:	b8 00 00 00 00       	mov    $0x0,%eax
  80065a:	5d                   	pop    %ebp
  80065b:	c3                   	ret    

0080065c <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80065c:	55                   	push   %ebp
  80065d:	89 e5                	mov    %esp,%ebp
  80065f:	56                   	push   %esi
  800660:	53                   	push   %ebx
  800661:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800664:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	68 30 22 80 00       	push   $0x802230
  800673:	e8 e8 0d 00 00       	call   801460 <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800678:	c7 04 24 84 00 80 00 	movl   $0x800084,(%esp)
  80067f:	e8 e7 fc ff ff       	call   80036b <sys_thread_create>
  800684:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800686:	83 c4 08             	add    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	68 30 22 80 00       	push   $0x802230
  80068f:	e8 cc 0d 00 00       	call   801460 <cprintf>
	return id;
	//return 0;
}
  800694:	89 f0                	mov    %esi,%eax
  800696:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800699:	5b                   	pop    %ebx
  80069a:	5e                   	pop    %esi
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	05 00 00 00 30       	add    $0x30000000,%eax
  8006a8:	c1 e8 0c             	shr    $0xc,%eax
}
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	05 00 00 00 30       	add    $0x30000000,%eax
  8006b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006bd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006c2:	5d                   	pop    %ebp
  8006c3:	c3                   	ret    

008006c4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ca:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	c1 ea 16             	shr    $0x16,%edx
  8006d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8006db:	f6 c2 01             	test   $0x1,%dl
  8006de:	74 11                	je     8006f1 <fd_alloc+0x2d>
  8006e0:	89 c2                	mov    %eax,%edx
  8006e2:	c1 ea 0c             	shr    $0xc,%edx
  8006e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8006ec:	f6 c2 01             	test   $0x1,%dl
  8006ef:	75 09                	jne    8006fa <fd_alloc+0x36>
			*fd_store = fd;
  8006f1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	eb 17                	jmp    800711 <fd_alloc+0x4d>
  8006fa:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8006ff:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800704:	75 c9                	jne    8006cf <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800706:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80070c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800711:	5d                   	pop    %ebp
  800712:	c3                   	ret    

00800713 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800713:	55                   	push   %ebp
  800714:	89 e5                	mov    %esp,%ebp
  800716:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800719:	83 f8 1f             	cmp    $0x1f,%eax
  80071c:	77 36                	ja     800754 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80071e:	c1 e0 0c             	shl    $0xc,%eax
  800721:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800726:	89 c2                	mov    %eax,%edx
  800728:	c1 ea 16             	shr    $0x16,%edx
  80072b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800732:	f6 c2 01             	test   $0x1,%dl
  800735:	74 24                	je     80075b <fd_lookup+0x48>
  800737:	89 c2                	mov    %eax,%edx
  800739:	c1 ea 0c             	shr    $0xc,%edx
  80073c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800743:	f6 c2 01             	test   $0x1,%dl
  800746:	74 1a                	je     800762 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800748:	8b 55 0c             	mov    0xc(%ebp),%edx
  80074b:	89 02                	mov    %eax,(%edx)
	return 0;
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
  800752:	eb 13                	jmp    800767 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800754:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800759:	eb 0c                	jmp    800767 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800760:	eb 05                	jmp    800767 <fd_lookup+0x54>
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800767:	5d                   	pop    %ebp
  800768:	c3                   	ret    

00800769 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800772:	ba d0 22 80 00       	mov    $0x8022d0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800777:	eb 13                	jmp    80078c <dev_lookup+0x23>
  800779:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80077c:	39 08                	cmp    %ecx,(%eax)
  80077e:	75 0c                	jne    80078c <dev_lookup+0x23>
			*dev = devtab[i];
  800780:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800783:	89 01                	mov    %eax,(%ecx)
			return 0;
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
  80078a:	eb 2e                	jmp    8007ba <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80078c:	8b 02                	mov    (%edx),%eax
  80078e:	85 c0                	test   %eax,%eax
  800790:	75 e7                	jne    800779 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800792:	a1 04 40 80 00       	mov    0x804004,%eax
  800797:	8b 40 54             	mov    0x54(%eax),%eax
  80079a:	83 ec 04             	sub    $0x4,%esp
  80079d:	51                   	push   %ecx
  80079e:	50                   	push   %eax
  80079f:	68 54 22 80 00       	push   $0x802254
  8007a4:	e8 b7 0c 00 00       	call   801460 <cprintf>
	*dev = 0;
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	56                   	push   %esi
  8007c0:	53                   	push   %ebx
  8007c1:	83 ec 10             	sub    $0x10,%esp
  8007c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007cd:	50                   	push   %eax
  8007ce:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007d4:	c1 e8 0c             	shr    $0xc,%eax
  8007d7:	50                   	push   %eax
  8007d8:	e8 36 ff ff ff       	call   800713 <fd_lookup>
  8007dd:	83 c4 08             	add    $0x8,%esp
  8007e0:	85 c0                	test   %eax,%eax
  8007e2:	78 05                	js     8007e9 <fd_close+0x2d>
	    || fd != fd2)
  8007e4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8007e7:	74 0c                	je     8007f5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8007e9:	84 db                	test   %bl,%bl
  8007eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f0:	0f 44 c2             	cmove  %edx,%eax
  8007f3:	eb 41                	jmp    800836 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fb:	50                   	push   %eax
  8007fc:	ff 36                	pushl  (%esi)
  8007fe:	e8 66 ff ff ff       	call   800769 <dev_lookup>
  800803:	89 c3                	mov    %eax,%ebx
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	85 c0                	test   %eax,%eax
  80080a:	78 1a                	js     800826 <fd_close+0x6a>
		if (dev->dev_close)
  80080c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800812:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800817:	85 c0                	test   %eax,%eax
  800819:	74 0b                	je     800826 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80081b:	83 ec 0c             	sub    $0xc,%esp
  80081e:	56                   	push   %esi
  80081f:	ff d0                	call   *%eax
  800821:	89 c3                	mov    %eax,%ebx
  800823:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	56                   	push   %esi
  80082a:	6a 00                	push   $0x0
  80082c:	e8 ce f9 ff ff       	call   8001ff <sys_page_unmap>
	return r;
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	89 d8                	mov    %ebx,%eax
}
  800836:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800843:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800846:	50                   	push   %eax
  800847:	ff 75 08             	pushl  0x8(%ebp)
  80084a:	e8 c4 fe ff ff       	call   800713 <fd_lookup>
  80084f:	83 c4 08             	add    $0x8,%esp
  800852:	85 c0                	test   %eax,%eax
  800854:	78 10                	js     800866 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800856:	83 ec 08             	sub    $0x8,%esp
  800859:	6a 01                	push   $0x1
  80085b:	ff 75 f4             	pushl  -0xc(%ebp)
  80085e:	e8 59 ff ff ff       	call   8007bc <fd_close>
  800863:	83 c4 10             	add    $0x10,%esp
}
  800866:	c9                   	leave  
  800867:	c3                   	ret    

00800868 <close_all>:

void
close_all(void)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80086f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800874:	83 ec 0c             	sub    $0xc,%esp
  800877:	53                   	push   %ebx
  800878:	e8 c0 ff ff ff       	call   80083d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80087d:	83 c3 01             	add    $0x1,%ebx
  800880:	83 c4 10             	add    $0x10,%esp
  800883:	83 fb 20             	cmp    $0x20,%ebx
  800886:	75 ec                	jne    800874 <close_all+0xc>
		close(i);
}
  800888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    

0080088d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	57                   	push   %edi
  800891:	56                   	push   %esi
  800892:	53                   	push   %ebx
  800893:	83 ec 2c             	sub    $0x2c,%esp
  800896:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800899:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80089c:	50                   	push   %eax
  80089d:	ff 75 08             	pushl  0x8(%ebp)
  8008a0:	e8 6e fe ff ff       	call   800713 <fd_lookup>
  8008a5:	83 c4 08             	add    $0x8,%esp
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	0f 88 c1 00 00 00    	js     800971 <dup+0xe4>
		return r;
	close(newfdnum);
  8008b0:	83 ec 0c             	sub    $0xc,%esp
  8008b3:	56                   	push   %esi
  8008b4:	e8 84 ff ff ff       	call   80083d <close>

	newfd = INDEX2FD(newfdnum);
  8008b9:	89 f3                	mov    %esi,%ebx
  8008bb:	c1 e3 0c             	shl    $0xc,%ebx
  8008be:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008c4:	83 c4 04             	add    $0x4,%esp
  8008c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008ca:	e8 de fd ff ff       	call   8006ad <fd2data>
  8008cf:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008d1:	89 1c 24             	mov    %ebx,(%esp)
  8008d4:	e8 d4 fd ff ff       	call   8006ad <fd2data>
  8008d9:	83 c4 10             	add    $0x10,%esp
  8008dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8008df:	89 f8                	mov    %edi,%eax
  8008e1:	c1 e8 16             	shr    $0x16,%eax
  8008e4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8008eb:	a8 01                	test   $0x1,%al
  8008ed:	74 37                	je     800926 <dup+0x99>
  8008ef:	89 f8                	mov    %edi,%eax
  8008f1:	c1 e8 0c             	shr    $0xc,%eax
  8008f4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8008fb:	f6 c2 01             	test   $0x1,%dl
  8008fe:	74 26                	je     800926 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800900:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800907:	83 ec 0c             	sub    $0xc,%esp
  80090a:	25 07 0e 00 00       	and    $0xe07,%eax
  80090f:	50                   	push   %eax
  800910:	ff 75 d4             	pushl  -0x2c(%ebp)
  800913:	6a 00                	push   $0x0
  800915:	57                   	push   %edi
  800916:	6a 00                	push   $0x0
  800918:	e8 a0 f8 ff ff       	call   8001bd <sys_page_map>
  80091d:	89 c7                	mov    %eax,%edi
  80091f:	83 c4 20             	add    $0x20,%esp
  800922:	85 c0                	test   %eax,%eax
  800924:	78 2e                	js     800954 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800926:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800929:	89 d0                	mov    %edx,%eax
  80092b:	c1 e8 0c             	shr    $0xc,%eax
  80092e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800935:	83 ec 0c             	sub    $0xc,%esp
  800938:	25 07 0e 00 00       	and    $0xe07,%eax
  80093d:	50                   	push   %eax
  80093e:	53                   	push   %ebx
  80093f:	6a 00                	push   $0x0
  800941:	52                   	push   %edx
  800942:	6a 00                	push   $0x0
  800944:	e8 74 f8 ff ff       	call   8001bd <sys_page_map>
  800949:	89 c7                	mov    %eax,%edi
  80094b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80094e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800950:	85 ff                	test   %edi,%edi
  800952:	79 1d                	jns    800971 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	6a 00                	push   $0x0
  80095a:	e8 a0 f8 ff ff       	call   8001ff <sys_page_unmap>
	sys_page_unmap(0, nva);
  80095f:	83 c4 08             	add    $0x8,%esp
  800962:	ff 75 d4             	pushl  -0x2c(%ebp)
  800965:	6a 00                	push   $0x0
  800967:	e8 93 f8 ff ff       	call   8001ff <sys_page_unmap>
	return r;
  80096c:	83 c4 10             	add    $0x10,%esp
  80096f:	89 f8                	mov    %edi,%eax
}
  800971:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	53                   	push   %ebx
  80097d:	83 ec 14             	sub    $0x14,%esp
  800980:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800983:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800986:	50                   	push   %eax
  800987:	53                   	push   %ebx
  800988:	e8 86 fd ff ff       	call   800713 <fd_lookup>
  80098d:	83 c4 08             	add    $0x8,%esp
  800990:	89 c2                	mov    %eax,%edx
  800992:	85 c0                	test   %eax,%eax
  800994:	78 6d                	js     800a03 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800996:	83 ec 08             	sub    $0x8,%esp
  800999:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80099c:	50                   	push   %eax
  80099d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a0:	ff 30                	pushl  (%eax)
  8009a2:	e8 c2 fd ff ff       	call   800769 <dev_lookup>
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	85 c0                	test   %eax,%eax
  8009ac:	78 4c                	js     8009fa <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009b1:	8b 42 08             	mov    0x8(%edx),%eax
  8009b4:	83 e0 03             	and    $0x3,%eax
  8009b7:	83 f8 01             	cmp    $0x1,%eax
  8009ba:	75 21                	jne    8009dd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c1:	8b 40 54             	mov    0x54(%eax),%eax
  8009c4:	83 ec 04             	sub    $0x4,%esp
  8009c7:	53                   	push   %ebx
  8009c8:	50                   	push   %eax
  8009c9:	68 95 22 80 00       	push   $0x802295
  8009ce:	e8 8d 0a 00 00       	call   801460 <cprintf>
		return -E_INVAL;
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8009db:	eb 26                	jmp    800a03 <read+0x8a>
	}
	if (!dev->dev_read)
  8009dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009e0:	8b 40 08             	mov    0x8(%eax),%eax
  8009e3:	85 c0                	test   %eax,%eax
  8009e5:	74 17                	je     8009fe <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  8009e7:	83 ec 04             	sub    $0x4,%esp
  8009ea:	ff 75 10             	pushl  0x10(%ebp)
  8009ed:	ff 75 0c             	pushl  0xc(%ebp)
  8009f0:	52                   	push   %edx
  8009f1:	ff d0                	call   *%eax
  8009f3:	89 c2                	mov    %eax,%edx
  8009f5:	83 c4 10             	add    $0x10,%esp
  8009f8:	eb 09                	jmp    800a03 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	eb 05                	jmp    800a03 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8009fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a03:	89 d0                	mov    %edx,%eax
  800a05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	57                   	push   %edi
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	83 ec 0c             	sub    $0xc,%esp
  800a13:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a16:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a1e:	eb 21                	jmp    800a41 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a20:	83 ec 04             	sub    $0x4,%esp
  800a23:	89 f0                	mov    %esi,%eax
  800a25:	29 d8                	sub    %ebx,%eax
  800a27:	50                   	push   %eax
  800a28:	89 d8                	mov    %ebx,%eax
  800a2a:	03 45 0c             	add    0xc(%ebp),%eax
  800a2d:	50                   	push   %eax
  800a2e:	57                   	push   %edi
  800a2f:	e8 45 ff ff ff       	call   800979 <read>
		if (m < 0)
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	85 c0                	test   %eax,%eax
  800a39:	78 10                	js     800a4b <readn+0x41>
			return m;
		if (m == 0)
  800a3b:	85 c0                	test   %eax,%eax
  800a3d:	74 0a                	je     800a49 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a3f:	01 c3                	add    %eax,%ebx
  800a41:	39 f3                	cmp    %esi,%ebx
  800a43:	72 db                	jb     800a20 <readn+0x16>
  800a45:	89 d8                	mov    %ebx,%eax
  800a47:	eb 02                	jmp    800a4b <readn+0x41>
  800a49:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	53                   	push   %ebx
  800a57:	83 ec 14             	sub    $0x14,%esp
  800a5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a60:	50                   	push   %eax
  800a61:	53                   	push   %ebx
  800a62:	e8 ac fc ff ff       	call   800713 <fd_lookup>
  800a67:	83 c4 08             	add    $0x8,%esp
  800a6a:	89 c2                	mov    %eax,%edx
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	78 68                	js     800ad8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a70:	83 ec 08             	sub    $0x8,%esp
  800a73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a76:	50                   	push   %eax
  800a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a7a:	ff 30                	pushl  (%eax)
  800a7c:	e8 e8 fc ff ff       	call   800769 <dev_lookup>
  800a81:	83 c4 10             	add    $0x10,%esp
  800a84:	85 c0                	test   %eax,%eax
  800a86:	78 47                	js     800acf <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800a88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800a8f:	75 21                	jne    800ab2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800a91:	a1 04 40 80 00       	mov    0x804004,%eax
  800a96:	8b 40 54             	mov    0x54(%eax),%eax
  800a99:	83 ec 04             	sub    $0x4,%esp
  800a9c:	53                   	push   %ebx
  800a9d:	50                   	push   %eax
  800a9e:	68 b1 22 80 00       	push   $0x8022b1
  800aa3:	e8 b8 09 00 00       	call   801460 <cprintf>
		return -E_INVAL;
  800aa8:	83 c4 10             	add    $0x10,%esp
  800aab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ab0:	eb 26                	jmp    800ad8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ab2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ab5:	8b 52 0c             	mov    0xc(%edx),%edx
  800ab8:	85 d2                	test   %edx,%edx
  800aba:	74 17                	je     800ad3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800abc:	83 ec 04             	sub    $0x4,%esp
  800abf:	ff 75 10             	pushl  0x10(%ebp)
  800ac2:	ff 75 0c             	pushl  0xc(%ebp)
  800ac5:	50                   	push   %eax
  800ac6:	ff d2                	call   *%edx
  800ac8:	89 c2                	mov    %eax,%edx
  800aca:	83 c4 10             	add    $0x10,%esp
  800acd:	eb 09                	jmp    800ad8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800acf:	89 c2                	mov    %eax,%edx
  800ad1:	eb 05                	jmp    800ad8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ad3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800ad8:	89 d0                	mov    %edx,%eax
  800ada:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800add:	c9                   	leave  
  800ade:	c3                   	ret    

00800adf <seek>:

int
seek(int fdnum, off_t offset)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ae5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800ae8:	50                   	push   %eax
  800ae9:	ff 75 08             	pushl  0x8(%ebp)
  800aec:	e8 22 fc ff ff       	call   800713 <fd_lookup>
  800af1:	83 c4 08             	add    $0x8,%esp
  800af4:	85 c0                	test   %eax,%eax
  800af6:	78 0e                	js     800b06 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800af8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800afb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afe:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b06:	c9                   	leave  
  800b07:	c3                   	ret    

00800b08 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	53                   	push   %ebx
  800b0c:	83 ec 14             	sub    $0x14,%esp
  800b0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b12:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b15:	50                   	push   %eax
  800b16:	53                   	push   %ebx
  800b17:	e8 f7 fb ff ff       	call   800713 <fd_lookup>
  800b1c:	83 c4 08             	add    $0x8,%esp
  800b1f:	89 c2                	mov    %eax,%edx
  800b21:	85 c0                	test   %eax,%eax
  800b23:	78 65                	js     800b8a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b2b:	50                   	push   %eax
  800b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b2f:	ff 30                	pushl  (%eax)
  800b31:	e8 33 fc ff ff       	call   800769 <dev_lookup>
  800b36:	83 c4 10             	add    $0x10,%esp
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	78 44                	js     800b81 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b40:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b44:	75 21                	jne    800b67 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b46:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b4b:	8b 40 54             	mov    0x54(%eax),%eax
  800b4e:	83 ec 04             	sub    $0x4,%esp
  800b51:	53                   	push   %ebx
  800b52:	50                   	push   %eax
  800b53:	68 74 22 80 00       	push   $0x802274
  800b58:	e8 03 09 00 00       	call   801460 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b5d:	83 c4 10             	add    $0x10,%esp
  800b60:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b65:	eb 23                	jmp    800b8a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b6a:	8b 52 18             	mov    0x18(%edx),%edx
  800b6d:	85 d2                	test   %edx,%edx
  800b6f:	74 14                	je     800b85 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b71:	83 ec 08             	sub    $0x8,%esp
  800b74:	ff 75 0c             	pushl  0xc(%ebp)
  800b77:	50                   	push   %eax
  800b78:	ff d2                	call   *%edx
  800b7a:	89 c2                	mov    %eax,%edx
  800b7c:	83 c4 10             	add    $0x10,%esp
  800b7f:	eb 09                	jmp    800b8a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b81:	89 c2                	mov    %eax,%edx
  800b83:	eb 05                	jmp    800b8a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800b85:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800b8a:	89 d0                	mov    %edx,%eax
  800b8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	53                   	push   %ebx
  800b95:	83 ec 14             	sub    $0x14,%esp
  800b98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b9e:	50                   	push   %eax
  800b9f:	ff 75 08             	pushl  0x8(%ebp)
  800ba2:	e8 6c fb ff ff       	call   800713 <fd_lookup>
  800ba7:	83 c4 08             	add    $0x8,%esp
  800baa:	89 c2                	mov    %eax,%edx
  800bac:	85 c0                	test   %eax,%eax
  800bae:	78 58                	js     800c08 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bb0:	83 ec 08             	sub    $0x8,%esp
  800bb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bb6:	50                   	push   %eax
  800bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bba:	ff 30                	pushl  (%eax)
  800bbc:	e8 a8 fb ff ff       	call   800769 <dev_lookup>
  800bc1:	83 c4 10             	add    $0x10,%esp
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	78 37                	js     800bff <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bcb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bcf:	74 32                	je     800c03 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bd1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800bd4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800bdb:	00 00 00 
	stat->st_isdir = 0;
  800bde:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800be5:	00 00 00 
	stat->st_dev = dev;
  800be8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800bee:	83 ec 08             	sub    $0x8,%esp
  800bf1:	53                   	push   %ebx
  800bf2:	ff 75 f0             	pushl  -0x10(%ebp)
  800bf5:	ff 50 14             	call   *0x14(%eax)
  800bf8:	89 c2                	mov    %eax,%edx
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	eb 09                	jmp    800c08 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bff:	89 c2                	mov    %eax,%edx
  800c01:	eb 05                	jmp    800c08 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c03:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c08:	89 d0                	mov    %edx,%eax
  800c0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c14:	83 ec 08             	sub    $0x8,%esp
  800c17:	6a 00                	push   $0x0
  800c19:	ff 75 08             	pushl  0x8(%ebp)
  800c1c:	e8 e3 01 00 00       	call   800e04 <open>
  800c21:	89 c3                	mov    %eax,%ebx
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	85 c0                	test   %eax,%eax
  800c28:	78 1b                	js     800c45 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c2a:	83 ec 08             	sub    $0x8,%esp
  800c2d:	ff 75 0c             	pushl  0xc(%ebp)
  800c30:	50                   	push   %eax
  800c31:	e8 5b ff ff ff       	call   800b91 <fstat>
  800c36:	89 c6                	mov    %eax,%esi
	close(fd);
  800c38:	89 1c 24             	mov    %ebx,(%esp)
  800c3b:	e8 fd fb ff ff       	call   80083d <close>
	return r;
  800c40:	83 c4 10             	add    $0x10,%esp
  800c43:	89 f0                	mov    %esi,%eax
}
  800c45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	89 c6                	mov    %eax,%esi
  800c53:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c55:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c5c:	75 12                	jne    800c70 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	6a 01                	push   $0x1
  800c63:	e8 2d 12 00 00       	call   801e95 <ipc_find_env>
  800c68:	a3 00 40 80 00       	mov    %eax,0x804000
  800c6d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c70:	6a 07                	push   $0x7
  800c72:	68 00 50 80 00       	push   $0x805000
  800c77:	56                   	push   %esi
  800c78:	ff 35 00 40 80 00    	pushl  0x804000
  800c7e:	e8 b0 11 00 00       	call   801e33 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c83:	83 c4 0c             	add    $0xc,%esp
  800c86:	6a 00                	push   $0x0
  800c88:	53                   	push   %ebx
  800c89:	6a 00                	push   $0x0
  800c8b:	e8 2b 11 00 00       	call   801dbb <ipc_recv>
}
  800c90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	8b 40 0c             	mov    0xc(%eax),%eax
  800ca3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cab:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb5:	b8 02 00 00 00       	mov    $0x2,%eax
  800cba:	e8 8d ff ff ff       	call   800c4c <fsipc>
}
  800cbf:	c9                   	leave  
  800cc0:	c3                   	ret    

00800cc1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	8b 40 0c             	mov    0xc(%eax),%eax
  800ccd:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800cd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cdc:	e8 6b ff ff ff       	call   800c4c <fsipc>
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 04             	sub    $0x4,%esp
  800cea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	8b 40 0c             	mov    0xc(%eax),%eax
  800cf3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800cf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfd:	b8 05 00 00 00       	mov    $0x5,%eax
  800d02:	e8 45 ff ff ff       	call   800c4c <fsipc>
  800d07:	85 c0                	test   %eax,%eax
  800d09:	78 2c                	js     800d37 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d0b:	83 ec 08             	sub    $0x8,%esp
  800d0e:	68 00 50 80 00       	push   $0x805000
  800d13:	53                   	push   %ebx
  800d14:	e8 cc 0c 00 00       	call   8019e5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d19:	a1 80 50 80 00       	mov    0x805080,%eax
  800d1e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d24:	a1 84 50 80 00       	mov    0x805084,%eax
  800d29:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d2f:	83 c4 10             	add    $0x10,%esp
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d3a:	c9                   	leave  
  800d3b:	c3                   	ret    

00800d3c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d45:	8b 55 08             	mov    0x8(%ebp),%edx
  800d48:	8b 52 0c             	mov    0xc(%edx),%edx
  800d4b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d51:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d56:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d5b:	0f 47 c2             	cmova  %edx,%eax
  800d5e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d63:	50                   	push   %eax
  800d64:	ff 75 0c             	pushl  0xc(%ebp)
  800d67:	68 08 50 80 00       	push   $0x805008
  800d6c:	e8 06 0e 00 00       	call   801b77 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d71:	ba 00 00 00 00       	mov    $0x0,%edx
  800d76:	b8 04 00 00 00       	mov    $0x4,%eax
  800d7b:	e8 cc fe ff ff       	call   800c4c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800d80:	c9                   	leave  
  800d81:	c3                   	ret    

00800d82 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	8b 40 0c             	mov    0xc(%eax),%eax
  800d90:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800d95:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800d9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800da0:	b8 03 00 00 00       	mov    $0x3,%eax
  800da5:	e8 a2 fe ff ff       	call   800c4c <fsipc>
  800daa:	89 c3                	mov    %eax,%ebx
  800dac:	85 c0                	test   %eax,%eax
  800dae:	78 4b                	js     800dfb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800db0:	39 c6                	cmp    %eax,%esi
  800db2:	73 16                	jae    800dca <devfile_read+0x48>
  800db4:	68 e0 22 80 00       	push   $0x8022e0
  800db9:	68 e7 22 80 00       	push   $0x8022e7
  800dbe:	6a 7c                	push   $0x7c
  800dc0:	68 fc 22 80 00       	push   $0x8022fc
  800dc5:	e8 bd 05 00 00       	call   801387 <_panic>
	assert(r <= PGSIZE);
  800dca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800dcf:	7e 16                	jle    800de7 <devfile_read+0x65>
  800dd1:	68 07 23 80 00       	push   $0x802307
  800dd6:	68 e7 22 80 00       	push   $0x8022e7
  800ddb:	6a 7d                	push   $0x7d
  800ddd:	68 fc 22 80 00       	push   $0x8022fc
  800de2:	e8 a0 05 00 00       	call   801387 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	50                   	push   %eax
  800deb:	68 00 50 80 00       	push   $0x805000
  800df0:	ff 75 0c             	pushl  0xc(%ebp)
  800df3:	e8 7f 0d 00 00       	call   801b77 <memmove>
	return r;
  800df8:	83 c4 10             	add    $0x10,%esp
}
  800dfb:	89 d8                	mov    %ebx,%eax
  800dfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	53                   	push   %ebx
  800e08:	83 ec 20             	sub    $0x20,%esp
  800e0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e0e:	53                   	push   %ebx
  800e0f:	e8 98 0b 00 00       	call   8019ac <strlen>
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e1c:	7f 67                	jg     800e85 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e1e:	83 ec 0c             	sub    $0xc,%esp
  800e21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e24:	50                   	push   %eax
  800e25:	e8 9a f8 ff ff       	call   8006c4 <fd_alloc>
  800e2a:	83 c4 10             	add    $0x10,%esp
		return r;
  800e2d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	78 57                	js     800e8a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e33:	83 ec 08             	sub    $0x8,%esp
  800e36:	53                   	push   %ebx
  800e37:	68 00 50 80 00       	push   $0x805000
  800e3c:	e8 a4 0b 00 00       	call   8019e5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e44:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e49:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e51:	e8 f6 fd ff ff       	call   800c4c <fsipc>
  800e56:	89 c3                	mov    %eax,%ebx
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	79 14                	jns    800e73 <open+0x6f>
		fd_close(fd, 0);
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	6a 00                	push   $0x0
  800e64:	ff 75 f4             	pushl  -0xc(%ebp)
  800e67:	e8 50 f9 ff ff       	call   8007bc <fd_close>
		return r;
  800e6c:	83 c4 10             	add    $0x10,%esp
  800e6f:	89 da                	mov    %ebx,%edx
  800e71:	eb 17                	jmp    800e8a <open+0x86>
	}

	return fd2num(fd);
  800e73:	83 ec 0c             	sub    $0xc,%esp
  800e76:	ff 75 f4             	pushl  -0xc(%ebp)
  800e79:	e8 1f f8 ff ff       	call   80069d <fd2num>
  800e7e:	89 c2                	mov    %eax,%edx
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	eb 05                	jmp    800e8a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800e85:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800e8a:	89 d0                	mov    %edx,%eax
  800e8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    

00800e91 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800e97:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea1:	e8 a6 fd ff ff       	call   800c4c <fsipc>
}
  800ea6:	c9                   	leave  
  800ea7:	c3                   	ret    

00800ea8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800eb0:	83 ec 0c             	sub    $0xc,%esp
  800eb3:	ff 75 08             	pushl  0x8(%ebp)
  800eb6:	e8 f2 f7 ff ff       	call   8006ad <fd2data>
  800ebb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ebd:	83 c4 08             	add    $0x8,%esp
  800ec0:	68 13 23 80 00       	push   $0x802313
  800ec5:	53                   	push   %ebx
  800ec6:	e8 1a 0b 00 00       	call   8019e5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ecb:	8b 46 04             	mov    0x4(%esi),%eax
  800ece:	2b 06                	sub    (%esi),%eax
  800ed0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ed6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800edd:	00 00 00 
	stat->st_dev = &devpipe;
  800ee0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ee7:	30 80 00 
	return 0;
}
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 0c             	sub    $0xc,%esp
  800efd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f00:	53                   	push   %ebx
  800f01:	6a 00                	push   $0x0
  800f03:	e8 f7 f2 ff ff       	call   8001ff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f08:	89 1c 24             	mov    %ebx,(%esp)
  800f0b:	e8 9d f7 ff ff       	call   8006ad <fd2data>
  800f10:	83 c4 08             	add    $0x8,%esp
  800f13:	50                   	push   %eax
  800f14:	6a 00                	push   $0x0
  800f16:	e8 e4 f2 ff ff       	call   8001ff <sys_page_unmap>
}
  800f1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	83 ec 1c             	sub    $0x1c,%esp
  800f29:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f2c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f2e:	a1 04 40 80 00       	mov    0x804004,%eax
  800f33:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f36:	83 ec 0c             	sub    $0xc,%esp
  800f39:	ff 75 e0             	pushl  -0x20(%ebp)
  800f3c:	e8 94 0f 00 00       	call   801ed5 <pageref>
  800f41:	89 c3                	mov    %eax,%ebx
  800f43:	89 3c 24             	mov    %edi,(%esp)
  800f46:	e8 8a 0f 00 00       	call   801ed5 <pageref>
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	39 c3                	cmp    %eax,%ebx
  800f50:	0f 94 c1             	sete   %cl
  800f53:	0f b6 c9             	movzbl %cl,%ecx
  800f56:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f59:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f5f:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  800f62:	39 ce                	cmp    %ecx,%esi
  800f64:	74 1b                	je     800f81 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800f66:	39 c3                	cmp    %eax,%ebx
  800f68:	75 c4                	jne    800f2e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f6a:	8b 42 64             	mov    0x64(%edx),%eax
  800f6d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f70:	50                   	push   %eax
  800f71:	56                   	push   %esi
  800f72:	68 1a 23 80 00       	push   $0x80231a
  800f77:	e8 e4 04 00 00       	call   801460 <cprintf>
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	eb ad                	jmp    800f2e <_pipeisclosed+0xe>
	}
}
  800f81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5f                   	pop    %edi
  800f8a:	5d                   	pop    %ebp
  800f8b:	c3                   	ret    

00800f8c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	57                   	push   %edi
  800f90:	56                   	push   %esi
  800f91:	53                   	push   %ebx
  800f92:	83 ec 28             	sub    $0x28,%esp
  800f95:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800f98:	56                   	push   %esi
  800f99:	e8 0f f7 ff ff       	call   8006ad <fd2data>
  800f9e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	bf 00 00 00 00       	mov    $0x0,%edi
  800fa8:	eb 4b                	jmp    800ff5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800faa:	89 da                	mov    %ebx,%edx
  800fac:	89 f0                	mov    %esi,%eax
  800fae:	e8 6d ff ff ff       	call   800f20 <_pipeisclosed>
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	75 48                	jne    800fff <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fb7:	e8 9f f1 ff ff       	call   80015b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fbc:	8b 43 04             	mov    0x4(%ebx),%eax
  800fbf:	8b 0b                	mov    (%ebx),%ecx
  800fc1:	8d 51 20             	lea    0x20(%ecx),%edx
  800fc4:	39 d0                	cmp    %edx,%eax
  800fc6:	73 e2                	jae    800faa <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fcb:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fcf:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fd2:	89 c2                	mov    %eax,%edx
  800fd4:	c1 fa 1f             	sar    $0x1f,%edx
  800fd7:	89 d1                	mov    %edx,%ecx
  800fd9:	c1 e9 1b             	shr    $0x1b,%ecx
  800fdc:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800fdf:	83 e2 1f             	and    $0x1f,%edx
  800fe2:	29 ca                	sub    %ecx,%edx
  800fe4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800fe8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800fec:	83 c0 01             	add    $0x1,%eax
  800fef:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ff2:	83 c7 01             	add    $0x1,%edi
  800ff5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ff8:	75 c2                	jne    800fbc <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ffa:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffd:	eb 05                	jmp    801004 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800fff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801004:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801007:	5b                   	pop    %ebx
  801008:	5e                   	pop    %esi
  801009:	5f                   	pop    %edi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	57                   	push   %edi
  801010:	56                   	push   %esi
  801011:	53                   	push   %ebx
  801012:	83 ec 18             	sub    $0x18,%esp
  801015:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801018:	57                   	push   %edi
  801019:	e8 8f f6 ff ff       	call   8006ad <fd2data>
  80101e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801020:	83 c4 10             	add    $0x10,%esp
  801023:	bb 00 00 00 00       	mov    $0x0,%ebx
  801028:	eb 3d                	jmp    801067 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80102a:	85 db                	test   %ebx,%ebx
  80102c:	74 04                	je     801032 <devpipe_read+0x26>
				return i;
  80102e:	89 d8                	mov    %ebx,%eax
  801030:	eb 44                	jmp    801076 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801032:	89 f2                	mov    %esi,%edx
  801034:	89 f8                	mov    %edi,%eax
  801036:	e8 e5 fe ff ff       	call   800f20 <_pipeisclosed>
  80103b:	85 c0                	test   %eax,%eax
  80103d:	75 32                	jne    801071 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80103f:	e8 17 f1 ff ff       	call   80015b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801044:	8b 06                	mov    (%esi),%eax
  801046:	3b 46 04             	cmp    0x4(%esi),%eax
  801049:	74 df                	je     80102a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80104b:	99                   	cltd   
  80104c:	c1 ea 1b             	shr    $0x1b,%edx
  80104f:	01 d0                	add    %edx,%eax
  801051:	83 e0 1f             	and    $0x1f,%eax
  801054:	29 d0                	sub    %edx,%eax
  801056:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80105b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801061:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801064:	83 c3 01             	add    $0x1,%ebx
  801067:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80106a:	75 d8                	jne    801044 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80106c:	8b 45 10             	mov    0x10(%ebp),%eax
  80106f:	eb 05                	jmp    801076 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801071:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801076:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801079:	5b                   	pop    %ebx
  80107a:	5e                   	pop    %esi
  80107b:	5f                   	pop    %edi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801086:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801089:	50                   	push   %eax
  80108a:	e8 35 f6 ff ff       	call   8006c4 <fd_alloc>
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	89 c2                	mov    %eax,%edx
  801094:	85 c0                	test   %eax,%eax
  801096:	0f 88 2c 01 00 00    	js     8011c8 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80109c:	83 ec 04             	sub    $0x4,%esp
  80109f:	68 07 04 00 00       	push   $0x407
  8010a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 cc f0 ff ff       	call   80017a <sys_page_alloc>
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	89 c2                	mov    %eax,%edx
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	0f 88 0d 01 00 00    	js     8011c8 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010c1:	50                   	push   %eax
  8010c2:	e8 fd f5 ff ff       	call   8006c4 <fd_alloc>
  8010c7:	89 c3                	mov    %eax,%ebx
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	0f 88 e2 00 00 00    	js     8011b6 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	68 07 04 00 00       	push   $0x407
  8010dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 94 f0 ff ff       	call   80017a <sys_page_alloc>
  8010e6:	89 c3                	mov    %eax,%ebx
  8010e8:	83 c4 10             	add    $0x10,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	0f 88 c3 00 00 00    	js     8011b6 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8010f9:	e8 af f5 ff ff       	call   8006ad <fd2data>
  8010fe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801100:	83 c4 0c             	add    $0xc,%esp
  801103:	68 07 04 00 00       	push   $0x407
  801108:	50                   	push   %eax
  801109:	6a 00                	push   $0x0
  80110b:	e8 6a f0 ff ff       	call   80017a <sys_page_alloc>
  801110:	89 c3                	mov    %eax,%ebx
  801112:	83 c4 10             	add    $0x10,%esp
  801115:	85 c0                	test   %eax,%eax
  801117:	0f 88 89 00 00 00    	js     8011a6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80111d:	83 ec 0c             	sub    $0xc,%esp
  801120:	ff 75 f0             	pushl  -0x10(%ebp)
  801123:	e8 85 f5 ff ff       	call   8006ad <fd2data>
  801128:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80112f:	50                   	push   %eax
  801130:	6a 00                	push   $0x0
  801132:	56                   	push   %esi
  801133:	6a 00                	push   $0x0
  801135:	e8 83 f0 ff ff       	call   8001bd <sys_page_map>
  80113a:	89 c3                	mov    %eax,%ebx
  80113c:	83 c4 20             	add    $0x20,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 55                	js     801198 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801143:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80114e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801151:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801158:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80115e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801161:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801163:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801166:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	ff 75 f4             	pushl  -0xc(%ebp)
  801173:	e8 25 f5 ff ff       	call   80069d <fd2num>
  801178:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80117d:	83 c4 04             	add    $0x4,%esp
  801180:	ff 75 f0             	pushl  -0x10(%ebp)
  801183:	e8 15 f5 ff ff       	call   80069d <fd2num>
  801188:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118b:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	ba 00 00 00 00       	mov    $0x0,%edx
  801196:	eb 30                	jmp    8011c8 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801198:	83 ec 08             	sub    $0x8,%esp
  80119b:	56                   	push   %esi
  80119c:	6a 00                	push   $0x0
  80119e:	e8 5c f0 ff ff       	call   8001ff <sys_page_unmap>
  8011a3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8011ac:	6a 00                	push   $0x0
  8011ae:	e8 4c f0 ff ff       	call   8001ff <sys_page_unmap>
  8011b3:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8011bc:	6a 00                	push   $0x0
  8011be:	e8 3c f0 ff ff       	call   8001ff <sys_page_unmap>
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011c8:	89 d0                	mov    %edx,%eax
  8011ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	ff 75 08             	pushl  0x8(%ebp)
  8011de:	e8 30 f5 ff ff       	call   800713 <fd_lookup>
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 18                	js     801202 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011ea:	83 ec 0c             	sub    $0xc,%esp
  8011ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f0:	e8 b8 f4 ff ff       	call   8006ad <fd2data>
	return _pipeisclosed(fd, p);
  8011f5:	89 c2                	mov    %eax,%edx
  8011f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fa:	e8 21 fd ff ff       	call   800f20 <_pipeisclosed>
  8011ff:	83 c4 10             	add    $0x10,%esp
}
  801202:	c9                   	leave  
  801203:	c3                   	ret    

00801204 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801207:	b8 00 00 00 00       	mov    $0x0,%eax
  80120c:	5d                   	pop    %ebp
  80120d:	c3                   	ret    

0080120e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801214:	68 32 23 80 00       	push   $0x802332
  801219:	ff 75 0c             	pushl  0xc(%ebp)
  80121c:	e8 c4 07 00 00       	call   8019e5 <strcpy>
	return 0;
}
  801221:	b8 00 00 00 00       	mov    $0x0,%eax
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	57                   	push   %edi
  80122c:	56                   	push   %esi
  80122d:	53                   	push   %ebx
  80122e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801234:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801239:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80123f:	eb 2d                	jmp    80126e <devcons_write+0x46>
		m = n - tot;
  801241:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801244:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801246:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801249:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80124e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801251:	83 ec 04             	sub    $0x4,%esp
  801254:	53                   	push   %ebx
  801255:	03 45 0c             	add    0xc(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	57                   	push   %edi
  80125a:	e8 18 09 00 00       	call   801b77 <memmove>
		sys_cputs(buf, m);
  80125f:	83 c4 08             	add    $0x8,%esp
  801262:	53                   	push   %ebx
  801263:	57                   	push   %edi
  801264:	e8 55 ee ff ff       	call   8000be <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801269:	01 de                	add    %ebx,%esi
  80126b:	83 c4 10             	add    $0x10,%esp
  80126e:	89 f0                	mov    %esi,%eax
  801270:	3b 75 10             	cmp    0x10(%ebp),%esi
  801273:	72 cc                	jb     801241 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	83 ec 08             	sub    $0x8,%esp
  801283:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801288:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80128c:	74 2a                	je     8012b8 <devcons_read+0x3b>
  80128e:	eb 05                	jmp    801295 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801290:	e8 c6 ee ff ff       	call   80015b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801295:	e8 42 ee ff ff       	call   8000dc <sys_cgetc>
  80129a:	85 c0                	test   %eax,%eax
  80129c:	74 f2                	je     801290 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80129e:	85 c0                	test   %eax,%eax
  8012a0:	78 16                	js     8012b8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012a2:	83 f8 04             	cmp    $0x4,%eax
  8012a5:	74 0c                	je     8012b3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012aa:	88 02                	mov    %al,(%edx)
	return 1;
  8012ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b1:	eb 05                	jmp    8012b8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012b3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012c6:	6a 01                	push   $0x1
  8012c8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012cb:	50                   	push   %eax
  8012cc:	e8 ed ed ff ff       	call   8000be <sys_cputs>
}
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	c9                   	leave  
  8012d5:	c3                   	ret    

008012d6 <getchar>:

int
getchar(void)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012dc:	6a 01                	push   $0x1
  8012de:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	6a 00                	push   $0x0
  8012e4:	e8 90 f6 ff ff       	call   800979 <read>
	if (r < 0)
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 0f                	js     8012ff <getchar+0x29>
		return r;
	if (r < 1)
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	7e 06                	jle    8012fa <getchar+0x24>
		return -E_EOF;
	return c;
  8012f4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8012f8:	eb 05                	jmp    8012ff <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8012fa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8012ff:	c9                   	leave  
  801300:	c3                   	ret    

00801301 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801307:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130a:	50                   	push   %eax
  80130b:	ff 75 08             	pushl  0x8(%ebp)
  80130e:	e8 00 f4 ff ff       	call   800713 <fd_lookup>
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	85 c0                	test   %eax,%eax
  801318:	78 11                	js     80132b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80131a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801323:	39 10                	cmp    %edx,(%eax)
  801325:	0f 94 c0             	sete   %al
  801328:	0f b6 c0             	movzbl %al,%eax
}
  80132b:	c9                   	leave  
  80132c:	c3                   	ret    

0080132d <opencons>:

int
opencons(void)
{
  80132d:	55                   	push   %ebp
  80132e:	89 e5                	mov    %esp,%ebp
  801330:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801333:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801336:	50                   	push   %eax
  801337:	e8 88 f3 ff ff       	call   8006c4 <fd_alloc>
  80133c:	83 c4 10             	add    $0x10,%esp
		return r;
  80133f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801341:	85 c0                	test   %eax,%eax
  801343:	78 3e                	js     801383 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801345:	83 ec 04             	sub    $0x4,%esp
  801348:	68 07 04 00 00       	push   $0x407
  80134d:	ff 75 f4             	pushl  -0xc(%ebp)
  801350:	6a 00                	push   $0x0
  801352:	e8 23 ee ff ff       	call   80017a <sys_page_alloc>
  801357:	83 c4 10             	add    $0x10,%esp
		return r;
  80135a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 23                	js     801383 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801360:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801366:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801369:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801375:	83 ec 0c             	sub    $0xc,%esp
  801378:	50                   	push   %eax
  801379:	e8 1f f3 ff ff       	call   80069d <fd2num>
  80137e:	89 c2                	mov    %eax,%edx
  801380:	83 c4 10             	add    $0x10,%esp
}
  801383:	89 d0                	mov    %edx,%eax
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80138c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80138f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801395:	e8 a2 ed ff ff       	call   80013c <sys_getenvid>
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	ff 75 0c             	pushl  0xc(%ebp)
  8013a0:	ff 75 08             	pushl  0x8(%ebp)
  8013a3:	56                   	push   %esi
  8013a4:	50                   	push   %eax
  8013a5:	68 40 23 80 00       	push   $0x802340
  8013aa:	e8 b1 00 00 00       	call   801460 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013af:	83 c4 18             	add    $0x18,%esp
  8013b2:	53                   	push   %ebx
  8013b3:	ff 75 10             	pushl  0x10(%ebp)
  8013b6:	e8 54 00 00 00       	call   80140f <vcprintf>
	cprintf("\n");
  8013bb:	c7 04 24 2b 23 80 00 	movl   $0x80232b,(%esp)
  8013c2:	e8 99 00 00 00       	call   801460 <cprintf>
  8013c7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013ca:	cc                   	int3   
  8013cb:	eb fd                	jmp    8013ca <_panic+0x43>

008013cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 04             	sub    $0x4,%esp
  8013d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013d7:	8b 13                	mov    (%ebx),%edx
  8013d9:	8d 42 01             	lea    0x1(%edx),%eax
  8013dc:	89 03                	mov    %eax,(%ebx)
  8013de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013ea:	75 1a                	jne    801406 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	68 ff 00 00 00       	push   $0xff
  8013f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8013f7:	50                   	push   %eax
  8013f8:	e8 c1 ec ff ff       	call   8000be <sys_cputs>
		b->idx = 0;
  8013fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801403:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801406:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80140a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801418:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80141f:	00 00 00 
	b.cnt = 0;
  801422:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801429:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80142c:	ff 75 0c             	pushl  0xc(%ebp)
  80142f:	ff 75 08             	pushl  0x8(%ebp)
  801432:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	68 cd 13 80 00       	push   $0x8013cd
  80143e:	e8 54 01 00 00       	call   801597 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801443:	83 c4 08             	add    $0x8,%esp
  801446:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80144c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801452:	50                   	push   %eax
  801453:	e8 66 ec ff ff       	call   8000be <sys_cputs>

	return b.cnt;
}
  801458:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801466:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801469:	50                   	push   %eax
  80146a:	ff 75 08             	pushl  0x8(%ebp)
  80146d:	e8 9d ff ff ff       	call   80140f <vcprintf>
	va_end(ap);

	return cnt;
}
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	57                   	push   %edi
  801478:	56                   	push   %esi
  801479:	53                   	push   %ebx
  80147a:	83 ec 1c             	sub    $0x1c,%esp
  80147d:	89 c7                	mov    %eax,%edi
  80147f:	89 d6                	mov    %edx,%esi
  801481:	8b 45 08             	mov    0x8(%ebp),%eax
  801484:	8b 55 0c             	mov    0xc(%ebp),%edx
  801487:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80148a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80148d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801490:	bb 00 00 00 00       	mov    $0x0,%ebx
  801495:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801498:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80149b:	39 d3                	cmp    %edx,%ebx
  80149d:	72 05                	jb     8014a4 <printnum+0x30>
  80149f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014a2:	77 45                	ja     8014e9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014a4:	83 ec 0c             	sub    $0xc,%esp
  8014a7:	ff 75 18             	pushl  0x18(%ebp)
  8014aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014b0:	53                   	push   %ebx
  8014b1:	ff 75 10             	pushl  0x10(%ebp)
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8014bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8014c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8014c3:	e8 48 0a 00 00       	call   801f10 <__udivdi3>
  8014c8:	83 c4 18             	add    $0x18,%esp
  8014cb:	52                   	push   %edx
  8014cc:	50                   	push   %eax
  8014cd:	89 f2                	mov    %esi,%edx
  8014cf:	89 f8                	mov    %edi,%eax
  8014d1:	e8 9e ff ff ff       	call   801474 <printnum>
  8014d6:	83 c4 20             	add    $0x20,%esp
  8014d9:	eb 18                	jmp    8014f3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	56                   	push   %esi
  8014df:	ff 75 18             	pushl  0x18(%ebp)
  8014e2:	ff d7                	call   *%edi
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	eb 03                	jmp    8014ec <printnum+0x78>
  8014e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014ec:	83 eb 01             	sub    $0x1,%ebx
  8014ef:	85 db                	test   %ebx,%ebx
  8014f1:	7f e8                	jg     8014db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	56                   	push   %esi
  8014f7:	83 ec 04             	sub    $0x4,%esp
  8014fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014fd:	ff 75 e0             	pushl  -0x20(%ebp)
  801500:	ff 75 dc             	pushl  -0x24(%ebp)
  801503:	ff 75 d8             	pushl  -0x28(%ebp)
  801506:	e8 35 0b 00 00       	call   802040 <__umoddi3>
  80150b:	83 c4 14             	add    $0x14,%esp
  80150e:	0f be 80 63 23 80 00 	movsbl 0x802363(%eax),%eax
  801515:	50                   	push   %eax
  801516:	ff d7                	call   *%edi
}
  801518:	83 c4 10             	add    $0x10,%esp
  80151b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80151e:	5b                   	pop    %ebx
  80151f:	5e                   	pop    %esi
  801520:	5f                   	pop    %edi
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801526:	83 fa 01             	cmp    $0x1,%edx
  801529:	7e 0e                	jle    801539 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80152b:	8b 10                	mov    (%eax),%edx
  80152d:	8d 4a 08             	lea    0x8(%edx),%ecx
  801530:	89 08                	mov    %ecx,(%eax)
  801532:	8b 02                	mov    (%edx),%eax
  801534:	8b 52 04             	mov    0x4(%edx),%edx
  801537:	eb 22                	jmp    80155b <getuint+0x38>
	else if (lflag)
  801539:	85 d2                	test   %edx,%edx
  80153b:	74 10                	je     80154d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80153d:	8b 10                	mov    (%eax),%edx
  80153f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801542:	89 08                	mov    %ecx,(%eax)
  801544:	8b 02                	mov    (%edx),%eax
  801546:	ba 00 00 00 00       	mov    $0x0,%edx
  80154b:	eb 0e                	jmp    80155b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80154d:	8b 10                	mov    (%eax),%edx
  80154f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801552:	89 08                	mov    %ecx,(%eax)
  801554:	8b 02                	mov    (%edx),%eax
  801556:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801563:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801567:	8b 10                	mov    (%eax),%edx
  801569:	3b 50 04             	cmp    0x4(%eax),%edx
  80156c:	73 0a                	jae    801578 <sprintputch+0x1b>
		*b->buf++ = ch;
  80156e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801571:	89 08                	mov    %ecx,(%eax)
  801573:	8b 45 08             	mov    0x8(%ebp),%eax
  801576:	88 02                	mov    %al,(%edx)
}
  801578:	5d                   	pop    %ebp
  801579:	c3                   	ret    

0080157a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801580:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801583:	50                   	push   %eax
  801584:	ff 75 10             	pushl  0x10(%ebp)
  801587:	ff 75 0c             	pushl  0xc(%ebp)
  80158a:	ff 75 08             	pushl  0x8(%ebp)
  80158d:	e8 05 00 00 00       	call   801597 <vprintfmt>
	va_end(ap);
}
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	57                   	push   %edi
  80159b:	56                   	push   %esi
  80159c:	53                   	push   %ebx
  80159d:	83 ec 2c             	sub    $0x2c,%esp
  8015a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8015a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015a6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015a9:	eb 12                	jmp    8015bd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	0f 84 89 03 00 00    	je     80193c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015b3:	83 ec 08             	sub    $0x8,%esp
  8015b6:	53                   	push   %ebx
  8015b7:	50                   	push   %eax
  8015b8:	ff d6                	call   *%esi
  8015ba:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015bd:	83 c7 01             	add    $0x1,%edi
  8015c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015c4:	83 f8 25             	cmp    $0x25,%eax
  8015c7:	75 e2                	jne    8015ab <vprintfmt+0x14>
  8015c9:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015cd:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015d4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015db:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e7:	eb 07                	jmp    8015f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015ec:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f0:	8d 47 01             	lea    0x1(%edi),%eax
  8015f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015f6:	0f b6 07             	movzbl (%edi),%eax
  8015f9:	0f b6 c8             	movzbl %al,%ecx
  8015fc:	83 e8 23             	sub    $0x23,%eax
  8015ff:	3c 55                	cmp    $0x55,%al
  801601:	0f 87 1a 03 00 00    	ja     801921 <vprintfmt+0x38a>
  801607:	0f b6 c0             	movzbl %al,%eax
  80160a:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
  801611:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801614:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801618:	eb d6                	jmp    8015f0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80161d:	b8 00 00 00 00       	mov    $0x0,%eax
  801622:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801625:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801628:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80162c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80162f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801632:	83 fa 09             	cmp    $0x9,%edx
  801635:	77 39                	ja     801670 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801637:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80163a:	eb e9                	jmp    801625 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80163c:	8b 45 14             	mov    0x14(%ebp),%eax
  80163f:	8d 48 04             	lea    0x4(%eax),%ecx
  801642:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801645:	8b 00                	mov    (%eax),%eax
  801647:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80164d:	eb 27                	jmp    801676 <vprintfmt+0xdf>
  80164f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801652:	85 c0                	test   %eax,%eax
  801654:	b9 00 00 00 00       	mov    $0x0,%ecx
  801659:	0f 49 c8             	cmovns %eax,%ecx
  80165c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80165f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801662:	eb 8c                	jmp    8015f0 <vprintfmt+0x59>
  801664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801667:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80166e:	eb 80                	jmp    8015f0 <vprintfmt+0x59>
  801670:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801673:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801676:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80167a:	0f 89 70 ff ff ff    	jns    8015f0 <vprintfmt+0x59>
				width = precision, precision = -1;
  801680:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801683:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801686:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80168d:	e9 5e ff ff ff       	jmp    8015f0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801692:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801695:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801698:	e9 53 ff ff ff       	jmp    8015f0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80169d:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a0:	8d 50 04             	lea    0x4(%eax),%edx
  8016a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	53                   	push   %ebx
  8016aa:	ff 30                	pushl  (%eax)
  8016ac:	ff d6                	call   *%esi
			break;
  8016ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016b4:	e9 04 ff ff ff       	jmp    8015bd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8016bc:	8d 50 04             	lea    0x4(%eax),%edx
  8016bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8016c2:	8b 00                	mov    (%eax),%eax
  8016c4:	99                   	cltd   
  8016c5:	31 d0                	xor    %edx,%eax
  8016c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016c9:	83 f8 0f             	cmp    $0xf,%eax
  8016cc:	7f 0b                	jg     8016d9 <vprintfmt+0x142>
  8016ce:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  8016d5:	85 d2                	test   %edx,%edx
  8016d7:	75 18                	jne    8016f1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016d9:	50                   	push   %eax
  8016da:	68 7b 23 80 00       	push   $0x80237b
  8016df:	53                   	push   %ebx
  8016e0:	56                   	push   %esi
  8016e1:	e8 94 fe ff ff       	call   80157a <printfmt>
  8016e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016ec:	e9 cc fe ff ff       	jmp    8015bd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8016f1:	52                   	push   %edx
  8016f2:	68 f9 22 80 00       	push   $0x8022f9
  8016f7:	53                   	push   %ebx
  8016f8:	56                   	push   %esi
  8016f9:	e8 7c fe ff ff       	call   80157a <printfmt>
  8016fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801701:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801704:	e9 b4 fe ff ff       	jmp    8015bd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801709:	8b 45 14             	mov    0x14(%ebp),%eax
  80170c:	8d 50 04             	lea    0x4(%eax),%edx
  80170f:	89 55 14             	mov    %edx,0x14(%ebp)
  801712:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801714:	85 ff                	test   %edi,%edi
  801716:	b8 74 23 80 00       	mov    $0x802374,%eax
  80171b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80171e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801722:	0f 8e 94 00 00 00    	jle    8017bc <vprintfmt+0x225>
  801728:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80172c:	0f 84 98 00 00 00    	je     8017ca <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	ff 75 d0             	pushl  -0x30(%ebp)
  801738:	57                   	push   %edi
  801739:	e8 86 02 00 00       	call   8019c4 <strnlen>
  80173e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801741:	29 c1                	sub    %eax,%ecx
  801743:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801746:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801749:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80174d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801750:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801753:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801755:	eb 0f                	jmp    801766 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801757:	83 ec 08             	sub    $0x8,%esp
  80175a:	53                   	push   %ebx
  80175b:	ff 75 e0             	pushl  -0x20(%ebp)
  80175e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801760:	83 ef 01             	sub    $0x1,%edi
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	85 ff                	test   %edi,%edi
  801768:	7f ed                	jg     801757 <vprintfmt+0x1c0>
  80176a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80176d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801770:	85 c9                	test   %ecx,%ecx
  801772:	b8 00 00 00 00       	mov    $0x0,%eax
  801777:	0f 49 c1             	cmovns %ecx,%eax
  80177a:	29 c1                	sub    %eax,%ecx
  80177c:	89 75 08             	mov    %esi,0x8(%ebp)
  80177f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801782:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801785:	89 cb                	mov    %ecx,%ebx
  801787:	eb 4d                	jmp    8017d6 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801789:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80178d:	74 1b                	je     8017aa <vprintfmt+0x213>
  80178f:	0f be c0             	movsbl %al,%eax
  801792:	83 e8 20             	sub    $0x20,%eax
  801795:	83 f8 5e             	cmp    $0x5e,%eax
  801798:	76 10                	jbe    8017aa <vprintfmt+0x213>
					putch('?', putdat);
  80179a:	83 ec 08             	sub    $0x8,%esp
  80179d:	ff 75 0c             	pushl  0xc(%ebp)
  8017a0:	6a 3f                	push   $0x3f
  8017a2:	ff 55 08             	call   *0x8(%ebp)
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	eb 0d                	jmp    8017b7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	ff 75 0c             	pushl  0xc(%ebp)
  8017b0:	52                   	push   %edx
  8017b1:	ff 55 08             	call   *0x8(%ebp)
  8017b4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017b7:	83 eb 01             	sub    $0x1,%ebx
  8017ba:	eb 1a                	jmp    8017d6 <vprintfmt+0x23f>
  8017bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8017bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017c8:	eb 0c                	jmp    8017d6 <vprintfmt+0x23f>
  8017ca:	89 75 08             	mov    %esi,0x8(%ebp)
  8017cd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017d0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017d3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017d6:	83 c7 01             	add    $0x1,%edi
  8017d9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017dd:	0f be d0             	movsbl %al,%edx
  8017e0:	85 d2                	test   %edx,%edx
  8017e2:	74 23                	je     801807 <vprintfmt+0x270>
  8017e4:	85 f6                	test   %esi,%esi
  8017e6:	78 a1                	js     801789 <vprintfmt+0x1f2>
  8017e8:	83 ee 01             	sub    $0x1,%esi
  8017eb:	79 9c                	jns    801789 <vprintfmt+0x1f2>
  8017ed:	89 df                	mov    %ebx,%edi
  8017ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8017f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017f5:	eb 18                	jmp    80180f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	53                   	push   %ebx
  8017fb:	6a 20                	push   $0x20
  8017fd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8017ff:	83 ef 01             	sub    $0x1,%edi
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	eb 08                	jmp    80180f <vprintfmt+0x278>
  801807:	89 df                	mov    %ebx,%edi
  801809:	8b 75 08             	mov    0x8(%ebp),%esi
  80180c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80180f:	85 ff                	test   %edi,%edi
  801811:	7f e4                	jg     8017f7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801813:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801816:	e9 a2 fd ff ff       	jmp    8015bd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80181b:	83 fa 01             	cmp    $0x1,%edx
  80181e:	7e 16                	jle    801836 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801820:	8b 45 14             	mov    0x14(%ebp),%eax
  801823:	8d 50 08             	lea    0x8(%eax),%edx
  801826:	89 55 14             	mov    %edx,0x14(%ebp)
  801829:	8b 50 04             	mov    0x4(%eax),%edx
  80182c:	8b 00                	mov    (%eax),%eax
  80182e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801831:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801834:	eb 32                	jmp    801868 <vprintfmt+0x2d1>
	else if (lflag)
  801836:	85 d2                	test   %edx,%edx
  801838:	74 18                	je     801852 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80183a:	8b 45 14             	mov    0x14(%ebp),%eax
  80183d:	8d 50 04             	lea    0x4(%eax),%edx
  801840:	89 55 14             	mov    %edx,0x14(%ebp)
  801843:	8b 00                	mov    (%eax),%eax
  801845:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801848:	89 c1                	mov    %eax,%ecx
  80184a:	c1 f9 1f             	sar    $0x1f,%ecx
  80184d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801850:	eb 16                	jmp    801868 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801852:	8b 45 14             	mov    0x14(%ebp),%eax
  801855:	8d 50 04             	lea    0x4(%eax),%edx
  801858:	89 55 14             	mov    %edx,0x14(%ebp)
  80185b:	8b 00                	mov    (%eax),%eax
  80185d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801860:	89 c1                	mov    %eax,%ecx
  801862:	c1 f9 1f             	sar    $0x1f,%ecx
  801865:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801868:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80186b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80186e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801873:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801877:	79 74                	jns    8018ed <vprintfmt+0x356>
				putch('-', putdat);
  801879:	83 ec 08             	sub    $0x8,%esp
  80187c:	53                   	push   %ebx
  80187d:	6a 2d                	push   $0x2d
  80187f:	ff d6                	call   *%esi
				num = -(long long) num;
  801881:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801884:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801887:	f7 d8                	neg    %eax
  801889:	83 d2 00             	adc    $0x0,%edx
  80188c:	f7 da                	neg    %edx
  80188e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801891:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801896:	eb 55                	jmp    8018ed <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801898:	8d 45 14             	lea    0x14(%ebp),%eax
  80189b:	e8 83 fc ff ff       	call   801523 <getuint>
			base = 10;
  8018a0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018a5:	eb 46                	jmp    8018ed <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8018aa:	e8 74 fc ff ff       	call   801523 <getuint>
			base = 8;
  8018af:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018b4:	eb 37                	jmp    8018ed <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018b6:	83 ec 08             	sub    $0x8,%esp
  8018b9:	53                   	push   %ebx
  8018ba:	6a 30                	push   $0x30
  8018bc:	ff d6                	call   *%esi
			putch('x', putdat);
  8018be:	83 c4 08             	add    $0x8,%esp
  8018c1:	53                   	push   %ebx
  8018c2:	6a 78                	push   $0x78
  8018c4:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c9:	8d 50 04             	lea    0x4(%eax),%edx
  8018cc:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018cf:	8b 00                	mov    (%eax),%eax
  8018d1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018d6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018d9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018de:	eb 0d                	jmp    8018ed <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8018e3:	e8 3b fc ff ff       	call   801523 <getuint>
			base = 16;
  8018e8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018ed:	83 ec 0c             	sub    $0xc,%esp
  8018f0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8018f4:	57                   	push   %edi
  8018f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8018f8:	51                   	push   %ecx
  8018f9:	52                   	push   %edx
  8018fa:	50                   	push   %eax
  8018fb:	89 da                	mov    %ebx,%edx
  8018fd:	89 f0                	mov    %esi,%eax
  8018ff:	e8 70 fb ff ff       	call   801474 <printnum>
			break;
  801904:	83 c4 20             	add    $0x20,%esp
  801907:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80190a:	e9 ae fc ff ff       	jmp    8015bd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80190f:	83 ec 08             	sub    $0x8,%esp
  801912:	53                   	push   %ebx
  801913:	51                   	push   %ecx
  801914:	ff d6                	call   *%esi
			break;
  801916:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801919:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80191c:	e9 9c fc ff ff       	jmp    8015bd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801921:	83 ec 08             	sub    $0x8,%esp
  801924:	53                   	push   %ebx
  801925:	6a 25                	push   $0x25
  801927:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801929:	83 c4 10             	add    $0x10,%esp
  80192c:	eb 03                	jmp    801931 <vprintfmt+0x39a>
  80192e:	83 ef 01             	sub    $0x1,%edi
  801931:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801935:	75 f7                	jne    80192e <vprintfmt+0x397>
  801937:	e9 81 fc ff ff       	jmp    8015bd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80193c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80193f:	5b                   	pop    %ebx
  801940:	5e                   	pop    %esi
  801941:	5f                   	pop    %edi
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	83 ec 18             	sub    $0x18,%esp
  80194a:	8b 45 08             	mov    0x8(%ebp),%eax
  80194d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801950:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801953:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801957:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80195a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801961:	85 c0                	test   %eax,%eax
  801963:	74 26                	je     80198b <vsnprintf+0x47>
  801965:	85 d2                	test   %edx,%edx
  801967:	7e 22                	jle    80198b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801969:	ff 75 14             	pushl  0x14(%ebp)
  80196c:	ff 75 10             	pushl  0x10(%ebp)
  80196f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801972:	50                   	push   %eax
  801973:	68 5d 15 80 00       	push   $0x80155d
  801978:	e8 1a fc ff ff       	call   801597 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80197d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801980:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801983:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	eb 05                	jmp    801990 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80198b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801990:	c9                   	leave  
  801991:	c3                   	ret    

00801992 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801998:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80199b:	50                   	push   %eax
  80199c:	ff 75 10             	pushl  0x10(%ebp)
  80199f:	ff 75 0c             	pushl  0xc(%ebp)
  8019a2:	ff 75 08             	pushl  0x8(%ebp)
  8019a5:	e8 9a ff ff ff       	call   801944 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019aa:	c9                   	leave  
  8019ab:	c3                   	ret    

008019ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019ac:	55                   	push   %ebp
  8019ad:	89 e5                	mov    %esp,%ebp
  8019af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b7:	eb 03                	jmp    8019bc <strlen+0x10>
		n++;
  8019b9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019c0:	75 f7                	jne    8019b9 <strlen+0xd>
		n++;
	return n;
}
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ca:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d2:	eb 03                	jmp    8019d7 <strnlen+0x13>
		n++;
  8019d4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019d7:	39 c2                	cmp    %eax,%edx
  8019d9:	74 08                	je     8019e3 <strnlen+0x1f>
  8019db:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019df:	75 f3                	jne    8019d4 <strnlen+0x10>
  8019e1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	53                   	push   %ebx
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019ef:	89 c2                	mov    %eax,%edx
  8019f1:	83 c2 01             	add    $0x1,%edx
  8019f4:	83 c1 01             	add    $0x1,%ecx
  8019f7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8019fb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8019fe:	84 db                	test   %bl,%bl
  801a00:	75 ef                	jne    8019f1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a02:	5b                   	pop    %ebx
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	53                   	push   %ebx
  801a09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a0c:	53                   	push   %ebx
  801a0d:	e8 9a ff ff ff       	call   8019ac <strlen>
  801a12:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a15:	ff 75 0c             	pushl  0xc(%ebp)
  801a18:	01 d8                	add    %ebx,%eax
  801a1a:	50                   	push   %eax
  801a1b:	e8 c5 ff ff ff       	call   8019e5 <strcpy>
	return dst;
}
  801a20:	89 d8                	mov    %ebx,%eax
  801a22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    

00801a27 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a27:	55                   	push   %ebp
  801a28:	89 e5                	mov    %esp,%ebp
  801a2a:	56                   	push   %esi
  801a2b:	53                   	push   %ebx
  801a2c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a32:	89 f3                	mov    %esi,%ebx
  801a34:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a37:	89 f2                	mov    %esi,%edx
  801a39:	eb 0f                	jmp    801a4a <strncpy+0x23>
		*dst++ = *src;
  801a3b:	83 c2 01             	add    $0x1,%edx
  801a3e:	0f b6 01             	movzbl (%ecx),%eax
  801a41:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a44:	80 39 01             	cmpb   $0x1,(%ecx)
  801a47:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a4a:	39 da                	cmp    %ebx,%edx
  801a4c:	75 ed                	jne    801a3b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a4e:	89 f0                	mov    %esi,%eax
  801a50:	5b                   	pop    %ebx
  801a51:	5e                   	pop    %esi
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5f:	8b 55 10             	mov    0x10(%ebp),%edx
  801a62:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a64:	85 d2                	test   %edx,%edx
  801a66:	74 21                	je     801a89 <strlcpy+0x35>
  801a68:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a6c:	89 f2                	mov    %esi,%edx
  801a6e:	eb 09                	jmp    801a79 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a70:	83 c2 01             	add    $0x1,%edx
  801a73:	83 c1 01             	add    $0x1,%ecx
  801a76:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a79:	39 c2                	cmp    %eax,%edx
  801a7b:	74 09                	je     801a86 <strlcpy+0x32>
  801a7d:	0f b6 19             	movzbl (%ecx),%ebx
  801a80:	84 db                	test   %bl,%bl
  801a82:	75 ec                	jne    801a70 <strlcpy+0x1c>
  801a84:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a86:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a89:	29 f0                	sub    %esi,%eax
}
  801a8b:	5b                   	pop    %ebx
  801a8c:	5e                   	pop    %esi
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    

00801a8f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a95:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801a98:	eb 06                	jmp    801aa0 <strcmp+0x11>
		p++, q++;
  801a9a:	83 c1 01             	add    $0x1,%ecx
  801a9d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801aa0:	0f b6 01             	movzbl (%ecx),%eax
  801aa3:	84 c0                	test   %al,%al
  801aa5:	74 04                	je     801aab <strcmp+0x1c>
  801aa7:	3a 02                	cmp    (%edx),%al
  801aa9:	74 ef                	je     801a9a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801aab:	0f b6 c0             	movzbl %al,%eax
  801aae:	0f b6 12             	movzbl (%edx),%edx
  801ab1:	29 d0                	sub    %edx,%eax
}
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	53                   	push   %ebx
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801abf:	89 c3                	mov    %eax,%ebx
  801ac1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ac4:	eb 06                	jmp    801acc <strncmp+0x17>
		n--, p++, q++;
  801ac6:	83 c0 01             	add    $0x1,%eax
  801ac9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801acc:	39 d8                	cmp    %ebx,%eax
  801ace:	74 15                	je     801ae5 <strncmp+0x30>
  801ad0:	0f b6 08             	movzbl (%eax),%ecx
  801ad3:	84 c9                	test   %cl,%cl
  801ad5:	74 04                	je     801adb <strncmp+0x26>
  801ad7:	3a 0a                	cmp    (%edx),%cl
  801ad9:	74 eb                	je     801ac6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801adb:	0f b6 00             	movzbl (%eax),%eax
  801ade:	0f b6 12             	movzbl (%edx),%edx
  801ae1:	29 d0                	sub    %edx,%eax
  801ae3:	eb 05                	jmp    801aea <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801aea:	5b                   	pop    %ebx
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    

00801aed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	8b 45 08             	mov    0x8(%ebp),%eax
  801af3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801af7:	eb 07                	jmp    801b00 <strchr+0x13>
		if (*s == c)
  801af9:	38 ca                	cmp    %cl,%dl
  801afb:	74 0f                	je     801b0c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801afd:	83 c0 01             	add    $0x1,%eax
  801b00:	0f b6 10             	movzbl (%eax),%edx
  801b03:	84 d2                	test   %dl,%dl
  801b05:	75 f2                	jne    801af9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0c:	5d                   	pop    %ebp
  801b0d:	c3                   	ret    

00801b0e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b0e:	55                   	push   %ebp
  801b0f:	89 e5                	mov    %esp,%ebp
  801b11:	8b 45 08             	mov    0x8(%ebp),%eax
  801b14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b18:	eb 03                	jmp    801b1d <strfind+0xf>
  801b1a:	83 c0 01             	add    $0x1,%eax
  801b1d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b20:	38 ca                	cmp    %cl,%dl
  801b22:	74 04                	je     801b28 <strfind+0x1a>
  801b24:	84 d2                	test   %dl,%dl
  801b26:	75 f2                	jne    801b1a <strfind+0xc>
			break;
	return (char *) s;
}
  801b28:	5d                   	pop    %ebp
  801b29:	c3                   	ret    

00801b2a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	57                   	push   %edi
  801b2e:	56                   	push   %esi
  801b2f:	53                   	push   %ebx
  801b30:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b36:	85 c9                	test   %ecx,%ecx
  801b38:	74 36                	je     801b70 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b3a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b40:	75 28                	jne    801b6a <memset+0x40>
  801b42:	f6 c1 03             	test   $0x3,%cl
  801b45:	75 23                	jne    801b6a <memset+0x40>
		c &= 0xFF;
  801b47:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b4b:	89 d3                	mov    %edx,%ebx
  801b4d:	c1 e3 08             	shl    $0x8,%ebx
  801b50:	89 d6                	mov    %edx,%esi
  801b52:	c1 e6 18             	shl    $0x18,%esi
  801b55:	89 d0                	mov    %edx,%eax
  801b57:	c1 e0 10             	shl    $0x10,%eax
  801b5a:	09 f0                	or     %esi,%eax
  801b5c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b5e:	89 d8                	mov    %ebx,%eax
  801b60:	09 d0                	or     %edx,%eax
  801b62:	c1 e9 02             	shr    $0x2,%ecx
  801b65:	fc                   	cld    
  801b66:	f3 ab                	rep stos %eax,%es:(%edi)
  801b68:	eb 06                	jmp    801b70 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6d:	fc                   	cld    
  801b6e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b70:	89 f8                	mov    %edi,%eax
  801b72:	5b                   	pop    %ebx
  801b73:	5e                   	pop    %esi
  801b74:	5f                   	pop    %edi
  801b75:	5d                   	pop    %ebp
  801b76:	c3                   	ret    

00801b77 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	57                   	push   %edi
  801b7b:	56                   	push   %esi
  801b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b85:	39 c6                	cmp    %eax,%esi
  801b87:	73 35                	jae    801bbe <memmove+0x47>
  801b89:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b8c:	39 d0                	cmp    %edx,%eax
  801b8e:	73 2e                	jae    801bbe <memmove+0x47>
		s += n;
		d += n;
  801b90:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b93:	89 d6                	mov    %edx,%esi
  801b95:	09 fe                	or     %edi,%esi
  801b97:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801b9d:	75 13                	jne    801bb2 <memmove+0x3b>
  801b9f:	f6 c1 03             	test   $0x3,%cl
  801ba2:	75 0e                	jne    801bb2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801ba4:	83 ef 04             	sub    $0x4,%edi
  801ba7:	8d 72 fc             	lea    -0x4(%edx),%esi
  801baa:	c1 e9 02             	shr    $0x2,%ecx
  801bad:	fd                   	std    
  801bae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bb0:	eb 09                	jmp    801bbb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bb2:	83 ef 01             	sub    $0x1,%edi
  801bb5:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bb8:	fd                   	std    
  801bb9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bbb:	fc                   	cld    
  801bbc:	eb 1d                	jmp    801bdb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bbe:	89 f2                	mov    %esi,%edx
  801bc0:	09 c2                	or     %eax,%edx
  801bc2:	f6 c2 03             	test   $0x3,%dl
  801bc5:	75 0f                	jne    801bd6 <memmove+0x5f>
  801bc7:	f6 c1 03             	test   $0x3,%cl
  801bca:	75 0a                	jne    801bd6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bcc:	c1 e9 02             	shr    $0x2,%ecx
  801bcf:	89 c7                	mov    %eax,%edi
  801bd1:	fc                   	cld    
  801bd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bd4:	eb 05                	jmp    801bdb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bd6:	89 c7                	mov    %eax,%edi
  801bd8:	fc                   	cld    
  801bd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801bdb:	5e                   	pop    %esi
  801bdc:	5f                   	pop    %edi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801be2:	ff 75 10             	pushl  0x10(%ebp)
  801be5:	ff 75 0c             	pushl  0xc(%ebp)
  801be8:	ff 75 08             	pushl  0x8(%ebp)
  801beb:	e8 87 ff ff ff       	call   801b77 <memmove>
}
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bfd:	89 c6                	mov    %eax,%esi
  801bff:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c02:	eb 1a                	jmp    801c1e <memcmp+0x2c>
		if (*s1 != *s2)
  801c04:	0f b6 08             	movzbl (%eax),%ecx
  801c07:	0f b6 1a             	movzbl (%edx),%ebx
  801c0a:	38 d9                	cmp    %bl,%cl
  801c0c:	74 0a                	je     801c18 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c0e:	0f b6 c1             	movzbl %cl,%eax
  801c11:	0f b6 db             	movzbl %bl,%ebx
  801c14:	29 d8                	sub    %ebx,%eax
  801c16:	eb 0f                	jmp    801c27 <memcmp+0x35>
		s1++, s2++;
  801c18:	83 c0 01             	add    $0x1,%eax
  801c1b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c1e:	39 f0                	cmp    %esi,%eax
  801c20:	75 e2                	jne    801c04 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c22:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	53                   	push   %ebx
  801c2f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c32:	89 c1                	mov    %eax,%ecx
  801c34:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c37:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c3b:	eb 0a                	jmp    801c47 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c3d:	0f b6 10             	movzbl (%eax),%edx
  801c40:	39 da                	cmp    %ebx,%edx
  801c42:	74 07                	je     801c4b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c44:	83 c0 01             	add    $0x1,%eax
  801c47:	39 c8                	cmp    %ecx,%eax
  801c49:	72 f2                	jb     801c3d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c4b:	5b                   	pop    %ebx
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c5a:	eb 03                	jmp    801c5f <strtol+0x11>
		s++;
  801c5c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c5f:	0f b6 01             	movzbl (%ecx),%eax
  801c62:	3c 20                	cmp    $0x20,%al
  801c64:	74 f6                	je     801c5c <strtol+0xe>
  801c66:	3c 09                	cmp    $0x9,%al
  801c68:	74 f2                	je     801c5c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c6a:	3c 2b                	cmp    $0x2b,%al
  801c6c:	75 0a                	jne    801c78 <strtol+0x2a>
		s++;
  801c6e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c71:	bf 00 00 00 00       	mov    $0x0,%edi
  801c76:	eb 11                	jmp    801c89 <strtol+0x3b>
  801c78:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c7d:	3c 2d                	cmp    $0x2d,%al
  801c7f:	75 08                	jne    801c89 <strtol+0x3b>
		s++, neg = 1;
  801c81:	83 c1 01             	add    $0x1,%ecx
  801c84:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c89:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c8f:	75 15                	jne    801ca6 <strtol+0x58>
  801c91:	80 39 30             	cmpb   $0x30,(%ecx)
  801c94:	75 10                	jne    801ca6 <strtol+0x58>
  801c96:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801c9a:	75 7c                	jne    801d18 <strtol+0xca>
		s += 2, base = 16;
  801c9c:	83 c1 02             	add    $0x2,%ecx
  801c9f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ca4:	eb 16                	jmp    801cbc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ca6:	85 db                	test   %ebx,%ebx
  801ca8:	75 12                	jne    801cbc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801caa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801caf:	80 39 30             	cmpb   $0x30,(%ecx)
  801cb2:	75 08                	jne    801cbc <strtol+0x6e>
		s++, base = 8;
  801cb4:	83 c1 01             	add    $0x1,%ecx
  801cb7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801cc1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cc4:	0f b6 11             	movzbl (%ecx),%edx
  801cc7:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cca:	89 f3                	mov    %esi,%ebx
  801ccc:	80 fb 09             	cmp    $0x9,%bl
  801ccf:	77 08                	ja     801cd9 <strtol+0x8b>
			dig = *s - '0';
  801cd1:	0f be d2             	movsbl %dl,%edx
  801cd4:	83 ea 30             	sub    $0x30,%edx
  801cd7:	eb 22                	jmp    801cfb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801cd9:	8d 72 9f             	lea    -0x61(%edx),%esi
  801cdc:	89 f3                	mov    %esi,%ebx
  801cde:	80 fb 19             	cmp    $0x19,%bl
  801ce1:	77 08                	ja     801ceb <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ce3:	0f be d2             	movsbl %dl,%edx
  801ce6:	83 ea 57             	sub    $0x57,%edx
  801ce9:	eb 10                	jmp    801cfb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ceb:	8d 72 bf             	lea    -0x41(%edx),%esi
  801cee:	89 f3                	mov    %esi,%ebx
  801cf0:	80 fb 19             	cmp    $0x19,%bl
  801cf3:	77 16                	ja     801d0b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801cf5:	0f be d2             	movsbl %dl,%edx
  801cf8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801cfb:	3b 55 10             	cmp    0x10(%ebp),%edx
  801cfe:	7d 0b                	jge    801d0b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d00:	83 c1 01             	add    $0x1,%ecx
  801d03:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d07:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d09:	eb b9                	jmp    801cc4 <strtol+0x76>

	if (endptr)
  801d0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d0f:	74 0d                	je     801d1e <strtol+0xd0>
		*endptr = (char *) s;
  801d11:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d14:	89 0e                	mov    %ecx,(%esi)
  801d16:	eb 06                	jmp    801d1e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d18:	85 db                	test   %ebx,%ebx
  801d1a:	74 98                	je     801cb4 <strtol+0x66>
  801d1c:	eb 9e                	jmp    801cbc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d1e:	89 c2                	mov    %eax,%edx
  801d20:	f7 da                	neg    %edx
  801d22:	85 ff                	test   %edi,%edi
  801d24:	0f 45 c2             	cmovne %edx,%eax
}
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5f                   	pop    %edi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d32:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d39:	75 2a                	jne    801d65 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d3b:	83 ec 04             	sub    $0x4,%esp
  801d3e:	6a 07                	push   $0x7
  801d40:	68 00 f0 bf ee       	push   $0xeebff000
  801d45:	6a 00                	push   $0x0
  801d47:	e8 2e e4 ff ff       	call   80017a <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d4c:	83 c4 10             	add    $0x10,%esp
  801d4f:	85 c0                	test   %eax,%eax
  801d51:	79 12                	jns    801d65 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d53:	50                   	push   %eax
  801d54:	68 60 26 80 00       	push   $0x802660
  801d59:	6a 23                	push   $0x23
  801d5b:	68 64 26 80 00       	push   $0x802664
  801d60:	e8 22 f6 ff ff       	call   801387 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d65:	8b 45 08             	mov    0x8(%ebp),%eax
  801d68:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d6d:	83 ec 08             	sub    $0x8,%esp
  801d70:	68 97 1d 80 00       	push   $0x801d97
  801d75:	6a 00                	push   $0x0
  801d77:	e8 49 e5 ff ff       	call   8002c5 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	79 12                	jns    801d95 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d83:	50                   	push   %eax
  801d84:	68 60 26 80 00       	push   $0x802660
  801d89:	6a 2c                	push   $0x2c
  801d8b:	68 64 26 80 00       	push   $0x802664
  801d90:	e8 f2 f5 ff ff       	call   801387 <_panic>
	}
}
  801d95:	c9                   	leave  
  801d96:	c3                   	ret    

00801d97 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d97:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d98:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d9d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d9f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801da2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801da6:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dab:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801daf:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801db1:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801db4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801db5:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801db8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801db9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dba:	c3                   	ret    

00801dbb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	56                   	push   %esi
  801dbf:	53                   	push   %ebx
  801dc0:	8b 75 08             	mov    0x8(%ebp),%esi
  801dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dc9:	85 c0                	test   %eax,%eax
  801dcb:	75 12                	jne    801ddf <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801dcd:	83 ec 0c             	sub    $0xc,%esp
  801dd0:	68 00 00 c0 ee       	push   $0xeec00000
  801dd5:	e8 50 e5 ff ff       	call   80032a <sys_ipc_recv>
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	eb 0c                	jmp    801deb <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801ddf:	83 ec 0c             	sub    $0xc,%esp
  801de2:	50                   	push   %eax
  801de3:	e8 42 e5 ff ff       	call   80032a <sys_ipc_recv>
  801de8:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801deb:	85 f6                	test   %esi,%esi
  801ded:	0f 95 c1             	setne  %cl
  801df0:	85 db                	test   %ebx,%ebx
  801df2:	0f 95 c2             	setne  %dl
  801df5:	84 d1                	test   %dl,%cl
  801df7:	74 09                	je     801e02 <ipc_recv+0x47>
  801df9:	89 c2                	mov    %eax,%edx
  801dfb:	c1 ea 1f             	shr    $0x1f,%edx
  801dfe:	84 d2                	test   %dl,%dl
  801e00:	75 2a                	jne    801e2c <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e02:	85 f6                	test   %esi,%esi
  801e04:	74 0d                	je     801e13 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e06:	a1 04 40 80 00       	mov    0x804004,%eax
  801e0b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e11:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e13:	85 db                	test   %ebx,%ebx
  801e15:	74 0d                	je     801e24 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e17:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1c:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e22:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e24:	a1 04 40 80 00       	mov    0x804004,%eax
  801e29:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2f:	5b                   	pop    %ebx
  801e30:	5e                   	pop    %esi
  801e31:	5d                   	pop    %ebp
  801e32:	c3                   	ret    

00801e33 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
  801e36:	57                   	push   %edi
  801e37:	56                   	push   %esi
  801e38:	53                   	push   %ebx
  801e39:	83 ec 0c             	sub    $0xc,%esp
  801e3c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e45:	85 db                	test   %ebx,%ebx
  801e47:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e4c:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e4f:	ff 75 14             	pushl  0x14(%ebp)
  801e52:	53                   	push   %ebx
  801e53:	56                   	push   %esi
  801e54:	57                   	push   %edi
  801e55:	e8 ad e4 ff ff       	call   800307 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e5a:	89 c2                	mov    %eax,%edx
  801e5c:	c1 ea 1f             	shr    $0x1f,%edx
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	84 d2                	test   %dl,%dl
  801e64:	74 17                	je     801e7d <ipc_send+0x4a>
  801e66:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e69:	74 12                	je     801e7d <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e6b:	50                   	push   %eax
  801e6c:	68 72 26 80 00       	push   $0x802672
  801e71:	6a 47                	push   $0x47
  801e73:	68 80 26 80 00       	push   $0x802680
  801e78:	e8 0a f5 ff ff       	call   801387 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e7d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e80:	75 07                	jne    801e89 <ipc_send+0x56>
			sys_yield();
  801e82:	e8 d4 e2 ff ff       	call   80015b <sys_yield>
  801e87:	eb c6                	jmp    801e4f <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	75 c2                	jne    801e4f <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e90:	5b                   	pop    %ebx
  801e91:	5e                   	pop    %esi
  801e92:	5f                   	pop    %edi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ea0:	89 c2                	mov    %eax,%edx
  801ea2:	c1 e2 07             	shl    $0x7,%edx
  801ea5:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801eac:	8b 52 5c             	mov    0x5c(%edx),%edx
  801eaf:	39 ca                	cmp    %ecx,%edx
  801eb1:	75 11                	jne    801ec4 <ipc_find_env+0x2f>
			return envs[i].env_id;
  801eb3:	89 c2                	mov    %eax,%edx
  801eb5:	c1 e2 07             	shl    $0x7,%edx
  801eb8:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801ebf:	8b 40 54             	mov    0x54(%eax),%eax
  801ec2:	eb 0f                	jmp    801ed3 <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ec4:	83 c0 01             	add    $0x1,%eax
  801ec7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ecc:	75 d2                	jne    801ea0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ece:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801edb:	89 d0                	mov    %edx,%eax
  801edd:	c1 e8 16             	shr    $0x16,%eax
  801ee0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ee7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eec:	f6 c1 01             	test   $0x1,%cl
  801eef:	74 1d                	je     801f0e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ef1:	c1 ea 0c             	shr    $0xc,%edx
  801ef4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801efb:	f6 c2 01             	test   $0x1,%dl
  801efe:	74 0e                	je     801f0e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f00:	c1 ea 0c             	shr    $0xc,%edx
  801f03:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f0a:	ef 
  801f0b:	0f b7 c0             	movzwl %ax,%eax
}
  801f0e:	5d                   	pop    %ebp
  801f0f:	c3                   	ret    

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
