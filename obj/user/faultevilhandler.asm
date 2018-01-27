
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
  800042:	e8 5d 01 00 00       	call   8001a4 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
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
  80007a:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8000d4:	e8 04 08 00 00       	call   8008dd <close_all>
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
  80014d:	68 4a 22 80 00       	push   $0x80224a
  800152:	6a 23                	push   $0x23
  800154:	68 67 22 80 00       	push   $0x802267
  800159:	e8 b0 12 00 00       	call   80140e <_panic>

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
  8001ce:	68 4a 22 80 00       	push   $0x80224a
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 67 22 80 00       	push   $0x802267
  8001da:	e8 2f 12 00 00       	call   80140e <_panic>

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
  800210:	68 4a 22 80 00       	push   $0x80224a
  800215:	6a 23                	push   $0x23
  800217:	68 67 22 80 00       	push   $0x802267
  80021c:	e8 ed 11 00 00       	call   80140e <_panic>

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
  800252:	68 4a 22 80 00       	push   $0x80224a
  800257:	6a 23                	push   $0x23
  800259:	68 67 22 80 00       	push   $0x802267
  80025e:	e8 ab 11 00 00       	call   80140e <_panic>

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
  800294:	68 4a 22 80 00       	push   $0x80224a
  800299:	6a 23                	push   $0x23
  80029b:	68 67 22 80 00       	push   $0x802267
  8002a0:	e8 69 11 00 00       	call   80140e <_panic>

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
  8002d6:	68 4a 22 80 00       	push   $0x80224a
  8002db:	6a 23                	push   $0x23
  8002dd:	68 67 22 80 00       	push   $0x802267
  8002e2:	e8 27 11 00 00       	call   80140e <_panic>
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
  800318:	68 4a 22 80 00       	push   $0x80224a
  80031d:	6a 23                	push   $0x23
  80031f:	68 67 22 80 00       	push   $0x802267
  800324:	e8 e5 10 00 00       	call   80140e <_panic>

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
  80037c:	68 4a 22 80 00       	push   $0x80224a
  800381:	6a 23                	push   $0x23
  800383:	68 67 22 80 00       	push   $0x802267
  800388:	e8 81 10 00 00       	call   80140e <_panic>

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

