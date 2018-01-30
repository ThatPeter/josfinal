
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
  8000d4:	e8 e4 09 00 00       	call   800abd <close_all>
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
  800159:	e8 90 14 00 00       	call   8015ee <_panic>

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
  8001da:	e8 0f 14 00 00       	call   8015ee <_panic>

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
  80021c:	e8 cd 13 00 00       	call   8015ee <_panic>

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
  80025e:	e8 8b 13 00 00       	call   8015ee <_panic>

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
  8002a0:	e8 49 13 00 00       	call   8015ee <_panic>

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
  8002e2:	e8 07 13 00 00       	call   8015ee <_panic>
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
  800324:	e8 c5 12 00 00       	call   8015ee <_panic>

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
  800388:	e8 61 12 00 00       	call   8015ee <_panic>

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
  800427:	e8 c2 11 00 00       	call   8015ee <_panic>
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
  800451:	e8 98 11 00 00       	call   8015ee <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800456:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80045c:	83 ec 04             	sub    $0x4,%esp
  80045f:	68 00 10 00 00       	push   $0x1000
  800464:	53                   	push   %ebx
  800465:	68 00 f0 7f 00       	push   $0x7ff000
  80046a:	e8 d7 19 00 00       	call   801e46 <memcpy>

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
  800499:	e8 50 11 00 00       	call   8015ee <_panic>
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
  8004c1:	e8 28 11 00 00       	call   8015ee <_panic>
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
  8004d9:	e8 b5 1a 00 00       	call   801f93 <set_pgfault_handler>
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
  800501:	e8 e8 10 00 00       	call   8015ee <_panic>
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
  8005ba:	e8 2f 10 00 00       	call   8015ee <_panic>
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
  8005ff:	e8 ea 0f 00 00       	call   8015ee <_panic>
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
  80062d:	e8 bc 0f 00 00       	call   8015ee <_panic>
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
  800657:	e8 92 0f 00 00       	call   8015ee <_panic>
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
  800717:	e8 d2 0e 00 00       	call   8015ee <_panic>
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
  80077d:	e8 6c 0e 00 00       	call   8015ee <_panic>
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
  80078e:	53                   	push   %ebx
  80078f:	83 ec 04             	sub    $0x4,%esp
  800792:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800795:	b8 01 00 00 00       	mov    $0x1,%eax
  80079a:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  80079d:	85 c0                	test   %eax,%eax
  80079f:	74 45                	je     8007e6 <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  8007a1:	e8 c0 f9 ff ff       	call   800166 <sys_getenvid>
  8007a6:	83 ec 08             	sub    $0x8,%esp
  8007a9:	83 c3 04             	add    $0x4,%ebx
  8007ac:	53                   	push   %ebx
  8007ad:	50                   	push   %eax
  8007ae:	e8 35 ff ff ff       	call   8006e8 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  8007b3:	e8 ae f9 ff ff       	call   800166 <sys_getenvid>
  8007b8:	83 c4 08             	add    $0x8,%esp
  8007bb:	6a 04                	push   $0x4
  8007bd:	50                   	push   %eax
  8007be:	e8 a8 fa ff ff       	call   80026b <sys_env_set_status>

		if (r < 0) {
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	79 15                	jns    8007df <mutex_lock+0x54>
			panic("%e\n", r);
  8007ca:	50                   	push   %eax
  8007cb:	68 dd 24 80 00       	push   $0x8024dd
  8007d0:	68 02 01 00 00       	push   $0x102
  8007d5:	68 65 24 80 00       	push   $0x802465
  8007da:	e8 0f 0e 00 00       	call   8015ee <_panic>
		}
		sys_yield();
  8007df:	e8 a1 f9 ff ff       	call   800185 <sys_yield>
  8007e4:	eb 08                	jmp    8007ee <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8007e6:	e8 7b f9 ff ff       	call   800166 <sys_getenvid>
  8007eb:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8007ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8007fd:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  800801:	74 36                	je     800839 <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  800803:	83 ec 0c             	sub    $0xc,%esp
  800806:	8d 43 04             	lea    0x4(%ebx),%eax
  800809:	50                   	push   %eax
  80080a:	e8 4d ff ff ff       	call   80075c <queue_pop>
  80080f:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800812:	83 c4 08             	add    $0x8,%esp
  800815:	6a 02                	push   $0x2
  800817:	50                   	push   %eax
  800818:	e8 4e fa ff ff       	call   80026b <sys_env_set_status>
		if (r < 0) {
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	85 c0                	test   %eax,%eax
  800822:	79 1d                	jns    800841 <mutex_unlock+0x4e>
			panic("%e\n", r);
  800824:	50                   	push   %eax
  800825:	68 dd 24 80 00       	push   $0x8024dd
  80082a:	68 16 01 00 00       	push   $0x116
  80082f:	68 65 24 80 00       	push   $0x802465
  800834:	e8 b5 0d 00 00       	call   8015ee <_panic>
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
  80083e:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  800841:	e8 3f f9 ff ff       	call   800185 <sys_yield>
}
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 04             	sub    $0x4,%esp
  800852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800855:	e8 0c f9 ff ff       	call   800166 <sys_getenvid>
  80085a:	83 ec 04             	sub    $0x4,%esp
  80085d:	6a 07                	push   $0x7
  80085f:	53                   	push   %ebx
  800860:	50                   	push   %eax
  800861:	e8 3e f9 ff ff       	call   8001a4 <sys_page_alloc>
  800866:	83 c4 10             	add    $0x10,%esp
  800869:	85 c0                	test   %eax,%eax
  80086b:	79 15                	jns    800882 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  80086d:	50                   	push   %eax
  80086e:	68 c8 24 80 00       	push   $0x8024c8
  800873:	68 23 01 00 00       	push   $0x123
  800878:	68 65 24 80 00       	push   $0x802465
  80087d:	e8 6c 0d 00 00       	call   8015ee <_panic>
	}	
	mtx->locked = 0;
  800882:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  800888:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  80088f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  800896:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  80089d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
  8008a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8008aa:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8008ad:	eb 20                	jmp    8008cf <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  8008af:	83 ec 0c             	sub    $0xc,%esp
  8008b2:	56                   	push   %esi
  8008b3:	e8 a4 fe ff ff       	call   80075c <queue_pop>
  8008b8:	83 c4 08             	add    $0x8,%esp
  8008bb:	6a 02                	push   $0x2
  8008bd:	50                   	push   %eax
  8008be:	e8 a8 f9 ff ff       	call   80026b <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  8008c3:	8b 43 04             	mov    0x4(%ebx),%eax
  8008c6:	8b 40 04             	mov    0x4(%eax),%eax
  8008c9:	89 43 04             	mov    %eax,0x4(%ebx)
  8008cc:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8008cf:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8008d3:	75 da                	jne    8008af <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008d5:	83 ec 04             	sub    $0x4,%esp
  8008d8:	68 00 10 00 00       	push   $0x1000
  8008dd:	6a 00                	push   $0x0
  8008df:	53                   	push   %ebx
  8008e0:	e8 ac 14 00 00       	call   801d91 <memset>
	mtx = NULL;
}
  8008e5:	83 c4 10             	add    $0x10,%esp
  8008e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008ef:	55                   	push   %ebp
  8008f0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f5:	05 00 00 00 30       	add    $0x30000000,%eax
  8008fa:	c1 e8 0c             	shr    $0xc,%eax
}
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	05 00 00 00 30       	add    $0x30000000,%eax
  80090a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80090f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800921:	89 c2                	mov    %eax,%edx
  800923:	c1 ea 16             	shr    $0x16,%edx
  800926:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80092d:	f6 c2 01             	test   $0x1,%dl
  800930:	74 11                	je     800943 <fd_alloc+0x2d>
  800932:	89 c2                	mov    %eax,%edx
  800934:	c1 ea 0c             	shr    $0xc,%edx
  800937:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80093e:	f6 c2 01             	test   $0x1,%dl
  800941:	75 09                	jne    80094c <fd_alloc+0x36>
			*fd_store = fd;
  800943:	89 01                	mov    %eax,(%ecx)
			return 0;
  800945:	b8 00 00 00 00       	mov    $0x0,%eax
  80094a:	eb 17                	jmp    800963 <fd_alloc+0x4d>
  80094c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800951:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800956:	75 c9                	jne    800921 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800958:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80095e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80096b:	83 f8 1f             	cmp    $0x1f,%eax
  80096e:	77 36                	ja     8009a6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800970:	c1 e0 0c             	shl    $0xc,%eax
  800973:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800978:	89 c2                	mov    %eax,%edx
  80097a:	c1 ea 16             	shr    $0x16,%edx
  80097d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800984:	f6 c2 01             	test   $0x1,%dl
  800987:	74 24                	je     8009ad <fd_lookup+0x48>
  800989:	89 c2                	mov    %eax,%edx
  80098b:	c1 ea 0c             	shr    $0xc,%edx
  80098e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800995:	f6 c2 01             	test   $0x1,%dl
  800998:	74 1a                	je     8009b4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099d:	89 02                	mov    %eax,(%edx)
	return 0;
  80099f:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a4:	eb 13                	jmp    8009b9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8009a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009ab:	eb 0c                	jmp    8009b9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8009ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b2:	eb 05                	jmp    8009b9 <fd_lookup+0x54>
  8009b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 08             	sub    $0x8,%esp
  8009c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c4:	ba 60 25 80 00       	mov    $0x802560,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009c9:	eb 13                	jmp    8009de <dev_lookup+0x23>
  8009cb:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009ce:	39 08                	cmp    %ecx,(%eax)
  8009d0:	75 0c                	jne    8009de <dev_lookup+0x23>
			*dev = devtab[i];
  8009d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	eb 31                	jmp    800a0f <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009de:	8b 02                	mov    (%edx),%eax
  8009e0:	85 c0                	test   %eax,%eax
  8009e2:	75 e7                	jne    8009cb <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009e4:	a1 04 40 80 00       	mov    0x804004,%eax
  8009e9:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009ef:	83 ec 04             	sub    $0x4,%esp
  8009f2:	51                   	push   %ecx
  8009f3:	50                   	push   %eax
  8009f4:	68 e4 24 80 00       	push   $0x8024e4
  8009f9:	e8 c9 0c 00 00       	call   8016c7 <cprintf>
	*dev = 0;
  8009fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a07:	83 c4 10             	add    $0x10,%esp
  800a0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	83 ec 10             	sub    $0x10,%esp
  800a19:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a22:	50                   	push   %eax
  800a23:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a29:	c1 e8 0c             	shr    $0xc,%eax
  800a2c:	50                   	push   %eax
  800a2d:	e8 33 ff ff ff       	call   800965 <fd_lookup>
  800a32:	83 c4 08             	add    $0x8,%esp
  800a35:	85 c0                	test   %eax,%eax
  800a37:	78 05                	js     800a3e <fd_close+0x2d>
	    || fd != fd2)
  800a39:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a3c:	74 0c                	je     800a4a <fd_close+0x39>
		return (must_exist ? r : 0);
  800a3e:	84 db                	test   %bl,%bl
  800a40:	ba 00 00 00 00       	mov    $0x0,%edx
  800a45:	0f 44 c2             	cmove  %edx,%eax
  800a48:	eb 41                	jmp    800a8b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a4a:	83 ec 08             	sub    $0x8,%esp
  800a4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a50:	50                   	push   %eax
  800a51:	ff 36                	pushl  (%esi)
  800a53:	e8 63 ff ff ff       	call   8009bb <dev_lookup>
  800a58:	89 c3                	mov    %eax,%ebx
  800a5a:	83 c4 10             	add    $0x10,%esp
  800a5d:	85 c0                	test   %eax,%eax
  800a5f:	78 1a                	js     800a7b <fd_close+0x6a>
		if (dev->dev_close)
  800a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a64:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a67:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a6c:	85 c0                	test   %eax,%eax
  800a6e:	74 0b                	je     800a7b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a70:	83 ec 0c             	sub    $0xc,%esp
  800a73:	56                   	push   %esi
  800a74:	ff d0                	call   *%eax
  800a76:	89 c3                	mov    %eax,%ebx
  800a78:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a7b:	83 ec 08             	sub    $0x8,%esp
  800a7e:	56                   	push   %esi
  800a7f:	6a 00                	push   $0x0
  800a81:	e8 a3 f7 ff ff       	call   800229 <sys_page_unmap>
	return r;
  800a86:	83 c4 10             	add    $0x10,%esp
  800a89:	89 d8                	mov    %ebx,%eax
}
  800a8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a9b:	50                   	push   %eax
  800a9c:	ff 75 08             	pushl  0x8(%ebp)
  800a9f:	e8 c1 fe ff ff       	call   800965 <fd_lookup>
  800aa4:	83 c4 08             	add    $0x8,%esp
  800aa7:	85 c0                	test   %eax,%eax
  800aa9:	78 10                	js     800abb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800aab:	83 ec 08             	sub    $0x8,%esp
  800aae:	6a 01                	push   $0x1
  800ab0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ab3:	e8 59 ff ff ff       	call   800a11 <fd_close>
  800ab8:	83 c4 10             	add    $0x10,%esp
}
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <close_all>:

void
close_all(void)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	53                   	push   %ebx
  800ac1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ac4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	53                   	push   %ebx
  800acd:	e8 c0 ff ff ff       	call   800a92 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800ad2:	83 c3 01             	add    $0x1,%ebx
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	83 fb 20             	cmp    $0x20,%ebx
  800adb:	75 ec                	jne    800ac9 <close_all+0xc>
		close(i);
}
  800add:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	83 ec 2c             	sub    $0x2c,%esp
  800aeb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800aee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800af1:	50                   	push   %eax
  800af2:	ff 75 08             	pushl  0x8(%ebp)
  800af5:	e8 6b fe ff ff       	call   800965 <fd_lookup>
  800afa:	83 c4 08             	add    $0x8,%esp
  800afd:	85 c0                	test   %eax,%eax
  800aff:	0f 88 c1 00 00 00    	js     800bc6 <dup+0xe4>
		return r;
	close(newfdnum);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	56                   	push   %esi
  800b09:	e8 84 ff ff ff       	call   800a92 <close>

	newfd = INDEX2FD(newfdnum);
  800b0e:	89 f3                	mov    %esi,%ebx
  800b10:	c1 e3 0c             	shl    $0xc,%ebx
  800b13:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b19:	83 c4 04             	add    $0x4,%esp
  800b1c:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b1f:	e8 db fd ff ff       	call   8008ff <fd2data>
  800b24:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b26:	89 1c 24             	mov    %ebx,(%esp)
  800b29:	e8 d1 fd ff ff       	call   8008ff <fd2data>
  800b2e:	83 c4 10             	add    $0x10,%esp
  800b31:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	c1 e8 16             	shr    $0x16,%eax
  800b39:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b40:	a8 01                	test   $0x1,%al
  800b42:	74 37                	je     800b7b <dup+0x99>
  800b44:	89 f8                	mov    %edi,%eax
  800b46:	c1 e8 0c             	shr    $0xc,%eax
  800b49:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b50:	f6 c2 01             	test   $0x1,%dl
  800b53:	74 26                	je     800b7b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b55:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	25 07 0e 00 00       	and    $0xe07,%eax
  800b64:	50                   	push   %eax
  800b65:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b68:	6a 00                	push   $0x0
  800b6a:	57                   	push   %edi
  800b6b:	6a 00                	push   $0x0
  800b6d:	e8 75 f6 ff ff       	call   8001e7 <sys_page_map>
  800b72:	89 c7                	mov    %eax,%edi
  800b74:	83 c4 20             	add    $0x20,%esp
  800b77:	85 c0                	test   %eax,%eax
  800b79:	78 2e                	js     800ba9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b7b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b7e:	89 d0                	mov    %edx,%eax
  800b80:	c1 e8 0c             	shr    $0xc,%eax
  800b83:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	25 07 0e 00 00       	and    $0xe07,%eax
  800b92:	50                   	push   %eax
  800b93:	53                   	push   %ebx
  800b94:	6a 00                	push   $0x0
  800b96:	52                   	push   %edx
  800b97:	6a 00                	push   $0x0
  800b99:	e8 49 f6 ff ff       	call   8001e7 <sys_page_map>
  800b9e:	89 c7                	mov    %eax,%edi
  800ba0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800ba3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ba5:	85 ff                	test   %edi,%edi
  800ba7:	79 1d                	jns    800bc6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ba9:	83 ec 08             	sub    $0x8,%esp
  800bac:	53                   	push   %ebx
  800bad:	6a 00                	push   $0x0
  800baf:	e8 75 f6 ff ff       	call   800229 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800bb4:	83 c4 08             	add    $0x8,%esp
  800bb7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bba:	6a 00                	push   $0x0
  800bbc:	e8 68 f6 ff ff       	call   800229 <sys_page_unmap>
	return r;
  800bc1:	83 c4 10             	add    $0x10,%esp
  800bc4:	89 f8                	mov    %edi,%eax
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 14             	sub    $0x14,%esp
  800bd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bdb:	50                   	push   %eax
  800bdc:	53                   	push   %ebx
  800bdd:	e8 83 fd ff ff       	call   800965 <fd_lookup>
  800be2:	83 c4 08             	add    $0x8,%esp
  800be5:	89 c2                	mov    %eax,%edx
  800be7:	85 c0                	test   %eax,%eax
  800be9:	78 70                	js     800c5b <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800beb:	83 ec 08             	sub    $0x8,%esp
  800bee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf1:	50                   	push   %eax
  800bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf5:	ff 30                	pushl  (%eax)
  800bf7:	e8 bf fd ff ff       	call   8009bb <dev_lookup>
  800bfc:	83 c4 10             	add    $0x10,%esp
  800bff:	85 c0                	test   %eax,%eax
  800c01:	78 4f                	js     800c52 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c03:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c06:	8b 42 08             	mov    0x8(%edx),%eax
  800c09:	83 e0 03             	and    $0x3,%eax
  800c0c:	83 f8 01             	cmp    $0x1,%eax
  800c0f:	75 24                	jne    800c35 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c11:	a1 04 40 80 00       	mov    0x804004,%eax
  800c16:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800c1c:	83 ec 04             	sub    $0x4,%esp
  800c1f:	53                   	push   %ebx
  800c20:	50                   	push   %eax
  800c21:	68 25 25 80 00       	push   $0x802525
  800c26:	e8 9c 0a 00 00       	call   8016c7 <cprintf>
		return -E_INVAL;
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c33:	eb 26                	jmp    800c5b <read+0x8d>
	}
	if (!dev->dev_read)
  800c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c38:	8b 40 08             	mov    0x8(%eax),%eax
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	74 17                	je     800c56 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c3f:	83 ec 04             	sub    $0x4,%esp
  800c42:	ff 75 10             	pushl  0x10(%ebp)
  800c45:	ff 75 0c             	pushl  0xc(%ebp)
  800c48:	52                   	push   %edx
  800c49:	ff d0                	call   *%eax
  800c4b:	89 c2                	mov    %eax,%edx
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	eb 09                	jmp    800c5b <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c52:	89 c2                	mov    %eax,%edx
  800c54:	eb 05                	jmp    800c5b <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c56:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c5b:	89 d0                	mov    %edx,%eax
  800c5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c60:	c9                   	leave  
  800c61:	c3                   	ret    

00800c62 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
  800c6b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c6e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c76:	eb 21                	jmp    800c99 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c78:	83 ec 04             	sub    $0x4,%esp
  800c7b:	89 f0                	mov    %esi,%eax
  800c7d:	29 d8                	sub    %ebx,%eax
  800c7f:	50                   	push   %eax
  800c80:	89 d8                	mov    %ebx,%eax
  800c82:	03 45 0c             	add    0xc(%ebp),%eax
  800c85:	50                   	push   %eax
  800c86:	57                   	push   %edi
  800c87:	e8 42 ff ff ff       	call   800bce <read>
		if (m < 0)
  800c8c:	83 c4 10             	add    $0x10,%esp
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	78 10                	js     800ca3 <readn+0x41>
			return m;
		if (m == 0)
  800c93:	85 c0                	test   %eax,%eax
  800c95:	74 0a                	je     800ca1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c97:	01 c3                	add    %eax,%ebx
  800c99:	39 f3                	cmp    %esi,%ebx
  800c9b:	72 db                	jb     800c78 <readn+0x16>
  800c9d:	89 d8                	mov    %ebx,%eax
  800c9f:	eb 02                	jmp    800ca3 <readn+0x41>
  800ca1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800ca3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	53                   	push   %ebx
  800caf:	83 ec 14             	sub    $0x14,%esp
  800cb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cb5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cb8:	50                   	push   %eax
  800cb9:	53                   	push   %ebx
  800cba:	e8 a6 fc ff ff       	call   800965 <fd_lookup>
  800cbf:	83 c4 08             	add    $0x8,%esp
  800cc2:	89 c2                	mov    %eax,%edx
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	78 6b                	js     800d33 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cc8:	83 ec 08             	sub    $0x8,%esp
  800ccb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cce:	50                   	push   %eax
  800ccf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd2:	ff 30                	pushl  (%eax)
  800cd4:	e8 e2 fc ff ff       	call   8009bb <dev_lookup>
  800cd9:	83 c4 10             	add    $0x10,%esp
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	78 4a                	js     800d2a <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ce7:	75 24                	jne    800d0d <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800ce9:	a1 04 40 80 00       	mov    0x804004,%eax
  800cee:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800cf4:	83 ec 04             	sub    $0x4,%esp
  800cf7:	53                   	push   %ebx
  800cf8:	50                   	push   %eax
  800cf9:	68 41 25 80 00       	push   $0x802541
  800cfe:	e8 c4 09 00 00       	call   8016c7 <cprintf>
		return -E_INVAL;
  800d03:	83 c4 10             	add    $0x10,%esp
  800d06:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d0b:	eb 26                	jmp    800d33 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d10:	8b 52 0c             	mov    0xc(%edx),%edx
  800d13:	85 d2                	test   %edx,%edx
  800d15:	74 17                	je     800d2e <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d17:	83 ec 04             	sub    $0x4,%esp
  800d1a:	ff 75 10             	pushl  0x10(%ebp)
  800d1d:	ff 75 0c             	pushl  0xc(%ebp)
  800d20:	50                   	push   %eax
  800d21:	ff d2                	call   *%edx
  800d23:	89 c2                	mov    %eax,%edx
  800d25:	83 c4 10             	add    $0x10,%esp
  800d28:	eb 09                	jmp    800d33 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d2a:	89 c2                	mov    %eax,%edx
  800d2c:	eb 05                	jmp    800d33 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d2e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d33:	89 d0                	mov    %edx,%eax
  800d35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d38:	c9                   	leave  
  800d39:	c3                   	ret    

00800d3a <seek>:

int
seek(int fdnum, off_t offset)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d40:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d43:	50                   	push   %eax
  800d44:	ff 75 08             	pushl  0x8(%ebp)
  800d47:	e8 19 fc ff ff       	call   800965 <fd_lookup>
  800d4c:	83 c4 08             	add    $0x8,%esp
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	78 0e                	js     800d61 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d53:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d59:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d61:	c9                   	leave  
  800d62:	c3                   	ret    

00800d63 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	53                   	push   %ebx
  800d67:	83 ec 14             	sub    $0x14,%esp
  800d6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d70:	50                   	push   %eax
  800d71:	53                   	push   %ebx
  800d72:	e8 ee fb ff ff       	call   800965 <fd_lookup>
  800d77:	83 c4 08             	add    $0x8,%esp
  800d7a:	89 c2                	mov    %eax,%edx
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	78 68                	js     800de8 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d80:	83 ec 08             	sub    $0x8,%esp
  800d83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d86:	50                   	push   %eax
  800d87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d8a:	ff 30                	pushl  (%eax)
  800d8c:	e8 2a fc ff ff       	call   8009bb <dev_lookup>
  800d91:	83 c4 10             	add    $0x10,%esp
  800d94:	85 c0                	test   %eax,%eax
  800d96:	78 47                	js     800ddf <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d9b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d9f:	75 24                	jne    800dc5 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800da1:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800da6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800dac:	83 ec 04             	sub    $0x4,%esp
  800daf:	53                   	push   %ebx
  800db0:	50                   	push   %eax
  800db1:	68 04 25 80 00       	push   $0x802504
  800db6:	e8 0c 09 00 00       	call   8016c7 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800dc3:	eb 23                	jmp    800de8 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800dc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dc8:	8b 52 18             	mov    0x18(%edx),%edx
  800dcb:	85 d2                	test   %edx,%edx
  800dcd:	74 14                	je     800de3 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800dcf:	83 ec 08             	sub    $0x8,%esp
  800dd2:	ff 75 0c             	pushl  0xc(%ebp)
  800dd5:	50                   	push   %eax
  800dd6:	ff d2                	call   *%edx
  800dd8:	89 c2                	mov    %eax,%edx
  800dda:	83 c4 10             	add    $0x10,%esp
  800ddd:	eb 09                	jmp    800de8 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ddf:	89 c2                	mov    %eax,%edx
  800de1:	eb 05                	jmp    800de8 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800de3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800de8:	89 d0                	mov    %edx,%eax
  800dea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ded:	c9                   	leave  
  800dee:	c3                   	ret    

