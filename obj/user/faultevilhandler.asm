
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
  80007a:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 04 40 80 00       	mov    %eax,0x804004

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
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	83 ec 08             	sub    $0x8,%esp
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
  8000d4:	e8 e8 09 00 00       	call   800ac1 <close_all>
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
  80014d:	68 2a 24 80 00       	push   $0x80242a
  800152:	6a 23                	push   $0x23
  800154:	68 47 24 80 00       	push   $0x802447
  800159:	e8 94 14 00 00       	call   8015f2 <_panic>

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
  8001ce:	68 2a 24 80 00       	push   $0x80242a
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 47 24 80 00       	push   $0x802447
  8001da:	e8 13 14 00 00       	call   8015f2 <_panic>

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
  800210:	68 2a 24 80 00       	push   $0x80242a
  800215:	6a 23                	push   $0x23
  800217:	68 47 24 80 00       	push   $0x802447
  80021c:	e8 d1 13 00 00       	call   8015f2 <_panic>

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
  800252:	68 2a 24 80 00       	push   $0x80242a
  800257:	6a 23                	push   $0x23
  800259:	68 47 24 80 00       	push   $0x802447
  80025e:	e8 8f 13 00 00       	call   8015f2 <_panic>

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
  800294:	68 2a 24 80 00       	push   $0x80242a
  800299:	6a 23                	push   $0x23
  80029b:	68 47 24 80 00       	push   $0x802447
  8002a0:	e8 4d 13 00 00       	call   8015f2 <_panic>

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
  8002d6:	68 2a 24 80 00       	push   $0x80242a
  8002db:	6a 23                	push   $0x23
  8002dd:	68 47 24 80 00       	push   $0x802447
  8002e2:	e8 0b 13 00 00       	call   8015f2 <_panic>
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
  800318:	68 2a 24 80 00       	push   $0x80242a
  80031d:	6a 23                	push   $0x23
  80031f:	68 47 24 80 00       	push   $0x802447
  800324:	e8 c9 12 00 00       	call   8015f2 <_panic>

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
  80037c:	68 2a 24 80 00       	push   $0x80242a
  800381:	6a 23                	push   $0x23
  800383:	68 47 24 80 00       	push   $0x802447
  800388:	e8 65 12 00 00       	call   8015f2 <_panic>

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
  80041b:	68 55 24 80 00       	push   $0x802455
  800420:	6a 1f                	push   $0x1f
  800422:	68 65 24 80 00       	push   $0x802465
  800427:	e8 c6 11 00 00       	call   8015f2 <_panic>
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
  800445:	68 70 24 80 00       	push   $0x802470
  80044a:	6a 2d                	push   $0x2d
  80044c:	68 65 24 80 00       	push   $0x802465
  800451:	e8 9c 11 00 00       	call   8015f2 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800456:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80045c:	83 ec 04             	sub    $0x4,%esp
  80045f:	68 00 10 00 00       	push   $0x1000
  800464:	53                   	push   %ebx
  800465:	68 00 f0 7f 00       	push   $0x7ff000
  80046a:	e8 db 19 00 00       	call   801e4a <memcpy>

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
  80048d:	68 70 24 80 00       	push   $0x802470
  800492:	6a 34                	push   $0x34
  800494:	68 65 24 80 00       	push   $0x802465
  800499:	e8 54 11 00 00       	call   8015f2 <_panic>
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
  8004b5:	68 70 24 80 00       	push   $0x802470
  8004ba:	6a 38                	push   $0x38
  8004bc:	68 65 24 80 00       	push   $0x802465
  8004c1:	e8 2c 11 00 00       	call   8015f2 <_panic>
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
  8004d9:	e8 b9 1a 00 00       	call   801f97 <set_pgfault_handler>
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
  8004f2:	68 89 24 80 00       	push   $0x802489
  8004f7:	68 85 00 00 00       	push   $0x85
  8004fc:	68 65 24 80 00       	push   $0x802465
  800501:	e8 ec 10 00 00       	call   8015f2 <_panic>
  800506:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  800508:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050c:	75 24                	jne    800532 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  80050e:	e8 53 fc ff ff       	call   800166 <sys_getenvid>
  800513:	25 ff 03 00 00       	and    $0x3ff,%eax
  800518:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
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
  8005ae:	68 97 24 80 00       	push   $0x802497
  8005b3:	6a 55                	push   $0x55
  8005b5:	68 65 24 80 00       	push   $0x802465
  8005ba:	e8 33 10 00 00       	call   8015f2 <_panic>
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
  8005f3:	68 97 24 80 00       	push   $0x802497
  8005f8:	6a 5c                	push   $0x5c
  8005fa:	68 65 24 80 00       	push   $0x802465
  8005ff:	e8 ee 0f 00 00       	call   8015f2 <_panic>
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
  800621:	68 97 24 80 00       	push   $0x802497
  800626:	6a 60                	push   $0x60
  800628:	68 65 24 80 00       	push   $0x802465
  80062d:	e8 c0 0f 00 00       	call   8015f2 <_panic>
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
  80064b:	68 97 24 80 00       	push   $0x802497
  800650:	6a 65                	push   $0x65
  800652:	68 65 24 80 00       	push   $0x802465
  800657:	e8 96 0f 00 00       	call   8015f2 <_panic>
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
  800673:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
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

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006b6:	68 ae 00 80 00       	push   $0x8000ae
  8006bb:	e8 d5 fc ff ff       	call   800395 <sys_thread_create>

	return id;
}
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    

008006c2 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  8006c8:	ff 75 08             	pushl  0x8(%ebp)
  8006cb:	e8 e5 fc ff ff       	call   8003b5 <sys_thread_free>
}
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    

008006d5 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8006db:	ff 75 08             	pushl  0x8(%ebp)
  8006de:	e8 f2 fc ff ff       	call   8003d5 <sys_thread_join>
}
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	c9                   	leave  
  8006e7:	c3                   	ret    

008006e8 <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	56                   	push   %esi
  8006ec:	53                   	push   %ebx
  8006ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006f3:	83 ec 04             	sub    $0x4,%esp
  8006f6:	6a 07                	push   $0x7
  8006f8:	6a 00                	push   $0x0
  8006fa:	56                   	push   %esi
  8006fb:	e8 a4 fa ff ff       	call   8001a4 <sys_page_alloc>
	if (r < 0) {
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 c0                	test   %eax,%eax
  800705:	79 15                	jns    80071c <queue_append+0x34>
		panic("%e\n", r);
  800707:	50                   	push   %eax
  800708:	68 dd 24 80 00       	push   $0x8024dd
  80070d:	68 d5 00 00 00       	push   $0xd5
  800712:	68 65 24 80 00       	push   $0x802465
  800717:	e8 d6 0e 00 00       	call   8015f2 <_panic>
	}	

	wt->envid = envid;
  80071c:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  800722:	83 3b 00             	cmpl   $0x0,(%ebx)
  800725:	75 13                	jne    80073a <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  800727:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80072e:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800735:	00 00 00 
  800738:	eb 1b                	jmp    800755 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  80073a:	8b 43 04             	mov    0x4(%ebx),%eax
  80073d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800744:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80074b:	00 00 00 
		queue->last = wt;
  80074e:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  800755:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  800765:	8b 02                	mov    (%edx),%eax
  800767:	85 c0                	test   %eax,%eax
  800769:	75 17                	jne    800782 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  80076b:	83 ec 04             	sub    $0x4,%esp
  80076e:	68 ad 24 80 00       	push   $0x8024ad
  800773:	68 ec 00 00 00       	push   $0xec
  800778:	68 65 24 80 00       	push   $0x802465
  80077d:	e8 70 0e 00 00       	call   8015f2 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  800782:	8b 48 04             	mov    0x4(%eax),%ecx
  800785:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  800787:	8b 00                	mov    (%eax),%eax
}
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800793:	b8 01 00 00 00       	mov    $0x1,%eax
  800798:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80079b:	85 c0                	test   %eax,%eax
  80079d:	74 4a                	je     8007e9 <mutex_lock+0x5e>
  80079f:	8b 73 04             	mov    0x4(%ebx),%esi
  8007a2:	83 3e 00             	cmpl   $0x0,(%esi)
  8007a5:	75 42                	jne    8007e9 <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  8007a7:	e8 ba f9 ff ff       	call   800166 <sys_getenvid>
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	56                   	push   %esi
  8007b0:	50                   	push   %eax
  8007b1:	e8 32 ff ff ff       	call   8006e8 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8007b6:	e8 ab f9 ff ff       	call   800166 <sys_getenvid>
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	6a 04                	push   $0x4
  8007c0:	50                   	push   %eax
  8007c1:	e8 a5 fa ff ff       	call   80026b <sys_env_set_status>

		if (r < 0) {
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	79 15                	jns    8007e2 <mutex_lock+0x57>
			panic("%e\n", r);
  8007cd:	50                   	push   %eax
  8007ce:	68 dd 24 80 00       	push   $0x8024dd
  8007d3:	68 02 01 00 00       	push   $0x102
  8007d8:	68 65 24 80 00       	push   $0x802465
  8007dd:	e8 10 0e 00 00       	call   8015f2 <_panic>
		}
		sys_yield();
  8007e2:	e8 9e f9 ff ff       	call   800185 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007e7:	eb 08                	jmp    8007f1 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8007e9:	e8 78 f9 ff ff       	call   800166 <sys_getenvid>
  8007ee:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8007f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007f4:	5b                   	pop    %ebx
  8007f5:	5e                   	pop    %esi
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	83 ec 04             	sub    $0x4,%esp
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  80080a:	8b 43 04             	mov    0x4(%ebx),%eax
  80080d:	83 38 00             	cmpl   $0x0,(%eax)
  800810:	74 33                	je     800845 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  800812:	83 ec 0c             	sub    $0xc,%esp
  800815:	50                   	push   %eax
  800816:	e8 41 ff ff ff       	call   80075c <queue_pop>
  80081b:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  80081e:	83 c4 08             	add    $0x8,%esp
  800821:	6a 02                	push   $0x2
  800823:	50                   	push   %eax
  800824:	e8 42 fa ff ff       	call   80026b <sys_env_set_status>
		if (r < 0) {
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	85 c0                	test   %eax,%eax
  80082e:	79 15                	jns    800845 <mutex_unlock+0x4d>
			panic("%e\n", r);
  800830:	50                   	push   %eax
  800831:	68 dd 24 80 00       	push   $0x8024dd
  800836:	68 16 01 00 00       	push   $0x116
  80083b:	68 65 24 80 00       	push   $0x802465
  800840:	e8 ad 0d 00 00       	call   8015f2 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  800845:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	83 ec 04             	sub    $0x4,%esp
  800851:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800854:	e8 0d f9 ff ff       	call   800166 <sys_getenvid>
  800859:	83 ec 04             	sub    $0x4,%esp
  80085c:	6a 07                	push   $0x7
  80085e:	53                   	push   %ebx
  80085f:	50                   	push   %eax
  800860:	e8 3f f9 ff ff       	call   8001a4 <sys_page_alloc>
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	85 c0                	test   %eax,%eax
  80086a:	79 15                	jns    800881 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80086c:	50                   	push   %eax
  80086d:	68 c8 24 80 00       	push   $0x8024c8
  800872:	68 22 01 00 00       	push   $0x122
  800877:	68 65 24 80 00       	push   $0x802465
  80087c:	e8 71 0d 00 00       	call   8015f2 <_panic>
	}	
	mtx->locked = 0;
  800881:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  800887:	8b 43 04             	mov    0x4(%ebx),%eax
  80088a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800890:	8b 43 04             	mov    0x4(%ebx),%eax
  800893:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80089a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  8008a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a4:	c9                   	leave  
  8008a5:	c3                   	ret    

008008a6 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	53                   	push   %ebx
  8008aa:	83 ec 04             	sub    $0x4,%esp
  8008ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  8008b0:	eb 21                	jmp    8008d3 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  8008b2:	83 ec 0c             	sub    $0xc,%esp
  8008b5:	50                   	push   %eax
  8008b6:	e8 a1 fe ff ff       	call   80075c <queue_pop>
  8008bb:	83 c4 08             	add    $0x8,%esp
  8008be:	6a 02                	push   $0x2
  8008c0:	50                   	push   %eax
  8008c1:	e8 a5 f9 ff ff       	call   80026b <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  8008c6:	8b 43 04             	mov    0x4(%ebx),%eax
  8008c9:	8b 10                	mov    (%eax),%edx
  8008cb:	8b 52 04             	mov    0x4(%edx),%edx
  8008ce:	89 10                	mov    %edx,(%eax)
  8008d0:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8008d3:	8b 43 04             	mov    0x4(%ebx),%eax
  8008d6:	83 38 00             	cmpl   $0x0,(%eax)
  8008d9:	75 d7                	jne    8008b2 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008db:	83 ec 04             	sub    $0x4,%esp
  8008de:	68 00 10 00 00       	push   $0x1000
  8008e3:	6a 00                	push   $0x0
  8008e5:	53                   	push   %ebx
  8008e6:	e8 aa 14 00 00       	call   801d95 <memset>
	mtx = NULL;
}
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	05 00 00 00 30       	add    $0x30000000,%eax
  8008fe:	c1 e8 0c             	shr    $0xc,%eax
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	05 00 00 00 30       	add    $0x30000000,%eax
  80090e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800913:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    

