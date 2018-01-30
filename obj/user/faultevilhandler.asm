
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
  8000d4:	e8 66 0a 00 00       	call   800b3f <close_all>
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
  80014d:	68 aa 24 80 00       	push   $0x8024aa
  800152:	6a 23                	push   $0x23
  800154:	68 c7 24 80 00       	push   $0x8024c7
  800159:	e8 12 15 00 00       	call   801670 <_panic>

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
  8001ce:	68 aa 24 80 00       	push   $0x8024aa
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 c7 24 80 00       	push   $0x8024c7
  8001da:	e8 91 14 00 00       	call   801670 <_panic>

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
  800210:	68 aa 24 80 00       	push   $0x8024aa
  800215:	6a 23                	push   $0x23
  800217:	68 c7 24 80 00       	push   $0x8024c7
  80021c:	e8 4f 14 00 00       	call   801670 <_panic>

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
  800252:	68 aa 24 80 00       	push   $0x8024aa
  800257:	6a 23                	push   $0x23
  800259:	68 c7 24 80 00       	push   $0x8024c7
  80025e:	e8 0d 14 00 00       	call   801670 <_panic>

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
  800294:	68 aa 24 80 00       	push   $0x8024aa
  800299:	6a 23                	push   $0x23
  80029b:	68 c7 24 80 00       	push   $0x8024c7
  8002a0:	e8 cb 13 00 00       	call   801670 <_panic>

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
  8002d6:	68 aa 24 80 00       	push   $0x8024aa
  8002db:	6a 23                	push   $0x23
  8002dd:	68 c7 24 80 00       	push   $0x8024c7
  8002e2:	e8 89 13 00 00       	call   801670 <_panic>
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
  800318:	68 aa 24 80 00       	push   $0x8024aa
  80031d:	6a 23                	push   $0x23
  80031f:	68 c7 24 80 00       	push   $0x8024c7
  800324:	e8 47 13 00 00       	call   801670 <_panic>

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
  80037c:	68 aa 24 80 00       	push   $0x8024aa
  800381:	6a 23                	push   $0x23
  800383:	68 c7 24 80 00       	push   $0x8024c7
  800388:	e8 e3 12 00 00       	call   801670 <_panic>

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
  80041b:	68 d5 24 80 00       	push   $0x8024d5
  800420:	6a 1f                	push   $0x1f
  800422:	68 e5 24 80 00       	push   $0x8024e5
  800427:	e8 44 12 00 00       	call   801670 <_panic>
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
  800445:	68 f0 24 80 00       	push   $0x8024f0
  80044a:	6a 2d                	push   $0x2d
  80044c:	68 e5 24 80 00       	push   $0x8024e5
  800451:	e8 1a 12 00 00       	call   801670 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800456:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80045c:	83 ec 04             	sub    $0x4,%esp
  80045f:	68 00 10 00 00       	push   $0x1000
  800464:	53                   	push   %ebx
  800465:	68 00 f0 7f 00       	push   $0x7ff000
  80046a:	e8 59 1a 00 00       	call   801ec8 <memcpy>

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
  80048d:	68 f0 24 80 00       	push   $0x8024f0
  800492:	6a 34                	push   $0x34
  800494:	68 e5 24 80 00       	push   $0x8024e5
  800499:	e8 d2 11 00 00       	call   801670 <_panic>
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
  8004b5:	68 f0 24 80 00       	push   $0x8024f0
  8004ba:	6a 38                	push   $0x38
  8004bc:	68 e5 24 80 00       	push   $0x8024e5
  8004c1:	e8 aa 11 00 00       	call   801670 <_panic>
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
  8004d9:	e8 37 1b 00 00       	call   802015 <set_pgfault_handler>
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
  8004f2:	68 09 25 80 00       	push   $0x802509
  8004f7:	68 85 00 00 00       	push   $0x85
  8004fc:	68 e5 24 80 00       	push   $0x8024e5
  800501:	e8 6a 11 00 00       	call   801670 <_panic>
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
  8005ae:	68 17 25 80 00       	push   $0x802517
  8005b3:	6a 55                	push   $0x55
  8005b5:	68 e5 24 80 00       	push   $0x8024e5
  8005ba:	e8 b1 10 00 00       	call   801670 <_panic>
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
  8005f3:	68 17 25 80 00       	push   $0x802517
  8005f8:	6a 5c                	push   $0x5c
  8005fa:	68 e5 24 80 00       	push   $0x8024e5
  8005ff:	e8 6c 10 00 00       	call   801670 <_panic>
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
  800621:	68 17 25 80 00       	push   $0x802517
  800626:	6a 60                	push   $0x60
  800628:	68 e5 24 80 00       	push   $0x8024e5
  80062d:	e8 3e 10 00 00       	call   801670 <_panic>
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
  80064b:	68 17 25 80 00       	push   $0x802517
  800650:	6a 65                	push   $0x65
  800652:	68 e5 24 80 00       	push   $0x8024e5
  800657:	e8 14 10 00 00       	call   801670 <_panic>
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
  8006ba:	68 a8 25 80 00       	push   $0x8025a8
  8006bf:	e8 85 10 00 00       	call   801749 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006c4:	c7 04 24 ae 00 80 00 	movl   $0x8000ae,(%esp)
  8006cb:	e8 c5 fc ff ff       	call   800395 <sys_thread_create>
  8006d0:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006d2:	83 c4 08             	add    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	68 a8 25 80 00       	push   $0x8025a8
  8006db:	e8 69 10 00 00       	call   801749 <cprintf>
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

0080070f <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	56                   	push   %esi
  800713:	53                   	push   %ebx
  800714:	8b 75 08             	mov    0x8(%ebp),%esi
  800717:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80071a:	83 ec 04             	sub    $0x4,%esp
  80071d:	6a 07                	push   $0x7
  80071f:	6a 00                	push   $0x0
  800721:	56                   	push   %esi
  800722:	e8 7d fa ff ff       	call   8001a4 <sys_page_alloc>
	if (r < 0) {
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	85 c0                	test   %eax,%eax
  80072c:	79 15                	jns    800743 <queue_append+0x34>
		panic("%e\n", r);
  80072e:	50                   	push   %eax
  80072f:	68 a3 25 80 00       	push   $0x8025a3
  800734:	68 c4 00 00 00       	push   $0xc4
  800739:	68 e5 24 80 00       	push   $0x8024e5
  80073e:	e8 2d 0f 00 00       	call   801670 <_panic>
	}	
	wt->envid = envid;
  800743:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  800749:	83 ec 04             	sub    $0x4,%esp
  80074c:	ff 33                	pushl  (%ebx)
  80074e:	56                   	push   %esi
  80074f:	68 cc 25 80 00       	push   $0x8025cc
  800754:	e8 f0 0f 00 00       	call   801749 <cprintf>
	if (queue->first == NULL) {
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	83 3b 00             	cmpl   $0x0,(%ebx)
  80075f:	75 29                	jne    80078a <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  800761:	83 ec 0c             	sub    $0xc,%esp
  800764:	68 2d 25 80 00       	push   $0x80252d
  800769:	e8 db 0f 00 00       	call   801749 <cprintf>
		queue->first = wt;
  80076e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  800774:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80077b:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800782:	00 00 00 
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	eb 2b                	jmp    8007b5 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  80078a:	83 ec 0c             	sub    $0xc,%esp
  80078d:	68 47 25 80 00       	push   $0x802547
  800792:	e8 b2 0f 00 00       	call   801749 <cprintf>
		queue->last->next = wt;
  800797:	8b 43 04             	mov    0x4(%ebx),%eax
  80079a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8007a1:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8007a8:	00 00 00 
		queue->last = wt;
  8007ab:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8007b2:	83 c4 10             	add    $0x10,%esp
	}
}
  8007b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007b8:	5b                   	pop    %ebx
  8007b9:	5e                   	pop    %esi
  8007ba:	5d                   	pop    %ebp
  8007bb:	c3                   	ret    

008007bc <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	53                   	push   %ebx
  8007c0:	83 ec 04             	sub    $0x4,%esp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8007c6:	8b 02                	mov    (%edx),%eax
  8007c8:	85 c0                	test   %eax,%eax
  8007ca:	75 17                	jne    8007e3 <queue_pop+0x27>
		panic("queue empty!\n");
  8007cc:	83 ec 04             	sub    $0x4,%esp
  8007cf:	68 65 25 80 00       	push   $0x802565
  8007d4:	68 d8 00 00 00       	push   $0xd8
  8007d9:	68 e5 24 80 00       	push   $0x8024e5
  8007de:	e8 8d 0e 00 00       	call   801670 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8007e3:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e6:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8007e8:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8007ea:	83 ec 08             	sub    $0x8,%esp
  8007ed:	53                   	push   %ebx
  8007ee:	68 73 25 80 00       	push   $0x802573
  8007f3:	e8 51 0f 00 00       	call   801749 <cprintf>
	return envid;
}
  8007f8:	89 d8                	mov    %ebx,%eax
  8007fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	83 ec 04             	sub    $0x4,%esp
  800806:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800809:	b8 01 00 00 00       	mov    $0x1,%eax
  80080e:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800811:	85 c0                	test   %eax,%eax
  800813:	74 5a                	je     80086f <mutex_lock+0x70>
  800815:	8b 43 04             	mov    0x4(%ebx),%eax
  800818:	83 38 00             	cmpl   $0x0,(%eax)
  80081b:	75 52                	jne    80086f <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  80081d:	83 ec 0c             	sub    $0xc,%esp
  800820:	68 f4 25 80 00       	push   $0x8025f4
  800825:	e8 1f 0f 00 00       	call   801749 <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  80082a:	8b 5b 04             	mov    0x4(%ebx),%ebx
  80082d:	e8 34 f9 ff ff       	call   800166 <sys_getenvid>
  800832:	83 c4 08             	add    $0x8,%esp
  800835:	53                   	push   %ebx
  800836:	50                   	push   %eax
  800837:	e8 d3 fe ff ff       	call   80070f <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80083c:	e8 25 f9 ff ff       	call   800166 <sys_getenvid>
  800841:	83 c4 08             	add    $0x8,%esp
  800844:	6a 04                	push   $0x4
  800846:	50                   	push   %eax
  800847:	e8 1f fa ff ff       	call   80026b <sys_env_set_status>
		if (r < 0) {
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	85 c0                	test   %eax,%eax
  800851:	79 15                	jns    800868 <mutex_lock+0x69>
			panic("%e\n", r);
  800853:	50                   	push   %eax
  800854:	68 a3 25 80 00       	push   $0x8025a3
  800859:	68 eb 00 00 00       	push   $0xeb
  80085e:	68 e5 24 80 00       	push   $0x8024e5
  800863:	e8 08 0e 00 00       	call   801670 <_panic>
		}
		sys_yield();
  800868:	e8 18 f9 ff ff       	call   800185 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80086d:	eb 18                	jmp    800887 <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  80086f:	83 ec 0c             	sub    $0xc,%esp
  800872:	68 14 26 80 00       	push   $0x802614
  800877:	e8 cd 0e 00 00       	call   801749 <cprintf>
	mtx->owner = sys_getenvid();}
  80087c:	e8 e5 f8 ff ff       	call   800166 <sys_getenvid>
  800881:	89 43 08             	mov    %eax,0x8(%ebx)
  800884:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  800887:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088a:	c9                   	leave  
  80088b:	c3                   	ret    

0080088c <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	53                   	push   %ebx
  800890:	83 ec 04             	sub    $0x4,%esp
  800893:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  80089e:	8b 43 04             	mov    0x4(%ebx),%eax
  8008a1:	83 38 00             	cmpl   $0x0,(%eax)
  8008a4:	74 33                	je     8008d9 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8008a6:	83 ec 0c             	sub    $0xc,%esp
  8008a9:	50                   	push   %eax
  8008aa:	e8 0d ff ff ff       	call   8007bc <queue_pop>
  8008af:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8008b2:	83 c4 08             	add    $0x8,%esp
  8008b5:	6a 02                	push   $0x2
  8008b7:	50                   	push   %eax
  8008b8:	e8 ae f9 ff ff       	call   80026b <sys_env_set_status>
		if (r < 0) {
  8008bd:	83 c4 10             	add    $0x10,%esp
  8008c0:	85 c0                	test   %eax,%eax
  8008c2:	79 15                	jns    8008d9 <mutex_unlock+0x4d>
			panic("%e\n", r);
  8008c4:	50                   	push   %eax
  8008c5:	68 a3 25 80 00       	push   $0x8025a3
  8008ca:	68 00 01 00 00       	push   $0x100
  8008cf:	68 e5 24 80 00       	push   $0x8024e5
  8008d4:	e8 97 0d 00 00       	call   801670 <_panic>
		}
	}

	asm volatile("pause");
  8008d9:	f3 90                	pause  
	//sys_yield();
}
  8008db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	83 ec 04             	sub    $0x4,%esp
  8008e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8008ea:	e8 77 f8 ff ff       	call   800166 <sys_getenvid>
  8008ef:	83 ec 04             	sub    $0x4,%esp
  8008f2:	6a 07                	push   $0x7
  8008f4:	53                   	push   %ebx
  8008f5:	50                   	push   %eax
  8008f6:	e8 a9 f8 ff ff       	call   8001a4 <sys_page_alloc>
  8008fb:	83 c4 10             	add    $0x10,%esp
  8008fe:	85 c0                	test   %eax,%eax
  800900:	79 15                	jns    800917 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800902:	50                   	push   %eax
  800903:	68 8e 25 80 00       	push   $0x80258e
  800908:	68 0d 01 00 00       	push   $0x10d
  80090d:	68 e5 24 80 00       	push   $0x8024e5
  800912:	e8 59 0d 00 00       	call   801670 <_panic>
	}	
	mtx->locked = 0;
  800917:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80091d:	8b 43 04             	mov    0x4(%ebx),%eax
  800920:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800926:	8b 43 04             	mov    0x4(%ebx),%eax
  800929:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800930:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  800937:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  800942:	e8 1f f8 ff ff       	call   800166 <sys_getenvid>
  800947:	83 ec 08             	sub    $0x8,%esp
  80094a:	ff 75 08             	pushl  0x8(%ebp)
  80094d:	50                   	push   %eax
  80094e:	e8 d6 f8 ff ff       	call   800229 <sys_page_unmap>
	if (r < 0) {
  800953:	83 c4 10             	add    $0x10,%esp
  800956:	85 c0                	test   %eax,%eax
  800958:	79 15                	jns    80096f <mutex_destroy+0x33>
		panic("%e\n", r);
  80095a:	50                   	push   %eax
  80095b:	68 a3 25 80 00       	push   $0x8025a3
  800960:	68 1a 01 00 00       	push   $0x11a
  800965:	68 e5 24 80 00       	push   $0x8024e5
  80096a:	e8 01 0d 00 00       	call   801670 <_panic>
	}
}
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	05 00 00 00 30       	add    $0x30000000,%eax
  80097c:	c1 e8 0c             	shr    $0xc,%eax
}
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	05 00 00 00 30       	add    $0x30000000,%eax
  80098c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800991:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8009a3:	89 c2                	mov    %eax,%edx
  8009a5:	c1 ea 16             	shr    $0x16,%edx
  8009a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8009af:	f6 c2 01             	test   $0x1,%dl
  8009b2:	74 11                	je     8009c5 <fd_alloc+0x2d>
  8009b4:	89 c2                	mov    %eax,%edx
  8009b6:	c1 ea 0c             	shr    $0xc,%edx
  8009b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009c0:	f6 c2 01             	test   $0x1,%dl
  8009c3:	75 09                	jne    8009ce <fd_alloc+0x36>
			*fd_store = fd;
  8009c5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cc:	eb 17                	jmp    8009e5 <fd_alloc+0x4d>
  8009ce:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8009d3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8009d8:	75 c9                	jne    8009a3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8009da:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8009e0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8009ed:	83 f8 1f             	cmp    $0x1f,%eax
  8009f0:	77 36                	ja     800a28 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8009f2:	c1 e0 0c             	shl    $0xc,%eax
  8009f5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	c1 ea 16             	shr    $0x16,%edx
  8009ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800a06:	f6 c2 01             	test   $0x1,%dl
  800a09:	74 24                	je     800a2f <fd_lookup+0x48>
  800a0b:	89 c2                	mov    %eax,%edx
  800a0d:	c1 ea 0c             	shr    $0xc,%edx
  800a10:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a17:	f6 c2 01             	test   $0x1,%dl
  800a1a:	74 1a                	je     800a36 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1f:	89 02                	mov    %eax,(%edx)
	return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
  800a26:	eb 13                	jmp    800a3b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a28:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a2d:	eb 0c                	jmp    800a3b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a34:	eb 05                	jmp    800a3b <fd_lookup+0x54>
  800a36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	83 ec 08             	sub    $0x8,%esp
  800a43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a46:	ba b0 26 80 00       	mov    $0x8026b0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800a4b:	eb 13                	jmp    800a60 <dev_lookup+0x23>
  800a4d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800a50:	39 08                	cmp    %ecx,(%eax)
  800a52:	75 0c                	jne    800a60 <dev_lookup+0x23>
			*dev = devtab[i];
  800a54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a57:	89 01                	mov    %eax,(%ecx)
			return 0;
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5e:	eb 31                	jmp    800a91 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800a60:	8b 02                	mov    (%edx),%eax
  800a62:	85 c0                	test   %eax,%eax
  800a64:	75 e7                	jne    800a4d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800a66:	a1 04 40 80 00       	mov    0x804004,%eax
  800a6b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a71:	83 ec 04             	sub    $0x4,%esp
  800a74:	51                   	push   %ecx
  800a75:	50                   	push   %eax
  800a76:	68 34 26 80 00       	push   $0x802634
  800a7b:	e8 c9 0c 00 00       	call   801749 <cprintf>
	*dev = 0;
  800a80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a83:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a91:	c9                   	leave  
  800a92:	c3                   	ret    