00800def <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	53                   	push   %ebx
  800df3:	83 ec 14             	sub    $0x14,%esp
  800df6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800df9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dfc:	50                   	push   %eax
  800dfd:	ff 75 08             	pushl  0x8(%ebp)
  800e00:	e8 60 fb ff ff       	call   800965 <fd_lookup>
  800e05:	83 c4 08             	add    $0x8,%esp
  800e08:	89 c2                	mov    %eax,%edx
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	78 58                	js     800e66 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e0e:	83 ec 08             	sub    $0x8,%esp
  800e11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e14:	50                   	push   %eax
  800e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e18:	ff 30                	pushl  (%eax)
  800e1a:	e8 9c fb ff ff       	call   8009bb <dev_lookup>
  800e1f:	83 c4 10             	add    $0x10,%esp
  800e22:	85 c0                	test   %eax,%eax
  800e24:	78 37                	js     800e5d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e29:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e2d:	74 32                	je     800e61 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e2f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e32:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e39:	00 00 00 
	stat->st_isdir = 0;
  800e3c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e43:	00 00 00 
	stat->st_dev = dev;
  800e46:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e4c:	83 ec 08             	sub    $0x8,%esp
  800e4f:	53                   	push   %ebx
  800e50:	ff 75 f0             	pushl  -0x10(%ebp)
  800e53:	ff 50 14             	call   *0x14(%eax)
  800e56:	89 c2                	mov    %eax,%edx
  800e58:	83 c4 10             	add    $0x10,%esp
  800e5b:	eb 09                	jmp    800e66 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e5d:	89 c2                	mov    %eax,%edx
  800e5f:	eb 05                	jmp    800e66 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e61:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e66:	89 d0                	mov    %edx,%eax
  800e68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6b:	c9                   	leave  
  800e6c:	c3                   	ret    

00800e6d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e72:	83 ec 08             	sub    $0x8,%esp
  800e75:	6a 00                	push   $0x0
  800e77:	ff 75 08             	pushl  0x8(%ebp)
  800e7a:	e8 e3 01 00 00       	call   801062 <open>
  800e7f:	89 c3                	mov    %eax,%ebx
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	85 c0                	test   %eax,%eax
  800e86:	78 1b                	js     800ea3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e88:	83 ec 08             	sub    $0x8,%esp
  800e8b:	ff 75 0c             	pushl  0xc(%ebp)
  800e8e:	50                   	push   %eax
  800e8f:	e8 5b ff ff ff       	call   800def <fstat>
  800e94:	89 c6                	mov    %eax,%esi
	close(fd);
  800e96:	89 1c 24             	mov    %ebx,(%esp)
  800e99:	e8 f4 fb ff ff       	call   800a92 <close>
	return r;
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	89 f0                	mov    %esi,%eax
}
  800ea3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea6:	5b                   	pop    %ebx
  800ea7:	5e                   	pop    %esi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	89 c6                	mov    %eax,%esi
  800eb1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800eb3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800eba:	75 12                	jne    800ece <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	6a 01                	push   $0x1
  800ec1:	e8 39 12 00 00       	call   8020ff <ipc_find_env>
  800ec6:	a3 00 40 80 00       	mov    %eax,0x804000
  800ecb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ece:	6a 07                	push   $0x7
  800ed0:	68 00 50 80 00       	push   $0x805000
  800ed5:	56                   	push   %esi
  800ed6:	ff 35 00 40 80 00    	pushl  0x804000
  800edc:	e8 bc 11 00 00       	call   80209d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ee1:	83 c4 0c             	add    $0xc,%esp
  800ee4:	6a 00                	push   $0x0
  800ee6:	53                   	push   %ebx
  800ee7:	6a 00                	push   $0x0
  800ee9:	e8 34 11 00 00       	call   802022 <ipc_recv>
}
  800eee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800efb:	8b 45 08             	mov    0x8(%ebp),%eax
  800efe:	8b 40 0c             	mov    0xc(%eax),%eax
  800f01:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f09:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f13:	b8 02 00 00 00       	mov    $0x2,%eax
  800f18:	e8 8d ff ff ff       	call   800eaa <fsipc>
}
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f25:	8b 45 08             	mov    0x8(%ebp),%eax
  800f28:	8b 40 0c             	mov    0xc(%eax),%eax
  800f2b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f30:	ba 00 00 00 00       	mov    $0x0,%edx
  800f35:	b8 06 00 00 00       	mov    $0x6,%eax
  800f3a:	e8 6b ff ff ff       	call   800eaa <fsipc>
}
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	53                   	push   %ebx
  800f45:	83 ec 04             	sub    $0x4,%esp
  800f48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4e:	8b 40 0c             	mov    0xc(%eax),%eax
  800f51:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f56:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5b:	b8 05 00 00 00       	mov    $0x5,%eax
  800f60:	e8 45 ff ff ff       	call   800eaa <fsipc>
  800f65:	85 c0                	test   %eax,%eax
  800f67:	78 2c                	js     800f95 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f69:	83 ec 08             	sub    $0x8,%esp
  800f6c:	68 00 50 80 00       	push   $0x805000
  800f71:	53                   	push   %ebx
  800f72:	e8 d5 0c 00 00       	call   801c4c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f77:	a1 80 50 80 00       	mov    0x805080,%eax
  800f7c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f82:	a1 84 50 80 00       	mov    0x805084,%eax
  800f87:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 0c             	sub    $0xc,%esp
  800fa0:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800fa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa6:	8b 52 0c             	mov    0xc(%edx),%edx
  800fa9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800faf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800fb4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800fb9:	0f 47 c2             	cmova  %edx,%eax
  800fbc:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800fc1:	50                   	push   %eax
  800fc2:	ff 75 0c             	pushl  0xc(%ebp)
  800fc5:	68 08 50 80 00       	push   $0x805008
  800fca:	e8 0f 0e 00 00       	call   801dde <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd4:	b8 04 00 00 00       	mov    $0x4,%eax
  800fd9:	e8 cc fe ff ff       	call   800eaa <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fde:	c9                   	leave  
  800fdf:	c3                   	ret    

00800fe0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	56                   	push   %esi
  800fe4:	53                   	push   %ebx
  800fe5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  800feb:	8b 40 0c             	mov    0xc(%eax),%eax
  800fee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ff3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ff9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ffe:	b8 03 00 00 00       	mov    $0x3,%eax
  801003:	e8 a2 fe ff ff       	call   800eaa <fsipc>
  801008:	89 c3                	mov    %eax,%ebx
  80100a:	85 c0                	test   %eax,%eax
  80100c:	78 4b                	js     801059 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80100e:	39 c6                	cmp    %eax,%esi
  801010:	73 16                	jae    801028 <devfile_read+0x48>
  801012:	68 70 25 80 00       	push   $0x802570
  801017:	68 77 25 80 00       	push   $0x802577
  80101c:	6a 7c                	push   $0x7c
  80101e:	68 8c 25 80 00       	push   $0x80258c
  801023:	e8 c6 05 00 00       	call   8015ee <_panic>
	assert(r <= PGSIZE);
  801028:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80102d:	7e 16                	jle    801045 <devfile_read+0x65>
  80102f:	68 97 25 80 00       	push   $0x802597
  801034:	68 77 25 80 00       	push   $0x802577
  801039:	6a 7d                	push   $0x7d
  80103b:	68 8c 25 80 00       	push   $0x80258c
  801040:	e8 a9 05 00 00       	call   8015ee <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801045:	83 ec 04             	sub    $0x4,%esp
  801048:	50                   	push   %eax
  801049:	68 00 50 80 00       	push   $0x805000
  80104e:	ff 75 0c             	pushl  0xc(%ebp)
  801051:	e8 88 0d 00 00       	call   801dde <memmove>
	return r;
  801056:	83 c4 10             	add    $0x10,%esp
}
  801059:	89 d8                	mov    %ebx,%eax
  80105b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80105e:	5b                   	pop    %ebx
  80105f:	5e                   	pop    %esi
  801060:	5d                   	pop    %ebp
  801061:	c3                   	ret    

00801062 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	53                   	push   %ebx
  801066:	83 ec 20             	sub    $0x20,%esp
  801069:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80106c:	53                   	push   %ebx
  80106d:	e8 a1 0b 00 00       	call   801c13 <strlen>
  801072:	83 c4 10             	add    $0x10,%esp
  801075:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80107a:	7f 67                	jg     8010e3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801082:	50                   	push   %eax
  801083:	e8 8e f8 ff ff       	call   800916 <fd_alloc>
  801088:	83 c4 10             	add    $0x10,%esp
		return r;
  80108b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80108d:	85 c0                	test   %eax,%eax
  80108f:	78 57                	js     8010e8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801091:	83 ec 08             	sub    $0x8,%esp
  801094:	53                   	push   %ebx
  801095:	68 00 50 80 00       	push   $0x805000
  80109a:	e8 ad 0b 00 00       	call   801c4c <strcpy>
	fsipcbuf.open.req_omode = mode;
  80109f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8010a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8010af:	e8 f6 fd ff ff       	call   800eaa <fsipc>
  8010b4:	89 c3                	mov    %eax,%ebx
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	79 14                	jns    8010d1 <open+0x6f>
		fd_close(fd, 0);
  8010bd:	83 ec 08             	sub    $0x8,%esp
  8010c0:	6a 00                	push   $0x0
  8010c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8010c5:	e8 47 f9 ff ff       	call   800a11 <fd_close>
		return r;
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	89 da                	mov    %ebx,%edx
  8010cf:	eb 17                	jmp    8010e8 <open+0x86>
	}

	return fd2num(fd);
  8010d1:	83 ec 0c             	sub    $0xc,%esp
  8010d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8010d7:	e8 13 f8 ff ff       	call   8008ef <fd2num>
  8010dc:	89 c2                	mov    %eax,%edx
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	eb 05                	jmp    8010e8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010e3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010e8:	89 d0                	mov    %edx,%eax
  8010ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ed:	c9                   	leave  
  8010ee:	c3                   	ret    

008010ef <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fa:	b8 08 00 00 00       	mov    $0x8,%eax
  8010ff:	e8 a6 fd ff ff       	call   800eaa <fsipc>
}
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	ff 75 08             	pushl  0x8(%ebp)
  801114:	e8 e6 f7 ff ff       	call   8008ff <fd2data>
  801119:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80111b:	83 c4 08             	add    $0x8,%esp
  80111e:	68 a3 25 80 00       	push   $0x8025a3
  801123:	53                   	push   %ebx
  801124:	e8 23 0b 00 00       	call   801c4c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801129:	8b 46 04             	mov    0x4(%esi),%eax
  80112c:	2b 06                	sub    (%esi),%eax
  80112e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801134:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80113b:	00 00 00 
	stat->st_dev = &devpipe;
  80113e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801145:	30 80 00 
	return 0;
}
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
  80114d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801150:	5b                   	pop    %ebx
  801151:	5e                   	pop    %esi
  801152:	5d                   	pop    %ebp
  801153:	c3                   	ret    

00801154 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	53                   	push   %ebx
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80115e:	53                   	push   %ebx
  80115f:	6a 00                	push   $0x0
  801161:	e8 c3 f0 ff ff       	call   800229 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801166:	89 1c 24             	mov    %ebx,(%esp)
  801169:	e8 91 f7 ff ff       	call   8008ff <fd2data>
  80116e:	83 c4 08             	add    $0x8,%esp
  801171:	50                   	push   %eax
  801172:	6a 00                	push   $0x0
  801174:	e8 b0 f0 ff ff       	call   800229 <sys_page_unmap>
}
  801179:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    