0080091a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800920:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800925:	89 c2                	mov    %eax,%edx
  800927:	c1 ea 16             	shr    $0x16,%edx
  80092a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800931:	f6 c2 01             	test   $0x1,%dl
  800934:	74 11                	je     800947 <fd_alloc+0x2d>
  800936:	89 c2                	mov    %eax,%edx
  800938:	c1 ea 0c             	shr    $0xc,%edx
  80093b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800942:	f6 c2 01             	test   $0x1,%dl
  800945:	75 09                	jne    800950 <fd_alloc+0x36>
			*fd_store = fd;
  800947:	89 01                	mov    %eax,(%ecx)
			return 0;
  800949:	b8 00 00 00 00       	mov    $0x0,%eax
  80094e:	eb 17                	jmp    800967 <fd_alloc+0x4d>
  800950:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800955:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80095a:	75 c9                	jne    800925 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80095c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800962:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80096f:	83 f8 1f             	cmp    $0x1f,%eax
  800972:	77 36                	ja     8009aa <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800974:	c1 e0 0c             	shl    $0xc,%eax
  800977:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80097c:	89 c2                	mov    %eax,%edx
  80097e:	c1 ea 16             	shr    $0x16,%edx
  800981:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800988:	f6 c2 01             	test   $0x1,%dl
  80098b:	74 24                	je     8009b1 <fd_lookup+0x48>
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	c1 ea 0c             	shr    $0xc,%edx
  800992:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800999:	f6 c2 01             	test   $0x1,%dl
  80099c:	74 1a                	je     8009b8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	89 02                	mov    %eax,(%edx)
	return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a8:	eb 13                	jmp    8009bd <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8009aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009af:	eb 0c                	jmp    8009bd <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8009b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b6:	eb 05                	jmp    8009bd <fd_lookup+0x54>
  8009b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c8:	ba 60 25 80 00       	mov    $0x802560,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009cd:	eb 13                	jmp    8009e2 <dev_lookup+0x23>
  8009cf:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009d2:	39 08                	cmp    %ecx,(%eax)
  8009d4:	75 0c                	jne    8009e2 <dev_lookup+0x23>
			*dev = devtab[i];
  8009d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e0:	eb 31                	jmp    800a13 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009e2:	8b 02                	mov    (%edx),%eax
  8009e4:	85 c0                	test   %eax,%eax
  8009e6:	75 e7                	jne    8009cf <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8009ed:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009f3:	83 ec 04             	sub    $0x4,%esp
  8009f6:	51                   	push   %ecx
  8009f7:	50                   	push   %eax
  8009f8:	68 e4 24 80 00       	push   $0x8024e4
  8009fd:	e8 c9 0c 00 00       	call   8016cb <cprintf>
	*dev = 0;
  800a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a05:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a0b:	83 c4 10             	add    $0x10,%esp
  800a0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    

00800a15 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	83 ec 10             	sub    $0x10,%esp
  800a1d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a26:	50                   	push   %eax
  800a27:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a2d:	c1 e8 0c             	shr    $0xc,%eax
  800a30:	50                   	push   %eax
  800a31:	e8 33 ff ff ff       	call   800969 <fd_lookup>
  800a36:	83 c4 08             	add    $0x8,%esp
  800a39:	85 c0                	test   %eax,%eax
  800a3b:	78 05                	js     800a42 <fd_close+0x2d>
	    || fd != fd2)
  800a3d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a40:	74 0c                	je     800a4e <fd_close+0x39>
		return (must_exist ? r : 0);
  800a42:	84 db                	test   %bl,%bl
  800a44:	ba 00 00 00 00       	mov    $0x0,%edx
  800a49:	0f 44 c2             	cmove  %edx,%eax
  800a4c:	eb 41                	jmp    800a8f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a4e:	83 ec 08             	sub    $0x8,%esp
  800a51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a54:	50                   	push   %eax
  800a55:	ff 36                	pushl  (%esi)
  800a57:	e8 63 ff ff ff       	call   8009bf <dev_lookup>
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	83 c4 10             	add    $0x10,%esp
  800a61:	85 c0                	test   %eax,%eax
  800a63:	78 1a                	js     800a7f <fd_close+0x6a>
		if (dev->dev_close)
  800a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a68:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a6b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a70:	85 c0                	test   %eax,%eax
  800a72:	74 0b                	je     800a7f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a74:	83 ec 0c             	sub    $0xc,%esp
  800a77:	56                   	push   %esi
  800a78:	ff d0                	call   *%eax
  800a7a:	89 c3                	mov    %eax,%ebx
  800a7c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a7f:	83 ec 08             	sub    $0x8,%esp
  800a82:	56                   	push   %esi
  800a83:	6a 00                	push   $0x0
  800a85:	e8 9f f7 ff ff       	call   800229 <sys_page_unmap>
	return r;
  800a8a:	83 c4 10             	add    $0x10,%esp
  800a8d:	89 d8                	mov    %ebx,%eax
}
  800a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a9f:	50                   	push   %eax
  800aa0:	ff 75 08             	pushl  0x8(%ebp)
  800aa3:	e8 c1 fe ff ff       	call   800969 <fd_lookup>
  800aa8:	83 c4 08             	add    $0x8,%esp
  800aab:	85 c0                	test   %eax,%eax
  800aad:	78 10                	js     800abf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800aaf:	83 ec 08             	sub    $0x8,%esp
  800ab2:	6a 01                	push   $0x1
  800ab4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ab7:	e8 59 ff ff ff       	call   800a15 <fd_close>
  800abc:	83 c4 10             	add    $0x10,%esp
}
  800abf:	c9                   	leave  
  800ac0:	c3                   	ret    

00800ac1 <close_all>:

void
close_all(void)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	53                   	push   %ebx
  800ac5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ac8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800acd:	83 ec 0c             	sub    $0xc,%esp
  800ad0:	53                   	push   %ebx
  800ad1:	e8 c0 ff ff ff       	call   800a96 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ad6:	83 c3 01             	add    $0x1,%ebx
  800ad9:	83 c4 10             	add    $0x10,%esp
  800adc:	83 fb 20             	cmp    $0x20,%ebx
  800adf:	75 ec                	jne    800acd <close_all+0xc>
		close(i);
}
  800ae1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	83 ec 2c             	sub    $0x2c,%esp
  800aef:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800af2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800af5:	50                   	push   %eax
  800af6:	ff 75 08             	pushl  0x8(%ebp)
  800af9:	e8 6b fe ff ff       	call   800969 <fd_lookup>
  800afe:	83 c4 08             	add    $0x8,%esp
  800b01:	85 c0                	test   %eax,%eax
  800b03:	0f 88 c1 00 00 00    	js     800bca <dup+0xe4>
		return r;
	close(newfdnum);
  800b09:	83 ec 0c             	sub    $0xc,%esp
  800b0c:	56                   	push   %esi
  800b0d:	e8 84 ff ff ff       	call   800a96 <close>

	newfd = INDEX2FD(newfdnum);
  800b12:	89 f3                	mov    %esi,%ebx
  800b14:	c1 e3 0c             	shl    $0xc,%ebx
  800b17:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b1d:	83 c4 04             	add    $0x4,%esp
  800b20:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b23:	e8 db fd ff ff       	call   800903 <fd2data>
  800b28:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b2a:	89 1c 24             	mov    %ebx,(%esp)
  800b2d:	e8 d1 fd ff ff       	call   800903 <fd2data>
  800b32:	83 c4 10             	add    $0x10,%esp
  800b35:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b38:	89 f8                	mov    %edi,%eax
  800b3a:	c1 e8 16             	shr    $0x16,%eax
  800b3d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b44:	a8 01                	test   $0x1,%al
  800b46:	74 37                	je     800b7f <dup+0x99>
  800b48:	89 f8                	mov    %edi,%eax
  800b4a:	c1 e8 0c             	shr    $0xc,%eax
  800b4d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b54:	f6 c2 01             	test   $0x1,%dl
  800b57:	74 26                	je     800b7f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b59:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	25 07 0e 00 00       	and    $0xe07,%eax
  800b68:	50                   	push   %eax
  800b69:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b6c:	6a 00                	push   $0x0
  800b6e:	57                   	push   %edi
  800b6f:	6a 00                	push   $0x0
  800b71:	e8 71 f6 ff ff       	call   8001e7 <sys_page_map>
  800b76:	89 c7                	mov    %eax,%edi
  800b78:	83 c4 20             	add    $0x20,%esp
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	78 2e                	js     800bad <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b82:	89 d0                	mov    %edx,%eax
  800b84:	c1 e8 0c             	shr    $0xc,%eax
  800b87:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b8e:	83 ec 0c             	sub    $0xc,%esp
  800b91:	25 07 0e 00 00       	and    $0xe07,%eax
  800b96:	50                   	push   %eax
  800b97:	53                   	push   %ebx
  800b98:	6a 00                	push   $0x0
  800b9a:	52                   	push   %edx
  800b9b:	6a 00                	push   $0x0
  800b9d:	e8 45 f6 ff ff       	call   8001e7 <sys_page_map>
  800ba2:	89 c7                	mov    %eax,%edi
  800ba4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800ba7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ba9:	85 ff                	test   %edi,%edi
  800bab:	79 1d                	jns    800bca <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800bad:	83 ec 08             	sub    $0x8,%esp
  800bb0:	53                   	push   %ebx
  800bb1:	6a 00                	push   $0x0
  800bb3:	e8 71 f6 ff ff       	call   800229 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800bb8:	83 c4 08             	add    $0x8,%esp
  800bbb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bbe:	6a 00                	push   $0x0
  800bc0:	e8 64 f6 ff ff       	call   800229 <sys_page_unmap>
	return r;
  800bc5:	83 c4 10             	add    $0x10,%esp
  800bc8:	89 f8                	mov    %edi,%eax
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 14             	sub    $0x14,%esp
  800bd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bdc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bdf:	50                   	push   %eax
  800be0:	53                   	push   %ebx
  800be1:	e8 83 fd ff ff       	call   800969 <fd_lookup>
  800be6:	83 c4 08             	add    $0x8,%esp
  800be9:	89 c2                	mov    %eax,%edx
  800beb:	85 c0                	test   %eax,%eax
  800bed:	78 70                	js     800c5f <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bef:	83 ec 08             	sub    $0x8,%esp
  800bf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf5:	50                   	push   %eax
  800bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf9:	ff 30                	pushl  (%eax)
  800bfb:	e8 bf fd ff ff       	call   8009bf <dev_lookup>
  800c00:	83 c4 10             	add    $0x10,%esp
  800c03:	85 c0                	test   %eax,%eax
  800c05:	78 4f                	js     800c56 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c07:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c0a:	8b 42 08             	mov    0x8(%edx),%eax
  800c0d:	83 e0 03             	and    $0x3,%eax
  800c10:	83 f8 01             	cmp    $0x1,%eax
  800c13:	75 24                	jne    800c39 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c15:	a1 04 40 80 00       	mov    0x804004,%eax
  800c1a:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800c20:	83 ec 04             	sub    $0x4,%esp
  800c23:	53                   	push   %ebx
  800c24:	50                   	push   %eax
  800c25:	68 25 25 80 00       	push   $0x802525
  800c2a:	e8 9c 0a 00 00       	call   8016cb <cprintf>
		return -E_INVAL;
  800c2f:	83 c4 10             	add    $0x10,%esp
  800c32:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c37:	eb 26                	jmp    800c5f <read+0x8d>
	}
	if (!dev->dev_read)
  800c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3c:	8b 40 08             	mov    0x8(%eax),%eax
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	74 17                	je     800c5a <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c43:	83 ec 04             	sub    $0x4,%esp
  800c46:	ff 75 10             	pushl  0x10(%ebp)
  800c49:	ff 75 0c             	pushl  0xc(%ebp)
  800c4c:	52                   	push   %edx
  800c4d:	ff d0                	call   *%eax
  800c4f:	89 c2                	mov    %eax,%edx
  800c51:	83 c4 10             	add    $0x10,%esp
  800c54:	eb 09                	jmp    800c5f <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c56:	89 c2                	mov    %eax,%edx
  800c58:	eb 05                	jmp    800c5f <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c5a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c5f:	89 d0                	mov    %edx,%eax
  800c61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c64:	c9                   	leave  
  800c65:	c3                   	ret    

