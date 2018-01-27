
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  800042:	e8 5d 01 00 00       	call   8001a4 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 99 02 00 00       	call   8002ef <sys_env_set_pgfault_upcall>
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
  800070:	e8 f1 00 00 00       	call   800166 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x30>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
  80009a:	e8 94 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009f:	e8 2a 00 00 00       	call   8000ce <exit>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    

008000ae <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000b4:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000b9:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000bb:	e8 a6 00 00 00       	call   800166 <sys_getenvid>
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	50                   	push   %eax
  8000c4:	e8 ec 02 00 00       	call   8003b5 <sys_thread_free>
}
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    

008000ce <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000d4:	e8 bb 07 00 00       	call   800894 <close_all>
	sys_env_destroy(0);
  8000d9:	83 ec 0c             	sub    $0xc,%esp
  8000dc:	6a 00                	push   $0x0
  8000de:	e8 42 00 00 00       	call   800125 <sys_env_destroy>
}
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	89 c3                	mov    %eax,%ebx
  8000fb:	89 c7                	mov    %eax,%edi
  8000fd:	89 c6                	mov    %eax,%esi
  8000ff:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <sys_cgetc>:

int
sys_cgetc(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	57                   	push   %edi
  80010a:	56                   	push   %esi
  80010b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010c:	ba 00 00 00 00       	mov    $0x0,%edx
  800111:	b8 01 00 00 00       	mov    $0x1,%eax
  800116:	89 d1                	mov    %edx,%ecx
  800118:	89 d3                	mov    %edx,%ebx
  80011a:	89 d7                	mov    %edx,%edi
  80011c:	89 d6                	mov    %edx,%esi
  80011e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
  80012b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800133:	b8 03 00 00 00       	mov    $0x3,%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	89 cb                	mov    %ecx,%ebx
  80013d:	89 cf                	mov    %ecx,%edi
  80013f:	89 ce                	mov    %ecx,%esi
  800141:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800143:	85 c0                	test   %eax,%eax
  800145:	7e 17                	jle    80015e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	50                   	push   %eax
  80014b:	6a 03                	push   $0x3
  80014d:	68 ea 21 80 00       	push   $0x8021ea
  800152:	6a 23                	push   $0x23
  800154:	68 07 22 80 00       	push   $0x802207
  800159:	e8 5e 12 00 00       	call   8013bc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	ba 00 00 00 00       	mov    $0x0,%edx
  800171:	b8 02 00 00 00       	mov    $0x2,%eax
  800176:	89 d1                	mov    %edx,%ecx
  800178:	89 d3                	mov    %edx,%ebx
  80017a:	89 d7                	mov    %edx,%edi
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <sys_yield>:

void
sys_yield(void)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018b:	ba 00 00 00 00       	mov    $0x0,%edx
  800190:	b8 0b 00 00 00       	mov    $0xb,%eax
  800195:	89 d1                	mov    %edx,%ecx
  800197:	89 d3                	mov    %edx,%ebx
  800199:	89 d7                	mov    %edx,%edi
  80019b:	89 d6                	mov    %edx,%esi
  80019d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80019f:	5b                   	pop    %ebx
  8001a0:	5e                   	pop    %esi
  8001a1:	5f                   	pop    %edi
  8001a2:	5d                   	pop    %ebp
  8001a3:	c3                   	ret    

008001a4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	57                   	push   %edi
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ad:	be 00 00 00 00       	mov    $0x0,%esi
  8001b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	89 f7                	mov    %esi,%edi
  8001c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7e 17                	jle    8001df <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 04                	push   $0x4
  8001ce:	68 ea 21 80 00       	push   $0x8021ea
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 07 22 80 00       	push   $0x802207
  8001da:	e8 dd 11 00 00       	call   8013bc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800201:	8b 75 18             	mov    0x18(%ebp),%esi
  800204:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7e 17                	jle    800221 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 05                	push   $0x5
  800210:	68 ea 21 80 00       	push   $0x8021ea
  800215:	6a 23                	push   $0x23
  800217:	68 07 22 80 00       	push   $0x802207
  80021c:	e8 9b 11 00 00       	call   8013bc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	b8 06 00 00 00       	mov    $0x6,%eax
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 17                	jle    800263 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 06                	push   $0x6
  800252:	68 ea 21 80 00       	push   $0x8021ea
  800257:	6a 23                	push   $0x23
  800259:	68 07 22 80 00       	push   $0x802207
  80025e:	e8 59 11 00 00       	call   8013bc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	b8 08 00 00 00       	mov    $0x8,%eax
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 17                	jle    8002a5 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 08                	push   $0x8
  800294:	68 ea 21 80 00       	push   $0x8021ea
  800299:	6a 23                	push   $0x23
  80029b:	68 07 22 80 00       	push   $0x802207
  8002a0:	e8 17 11 00 00       	call   8013bc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
  8002b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bb:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c6:	89 df                	mov    %ebx,%edi
  8002c8:	89 de                	mov    %ebx,%esi
  8002ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	7e 17                	jle    8002e7 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	50                   	push   %eax
  8002d4:	6a 09                	push   $0x9
  8002d6:	68 ea 21 80 00       	push   $0x8021ea
  8002db:	6a 23                	push   $0x23
  8002dd:	68 07 22 80 00       	push   $0x802207
  8002e2:	e8 d5 10 00 00       	call   8013bc <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ea:	5b                   	pop    %ebx
  8002eb:	5e                   	pop    %esi
  8002ec:	5f                   	pop    %edi
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	57                   	push   %edi
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
  8002f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800302:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	89 df                	mov    %ebx,%edi
  80030a:	89 de                	mov    %ebx,%esi
  80030c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80030e:	85 c0                	test   %eax,%eax
  800310:	7e 17                	jle    800329 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	50                   	push   %eax
  800316:	6a 0a                	push   $0xa
  800318:	68 ea 21 80 00       	push   $0x8021ea
  80031d:	6a 23                	push   $0x23
  80031f:	68 07 22 80 00       	push   $0x802207
  800324:	e8 93 10 00 00       	call   8013bc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800329:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800337:	be 00 00 00 00       	mov    $0x0,%esi
  80033c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800341:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80034d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
  80035a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800362:	b8 0d 00 00 00       	mov    $0xd,%eax
  800367:	8b 55 08             	mov    0x8(%ebp),%edx
  80036a:	89 cb                	mov    %ecx,%ebx
  80036c:	89 cf                	mov    %ecx,%edi
  80036e:	89 ce                	mov    %ecx,%esi
  800370:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800372:	85 c0                	test   %eax,%eax
  800374:	7e 17                	jle    80038d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	50                   	push   %eax
  80037a:	6a 0d                	push   $0xd
  80037c:	68 ea 21 80 00       	push   $0x8021ea
  800381:	6a 23                	push   $0x23
  800383:	68 07 22 80 00       	push   $0x802207
  800388:	e8 2f 10 00 00       	call   8013bc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80038d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800390:	5b                   	pop    %ebx
  800391:	5e                   	pop    %esi
  800392:	5f                   	pop    %edi
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	57                   	push   %edi
  800399:	56                   	push   %esi
  80039a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	89 cb                	mov    %ecx,%ebx
  8003aa:	89 cf                	mov    %ecx,%edi
  8003ac:	89 ce                	mov    %ecx,%esi
  8003ae:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  8003b0:	5b                   	pop    %ebx
  8003b1:	5e                   	pop    %esi
  8003b2:	5f                   	pop    %edi
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	57                   	push   %edi
  8003b9:	56                   	push   %esi
  8003ba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c0:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c8:	89 cb                	mov    %ecx,%ebx
  8003ca:	89 cf                	mov    %ecx,%edi
  8003cc:	89 ce                	mov    %ecx,%esi
  8003ce:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003d0:	5b                   	pop    %ebx
  8003d1:	5e                   	pop    %esi
  8003d2:	5f                   	pop    %edi
  8003d3:	5d                   	pop    %ebp
  8003d4:	c3                   	ret    

008003d5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	53                   	push   %ebx
  8003d9:	83 ec 04             	sub    $0x4,%esp
  8003dc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003df:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003e1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003e5:	74 11                	je     8003f8 <pgfault+0x23>
  8003e7:	89 d8                	mov    %ebx,%eax
  8003e9:	c1 e8 0c             	shr    $0xc,%eax
  8003ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003f3:	f6 c4 08             	test   $0x8,%ah
  8003f6:	75 14                	jne    80040c <pgfault+0x37>
		panic("faulting access");
  8003f8:	83 ec 04             	sub    $0x4,%esp
  8003fb:	68 15 22 80 00       	push   $0x802215
  800400:	6a 1e                	push   $0x1e
  800402:	68 25 22 80 00       	push   $0x802225
  800407:	e8 b0 0f 00 00       	call   8013bc <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  80040c:	83 ec 04             	sub    $0x4,%esp
  80040f:	6a 07                	push   $0x7
  800411:	68 00 f0 7f 00       	push   $0x7ff000
  800416:	6a 00                	push   $0x0
  800418:	e8 87 fd ff ff       	call   8001a4 <sys_page_alloc>
	if (r < 0) {
  80041d:	83 c4 10             	add    $0x10,%esp
  800420:	85 c0                	test   %eax,%eax
  800422:	79 12                	jns    800436 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800424:	50                   	push   %eax
  800425:	68 30 22 80 00       	push   $0x802230
  80042a:	6a 2c                	push   $0x2c
  80042c:	68 25 22 80 00       	push   $0x802225
  800431:	e8 86 0f 00 00       	call   8013bc <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800436:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80043c:	83 ec 04             	sub    $0x4,%esp
  80043f:	68 00 10 00 00       	push   $0x1000
  800444:	53                   	push   %ebx
  800445:	68 00 f0 7f 00       	push   $0x7ff000
  80044a:	e8 c5 17 00 00       	call   801c14 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80044f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800456:	53                   	push   %ebx
  800457:	6a 00                	push   $0x0
  800459:	68 00 f0 7f 00       	push   $0x7ff000
  80045e:	6a 00                	push   $0x0
  800460:	e8 82 fd ff ff       	call   8001e7 <sys_page_map>
	if (r < 0) {
  800465:	83 c4 20             	add    $0x20,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 30 22 80 00       	push   $0x802230
  800472:	6a 33                	push   $0x33
  800474:	68 25 22 80 00       	push   $0x802225
  800479:	e8 3e 0f 00 00       	call   8013bc <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	68 00 f0 7f 00       	push   $0x7ff000
  800486:	6a 00                	push   $0x0
  800488:	e8 9c fd ff ff       	call   800229 <sys_page_unmap>
	if (r < 0) {
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	85 c0                	test   %eax,%eax
  800492:	79 12                	jns    8004a6 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800494:	50                   	push   %eax
  800495:	68 30 22 80 00       	push   $0x802230
  80049a:	6a 37                	push   $0x37
  80049c:	68 25 22 80 00       	push   $0x802225
  8004a1:	e8 16 0f 00 00       	call   8013bc <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004a9:	c9                   	leave  
  8004aa:	c3                   	ret    

008004ab <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	57                   	push   %edi
  8004af:	56                   	push   %esi
  8004b0:	53                   	push   %ebx
  8004b1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004b4:	68 d5 03 80 00       	push   $0x8003d5
  8004b9:	e8 a3 18 00 00       	call   801d61 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004be:	b8 07 00 00 00       	mov    $0x7,%eax
  8004c3:	cd 30                	int    $0x30
  8004c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	79 17                	jns    8004e6 <fork+0x3b>
		panic("fork fault %e");
  8004cf:	83 ec 04             	sub    $0x4,%esp
  8004d2:	68 49 22 80 00       	push   $0x802249
  8004d7:	68 84 00 00 00       	push   $0x84
  8004dc:	68 25 22 80 00       	push   $0x802225
  8004e1:	e8 d6 0e 00 00       	call   8013bc <_panic>
  8004e6:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004e8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ec:	75 24                	jne    800512 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004ee:	e8 73 fc ff ff       	call   800166 <sys_getenvid>
  8004f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004f8:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8004fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800503:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800508:	b8 00 00 00 00       	mov    $0x0,%eax
  80050d:	e9 64 01 00 00       	jmp    800676 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800512:	83 ec 04             	sub    $0x4,%esp
  800515:	6a 07                	push   $0x7
  800517:	68 00 f0 bf ee       	push   $0xeebff000
  80051c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80051f:	e8 80 fc ff ff       	call   8001a4 <sys_page_alloc>
  800524:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800527:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80052c:	89 d8                	mov    %ebx,%eax
  80052e:	c1 e8 16             	shr    $0x16,%eax
  800531:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800538:	a8 01                	test   $0x1,%al
  80053a:	0f 84 fc 00 00 00    	je     80063c <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800540:	89 d8                	mov    %ebx,%eax
  800542:	c1 e8 0c             	shr    $0xc,%eax
  800545:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80054c:	f6 c2 01             	test   $0x1,%dl
  80054f:	0f 84 e7 00 00 00    	je     80063c <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800555:	89 c6                	mov    %eax,%esi
  800557:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80055a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800561:	f6 c6 04             	test   $0x4,%dh
  800564:	74 39                	je     80059f <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800566:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80056d:	83 ec 0c             	sub    $0xc,%esp
  800570:	25 07 0e 00 00       	and    $0xe07,%eax
  800575:	50                   	push   %eax
  800576:	56                   	push   %esi
  800577:	57                   	push   %edi
  800578:	56                   	push   %esi
  800579:	6a 00                	push   $0x0
  80057b:	e8 67 fc ff ff       	call   8001e7 <sys_page_map>
		if (r < 0) {
  800580:	83 c4 20             	add    $0x20,%esp
  800583:	85 c0                	test   %eax,%eax
  800585:	0f 89 b1 00 00 00    	jns    80063c <fork+0x191>
		    	panic("sys page map fault %e");
  80058b:	83 ec 04             	sub    $0x4,%esp
  80058e:	68 57 22 80 00       	push   $0x802257
  800593:	6a 54                	push   $0x54
  800595:	68 25 22 80 00       	push   $0x802225
  80059a:	e8 1d 0e 00 00       	call   8013bc <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  80059f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a6:	f6 c2 02             	test   $0x2,%dl
  8005a9:	75 0c                	jne    8005b7 <fork+0x10c>
  8005ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b2:	f6 c4 08             	test   $0x8,%ah
  8005b5:	74 5b                	je     800612 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005b7:	83 ec 0c             	sub    $0xc,%esp
  8005ba:	68 05 08 00 00       	push   $0x805
  8005bf:	56                   	push   %esi
  8005c0:	57                   	push   %edi
  8005c1:	56                   	push   %esi
  8005c2:	6a 00                	push   $0x0
  8005c4:	e8 1e fc ff ff       	call   8001e7 <sys_page_map>
		if (r < 0) {
  8005c9:	83 c4 20             	add    $0x20,%esp
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	79 14                	jns    8005e4 <fork+0x139>
		    	panic("sys page map fault %e");
  8005d0:	83 ec 04             	sub    $0x4,%esp
  8005d3:	68 57 22 80 00       	push   $0x802257
  8005d8:	6a 5b                	push   $0x5b
  8005da:	68 25 22 80 00       	push   $0x802225
  8005df:	e8 d8 0d 00 00       	call   8013bc <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005e4:	83 ec 0c             	sub    $0xc,%esp
  8005e7:	68 05 08 00 00       	push   $0x805
  8005ec:	56                   	push   %esi
  8005ed:	6a 00                	push   $0x0
  8005ef:	56                   	push   %esi
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 f0 fb ff ff       	call   8001e7 <sys_page_map>
		if (r < 0) {
  8005f7:	83 c4 20             	add    $0x20,%esp
  8005fa:	85 c0                	test   %eax,%eax
  8005fc:	79 3e                	jns    80063c <fork+0x191>
		    	panic("sys page map fault %e");
  8005fe:	83 ec 04             	sub    $0x4,%esp
  800601:	68 57 22 80 00       	push   $0x802257
  800606:	6a 5f                	push   $0x5f
  800608:	68 25 22 80 00       	push   $0x802225
  80060d:	e8 aa 0d 00 00       	call   8013bc <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800612:	83 ec 0c             	sub    $0xc,%esp
  800615:	6a 05                	push   $0x5
  800617:	56                   	push   %esi
  800618:	57                   	push   %edi
  800619:	56                   	push   %esi
  80061a:	6a 00                	push   $0x0
  80061c:	e8 c6 fb ff ff       	call   8001e7 <sys_page_map>
		if (r < 0) {
  800621:	83 c4 20             	add    $0x20,%esp
  800624:	85 c0                	test   %eax,%eax
  800626:	79 14                	jns    80063c <fork+0x191>
		    	panic("sys page map fault %e");
  800628:	83 ec 04             	sub    $0x4,%esp
  80062b:	68 57 22 80 00       	push   $0x802257
  800630:	6a 64                	push   $0x64
  800632:	68 25 22 80 00       	push   $0x802225
  800637:	e8 80 0d 00 00       	call   8013bc <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80063c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800642:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800648:	0f 85 de fe ff ff    	jne    80052c <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80064e:	a1 04 40 80 00       	mov    0x804004,%eax
  800653:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	50                   	push   %eax
  80065d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800660:	57                   	push   %edi
  800661:	e8 89 fc ff ff       	call   8002ef <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800666:	83 c4 08             	add    $0x8,%esp
  800669:	6a 02                	push   $0x2
  80066b:	57                   	push   %edi
  80066c:	e8 fa fb ff ff       	call   80026b <sys_env_set_status>
	
	return envid;
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800676:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800679:	5b                   	pop    %ebx
  80067a:	5e                   	pop    %esi
  80067b:	5f                   	pop    %edi
  80067c:	5d                   	pop    %ebp
  80067d:	c3                   	ret    

0080067e <sfork>:

envid_t
sfork(void)
{
  80067e:	55                   	push   %ebp
  80067f:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800681:	b8 00 00 00 00       	mov    $0x0,%eax
  800686:	5d                   	pop    %ebp
  800687:	c3                   	ret    

00800688 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
  80068d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800690:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	68 70 22 80 00       	push   $0x802270
  80069f:	e8 f1 0d 00 00       	call   801495 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006a4:	c7 04 24 ae 00 80 00 	movl   $0x8000ae,(%esp)
  8006ab:	e8 e5 fc ff ff       	call   800395 <sys_thread_create>
  8006b0:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006b2:	83 c4 08             	add    $0x8,%esp
  8006b5:	53                   	push   %ebx
  8006b6:	68 70 22 80 00       	push   $0x802270
  8006bb:	e8 d5 0d 00 00       	call   801495 <cprintf>
	return id;
}
  8006c0:	89 f0                	mov    %esi,%eax
  8006c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006c5:	5b                   	pop    %ebx
  8006c6:	5e                   	pop    %esi
  8006c7:	5d                   	pop    %ebp
  8006c8:	c3                   	ret    

008006c9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cf:	05 00 00 00 30       	add    $0x30000000,%eax
  8006d4:	c1 e8 0c             	shr    $0xc,%eax
}
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006d9:	55                   	push   %ebp
  8006da:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	05 00 00 00 30       	add    $0x30000000,%eax
  8006e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006e9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8006fb:	89 c2                	mov    %eax,%edx
  8006fd:	c1 ea 16             	shr    $0x16,%edx
  800700:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800707:	f6 c2 01             	test   $0x1,%dl
  80070a:	74 11                	je     80071d <fd_alloc+0x2d>
  80070c:	89 c2                	mov    %eax,%edx
  80070e:	c1 ea 0c             	shr    $0xc,%edx
  800711:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800718:	f6 c2 01             	test   $0x1,%dl
  80071b:	75 09                	jne    800726 <fd_alloc+0x36>
			*fd_store = fd;
  80071d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80071f:	b8 00 00 00 00       	mov    $0x0,%eax
  800724:	eb 17                	jmp    80073d <fd_alloc+0x4d>
  800726:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80072b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800730:	75 c9                	jne    8006fb <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800732:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800738:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800745:	83 f8 1f             	cmp    $0x1f,%eax
  800748:	77 36                	ja     800780 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80074a:	c1 e0 0c             	shl    $0xc,%eax
  80074d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800752:	89 c2                	mov    %eax,%edx
  800754:	c1 ea 16             	shr    $0x16,%edx
  800757:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80075e:	f6 c2 01             	test   $0x1,%dl
  800761:	74 24                	je     800787 <fd_lookup+0x48>
  800763:	89 c2                	mov    %eax,%edx
  800765:	c1 ea 0c             	shr    $0xc,%edx
  800768:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80076f:	f6 c2 01             	test   $0x1,%dl
  800772:	74 1a                	je     80078e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800774:	8b 55 0c             	mov    0xc(%ebp),%edx
  800777:	89 02                	mov    %eax,(%edx)
	return 0;
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
  80077e:	eb 13                	jmp    800793 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800780:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800785:	eb 0c                	jmp    800793 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800787:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078c:	eb 05                	jmp    800793 <fd_lookup+0x54>
  80078e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 08             	sub    $0x8,%esp
  80079b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079e:	ba 10 23 80 00       	mov    $0x802310,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007a3:	eb 13                	jmp    8007b8 <dev_lookup+0x23>
  8007a5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007a8:	39 08                	cmp    %ecx,(%eax)
  8007aa:	75 0c                	jne    8007b8 <dev_lookup+0x23>
			*dev = devtab[i];
  8007ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b6:	eb 2e                	jmp    8007e6 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007b8:	8b 02                	mov    (%edx),%eax
  8007ba:	85 c0                	test   %eax,%eax
  8007bc:	75 e7                	jne    8007a5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007be:	a1 04 40 80 00       	mov    0x804004,%eax
  8007c3:	8b 40 7c             	mov    0x7c(%eax),%eax
  8007c6:	83 ec 04             	sub    $0x4,%esp
  8007c9:	51                   	push   %ecx
  8007ca:	50                   	push   %eax
  8007cb:	68 94 22 80 00       	push   $0x802294
  8007d0:	e8 c0 0c 00 00       	call   801495 <cprintf>
	*dev = 0;
  8007d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	56                   	push   %esi
  8007ec:	53                   	push   %ebx
  8007ed:	83 ec 10             	sub    $0x10,%esp
  8007f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8007f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f9:	50                   	push   %eax
  8007fa:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800800:	c1 e8 0c             	shr    $0xc,%eax
  800803:	50                   	push   %eax
  800804:	e8 36 ff ff ff       	call   80073f <fd_lookup>
  800809:	83 c4 08             	add    $0x8,%esp
  80080c:	85 c0                	test   %eax,%eax
  80080e:	78 05                	js     800815 <fd_close+0x2d>
	    || fd != fd2)
  800810:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800813:	74 0c                	je     800821 <fd_close+0x39>
		return (must_exist ? r : 0);
  800815:	84 db                	test   %bl,%bl
  800817:	ba 00 00 00 00       	mov    $0x0,%edx
  80081c:	0f 44 c2             	cmove  %edx,%eax
  80081f:	eb 41                	jmp    800862 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800821:	83 ec 08             	sub    $0x8,%esp
  800824:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800827:	50                   	push   %eax
  800828:	ff 36                	pushl  (%esi)
  80082a:	e8 66 ff ff ff       	call   800795 <dev_lookup>
  80082f:	89 c3                	mov    %eax,%ebx
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	85 c0                	test   %eax,%eax
  800836:	78 1a                	js     800852 <fd_close+0x6a>
		if (dev->dev_close)
  800838:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80083e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800843:	85 c0                	test   %eax,%eax
  800845:	74 0b                	je     800852 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800847:	83 ec 0c             	sub    $0xc,%esp
  80084a:	56                   	push   %esi
  80084b:	ff d0                	call   *%eax
  80084d:	89 c3                	mov    %eax,%ebx
  80084f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800852:	83 ec 08             	sub    $0x8,%esp
  800855:	56                   	push   %esi
  800856:	6a 00                	push   $0x0
  800858:	e8 cc f9 ff ff       	call   800229 <sys_page_unmap>
	return r;
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	89 d8                	mov    %ebx,%eax
}
  800862:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800865:	5b                   	pop    %ebx
  800866:	5e                   	pop    %esi
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80086f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800872:	50                   	push   %eax
  800873:	ff 75 08             	pushl  0x8(%ebp)
  800876:	e8 c4 fe ff ff       	call   80073f <fd_lookup>
  80087b:	83 c4 08             	add    $0x8,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 10                	js     800892 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	6a 01                	push   $0x1
  800887:	ff 75 f4             	pushl  -0xc(%ebp)
  80088a:	e8 59 ff ff ff       	call   8007e8 <fd_close>
  80088f:	83 c4 10             	add    $0x10,%esp
}
  800892:	c9                   	leave  
  800893:	c3                   	ret    

00800894 <close_all>:

void
close_all(void)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80089b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008a0:	83 ec 0c             	sub    $0xc,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	e8 c0 ff ff ff       	call   800869 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008a9:	83 c3 01             	add    $0x1,%ebx
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	83 fb 20             	cmp    $0x20,%ebx
  8008b2:	75 ec                	jne    8008a0 <close_all+0xc>
		close(i);
}
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	57                   	push   %edi
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	83 ec 2c             	sub    $0x2c,%esp
  8008c2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008c8:	50                   	push   %eax
  8008c9:	ff 75 08             	pushl  0x8(%ebp)
  8008cc:	e8 6e fe ff ff       	call   80073f <fd_lookup>
  8008d1:	83 c4 08             	add    $0x8,%esp
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	0f 88 c1 00 00 00    	js     80099d <dup+0xe4>
		return r;
	close(newfdnum);
  8008dc:	83 ec 0c             	sub    $0xc,%esp
  8008df:	56                   	push   %esi
  8008e0:	e8 84 ff ff ff       	call   800869 <close>

	newfd = INDEX2FD(newfdnum);
  8008e5:	89 f3                	mov    %esi,%ebx
  8008e7:	c1 e3 0c             	shl    $0xc,%ebx
  8008ea:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8008f0:	83 c4 04             	add    $0x4,%esp
  8008f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8008f6:	e8 de fd ff ff       	call   8006d9 <fd2data>
  8008fb:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8008fd:	89 1c 24             	mov    %ebx,(%esp)
  800900:	e8 d4 fd ff ff       	call   8006d9 <fd2data>
  800905:	83 c4 10             	add    $0x10,%esp
  800908:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80090b:	89 f8                	mov    %edi,%eax
  80090d:	c1 e8 16             	shr    $0x16,%eax
  800910:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800917:	a8 01                	test   $0x1,%al
  800919:	74 37                	je     800952 <dup+0x99>
  80091b:	89 f8                	mov    %edi,%eax
  80091d:	c1 e8 0c             	shr    $0xc,%eax
  800920:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800927:	f6 c2 01             	test   $0x1,%dl
  80092a:	74 26                	je     800952 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80092c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	25 07 0e 00 00       	and    $0xe07,%eax
  80093b:	50                   	push   %eax
  80093c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80093f:	6a 00                	push   $0x0
  800941:	57                   	push   %edi
  800942:	6a 00                	push   $0x0
  800944:	e8 9e f8 ff ff       	call   8001e7 <sys_page_map>
  800949:	89 c7                	mov    %eax,%edi
  80094b:	83 c4 20             	add    $0x20,%esp
  80094e:	85 c0                	test   %eax,%eax
  800950:	78 2e                	js     800980 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800952:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800955:	89 d0                	mov    %edx,%eax
  800957:	c1 e8 0c             	shr    $0xc,%eax
  80095a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800961:	83 ec 0c             	sub    $0xc,%esp
  800964:	25 07 0e 00 00       	and    $0xe07,%eax
  800969:	50                   	push   %eax
  80096a:	53                   	push   %ebx
  80096b:	6a 00                	push   $0x0
  80096d:	52                   	push   %edx
  80096e:	6a 00                	push   $0x0
  800970:	e8 72 f8 ff ff       	call   8001e7 <sys_page_map>
  800975:	89 c7                	mov    %eax,%edi
  800977:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80097a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80097c:	85 ff                	test   %edi,%edi
  80097e:	79 1d                	jns    80099d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800980:	83 ec 08             	sub    $0x8,%esp
  800983:	53                   	push   %ebx
  800984:	6a 00                	push   $0x0
  800986:	e8 9e f8 ff ff       	call   800229 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80098b:	83 c4 08             	add    $0x8,%esp
  80098e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800991:	6a 00                	push   $0x0
  800993:	e8 91 f8 ff ff       	call   800229 <sys_page_unmap>
	return r;
  800998:	83 c4 10             	add    $0x10,%esp
  80099b:	89 f8                	mov    %edi,%eax
}
  80099d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	53                   	push   %ebx
  8009a9:	83 ec 14             	sub    $0x14,%esp
  8009ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009b2:	50                   	push   %eax
  8009b3:	53                   	push   %ebx
  8009b4:	e8 86 fd ff ff       	call   80073f <fd_lookup>
  8009b9:	83 c4 08             	add    $0x8,%esp
  8009bc:	89 c2                	mov    %eax,%edx
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 6d                	js     800a2f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009c8:	50                   	push   %eax
  8009c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009cc:	ff 30                	pushl  (%eax)
  8009ce:	e8 c2 fd ff ff       	call   800795 <dev_lookup>
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	85 c0                	test   %eax,%eax
  8009d8:	78 4c                	js     800a26 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009da:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009dd:	8b 42 08             	mov    0x8(%edx),%eax
  8009e0:	83 e0 03             	and    $0x3,%eax
  8009e3:	83 f8 01             	cmp    $0x1,%eax
  8009e6:	75 21                	jne    800a09 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8009ed:	8b 40 7c             	mov    0x7c(%eax),%eax
  8009f0:	83 ec 04             	sub    $0x4,%esp
  8009f3:	53                   	push   %ebx
  8009f4:	50                   	push   %eax
  8009f5:	68 d5 22 80 00       	push   $0x8022d5
  8009fa:	e8 96 0a 00 00       	call   801495 <cprintf>
		return -E_INVAL;
  8009ff:	83 c4 10             	add    $0x10,%esp
  800a02:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a07:	eb 26                	jmp    800a2f <read+0x8a>
	}
	if (!dev->dev_read)
  800a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a0c:	8b 40 08             	mov    0x8(%eax),%eax
  800a0f:	85 c0                	test   %eax,%eax
  800a11:	74 17                	je     800a2a <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a13:	83 ec 04             	sub    $0x4,%esp
  800a16:	ff 75 10             	pushl  0x10(%ebp)
  800a19:	ff 75 0c             	pushl  0xc(%ebp)
  800a1c:	52                   	push   %edx
  800a1d:	ff d0                	call   *%eax
  800a1f:	89 c2                	mov    %eax,%edx
  800a21:	83 c4 10             	add    $0x10,%esp
  800a24:	eb 09                	jmp    800a2f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a26:	89 c2                	mov    %eax,%edx
  800a28:	eb 05                	jmp    800a2f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a2a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a2f:	89 d0                	mov    %edx,%eax
  800a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	83 ec 0c             	sub    $0xc,%esp
  800a3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a42:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a4a:	eb 21                	jmp    800a6d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a4c:	83 ec 04             	sub    $0x4,%esp
  800a4f:	89 f0                	mov    %esi,%eax
  800a51:	29 d8                	sub    %ebx,%eax
  800a53:	50                   	push   %eax
  800a54:	89 d8                	mov    %ebx,%eax
  800a56:	03 45 0c             	add    0xc(%ebp),%eax
  800a59:	50                   	push   %eax
  800a5a:	57                   	push   %edi
  800a5b:	e8 45 ff ff ff       	call   8009a5 <read>
		if (m < 0)
  800a60:	83 c4 10             	add    $0x10,%esp
  800a63:	85 c0                	test   %eax,%eax
  800a65:	78 10                	js     800a77 <readn+0x41>
			return m;
		if (m == 0)
  800a67:	85 c0                	test   %eax,%eax
  800a69:	74 0a                	je     800a75 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a6b:	01 c3                	add    %eax,%ebx
  800a6d:	39 f3                	cmp    %esi,%ebx
  800a6f:	72 db                	jb     800a4c <readn+0x16>
  800a71:	89 d8                	mov    %ebx,%eax
  800a73:	eb 02                	jmp    800a77 <readn+0x41>
  800a75:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	53                   	push   %ebx
  800a83:	83 ec 14             	sub    $0x14,%esp
  800a86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a89:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a8c:	50                   	push   %eax
  800a8d:	53                   	push   %ebx
  800a8e:	e8 ac fc ff ff       	call   80073f <fd_lookup>
  800a93:	83 c4 08             	add    $0x8,%esp
  800a96:	89 c2                	mov    %eax,%edx
  800a98:	85 c0                	test   %eax,%eax
  800a9a:	78 68                	js     800b04 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a9c:	83 ec 08             	sub    $0x8,%esp
  800a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa2:	50                   	push   %eax
  800aa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aa6:	ff 30                	pushl  (%eax)
  800aa8:	e8 e8 fc ff ff       	call   800795 <dev_lookup>
  800aad:	83 c4 10             	add    $0x10,%esp
  800ab0:	85 c0                	test   %eax,%eax
  800ab2:	78 47                	js     800afb <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ab4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800abb:	75 21                	jne    800ade <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800abd:	a1 04 40 80 00       	mov    0x804004,%eax
  800ac2:	8b 40 7c             	mov    0x7c(%eax),%eax
  800ac5:	83 ec 04             	sub    $0x4,%esp
  800ac8:	53                   	push   %ebx
  800ac9:	50                   	push   %eax
  800aca:	68 f1 22 80 00       	push   $0x8022f1
  800acf:	e8 c1 09 00 00       	call   801495 <cprintf>
		return -E_INVAL;
  800ad4:	83 c4 10             	add    $0x10,%esp
  800ad7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800adc:	eb 26                	jmp    800b04 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ade:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae1:	8b 52 0c             	mov    0xc(%edx),%edx
  800ae4:	85 d2                	test   %edx,%edx
  800ae6:	74 17                	je     800aff <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ae8:	83 ec 04             	sub    $0x4,%esp
  800aeb:	ff 75 10             	pushl  0x10(%ebp)
  800aee:	ff 75 0c             	pushl  0xc(%ebp)
  800af1:	50                   	push   %eax
  800af2:	ff d2                	call   *%edx
  800af4:	89 c2                	mov    %eax,%edx
  800af6:	83 c4 10             	add    $0x10,%esp
  800af9:	eb 09                	jmp    800b04 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800afb:	89 c2                	mov    %eax,%edx
  800afd:	eb 05                	jmp    800b04 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800aff:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b04:	89 d0                	mov    %edx,%eax
  800b06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b09:	c9                   	leave  
  800b0a:	c3                   	ret    

00800b0b <seek>:

int
seek(int fdnum, off_t offset)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b11:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b14:	50                   	push   %eax
  800b15:	ff 75 08             	pushl  0x8(%ebp)
  800b18:	e8 22 fc ff ff       	call   80073f <fd_lookup>
  800b1d:	83 c4 08             	add    $0x8,%esp
  800b20:	85 c0                	test   %eax,%eax
  800b22:	78 0e                	js     800b32 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b24:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b32:	c9                   	leave  
  800b33:	c3                   	ret    

00800b34 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	53                   	push   %ebx
  800b38:	83 ec 14             	sub    $0x14,%esp
  800b3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b3e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b41:	50                   	push   %eax
  800b42:	53                   	push   %ebx
  800b43:	e8 f7 fb ff ff       	call   80073f <fd_lookup>
  800b48:	83 c4 08             	add    $0x8,%esp
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	78 65                	js     800bb6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b51:	83 ec 08             	sub    $0x8,%esp
  800b54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b57:	50                   	push   %eax
  800b58:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b5b:	ff 30                	pushl  (%eax)
  800b5d:	e8 33 fc ff ff       	call   800795 <dev_lookup>
  800b62:	83 c4 10             	add    $0x10,%esp
  800b65:	85 c0                	test   %eax,%eax
  800b67:	78 44                	js     800bad <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b69:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b6c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b70:	75 21                	jne    800b93 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b72:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b77:	8b 40 7c             	mov    0x7c(%eax),%eax
  800b7a:	83 ec 04             	sub    $0x4,%esp
  800b7d:	53                   	push   %ebx
  800b7e:	50                   	push   %eax
  800b7f:	68 b4 22 80 00       	push   $0x8022b4
  800b84:	e8 0c 09 00 00       	call   801495 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b89:	83 c4 10             	add    $0x10,%esp
  800b8c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b91:	eb 23                	jmp    800bb6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800b93:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b96:	8b 52 18             	mov    0x18(%edx),%edx
  800b99:	85 d2                	test   %edx,%edx
  800b9b:	74 14                	je     800bb1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800b9d:	83 ec 08             	sub    $0x8,%esp
  800ba0:	ff 75 0c             	pushl  0xc(%ebp)
  800ba3:	50                   	push   %eax
  800ba4:	ff d2                	call   *%edx
  800ba6:	89 c2                	mov    %eax,%edx
  800ba8:	83 c4 10             	add    $0x10,%esp
  800bab:	eb 09                	jmp    800bb6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bad:	89 c2                	mov    %eax,%edx
  800baf:	eb 05                	jmp    800bb6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800bb1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800bb6:	89 d0                	mov    %edx,%eax
  800bb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbb:	c9                   	leave  
  800bbc:	c3                   	ret    

00800bbd <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 14             	sub    $0x14,%esp
  800bc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bc7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bca:	50                   	push   %eax
  800bcb:	ff 75 08             	pushl  0x8(%ebp)
  800bce:	e8 6c fb ff ff       	call   80073f <fd_lookup>
  800bd3:	83 c4 08             	add    $0x8,%esp
  800bd6:	89 c2                	mov    %eax,%edx
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	78 58                	js     800c34 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bdc:	83 ec 08             	sub    $0x8,%esp
  800bdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800be2:	50                   	push   %eax
  800be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800be6:	ff 30                	pushl  (%eax)
  800be8:	e8 a8 fb ff ff       	call   800795 <dev_lookup>
  800bed:	83 c4 10             	add    $0x10,%esp
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	78 37                	js     800c2b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800bfb:	74 32                	je     800c2f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800bfd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c00:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c07:	00 00 00 
	stat->st_isdir = 0;
  800c0a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c11:	00 00 00 
	stat->st_dev = dev;
  800c14:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c1a:	83 ec 08             	sub    $0x8,%esp
  800c1d:	53                   	push   %ebx
  800c1e:	ff 75 f0             	pushl  -0x10(%ebp)
  800c21:	ff 50 14             	call   *0x14(%eax)
  800c24:	89 c2                	mov    %eax,%edx
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	eb 09                	jmp    800c34 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c2b:	89 c2                	mov    %eax,%edx
  800c2d:	eb 05                	jmp    800c34 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c2f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c34:	89 d0                	mov    %edx,%eax
  800c36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    

00800c3b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c40:	83 ec 08             	sub    $0x8,%esp
  800c43:	6a 00                	push   $0x0
  800c45:	ff 75 08             	pushl  0x8(%ebp)
  800c48:	e8 e3 01 00 00       	call   800e30 <open>
  800c4d:	89 c3                	mov    %eax,%ebx
  800c4f:	83 c4 10             	add    $0x10,%esp
  800c52:	85 c0                	test   %eax,%eax
  800c54:	78 1b                	js     800c71 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c56:	83 ec 08             	sub    $0x8,%esp
  800c59:	ff 75 0c             	pushl  0xc(%ebp)
  800c5c:	50                   	push   %eax
  800c5d:	e8 5b ff ff ff       	call   800bbd <fstat>
  800c62:	89 c6                	mov    %eax,%esi
	close(fd);
  800c64:	89 1c 24             	mov    %ebx,(%esp)
  800c67:	e8 fd fb ff ff       	call   800869 <close>
	return r;
  800c6c:	83 c4 10             	add    $0x10,%esp
  800c6f:	89 f0                	mov    %esi,%eax
}
  800c71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	89 c6                	mov    %eax,%esi
  800c7f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c81:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c88:	75 12                	jne    800c9c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c8a:	83 ec 0c             	sub    $0xc,%esp
  800c8d:	6a 01                	push   $0x1
  800c8f:	e8 39 12 00 00       	call   801ecd <ipc_find_env>
  800c94:	a3 00 40 80 00       	mov    %eax,0x804000
  800c99:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800c9c:	6a 07                	push   $0x7
  800c9e:	68 00 50 80 00       	push   $0x805000
  800ca3:	56                   	push   %esi
  800ca4:	ff 35 00 40 80 00    	pushl  0x804000
  800caa:	e8 bc 11 00 00       	call   801e6b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800caf:	83 c4 0c             	add    $0xc,%esp
  800cb2:	6a 00                	push   $0x0
  800cb4:	53                   	push   %ebx
  800cb5:	6a 00                	push   $0x0
  800cb7:	e8 34 11 00 00       	call   801df0 <ipc_recv>
}
  800cbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccc:	8b 40 0c             	mov    0xc(%eax),%eax
  800ccf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce1:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce6:	e8 8d ff ff ff       	call   800c78 <fsipc>
}
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    

