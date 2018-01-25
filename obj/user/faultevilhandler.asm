
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 5e 01 00 00       	call   8001a5 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 9a 02 00 00       	call   8002f0 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 f2 00 00 00       	call   800167 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	89 c2                	mov    %eax,%edx
  80007c:	c1 e2 07             	shl    $0x7,%edx
  80007f:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800086:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008b:	85 db                	test   %ebx,%ebx
  80008d:	7e 07                	jle    800096 <libmain+0x31>
		binaryname = argv[0];
  80008f:	8b 06                	mov    (%esi),%eax
  800091:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
  80009b:	e8 93 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 2a 00 00 00       	call   8000cf <exit>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000b5:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000ba:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000bc:	e8 a6 00 00 00       	call   800167 <sys_getenvid>
  8000c1:	83 ec 0c             	sub    $0xc,%esp
  8000c4:	50                   	push   %eax
  8000c5:	e8 ec 02 00 00       	call   8003b6 <sys_thread_free>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	c9                   	leave  
  8000ce:	c3                   	ret    

008000cf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d5:	e8 b9 07 00 00       	call   800893 <close_all>
	sys_env_destroy(0);
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	6a 00                	push   $0x0
  8000df:	e8 42 00 00 00       	call   800126 <sys_env_destroy>
}
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    

008000e9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 c3                	mov    %eax,%ebx
  8000fc:	89 c7                	mov    %eax,%edi
  8000fe:	89 c6                	mov    %eax,%esi
  800100:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5f                   	pop    %edi
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <sys_cgetc>:

int
sys_cgetc(void)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	57                   	push   %edi
  80010b:	56                   	push   %esi
  80010c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010d:	ba 00 00 00 00       	mov    $0x0,%edx
  800112:	b8 01 00 00 00       	mov    $0x1,%eax
  800117:	89 d1                	mov    %edx,%ecx
  800119:	89 d3                	mov    %edx,%ebx
  80011b:	89 d7                	mov    %edx,%edi
  80011d:	89 d6                	mov    %edx,%esi
  80011f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5f                   	pop    %edi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	57                   	push   %edi
  80012a:	56                   	push   %esi
  80012b:	53                   	push   %ebx
  80012c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800134:	b8 03 00 00 00       	mov    $0x3,%eax
  800139:	8b 55 08             	mov    0x8(%ebp),%edx
  80013c:	89 cb                	mov    %ecx,%ebx
  80013e:	89 cf                	mov    %ecx,%edi
  800140:	89 ce                	mov    %ecx,%esi
  800142:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800144:	85 c0                	test   %eax,%eax
  800146:	7e 17                	jle    80015f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800148:	83 ec 0c             	sub    $0xc,%esp
  80014b:	50                   	push   %eax
  80014c:	6a 03                	push   $0x3
  80014e:	68 ea 21 80 00       	push   $0x8021ea
  800153:	6a 23                	push   $0x23
  800155:	68 07 22 80 00       	push   $0x802207
  80015a:	e8 53 12 00 00       	call   8013b2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800162:	5b                   	pop    %ebx
  800163:	5e                   	pop    %esi
  800164:	5f                   	pop    %edi
  800165:	5d                   	pop    %ebp
  800166:	c3                   	ret    

00800167 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016d:	ba 00 00 00 00       	mov    $0x0,%edx
  800172:	b8 02 00 00 00       	mov    $0x2,%eax
  800177:	89 d1                	mov    %edx,%ecx
  800179:	89 d3                	mov    %edx,%ebx
  80017b:	89 d7                	mov    %edx,%edi
  80017d:	89 d6                	mov    %edx,%esi
  80017f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5f                   	pop    %edi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    

00800186 <sys_yield>:

void
sys_yield(void)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	57                   	push   %edi
  80018a:	56                   	push   %esi
  80018b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018c:	ba 00 00 00 00       	mov    $0x0,%edx
  800191:	b8 0b 00 00 00       	mov    $0xb,%eax
  800196:	89 d1                	mov    %edx,%ecx
  800198:	89 d3                	mov    %edx,%ebx
  80019a:	89 d7                	mov    %edx,%edi
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    