0080117e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80117e:	55                   	push   %ebp
  80117f:	89 e5                	mov    %esp,%ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	53                   	push   %ebx
  801184:	83 ec 1c             	sub    $0x1c,%esp
  801187:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80118a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80118c:	a1 04 40 80 00       	mov    0x804004,%eax
  801191:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801197:	83 ec 0c             	sub    $0xc,%esp
  80119a:	ff 75 e0             	pushl  -0x20(%ebp)
  80119d:	e8 a2 0f 00 00       	call   802144 <pageref>
  8011a2:	89 c3                	mov    %eax,%ebx
  8011a4:	89 3c 24             	mov    %edi,(%esp)
  8011a7:	e8 98 0f 00 00       	call   802144 <pageref>
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	39 c3                	cmp    %eax,%ebx
  8011b1:	0f 94 c1             	sete   %cl
  8011b4:	0f b6 c9             	movzbl %cl,%ecx
  8011b7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8011ba:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8011c0:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  8011c6:	39 ce                	cmp    %ecx,%esi
  8011c8:	74 1e                	je     8011e8 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011ca:	39 c3                	cmp    %eax,%ebx
  8011cc:	75 be                	jne    80118c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011ce:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011d4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d7:	50                   	push   %eax
  8011d8:	56                   	push   %esi
  8011d9:	68 aa 25 80 00       	push   $0x8025aa
  8011de:	e8 e4 04 00 00       	call   8016c7 <cprintf>
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	eb a4                	jmp    80118c <_pipeisclosed+0xe>
	}
}
  8011e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ee:	5b                   	pop    %ebx
  8011ef:	5e                   	pop    %esi
  8011f0:	5f                   	pop    %edi
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	57                   	push   %edi
  8011f7:	56                   	push   %esi
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 28             	sub    $0x28,%esp
  8011fc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011ff:	56                   	push   %esi
  801200:	e8 fa f6 ff ff       	call   8008ff <fd2data>
  801205:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	bf 00 00 00 00       	mov    $0x0,%edi
  80120f:	eb 4b                	jmp    80125c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801211:	89 da                	mov    %ebx,%edx
  801213:	89 f0                	mov    %esi,%eax
  801215:	e8 64 ff ff ff       	call   80117e <_pipeisclosed>
  80121a:	85 c0                	test   %eax,%eax
  80121c:	75 48                	jne    801266 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80121e:	e8 62 ef ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801223:	8b 43 04             	mov    0x4(%ebx),%eax
  801226:	8b 0b                	mov    (%ebx),%ecx
  801228:	8d 51 20             	lea    0x20(%ecx),%edx
  80122b:	39 d0                	cmp    %edx,%eax
  80122d:	73 e2                	jae    801211 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80122f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801232:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801236:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801239:	89 c2                	mov    %eax,%edx
  80123b:	c1 fa 1f             	sar    $0x1f,%edx
  80123e:	89 d1                	mov    %edx,%ecx
  801240:	c1 e9 1b             	shr    $0x1b,%ecx
  801243:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801246:	83 e2 1f             	and    $0x1f,%edx
  801249:	29 ca                	sub    %ecx,%edx
  80124b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80124f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801253:	83 c0 01             	add    $0x1,%eax
  801256:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801259:	83 c7 01             	add    $0x1,%edi
  80125c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80125f:	75 c2                	jne    801223 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801261:	8b 45 10             	mov    0x10(%ebp),%eax
  801264:	eb 05                	jmp    80126b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801266:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80126b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126e:	5b                   	pop    %ebx
  80126f:	5e                   	pop    %esi
  801270:	5f                   	pop    %edi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	57                   	push   %edi
  801277:	56                   	push   %esi
  801278:	53                   	push   %ebx
  801279:	83 ec 18             	sub    $0x18,%esp
  80127c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80127f:	57                   	push   %edi
  801280:	e8 7a f6 ff ff       	call   8008ff <fd2data>
  801285:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128f:	eb 3d                	jmp    8012ce <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801291:	85 db                	test   %ebx,%ebx
  801293:	74 04                	je     801299 <devpipe_read+0x26>
				return i;
  801295:	89 d8                	mov    %ebx,%eax
  801297:	eb 44                	jmp    8012dd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801299:	89 f2                	mov    %esi,%edx
  80129b:	89 f8                	mov    %edi,%eax
  80129d:	e8 dc fe ff ff       	call   80117e <_pipeisclosed>
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	75 32                	jne    8012d8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8012a6:	e8 da ee ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8012ab:	8b 06                	mov    (%esi),%eax
  8012ad:	3b 46 04             	cmp    0x4(%esi),%eax
  8012b0:	74 df                	je     801291 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8012b2:	99                   	cltd   
  8012b3:	c1 ea 1b             	shr    $0x1b,%edx
  8012b6:	01 d0                	add    %edx,%eax
  8012b8:	83 e0 1f             	and    $0x1f,%eax
  8012bb:	29 d0                	sub    %edx,%eax
  8012bd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8012c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012c8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012cb:	83 c3 01             	add    $0x1,%ebx
  8012ce:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012d1:	75 d8                	jne    8012ab <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8012d6:	eb 05                	jmp    8012dd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012d8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e0:	5b                   	pop    %ebx
  8012e1:	5e                   	pop    %esi
  8012e2:	5f                   	pop    %edi
  8012e3:	5d                   	pop    %ebp
  8012e4:	c3                   	ret    

008012e5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	56                   	push   %esi
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	e8 20 f6 ff ff       	call   800916 <fd_alloc>
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	0f 88 2c 01 00 00    	js     80142f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801303:	83 ec 04             	sub    $0x4,%esp
  801306:	68 07 04 00 00       	push   $0x407
  80130b:	ff 75 f4             	pushl  -0xc(%ebp)
  80130e:	6a 00                	push   $0x0
  801310:	e8 8f ee ff ff       	call   8001a4 <sys_page_alloc>
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	89 c2                	mov    %eax,%edx
  80131a:	85 c0                	test   %eax,%eax
  80131c:	0f 88 0d 01 00 00    	js     80142f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	e8 e8 f5 ff ff       	call   800916 <fd_alloc>
  80132e:	89 c3                	mov    %eax,%ebx
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	0f 88 e2 00 00 00    	js     80141d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80133b:	83 ec 04             	sub    $0x4,%esp
  80133e:	68 07 04 00 00       	push   $0x407
  801343:	ff 75 f0             	pushl  -0x10(%ebp)
  801346:	6a 00                	push   $0x0
  801348:	e8 57 ee ff ff       	call   8001a4 <sys_page_alloc>
  80134d:	89 c3                	mov    %eax,%ebx
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	0f 88 c3 00 00 00    	js     80141d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	ff 75 f4             	pushl  -0xc(%ebp)
  801360:	e8 9a f5 ff ff       	call   8008ff <fd2data>
  801365:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801367:	83 c4 0c             	add    $0xc,%esp
  80136a:	68 07 04 00 00       	push   $0x407
  80136f:	50                   	push   %eax
  801370:	6a 00                	push   $0x0
  801372:	e8 2d ee ff ff       	call   8001a4 <sys_page_alloc>
  801377:	89 c3                	mov    %eax,%ebx
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	0f 88 89 00 00 00    	js     80140d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801384:	83 ec 0c             	sub    $0xc,%esp
  801387:	ff 75 f0             	pushl  -0x10(%ebp)
  80138a:	e8 70 f5 ff ff       	call   8008ff <fd2data>
  80138f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801396:	50                   	push   %eax
  801397:	6a 00                	push   $0x0
  801399:	56                   	push   %esi
  80139a:	6a 00                	push   $0x0
  80139c:	e8 46 ee ff ff       	call   8001e7 <sys_page_map>
  8013a1:	89 c3                	mov    %eax,%ebx
  8013a3:	83 c4 20             	add    $0x20,%esp
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	78 55                	js     8013ff <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8013aa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8013b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8013bf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8013c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013d4:	83 ec 0c             	sub    $0xc,%esp
  8013d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013da:	e8 10 f5 ff ff       	call   8008ef <fd2num>
  8013df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013e4:	83 c4 04             	add    $0x4,%esp
  8013e7:	ff 75 f0             	pushl  -0x10(%ebp)
  8013ea:	e8 00 f5 ff ff       	call   8008ef <fd2num>
  8013ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f2:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fd:	eb 30                	jmp    80142f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	56                   	push   %esi
  801403:	6a 00                	push   $0x0
  801405:	e8 1f ee ff ff       	call   800229 <sys_page_unmap>
  80140a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	ff 75 f0             	pushl  -0x10(%ebp)
  801413:	6a 00                	push   $0x0
  801415:	e8 0f ee ff ff       	call   800229 <sys_page_unmap>
  80141a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	ff 75 f4             	pushl  -0xc(%ebp)
  801423:	6a 00                	push   $0x0
  801425:	e8 ff ed ff ff       	call   800229 <sys_page_unmap>
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80142f:	89 d0                	mov    %edx,%eax
  801431:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801434:	5b                   	pop    %ebx
  801435:	5e                   	pop    %esi
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    

00801438 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	ff 75 08             	pushl  0x8(%ebp)
  801445:	e8 1b f5 ff ff       	call   800965 <fd_lookup>
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 18                	js     801469 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801451:	83 ec 0c             	sub    $0xc,%esp
  801454:	ff 75 f4             	pushl  -0xc(%ebp)
  801457:	e8 a3 f4 ff ff       	call   8008ff <fd2data>
	return _pipeisclosed(fd, p);
  80145c:	89 c2                	mov    %eax,%edx
  80145e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801461:	e8 18 fd ff ff       	call   80117e <_pipeisclosed>
  801466:	83 c4 10             	add    $0x10,%esp
}
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80146e:	b8 00 00 00 00       	mov    $0x0,%eax
  801473:	5d                   	pop    %ebp
  801474:	c3                   	ret    

00801475 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80147b:	68 c2 25 80 00       	push   $0x8025c2
  801480:	ff 75 0c             	pushl  0xc(%ebp)
  801483:	e8 c4 07 00 00       	call   801c4c <strcpy>
	return 0;
}
  801488:	b8 00 00 00 00       	mov    $0x0,%eax
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	57                   	push   %edi
  801493:	56                   	push   %esi
  801494:	53                   	push   %ebx
  801495:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80149b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014a0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014a6:	eb 2d                	jmp    8014d5 <devcons_write+0x46>
		m = n - tot;
  8014a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014ab:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8014ad:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8014b0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8014b5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014b8:	83 ec 04             	sub    $0x4,%esp
  8014bb:	53                   	push   %ebx
  8014bc:	03 45 0c             	add    0xc(%ebp),%eax
  8014bf:	50                   	push   %eax
  8014c0:	57                   	push   %edi
  8014c1:	e8 18 09 00 00       	call   801dde <memmove>
		sys_cputs(buf, m);
  8014c6:	83 c4 08             	add    $0x8,%esp
  8014c9:	53                   	push   %ebx
  8014ca:	57                   	push   %edi
  8014cb:	e8 18 ec ff ff       	call   8000e8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014d0:	01 de                	add    %ebx,%esi
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	89 f0                	mov    %esi,%eax
  8014d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014da:	72 cc                	jb     8014a8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5f                   	pop    %edi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014ef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014f3:	74 2a                	je     80151f <devcons_read+0x3b>
  8014f5:	eb 05                	jmp    8014fc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014f7:	e8 89 ec ff ff       	call   800185 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014fc:	e8 05 ec ff ff       	call   800106 <sys_cgetc>
  801501:	85 c0                	test   %eax,%eax
  801503:	74 f2                	je     8014f7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801505:	85 c0                	test   %eax,%eax
  801507:	78 16                	js     80151f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801509:	83 f8 04             	cmp    $0x4,%eax
  80150c:	74 0c                	je     80151a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80150e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801511:	88 02                	mov    %al,(%edx)
	return 1;
  801513:	b8 01 00 00 00       	mov    $0x1,%eax
  801518:	eb 05                	jmp    80151f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80151a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80151f:	c9                   	leave  
  801520:	c3                   	ret    

00801521 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801521:	55                   	push   %ebp
  801522:	89 e5                	mov    %esp,%ebp
  801524:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801527:	8b 45 08             	mov    0x8(%ebp),%eax
  80152a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80152d:	6a 01                	push   $0x1
  80152f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801532:	50                   	push   %eax
  801533:	e8 b0 eb ff ff       	call   8000e8 <sys_cputs>
}
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	c9                   	leave  
  80153c:	c3                   	ret    

0080153d <getchar>:

int
getchar(void)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801543:	6a 01                	push   $0x1
  801545:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801548:	50                   	push   %eax
  801549:	6a 00                	push   $0x0
  80154b:	e8 7e f6 ff ff       	call   800bce <read>
	if (r < 0)
  801550:	83 c4 10             	add    $0x10,%esp
  801553:	85 c0                	test   %eax,%eax
  801555:	78 0f                	js     801566 <getchar+0x29>
		return r;
	if (r < 1)
  801557:	85 c0                	test   %eax,%eax
  801559:	7e 06                	jle    801561 <getchar+0x24>
		return -E_EOF;
	return c;
  80155b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80155f:	eb 05                	jmp    801566 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801561:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80156e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	ff 75 08             	pushl  0x8(%ebp)
  801575:	e8 eb f3 ff ff       	call   800965 <fd_lookup>
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 11                	js     801592 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801581:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801584:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80158a:	39 10                	cmp    %edx,(%eax)
  80158c:	0f 94 c0             	sete   %al
  80158f:	0f b6 c0             	movzbl %al,%eax
}
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <opencons>:

int
opencons(void)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80159a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	e8 73 f3 ff ff       	call   800916 <fd_alloc>
  8015a3:	83 c4 10             	add    $0x10,%esp
		return r;
  8015a6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 3e                	js     8015ea <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	68 07 04 00 00       	push   $0x407
  8015b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b7:	6a 00                	push   $0x0
  8015b9:	e8 e6 eb ff ff       	call   8001a4 <sys_page_alloc>
  8015be:	83 c4 10             	add    $0x10,%esp
		return r;
  8015c1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 23                	js     8015ea <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8015c7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015dc:	83 ec 0c             	sub    $0xc,%esp
  8015df:	50                   	push   %eax
  8015e0:	e8 0a f3 ff ff       	call   8008ef <fd2num>
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	83 c4 10             	add    $0x10,%esp
}
  8015ea:	89 d0                	mov    %edx,%eax
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	56                   	push   %esi
  8015f2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015f3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015f6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015fc:	e8 65 eb ff ff       	call   800166 <sys_getenvid>
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	ff 75 0c             	pushl  0xc(%ebp)
  801607:	ff 75 08             	pushl  0x8(%ebp)
  80160a:	56                   	push   %esi
  80160b:	50                   	push   %eax
  80160c:	68 d0 25 80 00       	push   $0x8025d0
  801611:	e8 b1 00 00 00       	call   8016c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801616:	83 c4 18             	add    $0x18,%esp
  801619:	53                   	push   %ebx
  80161a:	ff 75 10             	pushl  0x10(%ebp)
  80161d:	e8 54 00 00 00       	call   801676 <vcprintf>
	cprintf("\n");
  801622:	c7 04 24 c6 24 80 00 	movl   $0x8024c6,(%esp)
  801629:	e8 99 00 00 00       	call   8016c7 <cprintf>
  80162e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801631:	cc                   	int3   
  801632:	eb fd                	jmp    801631 <_panic+0x43>