00800c66 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c72:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7a:	eb 21                	jmp    800c9d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c7c:	83 ec 04             	sub    $0x4,%esp
  800c7f:	89 f0                	mov    %esi,%eax
  800c81:	29 d8                	sub    %ebx,%eax
  800c83:	50                   	push   %eax
  800c84:	89 d8                	mov    %ebx,%eax
  800c86:	03 45 0c             	add    0xc(%ebp),%eax
  800c89:	50                   	push   %eax
  800c8a:	57                   	push   %edi
  800c8b:	e8 42 ff ff ff       	call   800bd2 <read>
		if (m < 0)
  800c90:	83 c4 10             	add    $0x10,%esp
  800c93:	85 c0                	test   %eax,%eax
  800c95:	78 10                	js     800ca7 <readn+0x41>
			return m;
		if (m == 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	74 0a                	je     800ca5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c9b:	01 c3                	add    %eax,%ebx
  800c9d:	39 f3                	cmp    %esi,%ebx
  800c9f:	72 db                	jb     800c7c <readn+0x16>
  800ca1:	89 d8                	mov    %ebx,%eax
  800ca3:	eb 02                	jmp    800ca7 <readn+0x41>
  800ca5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 14             	sub    $0x14,%esp
  800cb6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cbc:	50                   	push   %eax
  800cbd:	53                   	push   %ebx
  800cbe:	e8 a6 fc ff ff       	call   800969 <fd_lookup>
  800cc3:	83 c4 08             	add    $0x8,%esp
  800cc6:	89 c2                	mov    %eax,%edx
  800cc8:	85 c0                	test   %eax,%eax
  800cca:	78 6b                	js     800d37 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ccc:	83 ec 08             	sub    $0x8,%esp
  800ccf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cd2:	50                   	push   %eax
  800cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd6:	ff 30                	pushl  (%eax)
  800cd8:	e8 e2 fc ff ff       	call   8009bf <dev_lookup>
  800cdd:	83 c4 10             	add    $0x10,%esp
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	78 4a                	js     800d2e <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ceb:	75 24                	jne    800d11 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800ced:	a1 04 40 80 00       	mov    0x804004,%eax
  800cf2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800cf8:	83 ec 04             	sub    $0x4,%esp
  800cfb:	53                   	push   %ebx
  800cfc:	50                   	push   %eax
  800cfd:	68 41 25 80 00       	push   $0x802541
  800d02:	e8 c4 09 00 00       	call   8016cb <cprintf>
		return -E_INVAL;
  800d07:	83 c4 10             	add    $0x10,%esp
  800d0a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d0f:	eb 26                	jmp    800d37 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d14:	8b 52 0c             	mov    0xc(%edx),%edx
  800d17:	85 d2                	test   %edx,%edx
  800d19:	74 17                	je     800d32 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d1b:	83 ec 04             	sub    $0x4,%esp
  800d1e:	ff 75 10             	pushl  0x10(%ebp)
  800d21:	ff 75 0c             	pushl  0xc(%ebp)
  800d24:	50                   	push   %eax
  800d25:	ff d2                	call   *%edx
  800d27:	89 c2                	mov    %eax,%edx
  800d29:	83 c4 10             	add    $0x10,%esp
  800d2c:	eb 09                	jmp    800d37 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d2e:	89 c2                	mov    %eax,%edx
  800d30:	eb 05                	jmp    800d37 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d32:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d37:	89 d0                	mov    %edx,%eax
  800d39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    

00800d3e <seek>:

int
seek(int fdnum, off_t offset)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d44:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d47:	50                   	push   %eax
  800d48:	ff 75 08             	pushl  0x8(%ebp)
  800d4b:	e8 19 fc ff ff       	call   800969 <fd_lookup>
  800d50:	83 c4 08             	add    $0x8,%esp
  800d53:	85 c0                	test   %eax,%eax
  800d55:	78 0e                	js     800d65 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d57:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    

00800d67 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 14             	sub    $0x14,%esp
  800d6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d74:	50                   	push   %eax
  800d75:	53                   	push   %ebx
  800d76:	e8 ee fb ff ff       	call   800969 <fd_lookup>
  800d7b:	83 c4 08             	add    $0x8,%esp
  800d7e:	89 c2                	mov    %eax,%edx
  800d80:	85 c0                	test   %eax,%eax
  800d82:	78 68                	js     800dec <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d84:	83 ec 08             	sub    $0x8,%esp
  800d87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d8a:	50                   	push   %eax
  800d8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d8e:	ff 30                	pushl  (%eax)
  800d90:	e8 2a fc ff ff       	call   8009bf <dev_lookup>
  800d95:	83 c4 10             	add    $0x10,%esp
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	78 47                	js     800de3 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d9f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800da3:	75 24                	jne    800dc9 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800da5:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800daa:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800db0:	83 ec 04             	sub    $0x4,%esp
  800db3:	53                   	push   %ebx
  800db4:	50                   	push   %eax
  800db5:	68 04 25 80 00       	push   $0x802504
  800dba:	e8 0c 09 00 00       	call   8016cb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800dc7:	eb 23                	jmp    800dec <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800dc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dcc:	8b 52 18             	mov    0x18(%edx),%edx
  800dcf:	85 d2                	test   %edx,%edx
  800dd1:	74 14                	je     800de7 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800dd3:	83 ec 08             	sub    $0x8,%esp
  800dd6:	ff 75 0c             	pushl  0xc(%ebp)
  800dd9:	50                   	push   %eax
  800dda:	ff d2                	call   *%edx
  800ddc:	89 c2                	mov    %eax,%edx
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	eb 09                	jmp    800dec <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800de3:	89 c2                	mov    %eax,%edx
  800de5:	eb 05                	jmp    800dec <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800de7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dec:	89 d0                	mov    %edx,%eax
  800dee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	53                   	push   %ebx
  800df7:	83 ec 14             	sub    $0x14,%esp
  800dfa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e00:	50                   	push   %eax
  800e01:	ff 75 08             	pushl  0x8(%ebp)
  800e04:	e8 60 fb ff ff       	call   800969 <fd_lookup>
  800e09:	83 c4 08             	add    $0x8,%esp
  800e0c:	89 c2                	mov    %eax,%edx
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	78 58                	js     800e6a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e18:	50                   	push   %eax
  800e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1c:	ff 30                	pushl  (%eax)
  800e1e:	e8 9c fb ff ff       	call   8009bf <dev_lookup>
  800e23:	83 c4 10             	add    $0x10,%esp
  800e26:	85 c0                	test   %eax,%eax
  800e28:	78 37                	js     800e61 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e31:	74 32                	je     800e65 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e33:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e36:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e3d:	00 00 00 
	stat->st_isdir = 0;
  800e40:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e47:	00 00 00 
	stat->st_dev = dev;
  800e4a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	53                   	push   %ebx
  800e54:	ff 75 f0             	pushl  -0x10(%ebp)
  800e57:	ff 50 14             	call   *0x14(%eax)
  800e5a:	89 c2                	mov    %eax,%edx
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	eb 09                	jmp    800e6a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	eb 05                	jmp    800e6a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e65:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e6a:	89 d0                	mov    %edx,%eax
  800e6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6f:	c9                   	leave  
  800e70:	c3                   	ret    

00800e71 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	56                   	push   %esi
  800e75:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e76:	83 ec 08             	sub    $0x8,%esp
  800e79:	6a 00                	push   $0x0
  800e7b:	ff 75 08             	pushl  0x8(%ebp)
  800e7e:	e8 e3 01 00 00       	call   801066 <open>
  800e83:	89 c3                	mov    %eax,%ebx
  800e85:	83 c4 10             	add    $0x10,%esp
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	78 1b                	js     800ea7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e8c:	83 ec 08             	sub    $0x8,%esp
  800e8f:	ff 75 0c             	pushl  0xc(%ebp)
  800e92:	50                   	push   %eax
  800e93:	e8 5b ff ff ff       	call   800df3 <fstat>
  800e98:	89 c6                	mov    %eax,%esi
	close(fd);
  800e9a:	89 1c 24             	mov    %ebx,(%esp)
  800e9d:	e8 f4 fb ff ff       	call   800a96 <close>
	return r;
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	89 f0                	mov    %esi,%eax
}
  800ea7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	89 c6                	mov    %eax,%esi
  800eb5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800eb7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ebe:	75 12                	jne    800ed2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ec0:	83 ec 0c             	sub    $0xc,%esp
  800ec3:	6a 01                	push   $0x1
  800ec5:	e8 39 12 00 00       	call   802103 <ipc_find_env>
  800eca:	a3 00 40 80 00       	mov    %eax,0x804000
  800ecf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ed2:	6a 07                	push   $0x7
  800ed4:	68 00 50 80 00       	push   $0x805000
  800ed9:	56                   	push   %esi
  800eda:	ff 35 00 40 80 00    	pushl  0x804000
  800ee0:	e8 bc 11 00 00       	call   8020a1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ee5:	83 c4 0c             	add    $0xc,%esp
  800ee8:	6a 00                	push   $0x0
  800eea:	53                   	push   %ebx
  800eeb:	6a 00                	push   $0x0
  800eed:	e8 34 11 00 00       	call   802026 <ipc_recv>
}
  800ef2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	8b 40 0c             	mov    0xc(%eax),%eax
  800f05:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f12:	ba 00 00 00 00       	mov    $0x0,%edx
  800f17:	b8 02 00 00 00       	mov    $0x2,%eax
  800f1c:	e8 8d ff ff ff       	call   800eae <fsipc>
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f29:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2c:	8b 40 0c             	mov    0xc(%eax),%eax
  800f2f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f34:	ba 00 00 00 00       	mov    $0x0,%edx
  800f39:	b8 06 00 00 00       	mov    $0x6,%eax
  800f3e:	e8 6b ff ff ff       	call   800eae <fsipc>
}
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	53                   	push   %ebx
  800f49:	83 ec 04             	sub    $0x4,%esp
  800f4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	8b 40 0c             	mov    0xc(%eax),%eax
  800f55:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800f64:	e8 45 ff ff ff       	call   800eae <fsipc>
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 2c                	js     800f99 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f6d:	83 ec 08             	sub    $0x8,%esp
  800f70:	68 00 50 80 00       	push   $0x805000
  800f75:	53                   	push   %ebx
  800f76:	e8 d5 0c 00 00       	call   801c50 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f7b:	a1 80 50 80 00       	mov    0x805080,%eax
  800f80:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f86:	a1 84 50 80 00       	mov    0x805084,%eax
  800f8b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 0c             	sub    $0xc,%esp
  800fa4:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800fa7:	8b 55 08             	mov    0x8(%ebp),%edx
  800faa:	8b 52 0c             	mov    0xc(%edx),%edx
  800fad:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800fb3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800fb8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800fbd:	0f 47 c2             	cmova  %edx,%eax
  800fc0:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800fc5:	50                   	push   %eax
  800fc6:	ff 75 0c             	pushl  0xc(%ebp)
  800fc9:	68 08 50 80 00       	push   $0x805008
  800fce:	e8 0f 0e 00 00       	call   801de2 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd8:	b8 04 00 00 00       	mov    $0x4,%eax
  800fdd:	e8 cc fe ff ff       	call   800eae <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fec:	8b 45 08             	mov    0x8(%ebp),%eax
  800fef:	8b 40 0c             	mov    0xc(%eax),%eax
  800ff2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ff7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ffd:	ba 00 00 00 00       	mov    $0x0,%edx
  801002:	b8 03 00 00 00       	mov    $0x3,%eax
  801007:	e8 a2 fe ff ff       	call   800eae <fsipc>
  80100c:	89 c3                	mov    %eax,%ebx
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 4b                	js     80105d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801012:	39 c6                	cmp    %eax,%esi
  801014:	73 16                	jae    80102c <devfile_read+0x48>
  801016:	68 70 25 80 00       	push   $0x802570
  80101b:	68 77 25 80 00       	push   $0x802577
  801020:	6a 7c                	push   $0x7c
  801022:	68 8c 25 80 00       	push   $0x80258c
  801027:	e8 c6 05 00 00       	call   8015f2 <_panic>
	assert(r <= PGSIZE);
  80102c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801031:	7e 16                	jle    801049 <devfile_read+0x65>
  801033:	68 97 25 80 00       	push   $0x802597
  801038:	68 77 25 80 00       	push   $0x802577
  80103d:	6a 7d                	push   $0x7d
  80103f:	68 8c 25 80 00       	push   $0x80258c
  801044:	e8 a9 05 00 00       	call   8015f2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801049:	83 ec 04             	sub    $0x4,%esp
  80104c:	50                   	push   %eax
  80104d:	68 00 50 80 00       	push   $0x805000
  801052:	ff 75 0c             	pushl  0xc(%ebp)
  801055:	e8 88 0d 00 00       	call   801de2 <memmove>
	return r;
  80105a:	83 c4 10             	add    $0x10,%esp
}
  80105d:	89 d8                	mov    %ebx,%eax
  80105f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	53                   	push   %ebx
  80106a:	83 ec 20             	sub    $0x20,%esp
  80106d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801070:	53                   	push   %ebx
  801071:	e8 a1 0b 00 00       	call   801c17 <strlen>
  801076:	83 c4 10             	add    $0x10,%esp
  801079:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80107e:	7f 67                	jg     8010e7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801086:	50                   	push   %eax
  801087:	e8 8e f8 ff ff       	call   80091a <fd_alloc>
  80108c:	83 c4 10             	add    $0x10,%esp
		return r;
  80108f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801091:	85 c0                	test   %eax,%eax
  801093:	78 57                	js     8010ec <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	53                   	push   %ebx
  801099:	68 00 50 80 00       	push   $0x805000
  80109e:	e8 ad 0b 00 00       	call   801c50 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8010a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8010ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b3:	e8 f6 fd ff ff       	call   800eae <fsipc>
  8010b8:	89 c3                	mov    %eax,%ebx
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	85 c0                	test   %eax,%eax
  8010bf:	79 14                	jns    8010d5 <open+0x6f>
		fd_close(fd, 0);
  8010c1:	83 ec 08             	sub    $0x8,%esp
  8010c4:	6a 00                	push   $0x0
  8010c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8010c9:	e8 47 f9 ff ff       	call   800a15 <fd_close>
		return r;
  8010ce:	83 c4 10             	add    $0x10,%esp
  8010d1:	89 da                	mov    %ebx,%edx
  8010d3:	eb 17                	jmp    8010ec <open+0x86>
	}

	return fd2num(fd);
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8010db:	e8 13 f8 ff ff       	call   8008f3 <fd2num>
  8010e0:	89 c2                	mov    %eax,%edx
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	eb 05                	jmp    8010ec <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010e7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010ec:	89 d0                	mov    %edx,%eax
  8010ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f1:	c9                   	leave  
  8010f2:	c3                   	ret    

008010f3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010f3:	55                   	push   %ebp
  8010f4:	89 e5                	mov    %esp,%ebp
  8010f6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fe:	b8 08 00 00 00       	mov    $0x8,%eax
  801103:	e8 a6 fd ff ff       	call   800eae <fsipc>
}
  801108:	c9                   	leave  
  801109:	c3                   	ret    

0080110a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	56                   	push   %esi
  80110e:	53                   	push   %ebx
  80110f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801112:	83 ec 0c             	sub    $0xc,%esp
  801115:	ff 75 08             	pushl  0x8(%ebp)
  801118:	e8 e6 f7 ff ff       	call   800903 <fd2data>
  80111d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80111f:	83 c4 08             	add    $0x8,%esp
  801122:	68 a3 25 80 00       	push   $0x8025a3
  801127:	53                   	push   %ebx
  801128:	e8 23 0b 00 00       	call   801c50 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80112d:	8b 46 04             	mov    0x4(%esi),%eax
  801130:	2b 06                	sub    (%esi),%eax
  801132:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801138:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80113f:	00 00 00 
	stat->st_dev = &devpipe;
  801142:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801149:	30 80 00 
	return 0;
}
  80114c:	b8 00 00 00 00       	mov    $0x0,%eax
  801151:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	53                   	push   %ebx
  80115c:	83 ec 0c             	sub    $0xc,%esp
  80115f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801162:	53                   	push   %ebx
  801163:	6a 00                	push   $0x0
  801165:	e8 bf f0 ff ff       	call   800229 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80116a:	89 1c 24             	mov    %ebx,(%esp)
  80116d:	e8 91 f7 ff ff       	call   800903 <fd2data>
  801172:	83 c4 08             	add    $0x8,%esp
  801175:	50                   	push   %eax
  801176:	6a 00                	push   $0x0
  801178:	e8 ac f0 ff ff       	call   800229 <sys_page_unmap>
}
  80117d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801180:	c9                   	leave  
  801181:	c3                   	ret    