00800a93 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	83 ec 10             	sub    $0x10,%esp
  800a9b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800aa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa4:	50                   	push   %eax
  800aa5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800aab:	c1 e8 0c             	shr    $0xc,%eax
  800aae:	50                   	push   %eax
  800aaf:	e8 33 ff ff ff       	call   8009e7 <fd_lookup>
  800ab4:	83 c4 08             	add    $0x8,%esp
  800ab7:	85 c0                	test   %eax,%eax
  800ab9:	78 05                	js     800ac0 <fd_close+0x2d>
	    || fd != fd2)
  800abb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800abe:	74 0c                	je     800acc <fd_close+0x39>
		return (must_exist ? r : 0);
  800ac0:	84 db                	test   %bl,%bl
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	0f 44 c2             	cmove  %edx,%eax
  800aca:	eb 41                	jmp    800b0d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800acc:	83 ec 08             	sub    $0x8,%esp
  800acf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ad2:	50                   	push   %eax
  800ad3:	ff 36                	pushl  (%esi)
  800ad5:	e8 63 ff ff ff       	call   800a3d <dev_lookup>
  800ada:	89 c3                	mov    %eax,%ebx
  800adc:	83 c4 10             	add    $0x10,%esp
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	78 1a                	js     800afd <fd_close+0x6a>
		if (dev->dev_close)
  800ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ae6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ae9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800aee:	85 c0                	test   %eax,%eax
  800af0:	74 0b                	je     800afd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800af2:	83 ec 0c             	sub    $0xc,%esp
  800af5:	56                   	push   %esi
  800af6:	ff d0                	call   *%eax
  800af8:	89 c3                	mov    %eax,%ebx
  800afa:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800afd:	83 ec 08             	sub    $0x8,%esp
  800b00:	56                   	push   %esi
  800b01:	6a 00                	push   $0x0
  800b03:	e8 21 f7 ff ff       	call   800229 <sys_page_unmap>
	return r;
  800b08:	83 c4 10             	add    $0x10,%esp
  800b0b:	89 d8                	mov    %ebx,%eax
}
  800b0d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1d:	50                   	push   %eax
  800b1e:	ff 75 08             	pushl  0x8(%ebp)
  800b21:	e8 c1 fe ff ff       	call   8009e7 <fd_lookup>
  800b26:	83 c4 08             	add    $0x8,%esp
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	78 10                	js     800b3d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800b2d:	83 ec 08             	sub    $0x8,%esp
  800b30:	6a 01                	push   $0x1
  800b32:	ff 75 f4             	pushl  -0xc(%ebp)
  800b35:	e8 59 ff ff ff       	call   800a93 <fd_close>
  800b3a:	83 c4 10             	add    $0x10,%esp
}
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <close_all>:

void
close_all(void)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	53                   	push   %ebx
  800b43:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800b46:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800b4b:	83 ec 0c             	sub    $0xc,%esp
  800b4e:	53                   	push   %ebx
  800b4f:	e8 c0 ff ff ff       	call   800b14 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b54:	83 c3 01             	add    $0x1,%ebx
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	83 fb 20             	cmp    $0x20,%ebx
  800b5d:	75 ec                	jne    800b4b <close_all+0xc>
		close(i);
}
  800b5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b62:	c9                   	leave  
  800b63:	c3                   	ret    

00800b64 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
  800b6a:	83 ec 2c             	sub    $0x2c,%esp
  800b6d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b70:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b73:	50                   	push   %eax
  800b74:	ff 75 08             	pushl  0x8(%ebp)
  800b77:	e8 6b fe ff ff       	call   8009e7 <fd_lookup>
  800b7c:	83 c4 08             	add    $0x8,%esp
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	0f 88 c1 00 00 00    	js     800c48 <dup+0xe4>
		return r;
	close(newfdnum);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	56                   	push   %esi
  800b8b:	e8 84 ff ff ff       	call   800b14 <close>

	newfd = INDEX2FD(newfdnum);
  800b90:	89 f3                	mov    %esi,%ebx
  800b92:	c1 e3 0c             	shl    $0xc,%ebx
  800b95:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b9b:	83 c4 04             	add    $0x4,%esp
  800b9e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ba1:	e8 db fd ff ff       	call   800981 <fd2data>
  800ba6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800ba8:	89 1c 24             	mov    %ebx,(%esp)
  800bab:	e8 d1 fd ff ff       	call   800981 <fd2data>
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800bb6:	89 f8                	mov    %edi,%eax
  800bb8:	c1 e8 16             	shr    $0x16,%eax
  800bbb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800bc2:	a8 01                	test   $0x1,%al
  800bc4:	74 37                	je     800bfd <dup+0x99>
  800bc6:	89 f8                	mov    %edi,%eax
  800bc8:	c1 e8 0c             	shr    $0xc,%eax
  800bcb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800bd2:	f6 c2 01             	test   $0x1,%dl
  800bd5:	74 26                	je     800bfd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800bd7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	25 07 0e 00 00       	and    $0xe07,%eax
  800be6:	50                   	push   %eax
  800be7:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bea:	6a 00                	push   $0x0
  800bec:	57                   	push   %edi
  800bed:	6a 00                	push   $0x0
  800bef:	e8 f3 f5 ff ff       	call   8001e7 <sys_page_map>
  800bf4:	89 c7                	mov    %eax,%edi
  800bf6:	83 c4 20             	add    $0x20,%esp
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	78 2e                	js     800c2b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bfd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c00:	89 d0                	mov    %edx,%eax
  800c02:	c1 e8 0c             	shr    $0xc,%eax
  800c05:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	25 07 0e 00 00       	and    $0xe07,%eax
  800c14:	50                   	push   %eax
  800c15:	53                   	push   %ebx
  800c16:	6a 00                	push   $0x0
  800c18:	52                   	push   %edx
  800c19:	6a 00                	push   $0x0
  800c1b:	e8 c7 f5 ff ff       	call   8001e7 <sys_page_map>
  800c20:	89 c7                	mov    %eax,%edi
  800c22:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800c25:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c27:	85 ff                	test   %edi,%edi
  800c29:	79 1d                	jns    800c48 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c2b:	83 ec 08             	sub    $0x8,%esp
  800c2e:	53                   	push   %ebx
  800c2f:	6a 00                	push   $0x0
  800c31:	e8 f3 f5 ff ff       	call   800229 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c36:	83 c4 08             	add    $0x8,%esp
  800c39:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c3c:	6a 00                	push   $0x0
  800c3e:	e8 e6 f5 ff ff       	call   800229 <sys_page_unmap>
	return r;
  800c43:	83 c4 10             	add    $0x10,%esp
  800c46:	89 f8                	mov    %edi,%eax
}
  800c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4b:	5b                   	pop    %ebx
  800c4c:	5e                   	pop    %esi
  800c4d:	5f                   	pop    %edi
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	53                   	push   %ebx
  800c54:	83 ec 14             	sub    $0x14,%esp
  800c57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c5a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c5d:	50                   	push   %eax
  800c5e:	53                   	push   %ebx
  800c5f:	e8 83 fd ff ff       	call   8009e7 <fd_lookup>
  800c64:	83 c4 08             	add    $0x8,%esp
  800c67:	89 c2                	mov    %eax,%edx
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	78 70                	js     800cdd <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c6d:	83 ec 08             	sub    $0x8,%esp
  800c70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c73:	50                   	push   %eax
  800c74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c77:	ff 30                	pushl  (%eax)
  800c79:	e8 bf fd ff ff       	call   800a3d <dev_lookup>
  800c7e:	83 c4 10             	add    $0x10,%esp
  800c81:	85 c0                	test   %eax,%eax
  800c83:	78 4f                	js     800cd4 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c85:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c88:	8b 42 08             	mov    0x8(%edx),%eax
  800c8b:	83 e0 03             	and    $0x3,%eax
  800c8e:	83 f8 01             	cmp    $0x1,%eax
  800c91:	75 24                	jne    800cb7 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c93:	a1 04 40 80 00       	mov    0x804004,%eax
  800c98:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800c9e:	83 ec 04             	sub    $0x4,%esp
  800ca1:	53                   	push   %ebx
  800ca2:	50                   	push   %eax
  800ca3:	68 75 26 80 00       	push   $0x802675
  800ca8:	e8 9c 0a 00 00       	call   801749 <cprintf>
		return -E_INVAL;
  800cad:	83 c4 10             	add    $0x10,%esp
  800cb0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800cb5:	eb 26                	jmp    800cdd <read+0x8d>
	}
	if (!dev->dev_read)
  800cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cba:	8b 40 08             	mov    0x8(%eax),%eax
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	74 17                	je     800cd8 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800cc1:	83 ec 04             	sub    $0x4,%esp
  800cc4:	ff 75 10             	pushl  0x10(%ebp)
  800cc7:	ff 75 0c             	pushl  0xc(%ebp)
  800cca:	52                   	push   %edx
  800ccb:	ff d0                	call   *%eax
  800ccd:	89 c2                	mov    %eax,%edx
  800ccf:	83 c4 10             	add    $0x10,%esp
  800cd2:	eb 09                	jmp    800cdd <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cd4:	89 c2                	mov    %eax,%edx
  800cd6:	eb 05                	jmp    800cdd <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800cd8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800cdd:	89 d0                	mov    %edx,%eax
  800cdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ce2:	c9                   	leave  
  800ce3:	c3                   	ret    

00800ce4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
  800ced:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf8:	eb 21                	jmp    800d1b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800cfa:	83 ec 04             	sub    $0x4,%esp
  800cfd:	89 f0                	mov    %esi,%eax
  800cff:	29 d8                	sub    %ebx,%eax
  800d01:	50                   	push   %eax
  800d02:	89 d8                	mov    %ebx,%eax
  800d04:	03 45 0c             	add    0xc(%ebp),%eax
  800d07:	50                   	push   %eax
  800d08:	57                   	push   %edi
  800d09:	e8 42 ff ff ff       	call   800c50 <read>
		if (m < 0)
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	85 c0                	test   %eax,%eax
  800d13:	78 10                	js     800d25 <readn+0x41>
			return m;
		if (m == 0)
  800d15:	85 c0                	test   %eax,%eax
  800d17:	74 0a                	je     800d23 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800d19:	01 c3                	add    %eax,%ebx
  800d1b:	39 f3                	cmp    %esi,%ebx
  800d1d:	72 db                	jb     800cfa <readn+0x16>
  800d1f:	89 d8                	mov    %ebx,%eax
  800d21:	eb 02                	jmp    800d25 <readn+0x41>
  800d23:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800d25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	53                   	push   %ebx
  800d31:	83 ec 14             	sub    $0x14,%esp
  800d34:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d37:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d3a:	50                   	push   %eax
  800d3b:	53                   	push   %ebx
  800d3c:	e8 a6 fc ff ff       	call   8009e7 <fd_lookup>
  800d41:	83 c4 08             	add    $0x8,%esp
  800d44:	89 c2                	mov    %eax,%edx
  800d46:	85 c0                	test   %eax,%eax
  800d48:	78 6b                	js     800db5 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d4a:	83 ec 08             	sub    $0x8,%esp
  800d4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d50:	50                   	push   %eax
  800d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d54:	ff 30                	pushl  (%eax)
  800d56:	e8 e2 fc ff ff       	call   800a3d <dev_lookup>
  800d5b:	83 c4 10             	add    $0x10,%esp
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	78 4a                	js     800dac <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d65:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d69:	75 24                	jne    800d8f <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d6b:	a1 04 40 80 00       	mov    0x804004,%eax
  800d70:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800d76:	83 ec 04             	sub    $0x4,%esp
  800d79:	53                   	push   %ebx
  800d7a:	50                   	push   %eax
  800d7b:	68 91 26 80 00       	push   $0x802691
  800d80:	e8 c4 09 00 00       	call   801749 <cprintf>
		return -E_INVAL;
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d8d:	eb 26                	jmp    800db5 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d92:	8b 52 0c             	mov    0xc(%edx),%edx
  800d95:	85 d2                	test   %edx,%edx
  800d97:	74 17                	je     800db0 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d99:	83 ec 04             	sub    $0x4,%esp
  800d9c:	ff 75 10             	pushl  0x10(%ebp)
  800d9f:	ff 75 0c             	pushl  0xc(%ebp)
  800da2:	50                   	push   %eax
  800da3:	ff d2                	call   *%edx
  800da5:	89 c2                	mov    %eax,%edx
  800da7:	83 c4 10             	add    $0x10,%esp
  800daa:	eb 09                	jmp    800db5 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dac:	89 c2                	mov    %eax,%edx
  800dae:	eb 05                	jmp    800db5 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800db0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800db5:	89 d0                	mov    %edx,%eax
  800db7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dba:	c9                   	leave  
  800dbb:	c3                   	ret    