008001a5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ae:	be 00 00 00 00       	mov    $0x0,%esi
  8001b3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c1:	89 f7                	mov    %esi,%edi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 04                	push   $0x4
  8001cf:	68 ea 21 80 00       	push   $0x8021ea
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 07 22 80 00       	push   $0x802207
  8001db:	e8 d2 11 00 00       	call   8013b2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800202:	8b 75 18             	mov    0x18(%ebp),%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 05                	push   $0x5
  800211:	68 ea 21 80 00       	push   $0x8021ea
  800216:	6a 23                	push   $0x23
  800218:	68 07 22 80 00       	push   $0x802207
  80021d:	e8 90 11 00 00       	call   8013b2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 06 00 00 00       	mov    $0x6,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 06                	push   $0x6
  800253:	68 ea 21 80 00       	push   $0x8021ea
  800258:	6a 23                	push   $0x23
  80025a:	68 07 22 80 00       	push   $0x802207
  80025f:	e8 4e 11 00 00       	call   8013b2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 08 00 00 00       	mov    $0x8,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 08                	push   $0x8
  800295:	68 ea 21 80 00       	push   $0x8021ea
  80029a:	6a 23                	push   $0x23
  80029c:	68 07 22 80 00       	push   $0x802207
  8002a1:	e8 0c 11 00 00       	call   8013b2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 09                	push   $0x9
  8002d7:	68 ea 21 80 00       	push   $0x8021ea
  8002dc:	6a 23                	push   $0x23
  8002de:	68 07 22 80 00       	push   $0x802207
  8002e3:	e8 ca 10 00 00       	call   8013b2 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
  8002f6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	89 df                	mov    %ebx,%edi
  80030b:	89 de                	mov    %ebx,%esi
  80030d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80030f:	85 c0                	test   %eax,%eax
  800311:	7e 17                	jle    80032a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800313:	83 ec 0c             	sub    $0xc,%esp
  800316:	50                   	push   %eax
  800317:	6a 0a                	push   $0xa
  800319:	68 ea 21 80 00       	push   $0x8021ea
  80031e:	6a 23                	push   $0x23
  800320:	68 07 22 80 00       	push   $0x802207
  800325:	e8 88 10 00 00       	call   8013b2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80032a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800338:	be 00 00 00 00       	mov    $0x0,%esi
  80033d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800342:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800345:	8b 55 08             	mov    0x8(%ebp),%edx
  800348:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80034e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	57                   	push   %edi
  800359:	56                   	push   %esi
  80035a:	53                   	push   %ebx
  80035b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800363:	b8 0d 00 00 00       	mov    $0xd,%eax
  800368:	8b 55 08             	mov    0x8(%ebp),%edx
  80036b:	89 cb                	mov    %ecx,%ebx
  80036d:	89 cf                	mov    %ecx,%edi
  80036f:	89 ce                	mov    %ecx,%esi
  800371:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800373:	85 c0                	test   %eax,%eax
  800375:	7e 17                	jle    80038e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800377:	83 ec 0c             	sub    $0xc,%esp
  80037a:	50                   	push   %eax
  80037b:	6a 0d                	push   $0xd
  80037d:	68 ea 21 80 00       	push   $0x8021ea
  800382:	6a 23                	push   $0x23
  800384:	68 07 22 80 00       	push   $0x802207
  800389:	e8 24 10 00 00       	call   8013b2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	57                   	push   %edi
  80039a:	56                   	push   %esi
  80039b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a1:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a9:	89 cb                	mov    %ecx,%ebx
  8003ab:	89 cf                	mov    %ecx,%edi
  8003ad:	89 ce                	mov    %ecx,%esi
  8003af:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  8003b1:	5b                   	pop    %ebx
  8003b2:	5e                   	pop    %esi
  8003b3:	5f                   	pop    %edi
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
  8003b9:	57                   	push   %edi
  8003ba:	56                   	push   %esi
  8003bb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c1:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c9:	89 cb                	mov    %ecx,%ebx
  8003cb:	89 cf                	mov    %ecx,%edi
  8003cd:	89 ce                	mov    %ecx,%esi
  8003cf:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003d1:	5b                   	pop    %ebx
  8003d2:	5e                   	pop    %esi
  8003d3:	5f                   	pop    %edi
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	53                   	push   %ebx
  8003da:	83 ec 04             	sub    $0x4,%esp
  8003dd:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003e0:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003e2:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003e6:	74 11                	je     8003f9 <pgfault+0x23>
  8003e8:	89 d8                	mov    %ebx,%eax
  8003ea:	c1 e8 0c             	shr    $0xc,%eax
  8003ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003f4:	f6 c4 08             	test   $0x8,%ah
  8003f7:	75 14                	jne    80040d <pgfault+0x37>
		panic("faulting access");
  8003f9:	83 ec 04             	sub    $0x4,%esp
  8003fc:	68 15 22 80 00       	push   $0x802215
  800401:	6a 1e                	push   $0x1e
  800403:	68 25 22 80 00       	push   $0x802225
  800408:	e8 a5 0f 00 00       	call   8013b2 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  80040d:	83 ec 04             	sub    $0x4,%esp
  800410:	6a 07                	push   $0x7
  800412:	68 00 f0 7f 00       	push   $0x7ff000
  800417:	6a 00                	push   $0x0
  800419:	e8 87 fd ff ff       	call   8001a5 <sys_page_alloc>
	if (r < 0) {
  80041e:	83 c4 10             	add    $0x10,%esp
  800421:	85 c0                	test   %eax,%eax
  800423:	79 12                	jns    800437 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800425:	50                   	push   %eax
  800426:	68 30 22 80 00       	push   $0x802230
  80042b:	6a 2c                	push   $0x2c
  80042d:	68 25 22 80 00       	push   $0x802225
  800432:	e8 7b 0f 00 00       	call   8013b2 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800437:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80043d:	83 ec 04             	sub    $0x4,%esp
  800440:	68 00 10 00 00       	push   $0x1000
  800445:	53                   	push   %ebx
  800446:	68 00 f0 7f 00       	push   $0x7ff000
  80044b:	e8 ba 17 00 00       	call   801c0a <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800450:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800457:	53                   	push   %ebx
  800458:	6a 00                	push   $0x0
  80045a:	68 00 f0 7f 00       	push   $0x7ff000
  80045f:	6a 00                	push   $0x0
  800461:	e8 82 fd ff ff       	call   8001e8 <sys_page_map>
	if (r < 0) {
  800466:	83 c4 20             	add    $0x20,%esp
  800469:	85 c0                	test   %eax,%eax
  80046b:	79 12                	jns    80047f <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80046d:	50                   	push   %eax
  80046e:	68 30 22 80 00       	push   $0x802230
  800473:	6a 33                	push   $0x33
  800475:	68 25 22 80 00       	push   $0x802225
  80047a:	e8 33 0f 00 00       	call   8013b2 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	68 00 f0 7f 00       	push   $0x7ff000
  800487:	6a 00                	push   $0x0
  800489:	e8 9c fd ff ff       	call   80022a <sys_page_unmap>
	if (r < 0) {
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	85 c0                	test   %eax,%eax
  800493:	79 12                	jns    8004a7 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800495:	50                   	push   %eax
  800496:	68 30 22 80 00       	push   $0x802230
  80049b:	6a 37                	push   $0x37
  80049d:	68 25 22 80 00       	push   $0x802225
  8004a2:	e8 0b 0f 00 00       	call   8013b2 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004aa:	c9                   	leave  
  8004ab:	c3                   	ret    

008004ac <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004b5:	68 d6 03 80 00       	push   $0x8003d6
  8004ba:	e8 98 18 00 00       	call   801d57 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004bf:	b8 07 00 00 00       	mov    $0x7,%eax
  8004c4:	cd 30                	int    $0x30
  8004c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	79 17                	jns    8004e7 <fork+0x3b>
		panic("fork fault %e");
  8004d0:	83 ec 04             	sub    $0x4,%esp
  8004d3:	68 49 22 80 00       	push   $0x802249
  8004d8:	68 84 00 00 00       	push   $0x84
  8004dd:	68 25 22 80 00       	push   $0x802225
  8004e2:	e8 cb 0e 00 00       	call   8013b2 <_panic>
  8004e7:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ed:	75 25                	jne    800514 <fork+0x68>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004ef:	e8 73 fc ff ff       	call   800167 <sys_getenvid>
  8004f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004f9:	89 c2                	mov    %eax,%edx
  8004fb:	c1 e2 07             	shl    $0x7,%edx
  8004fe:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  800505:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	e9 61 01 00 00       	jmp    800675 <fork+0x1c9>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800514:	83 ec 04             	sub    $0x4,%esp
  800517:	6a 07                	push   $0x7
  800519:	68 00 f0 bf ee       	push   $0xeebff000
  80051e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800521:	e8 7f fc ff ff       	call   8001a5 <sys_page_alloc>
  800526:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80052e:	89 d8                	mov    %ebx,%eax
  800530:	c1 e8 16             	shr    $0x16,%eax
  800533:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80053a:	a8 01                	test   $0x1,%al
  80053c:	0f 84 fc 00 00 00    	je     80063e <fork+0x192>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800542:	89 d8                	mov    %ebx,%eax
  800544:	c1 e8 0c             	shr    $0xc,%eax
  800547:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80054e:	f6 c2 01             	test   $0x1,%dl
  800551:	0f 84 e7 00 00 00    	je     80063e <fork+0x192>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800557:	89 c6                	mov    %eax,%esi
  800559:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80055c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800563:	f6 c6 04             	test   $0x4,%dh
  800566:	74 39                	je     8005a1 <fork+0xf5>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800568:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80056f:	83 ec 0c             	sub    $0xc,%esp
  800572:	25 07 0e 00 00       	and    $0xe07,%eax
  800577:	50                   	push   %eax
  800578:	56                   	push   %esi
  800579:	57                   	push   %edi
  80057a:	56                   	push   %esi
  80057b:	6a 00                	push   $0x0
  80057d:	e8 66 fc ff ff       	call   8001e8 <sys_page_map>
		if (r < 0) {
  800582:	83 c4 20             	add    $0x20,%esp
  800585:	85 c0                	test   %eax,%eax
  800587:	0f 89 b1 00 00 00    	jns    80063e <fork+0x192>
		    	panic("sys page map fault %e");
  80058d:	83 ec 04             	sub    $0x4,%esp
  800590:	68 57 22 80 00       	push   $0x802257
  800595:	6a 54                	push   $0x54
  800597:	68 25 22 80 00       	push   $0x802225
  80059c:	e8 11 0e 00 00       	call   8013b2 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8005a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a8:	f6 c2 02             	test   $0x2,%dl
  8005ab:	75 0c                	jne    8005b9 <fork+0x10d>
  8005ad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b4:	f6 c4 08             	test   $0x8,%ah
  8005b7:	74 5b                	je     800614 <fork+0x168>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	68 05 08 00 00       	push   $0x805
  8005c1:	56                   	push   %esi
  8005c2:	57                   	push   %edi
  8005c3:	56                   	push   %esi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 1d fc ff ff       	call   8001e8 <sys_page_map>
		if (r < 0) {
  8005cb:	83 c4 20             	add    $0x20,%esp
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	79 14                	jns    8005e6 <fork+0x13a>
		    	panic("sys page map fault %e");
  8005d2:	83 ec 04             	sub    $0x4,%esp
  8005d5:	68 57 22 80 00       	push   $0x802257
  8005da:	6a 5b                	push   $0x5b
  8005dc:	68 25 22 80 00       	push   $0x802225
  8005e1:	e8 cc 0d 00 00       	call   8013b2 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005e6:	83 ec 0c             	sub    $0xc,%esp
  8005e9:	68 05 08 00 00       	push   $0x805
  8005ee:	56                   	push   %esi
  8005ef:	6a 00                	push   $0x0
  8005f1:	56                   	push   %esi
  8005f2:	6a 00                	push   $0x0
  8005f4:	e8 ef fb ff ff       	call   8001e8 <sys_page_map>
		if (r < 0) {
  8005f9:	83 c4 20             	add    $0x20,%esp
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	79 3e                	jns    80063e <fork+0x192>
		    	panic("sys page map fault %e");
  800600:	83 ec 04             	sub    $0x4,%esp
  800603:	68 57 22 80 00       	push   $0x802257
  800608:	6a 5f                	push   $0x5f
  80060a:	68 25 22 80 00       	push   $0x802225
  80060f:	e8 9e 0d 00 00       	call   8013b2 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800614:	83 ec 0c             	sub    $0xc,%esp
  800617:	6a 05                	push   $0x5
  800619:	56                   	push   %esi
  80061a:	57                   	push   %edi
  80061b:	56                   	push   %esi
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_map>
		if (r < 0) {
  800623:	83 c4 20             	add    $0x20,%esp
  800626:	85 c0                	test   %eax,%eax
  800628:	79 14                	jns    80063e <fork+0x192>
		    	panic("sys page map fault %e");
  80062a:	83 ec 04             	sub    $0x4,%esp
  80062d:	68 57 22 80 00       	push   $0x802257
  800632:	6a 64                	push   $0x64
  800634:	68 25 22 80 00       	push   $0x802225
  800639:	e8 74 0d 00 00       	call   8013b2 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80063e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800644:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80064a:	0f 85 de fe ff ff    	jne    80052e <fork+0x82>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800650:	a1 04 40 80 00       	mov    0x804004,%eax
  800655:	8b 40 70             	mov    0x70(%eax),%eax
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	50                   	push   %eax
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065f:	57                   	push   %edi
  800660:	e8 8b fc ff ff       	call   8002f0 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800665:	83 c4 08             	add    $0x8,%esp
  800668:	6a 02                	push   $0x2
  80066a:	57                   	push   %edi
  80066b:	e8 fc fb ff ff       	call   80026c <sys_env_set_status>
	
	return envid;
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800675:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800678:	5b                   	pop    %ebx
  800679:	5e                   	pop    %esi
  80067a:	5f                   	pop    %edi
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    

0080067d <sfork>:

envid_t
sfork(void)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800680:	b8 00 00 00 00       	mov    $0x0,%eax
  800685:	5d                   	pop    %ebp
  800686:	c3                   	ret    

00800687 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	56                   	push   %esi
  80068b:	53                   	push   %ebx
  80068c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  80068f:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	68 70 22 80 00       	push   $0x802270
  80069e:	e8 e8 0d 00 00       	call   80148b <cprintf>
	//envid_t id = sys_thread_create((uintptr_t )func);
	//uintptr_t funct = (uintptr_t)threadmain;
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006a3:	c7 04 24 af 00 80 00 	movl   $0x8000af,(%esp)
  8006aa:	e8 e7 fc ff ff       	call   800396 <sys_thread_create>
  8006af:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006b1:	83 c4 08             	add    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	68 70 22 80 00       	push   $0x802270
  8006ba:	e8 cc 0d 00 00       	call   80148b <cprintf>
	return id;
	//return 0;
}
  8006bf:	89 f0                	mov    %esi,%eax
  8006c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006c4:	5b                   	pop    %ebx
  8006c5:	5e                   	pop    %esi
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ce:	05 00 00 00 30       	add    $0x30000000,%eax
  8006d3:	c1 e8 0c             	shr    $0xc,%eax
}
  8006d6:	5d                   	pop    %ebp
  8006d7:	c3                   	ret    

008006d8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006db:	8b 45 08             	mov    0x8(%ebp),%eax
  8006de:	05 00 00 00 30       	add    $0x30000000,%eax
  8006e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006e8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006ed:	5d                   	pop    %ebp
  8006ee:	c3                   	ret    

008006ef <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006fa:	89 c2                	mov    %eax,%edx
  8006fc:	c1 ea 16             	shr    $0x16,%edx
  8006ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800706:	f6 c2 01             	test   $0x1,%dl
  800709:	74 11                	je     80071c <fd_alloc+0x2d>
  80070b:	89 c2                	mov    %eax,%edx
  80070d:	c1 ea 0c             	shr    $0xc,%edx
  800710:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800717:	f6 c2 01             	test   $0x1,%dl
  80071a:	75 09                	jne    800725 <fd_alloc+0x36>
			*fd_store = fd;
  80071c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80071e:	b8 00 00 00 00       	mov    $0x0,%eax
  800723:	eb 17                	jmp    80073c <fd_alloc+0x4d>
  800725:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80072a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80072f:	75 c9                	jne    8006fa <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800731:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800737:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80073c:	5d                   	pop    %ebp
  80073d:	c3                   	ret    

0080073e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800744:	83 f8 1f             	cmp    $0x1f,%eax
  800747:	77 36                	ja     80077f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800749:	c1 e0 0c             	shl    $0xc,%eax
  80074c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800751:	89 c2                	mov    %eax,%edx
  800753:	c1 ea 16             	shr    $0x16,%edx
  800756:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80075d:	f6 c2 01             	test   $0x1,%dl
  800760:	74 24                	je     800786 <fd_lookup+0x48>
  800762:	89 c2                	mov    %eax,%edx
  800764:	c1 ea 0c             	shr    $0xc,%edx
  800767:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80076e:	f6 c2 01             	test   $0x1,%dl
  800771:	74 1a                	je     80078d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
  800776:	89 02                	mov    %eax,(%edx)
	return 0;
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 13                	jmp    800792 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80077f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800784:	eb 0c                	jmp    800792 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800786:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078b:	eb 05                	jmp    800792 <fd_lookup+0x54>
  80078d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	ba 10 23 80 00       	mov    $0x802310,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007a2:	eb 13                	jmp    8007b7 <dev_lookup+0x23>
  8007a4:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007a7:	39 08                	cmp    %ecx,(%eax)
  8007a9:	75 0c                	jne    8007b7 <dev_lookup+0x23>
			*dev = devtab[i];
  8007ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ae:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b5:	eb 2e                	jmp    8007e5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007b7:	8b 02                	mov    (%edx),%eax
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	75 e7                	jne    8007a4 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007bd:	a1 04 40 80 00       	mov    0x804004,%eax
  8007c2:	8b 40 54             	mov    0x54(%eax),%eax
  8007c5:	83 ec 04             	sub    $0x4,%esp
  8007c8:	51                   	push   %ecx
  8007c9:	50                   	push   %eax
  8007ca:	68 94 22 80 00       	push   $0x802294
  8007cf:	e8 b7 0c 00 00       	call   80148b <cprintf>
	*dev = 0;
  8007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007dd:	83 c4 10             	add    $0x10,%esp
  8007e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	56                   	push   %esi
  8007eb:	53                   	push   %ebx
  8007ec:	83 ec 10             	sub    $0x10,%esp
  8007ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f8:	50                   	push   %eax
  8007f9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8007ff:	c1 e8 0c             	shr    $0xc,%eax
  800802:	50                   	push   %eax
  800803:	e8 36 ff ff ff       	call   80073e <fd_lookup>
  800808:	83 c4 08             	add    $0x8,%esp
  80080b:	85 c0                	test   %eax,%eax
  80080d:	78 05                	js     800814 <fd_close+0x2d>
	    || fd != fd2)
  80080f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800812:	74 0c                	je     800820 <fd_close+0x39>
		return (must_exist ? r : 0);
  800814:	84 db                	test   %bl,%bl
  800816:	ba 00 00 00 00       	mov    $0x0,%edx
  80081b:	0f 44 c2             	cmove  %edx,%eax
  80081e:	eb 41                	jmp    800861 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800826:	50                   	push   %eax
  800827:	ff 36                	pushl  (%esi)
  800829:	e8 66 ff ff ff       	call   800794 <dev_lookup>
  80082e:	89 c3                	mov    %eax,%ebx
  800830:	83 c4 10             	add    $0x10,%esp
  800833:	85 c0                	test   %eax,%eax
  800835:	78 1a                	js     800851 <fd_close+0x6a>
		if (dev->dev_close)
  800837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80083d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800842:	85 c0                	test   %eax,%eax
  800844:	74 0b                	je     800851 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800846:	83 ec 0c             	sub    $0xc,%esp
  800849:	56                   	push   %esi
  80084a:	ff d0                	call   *%eax
  80084c:	89 c3                	mov    %eax,%ebx
  80084e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	56                   	push   %esi
  800855:	6a 00                	push   $0x0
  800857:	e8 ce f9 ff ff       	call   80022a <sys_page_unmap>
	return r;
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	89 d8                	mov    %ebx,%eax
}
  800861:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80086e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800871:	50                   	push   %eax
  800872:	ff 75 08             	pushl  0x8(%ebp)
  800875:	e8 c4 fe ff ff       	call   80073e <fd_lookup>
  80087a:	83 c4 08             	add    $0x8,%esp
  80087d:	85 c0                	test   %eax,%eax
  80087f:	78 10                	js     800891 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	6a 01                	push   $0x1
  800886:	ff 75 f4             	pushl  -0xc(%ebp)
  800889:	e8 59 ff ff ff       	call   8007e7 <fd_close>
  80088e:	83 c4 10             	add    $0x10,%esp
}
  800891:	c9                   	leave  
  800892:	c3                   	ret    

00800893 <close_all>:

void
close_all(void)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80089a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80089f:	83 ec 0c             	sub    $0xc,%esp
  8008a2:	53                   	push   %ebx
  8008a3:	e8 c0 ff ff ff       	call   800868 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008a8:	83 c3 01             	add    $0x1,%ebx
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	83 fb 20             	cmp    $0x20,%ebx
  8008b1:	75 ec                	jne    80089f <close_all+0xc>
		close(i);
}
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	57                   	push   %edi
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
  8008be:	83 ec 2c             	sub    $0x2c,%esp
  8008c1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008c7:	50                   	push   %eax
  8008c8:	ff 75 08             	pushl  0x8(%ebp)
  8008cb:	e8 6e fe ff ff       	call   80073e <fd_lookup>
  8008d0:	83 c4 08             	add    $0x8,%esp
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	0f 88 c1 00 00 00    	js     80099c <dup+0xe4>
		return r;
	close(newfdnum);
  8008db:	83 ec 0c             	sub    $0xc,%esp
  8008de:	56                   	push   %esi
  8008df:	e8 84 ff ff ff       	call   800868 <close>

	newfd = INDEX2FD(newfdnum);
  8008e4:	89 f3                	mov    %esi,%ebx
  8008e6:	c1 e3 0c             	shl    $0xc,%ebx
  8008e9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008ef:	83 c4 04             	add    $0x4,%esp
  8008f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008f5:	e8 de fd ff ff       	call   8006d8 <fd2data>
  8008fa:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008fc:	89 1c 24             	mov    %ebx,(%esp)
  8008ff:	e8 d4 fd ff ff       	call   8006d8 <fd2data>
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80090a:	89 f8                	mov    %edi,%eax
  80090c:	c1 e8 16             	shr    $0x16,%eax
  80090f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800916:	a8 01                	test   $0x1,%al
  800918:	74 37                	je     800951 <dup+0x99>
  80091a:	89 f8                	mov    %edi,%eax
  80091c:	c1 e8 0c             	shr    $0xc,%eax
  80091f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800926:	f6 c2 01             	test   $0x1,%dl
  800929:	74 26                	je     800951 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80092b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800932:	83 ec 0c             	sub    $0xc,%esp
  800935:	25 07 0e 00 00       	and    $0xe07,%eax
  80093a:	50                   	push   %eax
  80093b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80093e:	6a 00                	push   $0x0
  800940:	57                   	push   %edi
  800941:	6a 00                	push   $0x0
  800943:	e8 a0 f8 ff ff       	call   8001e8 <sys_page_map>
  800948:	89 c7                	mov    %eax,%edi
  80094a:	83 c4 20             	add    $0x20,%esp
  80094d:	85 c0                	test   %eax,%eax
  80094f:	78 2e                	js     80097f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800951:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800954:	89 d0                	mov    %edx,%eax
  800956:	c1 e8 0c             	shr    $0xc,%eax
  800959:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800960:	83 ec 0c             	sub    $0xc,%esp
  800963:	25 07 0e 00 00       	and    $0xe07,%eax
  800968:	50                   	push   %eax
  800969:	53                   	push   %ebx
  80096a:	6a 00                	push   $0x0
  80096c:	52                   	push   %edx
  80096d:	6a 00                	push   $0x0
  80096f:	e8 74 f8 ff ff       	call   8001e8 <sys_page_map>
  800974:	89 c7                	mov    %eax,%edi
  800976:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800979:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80097b:	85 ff                	test   %edi,%edi
  80097d:	79 1d                	jns    80099c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80097f:	83 ec 08             	sub    $0x8,%esp
  800982:	53                   	push   %ebx
  800983:	6a 00                	push   $0x0
  800985:	e8 a0 f8 ff ff       	call   80022a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80098a:	83 c4 08             	add    $0x8,%esp
  80098d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800990:	6a 00                	push   $0x0
  800992:	e8 93 f8 ff ff       	call   80022a <sys_page_unmap>
	return r;
  800997:	83 c4 10             	add    $0x10,%esp
  80099a:	89 f8                	mov    %edi,%eax
}
  80099c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80099f:	5b                   	pop    %ebx
  8009a0:	5e                   	pop    %esi
  8009a1:	5f                   	pop    %edi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	53                   	push   %ebx
  8009a8:	83 ec 14             	sub    $0x14,%esp
  8009ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009b1:	50                   	push   %eax
  8009b2:	53                   	push   %ebx
  8009b3:	e8 86 fd ff ff       	call   80073e <fd_lookup>
  8009b8:	83 c4 08             	add    $0x8,%esp
  8009bb:	89 c2                	mov    %eax,%edx
  8009bd:	85 c0                	test   %eax,%eax
  8009bf:	78 6d                	js     800a2e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009c1:	83 ec 08             	sub    $0x8,%esp
  8009c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009c7:	50                   	push   %eax
  8009c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009cb:	ff 30                	pushl  (%eax)
  8009cd:	e8 c2 fd ff ff       	call   800794 <dev_lookup>
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	85 c0                	test   %eax,%eax
  8009d7:	78 4c                	js     800a25 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009dc:	8b 42 08             	mov    0x8(%edx),%eax
  8009df:	83 e0 03             	and    $0x3,%eax
  8009e2:	83 f8 01             	cmp    $0x1,%eax
  8009e5:	75 21                	jne    800a08 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8009ec:	8b 40 54             	mov    0x54(%eax),%eax
  8009ef:	83 ec 04             	sub    $0x4,%esp
  8009f2:	53                   	push   %ebx
  8009f3:	50                   	push   %eax
  8009f4:	68 d5 22 80 00       	push   $0x8022d5
  8009f9:	e8 8d 0a 00 00       	call   80148b <cprintf>
		return -E_INVAL;
  8009fe:	83 c4 10             	add    $0x10,%esp
  800a01:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a06:	eb 26                	jmp    800a2e <read+0x8a>
	}
	if (!dev->dev_read)
  800a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a0b:	8b 40 08             	mov    0x8(%eax),%eax
  800a0e:	85 c0                	test   %eax,%eax
  800a10:	74 17                	je     800a29 <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a12:	83 ec 04             	sub    $0x4,%esp
  800a15:	ff 75 10             	pushl  0x10(%ebp)
  800a18:	ff 75 0c             	pushl  0xc(%ebp)
  800a1b:	52                   	push   %edx
  800a1c:	ff d0                	call   *%eax
  800a1e:	89 c2                	mov    %eax,%edx
  800a20:	83 c4 10             	add    $0x10,%esp
  800a23:	eb 09                	jmp    800a2e <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a25:	89 c2                	mov    %eax,%edx
  800a27:	eb 05                	jmp    800a2e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a29:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a2e:	89 d0                	mov    %edx,%eax
  800a30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	83 ec 0c             	sub    $0xc,%esp
  800a3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a41:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a49:	eb 21                	jmp    800a6c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a4b:	83 ec 04             	sub    $0x4,%esp
  800a4e:	89 f0                	mov    %esi,%eax
  800a50:	29 d8                	sub    %ebx,%eax
  800a52:	50                   	push   %eax
  800a53:	89 d8                	mov    %ebx,%eax
  800a55:	03 45 0c             	add    0xc(%ebp),%eax
  800a58:	50                   	push   %eax
  800a59:	57                   	push   %edi
  800a5a:	e8 45 ff ff ff       	call   8009a4 <read>
		if (m < 0)
  800a5f:	83 c4 10             	add    $0x10,%esp
  800a62:	85 c0                	test   %eax,%eax
  800a64:	78 10                	js     800a76 <readn+0x41>
			return m;
		if (m == 0)
  800a66:	85 c0                	test   %eax,%eax
  800a68:	74 0a                	je     800a74 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a6a:	01 c3                	add    %eax,%ebx
  800a6c:	39 f3                	cmp    %esi,%ebx
  800a6e:	72 db                	jb     800a4b <readn+0x16>
  800a70:	89 d8                	mov    %ebx,%eax
  800a72:	eb 02                	jmp    800a76 <readn+0x41>
  800a74:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5f                   	pop    %edi
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	53                   	push   %ebx
  800a82:	83 ec 14             	sub    $0x14,%esp
  800a85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a88:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a8b:	50                   	push   %eax
  800a8c:	53                   	push   %ebx
  800a8d:	e8 ac fc ff ff       	call   80073e <fd_lookup>
  800a92:	83 c4 08             	add    $0x8,%esp
  800a95:	89 c2                	mov    %eax,%edx
  800a97:	85 c0                	test   %eax,%eax
  800a99:	78 68                	js     800b03 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a9b:	83 ec 08             	sub    $0x8,%esp
  800a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa1:	50                   	push   %eax
  800aa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aa5:	ff 30                	pushl  (%eax)
  800aa7:	e8 e8 fc ff ff       	call   800794 <dev_lookup>
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	78 47                	js     800afa <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800aba:	75 21                	jne    800add <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800abc:	a1 04 40 80 00       	mov    0x804004,%eax
  800ac1:	8b 40 54             	mov    0x54(%eax),%eax
  800ac4:	83 ec 04             	sub    $0x4,%esp
  800ac7:	53                   	push   %ebx
  800ac8:	50                   	push   %eax
  800ac9:	68 f1 22 80 00       	push   $0x8022f1
  800ace:	e8 b8 09 00 00       	call   80148b <cprintf>
		return -E_INVAL;
  800ad3:	83 c4 10             	add    $0x10,%esp
  800ad6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800adb:	eb 26                	jmp    800b03 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800add:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae0:	8b 52 0c             	mov    0xc(%edx),%edx
  800ae3:	85 d2                	test   %edx,%edx
  800ae5:	74 17                	je     800afe <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ae7:	83 ec 04             	sub    $0x4,%esp
  800aea:	ff 75 10             	pushl  0x10(%ebp)
  800aed:	ff 75 0c             	pushl  0xc(%ebp)
  800af0:	50                   	push   %eax
  800af1:	ff d2                	call   *%edx
  800af3:	89 c2                	mov    %eax,%edx
  800af5:	83 c4 10             	add    $0x10,%esp
  800af8:	eb 09                	jmp    800b03 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800afa:	89 c2                	mov    %eax,%edx
  800afc:	eb 05                	jmp    800b03 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800afe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b03:	89 d0                	mov    %edx,%eax
  800b05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    