00801634 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	53                   	push   %ebx
  801638:	83 ec 04             	sub    $0x4,%esp
  80163b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80163e:	8b 13                	mov    (%ebx),%edx
  801640:	8d 42 01             	lea    0x1(%edx),%eax
  801643:	89 03                	mov    %eax,(%ebx)
  801645:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801648:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80164c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801651:	75 1a                	jne    80166d <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801653:	83 ec 08             	sub    $0x8,%esp
  801656:	68 ff 00 00 00       	push   $0xff
  80165b:	8d 43 08             	lea    0x8(%ebx),%eax
  80165e:	50                   	push   %eax
  80165f:	e8 84 ea ff ff       	call   8000e8 <sys_cputs>
		b->idx = 0;
  801664:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80166a:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80166d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801671:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80167f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801686:	00 00 00 
	b.cnt = 0;
  801689:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801690:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801693:	ff 75 0c             	pushl  0xc(%ebp)
  801696:	ff 75 08             	pushl  0x8(%ebp)
  801699:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	68 34 16 80 00       	push   $0x801634
  8016a5:	e8 54 01 00 00       	call   8017fe <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8016aa:	83 c4 08             	add    $0x8,%esp
  8016ad:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8016b3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8016b9:	50                   	push   %eax
  8016ba:	e8 29 ea ff ff       	call   8000e8 <sys_cputs>

	return b.cnt;
}
  8016bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016c5:	c9                   	leave  
  8016c6:	c3                   	ret    

008016c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016cd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016d0:	50                   	push   %eax
  8016d1:	ff 75 08             	pushl  0x8(%ebp)
  8016d4:	e8 9d ff ff ff       	call   801676 <vcprintf>
	va_end(ap);

	return cnt;
}
  8016d9:	c9                   	leave  
  8016da:	c3                   	ret    

008016db <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016db:	55                   	push   %ebp
  8016dc:	89 e5                	mov    %esp,%ebp
  8016de:	57                   	push   %edi
  8016df:	56                   	push   %esi
  8016e0:	53                   	push   %ebx
  8016e1:	83 ec 1c             	sub    $0x1c,%esp
  8016e4:	89 c7                	mov    %eax,%edi
  8016e6:	89 d6                	mov    %edx,%esi
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016f1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016fc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016ff:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801702:	39 d3                	cmp    %edx,%ebx
  801704:	72 05                	jb     80170b <printnum+0x30>
  801706:	39 45 10             	cmp    %eax,0x10(%ebp)
  801709:	77 45                	ja     801750 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80170b:	83 ec 0c             	sub    $0xc,%esp
  80170e:	ff 75 18             	pushl  0x18(%ebp)
  801711:	8b 45 14             	mov    0x14(%ebp),%eax
  801714:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801717:	53                   	push   %ebx
  801718:	ff 75 10             	pushl  0x10(%ebp)
  80171b:	83 ec 08             	sub    $0x8,%esp
  80171e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801721:	ff 75 e0             	pushl  -0x20(%ebp)
  801724:	ff 75 dc             	pushl  -0x24(%ebp)
  801727:	ff 75 d8             	pushl  -0x28(%ebp)
  80172a:	e8 51 0a 00 00       	call   802180 <__udivdi3>
  80172f:	83 c4 18             	add    $0x18,%esp
  801732:	52                   	push   %edx
  801733:	50                   	push   %eax
  801734:	89 f2                	mov    %esi,%edx
  801736:	89 f8                	mov    %edi,%eax
  801738:	e8 9e ff ff ff       	call   8016db <printnum>
  80173d:	83 c4 20             	add    $0x20,%esp
  801740:	eb 18                	jmp    80175a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801742:	83 ec 08             	sub    $0x8,%esp
  801745:	56                   	push   %esi
  801746:	ff 75 18             	pushl  0x18(%ebp)
  801749:	ff d7                	call   *%edi
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	eb 03                	jmp    801753 <printnum+0x78>
  801750:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801753:	83 eb 01             	sub    $0x1,%ebx
  801756:	85 db                	test   %ebx,%ebx
  801758:	7f e8                	jg     801742 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80175a:	83 ec 08             	sub    $0x8,%esp
  80175d:	56                   	push   %esi
  80175e:	83 ec 04             	sub    $0x4,%esp
  801761:	ff 75 e4             	pushl  -0x1c(%ebp)
  801764:	ff 75 e0             	pushl  -0x20(%ebp)
  801767:	ff 75 dc             	pushl  -0x24(%ebp)
  80176a:	ff 75 d8             	pushl  -0x28(%ebp)
  80176d:	e8 3e 0b 00 00       	call   8022b0 <__umoddi3>
  801772:	83 c4 14             	add    $0x14,%esp
  801775:	0f be 80 f3 25 80 00 	movsbl 0x8025f3(%eax),%eax
  80177c:	50                   	push   %eax
  80177d:	ff d7                	call   *%edi
}
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5f                   	pop    %edi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80178d:	83 fa 01             	cmp    $0x1,%edx
  801790:	7e 0e                	jle    8017a0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801792:	8b 10                	mov    (%eax),%edx
  801794:	8d 4a 08             	lea    0x8(%edx),%ecx
  801797:	89 08                	mov    %ecx,(%eax)
  801799:	8b 02                	mov    (%edx),%eax
  80179b:	8b 52 04             	mov    0x4(%edx),%edx
  80179e:	eb 22                	jmp    8017c2 <getuint+0x38>
	else if (lflag)
  8017a0:	85 d2                	test   %edx,%edx
  8017a2:	74 10                	je     8017b4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8017a4:	8b 10                	mov    (%eax),%edx
  8017a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017a9:	89 08                	mov    %ecx,(%eax)
  8017ab:	8b 02                	mov    (%edx),%eax
  8017ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b2:	eb 0e                	jmp    8017c2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8017b4:	8b 10                	mov    (%eax),%edx
  8017b6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017b9:	89 08                	mov    %ecx,(%eax)
  8017bb:	8b 02                	mov    (%edx),%eax
  8017bd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017ca:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017ce:	8b 10                	mov    (%eax),%edx
  8017d0:	3b 50 04             	cmp    0x4(%eax),%edx
  8017d3:	73 0a                	jae    8017df <sprintputch+0x1b>
		*b->buf++ = ch;
  8017d5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017d8:	89 08                	mov    %ecx,(%eax)
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	88 02                	mov    %al,(%edx)
}
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017e7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017ea:	50                   	push   %eax
  8017eb:	ff 75 10             	pushl  0x10(%ebp)
  8017ee:	ff 75 0c             	pushl  0xc(%ebp)
  8017f1:	ff 75 08             	pushl  0x8(%ebp)
  8017f4:	e8 05 00 00 00       	call   8017fe <vprintfmt>
	va_end(ap);
}
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    