00800ced <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf6:	8b 40 0c             	mov    0xc(%eax),%eax
  800cf9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800cfe:	ba 00 00 00 00       	mov    $0x0,%edx
  800d03:	b8 06 00 00 00       	mov    $0x6,%eax
  800d08:	e8 6b ff ff ff       	call   800c78 <fsipc>
}
  800d0d:	c9                   	leave  
  800d0e:	c3                   	ret    

00800d0f <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	53                   	push   %ebx
  800d13:	83 ec 04             	sub    $0x4,%esp
  800d16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	8b 40 0c             	mov    0xc(%eax),%eax
  800d1f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d24:	ba 00 00 00 00       	mov    $0x0,%edx
  800d29:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2e:	e8 45 ff ff ff       	call   800c78 <fsipc>
  800d33:	85 c0                	test   %eax,%eax
  800d35:	78 2c                	js     800d63 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d37:	83 ec 08             	sub    $0x8,%esp
  800d3a:	68 00 50 80 00       	push   $0x805000
  800d3f:	53                   	push   %ebx
  800d40:	e8 d5 0c 00 00       	call   801a1a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d45:	a1 80 50 80 00       	mov    0x805080,%eax
  800d4a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d50:	a1 84 50 80 00       	mov    0x805084,%eax
  800d55:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d5b:	83 c4 10             	add    $0x10,%esp
  800d5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	8b 52 0c             	mov    0xc(%edx),%edx
  800d77:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d7d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d82:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d87:	0f 47 c2             	cmova  %edx,%eax
  800d8a:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800d8f:	50                   	push   %eax
  800d90:	ff 75 0c             	pushl  0xc(%ebp)
  800d93:	68 08 50 80 00       	push   $0x805008
  800d98:	e8 0f 0e 00 00       	call   801bac <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800d9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800da2:	b8 04 00 00 00       	mov    $0x4,%eax
  800da7:	e8 cc fe ff ff       	call   800c78 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	56                   	push   %esi
  800db2:	53                   	push   %ebx
  800db3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	8b 40 0c             	mov    0xc(%eax),%eax
  800dbc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800dc1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800dc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcc:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd1:	e8 a2 fe ff ff       	call   800c78 <fsipc>
  800dd6:	89 c3                	mov    %eax,%ebx
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	78 4b                	js     800e27 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ddc:	39 c6                	cmp    %eax,%esi
  800dde:	73 16                	jae    800df6 <devfile_read+0x48>
  800de0:	68 20 23 80 00       	push   $0x802320
  800de5:	68 27 23 80 00       	push   $0x802327
  800dea:	6a 7c                	push   $0x7c
  800dec:	68 3c 23 80 00       	push   $0x80233c
  800df1:	e8 c6 05 00 00       	call   8013bc <_panic>
	assert(r <= PGSIZE);
  800df6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800dfb:	7e 16                	jle    800e13 <devfile_read+0x65>
  800dfd:	68 47 23 80 00       	push   $0x802347
  800e02:	68 27 23 80 00       	push   $0x802327
  800e07:	6a 7d                	push   $0x7d
  800e09:	68 3c 23 80 00       	push   $0x80233c
  800e0e:	e8 a9 05 00 00       	call   8013bc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	50                   	push   %eax
  800e17:	68 00 50 80 00       	push   $0x805000
  800e1c:	ff 75 0c             	pushl  0xc(%ebp)
  800e1f:	e8 88 0d 00 00       	call   801bac <memmove>
	return r;
  800e24:	83 c4 10             	add    $0x10,%esp
}
  800e27:	89 d8                	mov    %ebx,%eax
  800e29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5d                   	pop    %ebp
  800e2f:	c3                   	ret    