00801182 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	57                   	push   %edi
  801186:	56                   	push   %esi
  801187:	53                   	push   %ebx
  801188:	83 ec 1c             	sub    $0x1c,%esp
  80118b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80118e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801190:	a1 04 40 80 00       	mov    0x804004,%eax
  801195:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80119b:	83 ec 0c             	sub    $0xc,%esp
  80119e:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a1:	e8 a2 0f 00 00       	call   802148 <pageref>
  8011a6:	89 c3                	mov    %eax,%ebx
  8011a8:	89 3c 24             	mov    %edi,(%esp)
  8011ab:	e8 98 0f 00 00       	call   802148 <pageref>
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	39 c3                	cmp    %eax,%ebx
  8011b5:	0f 94 c1             	sete   %cl
  8011b8:	0f b6 c9             	movzbl %cl,%ecx
  8011bb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8011be:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011c4:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011ca:	39 ce                	cmp    %ecx,%esi
  8011cc:	74 1e                	je     8011ec <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011ce:	39 c3                	cmp    %eax,%ebx
  8011d0:	75 be                	jne    801190 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011d2:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011db:	50                   	push   %eax
  8011dc:	56                   	push   %esi
  8011dd:	68 aa 25 80 00       	push   $0x8025aa
  8011e2:	e8 e4 04 00 00       	call   8016cb <cprintf>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	eb a4                	jmp    801190 <_pipeisclosed+0xe>
	}
}
  8011ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	57                   	push   %edi
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 28             	sub    $0x28,%esp
  801200:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801203:	56                   	push   %esi
  801204:	e8 fa f6 ff ff       	call   800903 <fd2data>
  801209:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	bf 00 00 00 00       	mov    $0x0,%edi
  801213:	eb 4b                	jmp    801260 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801215:	89 da                	mov    %ebx,%edx
  801217:	89 f0                	mov    %esi,%eax
  801219:	e8 64 ff ff ff       	call   801182 <_pipeisclosed>
  80121e:	85 c0                	test   %eax,%eax
  801220:	75 48                	jne    80126a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801222:	e8 5e ef ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801227:	8b 43 04             	mov    0x4(%ebx),%eax
  80122a:	8b 0b                	mov    (%ebx),%ecx
  80122c:	8d 51 20             	lea    0x20(%ecx),%edx
  80122f:	39 d0                	cmp    %edx,%eax
  801231:	73 e2                	jae    801215 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801236:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80123a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80123d:	89 c2                	mov    %eax,%edx
  80123f:	c1 fa 1f             	sar    $0x1f,%edx
  801242:	89 d1                	mov    %edx,%ecx
  801244:	c1 e9 1b             	shr    $0x1b,%ecx
  801247:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80124a:	83 e2 1f             	and    $0x1f,%edx
  80124d:	29 ca                	sub    %ecx,%edx
  80124f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801253:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801257:	83 c0 01             	add    $0x1,%eax
  80125a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80125d:	83 c7 01             	add    $0x1,%edi
  801260:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801263:	75 c2                	jne    801227 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801265:	8b 45 10             	mov    0x10(%ebp),%eax
  801268:	eb 05                	jmp    80126f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80126a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80126f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801272:	5b                   	pop    %ebx
  801273:	5e                   	pop    %esi
  801274:	5f                   	pop    %edi
  801275:	5d                   	pop    %ebp
  801276:	c3                   	ret    

00801277 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801277:	55                   	push   %ebp
  801278:	89 e5                	mov    %esp,%ebp
  80127a:	57                   	push   %edi
  80127b:	56                   	push   %esi
  80127c:	53                   	push   %ebx
  80127d:	83 ec 18             	sub    $0x18,%esp
  801280:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801283:	57                   	push   %edi
  801284:	e8 7a f6 ff ff       	call   800903 <fd2data>
  801289:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801293:	eb 3d                	jmp    8012d2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801295:	85 db                	test   %ebx,%ebx
  801297:	74 04                	je     80129d <devpipe_read+0x26>
				return i;
  801299:	89 d8                	mov    %ebx,%eax
  80129b:	eb 44                	jmp    8012e1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80129d:	89 f2                	mov    %esi,%edx
  80129f:	89 f8                	mov    %edi,%eax
  8012a1:	e8 dc fe ff ff       	call   801182 <_pipeisclosed>
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	75 32                	jne    8012dc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8012aa:	e8 d6 ee ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8012af:	8b 06                	mov    (%esi),%eax
  8012b1:	3b 46 04             	cmp    0x4(%esi),%eax
  8012b4:	74 df                	je     801295 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8012b6:	99                   	cltd   
  8012b7:	c1 ea 1b             	shr    $0x1b,%edx
  8012ba:	01 d0                	add    %edx,%eax
  8012bc:	83 e0 1f             	and    $0x1f,%eax
  8012bf:	29 d0                	sub    %edx,%eax
  8012c1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8012c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012cc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012cf:	83 c3 01             	add    $0x1,%ebx
  8012d2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012d5:	75 d8                	jne    8012af <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8012da:	eb 05                	jmp    8012e1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012dc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    

008012e9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	56                   	push   %esi
  8012ed:	53                   	push   %ebx
  8012ee:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	e8 20 f6 ff ff       	call   80091a <fd_alloc>
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	89 c2                	mov    %eax,%edx
  8012ff:	85 c0                	test   %eax,%eax
  801301:	0f 88 2c 01 00 00    	js     801433 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801307:	83 ec 04             	sub    $0x4,%esp
  80130a:	68 07 04 00 00       	push   $0x407
  80130f:	ff 75 f4             	pushl  -0xc(%ebp)
  801312:	6a 00                	push   $0x0
  801314:	e8 8b ee ff ff       	call   8001a4 <sys_page_alloc>
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	85 c0                	test   %eax,%eax
  801320:	0f 88 0d 01 00 00    	js     801433 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	e8 e8 f5 ff ff       	call   80091a <fd_alloc>
  801332:	89 c3                	mov    %eax,%ebx
  801334:	83 c4 10             	add    $0x10,%esp
  801337:	85 c0                	test   %eax,%eax
  801339:	0f 88 e2 00 00 00    	js     801421 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80133f:	83 ec 04             	sub    $0x4,%esp
  801342:	68 07 04 00 00       	push   $0x407
  801347:	ff 75 f0             	pushl  -0x10(%ebp)
  80134a:	6a 00                	push   $0x0
  80134c:	e8 53 ee ff ff       	call   8001a4 <sys_page_alloc>
  801351:	89 c3                	mov    %eax,%ebx
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	0f 88 c3 00 00 00    	js     801421 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80135e:	83 ec 0c             	sub    $0xc,%esp
  801361:	ff 75 f4             	pushl  -0xc(%ebp)
  801364:	e8 9a f5 ff ff       	call   800903 <fd2data>
  801369:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80136b:	83 c4 0c             	add    $0xc,%esp
  80136e:	68 07 04 00 00       	push   $0x407
  801373:	50                   	push   %eax
  801374:	6a 00                	push   $0x0
  801376:	e8 29 ee ff ff       	call   8001a4 <sys_page_alloc>
  80137b:	89 c3                	mov    %eax,%ebx
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	85 c0                	test   %eax,%eax
  801382:	0f 88 89 00 00 00    	js     801411 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801388:	83 ec 0c             	sub    $0xc,%esp
  80138b:	ff 75 f0             	pushl  -0x10(%ebp)
  80138e:	e8 70 f5 ff ff       	call   800903 <fd2data>
  801393:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80139a:	50                   	push   %eax
  80139b:	6a 00                	push   $0x0
  80139d:	56                   	push   %esi
  80139e:	6a 00                	push   $0x0
  8013a0:	e8 42 ee ff ff       	call   8001e7 <sys_page_map>
  8013a5:	89 c3                	mov    %eax,%ebx
  8013a7:	83 c4 20             	add    $0x20,%esp
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 55                	js     801403 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8013ae:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8013b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013c3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013d8:	83 ec 0c             	sub    $0xc,%esp
  8013db:	ff 75 f4             	pushl  -0xc(%ebp)
  8013de:	e8 10 f5 ff ff       	call   8008f3 <fd2num>
  8013e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013e8:	83 c4 04             	add    $0x4,%esp
  8013eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ee:	e8 00 f5 ff ff       	call   8008f3 <fd2num>
  8013f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f6:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801401:	eb 30                	jmp    801433 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	56                   	push   %esi
  801407:	6a 00                	push   $0x0
  801409:	e8 1b ee ff ff       	call   800229 <sys_page_unmap>
  80140e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	ff 75 f0             	pushl  -0x10(%ebp)
  801417:	6a 00                	push   $0x0
  801419:	e8 0b ee ff ff       	call   800229 <sys_page_unmap>
  80141e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	ff 75 f4             	pushl  -0xc(%ebp)
  801427:	6a 00                	push   $0x0
  801429:	e8 fb ed ff ff       	call   800229 <sys_page_unmap>
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801433:	89 d0                	mov    %edx,%eax
  801435:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801438:	5b                   	pop    %ebx
  801439:	5e                   	pop    %esi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801442:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	ff 75 08             	pushl  0x8(%ebp)
  801449:	e8 1b f5 ff ff       	call   800969 <fd_lookup>
  80144e:	83 c4 10             	add    $0x10,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	78 18                	js     80146d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	ff 75 f4             	pushl  -0xc(%ebp)
  80145b:	e8 a3 f4 ff ff       	call   800903 <fd2data>
	return _pipeisclosed(fd, p);
  801460:	89 c2                	mov    %eax,%edx
  801462:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801465:	e8 18 fd ff ff       	call   801182 <_pipeisclosed>
  80146a:	83 c4 10             	add    $0x10,%esp
}
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801472:	b8 00 00 00 00       	mov    $0x0,%eax
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    

00801479 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80147f:	68 c2 25 80 00       	push   $0x8025c2
  801484:	ff 75 0c             	pushl  0xc(%ebp)
  801487:	e8 c4 07 00 00       	call   801c50 <strcpy>
	return 0;
}
  80148c:	b8 00 00 00 00       	mov    $0x0,%eax
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	57                   	push   %edi
  801497:	56                   	push   %esi
  801498:	53                   	push   %ebx
  801499:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80149f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014a4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014aa:	eb 2d                	jmp    8014d9 <devcons_write+0x46>
		m = n - tot;
  8014ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014af:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8014b1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8014b4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8014b9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014bc:	83 ec 04             	sub    $0x4,%esp
  8014bf:	53                   	push   %ebx
  8014c0:	03 45 0c             	add    0xc(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	57                   	push   %edi
  8014c5:	e8 18 09 00 00       	call   801de2 <memmove>
		sys_cputs(buf, m);
  8014ca:	83 c4 08             	add    $0x8,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	57                   	push   %edi
  8014cf:	e8 14 ec ff ff       	call   8000e8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014d4:	01 de                	add    %ebx,%esi
  8014d6:	83 c4 10             	add    $0x10,%esp
  8014d9:	89 f0                	mov    %esi,%eax
  8014db:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014de:	72 cc                	jb     8014ac <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e3:	5b                   	pop    %ebx
  8014e4:	5e                   	pop    %esi
  8014e5:	5f                   	pop    %edi
  8014e6:	5d                   	pop    %ebp
  8014e7:	c3                   	ret    

008014e8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	83 ec 08             	sub    $0x8,%esp
  8014ee:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014f3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014f7:	74 2a                	je     801523 <devcons_read+0x3b>
  8014f9:	eb 05                	jmp    801500 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014fb:	e8 85 ec ff ff       	call   800185 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801500:	e8 01 ec ff ff       	call   800106 <sys_cgetc>
  801505:	85 c0                	test   %eax,%eax
  801507:	74 f2                	je     8014fb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801509:	85 c0                	test   %eax,%eax
  80150b:	78 16                	js     801523 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80150d:	83 f8 04             	cmp    $0x4,%eax
  801510:	74 0c                	je     80151e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801512:	8b 55 0c             	mov    0xc(%ebp),%edx
  801515:	88 02                	mov    %al,(%edx)
	return 1;
  801517:	b8 01 00 00 00       	mov    $0x1,%eax
  80151c:	eb 05                	jmp    801523 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80151e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801523:	c9                   	leave  
  801524:	c3                   	ret    

00801525 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80152b:	8b 45 08             	mov    0x8(%ebp),%eax
  80152e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801531:	6a 01                	push   $0x1
  801533:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801536:	50                   	push   %eax
  801537:	e8 ac eb ff ff       	call   8000e8 <sys_cputs>
}
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	c9                   	leave  
  801540:	c3                   	ret    

00801541 <getchar>:

int
getchar(void)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801547:	6a 01                	push   $0x1
  801549:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80154c:	50                   	push   %eax
  80154d:	6a 00                	push   $0x0
  80154f:	e8 7e f6 ff ff       	call   800bd2 <read>
	if (r < 0)
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 0f                	js     80156a <getchar+0x29>
		return r;
	if (r < 1)
  80155b:	85 c0                	test   %eax,%eax
  80155d:	7e 06                	jle    801565 <getchar+0x24>
		return -E_EOF;
	return c;
  80155f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801563:	eb 05                	jmp    80156a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801565:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801572:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	ff 75 08             	pushl  0x8(%ebp)
  801579:	e8 eb f3 ff ff       	call   800969 <fd_lookup>
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	78 11                	js     801596 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801585:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801588:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80158e:	39 10                	cmp    %edx,(%eax)
  801590:	0f 94 c0             	sete   %al
  801593:	0f b6 c0             	movzbl %al,%eax
}
  801596:	c9                   	leave  
  801597:	c3                   	ret    

00801598 <opencons>:

int
opencons(void)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80159e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	e8 73 f3 ff ff       	call   80091a <fd_alloc>
  8015a7:	83 c4 10             	add    $0x10,%esp
		return r;
  8015aa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015ac:	85 c0                	test   %eax,%eax
  8015ae:	78 3e                	js     8015ee <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015b0:	83 ec 04             	sub    $0x4,%esp
  8015b3:	68 07 04 00 00       	push   $0x407
  8015b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015bb:	6a 00                	push   $0x0
  8015bd:	e8 e2 eb ff ff       	call   8001a4 <sys_page_alloc>
  8015c2:	83 c4 10             	add    $0x10,%esp
		return r;
  8015c5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015c7:	85 c0                	test   %eax,%eax
  8015c9:	78 23                	js     8015ee <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015cb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	50                   	push   %eax
  8015e4:	e8 0a f3 ff ff       	call   8008f3 <fd2num>
  8015e9:	89 c2                	mov    %eax,%edx
  8015eb:	83 c4 10             	add    $0x10,%esp
}
  8015ee:	89 d0                	mov    %edx,%eax
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	56                   	push   %esi
  8015f6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015f7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015fa:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801600:	e8 61 eb ff ff       	call   800166 <sys_getenvid>
  801605:	83 ec 0c             	sub    $0xc,%esp
  801608:	ff 75 0c             	pushl  0xc(%ebp)
  80160b:	ff 75 08             	pushl  0x8(%ebp)
  80160e:	56                   	push   %esi
  80160f:	50                   	push   %eax
  801610:	68 d0 25 80 00       	push   $0x8025d0
  801615:	e8 b1 00 00 00       	call   8016cb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80161a:	83 c4 18             	add    $0x18,%esp
  80161d:	53                   	push   %ebx
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	e8 54 00 00 00       	call   80167a <vcprintf>
	cprintf("\n");
  801626:	c7 04 24 c6 24 80 00 	movl   $0x8024c6,(%esp)
  80162d:	e8 99 00 00 00       	call   8016cb <cprintf>
  801632:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801635:	cc                   	int3   
  801636:	eb fd                	jmp    801635 <_panic+0x43>