008017fe <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	57                   	push   %edi
  801802:	56                   	push   %esi
  801803:	53                   	push   %ebx
  801804:	83 ec 2c             	sub    $0x2c,%esp
  801807:	8b 75 08             	mov    0x8(%ebp),%esi
  80180a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80180d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801810:	eb 12                	jmp    801824 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801812:	85 c0                	test   %eax,%eax
  801814:	0f 84 89 03 00 00    	je     801ba3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	53                   	push   %ebx
  80181e:	50                   	push   %eax
  80181f:	ff d6                	call   *%esi
  801821:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801824:	83 c7 01             	add    $0x1,%edi
  801827:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80182b:	83 f8 25             	cmp    $0x25,%eax
  80182e:	75 e2                	jne    801812 <vprintfmt+0x14>
  801830:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801834:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80183b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801842:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801849:	ba 00 00 00 00       	mov    $0x0,%edx
  80184e:	eb 07                	jmp    801857 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801850:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801853:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801857:	8d 47 01             	lea    0x1(%edi),%eax
  80185a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80185d:	0f b6 07             	movzbl (%edi),%eax
  801860:	0f b6 c8             	movzbl %al,%ecx
  801863:	83 e8 23             	sub    $0x23,%eax
  801866:	3c 55                	cmp    $0x55,%al
  801868:	0f 87 1a 03 00 00    	ja     801b88 <vprintfmt+0x38a>
  80186e:	0f b6 c0             	movzbl %al,%eax
  801871:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  801878:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80187b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80187f:	eb d6                	jmp    801857 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801884:	b8 00 00 00 00       	mov    $0x0,%eax
  801889:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80188c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80188f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801893:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801896:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801899:	83 fa 09             	cmp    $0x9,%edx
  80189c:	77 39                	ja     8018d7 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80189e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8018a1:	eb e9                	jmp    80188c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a6:	8d 48 04             	lea    0x4(%eax),%ecx
  8018a9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8018ac:	8b 00                	mov    (%eax),%eax
  8018ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8018b4:	eb 27                	jmp    8018dd <vprintfmt+0xdf>
  8018b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8018c0:	0f 49 c8             	cmovns %eax,%ecx
  8018c3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018c9:	eb 8c                	jmp    801857 <vprintfmt+0x59>
  8018cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018d5:	eb 80                	jmp    801857 <vprintfmt+0x59>
  8018d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018da:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018e1:	0f 89 70 ff ff ff    	jns    801857 <vprintfmt+0x59>
				width = precision, precision = -1;
  8018e7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ed:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018f4:	e9 5e ff ff ff       	jmp    801857 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018f9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018ff:	e9 53 ff ff ff       	jmp    801857 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801904:	8b 45 14             	mov    0x14(%ebp),%eax
  801907:	8d 50 04             	lea    0x4(%eax),%edx
  80190a:	89 55 14             	mov    %edx,0x14(%ebp)
  80190d:	83 ec 08             	sub    $0x8,%esp
  801910:	53                   	push   %ebx
  801911:	ff 30                	pushl  (%eax)
  801913:	ff d6                	call   *%esi
			break;
  801915:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801918:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80191b:	e9 04 ff ff ff       	jmp    801824 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801920:	8b 45 14             	mov    0x14(%ebp),%eax
  801923:	8d 50 04             	lea    0x4(%eax),%edx
  801926:	89 55 14             	mov    %edx,0x14(%ebp)
  801929:	8b 00                	mov    (%eax),%eax
  80192b:	99                   	cltd   
  80192c:	31 d0                	xor    %edx,%eax
  80192e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801930:	83 f8 0f             	cmp    $0xf,%eax
  801933:	7f 0b                	jg     801940 <vprintfmt+0x142>
  801935:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  80193c:	85 d2                	test   %edx,%edx
  80193e:	75 18                	jne    801958 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801940:	50                   	push   %eax
  801941:	68 0b 26 80 00       	push   $0x80260b
  801946:	53                   	push   %ebx
  801947:	56                   	push   %esi
  801948:	e8 94 fe ff ff       	call   8017e1 <printfmt>
  80194d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801950:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801953:	e9 cc fe ff ff       	jmp    801824 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801958:	52                   	push   %edx
  801959:	68 89 25 80 00       	push   $0x802589
  80195e:	53                   	push   %ebx
  80195f:	56                   	push   %esi
  801960:	e8 7c fe ff ff       	call   8017e1 <printfmt>
  801965:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801968:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80196b:	e9 b4 fe ff ff       	jmp    801824 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801970:	8b 45 14             	mov    0x14(%ebp),%eax
  801973:	8d 50 04             	lea    0x4(%eax),%edx
  801976:	89 55 14             	mov    %edx,0x14(%ebp)
  801979:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80197b:	85 ff                	test   %edi,%edi
  80197d:	b8 04 26 80 00       	mov    $0x802604,%eax
  801982:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801985:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801989:	0f 8e 94 00 00 00    	jle    801a23 <vprintfmt+0x225>
  80198f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801993:	0f 84 98 00 00 00    	je     801a31 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801999:	83 ec 08             	sub    $0x8,%esp
  80199c:	ff 75 d0             	pushl  -0x30(%ebp)
  80199f:	57                   	push   %edi
  8019a0:	e8 86 02 00 00       	call   801c2b <strnlen>
  8019a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8019a8:	29 c1                	sub    %eax,%ecx
  8019aa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8019ad:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8019b0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8019b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019b7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8019ba:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019bc:	eb 0f                	jmp    8019cd <vprintfmt+0x1cf>
					putch(padc, putdat);
  8019be:	83 ec 08             	sub    $0x8,%esp
  8019c1:	53                   	push   %ebx
  8019c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8019c5:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019c7:	83 ef 01             	sub    $0x1,%edi
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	85 ff                	test   %edi,%edi
  8019cf:	7f ed                	jg     8019be <vprintfmt+0x1c0>
  8019d1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019d4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019d7:	85 c9                	test   %ecx,%ecx
  8019d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019de:	0f 49 c1             	cmovns %ecx,%eax
  8019e1:	29 c1                	sub    %eax,%ecx
  8019e3:	89 75 08             	mov    %esi,0x8(%ebp)
  8019e6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019e9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019ec:	89 cb                	mov    %ecx,%ebx
  8019ee:	eb 4d                	jmp    801a3d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019f4:	74 1b                	je     801a11 <vprintfmt+0x213>
  8019f6:	0f be c0             	movsbl %al,%eax
  8019f9:	83 e8 20             	sub    $0x20,%eax
  8019fc:	83 f8 5e             	cmp    $0x5e,%eax
  8019ff:	76 10                	jbe    801a11 <vprintfmt+0x213>
					putch('?', putdat);
  801a01:	83 ec 08             	sub    $0x8,%esp
  801a04:	ff 75 0c             	pushl  0xc(%ebp)
  801a07:	6a 3f                	push   $0x3f
  801a09:	ff 55 08             	call   *0x8(%ebp)
  801a0c:	83 c4 10             	add    $0x10,%esp
  801a0f:	eb 0d                	jmp    801a1e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a11:	83 ec 08             	sub    $0x8,%esp
  801a14:	ff 75 0c             	pushl  0xc(%ebp)
  801a17:	52                   	push   %edx
  801a18:	ff 55 08             	call   *0x8(%ebp)
  801a1b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a1e:	83 eb 01             	sub    $0x1,%ebx
  801a21:	eb 1a                	jmp    801a3d <vprintfmt+0x23f>
  801a23:	89 75 08             	mov    %esi,0x8(%ebp)
  801a26:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a29:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a2c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a2f:	eb 0c                	jmp    801a3d <vprintfmt+0x23f>
  801a31:	89 75 08             	mov    %esi,0x8(%ebp)
  801a34:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a37:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a3a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a3d:	83 c7 01             	add    $0x1,%edi
  801a40:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a44:	0f be d0             	movsbl %al,%edx
  801a47:	85 d2                	test   %edx,%edx
  801a49:	74 23                	je     801a6e <vprintfmt+0x270>
  801a4b:	85 f6                	test   %esi,%esi
  801a4d:	78 a1                	js     8019f0 <vprintfmt+0x1f2>
  801a4f:	83 ee 01             	sub    $0x1,%esi
  801a52:	79 9c                	jns    8019f0 <vprintfmt+0x1f2>
  801a54:	89 df                	mov    %ebx,%edi
  801a56:	8b 75 08             	mov    0x8(%ebp),%esi
  801a59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a5c:	eb 18                	jmp    801a76 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a5e:	83 ec 08             	sub    $0x8,%esp
  801a61:	53                   	push   %ebx
  801a62:	6a 20                	push   $0x20
  801a64:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a66:	83 ef 01             	sub    $0x1,%edi
  801a69:	83 c4 10             	add    $0x10,%esp
  801a6c:	eb 08                	jmp    801a76 <vprintfmt+0x278>
  801a6e:	89 df                	mov    %ebx,%edi
  801a70:	8b 75 08             	mov    0x8(%ebp),%esi
  801a73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a76:	85 ff                	test   %edi,%edi
  801a78:	7f e4                	jg     801a5e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a7d:	e9 a2 fd ff ff       	jmp    801824 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a82:	83 fa 01             	cmp    $0x1,%edx
  801a85:	7e 16                	jle    801a9d <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a87:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8a:	8d 50 08             	lea    0x8(%eax),%edx
  801a8d:	89 55 14             	mov    %edx,0x14(%ebp)
  801a90:	8b 50 04             	mov    0x4(%eax),%edx
  801a93:	8b 00                	mov    (%eax),%eax
  801a95:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a98:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a9b:	eb 32                	jmp    801acf <vprintfmt+0x2d1>
	else if (lflag)
  801a9d:	85 d2                	test   %edx,%edx
  801a9f:	74 18                	je     801ab9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801aa1:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa4:	8d 50 04             	lea    0x4(%eax),%edx
  801aa7:	89 55 14             	mov    %edx,0x14(%ebp)
  801aaa:	8b 00                	mov    (%eax),%eax
  801aac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aaf:	89 c1                	mov    %eax,%ecx
  801ab1:	c1 f9 1f             	sar    $0x1f,%ecx
  801ab4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801ab7:	eb 16                	jmp    801acf <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801ab9:	8b 45 14             	mov    0x14(%ebp),%eax
  801abc:	8d 50 04             	lea    0x4(%eax),%edx
  801abf:	89 55 14             	mov    %edx,0x14(%ebp)
  801ac2:	8b 00                	mov    (%eax),%eax
  801ac4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ac7:	89 c1                	mov    %eax,%ecx
  801ac9:	c1 f9 1f             	sar    $0x1f,%ecx
  801acc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801acf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ad2:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801ad5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ada:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ade:	79 74                	jns    801b54 <vprintfmt+0x356>
				putch('-', putdat);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	53                   	push   %ebx
  801ae4:	6a 2d                	push   $0x2d
  801ae6:	ff d6                	call   *%esi
				num = -(long long) num;
  801ae8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aeb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801aee:	f7 d8                	neg    %eax
  801af0:	83 d2 00             	adc    $0x0,%edx
  801af3:	f7 da                	neg    %edx
  801af5:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801af8:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801afd:	eb 55                	jmp    801b54 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801aff:	8d 45 14             	lea    0x14(%ebp),%eax
  801b02:	e8 83 fc ff ff       	call   80178a <getuint>
			base = 10;
  801b07:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b0c:	eb 46                	jmp    801b54 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b0e:	8d 45 14             	lea    0x14(%ebp),%eax
  801b11:	e8 74 fc ff ff       	call   80178a <getuint>
			base = 8;
  801b16:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b1b:	eb 37                	jmp    801b54 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b1d:	83 ec 08             	sub    $0x8,%esp
  801b20:	53                   	push   %ebx
  801b21:	6a 30                	push   $0x30
  801b23:	ff d6                	call   *%esi
			putch('x', putdat);
  801b25:	83 c4 08             	add    $0x8,%esp
  801b28:	53                   	push   %ebx
  801b29:	6a 78                	push   $0x78
  801b2b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801b30:	8d 50 04             	lea    0x4(%eax),%edx
  801b33:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b36:	8b 00                	mov    (%eax),%eax
  801b38:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b3d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b40:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b45:	eb 0d                	jmp    801b54 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b47:	8d 45 14             	lea    0x14(%ebp),%eax
  801b4a:	e8 3b fc ff ff       	call   80178a <getuint>
			base = 16;
  801b4f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b54:	83 ec 0c             	sub    $0xc,%esp
  801b57:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b5b:	57                   	push   %edi
  801b5c:	ff 75 e0             	pushl  -0x20(%ebp)
  801b5f:	51                   	push   %ecx
  801b60:	52                   	push   %edx
  801b61:	50                   	push   %eax
  801b62:	89 da                	mov    %ebx,%edx
  801b64:	89 f0                	mov    %esi,%eax
  801b66:	e8 70 fb ff ff       	call   8016db <printnum>
			break;
  801b6b:	83 c4 20             	add    $0x20,%esp
  801b6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b71:	e9 ae fc ff ff       	jmp    801824 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b76:	83 ec 08             	sub    $0x8,%esp
  801b79:	53                   	push   %ebx
  801b7a:	51                   	push   %ecx
  801b7b:	ff d6                	call   *%esi
			break;
  801b7d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b83:	e9 9c fc ff ff       	jmp    801824 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b88:	83 ec 08             	sub    $0x8,%esp
  801b8b:	53                   	push   %ebx
  801b8c:	6a 25                	push   $0x25
  801b8e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b90:	83 c4 10             	add    $0x10,%esp
  801b93:	eb 03                	jmp    801b98 <vprintfmt+0x39a>
  801b95:	83 ef 01             	sub    $0x1,%edi
  801b98:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b9c:	75 f7                	jne    801b95 <vprintfmt+0x397>
  801b9e:	e9 81 fc ff ff       	jmp    801824 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba6:	5b                   	pop    %ebx
  801ba7:	5e                   	pop    %esi
  801ba8:	5f                   	pop    %edi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 18             	sub    $0x18,%esp
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801bb7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801bba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801bbe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bc1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	74 26                	je     801bf2 <vsnprintf+0x47>
  801bcc:	85 d2                	test   %edx,%edx
  801bce:	7e 22                	jle    801bf2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801bd0:	ff 75 14             	pushl  0x14(%ebp)
  801bd3:	ff 75 10             	pushl  0x10(%ebp)
  801bd6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bd9:	50                   	push   %eax
  801bda:	68 c4 17 80 00       	push   $0x8017c4
  801bdf:	e8 1a fc ff ff       	call   8017fe <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801be4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801be7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	eb 05                	jmp    801bf7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bf2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bf7:	c9                   	leave  
  801bf8:	c3                   	ret    

00801bf9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c02:	50                   	push   %eax
  801c03:	ff 75 10             	pushl  0x10(%ebp)
  801c06:	ff 75 0c             	pushl  0xc(%ebp)
  801c09:	ff 75 08             	pushl  0x8(%ebp)
  801c0c:	e8 9a ff ff ff       	call   801bab <vsnprintf>
	va_end(ap);

	return rc;
}
  801c11:	c9                   	leave  
  801c12:	c3                   	ret    

00801c13 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c13:	55                   	push   %ebp
  801c14:	89 e5                	mov    %esp,%ebp
  801c16:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c19:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1e:	eb 03                	jmp    801c23 <strlen+0x10>
		n++;
  801c20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c27:	75 f7                	jne    801c20 <strlen+0xd>
		n++;
	return n;
}
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c31:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c34:	ba 00 00 00 00       	mov    $0x0,%edx
  801c39:	eb 03                	jmp    801c3e <strnlen+0x13>
		n++;
  801c3b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c3e:	39 c2                	cmp    %eax,%edx
  801c40:	74 08                	je     801c4a <strnlen+0x1f>
  801c42:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c46:	75 f3                	jne    801c3b <strnlen+0x10>
  801c48:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	53                   	push   %ebx
  801c50:	8b 45 08             	mov    0x8(%ebp),%eax
  801c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	83 c2 01             	add    $0x1,%edx
  801c5b:	83 c1 01             	add    $0x1,%ecx
  801c5e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c62:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c65:	84 db                	test   %bl,%bl
  801c67:	75 ef                	jne    801c58 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c69:	5b                   	pop    %ebx
  801c6a:	5d                   	pop    %ebp
  801c6b:	c3                   	ret    

00801c6c <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	53                   	push   %ebx
  801c70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c73:	53                   	push   %ebx
  801c74:	e8 9a ff ff ff       	call   801c13 <strlen>
  801c79:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c7c:	ff 75 0c             	pushl  0xc(%ebp)
  801c7f:	01 d8                	add    %ebx,%eax
  801c81:	50                   	push   %eax
  801c82:	e8 c5 ff ff ff       	call   801c4c <strcpy>
	return dst;
}
  801c87:	89 d8                	mov    %ebx,%eax
  801c89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	56                   	push   %esi
  801c92:	53                   	push   %ebx
  801c93:	8b 75 08             	mov    0x8(%ebp),%esi
  801c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c99:	89 f3                	mov    %esi,%ebx
  801c9b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c9e:	89 f2                	mov    %esi,%edx
  801ca0:	eb 0f                	jmp    801cb1 <strncpy+0x23>
		*dst++ = *src;
  801ca2:	83 c2 01             	add    $0x1,%edx
  801ca5:	0f b6 01             	movzbl (%ecx),%eax
  801ca8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801cab:	80 39 01             	cmpb   $0x1,(%ecx)
  801cae:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cb1:	39 da                	cmp    %ebx,%edx
  801cb3:	75 ed                	jne    801ca2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801cb5:	89 f0                	mov    %esi,%eax
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	56                   	push   %esi
  801cbf:	53                   	push   %ebx
  801cc0:	8b 75 08             	mov    0x8(%ebp),%esi
  801cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cc6:	8b 55 10             	mov    0x10(%ebp),%edx
  801cc9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ccb:	85 d2                	test   %edx,%edx
  801ccd:	74 21                	je     801cf0 <strlcpy+0x35>
  801ccf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cd3:	89 f2                	mov    %esi,%edx
  801cd5:	eb 09                	jmp    801ce0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cd7:	83 c2 01             	add    $0x1,%edx
  801cda:	83 c1 01             	add    $0x1,%ecx
  801cdd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ce0:	39 c2                	cmp    %eax,%edx
  801ce2:	74 09                	je     801ced <strlcpy+0x32>
  801ce4:	0f b6 19             	movzbl (%ecx),%ebx
  801ce7:	84 db                	test   %bl,%bl
  801ce9:	75 ec                	jne    801cd7 <strlcpy+0x1c>
  801ceb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ced:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cf0:	29 f0                	sub    %esi,%eax
}
  801cf2:	5b                   	pop    %ebx
  801cf3:	5e                   	pop    %esi
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    