00800b0a <seek>:

int
seek(int fdnum, off_t offset)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b10:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b13:	50                   	push   %eax
  800b14:	ff 75 08             	pushl  0x8(%ebp)
  800b17:	e8 22 fc ff ff       	call   80073e <fd_lookup>
  800b1c:	83 c4 08             	add    $0x8,%esp
  800b1f:	85 c0                	test   %eax,%eax
  800b21:	78 0e                	js     800b31 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b23:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b29:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b31:	c9                   	leave  
  800b32:	c3                   	ret    

00800b33 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	53                   	push   %ebx
  800b37:	83 ec 14             	sub    $0x14,%esp
  800b3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b40:	50                   	push   %eax
  800b41:	53                   	push   %ebx
  800b42:	e8 f7 fb ff ff       	call   80073e <fd_lookup>
  800b47:	83 c4 08             	add    $0x8,%esp
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	78 65                	js     800bb5 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b50:	83 ec 08             	sub    $0x8,%esp
  800b53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b56:	50                   	push   %eax
  800b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b5a:	ff 30                	pushl  (%eax)
  800b5c:	e8 33 fc ff ff       	call   800794 <dev_lookup>
  800b61:	83 c4 10             	add    $0x10,%esp
  800b64:	85 c0                	test   %eax,%eax
  800b66:	78 44                	js     800bac <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b6b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b6f:	75 21                	jne    800b92 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b71:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b76:	8b 40 54             	mov    0x54(%eax),%eax
  800b79:	83 ec 04             	sub    $0x4,%esp
  800b7c:	53                   	push   %ebx
  800b7d:	50                   	push   %eax
  800b7e:	68 b4 22 80 00       	push   $0x8022b4
  800b83:	e8 03 09 00 00       	call   80148b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b88:	83 c4 10             	add    $0x10,%esp
  800b8b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b90:	eb 23                	jmp    800bb5 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b92:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b95:	8b 52 18             	mov    0x18(%edx),%edx
  800b98:	85 d2                	test   %edx,%edx
  800b9a:	74 14                	je     800bb0 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b9c:	83 ec 08             	sub    $0x8,%esp
  800b9f:	ff 75 0c             	pushl  0xc(%ebp)
  800ba2:	50                   	push   %eax
  800ba3:	ff d2                	call   *%edx
  800ba5:	89 c2                	mov    %eax,%edx
  800ba7:	83 c4 10             	add    $0x10,%esp
  800baa:	eb 09                	jmp    800bb5 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bac:	89 c2                	mov    %eax,%edx
  800bae:	eb 05                	jmp    800bb5 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800bb0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800bb5:	89 d0                	mov    %edx,%eax
  800bb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 14             	sub    $0x14,%esp
  800bc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bc6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bc9:	50                   	push   %eax
  800bca:	ff 75 08             	pushl  0x8(%ebp)
  800bcd:	e8 6c fb ff ff       	call   80073e <fd_lookup>
  800bd2:	83 c4 08             	add    $0x8,%esp
  800bd5:	89 c2                	mov    %eax,%edx
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	78 58                	js     800c33 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bdb:	83 ec 08             	sub    $0x8,%esp
  800bde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800be1:	50                   	push   %eax
  800be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be5:	ff 30                	pushl  (%eax)
  800be7:	e8 a8 fb ff ff       	call   800794 <dev_lookup>
  800bec:	83 c4 10             	add    $0x10,%esp
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	78 37                	js     800c2a <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bfa:	74 32                	je     800c2e <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bfc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800bff:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c06:	00 00 00 
	stat->st_isdir = 0;
  800c09:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c10:	00 00 00 
	stat->st_dev = dev;
  800c13:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c19:	83 ec 08             	sub    $0x8,%esp
  800c1c:	53                   	push   %ebx
  800c1d:	ff 75 f0             	pushl  -0x10(%ebp)
  800c20:	ff 50 14             	call   *0x14(%eax)
  800c23:	89 c2                	mov    %eax,%edx
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	eb 09                	jmp    800c33 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c2a:	89 c2                	mov    %eax,%edx
  800c2c:	eb 05                	jmp    800c33 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c2e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c33:	89 d0                	mov    %edx,%eax
  800c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c3f:	83 ec 08             	sub    $0x8,%esp
  800c42:	6a 00                	push   $0x0
  800c44:	ff 75 08             	pushl  0x8(%ebp)
  800c47:	e8 e3 01 00 00       	call   800e2f <open>
  800c4c:	89 c3                	mov    %eax,%ebx
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	85 c0                	test   %eax,%eax
  800c53:	78 1b                	js     800c70 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c55:	83 ec 08             	sub    $0x8,%esp
  800c58:	ff 75 0c             	pushl  0xc(%ebp)
  800c5b:	50                   	push   %eax
  800c5c:	e8 5b ff ff ff       	call   800bbc <fstat>
  800c61:	89 c6                	mov    %eax,%esi
	close(fd);
  800c63:	89 1c 24             	mov    %ebx,(%esp)
  800c66:	e8 fd fb ff ff       	call   800868 <close>
	return r;
  800c6b:	83 c4 10             	add    $0x10,%esp
  800c6e:	89 f0                	mov    %esi,%eax
}
  800c70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	89 c6                	mov    %eax,%esi
  800c7e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c80:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c87:	75 12                	jne    800c9b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	6a 01                	push   $0x1
  800c8e:	e8 2d 12 00 00       	call   801ec0 <ipc_find_env>
  800c93:	a3 00 40 80 00       	mov    %eax,0x804000
  800c98:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c9b:	6a 07                	push   $0x7
  800c9d:	68 00 50 80 00       	push   $0x805000
  800ca2:	56                   	push   %esi
  800ca3:	ff 35 00 40 80 00    	pushl  0x804000
  800ca9:	e8 b0 11 00 00       	call   801e5e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800cae:	83 c4 0c             	add    $0xc,%esp
  800cb1:	6a 00                	push   $0x0
  800cb3:	53                   	push   %ebx
  800cb4:	6a 00                	push   $0x0
  800cb6:	e8 2b 11 00 00       	call   801de6 <ipc_recv>
}
  800cbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	8b 40 0c             	mov    0xc(%eax),%eax
  800cce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce5:	e8 8d ff ff ff       	call   800c77 <fsipc>
}
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    

00800cec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	8b 40 0c             	mov    0xc(%eax),%eax
  800cf8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	b8 06 00 00 00       	mov    $0x6,%eax
  800d07:	e8 6b ff ff ff       	call   800c77 <fsipc>
}
  800d0c:	c9                   	leave  
  800d0d:	c3                   	ret    

00800d0e <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	53                   	push   %ebx
  800d12:	83 ec 04             	sub    $0x4,%esp
  800d15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	8b 40 0c             	mov    0xc(%eax),%eax
  800d1e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d23:	ba 00 00 00 00       	mov    $0x0,%edx
  800d28:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2d:	e8 45 ff ff ff       	call   800c77 <fsipc>
  800d32:	85 c0                	test   %eax,%eax
  800d34:	78 2c                	js     800d62 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d36:	83 ec 08             	sub    $0x8,%esp
  800d39:	68 00 50 80 00       	push   $0x805000
  800d3e:	53                   	push   %ebx
  800d3f:	e8 cc 0c 00 00       	call   801a10 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d44:	a1 80 50 80 00       	mov    0x805080,%eax
  800d49:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d4f:	a1 84 50 80 00       	mov    0x805084,%eax
  800d54:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    

00800d67 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	8b 52 0c             	mov    0xc(%edx),%edx
  800d76:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d7c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d81:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d86:	0f 47 c2             	cmova  %edx,%eax
  800d89:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d8e:	50                   	push   %eax
  800d8f:	ff 75 0c             	pushl  0xc(%ebp)
  800d92:	68 08 50 80 00       	push   $0x805008
  800d97:	e8 06 0e 00 00       	call   801ba2 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800da1:	b8 04 00 00 00       	mov    $0x4,%eax
  800da6:	e8 cc fe ff ff       	call   800c77 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800dab:	c9                   	leave  
  800dac:	c3                   	ret    