00800e30 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e30:	55                   	push   %ebp
  800e31:	89 e5                	mov    %esp,%ebp
  800e33:	53                   	push   %ebx
  800e34:	83 ec 20             	sub    $0x20,%esp
  800e37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e3a:	53                   	push   %ebx
  800e3b:	e8 a1 0b 00 00       	call   8019e1 <strlen>
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e48:	7f 67                	jg     800eb1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e4a:	83 ec 0c             	sub    $0xc,%esp
  800e4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e50:	50                   	push   %eax
  800e51:	e8 9a f8 ff ff       	call   8006f0 <fd_alloc>
  800e56:	83 c4 10             	add    $0x10,%esp
		return r;
  800e59:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	78 57                	js     800eb6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e5f:	83 ec 08             	sub    $0x8,%esp
  800e62:	53                   	push   %ebx
  800e63:	68 00 50 80 00       	push   $0x805000
  800e68:	e8 ad 0b 00 00       	call   801a1a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e70:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e75:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e78:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7d:	e8 f6 fd ff ff       	call   800c78 <fsipc>
  800e82:	89 c3                	mov    %eax,%ebx
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	85 c0                	test   %eax,%eax
  800e89:	79 14                	jns    800e9f <open+0x6f>
		fd_close(fd, 0);
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	6a 00                	push   $0x0
  800e90:	ff 75 f4             	pushl  -0xc(%ebp)
  800e93:	e8 50 f9 ff ff       	call   8007e8 <fd_close>
		return r;
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	89 da                	mov    %ebx,%edx
  800e9d:	eb 17                	jmp    800eb6 <open+0x86>
	}

	return fd2num(fd);
  800e9f:	83 ec 0c             	sub    $0xc,%esp
  800ea2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea5:	e8 1f f8 ff ff       	call   8006c9 <fd2num>
  800eaa:	89 c2                	mov    %eax,%edx
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	eb 05                	jmp    800eb6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800eb1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800eb6:	89 d0                	mov    %edx,%eax
  800eb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ec3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ecd:	e8 a6 fd ff ff       	call   800c78 <fsipc>
}
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	ff 75 08             	pushl  0x8(%ebp)
  800ee2:	e8 f2 f7 ff ff       	call   8006d9 <fd2data>
  800ee7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ee9:	83 c4 08             	add    $0x8,%esp
  800eec:	68 53 23 80 00       	push   $0x802353
  800ef1:	53                   	push   %ebx
  800ef2:	e8 23 0b 00 00       	call   801a1a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ef7:	8b 46 04             	mov    0x4(%esi),%eax
  800efa:	2b 06                	sub    (%esi),%eax
  800efc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f02:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f09:	00 00 00 
	stat->st_dev = &devpipe;
  800f0c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f13:	30 80 00 
	return 0;
}
  800f16:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1e:	5b                   	pop    %ebx
  800f1f:	5e                   	pop    %esi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    