008003d5 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	57                   	push   %edi
  8003d9:	56                   	push   %esi
  8003da:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e0:	b8 10 00 00 00       	mov    $0x10,%eax
  8003e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e8:	89 cb                	mov    %ecx,%ebx
  8003ea:	89 cf                	mov    %ecx,%edi
  8003ec:	89 ce                	mov    %ecx,%esi
  8003ee:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8003f0:	5b                   	pop    %ebx
  8003f1:	5e                   	pop    %esi
  8003f2:	5f                   	pop    %edi
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	53                   	push   %ebx
  8003f9:	83 ec 04             	sub    $0x4,%esp
  8003fc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003ff:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800401:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800405:	74 11                	je     800418 <pgfault+0x23>
  800407:	89 d8                	mov    %ebx,%eax
  800409:	c1 e8 0c             	shr    $0xc,%eax
  80040c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800413:	f6 c4 08             	test   $0x8,%ah
  800416:	75 14                	jne    80042c <pgfault+0x37>
		panic("faulting access");
  800418:	83 ec 04             	sub    $0x4,%esp
  80041b:	68 75 22 80 00       	push   $0x802275
  800420:	6a 1e                	push   $0x1e
  800422:	68 85 22 80 00       	push   $0x802285
  800427:	e8 e2 0f 00 00       	call   80140e <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  80042c:	83 ec 04             	sub    $0x4,%esp
  80042f:	6a 07                	push   $0x7
  800431:	68 00 f0 7f 00       	push   $0x7ff000
  800436:	6a 00                	push   $0x0
  800438:	e8 67 fd ff ff       	call   8001a4 <sys_page_alloc>
	if (r < 0) {
  80043d:	83 c4 10             	add    $0x10,%esp
  800440:	85 c0                	test   %eax,%eax
  800442:	79 12                	jns    800456 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800444:	50                   	push   %eax
  800445:	68 90 22 80 00       	push   $0x802290
  80044a:	6a 2c                	push   $0x2c
  80044c:	68 85 22 80 00       	push   $0x802285
  800451:	e8 b8 0f 00 00       	call   80140e <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800456:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80045c:	83 ec 04             	sub    $0x4,%esp
  80045f:	68 00 10 00 00       	push   $0x1000
  800464:	53                   	push   %ebx
  800465:	68 00 f0 7f 00       	push   $0x7ff000
  80046a:	e8 f7 17 00 00       	call   801c66 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  80046f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800476:	53                   	push   %ebx
  800477:	6a 00                	push   $0x0
  800479:	68 00 f0 7f 00       	push   $0x7ff000
  80047e:	6a 00                	push   $0x0
  800480:	e8 62 fd ff ff       	call   8001e7 <sys_page_map>
	if (r < 0) {
  800485:	83 c4 20             	add    $0x20,%esp
  800488:	85 c0                	test   %eax,%eax
  80048a:	79 12                	jns    80049e <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80048c:	50                   	push   %eax
  80048d:	68 90 22 80 00       	push   $0x802290
  800492:	6a 33                	push   $0x33
  800494:	68 85 22 80 00       	push   $0x802285
  800499:	e8 70 0f 00 00       	call   80140e <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	68 00 f0 7f 00       	push   $0x7ff000
  8004a6:	6a 00                	push   $0x0
  8004a8:	e8 7c fd ff ff       	call   800229 <sys_page_unmap>
	if (r < 0) {
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	85 c0                	test   %eax,%eax
  8004b2:	79 12                	jns    8004c6 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8004b4:	50                   	push   %eax
  8004b5:	68 90 22 80 00       	push   $0x802290
  8004ba:	6a 37                	push   $0x37
  8004bc:	68 85 22 80 00       	push   $0x802285
  8004c1:	e8 48 0f 00 00       	call   80140e <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004c9:	c9                   	leave  
  8004ca:	c3                   	ret    

008004cb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	57                   	push   %edi
  8004cf:	56                   	push   %esi
  8004d0:	53                   	push   %ebx
  8004d1:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004d4:	68 f5 03 80 00       	push   $0x8003f5
  8004d9:	e8 d5 18 00 00       	call   801db3 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004de:	b8 07 00 00 00       	mov    $0x7,%eax
  8004e3:	cd 30                	int    $0x30
  8004e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	79 17                	jns    800506 <fork+0x3b>
		panic("fork fault %e");
  8004ef:	83 ec 04             	sub    $0x4,%esp
  8004f2:	68 a9 22 80 00       	push   $0x8022a9
  8004f7:	68 84 00 00 00       	push   $0x84
  8004fc:	68 85 22 80 00       	push   $0x802285
  800501:	e8 08 0f 00 00       	call   80140e <_panic>
  800506:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800508:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050c:	75 24                	jne    800532 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80050e:	e8 53 fc ff ff       	call   800166 <sys_getenvid>
  800513:	25 ff 03 00 00       	and    $0x3ff,%eax
  800518:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80051e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800523:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800528:	b8 00 00 00 00       	mov    $0x0,%eax
  80052d:	e9 64 01 00 00       	jmp    800696 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800532:	83 ec 04             	sub    $0x4,%esp
  800535:	6a 07                	push   $0x7
  800537:	68 00 f0 bf ee       	push   $0xeebff000
  80053c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80053f:	e8 60 fc ff ff       	call   8001a4 <sys_page_alloc>
  800544:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800547:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80054c:	89 d8                	mov    %ebx,%eax
  80054e:	c1 e8 16             	shr    $0x16,%eax
  800551:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800558:	a8 01                	test   $0x1,%al
  80055a:	0f 84 fc 00 00 00    	je     80065c <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800560:	89 d8                	mov    %ebx,%eax
  800562:	c1 e8 0c             	shr    $0xc,%eax
  800565:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80056c:	f6 c2 01             	test   $0x1,%dl
  80056f:	0f 84 e7 00 00 00    	je     80065c <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800575:	89 c6                	mov    %eax,%esi
  800577:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80057a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800581:	f6 c6 04             	test   $0x4,%dh
  800584:	74 39                	je     8005bf <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800586:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80058d:	83 ec 0c             	sub    $0xc,%esp
  800590:	25 07 0e 00 00       	and    $0xe07,%eax
  800595:	50                   	push   %eax
  800596:	56                   	push   %esi
  800597:	57                   	push   %edi
  800598:	56                   	push   %esi
  800599:	6a 00                	push   $0x0
  80059b:	e8 47 fc ff ff       	call   8001e7 <sys_page_map>
		if (r < 0) {
  8005a0:	83 c4 20             	add    $0x20,%esp
  8005a3:	85 c0                	test   %eax,%eax
  8005a5:	0f 89 b1 00 00 00    	jns    80065c <fork+0x191>
		    	panic("sys page map fault %e");
  8005ab:	83 ec 04             	sub    $0x4,%esp
  8005ae:	68 b7 22 80 00       	push   $0x8022b7
  8005b3:	6a 54                	push   $0x54
  8005b5:	68 85 22 80 00       	push   $0x802285
  8005ba:	e8 4f 0e 00 00       	call   80140e <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8005bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c6:	f6 c2 02             	test   $0x2,%dl
  8005c9:	75 0c                	jne    8005d7 <fork+0x10c>
  8005cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d2:	f6 c4 08             	test   $0x8,%ah
  8005d5:	74 5b                	je     800632 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	68 05 08 00 00       	push   $0x805
  8005df:	56                   	push   %esi
  8005e0:	57                   	push   %edi
  8005e1:	56                   	push   %esi
  8005e2:	6a 00                	push   $0x0
  8005e4:	e8 fe fb ff ff       	call   8001e7 <sys_page_map>
		if (r < 0) {
  8005e9:	83 c4 20             	add    $0x20,%esp
  8005ec:	85 c0                	test   %eax,%eax
  8005ee:	79 14                	jns    800604 <fork+0x139>
		    	panic("sys page map fault %e");
  8005f0:	83 ec 04             	sub    $0x4,%esp
  8005f3:	68 b7 22 80 00       	push   $0x8022b7
  8005f8:	6a 5b                	push   $0x5b
  8005fa:	68 85 22 80 00       	push   $0x802285
  8005ff:	e8 0a 0e 00 00       	call   80140e <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	68 05 08 00 00       	push   $0x805
  80060c:	56                   	push   %esi
  80060d:	6a 00                	push   $0x0
  80060f:	56                   	push   %esi
  800610:	6a 00                	push   $0x0
  800612:	e8 d0 fb ff ff       	call   8001e7 <sys_page_map>
		if (r < 0) {
  800617:	83 c4 20             	add    $0x20,%esp
  80061a:	85 c0                	test   %eax,%eax
  80061c:	79 3e                	jns    80065c <fork+0x191>
		    	panic("sys page map fault %e");
  80061e:	83 ec 04             	sub    $0x4,%esp
  800621:	68 b7 22 80 00       	push   $0x8022b7
  800626:	6a 5f                	push   $0x5f
  800628:	68 85 22 80 00       	push   $0x802285
  80062d:	e8 dc 0d 00 00       	call   80140e <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800632:	83 ec 0c             	sub    $0xc,%esp
  800635:	6a 05                	push   $0x5
  800637:	56                   	push   %esi
  800638:	57                   	push   %edi
  800639:	56                   	push   %esi
  80063a:	6a 00                	push   $0x0
  80063c:	e8 a6 fb ff ff       	call   8001e7 <sys_page_map>
		if (r < 0) {
  800641:	83 c4 20             	add    $0x20,%esp
  800644:	85 c0                	test   %eax,%eax
  800646:	79 14                	jns    80065c <fork+0x191>
		    	panic("sys page map fault %e");
  800648:	83 ec 04             	sub    $0x4,%esp
  80064b:	68 b7 22 80 00       	push   $0x8022b7
  800650:	6a 64                	push   $0x64
  800652:	68 85 22 80 00       	push   $0x802285
  800657:	e8 b2 0d 00 00       	call   80140e <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80065c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800662:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800668:	0f 85 de fe ff ff    	jne    80054c <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  80066e:	a1 04 40 80 00       	mov    0x804004,%eax
  800673:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  800679:	83 ec 08             	sub    $0x8,%esp
  80067c:	50                   	push   %eax
  80067d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800680:	57                   	push   %edi
  800681:	e8 69 fc ff ff       	call   8002ef <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800686:	83 c4 08             	add    $0x8,%esp
  800689:	6a 02                	push   $0x2
  80068b:	57                   	push   %edi
  80068c:	e8 da fb ff ff       	call   80026b <sys_env_set_status>
	
	return envid;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800696:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800699:	5b                   	pop    %ebx
  80069a:	5e                   	pop    %esi
  80069b:	5f                   	pop    %edi
  80069c:	5d                   	pop    %ebp
  80069d:	c3                   	ret    

0080069e <sfork>:

envid_t
sfork(void)
{
  80069e:	55                   	push   %ebp
  80069f:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8006a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a6:	5d                   	pop    %ebp
  8006a7:	c3                   	ret    

008006a8 <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	56                   	push   %esi
  8006ac:	53                   	push   %ebx
  8006ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8006b0:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8006b6:	83 ec 08             	sub    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	68 d0 22 80 00       	push   $0x8022d0
  8006bf:	e8 23 0e 00 00       	call   8014e7 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006c4:	c7 04 24 ae 00 80 00 	movl   $0x8000ae,(%esp)
  8006cb:	e8 c5 fc ff ff       	call   800395 <sys_thread_create>
  8006d0:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006d2:	83 c4 08             	add    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	68 d0 22 80 00       	push   $0x8022d0
  8006db:	e8 07 0e 00 00       	call   8014e7 <cprintf>
	return id;
}
  8006e0:	89 f0                	mov    %esi,%eax
  8006e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006e5:	5b                   	pop    %ebx
  8006e6:	5e                   	pop    %esi
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8006ef:	ff 75 08             	pushl  0x8(%ebp)
  8006f2:	e8 be fc ff ff       	call   8003b5 <sys_thread_free>
}
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    

008006fc <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  800702:	ff 75 08             	pushl  0x8(%ebp)
  800705:	e8 cb fc ff ff       	call   8003d5 <sys_thread_join>
}
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    

0080070f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800712:	8b 45 08             	mov    0x8(%ebp),%eax
  800715:	05 00 00 00 30       	add    $0x30000000,%eax
  80071a:	c1 e8 0c             	shr    $0xc,%eax
}
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800722:	8b 45 08             	mov    0x8(%ebp),%eax
  800725:	05 00 00 00 30       	add    $0x30000000,%eax
  80072a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80072f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800741:	89 c2                	mov    %eax,%edx
  800743:	c1 ea 16             	shr    $0x16,%edx
  800746:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80074d:	f6 c2 01             	test   $0x1,%dl
  800750:	74 11                	je     800763 <fd_alloc+0x2d>
  800752:	89 c2                	mov    %eax,%edx
  800754:	c1 ea 0c             	shr    $0xc,%edx
  800757:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80075e:	f6 c2 01             	test   $0x1,%dl
  800761:	75 09                	jne    80076c <fd_alloc+0x36>
			*fd_store = fd;
  800763:	89 01                	mov    %eax,(%ecx)
			return 0;
  800765:	b8 00 00 00 00       	mov    $0x0,%eax
  80076a:	eb 17                	jmp    800783 <fd_alloc+0x4d>
  80076c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800771:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800776:	75 c9                	jne    800741 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800778:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80077e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800783:	5d                   	pop    %ebp
  800784:	c3                   	ret    

00800785 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80078b:	83 f8 1f             	cmp    $0x1f,%eax
  80078e:	77 36                	ja     8007c6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800790:	c1 e0 0c             	shl    $0xc,%eax
  800793:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800798:	89 c2                	mov    %eax,%edx
  80079a:	c1 ea 16             	shr    $0x16,%edx
  80079d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007a4:	f6 c2 01             	test   $0x1,%dl
  8007a7:	74 24                	je     8007cd <fd_lookup+0x48>
  8007a9:	89 c2                	mov    %eax,%edx
  8007ab:	c1 ea 0c             	shr    $0xc,%edx
  8007ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007b5:	f6 c2 01             	test   $0x1,%dl
  8007b8:	74 1a                	je     8007d4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bd:	89 02                	mov    %eax,(%edx)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 13                	jmp    8007d9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cb:	eb 0c                	jmp    8007d9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d2:	eb 05                	jmp    8007d9 <fd_lookup+0x54>
  8007d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	ba 70 23 80 00       	mov    $0x802370,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007e9:	eb 13                	jmp    8007fe <dev_lookup+0x23>
  8007eb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007ee:	39 08                	cmp    %ecx,(%eax)
  8007f0:	75 0c                	jne    8007fe <dev_lookup+0x23>
			*dev = devtab[i];
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	eb 31                	jmp    80082f <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007fe:	8b 02                	mov    (%edx),%eax
  800800:	85 c0                	test   %eax,%eax
  800802:	75 e7                	jne    8007eb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800804:	a1 04 40 80 00       	mov    0x804004,%eax
  800809:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  80080f:	83 ec 04             	sub    $0x4,%esp
  800812:	51                   	push   %ecx
  800813:	50                   	push   %eax
  800814:	68 f4 22 80 00       	push   $0x8022f4
  800819:	e8 c9 0c 00 00       	call   8014e7 <cprintf>
	*dev = 0;
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800821:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80082f:	c9                   	leave  
  800830:	c3                   	ret    

00800831 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	56                   	push   %esi
  800835:	53                   	push   %ebx
  800836:	83 ec 10             	sub    $0x10,%esp
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80083f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800842:	50                   	push   %eax
  800843:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800849:	c1 e8 0c             	shr    $0xc,%eax
  80084c:	50                   	push   %eax
  80084d:	e8 33 ff ff ff       	call   800785 <fd_lookup>
  800852:	83 c4 08             	add    $0x8,%esp
  800855:	85 c0                	test   %eax,%eax
  800857:	78 05                	js     80085e <fd_close+0x2d>
	    || fd != fd2)
  800859:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80085c:	74 0c                	je     80086a <fd_close+0x39>
		return (must_exist ? r : 0);
  80085e:	84 db                	test   %bl,%bl
  800860:	ba 00 00 00 00       	mov    $0x0,%edx
  800865:	0f 44 c2             	cmove  %edx,%eax
  800868:	eb 41                	jmp    8008ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	ff 36                	pushl  (%esi)
  800873:	e8 63 ff ff ff       	call   8007db <dev_lookup>
  800878:	89 c3                	mov    %eax,%ebx
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	85 c0                	test   %eax,%eax
  80087f:	78 1a                	js     80089b <fd_close+0x6a>
		if (dev->dev_close)
  800881:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800884:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800887:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80088c:	85 c0                	test   %eax,%eax
  80088e:	74 0b                	je     80089b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800890:	83 ec 0c             	sub    $0xc,%esp
  800893:	56                   	push   %esi
  800894:	ff d0                	call   *%eax
  800896:	89 c3                	mov    %eax,%ebx
  800898:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	56                   	push   %esi
  80089f:	6a 00                	push   $0x0
  8008a1:	e8 83 f9 ff ff       	call   800229 <sys_page_unmap>
	return r;
  8008a6:	83 c4 10             	add    $0x10,%esp
  8008a9:	89 d8                	mov    %ebx,%eax
}
  8008ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ae:	5b                   	pop    %ebx
  8008af:	5e                   	pop    %esi
  8008b0:	5d                   	pop    %ebp
  8008b1:	c3                   	ret    

008008b2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8008b2:	55                   	push   %ebp
  8008b3:	89 e5                	mov    %esp,%ebp
  8008b5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008bb:	50                   	push   %eax
  8008bc:	ff 75 08             	pushl  0x8(%ebp)
  8008bf:	e8 c1 fe ff ff       	call   800785 <fd_lookup>
  8008c4:	83 c4 08             	add    $0x8,%esp
  8008c7:	85 c0                	test   %eax,%eax
  8008c9:	78 10                	js     8008db <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 01                	push   $0x1
  8008d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8008d3:	e8 59 ff ff ff       	call   800831 <fd_close>
  8008d8:	83 c4 10             	add    $0x10,%esp
}
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <close_all>:

void
close_all(void)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	53                   	push   %ebx
  8008e1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008e4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008e9:	83 ec 0c             	sub    $0xc,%esp
  8008ec:	53                   	push   %ebx
  8008ed:	e8 c0 ff ff ff       	call   8008b2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008f2:	83 c3 01             	add    $0x1,%ebx
  8008f5:	83 c4 10             	add    $0x10,%esp
  8008f8:	83 fb 20             	cmp    $0x20,%ebx
  8008fb:	75 ec                	jne    8008e9 <close_all+0xc>
		close(i);
}
  8008fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	83 ec 2c             	sub    $0x2c,%esp
  80090b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80090e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800911:	50                   	push   %eax
  800912:	ff 75 08             	pushl  0x8(%ebp)
  800915:	e8 6b fe ff ff       	call   800785 <fd_lookup>
  80091a:	83 c4 08             	add    $0x8,%esp
  80091d:	85 c0                	test   %eax,%eax
  80091f:	0f 88 c1 00 00 00    	js     8009e6 <dup+0xe4>
		return r;
	close(newfdnum);
  800925:	83 ec 0c             	sub    $0xc,%esp
  800928:	56                   	push   %esi
  800929:	e8 84 ff ff ff       	call   8008b2 <close>

	newfd = INDEX2FD(newfdnum);
  80092e:	89 f3                	mov    %esi,%ebx
  800930:	c1 e3 0c             	shl    $0xc,%ebx
  800933:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800939:	83 c4 04             	add    $0x4,%esp
  80093c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80093f:	e8 db fd ff ff       	call   80071f <fd2data>
  800944:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800946:	89 1c 24             	mov    %ebx,(%esp)
  800949:	e8 d1 fd ff ff       	call   80071f <fd2data>
  80094e:	83 c4 10             	add    $0x10,%esp
  800951:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800954:	89 f8                	mov    %edi,%eax
  800956:	c1 e8 16             	shr    $0x16,%eax
  800959:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800960:	a8 01                	test   $0x1,%al
  800962:	74 37                	je     80099b <dup+0x99>
  800964:	89 f8                	mov    %edi,%eax
  800966:	c1 e8 0c             	shr    $0xc,%eax
  800969:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800970:	f6 c2 01             	test   $0x1,%dl
  800973:	74 26                	je     80099b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800975:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80097c:	83 ec 0c             	sub    $0xc,%esp
  80097f:	25 07 0e 00 00       	and    $0xe07,%eax
  800984:	50                   	push   %eax
  800985:	ff 75 d4             	pushl  -0x2c(%ebp)
  800988:	6a 00                	push   $0x0
  80098a:	57                   	push   %edi
  80098b:	6a 00                	push   $0x0
  80098d:	e8 55 f8 ff ff       	call   8001e7 <sys_page_map>
  800992:	89 c7                	mov    %eax,%edi
  800994:	83 c4 20             	add    $0x20,%esp
  800997:	85 c0                	test   %eax,%eax
  800999:	78 2e                	js     8009c9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80099b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80099e:	89 d0                	mov    %edx,%eax
  8009a0:	c1 e8 0c             	shr    $0xc,%eax
  8009a3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009aa:	83 ec 0c             	sub    $0xc,%esp
  8009ad:	25 07 0e 00 00       	and    $0xe07,%eax
  8009b2:	50                   	push   %eax
  8009b3:	53                   	push   %ebx
  8009b4:	6a 00                	push   $0x0
  8009b6:	52                   	push   %edx
  8009b7:	6a 00                	push   $0x0
  8009b9:	e8 29 f8 ff ff       	call   8001e7 <sys_page_map>
  8009be:	89 c7                	mov    %eax,%edi
  8009c0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8009c3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009c5:	85 ff                	test   %edi,%edi
  8009c7:	79 1d                	jns    8009e6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	53                   	push   %ebx
  8009cd:	6a 00                	push   $0x0
  8009cf:	e8 55 f8 ff ff       	call   800229 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8009d4:	83 c4 08             	add    $0x8,%esp
  8009d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009da:	6a 00                	push   $0x0
  8009dc:	e8 48 f8 ff ff       	call   800229 <sys_page_unmap>
	return r;
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	89 f8                	mov    %edi,%eax
}
  8009e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009e9:	5b                   	pop    %ebx
  8009ea:	5e                   	pop    %esi
  8009eb:	5f                   	pop    %edi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	53                   	push   %ebx
  8009f2:	83 ec 14             	sub    $0x14,%esp
  8009f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009fb:	50                   	push   %eax
  8009fc:	53                   	push   %ebx
  8009fd:	e8 83 fd ff ff       	call   800785 <fd_lookup>
  800a02:	83 c4 08             	add    $0x8,%esp
  800a05:	89 c2                	mov    %eax,%edx
  800a07:	85 c0                	test   %eax,%eax
  800a09:	78 70                	js     800a7b <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a0b:	83 ec 08             	sub    $0x8,%esp
  800a0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a11:	50                   	push   %eax
  800a12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a15:	ff 30                	pushl  (%eax)
  800a17:	e8 bf fd ff ff       	call   8007db <dev_lookup>
  800a1c:	83 c4 10             	add    $0x10,%esp
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	78 4f                	js     800a72 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a23:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a26:	8b 42 08             	mov    0x8(%edx),%eax
  800a29:	83 e0 03             	and    $0x3,%eax
  800a2c:	83 f8 01             	cmp    $0x1,%eax
  800a2f:	75 24                	jne    800a55 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a31:	a1 04 40 80 00       	mov    0x804004,%eax
  800a36:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a3c:	83 ec 04             	sub    $0x4,%esp
  800a3f:	53                   	push   %ebx
  800a40:	50                   	push   %eax
  800a41:	68 35 23 80 00       	push   $0x802335
  800a46:	e8 9c 0a 00 00       	call   8014e7 <cprintf>
		return -E_INVAL;
  800a4b:	83 c4 10             	add    $0x10,%esp
  800a4e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a53:	eb 26                	jmp    800a7b <read+0x8d>
	}
	if (!dev->dev_read)
  800a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a58:	8b 40 08             	mov    0x8(%eax),%eax
  800a5b:	85 c0                	test   %eax,%eax
  800a5d:	74 17                	je     800a76 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	ff 75 10             	pushl  0x10(%ebp)
  800a65:	ff 75 0c             	pushl  0xc(%ebp)
  800a68:	52                   	push   %edx
  800a69:	ff d0                	call   *%eax
  800a6b:	89 c2                	mov    %eax,%edx
  800a6d:	83 c4 10             	add    $0x10,%esp
  800a70:	eb 09                	jmp    800a7b <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a72:	89 c2                	mov    %eax,%edx
  800a74:	eb 05                	jmp    800a7b <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a76:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a7b:	89 d0                	mov    %edx,%eax
  800a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a80:	c9                   	leave  
  800a81:	c3                   	ret    