00800dad <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	8b 40 0c             	mov    0xc(%eax),%eax
  800dbb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800dc0:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800dc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcb:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd0:	e8 a2 fe ff ff       	call   800c77 <fsipc>
  800dd5:	89 c3                	mov    %eax,%ebx
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	78 4b                	js     800e26 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ddb:	39 c6                	cmp    %eax,%esi
  800ddd:	73 16                	jae    800df5 <devfile_read+0x48>
  800ddf:	68 20 23 80 00       	push   $0x802320
  800de4:	68 27 23 80 00       	push   $0x802327
  800de9:	6a 7c                	push   $0x7c
  800deb:	68 3c 23 80 00       	push   $0x80233c
  800df0:	e8 bd 05 00 00       	call   8013b2 <_panic>
	assert(r <= PGSIZE);
  800df5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800dfa:	7e 16                	jle    800e12 <devfile_read+0x65>
  800dfc:	68 47 23 80 00       	push   $0x802347
  800e01:	68 27 23 80 00       	push   $0x802327
  800e06:	6a 7d                	push   $0x7d
  800e08:	68 3c 23 80 00       	push   $0x80233c
  800e0d:	e8 a0 05 00 00       	call   8013b2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	50                   	push   %eax
  800e16:	68 00 50 80 00       	push   $0x805000
  800e1b:	ff 75 0c             	pushl  0xc(%ebp)
  800e1e:	e8 7f 0d 00 00       	call   801ba2 <memmove>
	return r;
  800e23:	83 c4 10             	add    $0x10,%esp
}
  800e26:	89 d8                	mov    %ebx,%eax
  800e28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e2b:	5b                   	pop    %ebx
  800e2c:	5e                   	pop    %esi
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	53                   	push   %ebx
  800e33:	83 ec 20             	sub    $0x20,%esp
  800e36:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e39:	53                   	push   %ebx
  800e3a:	e8 98 0b 00 00       	call   8019d7 <strlen>
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e47:	7f 67                	jg     800eb0 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e49:	83 ec 0c             	sub    $0xc,%esp
  800e4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e4f:	50                   	push   %eax
  800e50:	e8 9a f8 ff ff       	call   8006ef <fd_alloc>
  800e55:	83 c4 10             	add    $0x10,%esp
		return r;
  800e58:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	78 57                	js     800eb5 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e5e:	83 ec 08             	sub    $0x8,%esp
  800e61:	53                   	push   %ebx
  800e62:	68 00 50 80 00       	push   $0x805000
  800e67:	e8 a4 0b 00 00       	call   801a10 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e77:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7c:	e8 f6 fd ff ff       	call   800c77 <fsipc>
  800e81:	89 c3                	mov    %eax,%ebx
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	85 c0                	test   %eax,%eax
  800e88:	79 14                	jns    800e9e <open+0x6f>
		fd_close(fd, 0);
  800e8a:	83 ec 08             	sub    $0x8,%esp
  800e8d:	6a 00                	push   $0x0
  800e8f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e92:	e8 50 f9 ff ff       	call   8007e7 <fd_close>
		return r;
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	89 da                	mov    %ebx,%edx
  800e9c:	eb 17                	jmp    800eb5 <open+0x86>
	}

	return fd2num(fd);
  800e9e:	83 ec 0c             	sub    $0xc,%esp
  800ea1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea4:	e8 1f f8 ff ff       	call   8006c8 <fd2num>
  800ea9:	89 c2                	mov    %eax,%edx
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	eb 05                	jmp    800eb5 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800eb0:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800eb5:	89 d0                	mov    %edx,%eax
  800eb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ec2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec7:	b8 08 00 00 00       	mov    $0x8,%eax
  800ecc:	e8 a6 fd ff ff       	call   800c77 <fsipc>
}
  800ed1:	c9                   	leave  
  800ed2:	c3                   	ret    

00800ed3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800edb:	83 ec 0c             	sub    $0xc,%esp
  800ede:	ff 75 08             	pushl  0x8(%ebp)
  800ee1:	e8 f2 f7 ff ff       	call   8006d8 <fd2data>
  800ee6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ee8:	83 c4 08             	add    $0x8,%esp
  800eeb:	68 53 23 80 00       	push   $0x802353
  800ef0:	53                   	push   %ebx
  800ef1:	e8 1a 0b 00 00       	call   801a10 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ef6:	8b 46 04             	mov    0x4(%esi),%eax
  800ef9:	2b 06                	sub    (%esi),%eax
  800efb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f01:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f08:	00 00 00 
	stat->st_dev = &devpipe;
  800f0b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f12:	30 80 00 
	return 0;
}
  800f15:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    

00800f21 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	53                   	push   %ebx
  800f25:	83 ec 0c             	sub    $0xc,%esp
  800f28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f2b:	53                   	push   %ebx
  800f2c:	6a 00                	push   $0x0
  800f2e:	e8 f7 f2 ff ff       	call   80022a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f33:	89 1c 24             	mov    %ebx,(%esp)
  800f36:	e8 9d f7 ff ff       	call   8006d8 <fd2data>
  800f3b:	83 c4 08             	add    $0x8,%esp
  800f3e:	50                   	push   %eax
  800f3f:	6a 00                	push   $0x0
  800f41:	e8 e4 f2 ff ff       	call   80022a <sys_page_unmap>
}
  800f46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	57                   	push   %edi
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	83 ec 1c             	sub    $0x1c,%esp
  800f54:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f57:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f59:	a1 04 40 80 00       	mov    0x804004,%eax
  800f5e:	8b 70 64             	mov    0x64(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	ff 75 e0             	pushl  -0x20(%ebp)
  800f67:	e8 94 0f 00 00       	call   801f00 <pageref>
  800f6c:	89 c3                	mov    %eax,%ebx
  800f6e:	89 3c 24             	mov    %edi,(%esp)
  800f71:	e8 8a 0f 00 00       	call   801f00 <pageref>
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	39 c3                	cmp    %eax,%ebx
  800f7b:	0f 94 c1             	sete   %cl
  800f7e:	0f b6 c9             	movzbl %cl,%ecx
  800f81:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f84:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f8a:	8b 4a 64             	mov    0x64(%edx),%ecx
		if (n == nn)
  800f8d:	39 ce                	cmp    %ecx,%esi
  800f8f:	74 1b                	je     800fac <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800f91:	39 c3                	cmp    %eax,%ebx
  800f93:	75 c4                	jne    800f59 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f95:	8b 42 64             	mov    0x64(%edx),%eax
  800f98:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f9b:	50                   	push   %eax
  800f9c:	56                   	push   %esi
  800f9d:	68 5a 23 80 00       	push   $0x80235a
  800fa2:	e8 e4 04 00 00       	call   80148b <cprintf>
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	eb ad                	jmp    800f59 <_pipeisclosed+0xe>
	}
}
  800fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800faf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb2:	5b                   	pop    %ebx
  800fb3:	5e                   	pop    %esi
  800fb4:	5f                   	pop    %edi
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    

00800fb7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	57                   	push   %edi
  800fbb:	56                   	push   %esi
  800fbc:	53                   	push   %ebx
  800fbd:	83 ec 28             	sub    $0x28,%esp
  800fc0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fc3:	56                   	push   %esi
  800fc4:	e8 0f f7 ff ff       	call   8006d8 <fd2data>
  800fc9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	bf 00 00 00 00       	mov    $0x0,%edi
  800fd3:	eb 4b                	jmp    801020 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fd5:	89 da                	mov    %ebx,%edx
  800fd7:	89 f0                	mov    %esi,%eax
  800fd9:	e8 6d ff ff ff       	call   800f4b <_pipeisclosed>
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	75 48                	jne    80102a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fe2:	e8 9f f1 ff ff       	call   800186 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fe7:	8b 43 04             	mov    0x4(%ebx),%eax
  800fea:	8b 0b                	mov    (%ebx),%ecx
  800fec:	8d 51 20             	lea    0x20(%ecx),%edx
  800fef:	39 d0                	cmp    %edx,%eax
  800ff1:	73 e2                	jae    800fd5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ff3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ffa:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ffd:	89 c2                	mov    %eax,%edx
  800fff:	c1 fa 1f             	sar    $0x1f,%edx
  801002:	89 d1                	mov    %edx,%ecx
  801004:	c1 e9 1b             	shr    $0x1b,%ecx
  801007:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80100a:	83 e2 1f             	and    $0x1f,%edx
  80100d:	29 ca                	sub    %ecx,%edx
  80100f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801013:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801017:	83 c0 01             	add    $0x1,%eax
  80101a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80101d:	83 c7 01             	add    $0x1,%edi
  801020:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801023:	75 c2                	jne    800fe7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801025:	8b 45 10             	mov    0x10(%ebp),%eax
  801028:	eb 05                	jmp    80102f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80102a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80102f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801032:	5b                   	pop    %ebx
  801033:	5e                   	pop    %esi
  801034:	5f                   	pop    %edi
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	57                   	push   %edi
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	83 ec 18             	sub    $0x18,%esp
  801040:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801043:	57                   	push   %edi
  801044:	e8 8f f6 ff ff       	call   8006d8 <fd2data>
  801049:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80104b:	83 c4 10             	add    $0x10,%esp
  80104e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801053:	eb 3d                	jmp    801092 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801055:	85 db                	test   %ebx,%ebx
  801057:	74 04                	je     80105d <devpipe_read+0x26>
				return i;
  801059:	89 d8                	mov    %ebx,%eax
  80105b:	eb 44                	jmp    8010a1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80105d:	89 f2                	mov    %esi,%edx
  80105f:	89 f8                	mov    %edi,%eax
  801061:	e8 e5 fe ff ff       	call   800f4b <_pipeisclosed>
  801066:	85 c0                	test   %eax,%eax
  801068:	75 32                	jne    80109c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80106a:	e8 17 f1 ff ff       	call   800186 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80106f:	8b 06                	mov    (%esi),%eax
  801071:	3b 46 04             	cmp    0x4(%esi),%eax
  801074:	74 df                	je     801055 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801076:	99                   	cltd   
  801077:	c1 ea 1b             	shr    $0x1b,%edx
  80107a:	01 d0                	add    %edx,%eax
  80107c:	83 e0 1f             	and    $0x1f,%eax
  80107f:	29 d0                	sub    %edx,%eax
  801081:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801086:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801089:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80108c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80108f:	83 c3 01             	add    $0x1,%ebx
  801092:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801095:	75 d8                	jne    80106f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801097:	8b 45 10             	mov    0x10(%ebp),%eax
  80109a:	eb 05                	jmp    8010a1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80109c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a4:	5b                   	pop    %ebx
  8010a5:	5e                   	pop    %esi
  8010a6:	5f                   	pop    %edi
  8010a7:	5d                   	pop    %ebp
  8010a8:	c3                   	ret    

008010a9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010a9:	55                   	push   %ebp
  8010aa:	89 e5                	mov    %esp,%ebp
  8010ac:	56                   	push   %esi
  8010ad:	53                   	push   %ebx
  8010ae:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b4:	50                   	push   %eax
  8010b5:	e8 35 f6 ff ff       	call   8006ef <fd_alloc>
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	89 c2                	mov    %eax,%edx
  8010bf:	85 c0                	test   %eax,%eax
  8010c1:	0f 88 2c 01 00 00    	js     8011f3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010c7:	83 ec 04             	sub    $0x4,%esp
  8010ca:	68 07 04 00 00       	push   $0x407
  8010cf:	ff 75 f4             	pushl  -0xc(%ebp)
  8010d2:	6a 00                	push   $0x0
  8010d4:	e8 cc f0 ff ff       	call   8001a5 <sys_page_alloc>
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	89 c2                	mov    %eax,%edx
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	0f 88 0d 01 00 00    	js     8011f3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010e6:	83 ec 0c             	sub    $0xc,%esp
  8010e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ec:	50                   	push   %eax
  8010ed:	e8 fd f5 ff ff       	call   8006ef <fd_alloc>
  8010f2:	89 c3                	mov    %eax,%ebx
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	0f 88 e2 00 00 00    	js     8011e1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010ff:	83 ec 04             	sub    $0x4,%esp
  801102:	68 07 04 00 00       	push   $0x407
  801107:	ff 75 f0             	pushl  -0x10(%ebp)
  80110a:	6a 00                	push   $0x0
  80110c:	e8 94 f0 ff ff       	call   8001a5 <sys_page_alloc>
  801111:	89 c3                	mov    %eax,%ebx
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	0f 88 c3 00 00 00    	js     8011e1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80111e:	83 ec 0c             	sub    $0xc,%esp
  801121:	ff 75 f4             	pushl  -0xc(%ebp)
  801124:	e8 af f5 ff ff       	call   8006d8 <fd2data>
  801129:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80112b:	83 c4 0c             	add    $0xc,%esp
  80112e:	68 07 04 00 00       	push   $0x407
  801133:	50                   	push   %eax
  801134:	6a 00                	push   $0x0
  801136:	e8 6a f0 ff ff       	call   8001a5 <sys_page_alloc>
  80113b:	89 c3                	mov    %eax,%ebx
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	85 c0                	test   %eax,%eax
  801142:	0f 88 89 00 00 00    	js     8011d1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801148:	83 ec 0c             	sub    $0xc,%esp
  80114b:	ff 75 f0             	pushl  -0x10(%ebp)
  80114e:	e8 85 f5 ff ff       	call   8006d8 <fd2data>
  801153:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80115a:	50                   	push   %eax
  80115b:	6a 00                	push   $0x0
  80115d:	56                   	push   %esi
  80115e:	6a 00                	push   $0x0
  801160:	e8 83 f0 ff ff       	call   8001e8 <sys_page_map>
  801165:	89 c3                	mov    %eax,%ebx
  801167:	83 c4 20             	add    $0x20,%esp
  80116a:	85 c0                	test   %eax,%eax
  80116c:	78 55                	js     8011c3 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80116e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801174:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801177:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801179:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801183:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801189:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80118e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801191:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	ff 75 f4             	pushl  -0xc(%ebp)
  80119e:	e8 25 f5 ff ff       	call   8006c8 <fd2num>
  8011a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011a8:	83 c4 04             	add    $0x4,%esp
  8011ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8011ae:	e8 15 f5 ff ff       	call   8006c8 <fd2num>
  8011b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b6:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c1:	eb 30                	jmp    8011f3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	56                   	push   %esi
  8011c7:	6a 00                	push   $0x0
  8011c9:	e8 5c f0 ff ff       	call   80022a <sys_page_unmap>
  8011ce:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011d1:	83 ec 08             	sub    $0x8,%esp
  8011d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8011d7:	6a 00                	push   $0x0
  8011d9:	e8 4c f0 ff ff       	call   80022a <sys_page_unmap>
  8011de:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e7:	6a 00                	push   $0x0
  8011e9:	e8 3c f0 ff ff       	call   80022a <sys_page_unmap>
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011f3:	89 d0                	mov    %edx,%eax
  8011f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f8:	5b                   	pop    %ebx
  8011f9:	5e                   	pop    %esi
  8011fa:	5d                   	pop    %ebp
  8011fb:	c3                   	ret    