00801cf6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cfc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cff:	eb 06                	jmp    801d07 <strcmp+0x11>
		p++, q++;
  801d01:	83 c1 01             	add    $0x1,%ecx
  801d04:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d07:	0f b6 01             	movzbl (%ecx),%eax
  801d0a:	84 c0                	test   %al,%al
  801d0c:	74 04                	je     801d12 <strcmp+0x1c>
  801d0e:	3a 02                	cmp    (%edx),%al
  801d10:	74 ef                	je     801d01 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d12:	0f b6 c0             	movzbl %al,%eax
  801d15:	0f b6 12             	movzbl (%edx),%edx
  801d18:	29 d0                	sub    %edx,%eax
}
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    

00801d1c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	53                   	push   %ebx
  801d20:	8b 45 08             	mov    0x8(%ebp),%eax
  801d23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d2b:	eb 06                	jmp    801d33 <strncmp+0x17>
		n--, p++, q++;
  801d2d:	83 c0 01             	add    $0x1,%eax
  801d30:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d33:	39 d8                	cmp    %ebx,%eax
  801d35:	74 15                	je     801d4c <strncmp+0x30>
  801d37:	0f b6 08             	movzbl (%eax),%ecx
  801d3a:	84 c9                	test   %cl,%cl
  801d3c:	74 04                	je     801d42 <strncmp+0x26>
  801d3e:	3a 0a                	cmp    (%edx),%cl
  801d40:	74 eb                	je     801d2d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d42:	0f b6 00             	movzbl (%eax),%eax
  801d45:	0f b6 12             	movzbl (%edx),%edx
  801d48:	29 d0                	sub    %edx,%eax
  801d4a:	eb 05                	jmp    801d51 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d4c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d51:	5b                   	pop    %ebx
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d5e:	eb 07                	jmp    801d67 <strchr+0x13>
		if (*s == c)
  801d60:	38 ca                	cmp    %cl,%dl
  801d62:	74 0f                	je     801d73 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d64:	83 c0 01             	add    $0x1,%eax
  801d67:	0f b6 10             	movzbl (%eax),%edx
  801d6a:	84 d2                	test   %dl,%dl
  801d6c:	75 f2                	jne    801d60 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d7f:	eb 03                	jmp    801d84 <strfind+0xf>
  801d81:	83 c0 01             	add    $0x1,%eax
  801d84:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d87:	38 ca                	cmp    %cl,%dl
  801d89:	74 04                	je     801d8f <strfind+0x1a>
  801d8b:	84 d2                	test   %dl,%dl
  801d8d:	75 f2                	jne    801d81 <strfind+0xc>
			break;
	return (char *) s;
}
  801d8f:	5d                   	pop    %ebp
  801d90:	c3                   	ret    

00801d91 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	57                   	push   %edi
  801d95:	56                   	push   %esi
  801d96:	53                   	push   %ebx
  801d97:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d9d:	85 c9                	test   %ecx,%ecx
  801d9f:	74 36                	je     801dd7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801da1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801da7:	75 28                	jne    801dd1 <memset+0x40>
  801da9:	f6 c1 03             	test   $0x3,%cl
  801dac:	75 23                	jne    801dd1 <memset+0x40>
		c &= 0xFF;
  801dae:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801db2:	89 d3                	mov    %edx,%ebx
  801db4:	c1 e3 08             	shl    $0x8,%ebx
  801db7:	89 d6                	mov    %edx,%esi
  801db9:	c1 e6 18             	shl    $0x18,%esi
  801dbc:	89 d0                	mov    %edx,%eax
  801dbe:	c1 e0 10             	shl    $0x10,%eax
  801dc1:	09 f0                	or     %esi,%eax
  801dc3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801dc5:	89 d8                	mov    %ebx,%eax
  801dc7:	09 d0                	or     %edx,%eax
  801dc9:	c1 e9 02             	shr    $0x2,%ecx
  801dcc:	fc                   	cld    
  801dcd:	f3 ab                	rep stos %eax,%es:(%edi)
  801dcf:	eb 06                	jmp    801dd7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd4:	fc                   	cld    
  801dd5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dd7:	89 f8                	mov    %edi,%eax
  801dd9:	5b                   	pop    %ebx
  801dda:	5e                   	pop    %esi
  801ddb:	5f                   	pop    %edi
  801ddc:	5d                   	pop    %ebp
  801ddd:	c3                   	ret    

00801dde <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	8b 45 08             	mov    0x8(%ebp),%eax
  801de6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801de9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dec:	39 c6                	cmp    %eax,%esi
  801dee:	73 35                	jae    801e25 <memmove+0x47>
  801df0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801df3:	39 d0                	cmp    %edx,%eax
  801df5:	73 2e                	jae    801e25 <memmove+0x47>
		s += n;
		d += n;
  801df7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dfa:	89 d6                	mov    %edx,%esi
  801dfc:	09 fe                	or     %edi,%esi
  801dfe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e04:	75 13                	jne    801e19 <memmove+0x3b>
  801e06:	f6 c1 03             	test   $0x3,%cl
  801e09:	75 0e                	jne    801e19 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e0b:	83 ef 04             	sub    $0x4,%edi
  801e0e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e11:	c1 e9 02             	shr    $0x2,%ecx
  801e14:	fd                   	std    
  801e15:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e17:	eb 09                	jmp    801e22 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e19:	83 ef 01             	sub    $0x1,%edi
  801e1c:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e1f:	fd                   	std    
  801e20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e22:	fc                   	cld    
  801e23:	eb 1d                	jmp    801e42 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e25:	89 f2                	mov    %esi,%edx
  801e27:	09 c2                	or     %eax,%edx
  801e29:	f6 c2 03             	test   $0x3,%dl
  801e2c:	75 0f                	jne    801e3d <memmove+0x5f>
  801e2e:	f6 c1 03             	test   $0x3,%cl
  801e31:	75 0a                	jne    801e3d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e33:	c1 e9 02             	shr    $0x2,%ecx
  801e36:	89 c7                	mov    %eax,%edi
  801e38:	fc                   	cld    
  801e39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e3b:	eb 05                	jmp    801e42 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e3d:	89 c7                	mov    %eax,%edi
  801e3f:	fc                   	cld    
  801e40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e42:	5e                   	pop    %esi
  801e43:	5f                   	pop    %edi
  801e44:	5d                   	pop    %ebp
  801e45:	c3                   	ret    

00801e46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e49:	ff 75 10             	pushl  0x10(%ebp)
  801e4c:	ff 75 0c             	pushl  0xc(%ebp)
  801e4f:	ff 75 08             	pushl  0x8(%ebp)
  801e52:	e8 87 ff ff ff       	call   801dde <memmove>
}
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    

00801e59 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e59:	55                   	push   %ebp
  801e5a:	89 e5                	mov    %esp,%ebp
  801e5c:	56                   	push   %esi
  801e5d:	53                   	push   %ebx
  801e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e61:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e64:	89 c6                	mov    %eax,%esi
  801e66:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e69:	eb 1a                	jmp    801e85 <memcmp+0x2c>
		if (*s1 != *s2)
  801e6b:	0f b6 08             	movzbl (%eax),%ecx
  801e6e:	0f b6 1a             	movzbl (%edx),%ebx
  801e71:	38 d9                	cmp    %bl,%cl
  801e73:	74 0a                	je     801e7f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e75:	0f b6 c1             	movzbl %cl,%eax
  801e78:	0f b6 db             	movzbl %bl,%ebx
  801e7b:	29 d8                	sub    %ebx,%eax
  801e7d:	eb 0f                	jmp    801e8e <memcmp+0x35>
		s1++, s2++;
  801e7f:	83 c0 01             	add    $0x1,%eax
  801e82:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e85:	39 f0                	cmp    %esi,%eax
  801e87:	75 e2                	jne    801e6b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e8e:	5b                   	pop    %ebx
  801e8f:	5e                   	pop    %esi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    

00801e92 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	53                   	push   %ebx
  801e96:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e99:	89 c1                	mov    %eax,%ecx
  801e9b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e9e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ea2:	eb 0a                	jmp    801eae <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ea4:	0f b6 10             	movzbl (%eax),%edx
  801ea7:	39 da                	cmp    %ebx,%edx
  801ea9:	74 07                	je     801eb2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801eab:	83 c0 01             	add    $0x1,%eax
  801eae:	39 c8                	cmp    %ecx,%eax
  801eb0:	72 f2                	jb     801ea4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801eb2:	5b                   	pop    %ebx
  801eb3:	5d                   	pop    %ebp
  801eb4:	c3                   	ret    

00801eb5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	57                   	push   %edi
  801eb9:	56                   	push   %esi
  801eba:	53                   	push   %ebx
  801ebb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ebe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ec1:	eb 03                	jmp    801ec6 <strtol+0x11>
		s++;
  801ec3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ec6:	0f b6 01             	movzbl (%ecx),%eax
  801ec9:	3c 20                	cmp    $0x20,%al
  801ecb:	74 f6                	je     801ec3 <strtol+0xe>
  801ecd:	3c 09                	cmp    $0x9,%al
  801ecf:	74 f2                	je     801ec3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ed1:	3c 2b                	cmp    $0x2b,%al
  801ed3:	75 0a                	jne    801edf <strtol+0x2a>
		s++;
  801ed5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ed8:	bf 00 00 00 00       	mov    $0x0,%edi
  801edd:	eb 11                	jmp    801ef0 <strtol+0x3b>
  801edf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ee4:	3c 2d                	cmp    $0x2d,%al
  801ee6:	75 08                	jne    801ef0 <strtol+0x3b>
		s++, neg = 1;
  801ee8:	83 c1 01             	add    $0x1,%ecx
  801eeb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ef0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ef6:	75 15                	jne    801f0d <strtol+0x58>
  801ef8:	80 39 30             	cmpb   $0x30,(%ecx)
  801efb:	75 10                	jne    801f0d <strtol+0x58>
  801efd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f01:	75 7c                	jne    801f7f <strtol+0xca>
		s += 2, base = 16;
  801f03:	83 c1 02             	add    $0x2,%ecx
  801f06:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f0b:	eb 16                	jmp    801f23 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f0d:	85 db                	test   %ebx,%ebx
  801f0f:	75 12                	jne    801f23 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f11:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f16:	80 39 30             	cmpb   $0x30,(%ecx)
  801f19:	75 08                	jne    801f23 <strtol+0x6e>
		s++, base = 8;
  801f1b:	83 c1 01             	add    $0x1,%ecx
  801f1e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
  801f28:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f2b:	0f b6 11             	movzbl (%ecx),%edx
  801f2e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f31:	89 f3                	mov    %esi,%ebx
  801f33:	80 fb 09             	cmp    $0x9,%bl
  801f36:	77 08                	ja     801f40 <strtol+0x8b>
			dig = *s - '0';
  801f38:	0f be d2             	movsbl %dl,%edx
  801f3b:	83 ea 30             	sub    $0x30,%edx
  801f3e:	eb 22                	jmp    801f62 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f40:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f43:	89 f3                	mov    %esi,%ebx
  801f45:	80 fb 19             	cmp    $0x19,%bl
  801f48:	77 08                	ja     801f52 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f4a:	0f be d2             	movsbl %dl,%edx
  801f4d:	83 ea 57             	sub    $0x57,%edx
  801f50:	eb 10                	jmp    801f62 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f52:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f55:	89 f3                	mov    %esi,%ebx
  801f57:	80 fb 19             	cmp    $0x19,%bl
  801f5a:	77 16                	ja     801f72 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f5c:	0f be d2             	movsbl %dl,%edx
  801f5f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f62:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f65:	7d 0b                	jge    801f72 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f67:	83 c1 01             	add    $0x1,%ecx
  801f6a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f6e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f70:	eb b9                	jmp    801f2b <strtol+0x76>

	if (endptr)
  801f72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f76:	74 0d                	je     801f85 <strtol+0xd0>
		*endptr = (char *) s;
  801f78:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f7b:	89 0e                	mov    %ecx,(%esi)
  801f7d:	eb 06                	jmp    801f85 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f7f:	85 db                	test   %ebx,%ebx
  801f81:	74 98                	je     801f1b <strtol+0x66>
  801f83:	eb 9e                	jmp    801f23 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f85:	89 c2                	mov    %eax,%edx
  801f87:	f7 da                	neg    %edx
  801f89:	85 ff                	test   %edi,%edi
  801f8b:	0f 45 c2             	cmovne %edx,%eax
}
  801f8e:	5b                   	pop    %ebx
  801f8f:	5e                   	pop    %esi
  801f90:	5f                   	pop    %edi
  801f91:	5d                   	pop    %ebp
  801f92:	c3                   	ret    