00800dbc <seek>:

int
seek(int fdnum, off_t offset)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800dc2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800dc5:	50                   	push   %eax
  800dc6:	ff 75 08             	pushl  0x8(%ebp)
  800dc9:	e8 19 fc ff ff       	call   8009e7 <fd_lookup>
  800dce:	83 c4 08             	add    $0x8,%esp
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	78 0e                	js     800de3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800dd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ddb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800dde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de3:	c9                   	leave  
  800de4:	c3                   	ret    

00800de5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	53                   	push   %ebx
  800de9:	83 ec 14             	sub    $0x14,%esp
  800dec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800def:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800df2:	50                   	push   %eax
  800df3:	53                   	push   %ebx
  800df4:	e8 ee fb ff ff       	call   8009e7 <fd_lookup>
  800df9:	83 c4 08             	add    $0x8,%esp
  800dfc:	89 c2                	mov    %eax,%edx
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	78 68                	js     800e6a <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e02:	83 ec 08             	sub    $0x8,%esp
  800e05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e08:	50                   	push   %eax
  800e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0c:	ff 30                	pushl  (%eax)
  800e0e:	e8 2a fc ff ff       	call   800a3d <dev_lookup>
  800e13:	83 c4 10             	add    $0x10,%esp
  800e16:	85 c0                	test   %eax,%eax
  800e18:	78 47                	js     800e61 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800e21:	75 24                	jne    800e47 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800e23:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800e28:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	53                   	push   %ebx
  800e32:	50                   	push   %eax
  800e33:	68 54 26 80 00       	push   $0x802654
  800e38:	e8 0c 09 00 00       	call   801749 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e45:	eb 23                	jmp    800e6a <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800e47:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e4a:	8b 52 18             	mov    0x18(%edx),%edx
  800e4d:	85 d2                	test   %edx,%edx
  800e4f:	74 14                	je     800e65 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800e51:	83 ec 08             	sub    $0x8,%esp
  800e54:	ff 75 0c             	pushl  0xc(%ebp)
  800e57:	50                   	push   %eax
  800e58:	ff d2                	call   *%edx
  800e5a:	89 c2                	mov    %eax,%edx
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	eb 09                	jmp    800e6a <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e61:	89 c2                	mov    %eax,%edx
  800e63:	eb 05                	jmp    800e6a <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800e65:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800e6a:	89 d0                	mov    %edx,%eax
  800e6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6f:	c9                   	leave  
  800e70:	c3                   	ret    

00800e71 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	53                   	push   %ebx
  800e75:	83 ec 14             	sub    $0x14,%esp
  800e78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e7e:	50                   	push   %eax
  800e7f:	ff 75 08             	pushl  0x8(%ebp)
  800e82:	e8 60 fb ff ff       	call   8009e7 <fd_lookup>
  800e87:	83 c4 08             	add    $0x8,%esp
  800e8a:	89 c2                	mov    %eax,%edx
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	78 58                	js     800ee8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e90:	83 ec 08             	sub    $0x8,%esp
  800e93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e96:	50                   	push   %eax
  800e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e9a:	ff 30                	pushl  (%eax)
  800e9c:	e8 9c fb ff ff       	call   800a3d <dev_lookup>
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 37                	js     800edf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eab:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800eaf:	74 32                	je     800ee3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800eb1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800eb4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ebb:	00 00 00 
	stat->st_isdir = 0;
  800ebe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ec5:	00 00 00 
	stat->st_dev = dev;
  800ec8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ece:	83 ec 08             	sub    $0x8,%esp
  800ed1:	53                   	push   %ebx
  800ed2:	ff 75 f0             	pushl  -0x10(%ebp)
  800ed5:	ff 50 14             	call   *0x14(%eax)
  800ed8:	89 c2                	mov    %eax,%edx
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	eb 09                	jmp    800ee8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800edf:	89 c2                	mov    %eax,%edx
  800ee1:	eb 05                	jmp    800ee8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ee3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800ee8:	89 d0                	mov    %edx,%eax
  800eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ef4:	83 ec 08             	sub    $0x8,%esp
  800ef7:	6a 00                	push   $0x0
  800ef9:	ff 75 08             	pushl  0x8(%ebp)
  800efc:	e8 e3 01 00 00       	call   8010e4 <open>
  800f01:	89 c3                	mov    %eax,%ebx
  800f03:	83 c4 10             	add    $0x10,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	78 1b                	js     800f25 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800f0a:	83 ec 08             	sub    $0x8,%esp
  800f0d:	ff 75 0c             	pushl  0xc(%ebp)
  800f10:	50                   	push   %eax
  800f11:	e8 5b ff ff ff       	call   800e71 <fstat>
  800f16:	89 c6                	mov    %eax,%esi
	close(fd);
  800f18:	89 1c 24             	mov    %ebx,(%esp)
  800f1b:	e8 f4 fb ff ff       	call   800b14 <close>
	return r;
  800f20:	83 c4 10             	add    $0x10,%esp
  800f23:	89 f0                	mov    %esi,%eax
}
  800f25:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
  800f31:	89 c6                	mov    %eax,%esi
  800f33:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800f35:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800f3c:	75 12                	jne    800f50 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800f3e:	83 ec 0c             	sub    $0xc,%esp
  800f41:	6a 01                	push   $0x1
  800f43:	e8 39 12 00 00       	call   802181 <ipc_find_env>
  800f48:	a3 00 40 80 00       	mov    %eax,0x804000
  800f4d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800f50:	6a 07                	push   $0x7
  800f52:	68 00 50 80 00       	push   $0x805000
  800f57:	56                   	push   %esi
  800f58:	ff 35 00 40 80 00    	pushl  0x804000
  800f5e:	e8 bc 11 00 00       	call   80211f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800f63:	83 c4 0c             	add    $0xc,%esp
  800f66:	6a 00                	push   $0x0
  800f68:	53                   	push   %ebx
  800f69:	6a 00                	push   $0x0
  800f6b:	e8 34 11 00 00       	call   8020a4 <ipc_recv>
}
  800f70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f73:	5b                   	pop    %ebx
  800f74:	5e                   	pop    %esi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f80:	8b 40 0c             	mov    0xc(%eax),%eax
  800f83:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f88:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f90:	ba 00 00 00 00       	mov    $0x0,%edx
  800f95:	b8 02 00 00 00       	mov    $0x2,%eax
  800f9a:	e8 8d ff ff ff       	call   800f2c <fsipc>
}
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	8b 40 0c             	mov    0xc(%eax),%eax
  800fad:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800fb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb7:	b8 06 00 00 00       	mov    $0x6,%eax
  800fbc:	e8 6b ff ff ff       	call   800f2c <fsipc>
}
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    

00800fc3 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	53                   	push   %ebx
  800fc7:	83 ec 04             	sub    $0x4,%esp
  800fca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800fcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd0:	8b 40 0c             	mov    0xc(%eax),%eax
  800fd3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800fd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdd:	b8 05 00 00 00       	mov    $0x5,%eax
  800fe2:	e8 45 ff ff ff       	call   800f2c <fsipc>
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 2c                	js     801017 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	68 00 50 80 00       	push   $0x805000
  800ff3:	53                   	push   %ebx
  800ff4:	e8 d5 0c 00 00       	call   801cce <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800ff9:	a1 80 50 80 00       	mov    0x805080,%eax
  800ffe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801004:	a1 84 50 80 00       	mov    0x805084,%eax
  801009:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80100f:	83 c4 10             	add    $0x10,%esp
  801012:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801017:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801025:	8b 55 08             	mov    0x8(%ebp),%edx
  801028:	8b 52 0c             	mov    0xc(%edx),%edx
  80102b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801031:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801036:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80103b:	0f 47 c2             	cmova  %edx,%eax
  80103e:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801043:	50                   	push   %eax
  801044:	ff 75 0c             	pushl  0xc(%ebp)
  801047:	68 08 50 80 00       	push   $0x805008
  80104c:	e8 0f 0e 00 00       	call   801e60 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801051:	ba 00 00 00 00       	mov    $0x0,%edx
  801056:	b8 04 00 00 00       	mov    $0x4,%eax
  80105b:	e8 cc fe ff ff       	call   800f2c <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801060:	c9                   	leave  
  801061:	c3                   	ret    

00801062 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	56                   	push   %esi
  801066:	53                   	push   %ebx
  801067:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80106a:	8b 45 08             	mov    0x8(%ebp),%eax
  80106d:	8b 40 0c             	mov    0xc(%eax),%eax
  801070:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801075:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80107b:	ba 00 00 00 00       	mov    $0x0,%edx
  801080:	b8 03 00 00 00       	mov    $0x3,%eax
  801085:	e8 a2 fe ff ff       	call   800f2c <fsipc>
  80108a:	89 c3                	mov    %eax,%ebx
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 4b                	js     8010db <devfile_read+0x79>
		return r;
	assert(r <= n);
  801090:	39 c6                	cmp    %eax,%esi
  801092:	73 16                	jae    8010aa <devfile_read+0x48>
  801094:	68 c0 26 80 00       	push   $0x8026c0
  801099:	68 c7 26 80 00       	push   $0x8026c7
  80109e:	6a 7c                	push   $0x7c
  8010a0:	68 dc 26 80 00       	push   $0x8026dc
  8010a5:	e8 c6 05 00 00       	call   801670 <_panic>
	assert(r <= PGSIZE);
  8010aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8010af:	7e 16                	jle    8010c7 <devfile_read+0x65>
  8010b1:	68 e7 26 80 00       	push   $0x8026e7
  8010b6:	68 c7 26 80 00       	push   $0x8026c7
  8010bb:	6a 7d                	push   $0x7d
  8010bd:	68 dc 26 80 00       	push   $0x8026dc
  8010c2:	e8 a9 05 00 00       	call   801670 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8010c7:	83 ec 04             	sub    $0x4,%esp
  8010ca:	50                   	push   %eax
  8010cb:	68 00 50 80 00       	push   $0x805000
  8010d0:	ff 75 0c             	pushl  0xc(%ebp)
  8010d3:	e8 88 0d 00 00       	call   801e60 <memmove>
	return r;
  8010d8:	83 c4 10             	add    $0x10,%esp
}
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 20             	sub    $0x20,%esp
  8010eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8010ee:	53                   	push   %ebx
  8010ef:	e8 a1 0b 00 00       	call   801c95 <strlen>
  8010f4:	83 c4 10             	add    $0x10,%esp
  8010f7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010fc:	7f 67                	jg     801165 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	e8 8e f8 ff ff       	call   800998 <fd_alloc>
  80110a:	83 c4 10             	add    $0x10,%esp
		return r;
  80110d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 57                	js     80116a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801113:	83 ec 08             	sub    $0x8,%esp
  801116:	53                   	push   %ebx
  801117:	68 00 50 80 00       	push   $0x805000
  80111c:	e8 ad 0b 00 00       	call   801cce <strcpy>
	fsipcbuf.open.req_omode = mode;
  801121:	8b 45 0c             	mov    0xc(%ebp),%eax
  801124:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801129:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80112c:	b8 01 00 00 00       	mov    $0x1,%eax
  801131:	e8 f6 fd ff ff       	call   800f2c <fsipc>
  801136:	89 c3                	mov    %eax,%ebx
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	85 c0                	test   %eax,%eax
  80113d:	79 14                	jns    801153 <open+0x6f>
		fd_close(fd, 0);
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	6a 00                	push   $0x0
  801144:	ff 75 f4             	pushl  -0xc(%ebp)
  801147:	e8 47 f9 ff ff       	call   800a93 <fd_close>
		return r;
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	89 da                	mov    %ebx,%edx
  801151:	eb 17                	jmp    80116a <open+0x86>
	}

	return fd2num(fd);
  801153:	83 ec 0c             	sub    $0xc,%esp
  801156:	ff 75 f4             	pushl  -0xc(%ebp)
  801159:	e8 13 f8 ff ff       	call   800971 <fd2num>
  80115e:	89 c2                	mov    %eax,%edx
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	eb 05                	jmp    80116a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801165:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80116a:	89 d0                	mov    %edx,%eax
  80116c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801177:	ba 00 00 00 00       	mov    $0x0,%edx
  80117c:	b8 08 00 00 00       	mov    $0x8,%eax
  801181:	e8 a6 fd ff ff       	call   800f2c <fsipc>
}
  801186:	c9                   	leave  
  801187:	c3                   	ret    

00801188 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
  80118d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801190:	83 ec 0c             	sub    $0xc,%esp
  801193:	ff 75 08             	pushl  0x8(%ebp)
  801196:	e8 e6 f7 ff ff       	call   800981 <fd2data>
  80119b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80119d:	83 c4 08             	add    $0x8,%esp
  8011a0:	68 f3 26 80 00       	push   $0x8026f3
  8011a5:	53                   	push   %ebx
  8011a6:	e8 23 0b 00 00       	call   801cce <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8011ab:	8b 46 04             	mov    0x4(%esi),%eax
  8011ae:	2b 06                	sub    (%esi),%eax
  8011b0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8011b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011bd:	00 00 00 
	stat->st_dev = &devpipe;
  8011c0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8011c7:	30 80 00 
	return 0;
}
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	53                   	push   %ebx
  8011da:	83 ec 0c             	sub    $0xc,%esp
  8011dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8011e0:	53                   	push   %ebx
  8011e1:	6a 00                	push   $0x0
  8011e3:	e8 41 f0 ff ff       	call   800229 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8011e8:	89 1c 24             	mov    %ebx,(%esp)
  8011eb:	e8 91 f7 ff ff       	call   800981 <fd2data>
  8011f0:	83 c4 08             	add    $0x8,%esp
  8011f3:	50                   	push   %eax
  8011f4:	6a 00                	push   $0x0
  8011f6:	e8 2e f0 ff ff       	call   800229 <sys_page_unmap>
}
  8011fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011fe:	c9                   	leave  
  8011ff:	c3                   	ret    