00801638 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	53                   	push   %ebx
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801642:	8b 13                	mov    (%ebx),%edx
  801644:	8d 42 01             	lea    0x1(%edx),%eax
  801647:	89 03                	mov    %eax,(%ebx)
  801649:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80164c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801650:	3d ff 00 00 00       	cmp    $0xff,%eax
  801655:	75 1a                	jne    801671 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	68 ff 00 00 00       	push   $0xff
  80165f:	8d 43 08             	lea    0x8(%ebx),%eax
  801662:	50                   	push   %eax
  801663:	e8 80 ea ff ff       	call   8000e8 <sys_cputs>
		b->idx = 0;
  801668:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80166e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801671:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801675:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801678:	c9                   	leave  
  801679:	c3                   	ret    

0080167a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801683:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80168a:	00 00 00 
	b.cnt = 0;
  80168d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801694:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801697:	ff 75 0c             	pushl  0xc(%ebp)
  80169a:	ff 75 08             	pushl  0x8(%ebp)
  80169d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	68 38 16 80 00       	push   $0x801638
  8016a9:	e8 54 01 00 00       	call   801802 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8016ae:	83 c4 08             	add    $0x8,%esp
  8016b1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8016b7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8016bd:	50                   	push   %eax
  8016be:	e8 25 ea ff ff       	call   8000e8 <sys_cputs>

	return b.cnt;
}
  8016c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016d1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016d4:	50                   	push   %eax
  8016d5:	ff 75 08             	pushl  0x8(%ebp)
  8016d8:	e8 9d ff ff ff       	call   80167a <vcprintf>
	va_end(ap);

	return cnt;
}
  8016dd:	c9                   	leave  
  8016de:	c3                   	ret    

008016df <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	57                   	push   %edi
  8016e3:	56                   	push   %esi
  8016e4:	53                   	push   %ebx
  8016e5:	83 ec 1c             	sub    $0x1c,%esp
  8016e8:	89 c7                	mov    %eax,%edi
  8016ea:	89 d6                	mov    %edx,%esi
  8016ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801700:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801703:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801706:	39 d3                	cmp    %edx,%ebx
  801708:	72 05                	jb     80170f <printnum+0x30>
  80170a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80170d:	77 45                	ja     801754 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80170f:	83 ec 0c             	sub    $0xc,%esp
  801712:	ff 75 18             	pushl  0x18(%ebp)
  801715:	8b 45 14             	mov    0x14(%ebp),%eax
  801718:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80171b:	53                   	push   %ebx
  80171c:	ff 75 10             	pushl  0x10(%ebp)
  80171f:	83 ec 08             	sub    $0x8,%esp
  801722:	ff 75 e4             	pushl  -0x1c(%ebp)
  801725:	ff 75 e0             	pushl  -0x20(%ebp)
  801728:	ff 75 dc             	pushl  -0x24(%ebp)
  80172b:	ff 75 d8             	pushl  -0x28(%ebp)
  80172e:	e8 5d 0a 00 00       	call   802190 <__udivdi3>
  801733:	83 c4 18             	add    $0x18,%esp
  801736:	52                   	push   %edx
  801737:	50                   	push   %eax
  801738:	89 f2                	mov    %esi,%edx
  80173a:	89 f8                	mov    %edi,%eax
  80173c:	e8 9e ff ff ff       	call   8016df <printnum>
  801741:	83 c4 20             	add    $0x20,%esp
  801744:	eb 18                	jmp    80175e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801746:	83 ec 08             	sub    $0x8,%esp
  801749:	56                   	push   %esi
  80174a:	ff 75 18             	pushl  0x18(%ebp)
  80174d:	ff d7                	call   *%edi
  80174f:	83 c4 10             	add    $0x10,%esp
  801752:	eb 03                	jmp    801757 <printnum+0x78>
  801754:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801757:	83 eb 01             	sub    $0x1,%ebx
  80175a:	85 db                	test   %ebx,%ebx
  80175c:	7f e8                	jg     801746 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80175e:	83 ec 08             	sub    $0x8,%esp
  801761:	56                   	push   %esi
  801762:	83 ec 04             	sub    $0x4,%esp
  801765:	ff 75 e4             	pushl  -0x1c(%ebp)
  801768:	ff 75 e0             	pushl  -0x20(%ebp)
  80176b:	ff 75 dc             	pushl  -0x24(%ebp)
  80176e:	ff 75 d8             	pushl  -0x28(%ebp)
  801771:	e8 4a 0b 00 00       	call   8022c0 <__umoddi3>
  801776:	83 c4 14             	add    $0x14,%esp
  801779:	0f be 80 f3 25 80 00 	movsbl 0x8025f3(%eax),%eax
  801780:	50                   	push   %eax
  801781:	ff d7                	call   *%edi
}
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5f                   	pop    %edi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801791:	83 fa 01             	cmp    $0x1,%edx
  801794:	7e 0e                	jle    8017a4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801796:	8b 10                	mov    (%eax),%edx
  801798:	8d 4a 08             	lea    0x8(%edx),%ecx
  80179b:	89 08                	mov    %ecx,(%eax)
  80179d:	8b 02                	mov    (%edx),%eax
  80179f:	8b 52 04             	mov    0x4(%edx),%edx
  8017a2:	eb 22                	jmp    8017c6 <getuint+0x38>
	else if (lflag)
  8017a4:	85 d2                	test   %edx,%edx
  8017a6:	74 10                	je     8017b8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8017a8:	8b 10                	mov    (%eax),%edx
  8017aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017ad:	89 08                	mov    %ecx,(%eax)
  8017af:	8b 02                	mov    (%edx),%eax
  8017b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b6:	eb 0e                	jmp    8017c6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8017b8:	8b 10                	mov    (%eax),%edx
  8017ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017bd:	89 08                	mov    %ecx,(%eax)
  8017bf:	8b 02                	mov    (%edx),%eax
  8017c1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017ce:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017d2:	8b 10                	mov    (%eax),%edx
  8017d4:	3b 50 04             	cmp    0x4(%eax),%edx
  8017d7:	73 0a                	jae    8017e3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017d9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017dc:	89 08                	mov    %ecx,(%eax)
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	88 02                	mov    %al,(%edx)
}
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017eb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017ee:	50                   	push   %eax
  8017ef:	ff 75 10             	pushl  0x10(%ebp)
  8017f2:	ff 75 0c             	pushl  0xc(%ebp)
  8017f5:	ff 75 08             	pushl  0x8(%ebp)
  8017f8:	e8 05 00 00 00       	call   801802 <vprintfmt>
	va_end(ap);
}
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	c9                   	leave  
  801801:	c3                   	ret    

00801802 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801802:	55                   	push   %ebp
  801803:	89 e5                	mov    %esp,%ebp
  801805:	57                   	push   %edi
  801806:	56                   	push   %esi
  801807:	53                   	push   %ebx
  801808:	83 ec 2c             	sub    $0x2c,%esp
  80180b:	8b 75 08             	mov    0x8(%ebp),%esi
  80180e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801811:	8b 7d 10             	mov    0x10(%ebp),%edi
  801814:	eb 12                	jmp    801828 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801816:	85 c0                	test   %eax,%eax
  801818:	0f 84 89 03 00 00    	je     801ba7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	53                   	push   %ebx
  801822:	50                   	push   %eax
  801823:	ff d6                	call   *%esi
  801825:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801828:	83 c7 01             	add    $0x1,%edi
  80182b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80182f:	83 f8 25             	cmp    $0x25,%eax
  801832:	75 e2                	jne    801816 <vprintfmt+0x14>
  801834:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801838:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80183f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801846:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	eb 07                	jmp    80185b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801854:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801857:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185b:	8d 47 01             	lea    0x1(%edi),%eax
  80185e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801861:	0f b6 07             	movzbl (%edi),%eax
  801864:	0f b6 c8             	movzbl %al,%ecx
  801867:	83 e8 23             	sub    $0x23,%eax
  80186a:	3c 55                	cmp    $0x55,%al
  80186c:	0f 87 1a 03 00 00    	ja     801b8c <vprintfmt+0x38a>
  801872:	0f b6 c0             	movzbl %al,%eax
  801875:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  80187c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80187f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801883:	eb d6                	jmp    80185b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801885:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801888:	b8 00 00 00 00       	mov    $0x0,%eax
  80188d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801890:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801893:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801897:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80189a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80189d:	83 fa 09             	cmp    $0x9,%edx
  8018a0:	77 39                	ja     8018db <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018a2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8018a5:	eb e9                	jmp    801890 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8018aa:	8d 48 04             	lea    0x4(%eax),%ecx
  8018ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8018b0:	8b 00                	mov    (%eax),%eax
  8018b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8018b8:	eb 27                	jmp    8018e1 <vprintfmt+0xdf>
  8018ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018c4:	0f 49 c8             	cmovns %eax,%ecx
  8018c7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018cd:	eb 8c                	jmp    80185b <vprintfmt+0x59>
  8018cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018d2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018d9:	eb 80                	jmp    80185b <vprintfmt+0x59>
  8018db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018de:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018e5:	0f 89 70 ff ff ff    	jns    80185b <vprintfmt+0x59>
				width = precision, precision = -1;
  8018eb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018f1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018f8:	e9 5e ff ff ff       	jmp    80185b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018fd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801900:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801903:	e9 53 ff ff ff       	jmp    80185b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801908:	8b 45 14             	mov    0x14(%ebp),%eax
  80190b:	8d 50 04             	lea    0x4(%eax),%edx
  80190e:	89 55 14             	mov    %edx,0x14(%ebp)
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	53                   	push   %ebx
  801915:	ff 30                	pushl  (%eax)
  801917:	ff d6                	call   *%esi
			break;
  801919:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80191c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80191f:	e9 04 ff ff ff       	jmp    801828 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801924:	8b 45 14             	mov    0x14(%ebp),%eax
  801927:	8d 50 04             	lea    0x4(%eax),%edx
  80192a:	89 55 14             	mov    %edx,0x14(%ebp)
  80192d:	8b 00                	mov    (%eax),%eax
  80192f:	99                   	cltd   
  801930:	31 d0                	xor    %edx,%eax
  801932:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801934:	83 f8 0f             	cmp    $0xf,%eax
  801937:	7f 0b                	jg     801944 <vprintfmt+0x142>
  801939:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  801940:	85 d2                	test   %edx,%edx
  801942:	75 18                	jne    80195c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801944:	50                   	push   %eax
  801945:	68 0b 26 80 00       	push   $0x80260b
  80194a:	53                   	push   %ebx
  80194b:	56                   	push   %esi
  80194c:	e8 94 fe ff ff       	call   8017e5 <printfmt>
  801951:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801954:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801957:	e9 cc fe ff ff       	jmp    801828 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80195c:	52                   	push   %edx
  80195d:	68 89 25 80 00       	push   $0x802589
  801962:	53                   	push   %ebx
  801963:	56                   	push   %esi
  801964:	e8 7c fe ff ff       	call   8017e5 <printfmt>
  801969:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80196c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80196f:	e9 b4 fe ff ff       	jmp    801828 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801974:	8b 45 14             	mov    0x14(%ebp),%eax
  801977:	8d 50 04             	lea    0x4(%eax),%edx
  80197a:	89 55 14             	mov    %edx,0x14(%ebp)
  80197d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80197f:	85 ff                	test   %edi,%edi
  801981:	b8 04 26 80 00       	mov    $0x802604,%eax
  801986:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801989:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80198d:	0f 8e 94 00 00 00    	jle    801a27 <vprintfmt+0x225>
  801993:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801997:	0f 84 98 00 00 00    	je     801a35 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80199d:	83 ec 08             	sub    $0x8,%esp
  8019a0:	ff 75 d0             	pushl  -0x30(%ebp)
  8019a3:	57                   	push   %edi
  8019a4:	e8 86 02 00 00       	call   801c2f <strnlen>
  8019a9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8019ac:	29 c1                	sub    %eax,%ecx
  8019ae:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8019b1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8019b4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8019b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019bb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8019be:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019c0:	eb 0f                	jmp    8019d1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	53                   	push   %ebx
  8019c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8019c9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019cb:	83 ef 01             	sub    $0x1,%edi
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	85 ff                	test   %edi,%edi
  8019d3:	7f ed                	jg     8019c2 <vprintfmt+0x1c0>
  8019d5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019d8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019db:	85 c9                	test   %ecx,%ecx
  8019dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019e2:	0f 49 c1             	cmovns %ecx,%eax
  8019e5:	29 c1                	sub    %eax,%ecx
  8019e7:	89 75 08             	mov    %esi,0x8(%ebp)
  8019ea:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019ed:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019f0:	89 cb                	mov    %ecx,%ebx
  8019f2:	eb 4d                	jmp    801a41 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019f8:	74 1b                	je     801a15 <vprintfmt+0x213>
  8019fa:	0f be c0             	movsbl %al,%eax
  8019fd:	83 e8 20             	sub    $0x20,%eax
  801a00:	83 f8 5e             	cmp    $0x5e,%eax
  801a03:	76 10                	jbe    801a15 <vprintfmt+0x213>
					putch('?', putdat);
  801a05:	83 ec 08             	sub    $0x8,%esp
  801a08:	ff 75 0c             	pushl  0xc(%ebp)
  801a0b:	6a 3f                	push   $0x3f
  801a0d:	ff 55 08             	call   *0x8(%ebp)
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	eb 0d                	jmp    801a22 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a15:	83 ec 08             	sub    $0x8,%esp
  801a18:	ff 75 0c             	pushl  0xc(%ebp)
  801a1b:	52                   	push   %edx
  801a1c:	ff 55 08             	call   *0x8(%ebp)
  801a1f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a22:	83 eb 01             	sub    $0x1,%ebx
  801a25:	eb 1a                	jmp    801a41 <vprintfmt+0x23f>
  801a27:	89 75 08             	mov    %esi,0x8(%ebp)
  801a2a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a2d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a30:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a33:	eb 0c                	jmp    801a41 <vprintfmt+0x23f>
  801a35:	89 75 08             	mov    %esi,0x8(%ebp)
  801a38:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a3b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a3e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a41:	83 c7 01             	add    $0x1,%edi
  801a44:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a48:	0f be d0             	movsbl %al,%edx
  801a4b:	85 d2                	test   %edx,%edx
  801a4d:	74 23                	je     801a72 <vprintfmt+0x270>
  801a4f:	85 f6                	test   %esi,%esi
  801a51:	78 a1                	js     8019f4 <vprintfmt+0x1f2>
  801a53:	83 ee 01             	sub    $0x1,%esi
  801a56:	79 9c                	jns    8019f4 <vprintfmt+0x1f2>
  801a58:	89 df                	mov    %ebx,%edi
  801a5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a60:	eb 18                	jmp    801a7a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a62:	83 ec 08             	sub    $0x8,%esp
  801a65:	53                   	push   %ebx
  801a66:	6a 20                	push   $0x20
  801a68:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a6a:	83 ef 01             	sub    $0x1,%edi
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	eb 08                	jmp    801a7a <vprintfmt+0x278>
  801a72:	89 df                	mov    %ebx,%edi
  801a74:	8b 75 08             	mov    0x8(%ebp),%esi
  801a77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a7a:	85 ff                	test   %edi,%edi
  801a7c:	7f e4                	jg     801a62 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a81:	e9 a2 fd ff ff       	jmp    801828 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a86:	83 fa 01             	cmp    $0x1,%edx
  801a89:	7e 16                	jle    801aa1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a8b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8e:	8d 50 08             	lea    0x8(%eax),%edx
  801a91:	89 55 14             	mov    %edx,0x14(%ebp)
  801a94:	8b 50 04             	mov    0x4(%eax),%edx
  801a97:	8b 00                	mov    (%eax),%eax
  801a99:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a9c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a9f:	eb 32                	jmp    801ad3 <vprintfmt+0x2d1>
	else if (lflag)
  801aa1:	85 d2                	test   %edx,%edx
  801aa3:	74 18                	je     801abd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801aa5:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa8:	8d 50 04             	lea    0x4(%eax),%edx
  801aab:	89 55 14             	mov    %edx,0x14(%ebp)
  801aae:	8b 00                	mov    (%eax),%eax
  801ab0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ab3:	89 c1                	mov    %eax,%ecx
  801ab5:	c1 f9 1f             	sar    $0x1f,%ecx
  801ab8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801abb:	eb 16                	jmp    801ad3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801abd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac0:	8d 50 04             	lea    0x4(%eax),%edx
  801ac3:	89 55 14             	mov    %edx,0x14(%ebp)
  801ac6:	8b 00                	mov    (%eax),%eax
  801ac8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801acb:	89 c1                	mov    %eax,%ecx
  801acd:	c1 f9 1f             	sar    $0x1f,%ecx
  801ad0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ad3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ad6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801ad9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ade:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ae2:	79 74                	jns    801b58 <vprintfmt+0x356>
				putch('-', putdat);
  801ae4:	83 ec 08             	sub    $0x8,%esp
  801ae7:	53                   	push   %ebx
  801ae8:	6a 2d                	push   $0x2d
  801aea:	ff d6                	call   *%esi
				num = -(long long) num;
  801aec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aef:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801af2:	f7 d8                	neg    %eax
  801af4:	83 d2 00             	adc    $0x0,%edx
  801af7:	f7 da                	neg    %edx
  801af9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801afc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b01:	eb 55                	jmp    801b58 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b03:	8d 45 14             	lea    0x14(%ebp),%eax
  801b06:	e8 83 fc ff ff       	call   80178e <getuint>
			base = 10;
  801b0b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b10:	eb 46                	jmp    801b58 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b12:	8d 45 14             	lea    0x14(%ebp),%eax
  801b15:	e8 74 fc ff ff       	call   80178e <getuint>
			base = 8;
  801b1a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b1f:	eb 37                	jmp    801b58 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b21:	83 ec 08             	sub    $0x8,%esp
  801b24:	53                   	push   %ebx
  801b25:	6a 30                	push   $0x30
  801b27:	ff d6                	call   *%esi
			putch('x', putdat);
  801b29:	83 c4 08             	add    $0x8,%esp
  801b2c:	53                   	push   %ebx
  801b2d:	6a 78                	push   $0x78
  801b2f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b31:	8b 45 14             	mov    0x14(%ebp),%eax
  801b34:	8d 50 04             	lea    0x4(%eax),%edx
  801b37:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b3a:	8b 00                	mov    (%eax),%eax
  801b3c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b41:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b44:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b49:	eb 0d                	jmp    801b58 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b4b:	8d 45 14             	lea    0x14(%ebp),%eax
  801b4e:	e8 3b fc ff ff       	call   80178e <getuint>
			base = 16;
  801b53:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b58:	83 ec 0c             	sub    $0xc,%esp
  801b5b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b5f:	57                   	push   %edi
  801b60:	ff 75 e0             	pushl  -0x20(%ebp)
  801b63:	51                   	push   %ecx
  801b64:	52                   	push   %edx
  801b65:	50                   	push   %eax
  801b66:	89 da                	mov    %ebx,%edx
  801b68:	89 f0                	mov    %esi,%eax
  801b6a:	e8 70 fb ff ff       	call   8016df <printnum>
			break;
  801b6f:	83 c4 20             	add    $0x20,%esp
  801b72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b75:	e9 ae fc ff ff       	jmp    801828 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b7a:	83 ec 08             	sub    $0x8,%esp
  801b7d:	53                   	push   %ebx
  801b7e:	51                   	push   %ecx
  801b7f:	ff d6                	call   *%esi
			break;
  801b81:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b87:	e9 9c fc ff ff       	jmp    801828 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	53                   	push   %ebx
  801b90:	6a 25                	push   $0x25
  801b92:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b94:	83 c4 10             	add    $0x10,%esp
  801b97:	eb 03                	jmp    801b9c <vprintfmt+0x39a>
  801b99:	83 ef 01             	sub    $0x1,%edi
  801b9c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801ba0:	75 f7                	jne    801b99 <vprintfmt+0x397>
  801ba2:	e9 81 fc ff ff       	jmp    801828 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ba7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801baa:	5b                   	pop    %ebx
  801bab:	5e                   	pop    %esi
  801bac:	5f                   	pop    %edi
  801bad:	5d                   	pop    %ebp
  801bae:	c3                   	ret    