008011fc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801202:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	ff 75 08             	pushl  0x8(%ebp)
  801209:	e8 30 f5 ff ff       	call   80073e <fd_lookup>
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	78 18                	js     80122d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801215:	83 ec 0c             	sub    $0xc,%esp
  801218:	ff 75 f4             	pushl  -0xc(%ebp)
  80121b:	e8 b8 f4 ff ff       	call   8006d8 <fd2data>
	return _pipeisclosed(fd, p);
  801220:	89 c2                	mov    %eax,%edx
  801222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801225:	e8 21 fd ff ff       	call   800f4b <_pipeisclosed>
  80122a:	83 c4 10             	add    $0x10,%esp
}
  80122d:	c9                   	leave  
  80122e:	c3                   	ret    

0080122f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801232:	b8 00 00 00 00       	mov    $0x0,%eax
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80123f:	68 72 23 80 00       	push   $0x802372
  801244:	ff 75 0c             	pushl  0xc(%ebp)
  801247:	e8 c4 07 00 00       	call   801a10 <strcpy>
	return 0;
}
  80124c:	b8 00 00 00 00       	mov    $0x0,%eax
  801251:	c9                   	leave  
  801252:	c3                   	ret    

00801253 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	57                   	push   %edi
  801257:	56                   	push   %esi
  801258:	53                   	push   %ebx
  801259:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80125f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801264:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80126a:	eb 2d                	jmp    801299 <devcons_write+0x46>
		m = n - tot;
  80126c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80126f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801271:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801274:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801279:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80127c:	83 ec 04             	sub    $0x4,%esp
  80127f:	53                   	push   %ebx
  801280:	03 45 0c             	add    0xc(%ebp),%eax
  801283:	50                   	push   %eax
  801284:	57                   	push   %edi
  801285:	e8 18 09 00 00       	call   801ba2 <memmove>
		sys_cputs(buf, m);
  80128a:	83 c4 08             	add    $0x8,%esp
  80128d:	53                   	push   %ebx
  80128e:	57                   	push   %edi
  80128f:	e8 55 ee ff ff       	call   8000e9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801294:	01 de                	add    %ebx,%esi
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	89 f0                	mov    %esi,%eax
  80129b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80129e:	72 cc                	jb     80126c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012a3:	5b                   	pop    %ebx
  8012a4:	5e                   	pop    %esi
  8012a5:	5f                   	pop    %edi
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012b7:	74 2a                	je     8012e3 <devcons_read+0x3b>
  8012b9:	eb 05                	jmp    8012c0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012bb:	e8 c6 ee ff ff       	call   800186 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012c0:	e8 42 ee ff ff       	call   800107 <sys_cgetc>
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	74 f2                	je     8012bb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	78 16                	js     8012e3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012cd:	83 f8 04             	cmp    $0x4,%eax
  8012d0:	74 0c                	je     8012de <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012d5:	88 02                	mov    %al,(%edx)
	return 1;
  8012d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8012dc:	eb 05                	jmp    8012e3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012de:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012e3:	c9                   	leave  
  8012e4:	c3                   	ret    

008012e5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ee:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012f1:	6a 01                	push   $0x1
  8012f3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	e8 ed ed ff ff       	call   8000e9 <sys_cputs>
}
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	c9                   	leave  
  801300:	c3                   	ret    

00801301 <getchar>:

int
getchar(void)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801307:	6a 01                	push   $0x1
  801309:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	6a 00                	push   $0x0
  80130f:	e8 90 f6 ff ff       	call   8009a4 <read>
	if (r < 0)
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 0f                	js     80132a <getchar+0x29>
		return r;
	if (r < 1)
  80131b:	85 c0                	test   %eax,%eax
  80131d:	7e 06                	jle    801325 <getchar+0x24>
		return -E_EOF;
	return c;
  80131f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801323:	eb 05                	jmp    80132a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801325:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80132a:	c9                   	leave  
  80132b:	c3                   	ret    

0080132c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801332:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801335:	50                   	push   %eax
  801336:	ff 75 08             	pushl  0x8(%ebp)
  801339:	e8 00 f4 ff ff       	call   80073e <fd_lookup>
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	85 c0                	test   %eax,%eax
  801343:	78 11                	js     801356 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801345:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801348:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80134e:	39 10                	cmp    %edx,(%eax)
  801350:	0f 94 c0             	sete   %al
  801353:	0f b6 c0             	movzbl %al,%eax
}
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <opencons>:

int
opencons(void)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80135e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801361:	50                   	push   %eax
  801362:	e8 88 f3 ff ff       	call   8006ef <fd_alloc>
  801367:	83 c4 10             	add    $0x10,%esp
		return r;
  80136a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 3e                	js     8013ae <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801370:	83 ec 04             	sub    $0x4,%esp
  801373:	68 07 04 00 00       	push   $0x407
  801378:	ff 75 f4             	pushl  -0xc(%ebp)
  80137b:	6a 00                	push   $0x0
  80137d:	e8 23 ee ff ff       	call   8001a5 <sys_page_alloc>
  801382:	83 c4 10             	add    $0x10,%esp
		return r;
  801385:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801387:	85 c0                	test   %eax,%eax
  801389:	78 23                	js     8013ae <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80138b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801394:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801399:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013a0:	83 ec 0c             	sub    $0xc,%esp
  8013a3:	50                   	push   %eax
  8013a4:	e8 1f f3 ff ff       	call   8006c8 <fd2num>
  8013a9:	89 c2                	mov    %eax,%edx
  8013ab:	83 c4 10             	add    $0x10,%esp
}
  8013ae:	89 d0                	mov    %edx,%eax
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	56                   	push   %esi
  8013b6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013b7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013ba:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013c0:	e8 a2 ed ff ff       	call   800167 <sys_getenvid>
  8013c5:	83 ec 0c             	sub    $0xc,%esp
  8013c8:	ff 75 0c             	pushl  0xc(%ebp)
  8013cb:	ff 75 08             	pushl  0x8(%ebp)
  8013ce:	56                   	push   %esi
  8013cf:	50                   	push   %eax
  8013d0:	68 80 23 80 00       	push   $0x802380
  8013d5:	e8 b1 00 00 00       	call   80148b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013da:	83 c4 18             	add    $0x18,%esp
  8013dd:	53                   	push   %ebx
  8013de:	ff 75 10             	pushl  0x10(%ebp)
  8013e1:	e8 54 00 00 00       	call   80143a <vcprintf>
	cprintf("\n");
  8013e6:	c7 04 24 6b 23 80 00 	movl   $0x80236b,(%esp)
  8013ed:	e8 99 00 00 00       	call   80148b <cprintf>
  8013f2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013f5:	cc                   	int3   
  8013f6:	eb fd                	jmp    8013f5 <_panic+0x43>

008013f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	53                   	push   %ebx
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801402:	8b 13                	mov    (%ebx),%edx
  801404:	8d 42 01             	lea    0x1(%edx),%eax
  801407:	89 03                	mov    %eax,(%ebx)
  801409:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80140c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801410:	3d ff 00 00 00       	cmp    $0xff,%eax
  801415:	75 1a                	jne    801431 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	68 ff 00 00 00       	push   $0xff
  80141f:	8d 43 08             	lea    0x8(%ebx),%eax
  801422:	50                   	push   %eax
  801423:	e8 c1 ec ff ff       	call   8000e9 <sys_cputs>
		b->idx = 0;
  801428:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80142e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801431:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801435:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801438:	c9                   	leave  
  801439:	c3                   	ret    

0080143a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801443:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80144a:	00 00 00 
	b.cnt = 0;
  80144d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801454:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801457:	ff 75 0c             	pushl  0xc(%ebp)
  80145a:	ff 75 08             	pushl  0x8(%ebp)
  80145d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	68 f8 13 80 00       	push   $0x8013f8
  801469:	e8 54 01 00 00       	call   8015c2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80146e:	83 c4 08             	add    $0x8,%esp
  801471:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801477:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80147d:	50                   	push   %eax
  80147e:	e8 66 ec ff ff       	call   8000e9 <sys_cputs>

	return b.cnt;
}
  801483:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801491:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801494:	50                   	push   %eax
  801495:	ff 75 08             	pushl  0x8(%ebp)
  801498:	e8 9d ff ff ff       	call   80143a <vcprintf>
	va_end(ap);

	return cnt;
}
  80149d:	c9                   	leave  
  80149e:	c3                   	ret    

0080149f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
  8014a2:	57                   	push   %edi
  8014a3:	56                   	push   %esi
  8014a4:	53                   	push   %ebx
  8014a5:	83 ec 1c             	sub    $0x1c,%esp
  8014a8:	89 c7                	mov    %eax,%edi
  8014aa:	89 d6                	mov    %edx,%esi
  8014ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8014af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014c3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014c6:	39 d3                	cmp    %edx,%ebx
  8014c8:	72 05                	jb     8014cf <printnum+0x30>
  8014ca:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014cd:	77 45                	ja     801514 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014cf:	83 ec 0c             	sub    $0xc,%esp
  8014d2:	ff 75 18             	pushl  0x18(%ebp)
  8014d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014db:	53                   	push   %ebx
  8014dc:	ff 75 10             	pushl  0x10(%ebp)
  8014df:	83 ec 08             	sub    $0x8,%esp
  8014e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8014e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8014eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8014ee:	e8 4d 0a 00 00       	call   801f40 <__udivdi3>
  8014f3:	83 c4 18             	add    $0x18,%esp
  8014f6:	52                   	push   %edx
  8014f7:	50                   	push   %eax
  8014f8:	89 f2                	mov    %esi,%edx
  8014fa:	89 f8                	mov    %edi,%eax
  8014fc:	e8 9e ff ff ff       	call   80149f <printnum>
  801501:	83 c4 20             	add    $0x20,%esp
  801504:	eb 18                	jmp    80151e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	56                   	push   %esi
  80150a:	ff 75 18             	pushl  0x18(%ebp)
  80150d:	ff d7                	call   *%edi
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	eb 03                	jmp    801517 <printnum+0x78>
  801514:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801517:	83 eb 01             	sub    $0x1,%ebx
  80151a:	85 db                	test   %ebx,%ebx
  80151c:	7f e8                	jg     801506 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	56                   	push   %esi
  801522:	83 ec 04             	sub    $0x4,%esp
  801525:	ff 75 e4             	pushl  -0x1c(%ebp)
  801528:	ff 75 e0             	pushl  -0x20(%ebp)
  80152b:	ff 75 dc             	pushl  -0x24(%ebp)
  80152e:	ff 75 d8             	pushl  -0x28(%ebp)
  801531:	e8 3a 0b 00 00       	call   802070 <__umoddi3>
  801536:	83 c4 14             	add    $0x14,%esp
  801539:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  801540:	50                   	push   %eax
  801541:	ff d7                	call   *%edi
}
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5f                   	pop    %edi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    

0080154e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801551:	83 fa 01             	cmp    $0x1,%edx
  801554:	7e 0e                	jle    801564 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801556:	8b 10                	mov    (%eax),%edx
  801558:	8d 4a 08             	lea    0x8(%edx),%ecx
  80155b:	89 08                	mov    %ecx,(%eax)
  80155d:	8b 02                	mov    (%edx),%eax
  80155f:	8b 52 04             	mov    0x4(%edx),%edx
  801562:	eb 22                	jmp    801586 <getuint+0x38>
	else if (lflag)
  801564:	85 d2                	test   %edx,%edx
  801566:	74 10                	je     801578 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801568:	8b 10                	mov    (%eax),%edx
  80156a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80156d:	89 08                	mov    %ecx,(%eax)
  80156f:	8b 02                	mov    (%edx),%eax
  801571:	ba 00 00 00 00       	mov    $0x0,%edx
  801576:	eb 0e                	jmp    801586 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801578:	8b 10                	mov    (%eax),%edx
  80157a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80157d:	89 08                	mov    %ecx,(%eax)
  80157f:	8b 02                	mov    (%edx),%eax
  801581:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801586:	5d                   	pop    %ebp
  801587:	c3                   	ret    