00801200 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	57                   	push   %edi
  801204:	56                   	push   %esi
  801205:	53                   	push   %ebx
  801206:	83 ec 1c             	sub    $0x1c,%esp
  801209:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80120c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80120e:	a1 04 40 80 00       	mov    0x804004,%eax
  801213:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801219:	83 ec 0c             	sub    $0xc,%esp
  80121c:	ff 75 e0             	pushl  -0x20(%ebp)
  80121f:	e8 a2 0f 00 00       	call   8021c6 <pageref>
  801224:	89 c3                	mov    %eax,%ebx
  801226:	89 3c 24             	mov    %edi,(%esp)
  801229:	e8 98 0f 00 00       	call   8021c6 <pageref>
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	39 c3                	cmp    %eax,%ebx
  801233:	0f 94 c1             	sete   %cl
  801236:	0f b6 c9             	movzbl %cl,%ecx
  801239:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80123c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801242:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  801248:	39 ce                	cmp    %ecx,%esi
  80124a:	74 1e                	je     80126a <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  80124c:	39 c3                	cmp    %eax,%ebx
  80124e:	75 be                	jne    80120e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801250:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801256:	ff 75 e4             	pushl  -0x1c(%ebp)
  801259:	50                   	push   %eax
  80125a:	56                   	push   %esi
  80125b:	68 fa 26 80 00       	push   $0x8026fa
  801260:	e8 e4 04 00 00       	call   801749 <cprintf>
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	eb a4                	jmp    80120e <_pipeisclosed+0xe>
	}
}
  80126a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80126d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	57                   	push   %edi
  801279:	56                   	push   %esi
  80127a:	53                   	push   %ebx
  80127b:	83 ec 28             	sub    $0x28,%esp
  80127e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801281:	56                   	push   %esi
  801282:	e8 fa f6 ff ff       	call   800981 <fd2data>
  801287:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801289:	83 c4 10             	add    $0x10,%esp
  80128c:	bf 00 00 00 00       	mov    $0x0,%edi
  801291:	eb 4b                	jmp    8012de <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801293:	89 da                	mov    %ebx,%edx
  801295:	89 f0                	mov    %esi,%eax
  801297:	e8 64 ff ff ff       	call   801200 <_pipeisclosed>
  80129c:	85 c0                	test   %eax,%eax
  80129e:	75 48                	jne    8012e8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8012a0:	e8 e0 ee ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8012a5:	8b 43 04             	mov    0x4(%ebx),%eax
  8012a8:	8b 0b                	mov    (%ebx),%ecx
  8012aa:	8d 51 20             	lea    0x20(%ecx),%edx
  8012ad:	39 d0                	cmp    %edx,%eax
  8012af:	73 e2                	jae    801293 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8012b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8012b8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8012bb:	89 c2                	mov    %eax,%edx
  8012bd:	c1 fa 1f             	sar    $0x1f,%edx
  8012c0:	89 d1                	mov    %edx,%ecx
  8012c2:	c1 e9 1b             	shr    $0x1b,%ecx
  8012c5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8012c8:	83 e2 1f             	and    $0x1f,%edx
  8012cb:	29 ca                	sub    %ecx,%edx
  8012cd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8012d1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8012d5:	83 c0 01             	add    $0x1,%eax
  8012d8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012db:	83 c7 01             	add    $0x1,%edi
  8012de:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8012e1:	75 c2                	jne    8012a5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8012e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8012e6:	eb 05                	jmp    8012ed <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012e8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8012ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5f                   	pop    %edi
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	57                   	push   %edi
  8012f9:	56                   	push   %esi
  8012fa:	53                   	push   %ebx
  8012fb:	83 ec 18             	sub    $0x18,%esp
  8012fe:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801301:	57                   	push   %edi
  801302:	e8 7a f6 ff ff       	call   800981 <fd2data>
  801307:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801311:	eb 3d                	jmp    801350 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801313:	85 db                	test   %ebx,%ebx
  801315:	74 04                	je     80131b <devpipe_read+0x26>
				return i;
  801317:	89 d8                	mov    %ebx,%eax
  801319:	eb 44                	jmp    80135f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80131b:	89 f2                	mov    %esi,%edx
  80131d:	89 f8                	mov    %edi,%eax
  80131f:	e8 dc fe ff ff       	call   801200 <_pipeisclosed>
  801324:	85 c0                	test   %eax,%eax
  801326:	75 32                	jne    80135a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801328:	e8 58 ee ff ff       	call   800185 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80132d:	8b 06                	mov    (%esi),%eax
  80132f:	3b 46 04             	cmp    0x4(%esi),%eax
  801332:	74 df                	je     801313 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801334:	99                   	cltd   
  801335:	c1 ea 1b             	shr    $0x1b,%edx
  801338:	01 d0                	add    %edx,%eax
  80133a:	83 e0 1f             	and    $0x1f,%eax
  80133d:	29 d0                	sub    %edx,%eax
  80133f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801347:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80134a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80134d:	83 c3 01             	add    $0x1,%ebx
  801350:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801353:	75 d8                	jne    80132d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801355:	8b 45 10             	mov    0x10(%ebp),%eax
  801358:	eb 05                	jmp    80135f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80135a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80135f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801362:	5b                   	pop    %ebx
  801363:	5e                   	pop    %esi
  801364:	5f                   	pop    %edi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	56                   	push   %esi
  80136b:	53                   	push   %ebx
  80136c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80136f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801372:	50                   	push   %eax
  801373:	e8 20 f6 ff ff       	call   800998 <fd_alloc>
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	89 c2                	mov    %eax,%edx
  80137d:	85 c0                	test   %eax,%eax
  80137f:	0f 88 2c 01 00 00    	js     8014b1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801385:	83 ec 04             	sub    $0x4,%esp
  801388:	68 07 04 00 00       	push   $0x407
  80138d:	ff 75 f4             	pushl  -0xc(%ebp)
  801390:	6a 00                	push   $0x0
  801392:	e8 0d ee ff ff       	call   8001a4 <sys_page_alloc>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	89 c2                	mov    %eax,%edx
  80139c:	85 c0                	test   %eax,%eax
  80139e:	0f 88 0d 01 00 00    	js     8014b1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8013a4:	83 ec 0c             	sub    $0xc,%esp
  8013a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013aa:	50                   	push   %eax
  8013ab:	e8 e8 f5 ff ff       	call   800998 <fd_alloc>
  8013b0:	89 c3                	mov    %eax,%ebx
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	0f 88 e2 00 00 00    	js     80149f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013bd:	83 ec 04             	sub    $0x4,%esp
  8013c0:	68 07 04 00 00       	push   $0x407
  8013c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8013c8:	6a 00                	push   $0x0
  8013ca:	e8 d5 ed ff ff       	call   8001a4 <sys_page_alloc>
  8013cf:	89 c3                	mov    %eax,%ebx
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	0f 88 c3 00 00 00    	js     80149f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8013dc:	83 ec 0c             	sub    $0xc,%esp
  8013df:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e2:	e8 9a f5 ff ff       	call   800981 <fd2data>
  8013e7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013e9:	83 c4 0c             	add    $0xc,%esp
  8013ec:	68 07 04 00 00       	push   $0x407
  8013f1:	50                   	push   %eax
  8013f2:	6a 00                	push   $0x0
  8013f4:	e8 ab ed ff ff       	call   8001a4 <sys_page_alloc>
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	0f 88 89 00 00 00    	js     80148f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801406:	83 ec 0c             	sub    $0xc,%esp
  801409:	ff 75 f0             	pushl  -0x10(%ebp)
  80140c:	e8 70 f5 ff ff       	call   800981 <fd2data>
  801411:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801418:	50                   	push   %eax
  801419:	6a 00                	push   $0x0
  80141b:	56                   	push   %esi
  80141c:	6a 00                	push   $0x0
  80141e:	e8 c4 ed ff ff       	call   8001e7 <sys_page_map>
  801423:	89 c3                	mov    %eax,%ebx
  801425:	83 c4 20             	add    $0x20,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 55                	js     801481 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80142c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801432:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801435:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801437:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801441:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801447:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80144c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801456:	83 ec 0c             	sub    $0xc,%esp
  801459:	ff 75 f4             	pushl  -0xc(%ebp)
  80145c:	e8 10 f5 ff ff       	call   800971 <fd2num>
  801461:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801464:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801466:	83 c4 04             	add    $0x4,%esp
  801469:	ff 75 f0             	pushl  -0x10(%ebp)
  80146c:	e8 00 f5 ff ff       	call   800971 <fd2num>
  801471:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801474:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	ba 00 00 00 00       	mov    $0x0,%edx
  80147f:	eb 30                	jmp    8014b1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	56                   	push   %esi
  801485:	6a 00                	push   $0x0
  801487:	e8 9d ed ff ff       	call   800229 <sys_page_unmap>
  80148c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80148f:	83 ec 08             	sub    $0x8,%esp
  801492:	ff 75 f0             	pushl  -0x10(%ebp)
  801495:	6a 00                	push   $0x0
  801497:	e8 8d ed ff ff       	call   800229 <sys_page_unmap>
  80149c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a5:	6a 00                	push   $0x0
  8014a7:	e8 7d ed ff ff       	call   800229 <sys_page_unmap>
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8014b1:	89 d0                	mov    %edx,%eax
  8014b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    

008014ba <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c3:	50                   	push   %eax
  8014c4:	ff 75 08             	pushl  0x8(%ebp)
  8014c7:	e8 1b f5 ff ff       	call   8009e7 <fd_lookup>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 18                	js     8014eb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d9:	e8 a3 f4 ff ff       	call   800981 <fd2data>
	return _pipeisclosed(fd, p);
  8014de:	89 c2                	mov    %eax,%edx
  8014e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e3:	e8 18 fd ff ff       	call   801200 <_pipeisclosed>
  8014e8:	83 c4 10             	add    $0x10,%esp
}
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8014fd:	68 12 27 80 00       	push   $0x802712
  801502:	ff 75 0c             	pushl  0xc(%ebp)
  801505:	e8 c4 07 00 00       	call   801cce <strcpy>
	return 0;
}
  80150a:	b8 00 00 00 00       	mov    $0x0,%eax
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	57                   	push   %edi
  801515:	56                   	push   %esi
  801516:	53                   	push   %ebx
  801517:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80151d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801522:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801528:	eb 2d                	jmp    801557 <devcons_write+0x46>
		m = n - tot;
  80152a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80152d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80152f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801532:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801537:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	53                   	push   %ebx
  80153e:	03 45 0c             	add    0xc(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	57                   	push   %edi
  801543:	e8 18 09 00 00       	call   801e60 <memmove>
		sys_cputs(buf, m);
  801548:	83 c4 08             	add    $0x8,%esp
  80154b:	53                   	push   %ebx
  80154c:	57                   	push   %edi
  80154d:	e8 96 eb ff ff       	call   8000e8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801552:	01 de                	add    %ebx,%esi
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	89 f0                	mov    %esi,%eax
  801559:	3b 75 10             	cmp    0x10(%ebp),%esi
  80155c:	72 cc                	jb     80152a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80155e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801561:	5b                   	pop    %ebx
  801562:	5e                   	pop    %esi
  801563:	5f                   	pop    %edi
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	83 ec 08             	sub    $0x8,%esp
  80156c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801571:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801575:	74 2a                	je     8015a1 <devcons_read+0x3b>
  801577:	eb 05                	jmp    80157e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801579:	e8 07 ec ff ff       	call   800185 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80157e:	e8 83 eb ff ff       	call   800106 <sys_cgetc>
  801583:	85 c0                	test   %eax,%eax
  801585:	74 f2                	je     801579 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801587:	85 c0                	test   %eax,%eax
  801589:	78 16                	js     8015a1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80158b:	83 f8 04             	cmp    $0x4,%eax
  80158e:	74 0c                	je     80159c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801590:	8b 55 0c             	mov    0xc(%ebp),%edx
  801593:	88 02                	mov    %al,(%edx)
	return 1;
  801595:	b8 01 00 00 00       	mov    $0x1,%eax
  80159a:	eb 05                	jmp    8015a1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80159c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    

008015a3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8015a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ac:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8015af:	6a 01                	push   $0x1
  8015b1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8015b4:	50                   	push   %eax
  8015b5:	e8 2e eb ff ff       	call   8000e8 <sys_cputs>
}
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <getchar>:

int
getchar(void)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8015c5:	6a 01                	push   $0x1
  8015c7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8015ca:	50                   	push   %eax
  8015cb:	6a 00                	push   $0x0
  8015cd:	e8 7e f6 ff ff       	call   800c50 <read>
	if (r < 0)
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	78 0f                	js     8015e8 <getchar+0x29>
		return r;
	if (r < 1)
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	7e 06                	jle    8015e3 <getchar+0x24>
		return -E_EOF;
	return c;
  8015dd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8015e1:	eb 05                	jmp    8015e8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8015e3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	ff 75 08             	pushl  0x8(%ebp)
  8015f7:	e8 eb f3 ff ff       	call   8009e7 <fd_lookup>
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 11                	js     801614 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801603:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801606:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80160c:	39 10                	cmp    %edx,(%eax)
  80160e:	0f 94 c0             	sete   %al
  801611:	0f b6 c0             	movzbl %al,%eax
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <opencons>:

int
opencons(void)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80161c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161f:	50                   	push   %eax
  801620:	e8 73 f3 ff ff       	call   800998 <fd_alloc>
  801625:	83 c4 10             	add    $0x10,%esp
		return r;
  801628:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 3e                	js     80166c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80162e:	83 ec 04             	sub    $0x4,%esp
  801631:	68 07 04 00 00       	push   $0x407
  801636:	ff 75 f4             	pushl  -0xc(%ebp)
  801639:	6a 00                	push   $0x0
  80163b:	e8 64 eb ff ff       	call   8001a4 <sys_page_alloc>
  801640:	83 c4 10             	add    $0x10,%esp
		return r;
  801643:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801645:	85 c0                	test   %eax,%eax
  801647:	78 23                	js     80166c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801649:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80164f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801652:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801654:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801657:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80165e:	83 ec 0c             	sub    $0xc,%esp
  801661:	50                   	push   %eax
  801662:	e8 0a f3 ff ff       	call   800971 <fd2num>
  801667:	89 c2                	mov    %eax,%edx
  801669:	83 c4 10             	add    $0x10,%esp
}
  80166c:	89 d0                	mov    %edx,%eax
  80166e:	c9                   	leave  
  80166f:	c3                   	ret    

00801670 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	56                   	push   %esi
  801674:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801675:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801678:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80167e:	e8 e3 ea ff ff       	call   800166 <sys_getenvid>
  801683:	83 ec 0c             	sub    $0xc,%esp
  801686:	ff 75 0c             	pushl  0xc(%ebp)
  801689:	ff 75 08             	pushl  0x8(%ebp)
  80168c:	56                   	push   %esi
  80168d:	50                   	push   %eax
  80168e:	68 20 27 80 00       	push   $0x802720
  801693:	e8 b1 00 00 00       	call   801749 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801698:	83 c4 18             	add    $0x18,%esp
  80169b:	53                   	push   %ebx
  80169c:	ff 75 10             	pushl  0x10(%ebp)
  80169f:	e8 54 00 00 00       	call   8016f8 <vcprintf>
	cprintf("\n");
  8016a4:	c7 04 24 71 25 80 00 	movl   $0x802571,(%esp)
  8016ab:	e8 99 00 00 00       	call   801749 <cprintf>
  8016b0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8016b3:	cc                   	int3   
  8016b4:	eb fd                	jmp    8016b3 <_panic+0x43>