00801baf <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	83 ec 18             	sub    $0x18,%esp
  801bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801bbb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801bbe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801bc2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bc5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	74 26                	je     801bf6 <vsnprintf+0x47>
  801bd0:	85 d2                	test   %edx,%edx
  801bd2:	7e 22                	jle    801bf6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801bd4:	ff 75 14             	pushl  0x14(%ebp)
  801bd7:	ff 75 10             	pushl  0x10(%ebp)
  801bda:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	68 c8 17 80 00       	push   $0x8017c8
  801be3:	e8 1a fc ff ff       	call   801802 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801be8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801beb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	eb 05                	jmp    801bfb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bf6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bfb:	c9                   	leave  
  801bfc:	c3                   	ret    

00801bfd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bfd:	55                   	push   %ebp
  801bfe:	89 e5                	mov    %esp,%ebp
  801c00:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c03:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c06:	50                   	push   %eax
  801c07:	ff 75 10             	pushl  0x10(%ebp)
  801c0a:	ff 75 0c             	pushl  0xc(%ebp)
  801c0d:	ff 75 08             	pushl  0x8(%ebp)
  801c10:	e8 9a ff ff ff       	call   801baf <vsnprintf>
	va_end(ap);

	return rc;
}
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    

00801c17 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  801c22:	eb 03                	jmp    801c27 <strlen+0x10>
		n++;
  801c24:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c27:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c2b:	75 f7                	jne    801c24 <strlen+0xd>
		n++;
	return n;
}
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    

00801c2f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c35:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c38:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3d:	eb 03                	jmp    801c42 <strnlen+0x13>
		n++;
  801c3f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c42:	39 c2                	cmp    %eax,%edx
  801c44:	74 08                	je     801c4e <strnlen+0x1f>
  801c46:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c4a:	75 f3                	jne    801c3f <strnlen+0x10>
  801c4c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c4e:	5d                   	pop    %ebp
  801c4f:	c3                   	ret    

00801c50 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	53                   	push   %ebx
  801c54:	8b 45 08             	mov    0x8(%ebp),%eax
  801c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c5a:	89 c2                	mov    %eax,%edx
  801c5c:	83 c2 01             	add    $0x1,%edx
  801c5f:	83 c1 01             	add    $0x1,%ecx
  801c62:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c66:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c69:	84 db                	test   %bl,%bl
  801c6b:	75 ef                	jne    801c5c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c6d:	5b                   	pop    %ebx
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	53                   	push   %ebx
  801c74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c77:	53                   	push   %ebx
  801c78:	e8 9a ff ff ff       	call   801c17 <strlen>
  801c7d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c80:	ff 75 0c             	pushl  0xc(%ebp)
  801c83:	01 d8                	add    %ebx,%eax
  801c85:	50                   	push   %eax
  801c86:	e8 c5 ff ff ff       	call   801c50 <strcpy>
	return dst;
}
  801c8b:	89 d8                	mov    %ebx,%eax
  801c8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c90:	c9                   	leave  
  801c91:	c3                   	ret    

00801c92 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c92:	55                   	push   %ebp
  801c93:	89 e5                	mov    %esp,%ebp
  801c95:	56                   	push   %esi
  801c96:	53                   	push   %ebx
  801c97:	8b 75 08             	mov    0x8(%ebp),%esi
  801c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9d:	89 f3                	mov    %esi,%ebx
  801c9f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ca2:	89 f2                	mov    %esi,%edx
  801ca4:	eb 0f                	jmp    801cb5 <strncpy+0x23>
		*dst++ = *src;
  801ca6:	83 c2 01             	add    $0x1,%edx
  801ca9:	0f b6 01             	movzbl (%ecx),%eax
  801cac:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801caf:	80 39 01             	cmpb   $0x1,(%ecx)
  801cb2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cb5:	39 da                	cmp    %ebx,%edx
  801cb7:	75 ed                	jne    801ca6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801cb9:	89 f0                	mov    %esi,%eax
  801cbb:	5b                   	pop    %ebx
  801cbc:	5e                   	pop    %esi
  801cbd:	5d                   	pop    %ebp
  801cbe:	c3                   	ret    

00801cbf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	8b 75 08             	mov    0x8(%ebp),%esi
  801cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cca:	8b 55 10             	mov    0x10(%ebp),%edx
  801ccd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ccf:	85 d2                	test   %edx,%edx
  801cd1:	74 21                	je     801cf4 <strlcpy+0x35>
  801cd3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cd7:	89 f2                	mov    %esi,%edx
  801cd9:	eb 09                	jmp    801ce4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cdb:	83 c2 01             	add    $0x1,%edx
  801cde:	83 c1 01             	add    $0x1,%ecx
  801ce1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ce4:	39 c2                	cmp    %eax,%edx
  801ce6:	74 09                	je     801cf1 <strlcpy+0x32>
  801ce8:	0f b6 19             	movzbl (%ecx),%ebx
  801ceb:	84 db                	test   %bl,%bl
  801ced:	75 ec                	jne    801cdb <strlcpy+0x1c>
  801cef:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cf1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cf4:	29 f0                	sub    %esi,%eax
}
  801cf6:	5b                   	pop    %ebx
  801cf7:	5e                   	pop    %esi
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    

00801cfa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d00:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d03:	eb 06                	jmp    801d0b <strcmp+0x11>
		p++, q++;
  801d05:	83 c1 01             	add    $0x1,%ecx
  801d08:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d0b:	0f b6 01             	movzbl (%ecx),%eax
  801d0e:	84 c0                	test   %al,%al
  801d10:	74 04                	je     801d16 <strcmp+0x1c>
  801d12:	3a 02                	cmp    (%edx),%al
  801d14:	74 ef                	je     801d05 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d16:	0f b6 c0             	movzbl %al,%eax
  801d19:	0f b6 12             	movzbl (%edx),%edx
  801d1c:	29 d0                	sub    %edx,%eax
}
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    

00801d20 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	53                   	push   %ebx
  801d24:	8b 45 08             	mov    0x8(%ebp),%eax
  801d27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d2f:	eb 06                	jmp    801d37 <strncmp+0x17>
		n--, p++, q++;
  801d31:	83 c0 01             	add    $0x1,%eax
  801d34:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d37:	39 d8                	cmp    %ebx,%eax
  801d39:	74 15                	je     801d50 <strncmp+0x30>
  801d3b:	0f b6 08             	movzbl (%eax),%ecx
  801d3e:	84 c9                	test   %cl,%cl
  801d40:	74 04                	je     801d46 <strncmp+0x26>
  801d42:	3a 0a                	cmp    (%edx),%cl
  801d44:	74 eb                	je     801d31 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d46:	0f b6 00             	movzbl (%eax),%eax
  801d49:	0f b6 12             	movzbl (%edx),%edx
  801d4c:	29 d0                	sub    %edx,%eax
  801d4e:	eb 05                	jmp    801d55 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d50:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d55:	5b                   	pop    %ebx
  801d56:	5d                   	pop    %ebp
  801d57:	c3                   	ret    

00801d58 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d62:	eb 07                	jmp    801d6b <strchr+0x13>
		if (*s == c)
  801d64:	38 ca                	cmp    %cl,%dl
  801d66:	74 0f                	je     801d77 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d68:	83 c0 01             	add    $0x1,%eax
  801d6b:	0f b6 10             	movzbl (%eax),%edx
  801d6e:	84 d2                	test   %dl,%dl
  801d70:	75 f2                	jne    801d64 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d83:	eb 03                	jmp    801d88 <strfind+0xf>
  801d85:	83 c0 01             	add    $0x1,%eax
  801d88:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d8b:	38 ca                	cmp    %cl,%dl
  801d8d:	74 04                	je     801d93 <strfind+0x1a>
  801d8f:	84 d2                	test   %dl,%dl
  801d91:	75 f2                	jne    801d85 <strfind+0xc>
			break;
	return (char *) s;
}
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	57                   	push   %edi
  801d99:	56                   	push   %esi
  801d9a:	53                   	push   %ebx
  801d9b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801da1:	85 c9                	test   %ecx,%ecx
  801da3:	74 36                	je     801ddb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801da5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801dab:	75 28                	jne    801dd5 <memset+0x40>
  801dad:	f6 c1 03             	test   $0x3,%cl
  801db0:	75 23                	jne    801dd5 <memset+0x40>
		c &= 0xFF;
  801db2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801db6:	89 d3                	mov    %edx,%ebx
  801db8:	c1 e3 08             	shl    $0x8,%ebx
  801dbb:	89 d6                	mov    %edx,%esi
  801dbd:	c1 e6 18             	shl    $0x18,%esi
  801dc0:	89 d0                	mov    %edx,%eax
  801dc2:	c1 e0 10             	shl    $0x10,%eax
  801dc5:	09 f0                	or     %esi,%eax
  801dc7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801dc9:	89 d8                	mov    %ebx,%eax
  801dcb:	09 d0                	or     %edx,%eax
  801dcd:	c1 e9 02             	shr    $0x2,%ecx
  801dd0:	fc                   	cld    
  801dd1:	f3 ab                	rep stos %eax,%es:(%edi)
  801dd3:	eb 06                	jmp    801ddb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd8:	fc                   	cld    
  801dd9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ddb:	89 f8                	mov    %edi,%eax
  801ddd:	5b                   	pop    %ebx
  801dde:	5e                   	pop    %esi
  801ddf:	5f                   	pop    %edi
  801de0:	5d                   	pop    %ebp
  801de1:	c3                   	ret    