00801588 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80158e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801592:	8b 10                	mov    (%eax),%edx
  801594:	3b 50 04             	cmp    0x4(%eax),%edx
  801597:	73 0a                	jae    8015a3 <sprintputch+0x1b>
		*b->buf++ = ch;
  801599:	8d 4a 01             	lea    0x1(%edx),%ecx
  80159c:	89 08                	mov    %ecx,(%eax)
  80159e:	8b 45 08             	mov    0x8(%ebp),%eax
  8015a1:	88 02                	mov    %al,(%edx)
}
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015ab:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015ae:	50                   	push   %eax
  8015af:	ff 75 10             	pushl  0x10(%ebp)
  8015b2:	ff 75 0c             	pushl  0xc(%ebp)
  8015b5:	ff 75 08             	pushl  0x8(%ebp)
  8015b8:	e8 05 00 00 00       	call   8015c2 <vprintfmt>
	va_end(ap);
}
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	57                   	push   %edi
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 2c             	sub    $0x2c,%esp
  8015cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015d4:	eb 12                	jmp    8015e8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	0f 84 89 03 00 00    	je     801967 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015de:	83 ec 08             	sub    $0x8,%esp
  8015e1:	53                   	push   %ebx
  8015e2:	50                   	push   %eax
  8015e3:	ff d6                	call   *%esi
  8015e5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015e8:	83 c7 01             	add    $0x1,%edi
  8015eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015ef:	83 f8 25             	cmp    $0x25,%eax
  8015f2:	75 e2                	jne    8015d6 <vprintfmt+0x14>
  8015f4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015f8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015ff:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801606:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80160d:	ba 00 00 00 00       	mov    $0x0,%edx
  801612:	eb 07                	jmp    80161b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801614:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801617:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161b:	8d 47 01             	lea    0x1(%edi),%eax
  80161e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801621:	0f b6 07             	movzbl (%edi),%eax
  801624:	0f b6 c8             	movzbl %al,%ecx
  801627:	83 e8 23             	sub    $0x23,%eax
  80162a:	3c 55                	cmp    $0x55,%al
  80162c:	0f 87 1a 03 00 00    	ja     80194c <vprintfmt+0x38a>
  801632:	0f b6 c0             	movzbl %al,%eax
  801635:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  80163c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80163f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801643:	eb d6                	jmp    80161b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801645:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801648:	b8 00 00 00 00       	mov    $0x0,%eax
  80164d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801650:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801653:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801657:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80165a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80165d:	83 fa 09             	cmp    $0x9,%edx
  801660:	77 39                	ja     80169b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801662:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801665:	eb e9                	jmp    801650 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801667:	8b 45 14             	mov    0x14(%ebp),%eax
  80166a:	8d 48 04             	lea    0x4(%eax),%ecx
  80166d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801670:	8b 00                	mov    (%eax),%eax
  801672:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801675:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801678:	eb 27                	jmp    8016a1 <vprintfmt+0xdf>
  80167a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80167d:	85 c0                	test   %eax,%eax
  80167f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801684:	0f 49 c8             	cmovns %eax,%ecx
  801687:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80168a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80168d:	eb 8c                	jmp    80161b <vprintfmt+0x59>
  80168f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801692:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801699:	eb 80                	jmp    80161b <vprintfmt+0x59>
  80169b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80169e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016a5:	0f 89 70 ff ff ff    	jns    80161b <vprintfmt+0x59>
				width = precision, precision = -1;
  8016ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016b1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016b8:	e9 5e ff ff ff       	jmp    80161b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016bd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016c3:	e9 53 ff ff ff       	jmp    80161b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016cb:	8d 50 04             	lea    0x4(%eax),%edx
  8016ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	53                   	push   %ebx
  8016d5:	ff 30                	pushl  (%eax)
  8016d7:	ff d6                	call   *%esi
			break;
  8016d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016df:	e9 04 ff ff ff       	jmp    8015e8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e7:	8d 50 04             	lea    0x4(%eax),%edx
  8016ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ed:	8b 00                	mov    (%eax),%eax
  8016ef:	99                   	cltd   
  8016f0:	31 d0                	xor    %edx,%eax
  8016f2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016f4:	83 f8 0f             	cmp    $0xf,%eax
  8016f7:	7f 0b                	jg     801704 <vprintfmt+0x142>
  8016f9:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  801700:	85 d2                	test   %edx,%edx
  801702:	75 18                	jne    80171c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801704:	50                   	push   %eax
  801705:	68 bb 23 80 00       	push   $0x8023bb
  80170a:	53                   	push   %ebx
  80170b:	56                   	push   %esi
  80170c:	e8 94 fe ff ff       	call   8015a5 <printfmt>
  801711:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801717:	e9 cc fe ff ff       	jmp    8015e8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80171c:	52                   	push   %edx
  80171d:	68 39 23 80 00       	push   $0x802339
  801722:	53                   	push   %ebx
  801723:	56                   	push   %esi
  801724:	e8 7c fe ff ff       	call   8015a5 <printfmt>
  801729:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80172c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80172f:	e9 b4 fe ff ff       	jmp    8015e8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801734:	8b 45 14             	mov    0x14(%ebp),%eax
  801737:	8d 50 04             	lea    0x4(%eax),%edx
  80173a:	89 55 14             	mov    %edx,0x14(%ebp)
  80173d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80173f:	85 ff                	test   %edi,%edi
  801741:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  801746:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801749:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80174d:	0f 8e 94 00 00 00    	jle    8017e7 <vprintfmt+0x225>
  801753:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801757:	0f 84 98 00 00 00    	je     8017f5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	ff 75 d0             	pushl  -0x30(%ebp)
  801763:	57                   	push   %edi
  801764:	e8 86 02 00 00       	call   8019ef <strnlen>
  801769:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80176c:	29 c1                	sub    %eax,%ecx
  80176e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801771:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801774:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801778:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80177b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80177e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801780:	eb 0f                	jmp    801791 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801782:	83 ec 08             	sub    $0x8,%esp
  801785:	53                   	push   %ebx
  801786:	ff 75 e0             	pushl  -0x20(%ebp)
  801789:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80178b:	83 ef 01             	sub    $0x1,%edi
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	85 ff                	test   %edi,%edi
  801793:	7f ed                	jg     801782 <vprintfmt+0x1c0>
  801795:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801798:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80179b:	85 c9                	test   %ecx,%ecx
  80179d:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a2:	0f 49 c1             	cmovns %ecx,%eax
  8017a5:	29 c1                	sub    %eax,%ecx
  8017a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8017aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017b0:	89 cb                	mov    %ecx,%ebx
  8017b2:	eb 4d                	jmp    801801 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017b8:	74 1b                	je     8017d5 <vprintfmt+0x213>
  8017ba:	0f be c0             	movsbl %al,%eax
  8017bd:	83 e8 20             	sub    $0x20,%eax
  8017c0:	83 f8 5e             	cmp    $0x5e,%eax
  8017c3:	76 10                	jbe    8017d5 <vprintfmt+0x213>
					putch('?', putdat);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	ff 75 0c             	pushl  0xc(%ebp)
  8017cb:	6a 3f                	push   $0x3f
  8017cd:	ff 55 08             	call   *0x8(%ebp)
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	eb 0d                	jmp    8017e2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017d5:	83 ec 08             	sub    $0x8,%esp
  8017d8:	ff 75 0c             	pushl  0xc(%ebp)
  8017db:	52                   	push   %edx
  8017dc:	ff 55 08             	call   *0x8(%ebp)
  8017df:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017e2:	83 eb 01             	sub    $0x1,%ebx
  8017e5:	eb 1a                	jmp    801801 <vprintfmt+0x23f>
  8017e7:	89 75 08             	mov    %esi,0x8(%ebp)
  8017ea:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017f0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017f3:	eb 0c                	jmp    801801 <vprintfmt+0x23f>
  8017f5:	89 75 08             	mov    %esi,0x8(%ebp)
  8017f8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017fb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017fe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801801:	83 c7 01             	add    $0x1,%edi
  801804:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801808:	0f be d0             	movsbl %al,%edx
  80180b:	85 d2                	test   %edx,%edx
  80180d:	74 23                	je     801832 <vprintfmt+0x270>
  80180f:	85 f6                	test   %esi,%esi
  801811:	78 a1                	js     8017b4 <vprintfmt+0x1f2>
  801813:	83 ee 01             	sub    $0x1,%esi
  801816:	79 9c                	jns    8017b4 <vprintfmt+0x1f2>
  801818:	89 df                	mov    %ebx,%edi
  80181a:	8b 75 08             	mov    0x8(%ebp),%esi
  80181d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801820:	eb 18                	jmp    80183a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801822:	83 ec 08             	sub    $0x8,%esp
  801825:	53                   	push   %ebx
  801826:	6a 20                	push   $0x20
  801828:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80182a:	83 ef 01             	sub    $0x1,%edi
  80182d:	83 c4 10             	add    $0x10,%esp
  801830:	eb 08                	jmp    80183a <vprintfmt+0x278>
  801832:	89 df                	mov    %ebx,%edi
  801834:	8b 75 08             	mov    0x8(%ebp),%esi
  801837:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80183a:	85 ff                	test   %edi,%edi
  80183c:	7f e4                	jg     801822 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80183e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801841:	e9 a2 fd ff ff       	jmp    8015e8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801846:	83 fa 01             	cmp    $0x1,%edx
  801849:	7e 16                	jle    801861 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80184b:	8b 45 14             	mov    0x14(%ebp),%eax
  80184e:	8d 50 08             	lea    0x8(%eax),%edx
  801851:	89 55 14             	mov    %edx,0x14(%ebp)
  801854:	8b 50 04             	mov    0x4(%eax),%edx
  801857:	8b 00                	mov    (%eax),%eax
  801859:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80185c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80185f:	eb 32                	jmp    801893 <vprintfmt+0x2d1>
	else if (lflag)
  801861:	85 d2                	test   %edx,%edx
  801863:	74 18                	je     80187d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801865:	8b 45 14             	mov    0x14(%ebp),%eax
  801868:	8d 50 04             	lea    0x4(%eax),%edx
  80186b:	89 55 14             	mov    %edx,0x14(%ebp)
  80186e:	8b 00                	mov    (%eax),%eax
  801870:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801873:	89 c1                	mov    %eax,%ecx
  801875:	c1 f9 1f             	sar    $0x1f,%ecx
  801878:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80187b:	eb 16                	jmp    801893 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80187d:	8b 45 14             	mov    0x14(%ebp),%eax
  801880:	8d 50 04             	lea    0x4(%eax),%edx
  801883:	89 55 14             	mov    %edx,0x14(%ebp)
  801886:	8b 00                	mov    (%eax),%eax
  801888:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80188b:	89 c1                	mov    %eax,%ecx
  80188d:	c1 f9 1f             	sar    $0x1f,%ecx
  801890:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801893:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801896:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801899:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80189e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018a2:	79 74                	jns    801918 <vprintfmt+0x356>
				putch('-', putdat);
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	53                   	push   %ebx
  8018a8:	6a 2d                	push   $0x2d
  8018aa:	ff d6                	call   *%esi
				num = -(long long) num;
  8018ac:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018af:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018b2:	f7 d8                	neg    %eax
  8018b4:	83 d2 00             	adc    $0x0,%edx
  8018b7:	f7 da                	neg    %edx
  8018b9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018bc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018c1:	eb 55                	jmp    801918 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8018c6:	e8 83 fc ff ff       	call   80154e <getuint>
			base = 10;
  8018cb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018d0:	eb 46                	jmp    801918 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8018d5:	e8 74 fc ff ff       	call   80154e <getuint>
			base = 8;
  8018da:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018df:	eb 37                	jmp    801918 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	53                   	push   %ebx
  8018e5:	6a 30                	push   $0x30
  8018e7:	ff d6                	call   *%esi
			putch('x', putdat);
  8018e9:	83 c4 08             	add    $0x8,%esp
  8018ec:	53                   	push   %ebx
  8018ed:	6a 78                	push   $0x78
  8018ef:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f4:	8d 50 04             	lea    0x4(%eax),%edx
  8018f7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018fa:	8b 00                	mov    (%eax),%eax
  8018fc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801901:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801904:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801909:	eb 0d                	jmp    801918 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80190b:	8d 45 14             	lea    0x14(%ebp),%eax
  80190e:	e8 3b fc ff ff       	call   80154e <getuint>
			base = 16;
  801913:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801918:	83 ec 0c             	sub    $0xc,%esp
  80191b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80191f:	57                   	push   %edi
  801920:	ff 75 e0             	pushl  -0x20(%ebp)
  801923:	51                   	push   %ecx
  801924:	52                   	push   %edx
  801925:	50                   	push   %eax
  801926:	89 da                	mov    %ebx,%edx
  801928:	89 f0                	mov    %esi,%eax
  80192a:	e8 70 fb ff ff       	call   80149f <printnum>
			break;
  80192f:	83 c4 20             	add    $0x20,%esp
  801932:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801935:	e9 ae fc ff ff       	jmp    8015e8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80193a:	83 ec 08             	sub    $0x8,%esp
  80193d:	53                   	push   %ebx
  80193e:	51                   	push   %ecx
  80193f:	ff d6                	call   *%esi
			break;
  801941:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801944:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801947:	e9 9c fc ff ff       	jmp    8015e8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	53                   	push   %ebx
  801950:	6a 25                	push   $0x25
  801952:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	eb 03                	jmp    80195c <vprintfmt+0x39a>
  801959:	83 ef 01             	sub    $0x1,%edi
  80195c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801960:	75 f7                	jne    801959 <vprintfmt+0x397>
  801962:	e9 81 fc ff ff       	jmp    8015e8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801967:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80196a:	5b                   	pop    %ebx
  80196b:	5e                   	pop    %esi
  80196c:	5f                   	pop    %edi
  80196d:	5d                   	pop    %ebp
  80196e:	c3                   	ret    

0080196f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80196f:	55                   	push   %ebp
  801970:	89 e5                	mov    %esp,%ebp
  801972:	83 ec 18             	sub    $0x18,%esp
  801975:	8b 45 08             	mov    0x8(%ebp),%eax
  801978:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80197b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80197e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801982:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801985:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80198c:	85 c0                	test   %eax,%eax
  80198e:	74 26                	je     8019b6 <vsnprintf+0x47>
  801990:	85 d2                	test   %edx,%edx
  801992:	7e 22                	jle    8019b6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801994:	ff 75 14             	pushl  0x14(%ebp)
  801997:	ff 75 10             	pushl  0x10(%ebp)
  80199a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80199d:	50                   	push   %eax
  80199e:	68 88 15 80 00       	push   $0x801588
  8019a3:	e8 1a fc ff ff       	call   8015c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019ab:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	eb 05                	jmp    8019bb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019c3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019c6:	50                   	push   %eax
  8019c7:	ff 75 10             	pushl  0x10(%ebp)
  8019ca:	ff 75 0c             	pushl  0xc(%ebp)
  8019cd:	ff 75 08             	pushl  0x8(%ebp)
  8019d0:	e8 9a ff ff ff       	call   80196f <vsnprintf>
	va_end(ap);

	return rc;
}
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    

008019d7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e2:	eb 03                	jmp    8019e7 <strlen+0x10>
		n++;
  8019e4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019e7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019eb:	75 f7                	jne    8019e4 <strlen+0xd>
		n++;
	return n;
}
  8019ed:	5d                   	pop    %ebp
  8019ee:	c3                   	ret    

008019ef <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019ef:	55                   	push   %ebp
  8019f0:	89 e5                	mov    %esp,%ebp
  8019f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fd:	eb 03                	jmp    801a02 <strnlen+0x13>
		n++;
  8019ff:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a02:	39 c2                	cmp    %eax,%edx
  801a04:	74 08                	je     801a0e <strnlen+0x1f>
  801a06:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a0a:	75 f3                	jne    8019ff <strnlen+0x10>
  801a0c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a0e:	5d                   	pop    %ebp
  801a0f:	c3                   	ret    

00801a10 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	53                   	push   %ebx
  801a14:	8b 45 08             	mov    0x8(%ebp),%eax
  801a17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a1a:	89 c2                	mov    %eax,%edx
  801a1c:	83 c2 01             	add    $0x1,%edx
  801a1f:	83 c1 01             	add    $0x1,%ecx
  801a22:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a26:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a29:	84 db                	test   %bl,%bl
  801a2b:	75 ef                	jne    801a1c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a2d:	5b                   	pop    %ebx
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	53                   	push   %ebx
  801a34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a37:	53                   	push   %ebx
  801a38:	e8 9a ff ff ff       	call   8019d7 <strlen>
  801a3d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a40:	ff 75 0c             	pushl  0xc(%ebp)
  801a43:	01 d8                	add    %ebx,%eax
  801a45:	50                   	push   %eax
  801a46:	e8 c5 ff ff ff       	call   801a10 <strcpy>
	return dst;
}
  801a4b:	89 d8                	mov    %ebx,%eax
  801a4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a50:	c9                   	leave  
  801a51:	c3                   	ret    

00801a52 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a52:	55                   	push   %ebp
  801a53:	89 e5                	mov    %esp,%ebp
  801a55:	56                   	push   %esi
  801a56:	53                   	push   %ebx
  801a57:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5d:	89 f3                	mov    %esi,%ebx
  801a5f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a62:	89 f2                	mov    %esi,%edx
  801a64:	eb 0f                	jmp    801a75 <strncpy+0x23>
		*dst++ = *src;
  801a66:	83 c2 01             	add    $0x1,%edx
  801a69:	0f b6 01             	movzbl (%ecx),%eax
  801a6c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a6f:	80 39 01             	cmpb   $0x1,(%ecx)
  801a72:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a75:	39 da                	cmp    %ebx,%edx
  801a77:	75 ed                	jne    801a66 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a79:	89 f0                	mov    %esi,%eax
  801a7b:	5b                   	pop    %ebx
  801a7c:	5e                   	pop    %esi
  801a7d:	5d                   	pop    %ebp
  801a7e:	c3                   	ret    