00800f22 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	53                   	push   %ebx
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f2c:	53                   	push   %ebx
  800f2d:	6a 00                	push   $0x0
  800f2f:	e8 f5 f2 ff ff       	call   800229 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f34:	89 1c 24             	mov    %ebx,(%esp)
  800f37:	e8 9d f7 ff ff       	call   8006d9 <fd2data>
  800f3c:	83 c4 08             	add    $0x8,%esp
  800f3f:	50                   	push   %eax
  800f40:	6a 00                	push   $0x0
  800f42:	e8 e2 f2 ff ff       	call   800229 <sys_page_unmap>
}
  800f47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	57                   	push   %edi
  800f50:	56                   	push   %esi
  800f51:	53                   	push   %ebx
  800f52:	83 ec 1c             	sub    $0x1c,%esp
  800f55:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f58:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f5a:	a1 04 40 80 00       	mov    0x804004,%eax
  800f5f:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f65:	83 ec 0c             	sub    $0xc,%esp
  800f68:	ff 75 e0             	pushl  -0x20(%ebp)
  800f6b:	e8 9f 0f 00 00       	call   801f0f <pageref>
  800f70:	89 c3                	mov    %eax,%ebx
  800f72:	89 3c 24             	mov    %edi,(%esp)
  800f75:	e8 95 0f 00 00       	call   801f0f <pageref>
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	39 c3                	cmp    %eax,%ebx
  800f7f:	0f 94 c1             	sete   %cl
  800f82:	0f b6 c9             	movzbl %cl,%ecx
  800f85:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f88:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f8e:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  800f94:	39 ce                	cmp    %ecx,%esi
  800f96:	74 1e                	je     800fb6 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800f98:	39 c3                	cmp    %eax,%ebx
  800f9a:	75 be                	jne    800f5a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f9c:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  800fa2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa5:	50                   	push   %eax
  800fa6:	56                   	push   %esi
  800fa7:	68 5a 23 80 00       	push   $0x80235a
  800fac:	e8 e4 04 00 00       	call   801495 <cprintf>
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	eb a4                	jmp    800f5a <_pipeisclosed+0xe>
	}
}
  800fb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbc:	5b                   	pop    %ebx
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	57                   	push   %edi
  800fc5:	56                   	push   %esi
  800fc6:	53                   	push   %ebx
  800fc7:	83 ec 28             	sub    $0x28,%esp
  800fca:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fcd:	56                   	push   %esi
  800fce:	e8 06 f7 ff ff       	call   8006d9 <fd2data>
  800fd3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	bf 00 00 00 00       	mov    $0x0,%edi
  800fdd:	eb 4b                	jmp    80102a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fdf:	89 da                	mov    %ebx,%edx
  800fe1:	89 f0                	mov    %esi,%eax
  800fe3:	e8 64 ff ff ff       	call   800f4c <_pipeisclosed>
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	75 48                	jne    801034 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fec:	e8 94 f1 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ff1:	8b 43 04             	mov    0x4(%ebx),%eax
  800ff4:	8b 0b                	mov    (%ebx),%ecx
  800ff6:	8d 51 20             	lea    0x20(%ecx),%edx
  800ff9:	39 d0                	cmp    %edx,%eax
  800ffb:	73 e2                	jae    800fdf <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ffd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801000:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801004:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801007:	89 c2                	mov    %eax,%edx
  801009:	c1 fa 1f             	sar    $0x1f,%edx
  80100c:	89 d1                	mov    %edx,%ecx
  80100e:	c1 e9 1b             	shr    $0x1b,%ecx
  801011:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801014:	83 e2 1f             	and    $0x1f,%edx
  801017:	29 ca                	sub    %ecx,%edx
  801019:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80101d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801021:	83 c0 01             	add    $0x1,%eax
  801024:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801027:	83 c7 01             	add    $0x1,%edi
  80102a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80102d:	75 c2                	jne    800ff1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80102f:	8b 45 10             	mov    0x10(%ebp),%eax
  801032:	eb 05                	jmp    801039 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801034:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801039:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	57                   	push   %edi
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 18             	sub    $0x18,%esp
  80104a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80104d:	57                   	push   %edi
  80104e:	e8 86 f6 ff ff       	call   8006d9 <fd2data>
  801053:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	bb 00 00 00 00       	mov    $0x0,%ebx
  80105d:	eb 3d                	jmp    80109c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80105f:	85 db                	test   %ebx,%ebx
  801061:	74 04                	je     801067 <devpipe_read+0x26>
				return i;
  801063:	89 d8                	mov    %ebx,%eax
  801065:	eb 44                	jmp    8010ab <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801067:	89 f2                	mov    %esi,%edx
  801069:	89 f8                	mov    %edi,%eax
  80106b:	e8 dc fe ff ff       	call   800f4c <_pipeisclosed>
  801070:	85 c0                	test   %eax,%eax
  801072:	75 32                	jne    8010a6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801074:	e8 0c f1 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801079:	8b 06                	mov    (%esi),%eax
  80107b:	3b 46 04             	cmp    0x4(%esi),%eax
  80107e:	74 df                	je     80105f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801080:	99                   	cltd   
  801081:	c1 ea 1b             	shr    $0x1b,%edx
  801084:	01 d0                	add    %edx,%eax
  801086:	83 e0 1f             	and    $0x1f,%eax
  801089:	29 d0                	sub    %edx,%eax
  80108b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801090:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801093:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801096:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801099:	83 c3 01             	add    $0x1,%ebx
  80109c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80109f:	75 d8                	jne    801079 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010a1:	8b 45 10             	mov    0x10(%ebp),%eax
  8010a4:	eb 05                	jmp    8010ab <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010a6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ae:	5b                   	pop    %ebx
  8010af:	5e                   	pop    %esi
  8010b0:	5f                   	pop    %edi
  8010b1:	5d                   	pop    %ebp
  8010b2:	c3                   	ret    

008010b3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	56                   	push   %esi
  8010b7:	53                   	push   %ebx
  8010b8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010be:	50                   	push   %eax
  8010bf:	e8 2c f6 ff ff       	call   8006f0 <fd_alloc>
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	89 c2                	mov    %eax,%edx
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	0f 88 2c 01 00 00    	js     8011fd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010d1:	83 ec 04             	sub    $0x4,%esp
  8010d4:	68 07 04 00 00       	push   $0x407
  8010d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8010dc:	6a 00                	push   $0x0
  8010de:	e8 c1 f0 ff ff       	call   8001a4 <sys_page_alloc>
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	89 c2                	mov    %eax,%edx
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	0f 88 0d 01 00 00    	js     8011fd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010f0:	83 ec 0c             	sub    $0xc,%esp
  8010f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f6:	50                   	push   %eax
  8010f7:	e8 f4 f5 ff ff       	call   8006f0 <fd_alloc>
  8010fc:	89 c3                	mov    %eax,%ebx
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	0f 88 e2 00 00 00    	js     8011eb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801109:	83 ec 04             	sub    $0x4,%esp
  80110c:	68 07 04 00 00       	push   $0x407
  801111:	ff 75 f0             	pushl  -0x10(%ebp)
  801114:	6a 00                	push   $0x0
  801116:	e8 89 f0 ff ff       	call   8001a4 <sys_page_alloc>
  80111b:	89 c3                	mov    %eax,%ebx
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	0f 88 c3 00 00 00    	js     8011eb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	ff 75 f4             	pushl  -0xc(%ebp)
  80112e:	e8 a6 f5 ff ff       	call   8006d9 <fd2data>
  801133:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801135:	83 c4 0c             	add    $0xc,%esp
  801138:	68 07 04 00 00       	push   $0x407
  80113d:	50                   	push   %eax
  80113e:	6a 00                	push   $0x0
  801140:	e8 5f f0 ff ff       	call   8001a4 <sys_page_alloc>
  801145:	89 c3                	mov    %eax,%ebx
  801147:	83 c4 10             	add    $0x10,%esp
  80114a:	85 c0                	test   %eax,%eax
  80114c:	0f 88 89 00 00 00    	js     8011db <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801152:	83 ec 0c             	sub    $0xc,%esp
  801155:	ff 75 f0             	pushl  -0x10(%ebp)
  801158:	e8 7c f5 ff ff       	call   8006d9 <fd2data>
  80115d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801164:	50                   	push   %eax
  801165:	6a 00                	push   $0x0
  801167:	56                   	push   %esi
  801168:	6a 00                	push   $0x0
  80116a:	e8 78 f0 ff ff       	call   8001e7 <sys_page_map>
  80116f:	89 c3                	mov    %eax,%ebx
  801171:	83 c4 20             	add    $0x20,%esp
  801174:	85 c0                	test   %eax,%eax
  801176:	78 55                	js     8011cd <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801178:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801181:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801183:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801186:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80118d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801193:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801196:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801198:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8011a8:	e8 1c f5 ff ff       	call   8006c9 <fd2num>
  8011ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011b2:	83 c4 04             	add    $0x4,%esp
  8011b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8011b8:	e8 0c f5 ff ff       	call   8006c9 <fd2num>
  8011bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c0:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cb:	eb 30                	jmp    8011fd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011cd:	83 ec 08             	sub    $0x8,%esp
  8011d0:	56                   	push   %esi
  8011d1:	6a 00                	push   $0x0
  8011d3:	e8 51 f0 ff ff       	call   800229 <sys_page_unmap>
  8011d8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	ff 75 f0             	pushl  -0x10(%ebp)
  8011e1:	6a 00                	push   $0x0
  8011e3:	e8 41 f0 ff ff       	call   800229 <sys_page_unmap>
  8011e8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011eb:	83 ec 08             	sub    $0x8,%esp
  8011ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f1:	6a 00                	push   $0x0
  8011f3:	e8 31 f0 ff ff       	call   800229 <sys_page_unmap>
  8011f8:	83 c4 10             	add    $0x10,%esp
  8011fb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011fd:	89 d0                	mov    %edx,%eax
  8011ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80120c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	ff 75 08             	pushl  0x8(%ebp)
  801213:	e8 27 f5 ff ff       	call   80073f <fd_lookup>
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	78 18                	js     801237 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	ff 75 f4             	pushl  -0xc(%ebp)
  801225:	e8 af f4 ff ff       	call   8006d9 <fd2data>
	return _pipeisclosed(fd, p);
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122f:	e8 18 fd ff ff       	call   800f4c <_pipeisclosed>
  801234:	83 c4 10             	add    $0x10,%esp
}
  801237:	c9                   	leave  
  801238:	c3                   	ret    

00801239 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80123c:	b8 00 00 00 00       	mov    $0x0,%eax
  801241:	5d                   	pop    %ebp
  801242:	c3                   	ret    

00801243 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801249:	68 72 23 80 00       	push   $0x802372
  80124e:	ff 75 0c             	pushl  0xc(%ebp)
  801251:	e8 c4 07 00 00       	call   801a1a <strcpy>
	return 0;
}
  801256:	b8 00 00 00 00       	mov    $0x0,%eax
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	57                   	push   %edi
  801261:	56                   	push   %esi
  801262:	53                   	push   %ebx
  801263:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801269:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80126e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801274:	eb 2d                	jmp    8012a3 <devcons_write+0x46>
		m = n - tot;
  801276:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801279:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80127b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80127e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801283:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801286:	83 ec 04             	sub    $0x4,%esp
  801289:	53                   	push   %ebx
  80128a:	03 45 0c             	add    0xc(%ebp),%eax
  80128d:	50                   	push   %eax
  80128e:	57                   	push   %edi
  80128f:	e8 18 09 00 00       	call   801bac <memmove>
		sys_cputs(buf, m);
  801294:	83 c4 08             	add    $0x8,%esp
  801297:	53                   	push   %ebx
  801298:	57                   	push   %edi
  801299:	e8 4a ee ff ff       	call   8000e8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80129e:	01 de                	add    %ebx,%esi
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	89 f0                	mov    %esi,%eax
  8012a5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012a8:	72 cc                	jb     801276 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5f                   	pop    %edi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	83 ec 08             	sub    $0x8,%esp
  8012b8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012c1:	74 2a                	je     8012ed <devcons_read+0x3b>
  8012c3:	eb 05                	jmp    8012ca <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012c5:	e8 bb ee ff ff       	call   800185 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012ca:	e8 37 ee ff ff       	call   800106 <sys_cgetc>
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	74 f2                	je     8012c5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 16                	js     8012ed <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012d7:	83 f8 04             	cmp    $0x4,%eax
  8012da:	74 0c                	je     8012e8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012df:	88 02                	mov    %al,(%edx)
	return 1;
  8012e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012e6:	eb 05                	jmp    8012ed <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012e8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012ed:	c9                   	leave  
  8012ee:	c3                   	ret    