00801de2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	57                   	push   %edi
  801de6:	56                   	push   %esi
  801de7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dea:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ded:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801df0:	39 c6                	cmp    %eax,%esi
  801df2:	73 35                	jae    801e29 <memmove+0x47>
  801df4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801df7:	39 d0                	cmp    %edx,%eax
  801df9:	73 2e                	jae    801e29 <memmove+0x47>
		s += n;
		d += n;
  801dfb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dfe:	89 d6                	mov    %edx,%esi
  801e00:	09 fe                	or     %edi,%esi
  801e02:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e08:	75 13                	jne    801e1d <memmove+0x3b>
  801e0a:	f6 c1 03             	test   $0x3,%cl
  801e0d:	75 0e                	jne    801e1d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e0f:	83 ef 04             	sub    $0x4,%edi
  801e12:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e15:	c1 e9 02             	shr    $0x2,%ecx
  801e18:	fd                   	std    
  801e19:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e1b:	eb 09                	jmp    801e26 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e1d:	83 ef 01             	sub    $0x1,%edi
  801e20:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e23:	fd                   	std    
  801e24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e26:	fc                   	cld    
  801e27:	eb 1d                	jmp    801e46 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e29:	89 f2                	mov    %esi,%edx
  801e2b:	09 c2                	or     %eax,%edx
  801e2d:	f6 c2 03             	test   $0x3,%dl
  801e30:	75 0f                	jne    801e41 <memmove+0x5f>
  801e32:	f6 c1 03             	test   $0x3,%cl
  801e35:	75 0a                	jne    801e41 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e37:	c1 e9 02             	shr    $0x2,%ecx
  801e3a:	89 c7                	mov    %eax,%edi
  801e3c:	fc                   	cld    
  801e3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e3f:	eb 05                	jmp    801e46 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e41:	89 c7                	mov    %eax,%edi
  801e43:	fc                   	cld    
  801e44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e46:	5e                   	pop    %esi
  801e47:	5f                   	pop    %edi
  801e48:	5d                   	pop    %ebp
  801e49:	c3                   	ret    

00801e4a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e4d:	ff 75 10             	pushl  0x10(%ebp)
  801e50:	ff 75 0c             	pushl  0xc(%ebp)
  801e53:	ff 75 08             	pushl  0x8(%ebp)
  801e56:	e8 87 ff ff ff       	call   801de2 <memmove>
}
  801e5b:	c9                   	leave  
  801e5c:	c3                   	ret    

00801e5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e5d:	55                   	push   %ebp
  801e5e:	89 e5                	mov    %esp,%ebp
  801e60:	56                   	push   %esi
  801e61:	53                   	push   %ebx
  801e62:	8b 45 08             	mov    0x8(%ebp),%eax
  801e65:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e68:	89 c6                	mov    %eax,%esi
  801e6a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e6d:	eb 1a                	jmp    801e89 <memcmp+0x2c>
		if (*s1 != *s2)
  801e6f:	0f b6 08             	movzbl (%eax),%ecx
  801e72:	0f b6 1a             	movzbl (%edx),%ebx
  801e75:	38 d9                	cmp    %bl,%cl
  801e77:	74 0a                	je     801e83 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e79:	0f b6 c1             	movzbl %cl,%eax
  801e7c:	0f b6 db             	movzbl %bl,%ebx
  801e7f:	29 d8                	sub    %ebx,%eax
  801e81:	eb 0f                	jmp    801e92 <memcmp+0x35>
		s1++, s2++;
  801e83:	83 c0 01             	add    $0x1,%eax
  801e86:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e89:	39 f0                	cmp    %esi,%eax
  801e8b:	75 e2                	jne    801e6f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e92:	5b                   	pop    %ebx
  801e93:	5e                   	pop    %esi
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    

00801e96 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	53                   	push   %ebx
  801e9a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e9d:	89 c1                	mov    %eax,%ecx
  801e9f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801ea2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ea6:	eb 0a                	jmp    801eb2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ea8:	0f b6 10             	movzbl (%eax),%edx
  801eab:	39 da                	cmp    %ebx,%edx
  801ead:	74 07                	je     801eb6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801eaf:	83 c0 01             	add    $0x1,%eax
  801eb2:	39 c8                	cmp    %ecx,%eax
  801eb4:	72 f2                	jb     801ea8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801eb6:	5b                   	pop    %ebx
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	57                   	push   %edi
  801ebd:	56                   	push   %esi
  801ebe:	53                   	push   %ebx
  801ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ec5:	eb 03                	jmp    801eca <strtol+0x11>
		s++;
  801ec7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801eca:	0f b6 01             	movzbl (%ecx),%eax
  801ecd:	3c 20                	cmp    $0x20,%al
  801ecf:	74 f6                	je     801ec7 <strtol+0xe>
  801ed1:	3c 09                	cmp    $0x9,%al
  801ed3:	74 f2                	je     801ec7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ed5:	3c 2b                	cmp    $0x2b,%al
  801ed7:	75 0a                	jne    801ee3 <strtol+0x2a>
		s++;
  801ed9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801edc:	bf 00 00 00 00       	mov    $0x0,%edi
  801ee1:	eb 11                	jmp    801ef4 <strtol+0x3b>
  801ee3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ee8:	3c 2d                	cmp    $0x2d,%al
  801eea:	75 08                	jne    801ef4 <strtol+0x3b>
		s++, neg = 1;
  801eec:	83 c1 01             	add    $0x1,%ecx
  801eef:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ef4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801efa:	75 15                	jne    801f11 <strtol+0x58>
  801efc:	80 39 30             	cmpb   $0x30,(%ecx)
  801eff:	75 10                	jne    801f11 <strtol+0x58>
  801f01:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f05:	75 7c                	jne    801f83 <strtol+0xca>
		s += 2, base = 16;
  801f07:	83 c1 02             	add    $0x2,%ecx
  801f0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f0f:	eb 16                	jmp    801f27 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f11:	85 db                	test   %ebx,%ebx
  801f13:	75 12                	jne    801f27 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f15:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f1a:	80 39 30             	cmpb   $0x30,(%ecx)
  801f1d:	75 08                	jne    801f27 <strtol+0x6e>
		s++, base = 8;
  801f1f:	83 c1 01             	add    $0x1,%ecx
  801f22:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f27:	b8 00 00 00 00       	mov    $0x0,%eax
  801f2c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f2f:	0f b6 11             	movzbl (%ecx),%edx
  801f32:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f35:	89 f3                	mov    %esi,%ebx
  801f37:	80 fb 09             	cmp    $0x9,%bl
  801f3a:	77 08                	ja     801f44 <strtol+0x8b>
			dig = *s - '0';
  801f3c:	0f be d2             	movsbl %dl,%edx
  801f3f:	83 ea 30             	sub    $0x30,%edx
  801f42:	eb 22                	jmp    801f66 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f44:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f47:	89 f3                	mov    %esi,%ebx
  801f49:	80 fb 19             	cmp    $0x19,%bl
  801f4c:	77 08                	ja     801f56 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f4e:	0f be d2             	movsbl %dl,%edx
  801f51:	83 ea 57             	sub    $0x57,%edx
  801f54:	eb 10                	jmp    801f66 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f56:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f59:	89 f3                	mov    %esi,%ebx
  801f5b:	80 fb 19             	cmp    $0x19,%bl
  801f5e:	77 16                	ja     801f76 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f60:	0f be d2             	movsbl %dl,%edx
  801f63:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f66:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f69:	7d 0b                	jge    801f76 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f6b:	83 c1 01             	add    $0x1,%ecx
  801f6e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f72:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f74:	eb b9                	jmp    801f2f <strtol+0x76>

	if (endptr)
  801f76:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f7a:	74 0d                	je     801f89 <strtol+0xd0>
		*endptr = (char *) s;
  801f7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f7f:	89 0e                	mov    %ecx,(%esi)
  801f81:	eb 06                	jmp    801f89 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f83:	85 db                	test   %ebx,%ebx
  801f85:	74 98                	je     801f1f <strtol+0x66>
  801f87:	eb 9e                	jmp    801f27 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f89:	89 c2                	mov    %eax,%edx
  801f8b:	f7 da                	neg    %edx
  801f8d:	85 ff                	test   %edi,%edi
  801f8f:	0f 45 c2             	cmovne %edx,%eax
}
  801f92:	5b                   	pop    %ebx
  801f93:	5e                   	pop    %esi
  801f94:	5f                   	pop    %edi
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    

00801f97 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f9d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fa4:	75 2a                	jne    801fd0 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fa6:	83 ec 04             	sub    $0x4,%esp
  801fa9:	6a 07                	push   $0x7
  801fab:	68 00 f0 bf ee       	push   $0xeebff000
  801fb0:	6a 00                	push   $0x0
  801fb2:	e8 ed e1 ff ff       	call   8001a4 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fb7:	83 c4 10             	add    $0x10,%esp
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	79 12                	jns    801fd0 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fbe:	50                   	push   %eax
  801fbf:	68 dd 24 80 00       	push   $0x8024dd
  801fc4:	6a 23                	push   $0x23
  801fc6:	68 00 29 80 00       	push   $0x802900
  801fcb:	e8 22 f6 ff ff       	call   8015f2 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd3:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fd8:	83 ec 08             	sub    $0x8,%esp
  801fdb:	68 02 20 80 00       	push   $0x802002
  801fe0:	6a 00                	push   $0x0
  801fe2:	e8 08 e3 ff ff       	call   8002ef <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fe7:	83 c4 10             	add    $0x10,%esp
  801fea:	85 c0                	test   %eax,%eax
  801fec:	79 12                	jns    802000 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fee:	50                   	push   %eax
  801fef:	68 dd 24 80 00       	push   $0x8024dd
  801ff4:	6a 2c                	push   $0x2c
  801ff6:	68 00 29 80 00       	push   $0x802900
  801ffb:	e8 f2 f5 ff ff       	call   8015f2 <_panic>
	}
}
  802000:	c9                   	leave  
  802001:	c3                   	ret    

00802002 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802002:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802003:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802008:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80200a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80200d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802011:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802016:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80201a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80201c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80201f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802020:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802023:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802024:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802025:	c3                   	ret    

00802026 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	56                   	push   %esi
  80202a:	53                   	push   %ebx
  80202b:	8b 75 08             	mov    0x8(%ebp),%esi
  80202e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802031:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802034:	85 c0                	test   %eax,%eax
  802036:	75 12                	jne    80204a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802038:	83 ec 0c             	sub    $0xc,%esp
  80203b:	68 00 00 c0 ee       	push   $0xeec00000
  802040:	e8 0f e3 ff ff       	call   800354 <sys_ipc_recv>
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	eb 0c                	jmp    802056 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80204a:	83 ec 0c             	sub    $0xc,%esp
  80204d:	50                   	push   %eax
  80204e:	e8 01 e3 ff ff       	call   800354 <sys_ipc_recv>
  802053:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802056:	85 f6                	test   %esi,%esi
  802058:	0f 95 c1             	setne  %cl
  80205b:	85 db                	test   %ebx,%ebx
  80205d:	0f 95 c2             	setne  %dl
  802060:	84 d1                	test   %dl,%cl
  802062:	74 09                	je     80206d <ipc_recv+0x47>
  802064:	89 c2                	mov    %eax,%edx
  802066:	c1 ea 1f             	shr    $0x1f,%edx
  802069:	84 d2                	test   %dl,%dl
  80206b:	75 2d                	jne    80209a <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80206d:	85 f6                	test   %esi,%esi
  80206f:	74 0d                	je     80207e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802071:	a1 04 40 80 00       	mov    0x804004,%eax
  802076:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80207c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80207e:	85 db                	test   %ebx,%ebx
  802080:	74 0d                	je     80208f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802082:	a1 04 40 80 00       	mov    0x804004,%eax
  802087:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80208d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80208f:	a1 04 40 80 00       	mov    0x804004,%eax
  802094:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80209a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5d                   	pop    %ebp
  8020a0:	c3                   	ret    

008020a1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a1:	55                   	push   %ebp
  8020a2:	89 e5                	mov    %esp,%ebp
  8020a4:	57                   	push   %edi
  8020a5:	56                   	push   %esi
  8020a6:	53                   	push   %ebx
  8020a7:	83 ec 0c             	sub    $0xc,%esp
  8020aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020b3:	85 db                	test   %ebx,%ebx
  8020b5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020ba:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020bd:	ff 75 14             	pushl  0x14(%ebp)
  8020c0:	53                   	push   %ebx
  8020c1:	56                   	push   %esi
  8020c2:	57                   	push   %edi
  8020c3:	e8 69 e2 ff ff       	call   800331 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020c8:	89 c2                	mov    %eax,%edx
  8020ca:	c1 ea 1f             	shr    $0x1f,%edx
  8020cd:	83 c4 10             	add    $0x10,%esp
  8020d0:	84 d2                	test   %dl,%dl
  8020d2:	74 17                	je     8020eb <ipc_send+0x4a>
  8020d4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d7:	74 12                	je     8020eb <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020d9:	50                   	push   %eax
  8020da:	68 0e 29 80 00       	push   $0x80290e
  8020df:	6a 47                	push   $0x47
  8020e1:	68 1c 29 80 00       	push   $0x80291c
  8020e6:	e8 07 f5 ff ff       	call   8015f2 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ee:	75 07                	jne    8020f7 <ipc_send+0x56>
			sys_yield();
  8020f0:	e8 90 e0 ff ff       	call   800185 <sys_yield>
  8020f5:	eb c6                	jmp    8020bd <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	75 c2                	jne    8020bd <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fe:	5b                   	pop    %ebx
  8020ff:	5e                   	pop    %esi
  802100:	5f                   	pop    %edi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    