008016b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 04             	sub    $0x4,%esp
  8016bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8016c0:	8b 13                	mov    (%ebx),%edx
  8016c2:	8d 42 01             	lea    0x1(%edx),%eax
  8016c5:	89 03                	mov    %eax,(%ebx)
  8016c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8016ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8016d3:	75 1a                	jne    8016ef <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	68 ff 00 00 00       	push   $0xff
  8016dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8016e0:	50                   	push   %eax
  8016e1:	e8 02 ea ff ff       	call   8000e8 <sys_cputs>
		b->idx = 0;
  8016e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8016ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8016f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801701:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801708:	00 00 00 
	b.cnt = 0;
  80170b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801712:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801715:	ff 75 0c             	pushl  0xc(%ebp)
  801718:	ff 75 08             	pushl  0x8(%ebp)
  80171b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801721:	50                   	push   %eax
  801722:	68 b6 16 80 00       	push   $0x8016b6
  801727:	e8 54 01 00 00       	call   801880 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80172c:	83 c4 08             	add    $0x8,%esp
  80172f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801735:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80173b:	50                   	push   %eax
  80173c:	e8 a7 e9 ff ff       	call   8000e8 <sys_cputs>

	return b.cnt;
}
  801741:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801747:	c9                   	leave  
  801748:	c3                   	ret    

00801749 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80174f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801752:	50                   	push   %eax
  801753:	ff 75 08             	pushl  0x8(%ebp)
  801756:	e8 9d ff ff ff       	call   8016f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	57                   	push   %edi
  801761:	56                   	push   %esi
  801762:	53                   	push   %ebx
  801763:	83 ec 1c             	sub    $0x1c,%esp
  801766:	89 c7                	mov    %eax,%edi
  801768:	89 d6                	mov    %edx,%esi
  80176a:	8b 45 08             	mov    0x8(%ebp),%eax
  80176d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801770:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801773:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801776:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801779:	bb 00 00 00 00       	mov    $0x0,%ebx
  80177e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801781:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801784:	39 d3                	cmp    %edx,%ebx
  801786:	72 05                	jb     80178d <printnum+0x30>
  801788:	39 45 10             	cmp    %eax,0x10(%ebp)
  80178b:	77 45                	ja     8017d2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80178d:	83 ec 0c             	sub    $0xc,%esp
  801790:	ff 75 18             	pushl  0x18(%ebp)
  801793:	8b 45 14             	mov    0x14(%ebp),%eax
  801796:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801799:	53                   	push   %ebx
  80179a:	ff 75 10             	pushl  0x10(%ebp)
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8017a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8017a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8017ac:	e8 5f 0a 00 00       	call   802210 <__udivdi3>
  8017b1:	83 c4 18             	add    $0x18,%esp
  8017b4:	52                   	push   %edx
  8017b5:	50                   	push   %eax
  8017b6:	89 f2                	mov    %esi,%edx
  8017b8:	89 f8                	mov    %edi,%eax
  8017ba:	e8 9e ff ff ff       	call   80175d <printnum>
  8017bf:	83 c4 20             	add    $0x20,%esp
  8017c2:	eb 18                	jmp    8017dc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8017c4:	83 ec 08             	sub    $0x8,%esp
  8017c7:	56                   	push   %esi
  8017c8:	ff 75 18             	pushl  0x18(%ebp)
  8017cb:	ff d7                	call   *%edi
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	eb 03                	jmp    8017d5 <printnum+0x78>
  8017d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017d5:	83 eb 01             	sub    $0x1,%ebx
  8017d8:	85 db                	test   %ebx,%ebx
  8017da:	7f e8                	jg     8017c4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017dc:	83 ec 08             	sub    $0x8,%esp
  8017df:	56                   	push   %esi
  8017e0:	83 ec 04             	sub    $0x4,%esp
  8017e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8017e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8017ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8017ef:	e8 4c 0b 00 00       	call   802340 <__umoddi3>
  8017f4:	83 c4 14             	add    $0x14,%esp
  8017f7:	0f be 80 43 27 80 00 	movsbl 0x802743(%eax),%eax
  8017fe:	50                   	push   %eax
  8017ff:	ff d7                	call   *%edi
}
  801801:	83 c4 10             	add    $0x10,%esp
  801804:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801807:	5b                   	pop    %ebx
  801808:	5e                   	pop    %esi
  801809:	5f                   	pop    %edi
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80180f:	83 fa 01             	cmp    $0x1,%edx
  801812:	7e 0e                	jle    801822 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801814:	8b 10                	mov    (%eax),%edx
  801816:	8d 4a 08             	lea    0x8(%edx),%ecx
  801819:	89 08                	mov    %ecx,(%eax)
  80181b:	8b 02                	mov    (%edx),%eax
  80181d:	8b 52 04             	mov    0x4(%edx),%edx
  801820:	eb 22                	jmp    801844 <getuint+0x38>
	else if (lflag)
  801822:	85 d2                	test   %edx,%edx
  801824:	74 10                	je     801836 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801826:	8b 10                	mov    (%eax),%edx
  801828:	8d 4a 04             	lea    0x4(%edx),%ecx
  80182b:	89 08                	mov    %ecx,(%eax)
  80182d:	8b 02                	mov    (%edx),%eax
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	eb 0e                	jmp    801844 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801836:	8b 10                	mov    (%eax),%edx
  801838:	8d 4a 04             	lea    0x4(%edx),%ecx
  80183b:	89 08                	mov    %ecx,(%eax)
  80183d:	8b 02                	mov    (%edx),%eax
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801844:	5d                   	pop    %ebp
  801845:	c3                   	ret    

00801846 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80184c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801850:	8b 10                	mov    (%eax),%edx
  801852:	3b 50 04             	cmp    0x4(%eax),%edx
  801855:	73 0a                	jae    801861 <sprintputch+0x1b>
		*b->buf++ = ch;
  801857:	8d 4a 01             	lea    0x1(%edx),%ecx
  80185a:	89 08                	mov    %ecx,(%eax)
  80185c:	8b 45 08             	mov    0x8(%ebp),%eax
  80185f:	88 02                	mov    %al,(%edx)
}
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801869:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80186c:	50                   	push   %eax
  80186d:	ff 75 10             	pushl  0x10(%ebp)
  801870:	ff 75 0c             	pushl  0xc(%ebp)
  801873:	ff 75 08             	pushl  0x8(%ebp)
  801876:	e8 05 00 00 00       	call   801880 <vprintfmt>
	va_end(ap);
}
  80187b:	83 c4 10             	add    $0x10,%esp
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	57                   	push   %edi
  801884:	56                   	push   %esi
  801885:	53                   	push   %ebx
  801886:	83 ec 2c             	sub    $0x2c,%esp
  801889:	8b 75 08             	mov    0x8(%ebp),%esi
  80188c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80188f:	8b 7d 10             	mov    0x10(%ebp),%edi
  801892:	eb 12                	jmp    8018a6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801894:	85 c0                	test   %eax,%eax
  801896:	0f 84 89 03 00 00    	je     801c25 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80189c:	83 ec 08             	sub    $0x8,%esp
  80189f:	53                   	push   %ebx
  8018a0:	50                   	push   %eax
  8018a1:	ff d6                	call   *%esi
  8018a3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8018a6:	83 c7 01             	add    $0x1,%edi
  8018a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018ad:	83 f8 25             	cmp    $0x25,%eax
  8018b0:	75 e2                	jne    801894 <vprintfmt+0x14>
  8018b2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8018b6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8018bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018c4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	eb 07                	jmp    8018d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018d5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d9:	8d 47 01             	lea    0x1(%edi),%eax
  8018dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018df:	0f b6 07             	movzbl (%edi),%eax
  8018e2:	0f b6 c8             	movzbl %al,%ecx
  8018e5:	83 e8 23             	sub    $0x23,%eax
  8018e8:	3c 55                	cmp    $0x55,%al
  8018ea:	0f 87 1a 03 00 00    	ja     801c0a <vprintfmt+0x38a>
  8018f0:	0f b6 c0             	movzbl %al,%eax
  8018f3:	ff 24 85 80 28 80 00 	jmp    *0x802880(,%eax,4)
  8018fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8018fd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801901:	eb d6                	jmp    8018d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801903:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801906:	b8 00 00 00 00       	mov    $0x0,%eax
  80190b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80190e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801911:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801915:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801918:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80191b:	83 fa 09             	cmp    $0x9,%edx
  80191e:	77 39                	ja     801959 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801920:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801923:	eb e9                	jmp    80190e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801925:	8b 45 14             	mov    0x14(%ebp),%eax
  801928:	8d 48 04             	lea    0x4(%eax),%ecx
  80192b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80192e:	8b 00                	mov    (%eax),%eax
  801930:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801933:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801936:	eb 27                	jmp    80195f <vprintfmt+0xdf>
  801938:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80193b:	85 c0                	test   %eax,%eax
  80193d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801942:	0f 49 c8             	cmovns %eax,%ecx
  801945:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801948:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80194b:	eb 8c                	jmp    8018d9 <vprintfmt+0x59>
  80194d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801950:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801957:	eb 80                	jmp    8018d9 <vprintfmt+0x59>
  801959:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80195c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80195f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801963:	0f 89 70 ff ff ff    	jns    8018d9 <vprintfmt+0x59>
				width = precision, precision = -1;
  801969:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80196c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80196f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801976:	e9 5e ff ff ff       	jmp    8018d9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80197b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801981:	e9 53 ff ff ff       	jmp    8018d9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801986:	8b 45 14             	mov    0x14(%ebp),%eax
  801989:	8d 50 04             	lea    0x4(%eax),%edx
  80198c:	89 55 14             	mov    %edx,0x14(%ebp)
  80198f:	83 ec 08             	sub    $0x8,%esp
  801992:	53                   	push   %ebx
  801993:	ff 30                	pushl  (%eax)
  801995:	ff d6                	call   *%esi
			break;
  801997:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80199a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80199d:	e9 04 ff ff ff       	jmp    8018a6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8019a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a5:	8d 50 04             	lea    0x4(%eax),%edx
  8019a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8019ab:	8b 00                	mov    (%eax),%eax
  8019ad:	99                   	cltd   
  8019ae:	31 d0                	xor    %edx,%eax
  8019b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8019b2:	83 f8 0f             	cmp    $0xf,%eax
  8019b5:	7f 0b                	jg     8019c2 <vprintfmt+0x142>
  8019b7:	8b 14 85 e0 29 80 00 	mov    0x8029e0(,%eax,4),%edx
  8019be:	85 d2                	test   %edx,%edx
  8019c0:	75 18                	jne    8019da <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8019c2:	50                   	push   %eax
  8019c3:	68 5b 27 80 00       	push   $0x80275b
  8019c8:	53                   	push   %ebx
  8019c9:	56                   	push   %esi
  8019ca:	e8 94 fe ff ff       	call   801863 <printfmt>
  8019cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019d5:	e9 cc fe ff ff       	jmp    8018a6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8019da:	52                   	push   %edx
  8019db:	68 d9 26 80 00       	push   $0x8026d9
  8019e0:	53                   	push   %ebx
  8019e1:	56                   	push   %esi
  8019e2:	e8 7c fe ff ff       	call   801863 <printfmt>
  8019e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019ed:	e9 b4 fe ff ff       	jmp    8018a6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8019f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f5:	8d 50 04             	lea    0x4(%eax),%edx
  8019f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8019fb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8019fd:	85 ff                	test   %edi,%edi
  8019ff:	b8 54 27 80 00       	mov    $0x802754,%eax
  801a04:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801a07:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801a0b:	0f 8e 94 00 00 00    	jle    801aa5 <vprintfmt+0x225>
  801a11:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801a15:	0f 84 98 00 00 00    	je     801ab3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801a1b:	83 ec 08             	sub    $0x8,%esp
  801a1e:	ff 75 d0             	pushl  -0x30(%ebp)
  801a21:	57                   	push   %edi
  801a22:	e8 86 02 00 00       	call   801cad <strnlen>
  801a27:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801a2a:	29 c1                	sub    %eax,%ecx
  801a2c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801a2f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801a32:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801a36:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a39:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801a3c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a3e:	eb 0f                	jmp    801a4f <vprintfmt+0x1cf>
					putch(padc, putdat);
  801a40:	83 ec 08             	sub    $0x8,%esp
  801a43:	53                   	push   %ebx
  801a44:	ff 75 e0             	pushl  -0x20(%ebp)
  801a47:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a49:	83 ef 01             	sub    $0x1,%edi
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	85 ff                	test   %edi,%edi
  801a51:	7f ed                	jg     801a40 <vprintfmt+0x1c0>
  801a53:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801a56:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801a59:	85 c9                	test   %ecx,%ecx
  801a5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a60:	0f 49 c1             	cmovns %ecx,%eax
  801a63:	29 c1                	sub    %eax,%ecx
  801a65:	89 75 08             	mov    %esi,0x8(%ebp)
  801a68:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a6b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a6e:	89 cb                	mov    %ecx,%ebx
  801a70:	eb 4d                	jmp    801abf <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a72:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a76:	74 1b                	je     801a93 <vprintfmt+0x213>
  801a78:	0f be c0             	movsbl %al,%eax
  801a7b:	83 e8 20             	sub    $0x20,%eax
  801a7e:	83 f8 5e             	cmp    $0x5e,%eax
  801a81:	76 10                	jbe    801a93 <vprintfmt+0x213>
					putch('?', putdat);
  801a83:	83 ec 08             	sub    $0x8,%esp
  801a86:	ff 75 0c             	pushl  0xc(%ebp)
  801a89:	6a 3f                	push   $0x3f
  801a8b:	ff 55 08             	call   *0x8(%ebp)
  801a8e:	83 c4 10             	add    $0x10,%esp
  801a91:	eb 0d                	jmp    801aa0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a93:	83 ec 08             	sub    $0x8,%esp
  801a96:	ff 75 0c             	pushl  0xc(%ebp)
  801a99:	52                   	push   %edx
  801a9a:	ff 55 08             	call   *0x8(%ebp)
  801a9d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801aa0:	83 eb 01             	sub    $0x1,%ebx
  801aa3:	eb 1a                	jmp    801abf <vprintfmt+0x23f>
  801aa5:	89 75 08             	mov    %esi,0x8(%ebp)
  801aa8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801aab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801aae:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ab1:	eb 0c                	jmp    801abf <vprintfmt+0x23f>
  801ab3:	89 75 08             	mov    %esi,0x8(%ebp)
  801ab6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801ab9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801abc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801abf:	83 c7 01             	add    $0x1,%edi
  801ac2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ac6:	0f be d0             	movsbl %al,%edx
  801ac9:	85 d2                	test   %edx,%edx
  801acb:	74 23                	je     801af0 <vprintfmt+0x270>
  801acd:	85 f6                	test   %esi,%esi
  801acf:	78 a1                	js     801a72 <vprintfmt+0x1f2>
  801ad1:	83 ee 01             	sub    $0x1,%esi
  801ad4:	79 9c                	jns    801a72 <vprintfmt+0x1f2>
  801ad6:	89 df                	mov    %ebx,%edi
  801ad8:	8b 75 08             	mov    0x8(%ebp),%esi
  801adb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ade:	eb 18                	jmp    801af8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	53                   	push   %ebx
  801ae4:	6a 20                	push   $0x20
  801ae6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801ae8:	83 ef 01             	sub    $0x1,%edi
  801aeb:	83 c4 10             	add    $0x10,%esp
  801aee:	eb 08                	jmp    801af8 <vprintfmt+0x278>
  801af0:	89 df                	mov    %ebx,%edi
  801af2:	8b 75 08             	mov    0x8(%ebp),%esi
  801af5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801af8:	85 ff                	test   %edi,%edi
  801afa:	7f e4                	jg     801ae0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801afc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801aff:	e9 a2 fd ff ff       	jmp    8018a6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801b04:	83 fa 01             	cmp    $0x1,%edx
  801b07:	7e 16                	jle    801b1f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801b09:	8b 45 14             	mov    0x14(%ebp),%eax
  801b0c:	8d 50 08             	lea    0x8(%eax),%edx
  801b0f:	89 55 14             	mov    %edx,0x14(%ebp)
  801b12:	8b 50 04             	mov    0x4(%eax),%edx
  801b15:	8b 00                	mov    (%eax),%eax
  801b17:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b1a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801b1d:	eb 32                	jmp    801b51 <vprintfmt+0x2d1>
	else if (lflag)
  801b1f:	85 d2                	test   %edx,%edx
  801b21:	74 18                	je     801b3b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801b23:	8b 45 14             	mov    0x14(%ebp),%eax
  801b26:	8d 50 04             	lea    0x4(%eax),%edx
  801b29:	89 55 14             	mov    %edx,0x14(%ebp)
  801b2c:	8b 00                	mov    (%eax),%eax
  801b2e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b31:	89 c1                	mov    %eax,%ecx
  801b33:	c1 f9 1f             	sar    $0x1f,%ecx
  801b36:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801b39:	eb 16                	jmp    801b51 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801b3b:	8b 45 14             	mov    0x14(%ebp),%eax
  801b3e:	8d 50 04             	lea    0x4(%eax),%edx
  801b41:	89 55 14             	mov    %edx,0x14(%ebp)
  801b44:	8b 00                	mov    (%eax),%eax
  801b46:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b49:	89 c1                	mov    %eax,%ecx
  801b4b:	c1 f9 1f             	sar    $0x1f,%ecx
  801b4e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b51:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b54:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801b57:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b5c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b60:	79 74                	jns    801bd6 <vprintfmt+0x356>
				putch('-', putdat);
  801b62:	83 ec 08             	sub    $0x8,%esp
  801b65:	53                   	push   %ebx
  801b66:	6a 2d                	push   $0x2d
  801b68:	ff d6                	call   *%esi
				num = -(long long) num;
  801b6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b6d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b70:	f7 d8                	neg    %eax
  801b72:	83 d2 00             	adc    $0x0,%edx
  801b75:	f7 da                	neg    %edx
  801b77:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b7a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b7f:	eb 55                	jmp    801bd6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b81:	8d 45 14             	lea    0x14(%ebp),%eax
  801b84:	e8 83 fc ff ff       	call   80180c <getuint>
			base = 10;
  801b89:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b8e:	eb 46                	jmp    801bd6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b90:	8d 45 14             	lea    0x14(%ebp),%eax
  801b93:	e8 74 fc ff ff       	call   80180c <getuint>
			base = 8;
  801b98:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b9d:	eb 37                	jmp    801bd6 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b9f:	83 ec 08             	sub    $0x8,%esp
  801ba2:	53                   	push   %ebx
  801ba3:	6a 30                	push   $0x30
  801ba5:	ff d6                	call   *%esi
			putch('x', putdat);
  801ba7:	83 c4 08             	add    $0x8,%esp
  801baa:	53                   	push   %ebx
  801bab:	6a 78                	push   $0x78
  801bad:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801baf:	8b 45 14             	mov    0x14(%ebp),%eax
  801bb2:	8d 50 04             	lea    0x4(%eax),%edx
  801bb5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801bb8:	8b 00                	mov    (%eax),%eax
  801bba:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801bbf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801bc2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801bc7:	eb 0d                	jmp    801bd6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801bc9:	8d 45 14             	lea    0x14(%ebp),%eax
  801bcc:	e8 3b fc ff ff       	call   80180c <getuint>
			base = 16;
  801bd1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801bd6:	83 ec 0c             	sub    $0xc,%esp
  801bd9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801bdd:	57                   	push   %edi
  801bde:	ff 75 e0             	pushl  -0x20(%ebp)
  801be1:	51                   	push   %ecx
  801be2:	52                   	push   %edx
  801be3:	50                   	push   %eax
  801be4:	89 da                	mov    %ebx,%edx
  801be6:	89 f0                	mov    %esi,%eax
  801be8:	e8 70 fb ff ff       	call   80175d <printnum>
			break;
  801bed:	83 c4 20             	add    $0x20,%esp
  801bf0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bf3:	e9 ae fc ff ff       	jmp    8018a6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801bf8:	83 ec 08             	sub    $0x8,%esp
  801bfb:	53                   	push   %ebx
  801bfc:	51                   	push   %ecx
  801bfd:	ff d6                	call   *%esi
			break;
  801bff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801c05:	e9 9c fc ff ff       	jmp    8018a6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801c0a:	83 ec 08             	sub    $0x8,%esp
  801c0d:	53                   	push   %ebx
  801c0e:	6a 25                	push   $0x25
  801c10:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	eb 03                	jmp    801c1a <vprintfmt+0x39a>
  801c17:	83 ef 01             	sub    $0x1,%edi
  801c1a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801c1e:	75 f7                	jne    801c17 <vprintfmt+0x397>
  801c20:	e9 81 fc ff ff       	jmp    8018a6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c28:	5b                   	pop    %ebx
  801c29:	5e                   	pop    %esi
  801c2a:	5f                   	pop    %edi
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    