008012ef <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012fb:	6a 01                	push   $0x1
  8012fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	e8 e2 ed ff ff       	call   8000e8 <sys_cputs>
}
  801306:	83 c4 10             	add    $0x10,%esp
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <getchar>:

int
getchar(void)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801311:	6a 01                	push   $0x1
  801313:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801316:	50                   	push   %eax
  801317:	6a 00                	push   $0x0
  801319:	e8 87 f6 ff ff       	call   8009a5 <read>
	if (r < 0)
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	85 c0                	test   %eax,%eax
  801323:	78 0f                	js     801334 <getchar+0x29>
		return r;
	if (r < 1)
  801325:	85 c0                	test   %eax,%eax
  801327:	7e 06                	jle    80132f <getchar+0x24>
		return -E_EOF;
	return c;
  801329:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80132d:	eb 05                	jmp    801334 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80132f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	ff 75 08             	pushl  0x8(%ebp)
  801343:	e8 f7 f3 ff ff       	call   80073f <fd_lookup>
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 11                	js     801360 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801352:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801358:	39 10                	cmp    %edx,(%eax)
  80135a:	0f 94 c0             	sete   %al
  80135d:	0f b6 c0             	movzbl %al,%eax
}
  801360:	c9                   	leave  
  801361:	c3                   	ret    

00801362 <opencons>:

int
opencons(void)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801368:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136b:	50                   	push   %eax
  80136c:	e8 7f f3 ff ff       	call   8006f0 <fd_alloc>
  801371:	83 c4 10             	add    $0x10,%esp
		return r;
  801374:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801376:	85 c0                	test   %eax,%eax
  801378:	78 3e                	js     8013b8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80137a:	83 ec 04             	sub    $0x4,%esp
  80137d:	68 07 04 00 00       	push   $0x407
  801382:	ff 75 f4             	pushl  -0xc(%ebp)
  801385:	6a 00                	push   $0x0
  801387:	e8 18 ee ff ff       	call   8001a4 <sys_page_alloc>
  80138c:	83 c4 10             	add    $0x10,%esp
		return r;
  80138f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801391:	85 c0                	test   %eax,%eax
  801393:	78 23                	js     8013b8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801395:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013aa:	83 ec 0c             	sub    $0xc,%esp
  8013ad:	50                   	push   %eax
  8013ae:	e8 16 f3 ff ff       	call   8006c9 <fd2num>
  8013b3:	89 c2                	mov    %eax,%edx
  8013b5:	83 c4 10             	add    $0x10,%esp
}
  8013b8:	89 d0                	mov    %edx,%eax
  8013ba:	c9                   	leave  
  8013bb:	c3                   	ret    

008013bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	56                   	push   %esi
  8013c0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013c1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013c4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013ca:	e8 97 ed ff ff       	call   800166 <sys_getenvid>
  8013cf:	83 ec 0c             	sub    $0xc,%esp
  8013d2:	ff 75 0c             	pushl  0xc(%ebp)
  8013d5:	ff 75 08             	pushl  0x8(%ebp)
  8013d8:	56                   	push   %esi
  8013d9:	50                   	push   %eax
  8013da:	68 80 23 80 00       	push   $0x802380
  8013df:	e8 b1 00 00 00       	call   801495 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013e4:	83 c4 18             	add    $0x18,%esp
  8013e7:	53                   	push   %ebx
  8013e8:	ff 75 10             	pushl  0x10(%ebp)
  8013eb:	e8 54 00 00 00       	call   801444 <vcprintf>
	cprintf("\n");
  8013f0:	c7 04 24 6b 23 80 00 	movl   $0x80236b,(%esp)
  8013f7:	e8 99 00 00 00       	call   801495 <cprintf>
  8013fc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013ff:	cc                   	int3   
  801400:	eb fd                	jmp    8013ff <_panic+0x43>

00801402 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
  801405:	53                   	push   %ebx
  801406:	83 ec 04             	sub    $0x4,%esp
  801409:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80140c:	8b 13                	mov    (%ebx),%edx
  80140e:	8d 42 01             	lea    0x1(%edx),%eax
  801411:	89 03                	mov    %eax,(%ebx)
  801413:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801416:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80141a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80141f:	75 1a                	jne    80143b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	68 ff 00 00 00       	push   $0xff
  801429:	8d 43 08             	lea    0x8(%ebx),%eax
  80142c:	50                   	push   %eax
  80142d:	e8 b6 ec ff ff       	call   8000e8 <sys_cputs>
		b->idx = 0;
  801432:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801438:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80143b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80143f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801442:	c9                   	leave  
  801443:	c3                   	ret    

00801444 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80144d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801454:	00 00 00 
	b.cnt = 0;
  801457:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80145e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801461:	ff 75 0c             	pushl  0xc(%ebp)
  801464:	ff 75 08             	pushl  0x8(%ebp)
  801467:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80146d:	50                   	push   %eax
  80146e:	68 02 14 80 00       	push   $0x801402
  801473:	e8 54 01 00 00       	call   8015cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801478:	83 c4 08             	add    $0x8,%esp
  80147b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801481:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	e8 5b ec ff ff       	call   8000e8 <sys_cputs>

	return b.cnt;
}
  80148d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801493:	c9                   	leave  
  801494:	c3                   	ret    

00801495 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80149b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80149e:	50                   	push   %eax
  80149f:	ff 75 08             	pushl  0x8(%ebp)
  8014a2:	e8 9d ff ff ff       	call   801444 <vcprintf>
	va_end(ap);

	return cnt;
}
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	57                   	push   %edi
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 1c             	sub    $0x1c,%esp
  8014b2:	89 c7                	mov    %eax,%edi
  8014b4:	89 d6                	mov    %edx,%esi
  8014b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ca:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014cd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014d0:	39 d3                	cmp    %edx,%ebx
  8014d2:	72 05                	jb     8014d9 <printnum+0x30>
  8014d4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014d7:	77 45                	ja     80151e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	ff 75 18             	pushl  0x18(%ebp)
  8014df:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014e5:	53                   	push   %ebx
  8014e6:	ff 75 10             	pushl  0x10(%ebp)
  8014e9:	83 ec 08             	sub    $0x8,%esp
  8014ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8014f2:	ff 75 dc             	pushl  -0x24(%ebp)
  8014f5:	ff 75 d8             	pushl  -0x28(%ebp)
  8014f8:	e8 53 0a 00 00       	call   801f50 <__udivdi3>
  8014fd:	83 c4 18             	add    $0x18,%esp
  801500:	52                   	push   %edx
  801501:	50                   	push   %eax
  801502:	89 f2                	mov    %esi,%edx
  801504:	89 f8                	mov    %edi,%eax
  801506:	e8 9e ff ff ff       	call   8014a9 <printnum>
  80150b:	83 c4 20             	add    $0x20,%esp
  80150e:	eb 18                	jmp    801528 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	56                   	push   %esi
  801514:	ff 75 18             	pushl  0x18(%ebp)
  801517:	ff d7                	call   *%edi
  801519:	83 c4 10             	add    $0x10,%esp
  80151c:	eb 03                	jmp    801521 <printnum+0x78>
  80151e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801521:	83 eb 01             	sub    $0x1,%ebx
  801524:	85 db                	test   %ebx,%ebx
  801526:	7f e8                	jg     801510 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801528:	83 ec 08             	sub    $0x8,%esp
  80152b:	56                   	push   %esi
  80152c:	83 ec 04             	sub    $0x4,%esp
  80152f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801532:	ff 75 e0             	pushl  -0x20(%ebp)
  801535:	ff 75 dc             	pushl  -0x24(%ebp)
  801538:	ff 75 d8             	pushl  -0x28(%ebp)
  80153b:	e8 40 0b 00 00       	call   802080 <__umoddi3>
  801540:	83 c4 14             	add    $0x14,%esp
  801543:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  80154a:	50                   	push   %eax
  80154b:	ff d7                	call   *%edi
}
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801553:	5b                   	pop    %ebx
  801554:	5e                   	pop    %esi
  801555:	5f                   	pop    %edi
  801556:	5d                   	pop    %ebp
  801557:	c3                   	ret    

00801558 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80155b:	83 fa 01             	cmp    $0x1,%edx
  80155e:	7e 0e                	jle    80156e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801560:	8b 10                	mov    (%eax),%edx
  801562:	8d 4a 08             	lea    0x8(%edx),%ecx
  801565:	89 08                	mov    %ecx,(%eax)
  801567:	8b 02                	mov    (%edx),%eax
  801569:	8b 52 04             	mov    0x4(%edx),%edx
  80156c:	eb 22                	jmp    801590 <getuint+0x38>
	else if (lflag)
  80156e:	85 d2                	test   %edx,%edx
  801570:	74 10                	je     801582 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801572:	8b 10                	mov    (%eax),%edx
  801574:	8d 4a 04             	lea    0x4(%edx),%ecx
  801577:	89 08                	mov    %ecx,(%eax)
  801579:	8b 02                	mov    (%edx),%eax
  80157b:	ba 00 00 00 00       	mov    $0x0,%edx
  801580:	eb 0e                	jmp    801590 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801582:	8b 10                	mov    (%eax),%edx
  801584:	8d 4a 04             	lea    0x4(%edx),%ecx
  801587:	89 08                	mov    %ecx,(%eax)
  801589:	8b 02                	mov    (%edx),%eax
  80158b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801598:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80159c:	8b 10                	mov    (%eax),%edx
  80159e:	3b 50 04             	cmp    0x4(%eax),%edx
  8015a1:	73 0a                	jae    8015ad <sprintputch+0x1b>
		*b->buf++ = ch;
  8015a3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015a6:	89 08                	mov    %ecx,(%eax)
  8015a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ab:	88 02                	mov    %al,(%edx)
}
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    