00802103 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802103:	55                   	push   %ebp
  802104:	89 e5                	mov    %esp,%ebp
  802106:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802109:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80210e:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802114:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80211a:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  802120:	39 ca                	cmp    %ecx,%edx
  802122:	75 13                	jne    802137 <ipc_find_env+0x34>
			return envs[i].env_id;
  802124:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  80212a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80212f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802135:	eb 0f                	jmp    802146 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802137:	83 c0 01             	add    $0x1,%eax
  80213a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80213f:	75 cd                	jne    80210e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802141:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    

00802148 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802148:	55                   	push   %ebp
  802149:	89 e5                	mov    %esp,%ebp
  80214b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80214e:	89 d0                	mov    %edx,%eax
  802150:	c1 e8 16             	shr    $0x16,%eax
  802153:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80215a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80215f:	f6 c1 01             	test   $0x1,%cl
  802162:	74 1d                	je     802181 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802164:	c1 ea 0c             	shr    $0xc,%edx
  802167:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80216e:	f6 c2 01             	test   $0x1,%dl
  802171:	74 0e                	je     802181 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802173:	c1 ea 0c             	shr    $0xc,%edx
  802176:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80217d:	ef 
  80217e:	0f b7 c0             	movzwl %ax,%eax
}
  802181:	5d                   	pop    %ebp
  802182:	c3                   	ret    
  802183:	66 90                	xchg   %ax,%ax
  802185:	66 90                	xchg   %ax,%ax
  802187:	66 90                	xchg   %ax,%ax
  802189:	66 90                	xchg   %ax,%ax
  80218b:	66 90                	xchg   %ax,%ax
  80218d:	66 90                	xchg   %ax,%ax
  80218f:	90                   	nop

00802190 <__udivdi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80219b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80219f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 f6                	test   %esi,%esi
  8021a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ad:	89 ca                	mov    %ecx,%edx
  8021af:	89 f8                	mov    %edi,%eax
  8021b1:	75 3d                	jne    8021f0 <__udivdi3+0x60>
  8021b3:	39 cf                	cmp    %ecx,%edi
  8021b5:	0f 87 c5 00 00 00    	ja     802280 <__udivdi3+0xf0>
  8021bb:	85 ff                	test   %edi,%edi
  8021bd:	89 fd                	mov    %edi,%ebp
  8021bf:	75 0b                	jne    8021cc <__udivdi3+0x3c>
  8021c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c6:	31 d2                	xor    %edx,%edx
  8021c8:	f7 f7                	div    %edi
  8021ca:	89 c5                	mov    %eax,%ebp
  8021cc:	89 c8                	mov    %ecx,%eax
  8021ce:	31 d2                	xor    %edx,%edx
  8021d0:	f7 f5                	div    %ebp
  8021d2:	89 c1                	mov    %eax,%ecx
  8021d4:	89 d8                	mov    %ebx,%eax
  8021d6:	89 cf                	mov    %ecx,%edi
  8021d8:	f7 f5                	div    %ebp
  8021da:	89 c3                	mov    %eax,%ebx
  8021dc:	89 d8                	mov    %ebx,%eax
  8021de:	89 fa                	mov    %edi,%edx
  8021e0:	83 c4 1c             	add    $0x1c,%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5e                   	pop    %esi
  8021e5:	5f                   	pop    %edi
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    
  8021e8:	90                   	nop
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	39 ce                	cmp    %ecx,%esi
  8021f2:	77 74                	ja     802268 <__udivdi3+0xd8>
  8021f4:	0f bd fe             	bsr    %esi,%edi
  8021f7:	83 f7 1f             	xor    $0x1f,%edi
  8021fa:	0f 84 98 00 00 00    	je     802298 <__udivdi3+0x108>
  802200:	bb 20 00 00 00       	mov    $0x20,%ebx
  802205:	89 f9                	mov    %edi,%ecx
  802207:	89 c5                	mov    %eax,%ebp
  802209:	29 fb                	sub    %edi,%ebx
  80220b:	d3 e6                	shl    %cl,%esi
  80220d:	89 d9                	mov    %ebx,%ecx
  80220f:	d3 ed                	shr    %cl,%ebp
  802211:	89 f9                	mov    %edi,%ecx
  802213:	d3 e0                	shl    %cl,%eax
  802215:	09 ee                	or     %ebp,%esi
  802217:	89 d9                	mov    %ebx,%ecx
  802219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80221d:	89 d5                	mov    %edx,%ebp
  80221f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802223:	d3 ed                	shr    %cl,%ebp
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e2                	shl    %cl,%edx
  802229:	89 d9                	mov    %ebx,%ecx
  80222b:	d3 e8                	shr    %cl,%eax
  80222d:	09 c2                	or     %eax,%edx
  80222f:	89 d0                	mov    %edx,%eax
  802231:	89 ea                	mov    %ebp,%edx
  802233:	f7 f6                	div    %esi
  802235:	89 d5                	mov    %edx,%ebp
  802237:	89 c3                	mov    %eax,%ebx
  802239:	f7 64 24 0c          	mull   0xc(%esp)
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	72 10                	jb     802251 <__udivdi3+0xc1>
  802241:	8b 74 24 08          	mov    0x8(%esp),%esi
  802245:	89 f9                	mov    %edi,%ecx
  802247:	d3 e6                	shl    %cl,%esi
  802249:	39 c6                	cmp    %eax,%esi
  80224b:	73 07                	jae    802254 <__udivdi3+0xc4>
  80224d:	39 d5                	cmp    %edx,%ebp
  80224f:	75 03                	jne    802254 <__udivdi3+0xc4>
  802251:	83 eb 01             	sub    $0x1,%ebx
  802254:	31 ff                	xor    %edi,%edi
  802256:	89 d8                	mov    %ebx,%eax
  802258:	89 fa                	mov    %edi,%edx
  80225a:	83 c4 1c             	add    $0x1c,%esp
  80225d:	5b                   	pop    %ebx
  80225e:	5e                   	pop    %esi
  80225f:	5f                   	pop    %edi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    
  802262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802268:	31 ff                	xor    %edi,%edi
  80226a:	31 db                	xor    %ebx,%ebx
  80226c:	89 d8                	mov    %ebx,%eax
  80226e:	89 fa                	mov    %edi,%edx
  802270:	83 c4 1c             	add    $0x1c,%esp
  802273:	5b                   	pop    %ebx
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	90                   	nop
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	89 d8                	mov    %ebx,%eax
  802282:	f7 f7                	div    %edi
  802284:	31 ff                	xor    %edi,%edi
  802286:	89 c3                	mov    %eax,%ebx
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	89 fa                	mov    %edi,%edx
  80228c:	83 c4 1c             	add    $0x1c,%esp
  80228f:	5b                   	pop    %ebx
  802290:	5e                   	pop    %esi
  802291:	5f                   	pop    %edi
  802292:	5d                   	pop    %ebp
  802293:	c3                   	ret    
  802294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802298:	39 ce                	cmp    %ecx,%esi
  80229a:	72 0c                	jb     8022a8 <__udivdi3+0x118>
  80229c:	31 db                	xor    %ebx,%ebx
  80229e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022a2:	0f 87 34 ff ff ff    	ja     8021dc <__udivdi3+0x4c>
  8022a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022ad:	e9 2a ff ff ff       	jmp    8021dc <__udivdi3+0x4c>
  8022b2:	66 90                	xchg   %ax,%ax
  8022b4:	66 90                	xchg   %ax,%ax
  8022b6:	66 90                	xchg   %ax,%ax
  8022b8:	66 90                	xchg   %ax,%ax
  8022ba:	66 90                	xchg   %ax,%ax
  8022bc:	66 90                	xchg   %ax,%ax
  8022be:	66 90                	xchg   %ax,%ax

008022c0 <__umoddi3>:
  8022c0:	55                   	push   %ebp
  8022c1:	57                   	push   %edi
  8022c2:	56                   	push   %esi
  8022c3:	53                   	push   %ebx
  8022c4:	83 ec 1c             	sub    $0x1c,%esp
  8022c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022d7:	85 d2                	test   %edx,%edx
  8022d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022e1:	89 f3                	mov    %esi,%ebx
  8022e3:	89 3c 24             	mov    %edi,(%esp)
  8022e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ea:	75 1c                	jne    802308 <__umoddi3+0x48>
  8022ec:	39 f7                	cmp    %esi,%edi
  8022ee:	76 50                	jbe    802340 <__umoddi3+0x80>
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	f7 f7                	div    %edi
  8022f6:	89 d0                	mov    %edx,%eax
  8022f8:	31 d2                	xor    %edx,%edx
  8022fa:	83 c4 1c             	add    $0x1c,%esp
  8022fd:	5b                   	pop    %ebx
  8022fe:	5e                   	pop    %esi
  8022ff:	5f                   	pop    %edi
  802300:	5d                   	pop    %ebp
  802301:	c3                   	ret    
  802302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802308:	39 f2                	cmp    %esi,%edx
  80230a:	89 d0                	mov    %edx,%eax
  80230c:	77 52                	ja     802360 <__umoddi3+0xa0>
  80230e:	0f bd ea             	bsr    %edx,%ebp
  802311:	83 f5 1f             	xor    $0x1f,%ebp
  802314:	75 5a                	jne    802370 <__umoddi3+0xb0>
  802316:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80231a:	0f 82 e0 00 00 00    	jb     802400 <__umoddi3+0x140>
  802320:	39 0c 24             	cmp    %ecx,(%esp)
  802323:	0f 86 d7 00 00 00    	jbe    802400 <__umoddi3+0x140>
  802329:	8b 44 24 08          	mov    0x8(%esp),%eax
  80232d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802331:	83 c4 1c             	add    $0x1c,%esp
  802334:	5b                   	pop    %ebx
  802335:	5e                   	pop    %esi
  802336:	5f                   	pop    %edi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	85 ff                	test   %edi,%edi
  802342:	89 fd                	mov    %edi,%ebp
  802344:	75 0b                	jne    802351 <__umoddi3+0x91>
  802346:	b8 01 00 00 00       	mov    $0x1,%eax
  80234b:	31 d2                	xor    %edx,%edx
  80234d:	f7 f7                	div    %edi
  80234f:	89 c5                	mov    %eax,%ebp
  802351:	89 f0                	mov    %esi,%eax
  802353:	31 d2                	xor    %edx,%edx
  802355:	f7 f5                	div    %ebp
  802357:	89 c8                	mov    %ecx,%eax
  802359:	f7 f5                	div    %ebp
  80235b:	89 d0                	mov    %edx,%eax
  80235d:	eb 99                	jmp    8022f8 <__umoddi3+0x38>
  80235f:	90                   	nop
  802360:	89 c8                	mov    %ecx,%eax
  802362:	89 f2                	mov    %esi,%edx
  802364:	83 c4 1c             	add    $0x1c,%esp
  802367:	5b                   	pop    %ebx
  802368:	5e                   	pop    %esi
  802369:	5f                   	pop    %edi
  80236a:	5d                   	pop    %ebp
  80236b:	c3                   	ret    
  80236c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802370:	8b 34 24             	mov    (%esp),%esi
  802373:	bf 20 00 00 00       	mov    $0x20,%edi
  802378:	89 e9                	mov    %ebp,%ecx
  80237a:	29 ef                	sub    %ebp,%edi
  80237c:	d3 e0                	shl    %cl,%eax
  80237e:	89 f9                	mov    %edi,%ecx
  802380:	89 f2                	mov    %esi,%edx
  802382:	d3 ea                	shr    %cl,%edx
  802384:	89 e9                	mov    %ebp,%ecx
  802386:	09 c2                	or     %eax,%edx
  802388:	89 d8                	mov    %ebx,%eax
  80238a:	89 14 24             	mov    %edx,(%esp)
  80238d:	89 f2                	mov    %esi,%edx
  80238f:	d3 e2                	shl    %cl,%edx
  802391:	89 f9                	mov    %edi,%ecx
  802393:	89 54 24 04          	mov    %edx,0x4(%esp)
  802397:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80239b:	d3 e8                	shr    %cl,%eax
  80239d:	89 e9                	mov    %ebp,%ecx
  80239f:	89 c6                	mov    %eax,%esi
  8023a1:	d3 e3                	shl    %cl,%ebx
  8023a3:	89 f9                	mov    %edi,%ecx
  8023a5:	89 d0                	mov    %edx,%eax
  8023a7:	d3 e8                	shr    %cl,%eax
  8023a9:	89 e9                	mov    %ebp,%ecx
  8023ab:	09 d8                	or     %ebx,%eax
  8023ad:	89 d3                	mov    %edx,%ebx
  8023af:	89 f2                	mov    %esi,%edx
  8023b1:	f7 34 24             	divl   (%esp)
  8023b4:	89 d6                	mov    %edx,%esi
  8023b6:	d3 e3                	shl    %cl,%ebx
  8023b8:	f7 64 24 04          	mull   0x4(%esp)
  8023bc:	39 d6                	cmp    %edx,%esi
  8023be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023c2:	89 d1                	mov    %edx,%ecx
  8023c4:	89 c3                	mov    %eax,%ebx
  8023c6:	72 08                	jb     8023d0 <__umoddi3+0x110>
  8023c8:	75 11                	jne    8023db <__umoddi3+0x11b>
  8023ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ce:	73 0b                	jae    8023db <__umoddi3+0x11b>
  8023d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023d4:	1b 14 24             	sbb    (%esp),%edx
  8023d7:	89 d1                	mov    %edx,%ecx
  8023d9:	89 c3                	mov    %eax,%ebx
  8023db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023df:	29 da                	sub    %ebx,%edx
  8023e1:	19 ce                	sbb    %ecx,%esi
  8023e3:	89 f9                	mov    %edi,%ecx
  8023e5:	89 f0                	mov    %esi,%eax
  8023e7:	d3 e0                	shl    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	d3 ea                	shr    %cl,%edx
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	d3 ee                	shr    %cl,%esi
  8023f1:	09 d0                	or     %edx,%eax
  8023f3:	89 f2                	mov    %esi,%edx
  8023f5:	83 c4 1c             	add    $0x1c,%esp
  8023f8:	5b                   	pop    %ebx
  8023f9:	5e                   	pop    %esi
  8023fa:	5f                   	pop    %edi
  8023fb:	5d                   	pop    %ebp
  8023fc:	c3                   	ret    
  8023fd:	8d 76 00             	lea    0x0(%esi),%esi
  802400:	29 f9                	sub    %edi,%ecx
  802402:	19 d6                	sbb    %edx,%esi
  802404:	89 74 24 04          	mov    %esi,0x4(%esp)
  802408:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80240c:	e9 18 ff ff ff       	jmp    802329 <__umoddi3+0x69>