00801c2d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
  801c30:	83 ec 18             	sub    $0x18,%esp
  801c33:	8b 45 08             	mov    0x8(%ebp),%eax
  801c36:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c3c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c40:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	74 26                	je     801c74 <vsnprintf+0x47>
  801c4e:	85 d2                	test   %edx,%edx
  801c50:	7e 22                	jle    801c74 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c52:	ff 75 14             	pushl  0x14(%ebp)
  801c55:	ff 75 10             	pushl  0x10(%ebp)
  801c58:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c5b:	50                   	push   %eax
  801c5c:	68 46 18 80 00       	push   $0x801846
  801c61:	e8 1a fc ff ff       	call   801880 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c66:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c69:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	eb 05                	jmp    801c79 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    

00801c7b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c81:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c84:	50                   	push   %eax
  801c85:	ff 75 10             	pushl  0x10(%ebp)
  801c88:	ff 75 0c             	pushl  0xc(%ebp)
  801c8b:	ff 75 08             	pushl  0x8(%ebp)
  801c8e:	e8 9a ff ff ff       	call   801c2d <vsnprintf>
	va_end(ap);

	return rc;
}
  801c93:	c9                   	leave  
  801c94:	c3                   	ret    

00801c95 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca0:	eb 03                	jmp    801ca5 <strlen+0x10>
		n++;
  801ca2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ca5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ca9:	75 f7                	jne    801ca2 <strlen+0xd>
		n++;
	return n;
}
  801cab:	5d                   	pop    %ebp
  801cac:	c3                   	ret    

00801cad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801cad:	55                   	push   %ebp
  801cae:	89 e5                	mov    %esp,%ebp
  801cb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbb:	eb 03                	jmp    801cc0 <strnlen+0x13>
		n++;
  801cbd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801cc0:	39 c2                	cmp    %eax,%edx
  801cc2:	74 08                	je     801ccc <strnlen+0x1f>
  801cc4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801cc8:	75 f3                	jne    801cbd <strnlen+0x10>
  801cca:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	53                   	push   %ebx
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801cd8:	89 c2                	mov    %eax,%edx
  801cda:	83 c2 01             	add    $0x1,%edx
  801cdd:	83 c1 01             	add    $0x1,%ecx
  801ce0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801ce4:	88 5a ff             	mov    %bl,-0x1(%edx)
  801ce7:	84 db                	test   %bl,%bl
  801ce9:	75 ef                	jne    801cda <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801ceb:	5b                   	pop    %ebx
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    

00801cee <strcat>:

char *
strcat(char *dst, const char *src)
{
  801cee:	55                   	push   %ebp
  801cef:	89 e5                	mov    %esp,%ebp
  801cf1:	53                   	push   %ebx
  801cf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801cf5:	53                   	push   %ebx
  801cf6:	e8 9a ff ff ff       	call   801c95 <strlen>
  801cfb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801cfe:	ff 75 0c             	pushl  0xc(%ebp)
  801d01:	01 d8                	add    %ebx,%eax
  801d03:	50                   	push   %eax
  801d04:	e8 c5 ff ff ff       	call   801cce <strcpy>
	return dst;
}
  801d09:	89 d8                	mov    %ebx,%eax
  801d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	56                   	push   %esi
  801d14:	53                   	push   %ebx
  801d15:	8b 75 08             	mov    0x8(%ebp),%esi
  801d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d1b:	89 f3                	mov    %esi,%ebx
  801d1d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d20:	89 f2                	mov    %esi,%edx
  801d22:	eb 0f                	jmp    801d33 <strncpy+0x23>
		*dst++ = *src;
  801d24:	83 c2 01             	add    $0x1,%edx
  801d27:	0f b6 01             	movzbl (%ecx),%eax
  801d2a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d2d:	80 39 01             	cmpb   $0x1,(%ecx)
  801d30:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d33:	39 da                	cmp    %ebx,%edx
  801d35:	75 ed                	jne    801d24 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d37:	89 f0                	mov    %esi,%eax
  801d39:	5b                   	pop    %ebx
  801d3a:	5e                   	pop    %esi
  801d3b:	5d                   	pop    %ebp
  801d3c:	c3                   	ret    

00801d3d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	56                   	push   %esi
  801d41:	53                   	push   %ebx
  801d42:	8b 75 08             	mov    0x8(%ebp),%esi
  801d45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d48:	8b 55 10             	mov    0x10(%ebp),%edx
  801d4b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d4d:	85 d2                	test   %edx,%edx
  801d4f:	74 21                	je     801d72 <strlcpy+0x35>
  801d51:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801d55:	89 f2                	mov    %esi,%edx
  801d57:	eb 09                	jmp    801d62 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d59:	83 c2 01             	add    $0x1,%edx
  801d5c:	83 c1 01             	add    $0x1,%ecx
  801d5f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801d62:	39 c2                	cmp    %eax,%edx
  801d64:	74 09                	je     801d6f <strlcpy+0x32>
  801d66:	0f b6 19             	movzbl (%ecx),%ebx
  801d69:	84 db                	test   %bl,%bl
  801d6b:	75 ec                	jne    801d59 <strlcpy+0x1c>
  801d6d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d6f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d72:	29 f0                	sub    %esi,%eax
}
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    

00801d78 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d7e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d81:	eb 06                	jmp    801d89 <strcmp+0x11>
		p++, q++;
  801d83:	83 c1 01             	add    $0x1,%ecx
  801d86:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d89:	0f b6 01             	movzbl (%ecx),%eax
  801d8c:	84 c0                	test   %al,%al
  801d8e:	74 04                	je     801d94 <strcmp+0x1c>
  801d90:	3a 02                	cmp    (%edx),%al
  801d92:	74 ef                	je     801d83 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d94:	0f b6 c0             	movzbl %al,%eax
  801d97:	0f b6 12             	movzbl (%edx),%edx
  801d9a:	29 d0                	sub    %edx,%eax
}
  801d9c:	5d                   	pop    %ebp
  801d9d:	c3                   	ret    

00801d9e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	53                   	push   %ebx
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da8:	89 c3                	mov    %eax,%ebx
  801daa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801dad:	eb 06                	jmp    801db5 <strncmp+0x17>
		n--, p++, q++;
  801daf:	83 c0 01             	add    $0x1,%eax
  801db2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801db5:	39 d8                	cmp    %ebx,%eax
  801db7:	74 15                	je     801dce <strncmp+0x30>
  801db9:	0f b6 08             	movzbl (%eax),%ecx
  801dbc:	84 c9                	test   %cl,%cl
  801dbe:	74 04                	je     801dc4 <strncmp+0x26>
  801dc0:	3a 0a                	cmp    (%edx),%cl
  801dc2:	74 eb                	je     801daf <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801dc4:	0f b6 00             	movzbl (%eax),%eax
  801dc7:	0f b6 12             	movzbl (%edx),%edx
  801dca:	29 d0                	sub    %edx,%eax
  801dcc:	eb 05                	jmp    801dd3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801dce:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801dd3:	5b                   	pop    %ebx
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    

00801dd6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801de0:	eb 07                	jmp    801de9 <strchr+0x13>
		if (*s == c)
  801de2:	38 ca                	cmp    %cl,%dl
  801de4:	74 0f                	je     801df5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801de6:	83 c0 01             	add    $0x1,%eax
  801de9:	0f b6 10             	movzbl (%eax),%edx
  801dec:	84 d2                	test   %dl,%dl
  801dee:	75 f2                	jne    801de2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801df0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df5:	5d                   	pop    %ebp
  801df6:	c3                   	ret    

00801df7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801e01:	eb 03                	jmp    801e06 <strfind+0xf>
  801e03:	83 c0 01             	add    $0x1,%eax
  801e06:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801e09:	38 ca                	cmp    %cl,%dl
  801e0b:	74 04                	je     801e11 <strfind+0x1a>
  801e0d:	84 d2                	test   %dl,%dl
  801e0f:	75 f2                	jne    801e03 <strfind+0xc>
			break;
	return (char *) s;
}
  801e11:	5d                   	pop    %ebp
  801e12:	c3                   	ret    