008015af <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015b5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015b8:	50                   	push   %eax
  8015b9:	ff 75 10             	pushl  0x10(%ebp)
  8015bc:	ff 75 0c             	pushl  0xc(%ebp)
  8015bf:	ff 75 08             	pushl  0x8(%ebp)
  8015c2:	e8 05 00 00 00       	call   8015cc <vprintfmt>
	va_end(ap);
}
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	57                   	push   %edi
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 2c             	sub    $0x2c,%esp
  8015d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8015d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015db:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015de:	eb 12                	jmp    8015f2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	0f 84 89 03 00 00    	je     801971 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	53                   	push   %ebx
  8015ec:	50                   	push   %eax
  8015ed:	ff d6                	call   *%esi
  8015ef:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015f2:	83 c7 01             	add    $0x1,%edi
  8015f5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015f9:	83 f8 25             	cmp    $0x25,%eax
  8015fc:	75 e2                	jne    8015e0 <vprintfmt+0x14>
  8015fe:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801602:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801609:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801610:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801617:	ba 00 00 00 00       	mov    $0x0,%edx
  80161c:	eb 07                	jmp    801625 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801621:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801625:	8d 47 01             	lea    0x1(%edi),%eax
  801628:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80162b:	0f b6 07             	movzbl (%edi),%eax
  80162e:	0f b6 c8             	movzbl %al,%ecx
  801631:	83 e8 23             	sub    $0x23,%eax
  801634:	3c 55                	cmp    $0x55,%al
  801636:	0f 87 1a 03 00 00    	ja     801956 <vprintfmt+0x38a>
  80163c:	0f b6 c0             	movzbl %al,%eax
  80163f:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  801646:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801649:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80164d:	eb d6                	jmp    801625 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801652:	b8 00 00 00 00       	mov    $0x0,%eax
  801657:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80165a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80165d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801661:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801664:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801667:	83 fa 09             	cmp    $0x9,%edx
  80166a:	77 39                	ja     8016a5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80166c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80166f:	eb e9                	jmp    80165a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801671:	8b 45 14             	mov    0x14(%ebp),%eax
  801674:	8d 48 04             	lea    0x4(%eax),%ecx
  801677:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80167a:	8b 00                	mov    (%eax),%eax
  80167c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80167f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801682:	eb 27                	jmp    8016ab <vprintfmt+0xdf>
  801684:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801687:	85 c0                	test   %eax,%eax
  801689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80168e:	0f 49 c8             	cmovns %eax,%ecx
  801691:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801697:	eb 8c                	jmp    801625 <vprintfmt+0x59>
  801699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80169c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016a3:	eb 80                	jmp    801625 <vprintfmt+0x59>
  8016a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016a8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016af:	0f 89 70 ff ff ff    	jns    801625 <vprintfmt+0x59>
				width = precision, precision = -1;
  8016b5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016bb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016c2:	e9 5e ff ff ff       	jmp    801625 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016c7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016cd:	e9 53 ff ff ff       	jmp    801625 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d5:	8d 50 04             	lea    0x4(%eax),%edx
  8016d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8016db:	83 ec 08             	sub    $0x8,%esp
  8016de:	53                   	push   %ebx
  8016df:	ff 30                	pushl  (%eax)
  8016e1:	ff d6                	call   *%esi
			break;
  8016e3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016e9:	e9 04 ff ff ff       	jmp    8015f2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f1:	8d 50 04             	lea    0x4(%eax),%edx
  8016f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8016f7:	8b 00                	mov    (%eax),%eax
  8016f9:	99                   	cltd   
  8016fa:	31 d0                	xor    %edx,%eax
  8016fc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016fe:	83 f8 0f             	cmp    $0xf,%eax
  801701:	7f 0b                	jg     80170e <vprintfmt+0x142>
  801703:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  80170a:	85 d2                	test   %edx,%edx
  80170c:	75 18                	jne    801726 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80170e:	50                   	push   %eax
  80170f:	68 bb 23 80 00       	push   $0x8023bb
  801714:	53                   	push   %ebx
  801715:	56                   	push   %esi
  801716:	e8 94 fe ff ff       	call   8015af <printfmt>
  80171b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801721:	e9 cc fe ff ff       	jmp    8015f2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801726:	52                   	push   %edx
  801727:	68 39 23 80 00       	push   $0x802339
  80172c:	53                   	push   %ebx
  80172d:	56                   	push   %esi
  80172e:	e8 7c fe ff ff       	call   8015af <printfmt>
  801733:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801736:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801739:	e9 b4 fe ff ff       	jmp    8015f2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80173e:	8b 45 14             	mov    0x14(%ebp),%eax
  801741:	8d 50 04             	lea    0x4(%eax),%edx
  801744:	89 55 14             	mov    %edx,0x14(%ebp)
  801747:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801749:	85 ff                	test   %edi,%edi
  80174b:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  801750:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801753:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801757:	0f 8e 94 00 00 00    	jle    8017f1 <vprintfmt+0x225>
  80175d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801761:	0f 84 98 00 00 00    	je     8017ff <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	ff 75 d0             	pushl  -0x30(%ebp)
  80176d:	57                   	push   %edi
  80176e:	e8 86 02 00 00       	call   8019f9 <strnlen>
  801773:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801776:	29 c1                	sub    %eax,%ecx
  801778:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80177b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80177e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801782:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801785:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801788:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80178a:	eb 0f                	jmp    80179b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80178c:	83 ec 08             	sub    $0x8,%esp
  80178f:	53                   	push   %ebx
  801790:	ff 75 e0             	pushl  -0x20(%ebp)
  801793:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801795:	83 ef 01             	sub    $0x1,%edi
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	85 ff                	test   %edi,%edi
  80179d:	7f ed                	jg     80178c <vprintfmt+0x1c0>
  80179f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017a2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017a5:	85 c9                	test   %ecx,%ecx
  8017a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ac:	0f 49 c1             	cmovns %ecx,%eax
  8017af:	29 c1                	sub    %eax,%ecx
  8017b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8017b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017ba:	89 cb                	mov    %ecx,%ebx
  8017bc:	eb 4d                	jmp    80180b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017c2:	74 1b                	je     8017df <vprintfmt+0x213>
  8017c4:	0f be c0             	movsbl %al,%eax
  8017c7:	83 e8 20             	sub    $0x20,%eax
  8017ca:	83 f8 5e             	cmp    $0x5e,%eax
  8017cd:	76 10                	jbe    8017df <vprintfmt+0x213>
					putch('?', putdat);
  8017cf:	83 ec 08             	sub    $0x8,%esp
  8017d2:	ff 75 0c             	pushl  0xc(%ebp)
  8017d5:	6a 3f                	push   $0x3f
  8017d7:	ff 55 08             	call   *0x8(%ebp)
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	eb 0d                	jmp    8017ec <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017df:	83 ec 08             	sub    $0x8,%esp
  8017e2:	ff 75 0c             	pushl  0xc(%ebp)
  8017e5:	52                   	push   %edx
  8017e6:	ff 55 08             	call   *0x8(%ebp)
  8017e9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017ec:	83 eb 01             	sub    $0x1,%ebx
  8017ef:	eb 1a                	jmp    80180b <vprintfmt+0x23f>
  8017f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8017f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017fa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017fd:	eb 0c                	jmp    80180b <vprintfmt+0x23f>
  8017ff:	89 75 08             	mov    %esi,0x8(%ebp)
  801802:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801805:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801808:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80180b:	83 c7 01             	add    $0x1,%edi
  80180e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801812:	0f be d0             	movsbl %al,%edx
  801815:	85 d2                	test   %edx,%edx
  801817:	74 23                	je     80183c <vprintfmt+0x270>
  801819:	85 f6                	test   %esi,%esi
  80181b:	78 a1                	js     8017be <vprintfmt+0x1f2>
  80181d:	83 ee 01             	sub    $0x1,%esi
  801820:	79 9c                	jns    8017be <vprintfmt+0x1f2>
  801822:	89 df                	mov    %ebx,%edi
  801824:	8b 75 08             	mov    0x8(%ebp),%esi
  801827:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80182a:	eb 18                	jmp    801844 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	53                   	push   %ebx
  801830:	6a 20                	push   $0x20
  801832:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801834:	83 ef 01             	sub    $0x1,%edi
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	eb 08                	jmp    801844 <vprintfmt+0x278>
  80183c:	89 df                	mov    %ebx,%edi
  80183e:	8b 75 08             	mov    0x8(%ebp),%esi
  801841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801844:	85 ff                	test   %edi,%edi
  801846:	7f e4                	jg     80182c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801848:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80184b:	e9 a2 fd ff ff       	jmp    8015f2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801850:	83 fa 01             	cmp    $0x1,%edx
  801853:	7e 16                	jle    80186b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801855:	8b 45 14             	mov    0x14(%ebp),%eax
  801858:	8d 50 08             	lea    0x8(%eax),%edx
  80185b:	89 55 14             	mov    %edx,0x14(%ebp)
  80185e:	8b 50 04             	mov    0x4(%eax),%edx
  801861:	8b 00                	mov    (%eax),%eax
  801863:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801866:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801869:	eb 32                	jmp    80189d <vprintfmt+0x2d1>
	else if (lflag)
  80186b:	85 d2                	test   %edx,%edx
  80186d:	74 18                	je     801887 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80186f:	8b 45 14             	mov    0x14(%ebp),%eax
  801872:	8d 50 04             	lea    0x4(%eax),%edx
  801875:	89 55 14             	mov    %edx,0x14(%ebp)
  801878:	8b 00                	mov    (%eax),%eax
  80187a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80187d:	89 c1                	mov    %eax,%ecx
  80187f:	c1 f9 1f             	sar    $0x1f,%ecx
  801882:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801885:	eb 16                	jmp    80189d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801887:	8b 45 14             	mov    0x14(%ebp),%eax
  80188a:	8d 50 04             	lea    0x4(%eax),%edx
  80188d:	89 55 14             	mov    %edx,0x14(%ebp)
  801890:	8b 00                	mov    (%eax),%eax
  801892:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801895:	89 c1                	mov    %eax,%ecx
  801897:	c1 f9 1f             	sar    $0x1f,%ecx
  80189a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80189d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018a3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018ac:	79 74                	jns    801922 <vprintfmt+0x356>
				putch('-', putdat);
  8018ae:	83 ec 08             	sub    $0x8,%esp
  8018b1:	53                   	push   %ebx
  8018b2:	6a 2d                	push   $0x2d
  8018b4:	ff d6                	call   *%esi
				num = -(long long) num;
  8018b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018b9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018bc:	f7 d8                	neg    %eax
  8018be:	83 d2 00             	adc    $0x0,%edx
  8018c1:	f7 da                	neg    %edx
  8018c3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018cb:	eb 55                	jmp    801922 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018cd:	8d 45 14             	lea    0x14(%ebp),%eax
  8018d0:	e8 83 fc ff ff       	call   801558 <getuint>
			base = 10;
  8018d5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018da:	eb 46                	jmp    801922 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8018df:	e8 74 fc ff ff       	call   801558 <getuint>
			base = 8;
  8018e4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018e9:	eb 37                	jmp    801922 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018eb:	83 ec 08             	sub    $0x8,%esp
  8018ee:	53                   	push   %ebx
  8018ef:	6a 30                	push   $0x30
  8018f1:	ff d6                	call   *%esi
			putch('x', putdat);
  8018f3:	83 c4 08             	add    $0x8,%esp
  8018f6:	53                   	push   %ebx
  8018f7:	6a 78                	push   $0x78
  8018f9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fe:	8d 50 04             	lea    0x4(%eax),%edx
  801901:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801904:	8b 00                	mov    (%eax),%eax
  801906:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80190b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80190e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801913:	eb 0d                	jmp    801922 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801915:	8d 45 14             	lea    0x14(%ebp),%eax
  801918:	e8 3b fc ff ff       	call   801558 <getuint>
			base = 16;
  80191d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801929:	57                   	push   %edi
  80192a:	ff 75 e0             	pushl  -0x20(%ebp)
  80192d:	51                   	push   %ecx
  80192e:	52                   	push   %edx
  80192f:	50                   	push   %eax
  801930:	89 da                	mov    %ebx,%edx
  801932:	89 f0                	mov    %esi,%eax
  801934:	e8 70 fb ff ff       	call   8014a9 <printnum>
			break;
  801939:	83 c4 20             	add    $0x20,%esp
  80193c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80193f:	e9 ae fc ff ff       	jmp    8015f2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	53                   	push   %ebx
  801948:	51                   	push   %ecx
  801949:	ff d6                	call   *%esi
			break;
  80194b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80194e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801951:	e9 9c fc ff ff       	jmp    8015f2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801956:	83 ec 08             	sub    $0x8,%esp
  801959:	53                   	push   %ebx
  80195a:	6a 25                	push   $0x25
  80195c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	eb 03                	jmp    801966 <vprintfmt+0x39a>
  801963:	83 ef 01             	sub    $0x1,%edi
  801966:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80196a:	75 f7                	jne    801963 <vprintfmt+0x397>
  80196c:	e9 81 fc ff ff       	jmp    8015f2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801971:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801974:	5b                   	pop    %ebx
  801975:	5e                   	pop    %esi
  801976:	5f                   	pop    %edi
  801977:	5d                   	pop    %ebp
  801978:	c3                   	ret    

00801979 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	83 ec 18             	sub    $0x18,%esp
  80197f:	8b 45 08             	mov    0x8(%ebp),%eax
  801982:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801985:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801988:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80198c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80198f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801996:	85 c0                	test   %eax,%eax
  801998:	74 26                	je     8019c0 <vsnprintf+0x47>
  80199a:	85 d2                	test   %edx,%edx
  80199c:	7e 22                	jle    8019c0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80199e:	ff 75 14             	pushl  0x14(%ebp)
  8019a1:	ff 75 10             	pushl  0x10(%ebp)
  8019a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019a7:	50                   	push   %eax
  8019a8:	68 92 15 80 00       	push   $0x801592
  8019ad:	e8 1a fc ff ff       	call   8015cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019b5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	eb 05                	jmp    8019c5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019c5:	c9                   	leave  
  8019c6:	c3                   	ret    

008019c7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019cd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019d0:	50                   	push   %eax
  8019d1:	ff 75 10             	pushl  0x10(%ebp)
  8019d4:	ff 75 0c             	pushl  0xc(%ebp)
  8019d7:	ff 75 08             	pushl  0x8(%ebp)
  8019da:	e8 9a ff ff ff       	call   801979 <vsnprintf>
	va_end(ap);

	return rc;
}
  8019df:	c9                   	leave  
  8019e0:	c3                   	ret    

008019e1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ec:	eb 03                	jmp    8019f1 <strlen+0x10>
		n++;
  8019ee:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019f1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019f5:	75 f7                	jne    8019ee <strlen+0xd>
		n++;
	return n;
}
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ff:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a02:	ba 00 00 00 00       	mov    $0x0,%edx
  801a07:	eb 03                	jmp    801a0c <strnlen+0x13>
		n++;
  801a09:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a0c:	39 c2                	cmp    %eax,%edx
  801a0e:	74 08                	je     801a18 <strnlen+0x1f>
  801a10:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a14:	75 f3                	jne    801a09 <strnlen+0x10>
  801a16:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a18:	5d                   	pop    %ebp
  801a19:	c3                   	ret    

00801a1a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	53                   	push   %ebx
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a24:	89 c2                	mov    %eax,%edx
  801a26:	83 c2 01             	add    $0x1,%edx
  801a29:	83 c1 01             	add    $0x1,%ecx
  801a2c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a30:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a33:	84 db                	test   %bl,%bl
  801a35:	75 ef                	jne    801a26 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a37:	5b                   	pop    %ebx
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    

00801a3a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	53                   	push   %ebx
  801a3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a41:	53                   	push   %ebx
  801a42:	e8 9a ff ff ff       	call   8019e1 <strlen>
  801a47:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a4a:	ff 75 0c             	pushl  0xc(%ebp)
  801a4d:	01 d8                	add    %ebx,%eax
  801a4f:	50                   	push   %eax
  801a50:	e8 c5 ff ff ff       	call   801a1a <strcpy>
	return dst;
}
  801a55:	89 d8                	mov    %ebx,%eax
  801a57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5a:	c9                   	leave  
  801a5b:	c3                   	ret    

00801a5c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	8b 75 08             	mov    0x8(%ebp),%esi
  801a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a67:	89 f3                	mov    %esi,%ebx
  801a69:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a6c:	89 f2                	mov    %esi,%edx
  801a6e:	eb 0f                	jmp    801a7f <strncpy+0x23>
		*dst++ = *src;
  801a70:	83 c2 01             	add    $0x1,%edx
  801a73:	0f b6 01             	movzbl (%ecx),%eax
  801a76:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a79:	80 39 01             	cmpb   $0x1,(%ecx)
  801a7c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a7f:	39 da                	cmp    %ebx,%edx
  801a81:	75 ed                	jne    801a70 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a83:	89 f0                	mov    %esi,%eax
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a94:	8b 55 10             	mov    0x10(%ebp),%edx
  801a97:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a99:	85 d2                	test   %edx,%edx
  801a9b:	74 21                	je     801abe <strlcpy+0x35>
  801a9d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801aa1:	89 f2                	mov    %esi,%edx
  801aa3:	eb 09                	jmp    801aae <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801aa5:	83 c2 01             	add    $0x1,%edx
  801aa8:	83 c1 01             	add    $0x1,%ecx
  801aab:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801aae:	39 c2                	cmp    %eax,%edx
  801ab0:	74 09                	je     801abb <strlcpy+0x32>
  801ab2:	0f b6 19             	movzbl (%ecx),%ebx
  801ab5:	84 db                	test   %bl,%bl
  801ab7:	75 ec                	jne    801aa5 <strlcpy+0x1c>
  801ab9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801abb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801abe:	29 f0                	sub    %esi,%eax
}
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    