00801a7f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	8b 75 08             	mov    0x8(%ebp),%esi
  801a87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8a:	8b 55 10             	mov    0x10(%ebp),%edx
  801a8d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a8f:	85 d2                	test   %edx,%edx
  801a91:	74 21                	je     801ab4 <strlcpy+0x35>
  801a93:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a97:	89 f2                	mov    %esi,%edx
  801a99:	eb 09                	jmp    801aa4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a9b:	83 c2 01             	add    $0x1,%edx
  801a9e:	83 c1 01             	add    $0x1,%ecx
  801aa1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801aa4:	39 c2                	cmp    %eax,%edx
  801aa6:	74 09                	je     801ab1 <strlcpy+0x32>
  801aa8:	0f b6 19             	movzbl (%ecx),%ebx
  801aab:	84 db                	test   %bl,%bl
  801aad:	75 ec                	jne    801a9b <strlcpy+0x1c>
  801aaf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ab1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801ab4:	29 f0                	sub    %esi,%eax
}
  801ab6:	5b                   	pop    %ebx
  801ab7:	5e                   	pop    %esi
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    

00801aba <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ac3:	eb 06                	jmp    801acb <strcmp+0x11>
		p++, q++;
  801ac5:	83 c1 01             	add    $0x1,%ecx
  801ac8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801acb:	0f b6 01             	movzbl (%ecx),%eax
  801ace:	84 c0                	test   %al,%al
  801ad0:	74 04                	je     801ad6 <strcmp+0x1c>
  801ad2:	3a 02                	cmp    (%edx),%al
  801ad4:	74 ef                	je     801ac5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ad6:	0f b6 c0             	movzbl %al,%eax
  801ad9:	0f b6 12             	movzbl (%edx),%edx
  801adc:	29 d0                	sub    %edx,%eax
}
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	53                   	push   %ebx
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aea:	89 c3                	mov    %eax,%ebx
  801aec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801aef:	eb 06                	jmp    801af7 <strncmp+0x17>
		n--, p++, q++;
  801af1:	83 c0 01             	add    $0x1,%eax
  801af4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801af7:	39 d8                	cmp    %ebx,%eax
  801af9:	74 15                	je     801b10 <strncmp+0x30>
  801afb:	0f b6 08             	movzbl (%eax),%ecx
  801afe:	84 c9                	test   %cl,%cl
  801b00:	74 04                	je     801b06 <strncmp+0x26>
  801b02:	3a 0a                	cmp    (%edx),%cl
  801b04:	74 eb                	je     801af1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b06:	0f b6 00             	movzbl (%eax),%eax
  801b09:	0f b6 12             	movzbl (%edx),%edx
  801b0c:	29 d0                	sub    %edx,%eax
  801b0e:	eb 05                	jmp    801b15 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b15:	5b                   	pop    %ebx
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b22:	eb 07                	jmp    801b2b <strchr+0x13>
		if (*s == c)
  801b24:	38 ca                	cmp    %cl,%dl
  801b26:	74 0f                	je     801b37 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b28:	83 c0 01             	add    $0x1,%eax
  801b2b:	0f b6 10             	movzbl (%eax),%edx
  801b2e:	84 d2                	test   %dl,%dl
  801b30:	75 f2                	jne    801b24 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b43:	eb 03                	jmp    801b48 <strfind+0xf>
  801b45:	83 c0 01             	add    $0x1,%eax
  801b48:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b4b:	38 ca                	cmp    %cl,%dl
  801b4d:	74 04                	je     801b53 <strfind+0x1a>
  801b4f:	84 d2                	test   %dl,%dl
  801b51:	75 f2                	jne    801b45 <strfind+0xc>
			break;
	return (char *) s;
}
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	57                   	push   %edi
  801b59:	56                   	push   %esi
  801b5a:	53                   	push   %ebx
  801b5b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b61:	85 c9                	test   %ecx,%ecx
  801b63:	74 36                	je     801b9b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b65:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b6b:	75 28                	jne    801b95 <memset+0x40>
  801b6d:	f6 c1 03             	test   $0x3,%cl
  801b70:	75 23                	jne    801b95 <memset+0x40>
		c &= 0xFF;
  801b72:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b76:	89 d3                	mov    %edx,%ebx
  801b78:	c1 e3 08             	shl    $0x8,%ebx
  801b7b:	89 d6                	mov    %edx,%esi
  801b7d:	c1 e6 18             	shl    $0x18,%esi
  801b80:	89 d0                	mov    %edx,%eax
  801b82:	c1 e0 10             	shl    $0x10,%eax
  801b85:	09 f0                	or     %esi,%eax
  801b87:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b89:	89 d8                	mov    %ebx,%eax
  801b8b:	09 d0                	or     %edx,%eax
  801b8d:	c1 e9 02             	shr    $0x2,%ecx
  801b90:	fc                   	cld    
  801b91:	f3 ab                	rep stos %eax,%es:(%edi)
  801b93:	eb 06                	jmp    801b9b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b98:	fc                   	cld    
  801b99:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b9b:	89 f8                	mov    %edi,%eax
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5f                   	pop    %edi
  801ba0:	5d                   	pop    %ebp
  801ba1:	c3                   	ret    

00801ba2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	57                   	push   %edi
  801ba6:	56                   	push   %esi
  801ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  801baa:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801bb0:	39 c6                	cmp    %eax,%esi
  801bb2:	73 35                	jae    801be9 <memmove+0x47>
  801bb4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bb7:	39 d0                	cmp    %edx,%eax
  801bb9:	73 2e                	jae    801be9 <memmove+0x47>
		s += n;
		d += n;
  801bbb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bbe:	89 d6                	mov    %edx,%esi
  801bc0:	09 fe                	or     %edi,%esi
  801bc2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bc8:	75 13                	jne    801bdd <memmove+0x3b>
  801bca:	f6 c1 03             	test   $0x3,%cl
  801bcd:	75 0e                	jne    801bdd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bcf:	83 ef 04             	sub    $0x4,%edi
  801bd2:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bd5:	c1 e9 02             	shr    $0x2,%ecx
  801bd8:	fd                   	std    
  801bd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bdb:	eb 09                	jmp    801be6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bdd:	83 ef 01             	sub    $0x1,%edi
  801be0:	8d 72 ff             	lea    -0x1(%edx),%esi
  801be3:	fd                   	std    
  801be4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801be6:	fc                   	cld    
  801be7:	eb 1d                	jmp    801c06 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801be9:	89 f2                	mov    %esi,%edx
  801beb:	09 c2                	or     %eax,%edx
  801bed:	f6 c2 03             	test   $0x3,%dl
  801bf0:	75 0f                	jne    801c01 <memmove+0x5f>
  801bf2:	f6 c1 03             	test   $0x3,%cl
  801bf5:	75 0a                	jne    801c01 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bf7:	c1 e9 02             	shr    $0x2,%ecx
  801bfa:	89 c7                	mov    %eax,%edi
  801bfc:	fc                   	cld    
  801bfd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bff:	eb 05                	jmp    801c06 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c01:	89 c7                	mov    %eax,%edi
  801c03:	fc                   	cld    
  801c04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    

00801c0a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c0d:	ff 75 10             	pushl  0x10(%ebp)
  801c10:	ff 75 0c             	pushl  0xc(%ebp)
  801c13:	ff 75 08             	pushl  0x8(%ebp)
  801c16:	e8 87 ff ff ff       	call   801ba2 <memmove>
}
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	8b 45 08             	mov    0x8(%ebp),%eax
  801c25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c28:	89 c6                	mov    %eax,%esi
  801c2a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c2d:	eb 1a                	jmp    801c49 <memcmp+0x2c>
		if (*s1 != *s2)
  801c2f:	0f b6 08             	movzbl (%eax),%ecx
  801c32:	0f b6 1a             	movzbl (%edx),%ebx
  801c35:	38 d9                	cmp    %bl,%cl
  801c37:	74 0a                	je     801c43 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c39:	0f b6 c1             	movzbl %cl,%eax
  801c3c:	0f b6 db             	movzbl %bl,%ebx
  801c3f:	29 d8                	sub    %ebx,%eax
  801c41:	eb 0f                	jmp    801c52 <memcmp+0x35>
		s1++, s2++;
  801c43:	83 c0 01             	add    $0x1,%eax
  801c46:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c49:	39 f0                	cmp    %esi,%eax
  801c4b:	75 e2                	jne    801c2f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	53                   	push   %ebx
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c5d:	89 c1                	mov    %eax,%ecx
  801c5f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c62:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c66:	eb 0a                	jmp    801c72 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c68:	0f b6 10             	movzbl (%eax),%edx
  801c6b:	39 da                	cmp    %ebx,%edx
  801c6d:	74 07                	je     801c76 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c6f:	83 c0 01             	add    $0x1,%eax
  801c72:	39 c8                	cmp    %ecx,%eax
  801c74:	72 f2                	jb     801c68 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c76:	5b                   	pop    %ebx
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	57                   	push   %edi
  801c7d:	56                   	push   %esi
  801c7e:	53                   	push   %ebx
  801c7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c85:	eb 03                	jmp    801c8a <strtol+0x11>
		s++;
  801c87:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c8a:	0f b6 01             	movzbl (%ecx),%eax
  801c8d:	3c 20                	cmp    $0x20,%al
  801c8f:	74 f6                	je     801c87 <strtol+0xe>
  801c91:	3c 09                	cmp    $0x9,%al
  801c93:	74 f2                	je     801c87 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c95:	3c 2b                	cmp    $0x2b,%al
  801c97:	75 0a                	jne    801ca3 <strtol+0x2a>
		s++;
  801c99:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c9c:	bf 00 00 00 00       	mov    $0x0,%edi
  801ca1:	eb 11                	jmp    801cb4 <strtol+0x3b>
  801ca3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ca8:	3c 2d                	cmp    $0x2d,%al
  801caa:	75 08                	jne    801cb4 <strtol+0x3b>
		s++, neg = 1;
  801cac:	83 c1 01             	add    $0x1,%ecx
  801caf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cb4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cba:	75 15                	jne    801cd1 <strtol+0x58>
  801cbc:	80 39 30             	cmpb   $0x30,(%ecx)
  801cbf:	75 10                	jne    801cd1 <strtol+0x58>
  801cc1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cc5:	75 7c                	jne    801d43 <strtol+0xca>
		s += 2, base = 16;
  801cc7:	83 c1 02             	add    $0x2,%ecx
  801cca:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ccf:	eb 16                	jmp    801ce7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cd1:	85 db                	test   %ebx,%ebx
  801cd3:	75 12                	jne    801ce7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cd5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cda:	80 39 30             	cmpb   $0x30,(%ecx)
  801cdd:	75 08                	jne    801ce7 <strtol+0x6e>
		s++, base = 8;
  801cdf:	83 c1 01             	add    $0x1,%ecx
  801ce2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ce7:	b8 00 00 00 00       	mov    $0x0,%eax
  801cec:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cef:	0f b6 11             	movzbl (%ecx),%edx
  801cf2:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cf5:	89 f3                	mov    %esi,%ebx
  801cf7:	80 fb 09             	cmp    $0x9,%bl
  801cfa:	77 08                	ja     801d04 <strtol+0x8b>
			dig = *s - '0';
  801cfc:	0f be d2             	movsbl %dl,%edx
  801cff:	83 ea 30             	sub    $0x30,%edx
  801d02:	eb 22                	jmp    801d26 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d04:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d07:	89 f3                	mov    %esi,%ebx
  801d09:	80 fb 19             	cmp    $0x19,%bl
  801d0c:	77 08                	ja     801d16 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d0e:	0f be d2             	movsbl %dl,%edx
  801d11:	83 ea 57             	sub    $0x57,%edx
  801d14:	eb 10                	jmp    801d26 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d16:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d19:	89 f3                	mov    %esi,%ebx
  801d1b:	80 fb 19             	cmp    $0x19,%bl
  801d1e:	77 16                	ja     801d36 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d20:	0f be d2             	movsbl %dl,%edx
  801d23:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d26:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d29:	7d 0b                	jge    801d36 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d2b:	83 c1 01             	add    $0x1,%ecx
  801d2e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d32:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d34:	eb b9                	jmp    801cef <strtol+0x76>

	if (endptr)
  801d36:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d3a:	74 0d                	je     801d49 <strtol+0xd0>
		*endptr = (char *) s;
  801d3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d3f:	89 0e                	mov    %ecx,(%esi)
  801d41:	eb 06                	jmp    801d49 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d43:	85 db                	test   %ebx,%ebx
  801d45:	74 98                	je     801cdf <strtol+0x66>
  801d47:	eb 9e                	jmp    801ce7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d49:	89 c2                	mov    %eax,%edx
  801d4b:	f7 da                	neg    %edx
  801d4d:	85 ff                	test   %edi,%edi
  801d4f:	0f 45 c2             	cmovne %edx,%eax
}
  801d52:	5b                   	pop    %ebx
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d5d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d64:	75 2a                	jne    801d90 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d66:	83 ec 04             	sub    $0x4,%esp
  801d69:	6a 07                	push   $0x7
  801d6b:	68 00 f0 bf ee       	push   $0xeebff000
  801d70:	6a 00                	push   $0x0
  801d72:	e8 2e e4 ff ff       	call   8001a5 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d77:	83 c4 10             	add    $0x10,%esp
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	79 12                	jns    801d90 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d7e:	50                   	push   %eax
  801d7f:	68 a0 26 80 00       	push   $0x8026a0
  801d84:	6a 23                	push   $0x23
  801d86:	68 a4 26 80 00       	push   $0x8026a4
  801d8b:	e8 22 f6 ff ff       	call   8013b2 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
  801d93:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d98:	83 ec 08             	sub    $0x8,%esp
  801d9b:	68 c2 1d 80 00       	push   $0x801dc2
  801da0:	6a 00                	push   $0x0
  801da2:	e8 49 e5 ff ff       	call   8002f0 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	85 c0                	test   %eax,%eax
  801dac:	79 12                	jns    801dc0 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801dae:	50                   	push   %eax
  801daf:	68 a0 26 80 00       	push   $0x8026a0
  801db4:	6a 2c                	push   $0x2c
  801db6:	68 a4 26 80 00       	push   $0x8026a4
  801dbb:	e8 f2 f5 ff ff       	call   8013b2 <_panic>
	}
}
  801dc0:	c9                   	leave  
  801dc1:	c3                   	ret    