00801e13 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801e13:	55                   	push   %ebp
  801e14:	89 e5                	mov    %esp,%ebp
  801e16:	57                   	push   %edi
  801e17:	56                   	push   %esi
  801e18:	53                   	push   %ebx
  801e19:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801e1f:	85 c9                	test   %ecx,%ecx
  801e21:	74 36                	je     801e59 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801e23:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801e29:	75 28                	jne    801e53 <memset+0x40>
  801e2b:	f6 c1 03             	test   $0x3,%cl
  801e2e:	75 23                	jne    801e53 <memset+0x40>
		c &= 0xFF;
  801e30:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e34:	89 d3                	mov    %edx,%ebx
  801e36:	c1 e3 08             	shl    $0x8,%ebx
  801e39:	89 d6                	mov    %edx,%esi
  801e3b:	c1 e6 18             	shl    $0x18,%esi
  801e3e:	89 d0                	mov    %edx,%eax
  801e40:	c1 e0 10             	shl    $0x10,%eax
  801e43:	09 f0                	or     %esi,%eax
  801e45:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801e47:	89 d8                	mov    %ebx,%eax
  801e49:	09 d0                	or     %edx,%eax
  801e4b:	c1 e9 02             	shr    $0x2,%ecx
  801e4e:	fc                   	cld    
  801e4f:	f3 ab                	rep stos %eax,%es:(%edi)
  801e51:	eb 06                	jmp    801e59 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e56:	fc                   	cld    
  801e57:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e59:	89 f8                	mov    %edi,%eax
  801e5b:	5b                   	pop    %ebx
  801e5c:	5e                   	pop    %esi
  801e5d:	5f                   	pop    %edi
  801e5e:	5d                   	pop    %ebp
  801e5f:	c3                   	ret    

00801e60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	57                   	push   %edi
  801e64:	56                   	push   %esi
  801e65:	8b 45 08             	mov    0x8(%ebp),%eax
  801e68:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e6e:	39 c6                	cmp    %eax,%esi
  801e70:	73 35                	jae    801ea7 <memmove+0x47>
  801e72:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e75:	39 d0                	cmp    %edx,%eax
  801e77:	73 2e                	jae    801ea7 <memmove+0x47>
		s += n;
		d += n;
  801e79:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e7c:	89 d6                	mov    %edx,%esi
  801e7e:	09 fe                	or     %edi,%esi
  801e80:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e86:	75 13                	jne    801e9b <memmove+0x3b>
  801e88:	f6 c1 03             	test   $0x3,%cl
  801e8b:	75 0e                	jne    801e9b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e8d:	83 ef 04             	sub    $0x4,%edi
  801e90:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e93:	c1 e9 02             	shr    $0x2,%ecx
  801e96:	fd                   	std    
  801e97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e99:	eb 09                	jmp    801ea4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e9b:	83 ef 01             	sub    $0x1,%edi
  801e9e:	8d 72 ff             	lea    -0x1(%edx),%esi
  801ea1:	fd                   	std    
  801ea2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ea4:	fc                   	cld    
  801ea5:	eb 1d                	jmp    801ec4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ea7:	89 f2                	mov    %esi,%edx
  801ea9:	09 c2                	or     %eax,%edx
  801eab:	f6 c2 03             	test   $0x3,%dl
  801eae:	75 0f                	jne    801ebf <memmove+0x5f>
  801eb0:	f6 c1 03             	test   $0x3,%cl
  801eb3:	75 0a                	jne    801ebf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801eb5:	c1 e9 02             	shr    $0x2,%ecx
  801eb8:	89 c7                	mov    %eax,%edi
  801eba:	fc                   	cld    
  801ebb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801ebd:	eb 05                	jmp    801ec4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801ebf:	89 c7                	mov    %eax,%edi
  801ec1:	fc                   	cld    
  801ec2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801ec4:	5e                   	pop    %esi
  801ec5:	5f                   	pop    %edi
  801ec6:	5d                   	pop    %ebp
  801ec7:	c3                   	ret    

00801ec8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801ec8:	55                   	push   %ebp
  801ec9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801ecb:	ff 75 10             	pushl  0x10(%ebp)
  801ece:	ff 75 0c             	pushl  0xc(%ebp)
  801ed1:	ff 75 08             	pushl  0x8(%ebp)
  801ed4:	e8 87 ff ff ff       	call   801e60 <memmove>
}
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    

00801edb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	56                   	push   %esi
  801edf:	53                   	push   %ebx
  801ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ee6:	89 c6                	mov    %eax,%esi
  801ee8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801eeb:	eb 1a                	jmp    801f07 <memcmp+0x2c>
		if (*s1 != *s2)
  801eed:	0f b6 08             	movzbl (%eax),%ecx
  801ef0:	0f b6 1a             	movzbl (%edx),%ebx
  801ef3:	38 d9                	cmp    %bl,%cl
  801ef5:	74 0a                	je     801f01 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ef7:	0f b6 c1             	movzbl %cl,%eax
  801efa:	0f b6 db             	movzbl %bl,%ebx
  801efd:	29 d8                	sub    %ebx,%eax
  801eff:	eb 0f                	jmp    801f10 <memcmp+0x35>
		s1++, s2++;
  801f01:	83 c0 01             	add    $0x1,%eax
  801f04:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801f07:	39 f0                	cmp    %esi,%eax
  801f09:	75 e2                	jne    801eed <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801f0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f10:	5b                   	pop    %ebx
  801f11:	5e                   	pop    %esi
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    

00801f14 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	53                   	push   %ebx
  801f18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801f1b:	89 c1                	mov    %eax,%ecx
  801f1d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801f20:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f24:	eb 0a                	jmp    801f30 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801f26:	0f b6 10             	movzbl (%eax),%edx
  801f29:	39 da                	cmp    %ebx,%edx
  801f2b:	74 07                	je     801f34 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f2d:	83 c0 01             	add    $0x1,%eax
  801f30:	39 c8                	cmp    %ecx,%eax
  801f32:	72 f2                	jb     801f26 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801f34:	5b                   	pop    %ebx
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    

00801f37 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801f37:	55                   	push   %ebp
  801f38:	89 e5                	mov    %esp,%ebp
  801f3a:	57                   	push   %edi
  801f3b:	56                   	push   %esi
  801f3c:	53                   	push   %ebx
  801f3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f40:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f43:	eb 03                	jmp    801f48 <strtol+0x11>
		s++;
  801f45:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f48:	0f b6 01             	movzbl (%ecx),%eax
  801f4b:	3c 20                	cmp    $0x20,%al
  801f4d:	74 f6                	je     801f45 <strtol+0xe>
  801f4f:	3c 09                	cmp    $0x9,%al
  801f51:	74 f2                	je     801f45 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801f53:	3c 2b                	cmp    $0x2b,%al
  801f55:	75 0a                	jne    801f61 <strtol+0x2a>
		s++;
  801f57:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f5a:	bf 00 00 00 00       	mov    $0x0,%edi
  801f5f:	eb 11                	jmp    801f72 <strtol+0x3b>
  801f61:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801f66:	3c 2d                	cmp    $0x2d,%al
  801f68:	75 08                	jne    801f72 <strtol+0x3b>
		s++, neg = 1;
  801f6a:	83 c1 01             	add    $0x1,%ecx
  801f6d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f78:	75 15                	jne    801f8f <strtol+0x58>
  801f7a:	80 39 30             	cmpb   $0x30,(%ecx)
  801f7d:	75 10                	jne    801f8f <strtol+0x58>
  801f7f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f83:	75 7c                	jne    802001 <strtol+0xca>
		s += 2, base = 16;
  801f85:	83 c1 02             	add    $0x2,%ecx
  801f88:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f8d:	eb 16                	jmp    801fa5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f8f:	85 db                	test   %ebx,%ebx
  801f91:	75 12                	jne    801fa5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f93:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f98:	80 39 30             	cmpb   $0x30,(%ecx)
  801f9b:	75 08                	jne    801fa5 <strtol+0x6e>
		s++, base = 8;
  801f9d:	83 c1 01             	add    $0x1,%ecx
  801fa0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801fa5:	b8 00 00 00 00       	mov    $0x0,%eax
  801faa:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801fad:	0f b6 11             	movzbl (%ecx),%edx
  801fb0:	8d 72 d0             	lea    -0x30(%edx),%esi
  801fb3:	89 f3                	mov    %esi,%ebx
  801fb5:	80 fb 09             	cmp    $0x9,%bl
  801fb8:	77 08                	ja     801fc2 <strtol+0x8b>
			dig = *s - '0';
  801fba:	0f be d2             	movsbl %dl,%edx
  801fbd:	83 ea 30             	sub    $0x30,%edx
  801fc0:	eb 22                	jmp    801fe4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801fc2:	8d 72 9f             	lea    -0x61(%edx),%esi
  801fc5:	89 f3                	mov    %esi,%ebx
  801fc7:	80 fb 19             	cmp    $0x19,%bl
  801fca:	77 08                	ja     801fd4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801fcc:	0f be d2             	movsbl %dl,%edx
  801fcf:	83 ea 57             	sub    $0x57,%edx
  801fd2:	eb 10                	jmp    801fe4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801fd4:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fd7:	89 f3                	mov    %esi,%ebx
  801fd9:	80 fb 19             	cmp    $0x19,%bl
  801fdc:	77 16                	ja     801ff4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801fde:	0f be d2             	movsbl %dl,%edx
  801fe1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801fe4:	3b 55 10             	cmp    0x10(%ebp),%edx
  801fe7:	7d 0b                	jge    801ff4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801fe9:	83 c1 01             	add    $0x1,%ecx
  801fec:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ff0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ff2:	eb b9                	jmp    801fad <strtol+0x76>

	if (endptr)
  801ff4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ff8:	74 0d                	je     802007 <strtol+0xd0>
		*endptr = (char *) s;
  801ffa:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ffd:	89 0e                	mov    %ecx,(%esi)
  801fff:	eb 06                	jmp    802007 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802001:	85 db                	test   %ebx,%ebx
  802003:	74 98                	je     801f9d <strtol+0x66>
  802005:	eb 9e                	jmp    801fa5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802007:	89 c2                	mov    %eax,%edx
  802009:	f7 da                	neg    %edx
  80200b:	85 ff                	test   %edi,%edi
  80200d:	0f 45 c2             	cmovne %edx,%eax
}
  802010:	5b                   	pop    %ebx
  802011:	5e                   	pop    %esi
  802012:	5f                   	pop    %edi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    

00802015 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80201b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802022:	75 2a                	jne    80204e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802024:	83 ec 04             	sub    $0x4,%esp
  802027:	6a 07                	push   $0x7
  802029:	68 00 f0 bf ee       	push   $0xeebff000
  80202e:	6a 00                	push   $0x0
  802030:	e8 6f e1 ff ff       	call   8001a4 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802035:	83 c4 10             	add    $0x10,%esp
  802038:	85 c0                	test   %eax,%eax
  80203a:	79 12                	jns    80204e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80203c:	50                   	push   %eax
  80203d:	68 a3 25 80 00       	push   $0x8025a3
  802042:	6a 23                	push   $0x23
  802044:	68 40 2a 80 00       	push   $0x802a40
  802049:	e8 22 f6 ff ff       	call   801670 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80204e:	8b 45 08             	mov    0x8(%ebp),%eax
  802051:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802056:	83 ec 08             	sub    $0x8,%esp
  802059:	68 80 20 80 00       	push   $0x802080
  80205e:	6a 00                	push   $0x0
  802060:	e8 8a e2 ff ff       	call   8002ef <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802065:	83 c4 10             	add    $0x10,%esp
  802068:	85 c0                	test   %eax,%eax
  80206a:	79 12                	jns    80207e <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80206c:	50                   	push   %eax
  80206d:	68 a3 25 80 00       	push   $0x8025a3
  802072:	6a 2c                	push   $0x2c
  802074:	68 40 2a 80 00       	push   $0x802a40
  802079:	e8 f2 f5 ff ff       	call   801670 <_panic>
	}
}
  80207e:	c9                   	leave  
  80207f:	c3                   	ret    

00802080 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802080:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802081:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802086:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802088:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80208b:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  80208f:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802094:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  802098:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80209a:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  80209d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  80209e:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8020a1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8020a2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8020a3:	c3                   	ret    

008020a4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	56                   	push   %esi
  8020a8:	53                   	push   %ebx
  8020a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8020ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020b2:	85 c0                	test   %eax,%eax
  8020b4:	75 12                	jne    8020c8 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020b6:	83 ec 0c             	sub    $0xc,%esp
  8020b9:	68 00 00 c0 ee       	push   $0xeec00000
  8020be:	e8 91 e2 ff ff       	call   800354 <sys_ipc_recv>
  8020c3:	83 c4 10             	add    $0x10,%esp
  8020c6:	eb 0c                	jmp    8020d4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020c8:	83 ec 0c             	sub    $0xc,%esp
  8020cb:	50                   	push   %eax
  8020cc:	e8 83 e2 ff ff       	call   800354 <sys_ipc_recv>
  8020d1:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020d4:	85 f6                	test   %esi,%esi
  8020d6:	0f 95 c1             	setne  %cl
  8020d9:	85 db                	test   %ebx,%ebx
  8020db:	0f 95 c2             	setne  %dl
  8020de:	84 d1                	test   %dl,%cl
  8020e0:	74 09                	je     8020eb <ipc_recv+0x47>
  8020e2:	89 c2                	mov    %eax,%edx
  8020e4:	c1 ea 1f             	shr    $0x1f,%edx
  8020e7:	84 d2                	test   %dl,%dl
  8020e9:	75 2d                	jne    802118 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020eb:	85 f6                	test   %esi,%esi
  8020ed:	74 0d                	je     8020fc <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f4:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020fa:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020fc:	85 db                	test   %ebx,%ebx
  8020fe:	74 0d                	je     80210d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802100:	a1 04 40 80 00       	mov    0x804004,%eax
  802105:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  80210b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80210d:	a1 04 40 80 00       	mov    0x804004,%eax
  802112:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802118:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80211b:	5b                   	pop    %ebx
  80211c:	5e                   	pop    %esi
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    

0080211f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	57                   	push   %edi
  802123:	56                   	push   %esi
  802124:	53                   	push   %ebx
  802125:	83 ec 0c             	sub    $0xc,%esp
  802128:	8b 7d 08             	mov    0x8(%ebp),%edi
  80212b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80212e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802131:	85 db                	test   %ebx,%ebx
  802133:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802138:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80213b:	ff 75 14             	pushl  0x14(%ebp)
  80213e:	53                   	push   %ebx
  80213f:	56                   	push   %esi
  802140:	57                   	push   %edi
  802141:	e8 eb e1 ff ff       	call   800331 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802146:	89 c2                	mov    %eax,%edx
  802148:	c1 ea 1f             	shr    $0x1f,%edx
  80214b:	83 c4 10             	add    $0x10,%esp
  80214e:	84 d2                	test   %dl,%dl
  802150:	74 17                	je     802169 <ipc_send+0x4a>
  802152:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802155:	74 12                	je     802169 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802157:	50                   	push   %eax
  802158:	68 4e 2a 80 00       	push   $0x802a4e
  80215d:	6a 47                	push   $0x47
  80215f:	68 5c 2a 80 00       	push   $0x802a5c
  802164:	e8 07 f5 ff ff       	call   801670 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802169:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80216c:	75 07                	jne    802175 <ipc_send+0x56>
			sys_yield();
  80216e:	e8 12 e0 ff ff       	call   800185 <sys_yield>
  802173:	eb c6                	jmp    80213b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802175:	85 c0                	test   %eax,%eax
  802177:	75 c2                	jne    80213b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80217c:	5b                   	pop    %ebx
  80217d:	5e                   	pop    %esi
  80217e:	5f                   	pop    %edi
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    