00800a82 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	57                   	push   %edi
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	83 ec 0c             	sub    $0xc,%esp
  800a8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a91:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a96:	eb 21                	jmp    800ab9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a98:	83 ec 04             	sub    $0x4,%esp
  800a9b:	89 f0                	mov    %esi,%eax
  800a9d:	29 d8                	sub    %ebx,%eax
  800a9f:	50                   	push   %eax
  800aa0:	89 d8                	mov    %ebx,%eax
  800aa2:	03 45 0c             	add    0xc(%ebp),%eax
  800aa5:	50                   	push   %eax
  800aa6:	57                   	push   %edi
  800aa7:	e8 42 ff ff ff       	call   8009ee <read>
		if (m < 0)
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	85 c0                	test   %eax,%eax
  800ab1:	78 10                	js     800ac3 <readn+0x41>
			return m;
		if (m == 0)
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	74 0a                	je     800ac1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800ab7:	01 c3                	add    %eax,%ebx
  800ab9:	39 f3                	cmp    %esi,%ebx
  800abb:	72 db                	jb     800a98 <readn+0x16>
  800abd:	89 d8                	mov    %ebx,%eax
  800abf:	eb 02                	jmp    800ac3 <readn+0x41>
  800ac1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800ac3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac6:	5b                   	pop    %ebx
  800ac7:	5e                   	pop    %esi
  800ac8:	5f                   	pop    %edi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	83 ec 14             	sub    $0x14,%esp
  800ad2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ad5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ad8:	50                   	push   %eax
  800ad9:	53                   	push   %ebx
  800ada:	e8 a6 fc ff ff       	call   800785 <fd_lookup>
  800adf:	83 c4 08             	add    $0x8,%esp
  800ae2:	89 c2                	mov    %eax,%edx
  800ae4:	85 c0                	test   %eax,%eax
  800ae6:	78 6b                	js     800b53 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ae8:	83 ec 08             	sub    $0x8,%esp
  800aeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aee:	50                   	push   %eax
  800aef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800af2:	ff 30                	pushl  (%eax)
  800af4:	e8 e2 fc ff ff       	call   8007db <dev_lookup>
  800af9:	83 c4 10             	add    $0x10,%esp
  800afc:	85 c0                	test   %eax,%eax
  800afe:	78 4a                	js     800b4a <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b03:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b07:	75 24                	jne    800b2d <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b09:	a1 04 40 80 00       	mov    0x804004,%eax
  800b0e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800b14:	83 ec 04             	sub    $0x4,%esp
  800b17:	53                   	push   %ebx
  800b18:	50                   	push   %eax
  800b19:	68 51 23 80 00       	push   $0x802351
  800b1e:	e8 c4 09 00 00       	call   8014e7 <cprintf>
		return -E_INVAL;
  800b23:	83 c4 10             	add    $0x10,%esp
  800b26:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b2b:	eb 26                	jmp    800b53 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b30:	8b 52 0c             	mov    0xc(%edx),%edx
  800b33:	85 d2                	test   %edx,%edx
  800b35:	74 17                	je     800b4e <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b37:	83 ec 04             	sub    $0x4,%esp
  800b3a:	ff 75 10             	pushl  0x10(%ebp)
  800b3d:	ff 75 0c             	pushl  0xc(%ebp)
  800b40:	50                   	push   %eax
  800b41:	ff d2                	call   *%edx
  800b43:	89 c2                	mov    %eax,%edx
  800b45:	83 c4 10             	add    $0x10,%esp
  800b48:	eb 09                	jmp    800b53 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	eb 05                	jmp    800b53 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b4e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b53:	89 d0                	mov    %edx,%eax
  800b55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <seek>:

int
seek(int fdnum, off_t offset)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b60:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b63:	50                   	push   %eax
  800b64:	ff 75 08             	pushl  0x8(%ebp)
  800b67:	e8 19 fc ff ff       	call   800785 <fd_lookup>
  800b6c:	83 c4 08             	add    $0x8,%esp
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	78 0e                	js     800b81 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b73:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b79:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	53                   	push   %ebx
  800b87:	83 ec 14             	sub    $0x14,%esp
  800b8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b90:	50                   	push   %eax
  800b91:	53                   	push   %ebx
  800b92:	e8 ee fb ff ff       	call   800785 <fd_lookup>
  800b97:	83 c4 08             	add    $0x8,%esp
  800b9a:	89 c2                	mov    %eax,%edx
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	78 68                	js     800c08 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ba0:	83 ec 08             	sub    $0x8,%esp
  800ba3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ba6:	50                   	push   %eax
  800ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800baa:	ff 30                	pushl  (%eax)
  800bac:	e8 2a fc ff ff       	call   8007db <dev_lookup>
  800bb1:	83 c4 10             	add    $0x10,%esp
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	78 47                	js     800bff <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bbb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800bbf:	75 24                	jne    800be5 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800bc1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800bc6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800bcc:	83 ec 04             	sub    $0x4,%esp
  800bcf:	53                   	push   %ebx
  800bd0:	50                   	push   %eax
  800bd1:	68 14 23 80 00       	push   $0x802314
  800bd6:	e8 0c 09 00 00       	call   8014e7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800bdb:	83 c4 10             	add    $0x10,%esp
  800bde:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800be3:	eb 23                	jmp    800c08 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800be5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800be8:	8b 52 18             	mov    0x18(%edx),%edx
  800beb:	85 d2                	test   %edx,%edx
  800bed:	74 14                	je     800c03 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800bef:	83 ec 08             	sub    $0x8,%esp
  800bf2:	ff 75 0c             	pushl  0xc(%ebp)
  800bf5:	50                   	push   %eax
  800bf6:	ff d2                	call   *%edx
  800bf8:	89 c2                	mov    %eax,%edx
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	eb 09                	jmp    800c08 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bff:	89 c2                	mov    %eax,%edx
  800c01:	eb 05                	jmp    800c08 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c03:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800c08:	89 d0                	mov    %edx,%eax
  800c0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	53                   	push   %ebx
  800c13:	83 ec 14             	sub    $0x14,%esp
  800c16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c1c:	50                   	push   %eax
  800c1d:	ff 75 08             	pushl  0x8(%ebp)
  800c20:	e8 60 fb ff ff       	call   800785 <fd_lookup>
  800c25:	83 c4 08             	add    $0x8,%esp
  800c28:	89 c2                	mov    %eax,%edx
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	78 58                	js     800c86 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c2e:	83 ec 08             	sub    $0x8,%esp
  800c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c34:	50                   	push   %eax
  800c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c38:	ff 30                	pushl  (%eax)
  800c3a:	e8 9c fb ff ff       	call   8007db <dev_lookup>
  800c3f:	83 c4 10             	add    $0x10,%esp
  800c42:	85 c0                	test   %eax,%eax
  800c44:	78 37                	js     800c7d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c49:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c4d:	74 32                	je     800c81 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c4f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c52:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c59:	00 00 00 
	stat->st_isdir = 0;
  800c5c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c63:	00 00 00 
	stat->st_dev = dev;
  800c66:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c6c:	83 ec 08             	sub    $0x8,%esp
  800c6f:	53                   	push   %ebx
  800c70:	ff 75 f0             	pushl  -0x10(%ebp)
  800c73:	ff 50 14             	call   *0x14(%eax)
  800c76:	89 c2                	mov    %eax,%edx
  800c78:	83 c4 10             	add    $0x10,%esp
  800c7b:	eb 09                	jmp    800c86 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c7d:	89 c2                	mov    %eax,%edx
  800c7f:	eb 05                	jmp    800c86 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c81:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c86:	89 d0                	mov    %edx,%eax
  800c88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c8b:	c9                   	leave  
  800c8c:	c3                   	ret    

00800c8d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c92:	83 ec 08             	sub    $0x8,%esp
  800c95:	6a 00                	push   $0x0
  800c97:	ff 75 08             	pushl  0x8(%ebp)
  800c9a:	e8 e3 01 00 00       	call   800e82 <open>
  800c9f:	89 c3                	mov    %eax,%ebx
  800ca1:	83 c4 10             	add    $0x10,%esp
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	78 1b                	js     800cc3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800ca8:	83 ec 08             	sub    $0x8,%esp
  800cab:	ff 75 0c             	pushl  0xc(%ebp)
  800cae:	50                   	push   %eax
  800caf:	e8 5b ff ff ff       	call   800c0f <fstat>
  800cb4:	89 c6                	mov    %eax,%esi
	close(fd);
  800cb6:	89 1c 24             	mov    %ebx,(%esp)
  800cb9:	e8 f4 fb ff ff       	call   8008b2 <close>
	return r;
  800cbe:	83 c4 10             	add    $0x10,%esp
  800cc1:	89 f0                	mov    %esi,%eax
}
  800cc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc6:	5b                   	pop    %ebx
  800cc7:	5e                   	pop    %esi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	89 c6                	mov    %eax,%esi
  800cd1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800cd3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cda:	75 12                	jne    800cee <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	6a 01                	push   $0x1
  800ce1:	e8 39 12 00 00       	call   801f1f <ipc_find_env>
  800ce6:	a3 00 40 80 00       	mov    %eax,0x804000
  800ceb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cee:	6a 07                	push   $0x7
  800cf0:	68 00 50 80 00       	push   $0x805000
  800cf5:	56                   	push   %esi
  800cf6:	ff 35 00 40 80 00    	pushl  0x804000
  800cfc:	e8 bc 11 00 00       	call   801ebd <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d01:	83 c4 0c             	add    $0xc,%esp
  800d04:	6a 00                	push   $0x0
  800d06:	53                   	push   %ebx
  800d07:	6a 00                	push   $0x0
  800d09:	e8 34 11 00 00       	call   801e42 <ipc_recv>
}
  800d0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    

00800d15 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	8b 40 0c             	mov    0xc(%eax),%eax
  800d21:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d29:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d33:	b8 02 00 00 00       	mov    $0x2,%eax
  800d38:	e8 8d ff ff ff       	call   800cca <fsipc>
}
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	8b 40 0c             	mov    0xc(%eax),%eax
  800d4b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d50:	ba 00 00 00 00       	mov    $0x0,%edx
  800d55:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5a:	e8 6b ff ff ff       	call   800cca <fsipc>
}
  800d5f:	c9                   	leave  
  800d60:	c3                   	ret    

00800d61 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	53                   	push   %ebx
  800d65:	83 ec 04             	sub    $0x4,%esp
  800d68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	8b 40 0c             	mov    0xc(%eax),%eax
  800d71:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d76:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d80:	e8 45 ff ff ff       	call   800cca <fsipc>
  800d85:	85 c0                	test   %eax,%eax
  800d87:	78 2c                	js     800db5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d89:	83 ec 08             	sub    $0x8,%esp
  800d8c:	68 00 50 80 00       	push   $0x805000
  800d91:	53                   	push   %ebx
  800d92:	e8 d5 0c 00 00       	call   801a6c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d97:	a1 80 50 80 00       	mov    0x805080,%eax
  800d9c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800da2:	a1 84 50 80 00       	mov    0x805084,%eax
  800da7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800dad:	83 c4 10             	add    $0x10,%esp
  800db0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800db8:	c9                   	leave  
  800db9:	c3                   	ret    

00800dba <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	83 ec 0c             	sub    $0xc,%esp
  800dc0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	8b 52 0c             	mov    0xc(%edx),%edx
  800dc9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800dcf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800dd4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800dd9:	0f 47 c2             	cmova  %edx,%eax
  800ddc:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800de1:	50                   	push   %eax
  800de2:	ff 75 0c             	pushl  0xc(%ebp)
  800de5:	68 08 50 80 00       	push   $0x805008
  800dea:	e8 0f 0e 00 00       	call   801bfe <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800def:	ba 00 00 00 00       	mov    $0x0,%edx
  800df4:	b8 04 00 00 00       	mov    $0x4,%eax
  800df9:	e8 cc fe ff ff       	call   800cca <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    

00800e00 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0b:	8b 40 0c             	mov    0xc(%eax),%eax
  800e0e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e13:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e19:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800e23:	e8 a2 fe ff ff       	call   800cca <fsipc>
  800e28:	89 c3                	mov    %eax,%ebx
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	78 4b                	js     800e79 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e2e:	39 c6                	cmp    %eax,%esi
  800e30:	73 16                	jae    800e48 <devfile_read+0x48>
  800e32:	68 80 23 80 00       	push   $0x802380
  800e37:	68 87 23 80 00       	push   $0x802387
  800e3c:	6a 7c                	push   $0x7c
  800e3e:	68 9c 23 80 00       	push   $0x80239c
  800e43:	e8 c6 05 00 00       	call   80140e <_panic>
	assert(r <= PGSIZE);
  800e48:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e4d:	7e 16                	jle    800e65 <devfile_read+0x65>
  800e4f:	68 a7 23 80 00       	push   $0x8023a7
  800e54:	68 87 23 80 00       	push   $0x802387
  800e59:	6a 7d                	push   $0x7d
  800e5b:	68 9c 23 80 00       	push   $0x80239c
  800e60:	e8 a9 05 00 00       	call   80140e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	50                   	push   %eax
  800e69:	68 00 50 80 00       	push   $0x805000
  800e6e:	ff 75 0c             	pushl  0xc(%ebp)
  800e71:	e8 88 0d 00 00       	call   801bfe <memmove>
	return r;
  800e76:	83 c4 10             	add    $0x10,%esp
}
  800e79:	89 d8                	mov    %ebx,%eax
  800e7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	53                   	push   %ebx
  800e86:	83 ec 20             	sub    $0x20,%esp
  800e89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e8c:	53                   	push   %ebx
  800e8d:	e8 a1 0b 00 00       	call   801a33 <strlen>
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e9a:	7f 67                	jg     800f03 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e9c:	83 ec 0c             	sub    $0xc,%esp
  800e9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea2:	50                   	push   %eax
  800ea3:	e8 8e f8 ff ff       	call   800736 <fd_alloc>
  800ea8:	83 c4 10             	add    $0x10,%esp
		return r;
  800eab:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	78 57                	js     800f08 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	53                   	push   %ebx
  800eb5:	68 00 50 80 00       	push   $0x805000
  800eba:	e8 ad 0b 00 00       	call   801a6c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ec7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eca:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecf:	e8 f6 fd ff ff       	call   800cca <fsipc>
  800ed4:	89 c3                	mov    %eax,%ebx
  800ed6:	83 c4 10             	add    $0x10,%esp
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	79 14                	jns    800ef1 <open+0x6f>
		fd_close(fd, 0);
  800edd:	83 ec 08             	sub    $0x8,%esp
  800ee0:	6a 00                	push   $0x0
  800ee2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ee5:	e8 47 f9 ff ff       	call   800831 <fd_close>
		return r;
  800eea:	83 c4 10             	add    $0x10,%esp
  800eed:	89 da                	mov    %ebx,%edx
  800eef:	eb 17                	jmp    800f08 <open+0x86>
	}

	return fd2num(fd);
  800ef1:	83 ec 0c             	sub    $0xc,%esp
  800ef4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef7:	e8 13 f8 ff ff       	call   80070f <fd2num>
  800efc:	89 c2                	mov    %eax,%edx
  800efe:	83 c4 10             	add    $0x10,%esp
  800f01:	eb 05                	jmp    800f08 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f03:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f08:	89 d0                	mov    %edx,%eax
  800f0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0d:	c9                   	leave  
  800f0e:	c3                   	ret    