00801ac4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801aca:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801acd:	eb 06                	jmp    801ad5 <strcmp+0x11>
		p++, q++;
  801acf:	83 c1 01             	add    $0x1,%ecx
  801ad2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ad5:	0f b6 01             	movzbl (%ecx),%eax
  801ad8:	84 c0                	test   %al,%al
  801ada:	74 04                	je     801ae0 <strcmp+0x1c>
  801adc:	3a 02                	cmp    (%edx),%al
  801ade:	74 ef                	je     801acf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ae0:	0f b6 c0             	movzbl %al,%eax
  801ae3:	0f b6 12             	movzbl (%edx),%edx
  801ae6:	29 d0                	sub    %edx,%eax
}
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	53                   	push   %ebx
  801aee:	8b 45 08             	mov    0x8(%ebp),%eax
  801af1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801af4:	89 c3                	mov    %eax,%ebx
  801af6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801af9:	eb 06                	jmp    801b01 <strncmp+0x17>
		n--, p++, q++;
  801afb:	83 c0 01             	add    $0x1,%eax
  801afe:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b01:	39 d8                	cmp    %ebx,%eax
  801b03:	74 15                	je     801b1a <strncmp+0x30>
  801b05:	0f b6 08             	movzbl (%eax),%ecx
  801b08:	84 c9                	test   %cl,%cl
  801b0a:	74 04                	je     801b10 <strncmp+0x26>
  801b0c:	3a 0a                	cmp    (%edx),%cl
  801b0e:	74 eb                	je     801afb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b10:	0f b6 00             	movzbl (%eax),%eax
  801b13:	0f b6 12             	movzbl (%edx),%edx
  801b16:	29 d0                	sub    %edx,%eax
  801b18:	eb 05                	jmp    801b1f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b1a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b1f:	5b                   	pop    %ebx
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b2c:	eb 07                	jmp    801b35 <strchr+0x13>
		if (*s == c)
  801b2e:	38 ca                	cmp    %cl,%dl
  801b30:	74 0f                	je     801b41 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b32:	83 c0 01             	add    $0x1,%eax
  801b35:	0f b6 10             	movzbl (%eax),%edx
  801b38:	84 d2                	test   %dl,%dl
  801b3a:	75 f2                	jne    801b2e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	8b 45 08             	mov    0x8(%ebp),%eax
  801b49:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b4d:	eb 03                	jmp    801b52 <strfind+0xf>
  801b4f:	83 c0 01             	add    $0x1,%eax
  801b52:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b55:	38 ca                	cmp    %cl,%dl
  801b57:	74 04                	je     801b5d <strfind+0x1a>
  801b59:	84 d2                	test   %dl,%dl
  801b5b:	75 f2                	jne    801b4f <strfind+0xc>
			break;
	return (char *) s;
}
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	57                   	push   %edi
  801b63:	56                   	push   %esi
  801b64:	53                   	push   %ebx
  801b65:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b68:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b6b:	85 c9                	test   %ecx,%ecx
  801b6d:	74 36                	je     801ba5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b75:	75 28                	jne    801b9f <memset+0x40>
  801b77:	f6 c1 03             	test   $0x3,%cl
  801b7a:	75 23                	jne    801b9f <memset+0x40>
		c &= 0xFF;
  801b7c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b80:	89 d3                	mov    %edx,%ebx
  801b82:	c1 e3 08             	shl    $0x8,%ebx
  801b85:	89 d6                	mov    %edx,%esi
  801b87:	c1 e6 18             	shl    $0x18,%esi
  801b8a:	89 d0                	mov    %edx,%eax
  801b8c:	c1 e0 10             	shl    $0x10,%eax
  801b8f:	09 f0                	or     %esi,%eax
  801b91:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b93:	89 d8                	mov    %ebx,%eax
  801b95:	09 d0                	or     %edx,%eax
  801b97:	c1 e9 02             	shr    $0x2,%ecx
  801b9a:	fc                   	cld    
  801b9b:	f3 ab                	rep stos %eax,%es:(%edi)
  801b9d:	eb 06                	jmp    801ba5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba2:	fc                   	cld    
  801ba3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ba5:	89 f8                	mov    %edi,%eax
  801ba7:	5b                   	pop    %ebx
  801ba8:	5e                   	pop    %esi
  801ba9:	5f                   	pop    %edi
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    

00801bac <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	57                   	push   %edi
  801bb0:	56                   	push   %esi
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bb7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801bba:	39 c6                	cmp    %eax,%esi
  801bbc:	73 35                	jae    801bf3 <memmove+0x47>
  801bbe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bc1:	39 d0                	cmp    %edx,%eax
  801bc3:	73 2e                	jae    801bf3 <memmove+0x47>
		s += n;
		d += n;
  801bc5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bc8:	89 d6                	mov    %edx,%esi
  801bca:	09 fe                	or     %edi,%esi
  801bcc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bd2:	75 13                	jne    801be7 <memmove+0x3b>
  801bd4:	f6 c1 03             	test   $0x3,%cl
  801bd7:	75 0e                	jne    801be7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bd9:	83 ef 04             	sub    $0x4,%edi
  801bdc:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bdf:	c1 e9 02             	shr    $0x2,%ecx
  801be2:	fd                   	std    
  801be3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801be5:	eb 09                	jmp    801bf0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801be7:	83 ef 01             	sub    $0x1,%edi
  801bea:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bed:	fd                   	std    
  801bee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bf0:	fc                   	cld    
  801bf1:	eb 1d                	jmp    801c10 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bf3:	89 f2                	mov    %esi,%edx
  801bf5:	09 c2                	or     %eax,%edx
  801bf7:	f6 c2 03             	test   $0x3,%dl
  801bfa:	75 0f                	jne    801c0b <memmove+0x5f>
  801bfc:	f6 c1 03             	test   $0x3,%cl
  801bff:	75 0a                	jne    801c0b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c01:	c1 e9 02             	shr    $0x2,%ecx
  801c04:	89 c7                	mov    %eax,%edi
  801c06:	fc                   	cld    
  801c07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c09:	eb 05                	jmp    801c10 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c0b:	89 c7                	mov    %eax,%edi
  801c0d:	fc                   	cld    
  801c0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c10:	5e                   	pop    %esi
  801c11:	5f                   	pop    %edi
  801c12:	5d                   	pop    %ebp
  801c13:	c3                   	ret    

00801c14 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c17:	ff 75 10             	pushl  0x10(%ebp)
  801c1a:	ff 75 0c             	pushl  0xc(%ebp)
  801c1d:	ff 75 08             	pushl  0x8(%ebp)
  801c20:	e8 87 ff ff ff       	call   801bac <memmove>
}
  801c25:	c9                   	leave  
  801c26:	c3                   	ret    

00801c27 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	56                   	push   %esi
  801c2b:	53                   	push   %ebx
  801c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c32:	89 c6                	mov    %eax,%esi
  801c34:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c37:	eb 1a                	jmp    801c53 <memcmp+0x2c>
		if (*s1 != *s2)
  801c39:	0f b6 08             	movzbl (%eax),%ecx
  801c3c:	0f b6 1a             	movzbl (%edx),%ebx
  801c3f:	38 d9                	cmp    %bl,%cl
  801c41:	74 0a                	je     801c4d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c43:	0f b6 c1             	movzbl %cl,%eax
  801c46:	0f b6 db             	movzbl %bl,%ebx
  801c49:	29 d8                	sub    %ebx,%eax
  801c4b:	eb 0f                	jmp    801c5c <memcmp+0x35>
		s1++, s2++;
  801c4d:	83 c0 01             	add    $0x1,%eax
  801c50:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c53:	39 f0                	cmp    %esi,%eax
  801c55:	75 e2                	jne    801c39 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c57:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c5c:	5b                   	pop    %ebx
  801c5d:	5e                   	pop    %esi
  801c5e:	5d                   	pop    %ebp
  801c5f:	c3                   	ret    

00801c60 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	53                   	push   %ebx
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c67:	89 c1                	mov    %eax,%ecx
  801c69:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c6c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c70:	eb 0a                	jmp    801c7c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c72:	0f b6 10             	movzbl (%eax),%edx
  801c75:	39 da                	cmp    %ebx,%edx
  801c77:	74 07                	je     801c80 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c79:	83 c0 01             	add    $0x1,%eax
  801c7c:	39 c8                	cmp    %ecx,%eax
  801c7e:	72 f2                	jb     801c72 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c80:	5b                   	pop    %ebx
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	57                   	push   %edi
  801c87:	56                   	push   %esi
  801c88:	53                   	push   %ebx
  801c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c8f:	eb 03                	jmp    801c94 <strtol+0x11>
		s++;
  801c91:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c94:	0f b6 01             	movzbl (%ecx),%eax
  801c97:	3c 20                	cmp    $0x20,%al
  801c99:	74 f6                	je     801c91 <strtol+0xe>
  801c9b:	3c 09                	cmp    $0x9,%al
  801c9d:	74 f2                	je     801c91 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c9f:	3c 2b                	cmp    $0x2b,%al
  801ca1:	75 0a                	jne    801cad <strtol+0x2a>
		s++;
  801ca3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ca6:	bf 00 00 00 00       	mov    $0x0,%edi
  801cab:	eb 11                	jmp    801cbe <strtol+0x3b>
  801cad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801cb2:	3c 2d                	cmp    $0x2d,%al
  801cb4:	75 08                	jne    801cbe <strtol+0x3b>
		s++, neg = 1;
  801cb6:	83 c1 01             	add    $0x1,%ecx
  801cb9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cbe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cc4:	75 15                	jne    801cdb <strtol+0x58>
  801cc6:	80 39 30             	cmpb   $0x30,(%ecx)
  801cc9:	75 10                	jne    801cdb <strtol+0x58>
  801ccb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ccf:	75 7c                	jne    801d4d <strtol+0xca>
		s += 2, base = 16;
  801cd1:	83 c1 02             	add    $0x2,%ecx
  801cd4:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cd9:	eb 16                	jmp    801cf1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cdb:	85 db                	test   %ebx,%ebx
  801cdd:	75 12                	jne    801cf1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cdf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ce4:	80 39 30             	cmpb   $0x30,(%ecx)
  801ce7:	75 08                	jne    801cf1 <strtol+0x6e>
		s++, base = 8;
  801ce9:	83 c1 01             	add    $0x1,%ecx
  801cec:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801cf9:	0f b6 11             	movzbl (%ecx),%edx
  801cfc:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cff:	89 f3                	mov    %esi,%ebx
  801d01:	80 fb 09             	cmp    $0x9,%bl
  801d04:	77 08                	ja     801d0e <strtol+0x8b>
			dig = *s - '0';
  801d06:	0f be d2             	movsbl %dl,%edx
  801d09:	83 ea 30             	sub    $0x30,%edx
  801d0c:	eb 22                	jmp    801d30 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	80 fb 19             	cmp    $0x19,%bl
  801d16:	77 08                	ja     801d20 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d18:	0f be d2             	movsbl %dl,%edx
  801d1b:	83 ea 57             	sub    $0x57,%edx
  801d1e:	eb 10                	jmp    801d30 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d20:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d23:	89 f3                	mov    %esi,%ebx
  801d25:	80 fb 19             	cmp    $0x19,%bl
  801d28:	77 16                	ja     801d40 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d2a:	0f be d2             	movsbl %dl,%edx
  801d2d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d30:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d33:	7d 0b                	jge    801d40 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d35:	83 c1 01             	add    $0x1,%ecx
  801d38:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d3c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d3e:	eb b9                	jmp    801cf9 <strtol+0x76>

	if (endptr)
  801d40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d44:	74 0d                	je     801d53 <strtol+0xd0>
		*endptr = (char *) s;
  801d46:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d49:	89 0e                	mov    %ecx,(%esi)
  801d4b:	eb 06                	jmp    801d53 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d4d:	85 db                	test   %ebx,%ebx
  801d4f:	74 98                	je     801ce9 <strtol+0x66>
  801d51:	eb 9e                	jmp    801cf1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d53:	89 c2                	mov    %eax,%edx
  801d55:	f7 da                	neg    %edx
  801d57:	85 ff                	test   %edi,%edi
  801d59:	0f 45 c2             	cmovne %edx,%eax
}
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5f                   	pop    %edi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d67:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d6e:	75 2a                	jne    801d9a <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d70:	83 ec 04             	sub    $0x4,%esp
  801d73:	6a 07                	push   $0x7
  801d75:	68 00 f0 bf ee       	push   $0xeebff000
  801d7a:	6a 00                	push   $0x0
  801d7c:	e8 23 e4 ff ff       	call   8001a4 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d81:	83 c4 10             	add    $0x10,%esp
  801d84:	85 c0                	test   %eax,%eax
  801d86:	79 12                	jns    801d9a <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d88:	50                   	push   %eax
  801d89:	68 a0 26 80 00       	push   $0x8026a0
  801d8e:	6a 23                	push   $0x23
  801d90:	68 a4 26 80 00       	push   $0x8026a4
  801d95:	e8 22 f6 ff ff       	call   8013bc <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9d:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801da2:	83 ec 08             	sub    $0x8,%esp
  801da5:	68 cc 1d 80 00       	push   $0x801dcc
  801daa:	6a 00                	push   $0x0
  801dac:	e8 3e e5 ff ff       	call   8002ef <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801db1:	83 c4 10             	add    $0x10,%esp
  801db4:	85 c0                	test   %eax,%eax
  801db6:	79 12                	jns    801dca <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801db8:	50                   	push   %eax
  801db9:	68 a0 26 80 00       	push   $0x8026a0
  801dbe:	6a 2c                	push   $0x2c
  801dc0:	68 a4 26 80 00       	push   $0x8026a4
  801dc5:	e8 f2 f5 ff ff       	call   8013bc <_panic>
	}
}
  801dca:	c9                   	leave  
  801dcb:	c3                   	ret    

00801dcc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dcc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dcd:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dd2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dd4:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dd7:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801ddb:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801de0:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801de4:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801de6:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801de9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dea:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ded:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dee:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801def:	c3                   	ret    

00801df0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	56                   	push   %esi
  801df4:	53                   	push   %ebx
  801df5:	8b 75 08             	mov    0x8(%ebp),%esi
  801df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	75 12                	jne    801e14 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e02:	83 ec 0c             	sub    $0xc,%esp
  801e05:	68 00 00 c0 ee       	push   $0xeec00000
  801e0a:	e8 45 e5 ff ff       	call   800354 <sys_ipc_recv>
  801e0f:	83 c4 10             	add    $0x10,%esp
  801e12:	eb 0c                	jmp    801e20 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e14:	83 ec 0c             	sub    $0xc,%esp
  801e17:	50                   	push   %eax
  801e18:	e8 37 e5 ff ff       	call   800354 <sys_ipc_recv>
  801e1d:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e20:	85 f6                	test   %esi,%esi
  801e22:	0f 95 c1             	setne  %cl
  801e25:	85 db                	test   %ebx,%ebx
  801e27:	0f 95 c2             	setne  %dl
  801e2a:	84 d1                	test   %dl,%cl
  801e2c:	74 09                	je     801e37 <ipc_recv+0x47>
  801e2e:	89 c2                	mov    %eax,%edx
  801e30:	c1 ea 1f             	shr    $0x1f,%edx
  801e33:	84 d2                	test   %dl,%dl
  801e35:	75 2d                	jne    801e64 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e37:	85 f6                	test   %esi,%esi
  801e39:	74 0d                	je     801e48 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e3b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e40:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e46:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e48:	85 db                	test   %ebx,%ebx
  801e4a:	74 0d                	je     801e59 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e51:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e57:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e59:	a1 04 40 80 00       	mov    0x804004,%eax
  801e5e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    