00802181 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802181:	55                   	push   %ebp
  802182:	89 e5                	mov    %esp,%ebp
  802184:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802187:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80218c:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802192:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802198:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  80219e:	39 ca                	cmp    %ecx,%edx
  8021a0:	75 13                	jne    8021b5 <ipc_find_env+0x34>
			return envs[i].env_id;
  8021a2:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  8021a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8021ad:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8021b3:	eb 0f                	jmp    8021c4 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021b5:	83 c0 01             	add    $0x1,%eax
  8021b8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021bd:	75 cd                	jne    80218c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021c4:	5d                   	pop    %ebp
  8021c5:	c3                   	ret    

008021c6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021c6:	55                   	push   %ebp
  8021c7:	89 e5                	mov    %esp,%ebp
  8021c9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021cc:	89 d0                	mov    %edx,%eax
  8021ce:	c1 e8 16             	shr    $0x16,%eax
  8021d1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021d8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021dd:	f6 c1 01             	test   $0x1,%cl
  8021e0:	74 1d                	je     8021ff <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021e2:	c1 ea 0c             	shr    $0xc,%edx
  8021e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021ec:	f6 c2 01             	test   $0x1,%dl
  8021ef:	74 0e                	je     8021ff <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021f1:	c1 ea 0c             	shr    $0xc,%edx
  8021f4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021fb:	ef 
  8021fc:	0f b7 c0             	movzwl %ax,%eax
}
  8021ff:	5d                   	pop    %ebp
  802200:	c3                   	ret    
  802201:	66 90                	xchg   %ax,%ax
  802203:	66 90                	xchg   %ax,%ax
  802205:	66 90                	xchg   %ax,%ax
  802207:	66 90                	xchg   %ax,%ax
  802209:	66 90                	xchg   %ax,%ax
  80220b:	66 90                	xchg   %ax,%ax
  80220d:	66 90                	xchg   %ax,%ax
  80220f:	90                   	nop

00802210 <__udivdi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80221b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80221f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 f6                	test   %esi,%esi
  802229:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80222d:	89 ca                	mov    %ecx,%edx
  80222f:	89 f8                	mov    %edi,%eax
  802231:	75 3d                	jne    802270 <__udivdi3+0x60>
  802233:	39 cf                	cmp    %ecx,%edi
  802235:	0f 87 c5 00 00 00    	ja     802300 <__udivdi3+0xf0>
  80223b:	85 ff                	test   %edi,%edi
  80223d:	89 fd                	mov    %edi,%ebp
  80223f:	75 0b                	jne    80224c <__udivdi3+0x3c>
  802241:	b8 01 00 00 00       	mov    $0x1,%eax
  802246:	31 d2                	xor    %edx,%edx
  802248:	f7 f7                	div    %edi
  80224a:	89 c5                	mov    %eax,%ebp
  80224c:	89 c8                	mov    %ecx,%eax
  80224e:	31 d2                	xor    %edx,%edx
  802250:	f7 f5                	div    %ebp
  802252:	89 c1                	mov    %eax,%ecx
  802254:	89 d8                	mov    %ebx,%eax
  802256:	89 cf                	mov    %ecx,%edi
  802258:	f7 f5                	div    %ebp
  80225a:	89 c3                	mov    %eax,%ebx
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
  802270:	39 ce                	cmp    %ecx,%esi
  802272:	77 74                	ja     8022e8 <__udivdi3+0xd8>
  802274:	0f bd fe             	bsr    %esi,%edi
  802277:	83 f7 1f             	xor    $0x1f,%edi
  80227a:	0f 84 98 00 00 00    	je     802318 <__udivdi3+0x108>
  802280:	bb 20 00 00 00       	mov    $0x20,%ebx
  802285:	89 f9                	mov    %edi,%ecx
  802287:	89 c5                	mov    %eax,%ebp
  802289:	29 fb                	sub    %edi,%ebx
  80228b:	d3 e6                	shl    %cl,%esi
  80228d:	89 d9                	mov    %ebx,%ecx
  80228f:	d3 ed                	shr    %cl,%ebp
  802291:	89 f9                	mov    %edi,%ecx
  802293:	d3 e0                	shl    %cl,%eax
  802295:	09 ee                	or     %ebp,%esi
  802297:	89 d9                	mov    %ebx,%ecx
  802299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80229d:	89 d5                	mov    %edx,%ebp
  80229f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022a3:	d3 ed                	shr    %cl,%ebp
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	d3 e2                	shl    %cl,%edx
  8022a9:	89 d9                	mov    %ebx,%ecx
  8022ab:	d3 e8                	shr    %cl,%eax
  8022ad:	09 c2                	or     %eax,%edx
  8022af:	89 d0                	mov    %edx,%eax
  8022b1:	89 ea                	mov    %ebp,%edx
  8022b3:	f7 f6                	div    %esi
  8022b5:	89 d5                	mov    %edx,%ebp
  8022b7:	89 c3                	mov    %eax,%ebx
  8022b9:	f7 64 24 0c          	mull   0xc(%esp)
  8022bd:	39 d5                	cmp    %edx,%ebp
  8022bf:	72 10                	jb     8022d1 <__udivdi3+0xc1>
  8022c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022c5:	89 f9                	mov    %edi,%ecx
  8022c7:	d3 e6                	shl    %cl,%esi
  8022c9:	39 c6                	cmp    %eax,%esi
  8022cb:	73 07                	jae    8022d4 <__udivdi3+0xc4>
  8022cd:	39 d5                	cmp    %edx,%ebp
  8022cf:	75 03                	jne    8022d4 <__udivdi3+0xc4>
  8022d1:	83 eb 01             	sub    $0x1,%ebx
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 d8                	mov    %ebx,%eax
  8022d8:	89 fa                	mov    %edi,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	31 ff                	xor    %edi,%edi
  8022ea:	31 db                	xor    %ebx,%ebx
  8022ec:	89 d8                	mov    %ebx,%eax
  8022ee:	89 fa                	mov    %edi,%edx
  8022f0:	83 c4 1c             	add    $0x1c,%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
  8022f8:	90                   	nop
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	89 d8                	mov    %ebx,%eax
  802302:	f7 f7                	div    %edi
  802304:	31 ff                	xor    %edi,%edi
  802306:	89 c3                	mov    %eax,%ebx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 fa                	mov    %edi,%edx
  80230c:	83 c4 1c             	add    $0x1c,%esp
  80230f:	5b                   	pop    %ebx
  802310:	5e                   	pop    %esi
  802311:	5f                   	pop    %edi
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    
  802314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802318:	39 ce                	cmp    %ecx,%esi
  80231a:	72 0c                	jb     802328 <__udivdi3+0x118>
  80231c:	31 db                	xor    %ebx,%ebx
  80231e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802322:	0f 87 34 ff ff ff    	ja     80225c <__udivdi3+0x4c>
  802328:	bb 01 00 00 00       	mov    $0x1,%ebx
  80232d:	e9 2a ff ff ff       	jmp    80225c <__udivdi3+0x4c>
  802332:	66 90                	xchg   %ax,%ax
  802334:	66 90                	xchg   %ax,%ax
  802336:	66 90                	xchg   %ax,%ax
  802338:	66 90                	xchg   %ax,%ax
  80233a:	66 90                	xchg   %ax,%ax
  80233c:	66 90                	xchg   %ax,%ax
  80233e:	66 90                	xchg   %ax,%ax

00802340 <__umoddi3>:
  802340:	55                   	push   %ebp
  802341:	57                   	push   %edi
  802342:	56                   	push   %esi
  802343:	53                   	push   %ebx
  802344:	83 ec 1c             	sub    $0x1c,%esp
  802347:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80234b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80234f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802353:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802357:	85 d2                	test   %edx,%edx
  802359:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80235d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802361:	89 f3                	mov    %esi,%ebx
  802363:	89 3c 24             	mov    %edi,(%esp)
  802366:	89 74 24 04          	mov    %esi,0x4(%esp)
  80236a:	75 1c                	jne    802388 <__umoddi3+0x48>
  80236c:	39 f7                	cmp    %esi,%edi
  80236e:	76 50                	jbe    8023c0 <__umoddi3+0x80>
  802370:	89 c8                	mov    %ecx,%eax
  802372:	89 f2                	mov    %esi,%edx
  802374:	f7 f7                	div    %edi
  802376:	89 d0                	mov    %edx,%eax
  802378:	31 d2                	xor    %edx,%edx
  80237a:	83 c4 1c             	add    $0x1c,%esp
  80237d:	5b                   	pop    %ebx
  80237e:	5e                   	pop    %esi
  80237f:	5f                   	pop    %edi
  802380:	5d                   	pop    %ebp
  802381:	c3                   	ret    
  802382:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802388:	39 f2                	cmp    %esi,%edx
  80238a:	89 d0                	mov    %edx,%eax
  80238c:	77 52                	ja     8023e0 <__umoddi3+0xa0>
  80238e:	0f bd ea             	bsr    %edx,%ebp
  802391:	83 f5 1f             	xor    $0x1f,%ebp
  802394:	75 5a                	jne    8023f0 <__umoddi3+0xb0>
  802396:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80239a:	0f 82 e0 00 00 00    	jb     802480 <__umoddi3+0x140>
  8023a0:	39 0c 24             	cmp    %ecx,(%esp)
  8023a3:	0f 86 d7 00 00 00    	jbe    802480 <__umoddi3+0x140>
  8023a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8023ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023b1:	83 c4 1c             	add    $0x1c,%esp
  8023b4:	5b                   	pop    %ebx
  8023b5:	5e                   	pop    %esi
  8023b6:	5f                   	pop    %edi
  8023b7:	5d                   	pop    %ebp
  8023b8:	c3                   	ret    
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	85 ff                	test   %edi,%edi
  8023c2:	89 fd                	mov    %edi,%ebp
  8023c4:	75 0b                	jne    8023d1 <__umoddi3+0x91>
  8023c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023cb:	31 d2                	xor    %edx,%edx
  8023cd:	f7 f7                	div    %edi
  8023cf:	89 c5                	mov    %eax,%ebp
  8023d1:	89 f0                	mov    %esi,%eax
  8023d3:	31 d2                	xor    %edx,%edx
  8023d5:	f7 f5                	div    %ebp
  8023d7:	89 c8                	mov    %ecx,%eax
  8023d9:	f7 f5                	div    %ebp
  8023db:	89 d0                	mov    %edx,%eax
  8023dd:	eb 99                	jmp    802378 <__umoddi3+0x38>
  8023df:	90                   	nop
  8023e0:	89 c8                	mov    %ecx,%eax
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	83 c4 1c             	add    $0x1c,%esp
  8023e7:	5b                   	pop    %ebx
  8023e8:	5e                   	pop    %esi
  8023e9:	5f                   	pop    %edi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    
  8023ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	8b 34 24             	mov    (%esp),%esi
  8023f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023f8:	89 e9                	mov    %ebp,%ecx
  8023fa:	29 ef                	sub    %ebp,%edi
  8023fc:	d3 e0                	shl    %cl,%eax
  8023fe:	89 f9                	mov    %edi,%ecx
  802400:	89 f2                	mov    %esi,%edx
  802402:	d3 ea                	shr    %cl,%edx
  802404:	89 e9                	mov    %ebp,%ecx
  802406:	09 c2                	or     %eax,%edx
  802408:	89 d8                	mov    %ebx,%eax
  80240a:	89 14 24             	mov    %edx,(%esp)
  80240d:	89 f2                	mov    %esi,%edx
  80240f:	d3 e2                	shl    %cl,%edx
  802411:	89 f9                	mov    %edi,%ecx
  802413:	89 54 24 04          	mov    %edx,0x4(%esp)
  802417:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	89 e9                	mov    %ebp,%ecx
  80241f:	89 c6                	mov    %eax,%esi
  802421:	d3 e3                	shl    %cl,%ebx
  802423:	89 f9                	mov    %edi,%ecx
  802425:	89 d0                	mov    %edx,%eax
  802427:	d3 e8                	shr    %cl,%eax
  802429:	89 e9                	mov    %ebp,%ecx
  80242b:	09 d8                	or     %ebx,%eax
  80242d:	89 d3                	mov    %edx,%ebx
  80242f:	89 f2                	mov    %esi,%edx
  802431:	f7 34 24             	divl   (%esp)
  802434:	89 d6                	mov    %edx,%esi
  802436:	d3 e3                	shl    %cl,%ebx
  802438:	f7 64 24 04          	mull   0x4(%esp)
  80243c:	39 d6                	cmp    %edx,%esi
  80243e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802442:	89 d1                	mov    %edx,%ecx
  802444:	89 c3                	mov    %eax,%ebx
  802446:	72 08                	jb     802450 <__umoddi3+0x110>
  802448:	75 11                	jne    80245b <__umoddi3+0x11b>
  80244a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80244e:	73 0b                	jae    80245b <__umoddi3+0x11b>
  802450:	2b 44 24 04          	sub    0x4(%esp),%eax
  802454:	1b 14 24             	sbb    (%esp),%edx
  802457:	89 d1                	mov    %edx,%ecx
  802459:	89 c3                	mov    %eax,%ebx
  80245b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80245f:	29 da                	sub    %ebx,%edx
  802461:	19 ce                	sbb    %ecx,%esi
  802463:	89 f9                	mov    %edi,%ecx
  802465:	89 f0                	mov    %esi,%eax
  802467:	d3 e0                	shl    %cl,%eax
  802469:	89 e9                	mov    %ebp,%ecx
  80246b:	d3 ea                	shr    %cl,%edx
  80246d:	89 e9                	mov    %ebp,%ecx
  80246f:	d3 ee                	shr    %cl,%esi
  802471:	09 d0                	or     %edx,%eax
  802473:	89 f2                	mov    %esi,%edx
  802475:	83 c4 1c             	add    $0x1c,%esp
  802478:	5b                   	pop    %ebx
  802479:	5e                   	pop    %esi
  80247a:	5f                   	pop    %edi
  80247b:	5d                   	pop    %ebp
  80247c:	c3                   	ret    
  80247d:	8d 76 00             	lea    0x0(%esi),%esi
  802480:	29 f9                	sub    %edi,%ecx
  802482:	19 d6                	sbb    %edx,%esi
  802484:	89 74 24 04          	mov    %esi,0x4(%esp)
  802488:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80248c:	e9 18 ff ff ff       	jmp    8023a9 <__umoddi3+0x69>