00800f0f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f0f:	55                   	push   %ebp
  800f10:	89 e5                	mov    %esp,%ebp
  800f12:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f15:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1a:	b8 08 00 00 00       	mov    $0x8,%eax
  800f1f:	e8 a6 fd ff ff       	call   800cca <fsipc>
}
  800f24:	c9                   	leave  
  800f25:	c3                   	ret    

00800f26 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	56                   	push   %esi
  800f2a:	53                   	push   %ebx
  800f2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	ff 75 08             	pushl  0x8(%ebp)
  800f34:	e8 e6 f7 ff ff       	call   80071f <fd2data>
  800f39:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f3b:	83 c4 08             	add    $0x8,%esp
  800f3e:	68 b3 23 80 00       	push   $0x8023b3
  800f43:	53                   	push   %ebx
  800f44:	e8 23 0b 00 00       	call   801a6c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f49:	8b 46 04             	mov    0x4(%esi),%eax
  800f4c:	2b 06                	sub    (%esi),%eax
  800f4e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f54:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f5b:	00 00 00 
	stat->st_dev = &devpipe;
  800f5e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f65:	30 80 00 
	return 0;
}
  800f68:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5d                   	pop    %ebp
  800f73:	c3                   	ret    

00800f74 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	53                   	push   %ebx
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f7e:	53                   	push   %ebx
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 a3 f2 ff ff       	call   800229 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f86:	89 1c 24             	mov    %ebx,(%esp)
  800f89:	e8 91 f7 ff ff       	call   80071f <fd2data>
  800f8e:	83 c4 08             	add    $0x8,%esp
  800f91:	50                   	push   %eax
  800f92:	6a 00                	push   $0x0
  800f94:	e8 90 f2 ff ff       	call   800229 <sys_page_unmap>
}
  800f99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 1c             	sub    $0x1c,%esp
  800fa7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800faa:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800fac:	a1 04 40 80 00       	mov    0x804004,%eax
  800fb1:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800fb7:	83 ec 0c             	sub    $0xc,%esp
  800fba:	ff 75 e0             	pushl  -0x20(%ebp)
  800fbd:	e8 a2 0f 00 00       	call   801f64 <pageref>
  800fc2:	89 c3                	mov    %eax,%ebx
  800fc4:	89 3c 24             	mov    %edi,(%esp)
  800fc7:	e8 98 0f 00 00       	call   801f64 <pageref>
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	39 c3                	cmp    %eax,%ebx
  800fd1:	0f 94 c1             	sete   %cl
  800fd4:	0f b6 c9             	movzbl %cl,%ecx
  800fd7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800fda:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fe0:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  800fe6:	39 ce                	cmp    %ecx,%esi
  800fe8:	74 1e                	je     801008 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800fea:	39 c3                	cmp    %eax,%ebx
  800fec:	75 be                	jne    800fac <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fee:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  800ff4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff7:	50                   	push   %eax
  800ff8:	56                   	push   %esi
  800ff9:	68 ba 23 80 00       	push   $0x8023ba
  800ffe:	e8 e4 04 00 00       	call   8014e7 <cprintf>
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	eb a4                	jmp    800fac <_pipeisclosed+0xe>
	}
}
  801008:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80100b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5f                   	pop    %edi
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	57                   	push   %edi
  801017:	56                   	push   %esi
  801018:	53                   	push   %ebx
  801019:	83 ec 28             	sub    $0x28,%esp
  80101c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80101f:	56                   	push   %esi
  801020:	e8 fa f6 ff ff       	call   80071f <fd2data>
  801025:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	bf 00 00 00 00       	mov    $0x0,%edi
  80102f:	eb 4b                	jmp    80107c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801031:	89 da                	mov    %ebx,%edx
  801033:	89 f0                	mov    %esi,%eax
  801035:	e8 64 ff ff ff       	call   800f9e <_pipeisclosed>
  80103a:	85 c0                	test   %eax,%eax
  80103c:	75 48                	jne    801086 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80103e:	e8 42 f1 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801043:	8b 43 04             	mov    0x4(%ebx),%eax
  801046:	8b 0b                	mov    (%ebx),%ecx
  801048:	8d 51 20             	lea    0x20(%ecx),%edx
  80104b:	39 d0                	cmp    %edx,%eax
  80104d:	73 e2                	jae    801031 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80104f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801052:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801056:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801059:	89 c2                	mov    %eax,%edx
  80105b:	c1 fa 1f             	sar    $0x1f,%edx
  80105e:	89 d1                	mov    %edx,%ecx
  801060:	c1 e9 1b             	shr    $0x1b,%ecx
  801063:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801066:	83 e2 1f             	and    $0x1f,%edx
  801069:	29 ca                	sub    %ecx,%edx
  80106b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80106f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801073:	83 c0 01             	add    $0x1,%eax
  801076:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801079:	83 c7 01             	add    $0x1,%edi
  80107c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80107f:	75 c2                	jne    801043 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801081:	8b 45 10             	mov    0x10(%ebp),%eax
  801084:	eb 05                	jmp    80108b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801086:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80108b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
  801099:	83 ec 18             	sub    $0x18,%esp
  80109c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80109f:	57                   	push   %edi
  8010a0:	e8 7a f6 ff ff       	call   80071f <fd2data>
  8010a5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010af:	eb 3d                	jmp    8010ee <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8010b1:	85 db                	test   %ebx,%ebx
  8010b3:	74 04                	je     8010b9 <devpipe_read+0x26>
				return i;
  8010b5:	89 d8                	mov    %ebx,%eax
  8010b7:	eb 44                	jmp    8010fd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8010b9:	89 f2                	mov    %esi,%edx
  8010bb:	89 f8                	mov    %edi,%eax
  8010bd:	e8 dc fe ff ff       	call   800f9e <_pipeisclosed>
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	75 32                	jne    8010f8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8010c6:	e8 ba f0 ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010cb:	8b 06                	mov    (%esi),%eax
  8010cd:	3b 46 04             	cmp    0x4(%esi),%eax
  8010d0:	74 df                	je     8010b1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010d2:	99                   	cltd   
  8010d3:	c1 ea 1b             	shr    $0x1b,%edx
  8010d6:	01 d0                	add    %edx,%eax
  8010d8:	83 e0 1f             	and    $0x1f,%eax
  8010db:	29 d0                	sub    %edx,%eax
  8010dd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010e8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010eb:	83 c3 01             	add    $0x1,%ebx
  8010ee:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010f1:	75 d8                	jne    8010cb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f6:	eb 05                	jmp    8010fd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010f8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801100:	5b                   	pop    %ebx
  801101:	5e                   	pop    %esi
  801102:	5f                   	pop    %edi
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	56                   	push   %esi
  801109:	53                   	push   %ebx
  80110a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80110d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	e8 20 f6 ff ff       	call   800736 <fd_alloc>
  801116:	83 c4 10             	add    $0x10,%esp
  801119:	89 c2                	mov    %eax,%edx
  80111b:	85 c0                	test   %eax,%eax
  80111d:	0f 88 2c 01 00 00    	js     80124f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801123:	83 ec 04             	sub    $0x4,%esp
  801126:	68 07 04 00 00       	push   $0x407
  80112b:	ff 75 f4             	pushl  -0xc(%ebp)
  80112e:	6a 00                	push   $0x0
  801130:	e8 6f f0 ff ff       	call   8001a4 <sys_page_alloc>
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	89 c2                	mov    %eax,%edx
  80113a:	85 c0                	test   %eax,%eax
  80113c:	0f 88 0d 01 00 00    	js     80124f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	e8 e8 f5 ff ff       	call   800736 <fd_alloc>
  80114e:	89 c3                	mov    %eax,%ebx
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	0f 88 e2 00 00 00    	js     80123d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80115b:	83 ec 04             	sub    $0x4,%esp
  80115e:	68 07 04 00 00       	push   $0x407
  801163:	ff 75 f0             	pushl  -0x10(%ebp)
  801166:	6a 00                	push   $0x0
  801168:	e8 37 f0 ff ff       	call   8001a4 <sys_page_alloc>
  80116d:	89 c3                	mov    %eax,%ebx
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	85 c0                	test   %eax,%eax
  801174:	0f 88 c3 00 00 00    	js     80123d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	ff 75 f4             	pushl  -0xc(%ebp)
  801180:	e8 9a f5 ff ff       	call   80071f <fd2data>
  801185:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801187:	83 c4 0c             	add    $0xc,%esp
  80118a:	68 07 04 00 00       	push   $0x407
  80118f:	50                   	push   %eax
  801190:	6a 00                	push   $0x0
  801192:	e8 0d f0 ff ff       	call   8001a4 <sys_page_alloc>
  801197:	89 c3                	mov    %eax,%ebx
  801199:	83 c4 10             	add    $0x10,%esp
  80119c:	85 c0                	test   %eax,%eax
  80119e:	0f 88 89 00 00 00    	js     80122d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	ff 75 f0             	pushl  -0x10(%ebp)
  8011aa:	e8 70 f5 ff ff       	call   80071f <fd2data>
  8011af:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8011b6:	50                   	push   %eax
  8011b7:	6a 00                	push   $0x0
  8011b9:	56                   	push   %esi
  8011ba:	6a 00                	push   $0x0
  8011bc:	e8 26 f0 ff ff       	call   8001e7 <sys_page_map>
  8011c1:	89 c3                	mov    %eax,%ebx
  8011c3:	83 c4 20             	add    $0x20,%esp
  8011c6:	85 c0                	test   %eax,%eax
  8011c8:	78 55                	js     80121f <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8011ca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011df:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ed:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011f4:	83 ec 0c             	sub    $0xc,%esp
  8011f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8011fa:	e8 10 f5 ff ff       	call   80070f <fd2num>
  8011ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801202:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801204:	83 c4 04             	add    $0x4,%esp
  801207:	ff 75 f0             	pushl  -0x10(%ebp)
  80120a:	e8 00 f5 ff ff       	call   80070f <fd2num>
  80120f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801212:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	ba 00 00 00 00       	mov    $0x0,%edx
  80121d:	eb 30                	jmp    80124f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	56                   	push   %esi
  801223:	6a 00                	push   $0x0
  801225:	e8 ff ef ff ff       	call   800229 <sys_page_unmap>
  80122a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80122d:	83 ec 08             	sub    $0x8,%esp
  801230:	ff 75 f0             	pushl  -0x10(%ebp)
  801233:	6a 00                	push   $0x0
  801235:	e8 ef ef ff ff       	call   800229 <sys_page_unmap>
  80123a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	ff 75 f4             	pushl  -0xc(%ebp)
  801243:	6a 00                	push   $0x0
  801245:	e8 df ef ff ff       	call   800229 <sys_page_unmap>
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80124f:	89 d0                	mov    %edx,%eax
  801251:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801254:	5b                   	pop    %ebx
  801255:	5e                   	pop    %esi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801261:	50                   	push   %eax
  801262:	ff 75 08             	pushl  0x8(%ebp)
  801265:	e8 1b f5 ff ff       	call   800785 <fd_lookup>
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 18                	js     801289 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801271:	83 ec 0c             	sub    $0xc,%esp
  801274:	ff 75 f4             	pushl  -0xc(%ebp)
  801277:	e8 a3 f4 ff ff       	call   80071f <fd2data>
	return _pipeisclosed(fd, p);
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801281:	e8 18 fd ff ff       	call   800f9e <_pipeisclosed>
  801286:	83 c4 10             	add    $0x10,%esp
}
  801289:	c9                   	leave  
  80128a:	c3                   	ret    

0080128b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80128e:	b8 00 00 00 00       	mov    $0x0,%eax
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80129b:	68 d2 23 80 00       	push   $0x8023d2
  8012a0:	ff 75 0c             	pushl  0xc(%ebp)
  8012a3:	e8 c4 07 00 00       	call   801a6c <strcpy>
	return 0;
}
  8012a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ad:	c9                   	leave  
  8012ae:	c3                   	ret    

008012af <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	57                   	push   %edi
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012bb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012c0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012c6:	eb 2d                	jmp    8012f5 <devcons_write+0x46>
		m = n - tot;
  8012c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012cb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8012cd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012d0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8012d5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012d8:	83 ec 04             	sub    $0x4,%esp
  8012db:	53                   	push   %ebx
  8012dc:	03 45 0c             	add    0xc(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	57                   	push   %edi
  8012e1:	e8 18 09 00 00       	call   801bfe <memmove>
		sys_cputs(buf, m);
  8012e6:	83 c4 08             	add    $0x8,%esp
  8012e9:	53                   	push   %ebx
  8012ea:	57                   	push   %edi
  8012eb:	e8 f8 ed ff ff       	call   8000e8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012f0:	01 de                	add    %ebx,%esi
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	89 f0                	mov    %esi,%eax
  8012f7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012fa:	72 cc                	jb     8012c8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ff:	5b                   	pop    %ebx
  801300:	5e                   	pop    %esi
  801301:	5f                   	pop    %edi
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    

00801304 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	83 ec 08             	sub    $0x8,%esp
  80130a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80130f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801313:	74 2a                	je     80133f <devcons_read+0x3b>
  801315:	eb 05                	jmp    80131c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801317:	e8 69 ee ff ff       	call   800185 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80131c:	e8 e5 ed ff ff       	call   800106 <sys_cgetc>
  801321:	85 c0                	test   %eax,%eax
  801323:	74 f2                	je     801317 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801325:	85 c0                	test   %eax,%eax
  801327:	78 16                	js     80133f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801329:	83 f8 04             	cmp    $0x4,%eax
  80132c:	74 0c                	je     80133a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80132e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801331:	88 02                	mov    %al,(%edx)
	return 1;
  801333:	b8 01 00 00 00       	mov    $0x1,%eax
  801338:	eb 05                	jmp    80133f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80133f:	c9                   	leave  
  801340:	c3                   	ret    

00801341 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801347:	8b 45 08             	mov    0x8(%ebp),%eax
  80134a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80134d:	6a 01                	push   $0x1
  80134f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	e8 90 ed ff ff       	call   8000e8 <sys_cputs>
}
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <getchar>:

int
getchar(void)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801363:	6a 01                	push   $0x1
  801365:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801368:	50                   	push   %eax
  801369:	6a 00                	push   $0x0
  80136b:	e8 7e f6 ff ff       	call   8009ee <read>
	if (r < 0)
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 0f                	js     801386 <getchar+0x29>
		return r;
	if (r < 1)
  801377:	85 c0                	test   %eax,%eax
  801379:	7e 06                	jle    801381 <getchar+0x24>
		return -E_EOF;
	return c;
  80137b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80137f:	eb 05                	jmp    801386 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801381:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801391:	50                   	push   %eax
  801392:	ff 75 08             	pushl  0x8(%ebp)
  801395:	e8 eb f3 ff ff       	call   800785 <fd_lookup>
  80139a:	83 c4 10             	add    $0x10,%esp
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 11                	js     8013b2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8013a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013aa:	39 10                	cmp    %edx,(%eax)
  8013ac:	0f 94 c0             	sete   %al
  8013af:	0f b6 c0             	movzbl %al,%eax
}
  8013b2:	c9                   	leave  
  8013b3:	c3                   	ret    

008013b4 <opencons>:

int
opencons(void)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	e8 73 f3 ff ff       	call   800736 <fd_alloc>
  8013c3:	83 c4 10             	add    $0x10,%esp
		return r;
  8013c6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 3e                	js     80140a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013cc:	83 ec 04             	sub    $0x4,%esp
  8013cf:	68 07 04 00 00       	push   $0x407
  8013d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013d7:	6a 00                	push   $0x0
  8013d9:	e8 c6 ed ff ff       	call   8001a4 <sys_page_alloc>
  8013de:	83 c4 10             	add    $0x10,%esp
		return r;
  8013e1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 23                	js     80140a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013e7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013fc:	83 ec 0c             	sub    $0xc,%esp
  8013ff:	50                   	push   %eax
  801400:	e8 0a f3 ff ff       	call   80070f <fd2num>
  801405:	89 c2                	mov    %eax,%edx
  801407:	83 c4 10             	add    $0x10,%esp
}
  80140a:	89 d0                	mov    %edx,%eax
  80140c:	c9                   	leave  
  80140d:	c3                   	ret    

0080140e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80140e:	55                   	push   %ebp
  80140f:	89 e5                	mov    %esp,%ebp
  801411:	56                   	push   %esi
  801412:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801413:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801416:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80141c:	e8 45 ed ff ff       	call   800166 <sys_getenvid>
  801421:	83 ec 0c             	sub    $0xc,%esp
  801424:	ff 75 0c             	pushl  0xc(%ebp)
  801427:	ff 75 08             	pushl  0x8(%ebp)
  80142a:	56                   	push   %esi
  80142b:	50                   	push   %eax
  80142c:	68 e0 23 80 00       	push   $0x8023e0
  801431:	e8 b1 00 00 00       	call   8014e7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801436:	83 c4 18             	add    $0x18,%esp
  801439:	53                   	push   %ebx
  80143a:	ff 75 10             	pushl  0x10(%ebp)
  80143d:	e8 54 00 00 00       	call   801496 <vcprintf>
	cprintf("\n");
  801442:	c7 04 24 cb 23 80 00 	movl   $0x8023cb,(%esp)
  801449:	e8 99 00 00 00       	call   8014e7 <cprintf>
  80144e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801451:	cc                   	int3   
  801452:	eb fd                	jmp    801451 <_panic+0x43>

00801454 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	53                   	push   %ebx
  801458:	83 ec 04             	sub    $0x4,%esp
  80145b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80145e:	8b 13                	mov    (%ebx),%edx
  801460:	8d 42 01             	lea    0x1(%edx),%eax
  801463:	89 03                	mov    %eax,(%ebx)
  801465:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801468:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80146c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801471:	75 1a                	jne    80148d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	68 ff 00 00 00       	push   $0xff
  80147b:	8d 43 08             	lea    0x8(%ebx),%eax
  80147e:	50                   	push   %eax
  80147f:	e8 64 ec ff ff       	call   8000e8 <sys_cputs>
		b->idx = 0;
  801484:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80148a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80148d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801491:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801494:	c9                   	leave  
  801495:	c3                   	ret    

00801496 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80149f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8014a6:	00 00 00 
	b.cnt = 0;
  8014a9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8014b0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8014b3:	ff 75 0c             	pushl  0xc(%ebp)
  8014b6:	ff 75 08             	pushl  0x8(%ebp)
  8014b9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	68 54 14 80 00       	push   $0x801454
  8014c5:	e8 54 01 00 00       	call   80161e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014ca:	83 c4 08             	add    $0x8,%esp
  8014cd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014d3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014d9:	50                   	push   %eax
  8014da:	e8 09 ec ff ff       	call   8000e8 <sys_cputs>

	return b.cnt;
}
  8014df:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014ed:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014f0:	50                   	push   %eax
  8014f1:	ff 75 08             	pushl  0x8(%ebp)
  8014f4:	e8 9d ff ff ff       	call   801496 <vcprintf>
	va_end(ap);

	return cnt;
}
  8014f9:	c9                   	leave  
  8014fa:	c3                   	ret    

008014fb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	57                   	push   %edi
  8014ff:	56                   	push   %esi
  801500:	53                   	push   %ebx
  801501:	83 ec 1c             	sub    $0x1c,%esp
  801504:	89 c7                	mov    %eax,%edi
  801506:	89 d6                	mov    %edx,%esi
  801508:	8b 45 08             	mov    0x8(%ebp),%eax
  80150b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80150e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801511:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801514:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801517:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80151f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801522:	39 d3                	cmp    %edx,%ebx
  801524:	72 05                	jb     80152b <printnum+0x30>
  801526:	39 45 10             	cmp    %eax,0x10(%ebp)
  801529:	77 45                	ja     801570 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80152b:	83 ec 0c             	sub    $0xc,%esp
  80152e:	ff 75 18             	pushl  0x18(%ebp)
  801531:	8b 45 14             	mov    0x14(%ebp),%eax
  801534:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801537:	53                   	push   %ebx
  801538:	ff 75 10             	pushl  0x10(%ebp)
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801541:	ff 75 e0             	pushl  -0x20(%ebp)
  801544:	ff 75 dc             	pushl  -0x24(%ebp)
  801547:	ff 75 d8             	pushl  -0x28(%ebp)
  80154a:	e8 51 0a 00 00       	call   801fa0 <__udivdi3>
  80154f:	83 c4 18             	add    $0x18,%esp
  801552:	52                   	push   %edx
  801553:	50                   	push   %eax
  801554:	89 f2                	mov    %esi,%edx
  801556:	89 f8                	mov    %edi,%eax
  801558:	e8 9e ff ff ff       	call   8014fb <printnum>
  80155d:	83 c4 20             	add    $0x20,%esp
  801560:	eb 18                	jmp    80157a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801562:	83 ec 08             	sub    $0x8,%esp
  801565:	56                   	push   %esi
  801566:	ff 75 18             	pushl  0x18(%ebp)
  801569:	ff d7                	call   *%edi
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	eb 03                	jmp    801573 <printnum+0x78>
  801570:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801573:	83 eb 01             	sub    $0x1,%ebx
  801576:	85 db                	test   %ebx,%ebx
  801578:	7f e8                	jg     801562 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	56                   	push   %esi
  80157e:	83 ec 04             	sub    $0x4,%esp
  801581:	ff 75 e4             	pushl  -0x1c(%ebp)
  801584:	ff 75 e0             	pushl  -0x20(%ebp)
  801587:	ff 75 dc             	pushl  -0x24(%ebp)
  80158a:	ff 75 d8             	pushl  -0x28(%ebp)
  80158d:	e8 3e 0b 00 00       	call   8020d0 <__umoddi3>
  801592:	83 c4 14             	add    $0x14,%esp
  801595:	0f be 80 03 24 80 00 	movsbl 0x802403(%eax),%eax
  80159c:	50                   	push   %eax
  80159d:	ff d7                	call   *%edi
}
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5e                   	pop    %esi
  8015a7:	5f                   	pop    %edi
  8015a8:	5d                   	pop    %ebp
  8015a9:	c3                   	ret    

008015aa <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8015aa:	55                   	push   %ebp
  8015ab:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8015ad:	83 fa 01             	cmp    $0x1,%edx
  8015b0:	7e 0e                	jle    8015c0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8015b2:	8b 10                	mov    (%eax),%edx
  8015b4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8015b7:	89 08                	mov    %ecx,(%eax)
  8015b9:	8b 02                	mov    (%edx),%eax
  8015bb:	8b 52 04             	mov    0x4(%edx),%edx
  8015be:	eb 22                	jmp    8015e2 <getuint+0x38>
	else if (lflag)
  8015c0:	85 d2                	test   %edx,%edx
  8015c2:	74 10                	je     8015d4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8015c4:	8b 10                	mov    (%eax),%edx
  8015c6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015c9:	89 08                	mov    %ecx,(%eax)
  8015cb:	8b 02                	mov    (%edx),%eax
  8015cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d2:	eb 0e                	jmp    8015e2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015d4:	8b 10                	mov    (%eax),%edx
  8015d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015d9:	89 08                	mov    %ecx,(%eax)
  8015db:	8b 02                	mov    (%edx),%eax
  8015dd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015ea:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015ee:	8b 10                	mov    (%eax),%edx
  8015f0:	3b 50 04             	cmp    0x4(%eax),%edx
  8015f3:	73 0a                	jae    8015ff <sprintputch+0x1b>
		*b->buf++ = ch;
  8015f5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015f8:	89 08                	mov    %ecx,(%eax)
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	88 02                	mov    %al,(%edx)
}
  8015ff:	5d                   	pop    %ebp
  801600:	c3                   	ret    