00801f93 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f99:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fa0:	75 2a                	jne    801fcc <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801fa2:	83 ec 04             	sub    $0x4,%esp
  801fa5:	6a 07                	push   $0x7
  801fa7:	68 00 f0 bf ee       	push   $0xeebff000
  801fac:	6a 00                	push   $0x0
  801fae:	e8 f1 e1 ff ff       	call   8001a4 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	79 12                	jns    801fcc <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801fba:	50                   	push   %eax
  801fbb:	68 dd 24 80 00       	push   $0x8024dd
  801fc0:	6a 23                	push   $0x23
  801fc2:	68 00 29 80 00       	push   $0x802900
  801fc7:	e8 22 f6 ff ff       	call   8015ee <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcf:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fd4:	83 ec 08             	sub    $0x8,%esp
  801fd7:	68 fe 1f 80 00       	push   $0x801ffe
  801fdc:	6a 00                	push   $0x0
  801fde:	e8 0c e3 ff ff       	call   8002ef <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	79 12                	jns    801ffc <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fea:	50                   	push   %eax
  801feb:	68 dd 24 80 00       	push   $0x8024dd
  801ff0:	6a 2c                	push   $0x2c
  801ff2:	68 00 29 80 00       	push   $0x802900
  801ff7:	e8 f2 f5 ff ff       	call   8015ee <_panic>
	}
}
  801ffc:	c9                   	leave  
  801ffd:	c3                   	ret    

00801ffe <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ffe:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fff:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802004:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802006:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  802009:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80200d:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802012:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802016:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  802018:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80201b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80201c:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  80201f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802020:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802021:	c3                   	ret    

00802022 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	56                   	push   %esi
  802026:	53                   	push   %ebx
  802027:	8b 75 08             	mov    0x8(%ebp),%esi
  80202a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80202d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802030:	85 c0                	test   %eax,%eax
  802032:	75 12                	jne    802046 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802034:	83 ec 0c             	sub    $0xc,%esp
  802037:	68 00 00 c0 ee       	push   $0xeec00000
  80203c:	e8 13 e3 ff ff       	call   800354 <sys_ipc_recv>
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	eb 0c                	jmp    802052 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  802046:	83 ec 0c             	sub    $0xc,%esp
  802049:	50                   	push   %eax
  80204a:	e8 05 e3 ff ff       	call   800354 <sys_ipc_recv>
  80204f:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802052:	85 f6                	test   %esi,%esi
  802054:	0f 95 c1             	setne  %cl
  802057:	85 db                	test   %ebx,%ebx
  802059:	0f 95 c2             	setne  %dl
  80205c:	84 d1                	test   %dl,%cl
  80205e:	74 09                	je     802069 <ipc_recv+0x47>
  802060:	89 c2                	mov    %eax,%edx
  802062:	c1 ea 1f             	shr    $0x1f,%edx
  802065:	84 d2                	test   %dl,%dl
  802067:	75 2d                	jne    802096 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802069:	85 f6                	test   %esi,%esi
  80206b:	74 0d                	je     80207a <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  80206d:	a1 04 40 80 00       	mov    0x804004,%eax
  802072:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802078:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80207a:	85 db                	test   %ebx,%ebx
  80207c:	74 0d                	je     80208b <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  80207e:	a1 04 40 80 00       	mov    0x804004,%eax
  802083:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802089:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80208b:	a1 04 40 80 00       	mov    0x804004,%eax
  802090:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  802096:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802099:	5b                   	pop    %ebx
  80209a:	5e                   	pop    %esi
  80209b:	5d                   	pop    %ebp
  80209c:	c3                   	ret    

0080209d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80209d:	55                   	push   %ebp
  80209e:	89 e5                	mov    %esp,%ebp
  8020a0:	57                   	push   %edi
  8020a1:	56                   	push   %esi
  8020a2:	53                   	push   %ebx
  8020a3:	83 ec 0c             	sub    $0xc,%esp
  8020a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  8020af:	85 db                	test   %ebx,%ebx
  8020b1:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020b6:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020b9:	ff 75 14             	pushl  0x14(%ebp)
  8020bc:	53                   	push   %ebx
  8020bd:	56                   	push   %esi
  8020be:	57                   	push   %edi
  8020bf:	e8 6d e2 ff ff       	call   800331 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  8020c4:	89 c2                	mov    %eax,%edx
  8020c6:	c1 ea 1f             	shr    $0x1f,%edx
  8020c9:	83 c4 10             	add    $0x10,%esp
  8020cc:	84 d2                	test   %dl,%dl
  8020ce:	74 17                	je     8020e7 <ipc_send+0x4a>
  8020d0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d3:	74 12                	je     8020e7 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020d5:	50                   	push   %eax
  8020d6:	68 0e 29 80 00       	push   $0x80290e
  8020db:	6a 47                	push   $0x47
  8020dd:	68 1c 29 80 00       	push   $0x80291c
  8020e2:	e8 07 f5 ff ff       	call   8015ee <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020e7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ea:	75 07                	jne    8020f3 <ipc_send+0x56>
			sys_yield();
  8020ec:	e8 94 e0 ff ff       	call   800185 <sys_yield>
  8020f1:	eb c6                	jmp    8020b9 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	75 c2                	jne    8020b9 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    

008020ff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802105:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80210a:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  802110:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802116:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  80211c:	39 ca                	cmp    %ecx,%edx
  80211e:	75 13                	jne    802133 <ipc_find_env+0x34>
			return envs[i].env_id;
  802120:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  802126:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80212b:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802131:	eb 0f                	jmp    802142 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802133:	83 c0 01             	add    $0x1,%eax
  802136:	3d 00 04 00 00       	cmp    $0x400,%eax
  80213b:	75 cd                	jne    80210a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80213d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    

00802144 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
  802147:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80214a:	89 d0                	mov    %edx,%eax
  80214c:	c1 e8 16             	shr    $0x16,%eax
  80214f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802156:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80215b:	f6 c1 01             	test   $0x1,%cl
  80215e:	74 1d                	je     80217d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802160:	c1 ea 0c             	shr    $0xc,%edx
  802163:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80216a:	f6 c2 01             	test   $0x1,%dl
  80216d:	74 0e                	je     80217d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80216f:	c1 ea 0c             	shr    $0xc,%edx
  802172:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802179:	ef 
  80217a:	0f b7 c0             	movzwl %ax,%eax
}
  80217d:	5d                   	pop    %ebp
  80217e:	c3                   	ret    
  80217f:	90                   	nop

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80218b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80218f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 f6                	test   %esi,%esi
  802199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80219d:	89 ca                	mov    %ecx,%edx
  80219f:	89 f8                	mov    %edi,%eax
  8021a1:	75 3d                	jne    8021e0 <__udivdi3+0x60>
  8021a3:	39 cf                	cmp    %ecx,%edi
  8021a5:	0f 87 c5 00 00 00    	ja     802270 <__udivdi3+0xf0>
  8021ab:	85 ff                	test   %edi,%edi
  8021ad:	89 fd                	mov    %edi,%ebp
  8021af:	75 0b                	jne    8021bc <__udivdi3+0x3c>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	f7 f7                	div    %edi
  8021ba:	89 c5                	mov    %eax,%ebp
  8021bc:	89 c8                	mov    %ecx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f5                	div    %ebp
  8021c2:	89 c1                	mov    %eax,%ecx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	89 cf                	mov    %ecx,%edi
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 ce                	cmp    %ecx,%esi
  8021e2:	77 74                	ja     802258 <__udivdi3+0xd8>
  8021e4:	0f bd fe             	bsr    %esi,%edi
  8021e7:	83 f7 1f             	xor    $0x1f,%edi
  8021ea:	0f 84 98 00 00 00    	je     802288 <__udivdi3+0x108>
  8021f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	29 fb                	sub    %edi,%ebx
  8021fb:	d3 e6                	shl    %cl,%esi
  8021fd:	89 d9                	mov    %ebx,%ecx
  8021ff:	d3 ed                	shr    %cl,%ebp
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	09 ee                	or     %ebp,%esi
  802207:	89 d9                	mov    %ebx,%ecx
  802209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220d:	89 d5                	mov    %edx,%ebp
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	d3 ed                	shr    %cl,%ebp
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 d9                	mov    %ebx,%ecx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 d0                	mov    %edx,%eax
  802221:	89 ea                	mov    %ebp,%edx
  802223:	f7 f6                	div    %esi
  802225:	89 d5                	mov    %edx,%ebp
  802227:	89 c3                	mov    %eax,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	72 10                	jb     802241 <__udivdi3+0xc1>
  802231:	8b 74 24 08          	mov    0x8(%esp),%esi
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e6                	shl    %cl,%esi
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	73 07                	jae    802244 <__udivdi3+0xc4>
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	75 03                	jne    802244 <__udivdi3+0xc4>
  802241:	83 eb 01             	sub    $0x1,%ebx
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 d8                	mov    %ebx,%eax
  802248:	89 fa                	mov    %edi,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	31 ff                	xor    %edi,%edi
  80225a:	31 db                	xor    %ebx,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d8                	mov    %ebx,%eax
  802272:	f7 f7                	div    %edi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 c3                	mov    %eax,%ebx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 fa                	mov    %edi,%edx
  80227c:	83 c4 1c             	add    $0x1c,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	72 0c                	jb     802298 <__udivdi3+0x118>
  80228c:	31 db                	xor    %ebx,%ebx
  80228e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802292:	0f 87 34 ff ff ff    	ja     8021cc <__udivdi3+0x4c>
  802298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80229d:	e9 2a ff ff ff       	jmp    8021cc <__udivdi3+0x4c>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f3                	mov    %esi,%ebx
  8022d3:	89 3c 24             	mov    %edi,(%esp)
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	75 1c                	jne    8022f8 <__umoddi3+0x48>
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	76 50                	jbe    802330 <__umoddi3+0x80>
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	f7 f7                	div    %edi
  8022e6:	89 d0                	mov    %edx,%eax
  8022e8:	31 d2                	xor    %edx,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	77 52                	ja     802350 <__umoddi3+0xa0>
  8022fe:	0f bd ea             	bsr    %edx,%ebp
  802301:	83 f5 1f             	xor    $0x1f,%ebp
  802304:	75 5a                	jne    802360 <__umoddi3+0xb0>
  802306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	39 0c 24             	cmp    %ecx,(%esp)
  802313:	0f 86 d7 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  802319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80231d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	85 ff                	test   %edi,%edi
  802332:	89 fd                	mov    %edi,%ebp
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	eb 99                	jmp    8022e8 <__umoddi3+0x38>
  80234f:	90                   	nop
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 1c             	add    $0x1c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	8b 34 24             	mov    (%esp),%esi
  802363:	bf 20 00 00 00       	mov    $0x20,%edi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	29 ef                	sub    %ebp,%edi
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	89 f2                	mov    %esi,%edx
  802372:	d3 ea                	shr    %cl,%edx
  802374:	89 e9                	mov    %ebp,%ecx
  802376:	09 c2                	or     %eax,%edx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 14 24             	mov    %edx,(%esp)
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	d3 e2                	shl    %cl,%edx
  802381:	89 f9                	mov    %edi,%ecx
  802383:	89 54 24 04          	mov    %edx,0x4(%esp)
  802387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	89 c6                	mov    %eax,%esi
  802391:	d3 e3                	shl    %cl,%ebx
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 d0                	mov    %edx,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	09 d8                	or     %ebx,%eax
  80239d:	89 d3                	mov    %edx,%ebx
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	f7 34 24             	divl   (%esp)
  8023a4:	89 d6                	mov    %edx,%esi
  8023a6:	d3 e3                	shl    %cl,%ebx
  8023a8:	f7 64 24 04          	mull   0x4(%esp)
  8023ac:	39 d6                	cmp    %edx,%esi
  8023ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b2:	89 d1                	mov    %edx,%ecx
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	72 08                	jb     8023c0 <__umoddi3+0x110>
  8023b8:	75 11                	jne    8023cb <__umoddi3+0x11b>
  8023ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023be:	73 0b                	jae    8023cb <__umoddi3+0x11b>
  8023c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023c4:	1b 14 24             	sbb    (%esp),%edx
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 c3                	mov    %eax,%ebx
  8023cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023cf:	29 da                	sub    %ebx,%edx
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	d3 ea                	shr    %cl,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	09 d0                	or     %edx,%eax
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	83 c4 1c             	add    $0x1c,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 f9                	sub    %edi,%ecx
  8023f2:	19 d6                	sbb    %edx,%esi
  8023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023fc:	e9 18 ff ff ff       	jmp    802319 <__umoddi3+0x69>