00801dc2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dc2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dc3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dc8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dca:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dcd:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801dd1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801dd6:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801dda:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ddc:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ddf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801de0:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801de3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801de4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801de5:	c3                   	ret    

00801de6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801de6:	55                   	push   %ebp
  801de7:	89 e5                	mov    %esp,%ebp
  801de9:	56                   	push   %esi
  801dea:	53                   	push   %ebx
  801deb:	8b 75 08             	mov    0x8(%ebp),%esi
  801dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801df4:	85 c0                	test   %eax,%eax
  801df6:	75 12                	jne    801e0a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801df8:	83 ec 0c             	sub    $0xc,%esp
  801dfb:	68 00 00 c0 ee       	push   $0xeec00000
  801e00:	e8 50 e5 ff ff       	call   800355 <sys_ipc_recv>
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	eb 0c                	jmp    801e16 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e0a:	83 ec 0c             	sub    $0xc,%esp
  801e0d:	50                   	push   %eax
  801e0e:	e8 42 e5 ff ff       	call   800355 <sys_ipc_recv>
  801e13:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e16:	85 f6                	test   %esi,%esi
  801e18:	0f 95 c1             	setne  %cl
  801e1b:	85 db                	test   %ebx,%ebx
  801e1d:	0f 95 c2             	setne  %dl
  801e20:	84 d1                	test   %dl,%cl
  801e22:	74 09                	je     801e2d <ipc_recv+0x47>
  801e24:	89 c2                	mov    %eax,%edx
  801e26:	c1 ea 1f             	shr    $0x1f,%edx
  801e29:	84 d2                	test   %dl,%dl
  801e2b:	75 2a                	jne    801e57 <ipc_recv+0x71>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e2d:	85 f6                	test   %esi,%esi
  801e2f:	74 0d                	je     801e3e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e31:	a1 04 40 80 00       	mov    0x804004,%eax
  801e36:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  801e3c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e3e:	85 db                	test   %ebx,%ebx
  801e40:	74 0d                	je     801e4f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e42:	a1 04 40 80 00       	mov    0x804004,%eax
  801e47:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
  801e4d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e4f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e54:	8b 40 7c             	mov    0x7c(%eax),%eax
}
  801e57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5a:	5b                   	pop    %ebx
  801e5b:	5e                   	pop    %esi
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    

00801e5e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	57                   	push   %edi
  801e62:	56                   	push   %esi
  801e63:	53                   	push   %ebx
  801e64:	83 ec 0c             	sub    $0xc,%esp
  801e67:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e6a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e70:	85 db                	test   %ebx,%ebx
  801e72:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e77:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e7a:	ff 75 14             	pushl  0x14(%ebp)
  801e7d:	53                   	push   %ebx
  801e7e:	56                   	push   %esi
  801e7f:	57                   	push   %edi
  801e80:	e8 ad e4 ff ff       	call   800332 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e85:	89 c2                	mov    %eax,%edx
  801e87:	c1 ea 1f             	shr    $0x1f,%edx
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	84 d2                	test   %dl,%dl
  801e8f:	74 17                	je     801ea8 <ipc_send+0x4a>
  801e91:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e94:	74 12                	je     801ea8 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e96:	50                   	push   %eax
  801e97:	68 b2 26 80 00       	push   $0x8026b2
  801e9c:	6a 47                	push   $0x47
  801e9e:	68 c0 26 80 00       	push   $0x8026c0
  801ea3:	e8 0a f5 ff ff       	call   8013b2 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ea8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eab:	75 07                	jne    801eb4 <ipc_send+0x56>
			sys_yield();
  801ead:	e8 d4 e2 ff ff       	call   800186 <sys_yield>
  801eb2:	eb c6                	jmp    801e7a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	75 c2                	jne    801e7a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ebb:	5b                   	pop    %ebx
  801ebc:	5e                   	pop    %esi
  801ebd:	5f                   	pop    %edi
  801ebe:	5d                   	pop    %ebp
  801ebf:	c3                   	ret    

00801ec0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ec6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ecb:	89 c2                	mov    %eax,%edx
  801ecd:	c1 e2 07             	shl    $0x7,%edx
  801ed0:	8d 94 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%edx
  801ed7:	8b 52 5c             	mov    0x5c(%edx),%edx
  801eda:	39 ca                	cmp    %ecx,%edx
  801edc:	75 11                	jne    801eef <ipc_find_env+0x2f>
			return envs[i].env_id;
  801ede:	89 c2                	mov    %eax,%edx
  801ee0:	c1 e2 07             	shl    $0x7,%edx
  801ee3:	8d 84 c2 00 00 c0 ee 	lea    -0x11400000(%edx,%eax,8),%eax
  801eea:	8b 40 54             	mov    0x54(%eax),%eax
  801eed:	eb 0f                	jmp    801efe <ipc_find_env+0x3e>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eef:	83 c0 01             	add    $0x1,%eax
  801ef2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ef7:	75 d2                	jne    801ecb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ef9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801efe:	5d                   	pop    %ebp
  801eff:	c3                   	ret    

00801f00 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f06:	89 d0                	mov    %edx,%eax
  801f08:	c1 e8 16             	shr    $0x16,%eax
  801f0b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f12:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f17:	f6 c1 01             	test   $0x1,%cl
  801f1a:	74 1d                	je     801f39 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f1c:	c1 ea 0c             	shr    $0xc,%edx
  801f1f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f26:	f6 c2 01             	test   $0x1,%dl
  801f29:	74 0e                	je     801f39 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f2b:	c1 ea 0c             	shr    $0xc,%edx
  801f2e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f35:	ef 
  801f36:	0f b7 c0             	movzwl %ax,%eax
}
  801f39:	5d                   	pop    %ebp
  801f3a:	c3                   	ret    
  801f3b:	66 90                	xchg   %ax,%ax
  801f3d:	66 90                	xchg   %ax,%ax
  801f3f:	90                   	nop

00801f40 <__udivdi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 1c             	sub    $0x1c,%esp
  801f47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f57:	85 f6                	test   %esi,%esi
  801f59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5d:	89 ca                	mov    %ecx,%edx
  801f5f:	89 f8                	mov    %edi,%eax
  801f61:	75 3d                	jne    801fa0 <__udivdi3+0x60>
  801f63:	39 cf                	cmp    %ecx,%edi
  801f65:	0f 87 c5 00 00 00    	ja     802030 <__udivdi3+0xf0>
  801f6b:	85 ff                	test   %edi,%edi
  801f6d:	89 fd                	mov    %edi,%ebp
  801f6f:	75 0b                	jne    801f7c <__udivdi3+0x3c>
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
  801f76:	31 d2                	xor    %edx,%edx
  801f78:	f7 f7                	div    %edi
  801f7a:	89 c5                	mov    %eax,%ebp
  801f7c:	89 c8                	mov    %ecx,%eax
  801f7e:	31 d2                	xor    %edx,%edx
  801f80:	f7 f5                	div    %ebp
  801f82:	89 c1                	mov    %eax,%ecx
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	89 cf                	mov    %ecx,%edi
  801f88:	f7 f5                	div    %ebp
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	39 ce                	cmp    %ecx,%esi
  801fa2:	77 74                	ja     802018 <__udivdi3+0xd8>
  801fa4:	0f bd fe             	bsr    %esi,%edi
  801fa7:	83 f7 1f             	xor    $0x1f,%edi
  801faa:	0f 84 98 00 00 00    	je     802048 <__udivdi3+0x108>
  801fb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	89 c5                	mov    %eax,%ebp
  801fb9:	29 fb                	sub    %edi,%ebx
  801fbb:	d3 e6                	shl    %cl,%esi
  801fbd:	89 d9                	mov    %ebx,%ecx
  801fbf:	d3 ed                	shr    %cl,%ebp
  801fc1:	89 f9                	mov    %edi,%ecx
  801fc3:	d3 e0                	shl    %cl,%eax
  801fc5:	09 ee                	or     %ebp,%esi
  801fc7:	89 d9                	mov    %ebx,%ecx
  801fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcd:	89 d5                	mov    %edx,%ebp
  801fcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fd3:	d3 ed                	shr    %cl,%ebp
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e2                	shl    %cl,%edx
  801fd9:	89 d9                	mov    %ebx,%ecx
  801fdb:	d3 e8                	shr    %cl,%eax
  801fdd:	09 c2                	or     %eax,%edx
  801fdf:	89 d0                	mov    %edx,%eax
  801fe1:	89 ea                	mov    %ebp,%edx
  801fe3:	f7 f6                	div    %esi
  801fe5:	89 d5                	mov    %edx,%ebp
  801fe7:	89 c3                	mov    %eax,%ebx
  801fe9:	f7 64 24 0c          	mull   0xc(%esp)
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	72 10                	jb     802001 <__udivdi3+0xc1>
  801ff1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e6                	shl    %cl,%esi
  801ff9:	39 c6                	cmp    %eax,%esi
  801ffb:	73 07                	jae    802004 <__udivdi3+0xc4>
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	75 03                	jne    802004 <__udivdi3+0xc4>
  802001:	83 eb 01             	sub    $0x1,%ebx
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 d8                	mov    %ebx,%eax
  802008:	89 fa                	mov    %edi,%edx
  80200a:	83 c4 1c             	add    $0x1c,%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802018:	31 ff                	xor    %edi,%edi
  80201a:	31 db                	xor    %ebx,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 d8                	mov    %ebx,%eax
  802032:	f7 f7                	div    %edi
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 c3                	mov    %eax,%ebx
  802038:	89 d8                	mov    %ebx,%eax
  80203a:	89 fa                	mov    %edi,%edx
  80203c:	83 c4 1c             	add    $0x1c,%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	39 ce                	cmp    %ecx,%esi
  80204a:	72 0c                	jb     802058 <__udivdi3+0x118>
  80204c:	31 db                	xor    %ebx,%ebx
  80204e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802052:	0f 87 34 ff ff ff    	ja     801f8c <__udivdi3+0x4c>
  802058:	bb 01 00 00 00       	mov    $0x1,%ebx
  80205d:	e9 2a ff ff ff       	jmp    801f8c <__udivdi3+0x4c>
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80207b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80207f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 d2                	test   %edx,%edx
  802089:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80208d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802091:	89 f3                	mov    %esi,%ebx
  802093:	89 3c 24             	mov    %edi,(%esp)
  802096:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209a:	75 1c                	jne    8020b8 <__umoddi3+0x48>
  80209c:	39 f7                	cmp    %esi,%edi
  80209e:	76 50                	jbe    8020f0 <__umoddi3+0x80>
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	f7 f7                	div    %edi
  8020a6:	89 d0                	mov    %edx,%eax
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	39 f2                	cmp    %esi,%edx
  8020ba:	89 d0                	mov    %edx,%eax
  8020bc:	77 52                	ja     802110 <__umoddi3+0xa0>
  8020be:	0f bd ea             	bsr    %edx,%ebp
  8020c1:	83 f5 1f             	xor    $0x1f,%ebp
  8020c4:	75 5a                	jne    802120 <__umoddi3+0xb0>
  8020c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ca:	0f 82 e0 00 00 00    	jb     8021b0 <__umoddi3+0x140>
  8020d0:	39 0c 24             	cmp    %ecx,(%esp)
  8020d3:	0f 86 d7 00 00 00    	jbe    8021b0 <__umoddi3+0x140>
  8020d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020e1:	83 c4 1c             	add    $0x1c,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	85 ff                	test   %edi,%edi
  8020f2:	89 fd                	mov    %edi,%ebp
  8020f4:	75 0b                	jne    802101 <__umoddi3+0x91>
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f7                	div    %edi
  8020ff:	89 c5                	mov    %eax,%ebp
  802101:	89 f0                	mov    %esi,%eax
  802103:	31 d2                	xor    %edx,%edx
  802105:	f7 f5                	div    %ebp
  802107:	89 c8                	mov    %ecx,%eax
  802109:	f7 f5                	div    %ebp
  80210b:	89 d0                	mov    %edx,%eax
  80210d:	eb 99                	jmp    8020a8 <__umoddi3+0x38>
  80210f:	90                   	nop
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	8b 34 24             	mov    (%esp),%esi
  802123:	bf 20 00 00 00       	mov    $0x20,%edi
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	29 ef                	sub    %ebp,%edi
  80212c:	d3 e0                	shl    %cl,%eax
  80212e:	89 f9                	mov    %edi,%ecx
  802130:	89 f2                	mov    %esi,%edx
  802132:	d3 ea                	shr    %cl,%edx
  802134:	89 e9                	mov    %ebp,%ecx
  802136:	09 c2                	or     %eax,%edx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 14 24             	mov    %edx,(%esp)
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	d3 e2                	shl    %cl,%edx
  802141:	89 f9                	mov    %edi,%ecx
  802143:	89 54 24 04          	mov    %edx,0x4(%esp)
  802147:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	89 e9                	mov    %ebp,%ecx
  80214f:	89 c6                	mov    %eax,%esi
  802151:	d3 e3                	shl    %cl,%ebx
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 d0                	mov    %edx,%eax
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	09 d8                	or     %ebx,%eax
  80215d:	89 d3                	mov    %edx,%ebx
  80215f:	89 f2                	mov    %esi,%edx
  802161:	f7 34 24             	divl   (%esp)
  802164:	89 d6                	mov    %edx,%esi
  802166:	d3 e3                	shl    %cl,%ebx
  802168:	f7 64 24 04          	mull   0x4(%esp)
  80216c:	39 d6                	cmp    %edx,%esi
  80216e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802172:	89 d1                	mov    %edx,%ecx
  802174:	89 c3                	mov    %eax,%ebx
  802176:	72 08                	jb     802180 <__umoddi3+0x110>
  802178:	75 11                	jne    80218b <__umoddi3+0x11b>
  80217a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80217e:	73 0b                	jae    80218b <__umoddi3+0x11b>
  802180:	2b 44 24 04          	sub    0x4(%esp),%eax
  802184:	1b 14 24             	sbb    (%esp),%edx
  802187:	89 d1                	mov    %edx,%ecx
  802189:	89 c3                	mov    %eax,%ebx
  80218b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80218f:	29 da                	sub    %ebx,%edx
  802191:	19 ce                	sbb    %ecx,%esi
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 f0                	mov    %esi,%eax
  802197:	d3 e0                	shl    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	d3 ea                	shr    %cl,%edx
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	d3 ee                	shr    %cl,%esi
  8021a1:	09 d0                	or     %edx,%eax
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	83 c4 1c             	add    $0x1c,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	29 f9                	sub    %edi,%ecx
  8021b2:	19 d6                	sbb    %edx,%esi
  8021b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bc:	e9 18 ff ff ff       	jmp    8020d9 <__umoddi3+0x69>