00801601 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801607:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80160a:	50                   	push   %eax
  80160b:	ff 75 10             	pushl  0x10(%ebp)
  80160e:	ff 75 0c             	pushl  0xc(%ebp)
  801611:	ff 75 08             	pushl  0x8(%ebp)
  801614:	e8 05 00 00 00       	call   80161e <vprintfmt>
	va_end(ap);
}
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	57                   	push   %edi
  801622:	56                   	push   %esi
  801623:	53                   	push   %ebx
  801624:	83 ec 2c             	sub    $0x2c,%esp
  801627:	8b 75 08             	mov    0x8(%ebp),%esi
  80162a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80162d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801630:	eb 12                	jmp    801644 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801632:	85 c0                	test   %eax,%eax
  801634:	0f 84 89 03 00 00    	je     8019c3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80163a:	83 ec 08             	sub    $0x8,%esp
  80163d:	53                   	push   %ebx
  80163e:	50                   	push   %eax
  80163f:	ff d6                	call   *%esi
  801641:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801644:	83 c7 01             	add    $0x1,%edi
  801647:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80164b:	83 f8 25             	cmp    $0x25,%eax
  80164e:	75 e2                	jne    801632 <vprintfmt+0x14>
  801650:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801654:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80165b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801662:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801669:	ba 00 00 00 00       	mov    $0x0,%edx
  80166e:	eb 07                	jmp    801677 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801670:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801673:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801677:	8d 47 01             	lea    0x1(%edi),%eax
  80167a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80167d:	0f b6 07             	movzbl (%edi),%eax
  801680:	0f b6 c8             	movzbl %al,%ecx
  801683:	83 e8 23             	sub    $0x23,%eax
  801686:	3c 55                	cmp    $0x55,%al
  801688:	0f 87 1a 03 00 00    	ja     8019a8 <vprintfmt+0x38a>
  80168e:	0f b6 c0             	movzbl %al,%eax
  801691:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  801698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80169b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80169f:	eb d6                	jmp    801677 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8016ac:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8016af:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8016b3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8016b6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8016b9:	83 fa 09             	cmp    $0x9,%edx
  8016bc:	77 39                	ja     8016f7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8016be:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8016c1:	eb e9                	jmp    8016ac <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8016c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c6:	8d 48 04             	lea    0x4(%eax),%ecx
  8016c9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8016cc:	8b 00                	mov    (%eax),%eax
  8016ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016d4:	eb 27                	jmp    8016fd <vprintfmt+0xdf>
  8016d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016e0:	0f 49 c8             	cmovns %eax,%ecx
  8016e3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016e9:	eb 8c                	jmp    801677 <vprintfmt+0x59>
  8016eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8016ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016f5:	eb 80                	jmp    801677 <vprintfmt+0x59>
  8016f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016fa:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801701:	0f 89 70 ff ff ff    	jns    801677 <vprintfmt+0x59>
				width = precision, precision = -1;
  801707:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80170a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80170d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801714:	e9 5e ff ff ff       	jmp    801677 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801719:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80171f:	e9 53 ff ff ff       	jmp    801677 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801724:	8b 45 14             	mov    0x14(%ebp),%eax
  801727:	8d 50 04             	lea    0x4(%eax),%edx
  80172a:	89 55 14             	mov    %edx,0x14(%ebp)
  80172d:	83 ec 08             	sub    $0x8,%esp
  801730:	53                   	push   %ebx
  801731:	ff 30                	pushl  (%eax)
  801733:	ff d6                	call   *%esi
			break;
  801735:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801738:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80173b:	e9 04 ff ff ff       	jmp    801644 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801740:	8b 45 14             	mov    0x14(%ebp),%eax
  801743:	8d 50 04             	lea    0x4(%eax),%edx
  801746:	89 55 14             	mov    %edx,0x14(%ebp)
  801749:	8b 00                	mov    (%eax),%eax
  80174b:	99                   	cltd   
  80174c:	31 d0                	xor    %edx,%eax
  80174e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801750:	83 f8 0f             	cmp    $0xf,%eax
  801753:	7f 0b                	jg     801760 <vprintfmt+0x142>
  801755:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80175c:	85 d2                	test   %edx,%edx
  80175e:	75 18                	jne    801778 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801760:	50                   	push   %eax
  801761:	68 1b 24 80 00       	push   $0x80241b
  801766:	53                   	push   %ebx
  801767:	56                   	push   %esi
  801768:	e8 94 fe ff ff       	call   801601 <printfmt>
  80176d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801773:	e9 cc fe ff ff       	jmp    801644 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801778:	52                   	push   %edx
  801779:	68 99 23 80 00       	push   $0x802399
  80177e:	53                   	push   %ebx
  80177f:	56                   	push   %esi
  801780:	e8 7c fe ff ff       	call   801601 <printfmt>
  801785:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801788:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80178b:	e9 b4 fe ff ff       	jmp    801644 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801790:	8b 45 14             	mov    0x14(%ebp),%eax
  801793:	8d 50 04             	lea    0x4(%eax),%edx
  801796:	89 55 14             	mov    %edx,0x14(%ebp)
  801799:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80179b:	85 ff                	test   %edi,%edi
  80179d:	b8 14 24 80 00       	mov    $0x802414,%eax
  8017a2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8017a5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017a9:	0f 8e 94 00 00 00    	jle    801843 <vprintfmt+0x225>
  8017af:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8017b3:	0f 84 98 00 00 00    	je     801851 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	ff 75 d0             	pushl  -0x30(%ebp)
  8017bf:	57                   	push   %edi
  8017c0:	e8 86 02 00 00       	call   801a4b <strnlen>
  8017c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017c8:	29 c1                	sub    %eax,%ecx
  8017ca:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8017cd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017d0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017d7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017da:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017dc:	eb 0f                	jmp    8017ed <vprintfmt+0x1cf>
					putch(padc, putdat);
  8017de:	83 ec 08             	sub    $0x8,%esp
  8017e1:	53                   	push   %ebx
  8017e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8017e5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017e7:	83 ef 01             	sub    $0x1,%edi
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 ff                	test   %edi,%edi
  8017ef:	7f ed                	jg     8017de <vprintfmt+0x1c0>
  8017f1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017f4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017f7:	85 c9                	test   %ecx,%ecx
  8017f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fe:	0f 49 c1             	cmovns %ecx,%eax
  801801:	29 c1                	sub    %eax,%ecx
  801803:	89 75 08             	mov    %esi,0x8(%ebp)
  801806:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801809:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80180c:	89 cb                	mov    %ecx,%ebx
  80180e:	eb 4d                	jmp    80185d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801810:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801814:	74 1b                	je     801831 <vprintfmt+0x213>
  801816:	0f be c0             	movsbl %al,%eax
  801819:	83 e8 20             	sub    $0x20,%eax
  80181c:	83 f8 5e             	cmp    $0x5e,%eax
  80181f:	76 10                	jbe    801831 <vprintfmt+0x213>
					putch('?', putdat);
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	ff 75 0c             	pushl  0xc(%ebp)
  801827:	6a 3f                	push   $0x3f
  801829:	ff 55 08             	call   *0x8(%ebp)
  80182c:	83 c4 10             	add    $0x10,%esp
  80182f:	eb 0d                	jmp    80183e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801831:	83 ec 08             	sub    $0x8,%esp
  801834:	ff 75 0c             	pushl  0xc(%ebp)
  801837:	52                   	push   %edx
  801838:	ff 55 08             	call   *0x8(%ebp)
  80183b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80183e:	83 eb 01             	sub    $0x1,%ebx
  801841:	eb 1a                	jmp    80185d <vprintfmt+0x23f>
  801843:	89 75 08             	mov    %esi,0x8(%ebp)
  801846:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801849:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80184c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80184f:	eb 0c                	jmp    80185d <vprintfmt+0x23f>
  801851:	89 75 08             	mov    %esi,0x8(%ebp)
  801854:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801857:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80185a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80185d:	83 c7 01             	add    $0x1,%edi
  801860:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801864:	0f be d0             	movsbl %al,%edx
  801867:	85 d2                	test   %edx,%edx
  801869:	74 23                	je     80188e <vprintfmt+0x270>
  80186b:	85 f6                	test   %esi,%esi
  80186d:	78 a1                	js     801810 <vprintfmt+0x1f2>
  80186f:	83 ee 01             	sub    $0x1,%esi
  801872:	79 9c                	jns    801810 <vprintfmt+0x1f2>
  801874:	89 df                	mov    %ebx,%edi
  801876:	8b 75 08             	mov    0x8(%ebp),%esi
  801879:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80187c:	eb 18                	jmp    801896 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	53                   	push   %ebx
  801882:	6a 20                	push   $0x20
  801884:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801886:	83 ef 01             	sub    $0x1,%edi
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	eb 08                	jmp    801896 <vprintfmt+0x278>
  80188e:	89 df                	mov    %ebx,%edi
  801890:	8b 75 08             	mov    0x8(%ebp),%esi
  801893:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801896:	85 ff                	test   %edi,%edi
  801898:	7f e4                	jg     80187e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80189d:	e9 a2 fd ff ff       	jmp    801644 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8018a2:	83 fa 01             	cmp    $0x1,%edx
  8018a5:	7e 16                	jle    8018bd <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8018a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8018aa:	8d 50 08             	lea    0x8(%eax),%edx
  8018ad:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b0:	8b 50 04             	mov    0x4(%eax),%edx
  8018b3:	8b 00                	mov    (%eax),%eax
  8018b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018b8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018bb:	eb 32                	jmp    8018ef <vprintfmt+0x2d1>
	else if (lflag)
  8018bd:	85 d2                	test   %edx,%edx
  8018bf:	74 18                	je     8018d9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8018c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c4:	8d 50 04             	lea    0x4(%eax),%edx
  8018c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8018ca:	8b 00                	mov    (%eax),%eax
  8018cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018cf:	89 c1                	mov    %eax,%ecx
  8018d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8018d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018d7:	eb 16                	jmp    8018ef <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8018d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8018dc:	8d 50 04             	lea    0x4(%eax),%edx
  8018df:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e2:	8b 00                	mov    (%eax),%eax
  8018e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018e7:	89 c1                	mov    %eax,%ecx
  8018e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8018ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018f2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018f5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018fe:	79 74                	jns    801974 <vprintfmt+0x356>
				putch('-', putdat);
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	53                   	push   %ebx
  801904:	6a 2d                	push   $0x2d
  801906:	ff d6                	call   *%esi
				num = -(long long) num;
  801908:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80190b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80190e:	f7 d8                	neg    %eax
  801910:	83 d2 00             	adc    $0x0,%edx
  801913:	f7 da                	neg    %edx
  801915:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801918:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80191d:	eb 55                	jmp    801974 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80191f:	8d 45 14             	lea    0x14(%ebp),%eax
  801922:	e8 83 fc ff ff       	call   8015aa <getuint>
			base = 10;
  801927:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80192c:	eb 46                	jmp    801974 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80192e:	8d 45 14             	lea    0x14(%ebp),%eax
  801931:	e8 74 fc ff ff       	call   8015aa <getuint>
			base = 8;
  801936:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80193b:	eb 37                	jmp    801974 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80193d:	83 ec 08             	sub    $0x8,%esp
  801940:	53                   	push   %ebx
  801941:	6a 30                	push   $0x30
  801943:	ff d6                	call   *%esi
			putch('x', putdat);
  801945:	83 c4 08             	add    $0x8,%esp
  801948:	53                   	push   %ebx
  801949:	6a 78                	push   $0x78
  80194b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80194d:	8b 45 14             	mov    0x14(%ebp),%eax
  801950:	8d 50 04             	lea    0x4(%eax),%edx
  801953:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801956:	8b 00                	mov    (%eax),%eax
  801958:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80195d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801960:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801965:	eb 0d                	jmp    801974 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801967:	8d 45 14             	lea    0x14(%ebp),%eax
  80196a:	e8 3b fc ff ff       	call   8015aa <getuint>
			base = 16;
  80196f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80197b:	57                   	push   %edi
  80197c:	ff 75 e0             	pushl  -0x20(%ebp)
  80197f:	51                   	push   %ecx
  801980:	52                   	push   %edx
  801981:	50                   	push   %eax
  801982:	89 da                	mov    %ebx,%edx
  801984:	89 f0                	mov    %esi,%eax
  801986:	e8 70 fb ff ff       	call   8014fb <printnum>
			break;
  80198b:	83 c4 20             	add    $0x20,%esp
  80198e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801991:	e9 ae fc ff ff       	jmp    801644 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	53                   	push   %ebx
  80199a:	51                   	push   %ecx
  80199b:	ff d6                	call   *%esi
			break;
  80199d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8019a3:	e9 9c fc ff ff       	jmp    801644 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8019a8:	83 ec 08             	sub    $0x8,%esp
  8019ab:	53                   	push   %ebx
  8019ac:	6a 25                	push   $0x25
  8019ae:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8019b0:	83 c4 10             	add    $0x10,%esp
  8019b3:	eb 03                	jmp    8019b8 <vprintfmt+0x39a>
  8019b5:	83 ef 01             	sub    $0x1,%edi
  8019b8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8019bc:	75 f7                	jne    8019b5 <vprintfmt+0x397>
  8019be:	e9 81 fc ff ff       	jmp    801644 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8019c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019c6:	5b                   	pop    %ebx
  8019c7:	5e                   	pop    %esi
  8019c8:	5f                   	pop    %edi
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    

008019cb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 18             	sub    $0x18,%esp
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	74 26                	je     801a12 <vsnprintf+0x47>
  8019ec:	85 d2                	test   %edx,%edx
  8019ee:	7e 22                	jle    801a12 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019f0:	ff 75 14             	pushl  0x14(%ebp)
  8019f3:	ff 75 10             	pushl  0x10(%ebp)
  8019f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019f9:	50                   	push   %eax
  8019fa:	68 e4 15 80 00       	push   $0x8015e4
  8019ff:	e8 1a fc ff ff       	call   80161e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a07:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	eb 05                	jmp    801a17 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a17:	c9                   	leave  
  801a18:	c3                   	ret    

00801a19 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a1f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a22:	50                   	push   %eax
  801a23:	ff 75 10             	pushl  0x10(%ebp)
  801a26:	ff 75 0c             	pushl  0xc(%ebp)
  801a29:	ff 75 08             	pushl  0x8(%ebp)
  801a2c:	e8 9a ff ff ff       	call   8019cb <vsnprintf>
	va_end(ap);

	return rc;
}
  801a31:	c9                   	leave  
  801a32:	c3                   	ret    

00801a33 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a39:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3e:	eb 03                	jmp    801a43 <strlen+0x10>
		n++;
  801a40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a47:	75 f7                	jne    801a40 <strlen+0xd>
		n++;
	return n;
}
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    

00801a4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a51:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a54:	ba 00 00 00 00       	mov    $0x0,%edx
  801a59:	eb 03                	jmp    801a5e <strnlen+0x13>
		n++;
  801a5b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a5e:	39 c2                	cmp    %eax,%edx
  801a60:	74 08                	je     801a6a <strnlen+0x1f>
  801a62:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a66:	75 f3                	jne    801a5b <strnlen+0x10>
  801a68:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	53                   	push   %ebx
  801a70:	8b 45 08             	mov    0x8(%ebp),%eax
  801a73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a76:	89 c2                	mov    %eax,%edx
  801a78:	83 c2 01             	add    $0x1,%edx
  801a7b:	83 c1 01             	add    $0x1,%ecx
  801a7e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a82:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a85:	84 db                	test   %bl,%bl
  801a87:	75 ef                	jne    801a78 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a89:	5b                   	pop    %ebx
  801a8a:	5d                   	pop    %ebp
  801a8b:	c3                   	ret    

00801a8c <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	53                   	push   %ebx
  801a90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a93:	53                   	push   %ebx
  801a94:	e8 9a ff ff ff       	call   801a33 <strlen>
  801a99:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a9c:	ff 75 0c             	pushl  0xc(%ebp)
  801a9f:	01 d8                	add    %ebx,%eax
  801aa1:	50                   	push   %eax
  801aa2:	e8 c5 ff ff ff       	call   801a6c <strcpy>
	return dst;
}
  801aa7:	89 d8                	mov    %ebx,%eax
  801aa9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aac:	c9                   	leave  
  801aad:	c3                   	ret    

00801aae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
  801ab3:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab9:	89 f3                	mov    %esi,%ebx
  801abb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801abe:	89 f2                	mov    %esi,%edx
  801ac0:	eb 0f                	jmp    801ad1 <strncpy+0x23>
		*dst++ = *src;
  801ac2:	83 c2 01             	add    $0x1,%edx
  801ac5:	0f b6 01             	movzbl (%ecx),%eax
  801ac8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801acb:	80 39 01             	cmpb   $0x1,(%ecx)
  801ace:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ad1:	39 da                	cmp    %ebx,%edx
  801ad3:	75 ed                	jne    801ac2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ad5:	89 f0                	mov    %esi,%eax
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	56                   	push   %esi
  801adf:	53                   	push   %ebx
  801ae0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ae3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae6:	8b 55 10             	mov    0x10(%ebp),%edx
  801ae9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801aeb:	85 d2                	test   %edx,%edx
  801aed:	74 21                	je     801b10 <strlcpy+0x35>
  801aef:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801af3:	89 f2                	mov    %esi,%edx
  801af5:	eb 09                	jmp    801b00 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801af7:	83 c2 01             	add    $0x1,%edx
  801afa:	83 c1 01             	add    $0x1,%ecx
  801afd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b00:	39 c2                	cmp    %eax,%edx
  801b02:	74 09                	je     801b0d <strlcpy+0x32>
  801b04:	0f b6 19             	movzbl (%ecx),%ebx
  801b07:	84 db                	test   %bl,%bl
  801b09:	75 ec                	jne    801af7 <strlcpy+0x1c>
  801b0b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801b0d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801b10:	29 f0                	sub    %esi,%eax
}
  801b12:	5b                   	pop    %ebx
  801b13:	5e                   	pop    %esi
  801b14:	5d                   	pop    %ebp
  801b15:	c3                   	ret    

00801b16 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801b1f:	eb 06                	jmp    801b27 <strcmp+0x11>
		p++, q++;
  801b21:	83 c1 01             	add    $0x1,%ecx
  801b24:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b27:	0f b6 01             	movzbl (%ecx),%eax
  801b2a:	84 c0                	test   %al,%al
  801b2c:	74 04                	je     801b32 <strcmp+0x1c>
  801b2e:	3a 02                	cmp    (%edx),%al
  801b30:	74 ef                	je     801b21 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b32:	0f b6 c0             	movzbl %al,%eax
  801b35:	0f b6 12             	movzbl (%edx),%edx
  801b38:	29 d0                	sub    %edx,%eax
}
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    