00801e6b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	57                   	push   %edi
  801e6f:	56                   	push   %esi
  801e70:	53                   	push   %ebx
  801e71:	83 ec 0c             	sub    $0xc,%esp
  801e74:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e77:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e7d:	85 db                	test   %ebx,%ebx
  801e7f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e84:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e87:	ff 75 14             	pushl  0x14(%ebp)
  801e8a:	53                   	push   %ebx
  801e8b:	56                   	push   %esi
  801e8c:	57                   	push   %edi
  801e8d:	e8 9f e4 ff ff       	call   800331 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e92:	89 c2                	mov    %eax,%edx
  801e94:	c1 ea 1f             	shr    $0x1f,%edx
  801e97:	83 c4 10             	add    $0x10,%esp
  801e9a:	84 d2                	test   %dl,%dl
  801e9c:	74 17                	je     801eb5 <ipc_send+0x4a>
  801e9e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ea1:	74 12                	je     801eb5 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ea3:	50                   	push   %eax
  801ea4:	68 b2 26 80 00       	push   $0x8026b2
  801ea9:	6a 47                	push   $0x47
  801eab:	68 c0 26 80 00       	push   $0x8026c0
  801eb0:	e8 07 f5 ff ff       	call   8013bc <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801eb5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801eb8:	75 07                	jne    801ec1 <ipc_send+0x56>
			sys_yield();
  801eba:	e8 c6 e2 ff ff       	call   800185 <sys_yield>
  801ebf:	eb c6                	jmp    801e87 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ec1:	85 c0                	test   %eax,%eax
  801ec3:	75 c2                	jne    801e87 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801ec5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    

00801ecd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ed3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ed8:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ede:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ee4:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801eea:	39 ca                	cmp    %ecx,%edx
  801eec:	75 10                	jne    801efe <ipc_find_env+0x31>
			return envs[i].env_id;
  801eee:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801ef4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ef9:	8b 40 7c             	mov    0x7c(%eax),%eax
  801efc:	eb 0f                	jmp    801f0d <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801efe:	83 c0 01             	add    $0x1,%eax
  801f01:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f06:	75 d0                	jne    801ed8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f15:	89 d0                	mov    %edx,%eax
  801f17:	c1 e8 16             	shr    $0x16,%eax
  801f1a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f21:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f26:	f6 c1 01             	test   $0x1,%cl
  801f29:	74 1d                	je     801f48 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f2b:	c1 ea 0c             	shr    $0xc,%edx
  801f2e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f35:	f6 c2 01             	test   $0x1,%dl
  801f38:	74 0e                	je     801f48 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f3a:	c1 ea 0c             	shr    $0xc,%edx
  801f3d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f44:	ef 
  801f45:	0f b7 c0             	movzwl %ax,%eax
}
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    
  801f4a:	66 90                	xchg   %ax,%ax
  801f4c:	66 90                	xchg   %ax,%ax
  801f4e:	66 90                	xchg   %ax,%ax

00801f50 <__udivdi3>:
  801f50:	55                   	push   %ebp
  801f51:	57                   	push   %edi
  801f52:	56                   	push   %esi
  801f53:	53                   	push   %ebx
  801f54:	83 ec 1c             	sub    $0x1c,%esp
  801f57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f67:	85 f6                	test   %esi,%esi
  801f69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f6d:	89 ca                	mov    %ecx,%edx
  801f6f:	89 f8                	mov    %edi,%eax
  801f71:	75 3d                	jne    801fb0 <__udivdi3+0x60>
  801f73:	39 cf                	cmp    %ecx,%edi
  801f75:	0f 87 c5 00 00 00    	ja     802040 <__udivdi3+0xf0>
  801f7b:	85 ff                	test   %edi,%edi
  801f7d:	89 fd                	mov    %edi,%ebp
  801f7f:	75 0b                	jne    801f8c <__udivdi3+0x3c>
  801f81:	b8 01 00 00 00       	mov    $0x1,%eax
  801f86:	31 d2                	xor    %edx,%edx
  801f88:	f7 f7                	div    %edi
  801f8a:	89 c5                	mov    %eax,%ebp
  801f8c:	89 c8                	mov    %ecx,%eax
  801f8e:	31 d2                	xor    %edx,%edx
  801f90:	f7 f5                	div    %ebp
  801f92:	89 c1                	mov    %eax,%ecx
  801f94:	89 d8                	mov    %ebx,%eax
  801f96:	89 cf                	mov    %ecx,%edi
  801f98:	f7 f5                	div    %ebp
  801f9a:	89 c3                	mov    %eax,%ebx
  801f9c:	89 d8                	mov    %ebx,%eax
  801f9e:	89 fa                	mov    %edi,%edx
  801fa0:	83 c4 1c             	add    $0x1c,%esp
  801fa3:	5b                   	pop    %ebx
  801fa4:	5e                   	pop    %esi
  801fa5:	5f                   	pop    %edi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    
  801fa8:	90                   	nop
  801fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fb0:	39 ce                	cmp    %ecx,%esi
  801fb2:	77 74                	ja     802028 <__udivdi3+0xd8>
  801fb4:	0f bd fe             	bsr    %esi,%edi
  801fb7:	83 f7 1f             	xor    $0x1f,%edi
  801fba:	0f 84 98 00 00 00    	je     802058 <__udivdi3+0x108>
  801fc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	89 c5                	mov    %eax,%ebp
  801fc9:	29 fb                	sub    %edi,%ebx
  801fcb:	d3 e6                	shl    %cl,%esi
  801fcd:	89 d9                	mov    %ebx,%ecx
  801fcf:	d3 ed                	shr    %cl,%ebp
  801fd1:	89 f9                	mov    %edi,%ecx
  801fd3:	d3 e0                	shl    %cl,%eax
  801fd5:	09 ee                	or     %ebp,%esi
  801fd7:	89 d9                	mov    %ebx,%ecx
  801fd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fdd:	89 d5                	mov    %edx,%ebp
  801fdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fe3:	d3 ed                	shr    %cl,%ebp
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e2                	shl    %cl,%edx
  801fe9:	89 d9                	mov    %ebx,%ecx
  801feb:	d3 e8                	shr    %cl,%eax
  801fed:	09 c2                	or     %eax,%edx
  801fef:	89 d0                	mov    %edx,%eax
  801ff1:	89 ea                	mov    %ebp,%edx
  801ff3:	f7 f6                	div    %esi
  801ff5:	89 d5                	mov    %edx,%ebp
  801ff7:	89 c3                	mov    %eax,%ebx
  801ff9:	f7 64 24 0c          	mull   0xc(%esp)
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	72 10                	jb     802011 <__udivdi3+0xc1>
  802001:	8b 74 24 08          	mov    0x8(%esp),%esi
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e6                	shl    %cl,%esi
  802009:	39 c6                	cmp    %eax,%esi
  80200b:	73 07                	jae    802014 <__udivdi3+0xc4>
  80200d:	39 d5                	cmp    %edx,%ebp
  80200f:	75 03                	jne    802014 <__udivdi3+0xc4>
  802011:	83 eb 01             	sub    $0x1,%ebx
  802014:	31 ff                	xor    %edi,%edi
  802016:	89 d8                	mov    %ebx,%eax
  802018:	89 fa                	mov    %edi,%edx
  80201a:	83 c4 1c             	add    $0x1c,%esp
  80201d:	5b                   	pop    %ebx
  80201e:	5e                   	pop    %esi
  80201f:	5f                   	pop    %edi
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
  802022:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802028:	31 ff                	xor    %edi,%edi
  80202a:	31 db                	xor    %ebx,%ebx
  80202c:	89 d8                	mov    %ebx,%eax
  80202e:	89 fa                	mov    %edi,%edx
  802030:	83 c4 1c             	add    $0x1c,%esp
  802033:	5b                   	pop    %ebx
  802034:	5e                   	pop    %esi
  802035:	5f                   	pop    %edi
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    
  802038:	90                   	nop
  802039:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802040:	89 d8                	mov    %ebx,%eax
  802042:	f7 f7                	div    %edi
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 c3                	mov    %eax,%ebx
  802048:	89 d8                	mov    %ebx,%eax
  80204a:	89 fa                	mov    %edi,%edx
  80204c:	83 c4 1c             	add    $0x1c,%esp
  80204f:	5b                   	pop    %ebx
  802050:	5e                   	pop    %esi
  802051:	5f                   	pop    %edi
  802052:	5d                   	pop    %ebp
  802053:	c3                   	ret    
  802054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802058:	39 ce                	cmp    %ecx,%esi
  80205a:	72 0c                	jb     802068 <__udivdi3+0x118>
  80205c:	31 db                	xor    %ebx,%ebx
  80205e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802062:	0f 87 34 ff ff ff    	ja     801f9c <__udivdi3+0x4c>
  802068:	bb 01 00 00 00       	mov    $0x1,%ebx
  80206d:	e9 2a ff ff ff       	jmp    801f9c <__udivdi3+0x4c>
  802072:	66 90                	xchg   %ax,%ax
  802074:	66 90                	xchg   %ax,%ax
  802076:	66 90                	xchg   %ax,%ax
  802078:	66 90                	xchg   %ax,%ax
  80207a:	66 90                	xchg   %ax,%ax
  80207c:	66 90                	xchg   %ax,%ax
  80207e:	66 90                	xchg   %ax,%ax

00802080 <__umoddi3>:
  802080:	55                   	push   %ebp
  802081:	57                   	push   %edi
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
  802087:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80208b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80208f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802097:	85 d2                	test   %edx,%edx
  802099:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80209d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020a1:	89 f3                	mov    %esi,%ebx
  8020a3:	89 3c 24             	mov    %edi,(%esp)
  8020a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020aa:	75 1c                	jne    8020c8 <__umoddi3+0x48>
  8020ac:	39 f7                	cmp    %esi,%edi
  8020ae:	76 50                	jbe    802100 <__umoddi3+0x80>
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	f7 f7                	div    %edi
  8020b6:	89 d0                	mov    %edx,%eax
  8020b8:	31 d2                	xor    %edx,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	39 f2                	cmp    %esi,%edx
  8020ca:	89 d0                	mov    %edx,%eax
  8020cc:	77 52                	ja     802120 <__umoddi3+0xa0>
  8020ce:	0f bd ea             	bsr    %edx,%ebp
  8020d1:	83 f5 1f             	xor    $0x1f,%ebp
  8020d4:	75 5a                	jne    802130 <__umoddi3+0xb0>
  8020d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020da:	0f 82 e0 00 00 00    	jb     8021c0 <__umoddi3+0x140>
  8020e0:	39 0c 24             	cmp    %ecx,(%esp)
  8020e3:	0f 86 d7 00 00 00    	jbe    8021c0 <__umoddi3+0x140>
  8020e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020f1:	83 c4 1c             	add    $0x1c,%esp
  8020f4:	5b                   	pop    %ebx
  8020f5:	5e                   	pop    %esi
  8020f6:	5f                   	pop    %edi
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    
  8020f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802100:	85 ff                	test   %edi,%edi
  802102:	89 fd                	mov    %edi,%ebp
  802104:	75 0b                	jne    802111 <__umoddi3+0x91>
  802106:	b8 01 00 00 00       	mov    $0x1,%eax
  80210b:	31 d2                	xor    %edx,%edx
  80210d:	f7 f7                	div    %edi
  80210f:	89 c5                	mov    %eax,%ebp
  802111:	89 f0                	mov    %esi,%eax
  802113:	31 d2                	xor    %edx,%edx
  802115:	f7 f5                	div    %ebp
  802117:	89 c8                	mov    %ecx,%eax
  802119:	f7 f5                	div    %ebp
  80211b:	89 d0                	mov    %edx,%eax
  80211d:	eb 99                	jmp    8020b8 <__umoddi3+0x38>
  80211f:	90                   	nop
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	83 c4 1c             	add    $0x1c,%esp
  802127:	5b                   	pop    %ebx
  802128:	5e                   	pop    %esi
  802129:	5f                   	pop    %edi
  80212a:	5d                   	pop    %ebp
  80212b:	c3                   	ret    
  80212c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802130:	8b 34 24             	mov    (%esp),%esi
  802133:	bf 20 00 00 00       	mov    $0x20,%edi
  802138:	89 e9                	mov    %ebp,%ecx
  80213a:	29 ef                	sub    %ebp,%edi
  80213c:	d3 e0                	shl    %cl,%eax
  80213e:	89 f9                	mov    %edi,%ecx
  802140:	89 f2                	mov    %esi,%edx
  802142:	d3 ea                	shr    %cl,%edx
  802144:	89 e9                	mov    %ebp,%ecx
  802146:	09 c2                	or     %eax,%edx
  802148:	89 d8                	mov    %ebx,%eax
  80214a:	89 14 24             	mov    %edx,(%esp)
  80214d:	89 f2                	mov    %esi,%edx
  80214f:	d3 e2                	shl    %cl,%edx
  802151:	89 f9                	mov    %edi,%ecx
  802153:	89 54 24 04          	mov    %edx,0x4(%esp)
  802157:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80215b:	d3 e8                	shr    %cl,%eax
  80215d:	89 e9                	mov    %ebp,%ecx
  80215f:	89 c6                	mov    %eax,%esi
  802161:	d3 e3                	shl    %cl,%ebx
  802163:	89 f9                	mov    %edi,%ecx
  802165:	89 d0                	mov    %edx,%eax
  802167:	d3 e8                	shr    %cl,%eax
  802169:	89 e9                	mov    %ebp,%ecx
  80216b:	09 d8                	or     %ebx,%eax
  80216d:	89 d3                	mov    %edx,%ebx
  80216f:	89 f2                	mov    %esi,%edx
  802171:	f7 34 24             	divl   (%esp)
  802174:	89 d6                	mov    %edx,%esi
  802176:	d3 e3                	shl    %cl,%ebx
  802178:	f7 64 24 04          	mull   0x4(%esp)
  80217c:	39 d6                	cmp    %edx,%esi
  80217e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802182:	89 d1                	mov    %edx,%ecx
  802184:	89 c3                	mov    %eax,%ebx
  802186:	72 08                	jb     802190 <__umoddi3+0x110>
  802188:	75 11                	jne    80219b <__umoddi3+0x11b>
  80218a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80218e:	73 0b                	jae    80219b <__umoddi3+0x11b>
  802190:	2b 44 24 04          	sub    0x4(%esp),%eax
  802194:	1b 14 24             	sbb    (%esp),%edx
  802197:	89 d1                	mov    %edx,%ecx
  802199:	89 c3                	mov    %eax,%ebx
  80219b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80219f:	29 da                	sub    %ebx,%edx
  8021a1:	19 ce                	sbb    %ecx,%esi
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 f0                	mov    %esi,%eax
  8021a7:	d3 e0                	shl    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	d3 ea                	shr    %cl,%edx
  8021ad:	89 e9                	mov    %ebp,%ecx
  8021af:	d3 ee                	shr    %cl,%esi
  8021b1:	09 d0                	or     %edx,%eax
  8021b3:	89 f2                	mov    %esi,%edx
  8021b5:	83 c4 1c             	add    $0x1c,%esp
  8021b8:	5b                   	pop    %ebx
  8021b9:	5e                   	pop    %esi
  8021ba:	5f                   	pop    %edi
  8021bb:	5d                   	pop    %ebp
  8021bc:	c3                   	ret    
  8021bd:	8d 76 00             	lea    0x0(%esi),%esi
  8021c0:	29 f9                	sub    %edi,%ecx
  8021c2:	19 d6                	sbb    %edx,%esi
  8021c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021cc:	e9 18 ff ff ff       	jmp    8020e9 <__umoddi3+0x69>