00801b3c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	53                   	push   %ebx
  801b40:	8b 45 08             	mov    0x8(%ebp),%eax
  801b43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b46:	89 c3                	mov    %eax,%ebx
  801b48:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b4b:	eb 06                	jmp    801b53 <strncmp+0x17>
		n--, p++, q++;
  801b4d:	83 c0 01             	add    $0x1,%eax
  801b50:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b53:	39 d8                	cmp    %ebx,%eax
  801b55:	74 15                	je     801b6c <strncmp+0x30>
  801b57:	0f b6 08             	movzbl (%eax),%ecx
  801b5a:	84 c9                	test   %cl,%cl
  801b5c:	74 04                	je     801b62 <strncmp+0x26>
  801b5e:	3a 0a                	cmp    (%edx),%cl
  801b60:	74 eb                	je     801b4d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b62:	0f b6 00             	movzbl (%eax),%eax
  801b65:	0f b6 12             	movzbl (%edx),%edx
  801b68:	29 d0                	sub    %edx,%eax
  801b6a:	eb 05                	jmp    801b71 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b6c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b71:	5b                   	pop    %ebx
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    

00801b74 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b7e:	eb 07                	jmp    801b87 <strchr+0x13>
		if (*s == c)
  801b80:	38 ca                	cmp    %cl,%dl
  801b82:	74 0f                	je     801b93 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b84:	83 c0 01             	add    $0x1,%eax
  801b87:	0f b6 10             	movzbl (%eax),%edx
  801b8a:	84 d2                	test   %dl,%dl
  801b8c:	75 f2                	jne    801b80 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b9f:	eb 03                	jmp    801ba4 <strfind+0xf>
  801ba1:	83 c0 01             	add    $0x1,%eax
  801ba4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801ba7:	38 ca                	cmp    %cl,%dl
  801ba9:	74 04                	je     801baf <strfind+0x1a>
  801bab:	84 d2                	test   %dl,%dl
  801bad:	75 f2                	jne    801ba1 <strfind+0xc>
			break;
	return (char *) s;
}
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    

00801bb1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	57                   	push   %edi
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bba:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801bbd:	85 c9                	test   %ecx,%ecx
  801bbf:	74 36                	je     801bf7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801bc1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801bc7:	75 28                	jne    801bf1 <memset+0x40>
  801bc9:	f6 c1 03             	test   $0x3,%cl
  801bcc:	75 23                	jne    801bf1 <memset+0x40>
		c &= 0xFF;
  801bce:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801bd2:	89 d3                	mov    %edx,%ebx
  801bd4:	c1 e3 08             	shl    $0x8,%ebx
  801bd7:	89 d6                	mov    %edx,%esi
  801bd9:	c1 e6 18             	shl    $0x18,%esi
  801bdc:	89 d0                	mov    %edx,%eax
  801bde:	c1 e0 10             	shl    $0x10,%eax
  801be1:	09 f0                	or     %esi,%eax
  801be3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801be5:	89 d8                	mov    %ebx,%eax
  801be7:	09 d0                	or     %edx,%eax
  801be9:	c1 e9 02             	shr    $0x2,%ecx
  801bec:	fc                   	cld    
  801bed:	f3 ab                	rep stos %eax,%es:(%edi)
  801bef:	eb 06                	jmp    801bf7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf4:	fc                   	cld    
  801bf5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bf7:	89 f8                	mov    %edi,%eax
  801bf9:	5b                   	pop    %ebx
  801bfa:	5e                   	pop    %esi
  801bfb:	5f                   	pop    %edi
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    

00801bfe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	57                   	push   %edi
  801c02:	56                   	push   %esi
  801c03:	8b 45 08             	mov    0x8(%ebp),%eax
  801c06:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c09:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801c0c:	39 c6                	cmp    %eax,%esi
  801c0e:	73 35                	jae    801c45 <memmove+0x47>
  801c10:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801c13:	39 d0                	cmp    %edx,%eax
  801c15:	73 2e                	jae    801c45 <memmove+0x47>
		s += n;
		d += n;
  801c17:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c1a:	89 d6                	mov    %edx,%esi
  801c1c:	09 fe                	or     %edi,%esi
  801c1e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c24:	75 13                	jne    801c39 <memmove+0x3b>
  801c26:	f6 c1 03             	test   $0x3,%cl
  801c29:	75 0e                	jne    801c39 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801c2b:	83 ef 04             	sub    $0x4,%edi
  801c2e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c31:	c1 e9 02             	shr    $0x2,%ecx
  801c34:	fd                   	std    
  801c35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c37:	eb 09                	jmp    801c42 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c39:	83 ef 01             	sub    $0x1,%edi
  801c3c:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c3f:	fd                   	std    
  801c40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c42:	fc                   	cld    
  801c43:	eb 1d                	jmp    801c62 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c45:	89 f2                	mov    %esi,%edx
  801c47:	09 c2                	or     %eax,%edx
  801c49:	f6 c2 03             	test   $0x3,%dl
  801c4c:	75 0f                	jne    801c5d <memmove+0x5f>
  801c4e:	f6 c1 03             	test   $0x3,%cl
  801c51:	75 0a                	jne    801c5d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c53:	c1 e9 02             	shr    $0x2,%ecx
  801c56:	89 c7                	mov    %eax,%edi
  801c58:	fc                   	cld    
  801c59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c5b:	eb 05                	jmp    801c62 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c5d:	89 c7                	mov    %eax,%edi
  801c5f:	fc                   	cld    
  801c60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c62:	5e                   	pop    %esi
  801c63:	5f                   	pop    %edi
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c69:	ff 75 10             	pushl  0x10(%ebp)
  801c6c:	ff 75 0c             	pushl  0xc(%ebp)
  801c6f:	ff 75 08             	pushl  0x8(%ebp)
  801c72:	e8 87 ff ff ff       	call   801bfe <memmove>
}
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	56                   	push   %esi
  801c7d:	53                   	push   %ebx
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c84:	89 c6                	mov    %eax,%esi
  801c86:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c89:	eb 1a                	jmp    801ca5 <memcmp+0x2c>
		if (*s1 != *s2)
  801c8b:	0f b6 08             	movzbl (%eax),%ecx
  801c8e:	0f b6 1a             	movzbl (%edx),%ebx
  801c91:	38 d9                	cmp    %bl,%cl
  801c93:	74 0a                	je     801c9f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c95:	0f b6 c1             	movzbl %cl,%eax
  801c98:	0f b6 db             	movzbl %bl,%ebx
  801c9b:	29 d8                	sub    %ebx,%eax
  801c9d:	eb 0f                	jmp    801cae <memcmp+0x35>
		s1++, s2++;
  801c9f:	83 c0 01             	add    $0x1,%eax
  801ca2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ca5:	39 f0                	cmp    %esi,%eax
  801ca7:	75 e2                	jne    801c8b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ca9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cae:	5b                   	pop    %ebx
  801caf:	5e                   	pop    %esi
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    

00801cb2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	53                   	push   %ebx
  801cb6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801cb9:	89 c1                	mov    %eax,%ecx
  801cbb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801cbe:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801cc2:	eb 0a                	jmp    801cce <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801cc4:	0f b6 10             	movzbl (%eax),%edx
  801cc7:	39 da                	cmp    %ebx,%edx
  801cc9:	74 07                	je     801cd2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ccb:	83 c0 01             	add    $0x1,%eax
  801cce:	39 c8                	cmp    %ecx,%eax
  801cd0:	72 f2                	jb     801cc4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801cd2:	5b                   	pop    %ebx
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	57                   	push   %edi
  801cd9:	56                   	push   %esi
  801cda:	53                   	push   %ebx
  801cdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ce1:	eb 03                	jmp    801ce6 <strtol+0x11>
		s++;
  801ce3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ce6:	0f b6 01             	movzbl (%ecx),%eax
  801ce9:	3c 20                	cmp    $0x20,%al
  801ceb:	74 f6                	je     801ce3 <strtol+0xe>
  801ced:	3c 09                	cmp    $0x9,%al
  801cef:	74 f2                	je     801ce3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801cf1:	3c 2b                	cmp    $0x2b,%al
  801cf3:	75 0a                	jne    801cff <strtol+0x2a>
		s++;
  801cf5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801cf8:	bf 00 00 00 00       	mov    $0x0,%edi
  801cfd:	eb 11                	jmp    801d10 <strtol+0x3b>
  801cff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801d04:	3c 2d                	cmp    $0x2d,%al
  801d06:	75 08                	jne    801d10 <strtol+0x3b>
		s++, neg = 1;
  801d08:	83 c1 01             	add    $0x1,%ecx
  801d0b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801d10:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801d16:	75 15                	jne    801d2d <strtol+0x58>
  801d18:	80 39 30             	cmpb   $0x30,(%ecx)
  801d1b:	75 10                	jne    801d2d <strtol+0x58>
  801d1d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801d21:	75 7c                	jne    801d9f <strtol+0xca>
		s += 2, base = 16;
  801d23:	83 c1 02             	add    $0x2,%ecx
  801d26:	bb 10 00 00 00       	mov    $0x10,%ebx
  801d2b:	eb 16                	jmp    801d43 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801d2d:	85 db                	test   %ebx,%ebx
  801d2f:	75 12                	jne    801d43 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d31:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d36:	80 39 30             	cmpb   $0x30,(%ecx)
  801d39:	75 08                	jne    801d43 <strtol+0x6e>
		s++, base = 8;
  801d3b:	83 c1 01             	add    $0x1,%ecx
  801d3e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d43:	b8 00 00 00 00       	mov    $0x0,%eax
  801d48:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d4b:	0f b6 11             	movzbl (%ecx),%edx
  801d4e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d51:	89 f3                	mov    %esi,%ebx
  801d53:	80 fb 09             	cmp    $0x9,%bl
  801d56:	77 08                	ja     801d60 <strtol+0x8b>
			dig = *s - '0';
  801d58:	0f be d2             	movsbl %dl,%edx
  801d5b:	83 ea 30             	sub    $0x30,%edx
  801d5e:	eb 22                	jmp    801d82 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d60:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d63:	89 f3                	mov    %esi,%ebx
  801d65:	80 fb 19             	cmp    $0x19,%bl
  801d68:	77 08                	ja     801d72 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d6a:	0f be d2             	movsbl %dl,%edx
  801d6d:	83 ea 57             	sub    $0x57,%edx
  801d70:	eb 10                	jmp    801d82 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d72:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d75:	89 f3                	mov    %esi,%ebx
  801d77:	80 fb 19             	cmp    $0x19,%bl
  801d7a:	77 16                	ja     801d92 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d7c:	0f be d2             	movsbl %dl,%edx
  801d7f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d82:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d85:	7d 0b                	jge    801d92 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d87:	83 c1 01             	add    $0x1,%ecx
  801d8a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d8e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d90:	eb b9                	jmp    801d4b <strtol+0x76>

	if (endptr)
  801d92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d96:	74 0d                	je     801da5 <strtol+0xd0>
		*endptr = (char *) s;
  801d98:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d9b:	89 0e                	mov    %ecx,(%esi)
  801d9d:	eb 06                	jmp    801da5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d9f:	85 db                	test   %ebx,%ebx
  801da1:	74 98                	je     801d3b <strtol+0x66>
  801da3:	eb 9e                	jmp    801d43 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801da5:	89 c2                	mov    %eax,%edx
  801da7:	f7 da                	neg    %edx
  801da9:	85 ff                	test   %edi,%edi
  801dab:	0f 45 c2             	cmovne %edx,%eax
}
  801dae:	5b                   	pop    %ebx
  801daf:	5e                   	pop    %esi
  801db0:	5f                   	pop    %edi
  801db1:	5d                   	pop    %ebp
  801db2:	c3                   	ret    

00801db3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801db3:	55                   	push   %ebp
  801db4:	89 e5                	mov    %esp,%ebp
  801db6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801db9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dc0:	75 2a                	jne    801dec <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801dc2:	83 ec 04             	sub    $0x4,%esp
  801dc5:	6a 07                	push   $0x7
  801dc7:	68 00 f0 bf ee       	push   $0xeebff000
  801dcc:	6a 00                	push   $0x0
  801dce:	e8 d1 e3 ff ff       	call   8001a4 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	85 c0                	test   %eax,%eax
  801dd8:	79 12                	jns    801dec <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801dda:	50                   	push   %eax
  801ddb:	68 00 27 80 00       	push   $0x802700
  801de0:	6a 23                	push   $0x23
  801de2:	68 04 27 80 00       	push   $0x802704
  801de7:	e8 22 f6 ff ff       	call   80140e <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801df4:	83 ec 08             	sub    $0x8,%esp
  801df7:	68 1e 1e 80 00       	push   $0x801e1e
  801dfc:	6a 00                	push   $0x0
  801dfe:	e8 ec e4 ff ff       	call   8002ef <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e03:	83 c4 10             	add    $0x10,%esp
  801e06:	85 c0                	test   %eax,%eax
  801e08:	79 12                	jns    801e1c <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e0a:	50                   	push   %eax
  801e0b:	68 00 27 80 00       	push   $0x802700
  801e10:	6a 2c                	push   $0x2c
  801e12:	68 04 27 80 00       	push   $0x802704
  801e17:	e8 f2 f5 ff ff       	call   80140e <_panic>
	}
}
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e1e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e1f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e24:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e26:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801e29:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e2d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e32:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e36:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e38:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e3b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e3c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e3f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e40:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e41:	c3                   	ret    

00801e42 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	56                   	push   %esi
  801e46:	53                   	push   %ebx
  801e47:	8b 75 08             	mov    0x8(%ebp),%esi
  801e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e50:	85 c0                	test   %eax,%eax
  801e52:	75 12                	jne    801e66 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e54:	83 ec 0c             	sub    $0xc,%esp
  801e57:	68 00 00 c0 ee       	push   $0xeec00000
  801e5c:	e8 f3 e4 ff ff       	call   800354 <sys_ipc_recv>
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	eb 0c                	jmp    801e72 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e66:	83 ec 0c             	sub    $0xc,%esp
  801e69:	50                   	push   %eax
  801e6a:	e8 e5 e4 ff ff       	call   800354 <sys_ipc_recv>
  801e6f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e72:	85 f6                	test   %esi,%esi
  801e74:	0f 95 c1             	setne  %cl
  801e77:	85 db                	test   %ebx,%ebx
  801e79:	0f 95 c2             	setne  %dl
  801e7c:	84 d1                	test   %dl,%cl
  801e7e:	74 09                	je     801e89 <ipc_recv+0x47>
  801e80:	89 c2                	mov    %eax,%edx
  801e82:	c1 ea 1f             	shr    $0x1f,%edx
  801e85:	84 d2                	test   %dl,%dl
  801e87:	75 2d                	jne    801eb6 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e89:	85 f6                	test   %esi,%esi
  801e8b:	74 0d                	je     801e9a <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e8d:	a1 04 40 80 00       	mov    0x804004,%eax
  801e92:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801e98:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e9a:	85 db                	test   %ebx,%ebx
  801e9c:	74 0d                	je     801eab <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801ea3:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801ea9:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801eab:	a1 04 40 80 00       	mov    0x804004,%eax
  801eb0:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801eb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb9:	5b                   	pop    %ebx
  801eba:	5e                   	pop    %esi
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    

00801ebd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ebd:	55                   	push   %ebp
  801ebe:	89 e5                	mov    %esp,%ebp
  801ec0:	57                   	push   %edi
  801ec1:	56                   	push   %esi
  801ec2:	53                   	push   %ebx
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ecc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ecf:	85 db                	test   %ebx,%ebx
  801ed1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ed6:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ed9:	ff 75 14             	pushl  0x14(%ebp)
  801edc:	53                   	push   %ebx
  801edd:	56                   	push   %esi
  801ede:	57                   	push   %edi
  801edf:	e8 4d e4 ff ff       	call   800331 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ee4:	89 c2                	mov    %eax,%edx
  801ee6:	c1 ea 1f             	shr    $0x1f,%edx
  801ee9:	83 c4 10             	add    $0x10,%esp
  801eec:	84 d2                	test   %dl,%dl
  801eee:	74 17                	je     801f07 <ipc_send+0x4a>
  801ef0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef3:	74 12                	je     801f07 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ef5:	50                   	push   %eax
  801ef6:	68 12 27 80 00       	push   $0x802712
  801efb:	6a 47                	push   $0x47
  801efd:	68 20 27 80 00       	push   $0x802720
  801f02:	e8 07 f5 ff ff       	call   80140e <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801f07:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f0a:	75 07                	jne    801f13 <ipc_send+0x56>
			sys_yield();
  801f0c:	e8 74 e2 ff ff       	call   800185 <sys_yield>
  801f11:	eb c6                	jmp    801ed9 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f13:	85 c0                	test   %eax,%eax
  801f15:	75 c2                	jne    801ed9 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5f                   	pop    %edi
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f25:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f2a:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f30:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f36:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f3c:	39 ca                	cmp    %ecx,%edx
  801f3e:	75 13                	jne    801f53 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f40:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f46:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f4b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f51:	eb 0f                	jmp    801f62 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f53:	83 c0 01             	add    $0x1,%eax
  801f56:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f5b:	75 cd                	jne    801f2a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    

00801f64 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6a:	89 d0                	mov    %edx,%eax
  801f6c:	c1 e8 16             	shr    $0x16,%eax
  801f6f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f76:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7b:	f6 c1 01             	test   $0x1,%cl
  801f7e:	74 1d                	je     801f9d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f80:	c1 ea 0c             	shr    $0xc,%edx
  801f83:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f8a:	f6 c2 01             	test   $0x1,%dl
  801f8d:	74 0e                	je     801f9d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f8f:	c1 ea 0c             	shr    $0xc,%edx
  801f92:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f99:	ef 
  801f9a:	0f b7 c0             	movzwl %ax,%eax
}
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    
  801f9f:	90                   	nop

00801fa0 <__udivdi3>:
  801fa0:	55                   	push   %ebp
  801fa1:	57                   	push   %edi
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 1c             	sub    $0x1c,%esp
  801fa7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801faf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fb7:	85 f6                	test   %esi,%esi
  801fb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbd:	89 ca                	mov    %ecx,%edx
  801fbf:	89 f8                	mov    %edi,%eax
  801fc1:	75 3d                	jne    802000 <__udivdi3+0x60>
  801fc3:	39 cf                	cmp    %ecx,%edi
  801fc5:	0f 87 c5 00 00 00    	ja     802090 <__udivdi3+0xf0>
  801fcb:	85 ff                	test   %edi,%edi
  801fcd:	89 fd                	mov    %edi,%ebp
  801fcf:	75 0b                	jne    801fdc <__udivdi3+0x3c>
  801fd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd6:	31 d2                	xor    %edx,%edx
  801fd8:	f7 f7                	div    %edi
  801fda:	89 c5                	mov    %eax,%ebp
  801fdc:	89 c8                	mov    %ecx,%eax
  801fde:	31 d2                	xor    %edx,%edx
  801fe0:	f7 f5                	div    %ebp
  801fe2:	89 c1                	mov    %eax,%ecx
  801fe4:	89 d8                	mov    %ebx,%eax
  801fe6:	89 cf                	mov    %ecx,%edi
  801fe8:	f7 f5                	div    %ebp
  801fea:	89 c3                	mov    %eax,%ebx
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
  802000:	39 ce                	cmp    %ecx,%esi
  802002:	77 74                	ja     802078 <__udivdi3+0xd8>
  802004:	0f bd fe             	bsr    %esi,%edi
  802007:	83 f7 1f             	xor    $0x1f,%edi
  80200a:	0f 84 98 00 00 00    	je     8020a8 <__udivdi3+0x108>
  802010:	bb 20 00 00 00       	mov    $0x20,%ebx
  802015:	89 f9                	mov    %edi,%ecx
  802017:	89 c5                	mov    %eax,%ebp
  802019:	29 fb                	sub    %edi,%ebx
  80201b:	d3 e6                	shl    %cl,%esi
  80201d:	89 d9                	mov    %ebx,%ecx
  80201f:	d3 ed                	shr    %cl,%ebp
  802021:	89 f9                	mov    %edi,%ecx
  802023:	d3 e0                	shl    %cl,%eax
  802025:	09 ee                	or     %ebp,%esi
  802027:	89 d9                	mov    %ebx,%ecx
  802029:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80202d:	89 d5                	mov    %edx,%ebp
  80202f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802033:	d3 ed                	shr    %cl,%ebp
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e2                	shl    %cl,%edx
  802039:	89 d9                	mov    %ebx,%ecx
  80203b:	d3 e8                	shr    %cl,%eax
  80203d:	09 c2                	or     %eax,%edx
  80203f:	89 d0                	mov    %edx,%eax
  802041:	89 ea                	mov    %ebp,%edx
  802043:	f7 f6                	div    %esi
  802045:	89 d5                	mov    %edx,%ebp
  802047:	89 c3                	mov    %eax,%ebx
  802049:	f7 64 24 0c          	mull   0xc(%esp)
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	72 10                	jb     802061 <__udivdi3+0xc1>
  802051:	8b 74 24 08          	mov    0x8(%esp),%esi
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e6                	shl    %cl,%esi
  802059:	39 c6                	cmp    %eax,%esi
  80205b:	73 07                	jae    802064 <__udivdi3+0xc4>
  80205d:	39 d5                	cmp    %edx,%ebp
  80205f:	75 03                	jne    802064 <__udivdi3+0xc4>
  802061:	83 eb 01             	sub    $0x1,%ebx
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 d8                	mov    %ebx,%eax
  802068:	89 fa                	mov    %edi,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	31 ff                	xor    %edi,%edi
  80207a:	31 db                	xor    %ebx,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d8                	mov    %ebx,%eax
  802092:	f7 f7                	div    %edi
  802094:	31 ff                	xor    %edi,%edi
  802096:	89 c3                	mov    %eax,%ebx
  802098:	89 d8                	mov    %ebx,%eax
  80209a:	89 fa                	mov    %edi,%edx
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    
  8020a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a8:	39 ce                	cmp    %ecx,%esi
  8020aa:	72 0c                	jb     8020b8 <__udivdi3+0x118>
  8020ac:	31 db                	xor    %ebx,%ebx
  8020ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020b2:	0f 87 34 ff ff ff    	ja     801fec <__udivdi3+0x4c>
  8020b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020bd:	e9 2a ff ff ff       	jmp    801fec <__udivdi3+0x4c>
  8020c2:	66 90                	xchg   %ax,%ax
  8020c4:	66 90                	xchg   %ax,%ax
  8020c6:	66 90                	xchg   %ax,%ax
  8020c8:	66 90                	xchg   %ax,%ax
  8020ca:	66 90                	xchg   %ax,%ax
  8020cc:	66 90                	xchg   %ax,%ax
  8020ce:	66 90                	xchg   %ax,%ax

008020d0 <__umoddi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 d2                	test   %edx,%edx
  8020e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f3                	mov    %esi,%ebx
  8020f3:	89 3c 24             	mov    %edi,(%esp)
  8020f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020fa:	75 1c                	jne    802118 <__umoddi3+0x48>
  8020fc:	39 f7                	cmp    %esi,%edi
  8020fe:	76 50                	jbe    802150 <__umoddi3+0x80>
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	f7 f7                	div    %edi
  802106:	89 d0                	mov    %edx,%eax
  802108:	31 d2                	xor    %edx,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	39 f2                	cmp    %esi,%edx
  80211a:	89 d0                	mov    %edx,%eax
  80211c:	77 52                	ja     802170 <__umoddi3+0xa0>
  80211e:	0f bd ea             	bsr    %edx,%ebp
  802121:	83 f5 1f             	xor    $0x1f,%ebp
  802124:	75 5a                	jne    802180 <__umoddi3+0xb0>
  802126:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80212a:	0f 82 e0 00 00 00    	jb     802210 <__umoddi3+0x140>
  802130:	39 0c 24             	cmp    %ecx,(%esp)
  802133:	0f 86 d7 00 00 00    	jbe    802210 <__umoddi3+0x140>
  802139:	8b 44 24 08          	mov    0x8(%esp),%eax
  80213d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	85 ff                	test   %edi,%edi
  802152:	89 fd                	mov    %edi,%ebp
  802154:	75 0b                	jne    802161 <__umoddi3+0x91>
  802156:	b8 01 00 00 00       	mov    $0x1,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	f7 f7                	div    %edi
  80215f:	89 c5                	mov    %eax,%ebp
  802161:	89 f0                	mov    %esi,%eax
  802163:	31 d2                	xor    %edx,%edx
  802165:	f7 f5                	div    %ebp
  802167:	89 c8                	mov    %ecx,%eax
  802169:	f7 f5                	div    %ebp
  80216b:	89 d0                	mov    %edx,%eax
  80216d:	eb 99                	jmp    802108 <__umoddi3+0x38>
  80216f:	90                   	nop
  802170:	89 c8                	mov    %ecx,%eax
  802172:	89 f2                	mov    %esi,%edx
  802174:	83 c4 1c             	add    $0x1c,%esp
  802177:	5b                   	pop    %ebx
  802178:	5e                   	pop    %esi
  802179:	5f                   	pop    %edi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    
  80217c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802180:	8b 34 24             	mov    (%esp),%esi
  802183:	bf 20 00 00 00       	mov    $0x20,%edi
  802188:	89 e9                	mov    %ebp,%ecx
  80218a:	29 ef                	sub    %ebp,%edi
  80218c:	d3 e0                	shl    %cl,%eax
  80218e:	89 f9                	mov    %edi,%ecx
  802190:	89 f2                	mov    %esi,%edx
  802192:	d3 ea                	shr    %cl,%edx
  802194:	89 e9                	mov    %ebp,%ecx
  802196:	09 c2                	or     %eax,%edx
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	89 14 24             	mov    %edx,(%esp)
  80219d:	89 f2                	mov    %esi,%edx
  80219f:	d3 e2                	shl    %cl,%edx
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	89 e9                	mov    %ebp,%ecx
  8021af:	89 c6                	mov    %eax,%esi
  8021b1:	d3 e3                	shl    %cl,%ebx
  8021b3:	89 f9                	mov    %edi,%ecx
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	d3 e8                	shr    %cl,%eax
  8021b9:	89 e9                	mov    %ebp,%ecx
  8021bb:	09 d8                	or     %ebx,%eax
  8021bd:	89 d3                	mov    %edx,%ebx
  8021bf:	89 f2                	mov    %esi,%edx
  8021c1:	f7 34 24             	divl   (%esp)
  8021c4:	89 d6                	mov    %edx,%esi
  8021c6:	d3 e3                	shl    %cl,%ebx
  8021c8:	f7 64 24 04          	mull   0x4(%esp)
  8021cc:	39 d6                	cmp    %edx,%esi
  8021ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d2:	89 d1                	mov    %edx,%ecx
  8021d4:	89 c3                	mov    %eax,%ebx
  8021d6:	72 08                	jb     8021e0 <__umoddi3+0x110>
  8021d8:	75 11                	jne    8021eb <__umoddi3+0x11b>
  8021da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021de:	73 0b                	jae    8021eb <__umoddi3+0x11b>
  8021e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021e4:	1b 14 24             	sbb    (%esp),%edx
  8021e7:	89 d1                	mov    %edx,%ecx
  8021e9:	89 c3                	mov    %eax,%ebx
  8021eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021ef:	29 da                	sub    %ebx,%edx
  8021f1:	19 ce                	sbb    %ecx,%esi
  8021f3:	89 f9                	mov    %edi,%ecx
  8021f5:	89 f0                	mov    %esi,%eax
  8021f7:	d3 e0                	shl    %cl,%eax
  8021f9:	89 e9                	mov    %ebp,%ecx
  8021fb:	d3 ea                	shr    %cl,%edx
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	d3 ee                	shr    %cl,%esi
  802201:	09 d0                	or     %edx,%eax
  802203:	89 f2                	mov    %esi,%edx
  802205:	83 c4 1c             	add    $0x1c,%esp
  802208:	5b                   	pop    %ebx
  802209:	5e                   	pop    %esi
  80220a:	5f                   	pop    %edi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    
  80220d:	8d 76 00             	lea    0x0(%esi),%esi
  802210:	29 f9                	sub    %edi,%ecx
  802212:	19 d6                	sbb    %edx,%esi
  802214:	89 74 24 04          	mov    %esi,0x4(%esp)
  802218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80221c:	e9 18 ff ff ff       	jmp    802139 <__umoddi3+0x69>
