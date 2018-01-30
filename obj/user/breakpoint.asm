
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 f1 00 00 00       	call   80013a <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 db                	test   %ebx,%ebx
  800060:	7e 07                	jle    800069 <libmain+0x30>
		binaryname = argv[0];
  800062:	8b 06                	mov    (%esi),%eax
  800064:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	56                   	push   %esi
  80006d:	53                   	push   %ebx
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 2a 00 00 00       	call   8000a2 <exit>
}
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007e:	5b                   	pop    %ebx
  80007f:	5e                   	pop    %esi
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <thread_main>:

/*Lab 7: Multithreading thread main routine*/
/*hlavna obsluha threadu - zavola sa funkcia, nasledne sa dany thread znici*/
void 
thread_main()
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 08             	sub    $0x8,%esp
	void (*func)(void) = (void (*)(void))eip;
  800088:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  80008d:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  80008f:	e8 a6 00 00 00       	call   80013a <sys_getenvid>
  800094:	83 ec 0c             	sub    $0xc,%esp
  800097:	50                   	push   %eax
  800098:	e8 ec 02 00 00       	call   800389 <sys_thread_free>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a8:	e8 e8 09 00 00       	call   800a95 <close_all>
	sys_env_destroy(0);
  8000ad:	83 ec 0c             	sub    $0xc,%esp
  8000b0:	6a 00                	push   $0x0
  8000b2:	e8 42 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ea:	89 d1                	mov    %edx,%ecx
  8000ec:	89 d3                	mov    %edx,%ebx
  8000ee:	89 d7                	mov    %edx,%edi
  8000f0:	89 d6                	mov    %edx,%esi
  8000f2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800102:	b9 00 00 00 00       	mov    $0x0,%ecx
  800107:	b8 03 00 00 00       	mov    $0x3,%eax
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	89 cb                	mov    %ecx,%ebx
  800111:	89 cf                	mov    %ecx,%edi
  800113:	89 ce                	mov    %ecx,%esi
  800115:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800117:	85 c0                	test   %eax,%eax
  800119:	7e 17                	jle    800132 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	50                   	push   %eax
  80011f:	6a 03                	push   $0x3
  800121:	68 0a 24 80 00       	push   $0x80240a
  800126:	6a 23                	push   $0x23
  800128:	68 27 24 80 00       	push   $0x802427
  80012d:	e8 94 14 00 00       	call   8015c6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800132:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	57                   	push   %edi
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800140:	ba 00 00 00 00       	mov    $0x0,%edx
  800145:	b8 02 00 00 00       	mov    $0x2,%eax
  80014a:	89 d1                	mov    %edx,%ecx
  80014c:	89 d3                	mov    %edx,%ebx
  80014e:	89 d7                	mov    %edx,%edi
  800150:	89 d6                	mov    %edx,%esi
  800152:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5f                   	pop    %edi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <sys_yield>:

void
sys_yield(void)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	b8 0b 00 00 00       	mov    $0xb,%eax
  800169:	89 d1                	mov    %edx,%ecx
  80016b:	89 d3                	mov    %edx,%ebx
  80016d:	89 d7                	mov    %edx,%edi
  80016f:	89 d6                	mov    %edx,%esi
  800171:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800173:	5b                   	pop    %ebx
  800174:	5e                   	pop    %esi
  800175:	5f                   	pop    %edi
  800176:	5d                   	pop    %ebp
  800177:	c3                   	ret    

00800178 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800181:	be 00 00 00 00       	mov    $0x0,%esi
  800186:	b8 04 00 00 00       	mov    $0x4,%eax
  80018b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018e:	8b 55 08             	mov    0x8(%ebp),%edx
  800191:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800194:	89 f7                	mov    %esi,%edi
  800196:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	7e 17                	jle    8001b3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	50                   	push   %eax
  8001a0:	6a 04                	push   $0x4
  8001a2:	68 0a 24 80 00       	push   $0x80240a
  8001a7:	6a 23                	push   $0x23
  8001a9:	68 27 24 80 00       	push   $0x802427
  8001ae:	e8 13 14 00 00       	call   8015c6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b6:	5b                   	pop    %ebx
  8001b7:	5e                   	pop    %esi
  8001b8:	5f                   	pop    %edi
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    

008001bb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bb:	55                   	push   %ebp
  8001bc:	89 e5                	mov    %esp,%ebp
  8001be:	57                   	push   %edi
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001da:	85 c0                	test   %eax,%eax
  8001dc:	7e 17                	jle    8001f5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001de:	83 ec 0c             	sub    $0xc,%esp
  8001e1:	50                   	push   %eax
  8001e2:	6a 05                	push   $0x5
  8001e4:	68 0a 24 80 00       	push   $0x80240a
  8001e9:	6a 23                	push   $0x23
  8001eb:	68 27 24 80 00       	push   $0x802427
  8001f0:	e8 d1 13 00 00       	call   8015c6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f8:	5b                   	pop    %ebx
  8001f9:	5e                   	pop    %esi
  8001fa:	5f                   	pop    %edi
  8001fb:	5d                   	pop    %ebp
  8001fc:	c3                   	ret    

008001fd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	57                   	push   %edi
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800206:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020b:	b8 06 00 00 00       	mov    $0x6,%eax
  800210:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800213:	8b 55 08             	mov    0x8(%ebp),%edx
  800216:	89 df                	mov    %ebx,%edi
  800218:	89 de                	mov    %ebx,%esi
  80021a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80021c:	85 c0                	test   %eax,%eax
  80021e:	7e 17                	jle    800237 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800220:	83 ec 0c             	sub    $0xc,%esp
  800223:	50                   	push   %eax
  800224:	6a 06                	push   $0x6
  800226:	68 0a 24 80 00       	push   $0x80240a
  80022b:	6a 23                	push   $0x23
  80022d:	68 27 24 80 00       	push   $0x802427
  800232:	e8 8f 13 00 00       	call   8015c6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800237:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023a:	5b                   	pop    %ebx
  80023b:	5e                   	pop    %esi
  80023c:	5f                   	pop    %edi
  80023d:	5d                   	pop    %ebp
  80023e:	c3                   	ret    

0080023f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	57                   	push   %edi
  800243:	56                   	push   %esi
  800244:	53                   	push   %ebx
  800245:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800248:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024d:	b8 08 00 00 00       	mov    $0x8,%eax
  800252:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800255:	8b 55 08             	mov    0x8(%ebp),%edx
  800258:	89 df                	mov    %ebx,%edi
  80025a:	89 de                	mov    %ebx,%esi
  80025c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80025e:	85 c0                	test   %eax,%eax
  800260:	7e 17                	jle    800279 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	50                   	push   %eax
  800266:	6a 08                	push   $0x8
  800268:	68 0a 24 80 00       	push   $0x80240a
  80026d:	6a 23                	push   $0x23
  80026f:	68 27 24 80 00       	push   $0x802427
  800274:	e8 4d 13 00 00       	call   8015c6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    

00800281 <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	57                   	push   %edi
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028f:	b8 09 00 00 00       	mov    $0x9,%eax
  800294:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800297:	8b 55 08             	mov    0x8(%ebp),%edx
  80029a:	89 df                	mov    %ebx,%edi
  80029c:	89 de                	mov    %ebx,%esi
  80029e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a0:	85 c0                	test   %eax,%eax
  8002a2:	7e 17                	jle    8002bb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	50                   	push   %eax
  8002a8:	6a 09                	push   $0x9
  8002aa:	68 0a 24 80 00       	push   $0x80240a
  8002af:	6a 23                	push   $0x23
  8002b1:	68 27 24 80 00       	push   $0x802427
  8002b6:	e8 0b 13 00 00       	call   8015c6 <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	57                   	push   %edi
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dc:	89 df                	mov    %ebx,%edi
  8002de:	89 de                	mov    %ebx,%esi
  8002e0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	7e 17                	jle    8002fd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	50                   	push   %eax
  8002ea:	6a 0a                	push   $0xa
  8002ec:	68 0a 24 80 00       	push   $0x80240a
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 27 24 80 00       	push   $0x802427
  8002f8:	e8 c9 12 00 00       	call   8015c6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030b:	be 00 00 00 00       	mov    $0x0,%esi
  800310:	b8 0c 00 00 00       	mov    $0xc,%eax
  800315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80031e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800321:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    

00800328 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800331:	b9 00 00 00 00       	mov    $0x0,%ecx
  800336:	b8 0d 00 00 00       	mov    $0xd,%eax
  80033b:	8b 55 08             	mov    0x8(%ebp),%edx
  80033e:	89 cb                	mov    %ecx,%ebx
  800340:	89 cf                	mov    %ecx,%edi
  800342:	89 ce                	mov    %ecx,%esi
  800344:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800346:	85 c0                	test   %eax,%eax
  800348:	7e 17                	jle    800361 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034a:	83 ec 0c             	sub    $0xc,%esp
  80034d:	50                   	push   %eax
  80034e:	6a 0d                	push   $0xd
  800350:	68 0a 24 80 00       	push   $0x80240a
  800355:	6a 23                	push   $0x23
  800357:	68 27 24 80 00       	push   $0x802427
  80035c:	e8 65 12 00 00       	call   8015c6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800361:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800364:	5b                   	pop    %ebx
  800365:	5e                   	pop    %esi
  800366:	5f                   	pop    %edi
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	57                   	push   %edi
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800374:	b8 0e 00 00 00       	mov    $0xe,%eax
  800379:	8b 55 08             	mov    0x8(%ebp),%edx
  80037c:	89 cb                	mov    %ecx,%ebx
  80037e:	89 cf                	mov    %ecx,%edi
  800380:	89 ce                	mov    %ecx,%esi
  800382:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  800384:	5b                   	pop    %ebx
  800385:	5e                   	pop    %esi
  800386:	5f                   	pop    %edi
  800387:	5d                   	pop    %ebp
  800388:	c3                   	ret    

00800389 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	57                   	push   %edi
  80038d:	56                   	push   %esi
  80038e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800394:	b8 0f 00 00 00       	mov    $0xf,%eax
  800399:	8b 55 08             	mov    0x8(%ebp),%edx
  80039c:	89 cb                	mov    %ecx,%ebx
  80039e:	89 cf                	mov    %ecx,%edi
  8003a0:	89 ce                	mov    %ecx,%esi
  8003a2:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003a4:	5b                   	pop    %ebx
  8003a5:	5e                   	pop    %esi
  8003a6:	5f                   	pop    %edi
  8003a7:	5d                   	pop    %ebp
  8003a8:	c3                   	ret    

008003a9 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	57                   	push   %edi
  8003ad:	56                   	push   %esi
  8003ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b4:	b8 10 00 00 00       	mov    $0x10,%eax
  8003b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bc:	89 cb                	mov    %ecx,%ebx
  8003be:	89 cf                	mov    %ecx,%edi
  8003c0:	89 ce                	mov    %ecx,%esi
  8003c2:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8003c4:	5b                   	pop    %ebx
  8003c5:	5e                   	pop    %esi
  8003c6:	5f                   	pop    %edi
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    

008003c9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	53                   	push   %ebx
  8003cd:	83 ec 04             	sub    $0x4,%esp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003d3:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003d5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003d9:	74 11                	je     8003ec <pgfault+0x23>
  8003db:	89 d8                	mov    %ebx,%eax
  8003dd:	c1 e8 0c             	shr    $0xc,%eax
  8003e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003e7:	f6 c4 08             	test   $0x8,%ah
  8003ea:	75 14                	jne    800400 <pgfault+0x37>
		panic("faulting access");
  8003ec:	83 ec 04             	sub    $0x4,%esp
  8003ef:	68 35 24 80 00       	push   $0x802435
  8003f4:	6a 1f                	push   $0x1f
  8003f6:	68 45 24 80 00       	push   $0x802445
  8003fb:	e8 c6 11 00 00       	call   8015c6 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  800400:	83 ec 04             	sub    $0x4,%esp
  800403:	6a 07                	push   $0x7
  800405:	68 00 f0 7f 00       	push   $0x7ff000
  80040a:	6a 00                	push   $0x0
  80040c:	e8 67 fd ff ff       	call   800178 <sys_page_alloc>
	if (r < 0) {
  800411:	83 c4 10             	add    $0x10,%esp
  800414:	85 c0                	test   %eax,%eax
  800416:	79 12                	jns    80042a <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800418:	50                   	push   %eax
  800419:	68 50 24 80 00       	push   $0x802450
  80041e:	6a 2d                	push   $0x2d
  800420:	68 45 24 80 00       	push   $0x802445
  800425:	e8 9c 11 00 00       	call   8015c6 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80042a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800430:	83 ec 04             	sub    $0x4,%esp
  800433:	68 00 10 00 00       	push   $0x1000
  800438:	53                   	push   %ebx
  800439:	68 00 f0 7f 00       	push   $0x7ff000
  80043e:	e8 db 19 00 00       	call   801e1e <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800443:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80044a:	53                   	push   %ebx
  80044b:	6a 00                	push   $0x0
  80044d:	68 00 f0 7f 00       	push   $0x7ff000
  800452:	6a 00                	push   $0x0
  800454:	e8 62 fd ff ff       	call   8001bb <sys_page_map>
	if (r < 0) {
  800459:	83 c4 20             	add    $0x20,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800460:	50                   	push   %eax
  800461:	68 50 24 80 00       	push   $0x802450
  800466:	6a 34                	push   $0x34
  800468:	68 45 24 80 00       	push   $0x802445
  80046d:	e8 54 11 00 00       	call   8015c6 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	68 00 f0 7f 00       	push   $0x7ff000
  80047a:	6a 00                	push   $0x0
  80047c:	e8 7c fd ff ff       	call   8001fd <sys_page_unmap>
	if (r < 0) {
  800481:	83 c4 10             	add    $0x10,%esp
  800484:	85 c0                	test   %eax,%eax
  800486:	79 12                	jns    80049a <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800488:	50                   	push   %eax
  800489:	68 50 24 80 00       	push   $0x802450
  80048e:	6a 38                	push   $0x38
  800490:	68 45 24 80 00       	push   $0x802445
  800495:	e8 2c 11 00 00       	call   8015c6 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80049a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80049d:	c9                   	leave  
  80049e:	c3                   	ret    

0080049f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	57                   	push   %edi
  8004a3:	56                   	push   %esi
  8004a4:	53                   	push   %ebx
  8004a5:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004a8:	68 c9 03 80 00       	push   $0x8003c9
  8004ad:	e8 b9 1a 00 00       	call   801f6b <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004b2:	b8 07 00 00 00       	mov    $0x7,%eax
  8004b7:	cd 30                	int    $0x30
  8004b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	79 17                	jns    8004da <fork+0x3b>
		panic("fork fault %e");
  8004c3:	83 ec 04             	sub    $0x4,%esp
  8004c6:	68 69 24 80 00       	push   $0x802469
  8004cb:	68 85 00 00 00       	push   $0x85
  8004d0:	68 45 24 80 00       	push   $0x802445
  8004d5:	e8 ec 10 00 00       	call   8015c6 <_panic>
  8004da:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e0:	75 24                	jne    800506 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004e2:	e8 53 fc ff ff       	call   80013a <sys_getenvid>
  8004e7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004ec:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8004f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004f7:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800501:	e9 64 01 00 00       	jmp    80066a <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800506:	83 ec 04             	sub    $0x4,%esp
  800509:	6a 07                	push   $0x7
  80050b:	68 00 f0 bf ee       	push   $0xeebff000
  800510:	ff 75 e4             	pushl  -0x1c(%ebp)
  800513:	e8 60 fc ff ff       	call   800178 <sys_page_alloc>
  800518:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80051b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800520:	89 d8                	mov    %ebx,%eax
  800522:	c1 e8 16             	shr    $0x16,%eax
  800525:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80052c:	a8 01                	test   $0x1,%al
  80052e:	0f 84 fc 00 00 00    	je     800630 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800534:	89 d8                	mov    %ebx,%eax
  800536:	c1 e8 0c             	shr    $0xc,%eax
  800539:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800540:	f6 c2 01             	test   $0x1,%dl
  800543:	0f 84 e7 00 00 00    	je     800630 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800549:	89 c6                	mov    %eax,%esi
  80054b:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80054e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800555:	f6 c6 04             	test   $0x4,%dh
  800558:	74 39                	je     800593 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80055a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800561:	83 ec 0c             	sub    $0xc,%esp
  800564:	25 07 0e 00 00       	and    $0xe07,%eax
  800569:	50                   	push   %eax
  80056a:	56                   	push   %esi
  80056b:	57                   	push   %edi
  80056c:	56                   	push   %esi
  80056d:	6a 00                	push   $0x0
  80056f:	e8 47 fc ff ff       	call   8001bb <sys_page_map>
		if (r < 0) {
  800574:	83 c4 20             	add    $0x20,%esp
  800577:	85 c0                	test   %eax,%eax
  800579:	0f 89 b1 00 00 00    	jns    800630 <fork+0x191>
		    	panic("sys page map fault %e");
  80057f:	83 ec 04             	sub    $0x4,%esp
  800582:	68 77 24 80 00       	push   $0x802477
  800587:	6a 55                	push   $0x55
  800589:	68 45 24 80 00       	push   $0x802445
  80058e:	e8 33 10 00 00       	call   8015c6 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800593:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80059a:	f6 c2 02             	test   $0x2,%dl
  80059d:	75 0c                	jne    8005ab <fork+0x10c>
  80059f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005a6:	f6 c4 08             	test   $0x8,%ah
  8005a9:	74 5b                	je     800606 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005ab:	83 ec 0c             	sub    $0xc,%esp
  8005ae:	68 05 08 00 00       	push   $0x805
  8005b3:	56                   	push   %esi
  8005b4:	57                   	push   %edi
  8005b5:	56                   	push   %esi
  8005b6:	6a 00                	push   $0x0
  8005b8:	e8 fe fb ff ff       	call   8001bb <sys_page_map>
		if (r < 0) {
  8005bd:	83 c4 20             	add    $0x20,%esp
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	79 14                	jns    8005d8 <fork+0x139>
		    	panic("sys page map fault %e");
  8005c4:	83 ec 04             	sub    $0x4,%esp
  8005c7:	68 77 24 80 00       	push   $0x802477
  8005cc:	6a 5c                	push   $0x5c
  8005ce:	68 45 24 80 00       	push   $0x802445
  8005d3:	e8 ee 0f 00 00       	call   8015c6 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	68 05 08 00 00       	push   $0x805
  8005e0:	56                   	push   %esi
  8005e1:	6a 00                	push   $0x0
  8005e3:	56                   	push   %esi
  8005e4:	6a 00                	push   $0x0
  8005e6:	e8 d0 fb ff ff       	call   8001bb <sys_page_map>
		if (r < 0) {
  8005eb:	83 c4 20             	add    $0x20,%esp
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	79 3e                	jns    800630 <fork+0x191>
		    	panic("sys page map fault %e");
  8005f2:	83 ec 04             	sub    $0x4,%esp
  8005f5:	68 77 24 80 00       	push   $0x802477
  8005fa:	6a 60                	push   $0x60
  8005fc:	68 45 24 80 00       	push   $0x802445
  800601:	e8 c0 0f 00 00       	call   8015c6 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	6a 05                	push   $0x5
  80060b:	56                   	push   %esi
  80060c:	57                   	push   %edi
  80060d:	56                   	push   %esi
  80060e:	6a 00                	push   $0x0
  800610:	e8 a6 fb ff ff       	call   8001bb <sys_page_map>
		if (r < 0) {
  800615:	83 c4 20             	add    $0x20,%esp
  800618:	85 c0                	test   %eax,%eax
  80061a:	79 14                	jns    800630 <fork+0x191>
		    	panic("sys page map fault %e");
  80061c:	83 ec 04             	sub    $0x4,%esp
  80061f:	68 77 24 80 00       	push   $0x802477
  800624:	6a 65                	push   $0x65
  800626:	68 45 24 80 00       	push   $0x802445
  80062b:	e8 96 0f 00 00       	call   8015c6 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800630:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800636:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80063c:	0f 85 de fe ff ff    	jne    800520 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800642:	a1 04 40 80 00       	mov    0x804004,%eax
  800647:	8b 80 bc 00 00 00    	mov    0xbc(%eax),%eax
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	50                   	push   %eax
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800654:	57                   	push   %edi
  800655:	e8 69 fc ff ff       	call   8002c3 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80065a:	83 c4 08             	add    $0x8,%esp
  80065d:	6a 02                	push   $0x2
  80065f:	57                   	push   %edi
  800660:	e8 da fb ff ff       	call   80023f <sys_env_set_status>
	
	return envid;
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  80066a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066d:	5b                   	pop    %ebx
  80066e:	5e                   	pop    %esi
  80066f:	5f                   	pop    %edi
  800670:	5d                   	pop    %ebp
  800671:	c3                   	ret    

00800672 <sfork>:

envid_t
sfork(void)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800675:	b8 00 00 00 00       	mov    $0x0,%eax
  80067a:	5d                   	pop    %ebp
  80067b:	c3                   	ret    

0080067c <thread_create>:

/*Vyvola systemove volanie pre spustenie threadu (jeho hlavnej rutiny)
vradi id spusteneho threadu*/
envid_t
thread_create(void (*func)())
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread create. func: %x\n", func);
#endif
	eip = (uintptr_t )func;
  800682:	8b 45 08             	mov    0x8(%ebp),%eax
  800685:	a3 08 40 80 00       	mov    %eax,0x804008
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  80068a:	68 82 00 80 00       	push   $0x800082
  80068f:	e8 d5 fc ff ff       	call   800369 <sys_thread_create>

	return id;
}
  800694:	c9                   	leave  
  800695:	c3                   	ret    

00800696 <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  800696:	55                   	push   %ebp
  800697:	89 e5                	mov    %esp,%ebp
  800699:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread interrupt. thread id: %d\n", thread_id);
#endif
	sys_thread_free(thread_id);
  80069c:	ff 75 08             	pushl  0x8(%ebp)
  80069f:	e8 e5 fc ff ff       	call   800389 <sys_thread_free>
}
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	c9                   	leave  
  8006a8:	c3                   	ret    

008006a9 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006a9:	55                   	push   %ebp
  8006aa:	89 e5                	mov    %esp,%ebp
  8006ac:	83 ec 14             	sub    $0x14,%esp
#ifdef TRACE
	cprintf("in fork.c thread join. thread id: %d\n", thread_id);
#endif
	sys_thread_join(thread_id);
  8006af:	ff 75 08             	pushl  0x8(%ebp)
  8006b2:	e8 f2 fc ff ff       	call   8003a9 <sys_thread_join>
}
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <queue_append>:
/*Lab 7: Multithreading - mutex*/

// Funckia prida environment na koniec zoznamu cakajucich threadov
void 
queue_append(envid_t envid, struct waiting_queue* queue) 
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	56                   	push   %esi
  8006c0:	53                   	push   %ebx
  8006c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
#ifdef TRACE
		cprintf("Appending an env (envid: %d)\n", envid);
#endif
	struct waiting_thread* wt = NULL;

	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006c7:	83 ec 04             	sub    $0x4,%esp
  8006ca:	6a 07                	push   $0x7
  8006cc:	6a 00                	push   $0x0
  8006ce:	56                   	push   %esi
  8006cf:	e8 a4 fa ff ff       	call   800178 <sys_page_alloc>
	if (r < 0) {
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	79 15                	jns    8006f0 <queue_append+0x34>
		panic("%e\n", r);
  8006db:	50                   	push   %eax
  8006dc:	68 bd 24 80 00       	push   $0x8024bd
  8006e1:	68 d5 00 00 00       	push   $0xd5
  8006e6:	68 45 24 80 00       	push   $0x802445
  8006eb:	e8 d6 0e 00 00       	call   8015c6 <_panic>
	}	

	wt->envid = envid;
  8006f0:	89 35 00 00 00 00    	mov    %esi,0x0

	if (queue->first == NULL) {
  8006f6:	83 3b 00             	cmpl   $0x0,(%ebx)
  8006f9:	75 13                	jne    80070e <queue_append+0x52>
		queue->first = wt;
		queue->last = wt;
  8006fb:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  800702:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800709:	00 00 00 
  80070c:	eb 1b                	jmp    800729 <queue_append+0x6d>
	} else {
		queue->last->next = wt;
  80070e:	8b 43 04             	mov    0x4(%ebx),%eax
  800711:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800718:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80071f:	00 00 00 
		queue->last = wt;
  800722:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  800729:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80072c:	5b                   	pop    %ebx
  80072d:	5e                   	pop    %esi
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <queue_pop>:

// Funckia vyberie prvy env zo zoznamu cakajucich. POZOR! TATO FUNKCIA BY SA NEMALA
// NIKDY VOLAT AK JE ZOZNAM PRAZDNY!
envid_t 
queue_pop(struct waiting_queue* queue) 
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	8b 55 08             	mov    0x8(%ebp),%edx

	if(queue->first == NULL) {
  800739:	8b 02                	mov    (%edx),%eax
  80073b:	85 c0                	test   %eax,%eax
  80073d:	75 17                	jne    800756 <queue_pop+0x26>
		panic("mutex waiting list empty!\n");
  80073f:	83 ec 04             	sub    $0x4,%esp
  800742:	68 8d 24 80 00       	push   $0x80248d
  800747:	68 ec 00 00 00       	push   $0xec
  80074c:	68 45 24 80 00       	push   $0x802445
  800751:	e8 70 0e 00 00       	call   8015c6 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  800756:	8b 48 04             	mov    0x4(%eax),%ecx
  800759:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
#ifdef TRACE
	cprintf("Popping an env (envid: %d)\n", envid);
#endif
	return envid;
  80075b:	8b 00                	mov    (%eax),%eax
}
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <mutex_lock>:
/*Funckia zamkne mutex - atomickou operaciou xchg sa vymeni hodnota stavu "locked"
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	56                   	push   %esi
  800763:	53                   	push   %ebx
  800764:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800767:	b8 01 00 00 00       	mov    $0x1,%eax
  80076c:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 4a                	je     8007bd <mutex_lock+0x5e>
  800773:	8b 73 04             	mov    0x4(%ebx),%esi
  800776:	83 3e 00             	cmpl   $0x0,(%esi)
  800779:	75 42                	jne    8007bd <mutex_lock+0x5e>
		queue_append(sys_getenvid(), mtx->queue);		
  80077b:	e8 ba f9 ff ff       	call   80013a <sys_getenvid>
  800780:	83 ec 08             	sub    $0x8,%esp
  800783:	56                   	push   %esi
  800784:	50                   	push   %eax
  800785:	e8 32 ff ff ff       	call   8006bc <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80078a:	e8 ab f9 ff ff       	call   80013a <sys_getenvid>
  80078f:	83 c4 08             	add    $0x8,%esp
  800792:	6a 04                	push   $0x4
  800794:	50                   	push   %eax
  800795:	e8 a5 fa ff ff       	call   80023f <sys_env_set_status>

		if (r < 0) {
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	85 c0                	test   %eax,%eax
  80079f:	79 15                	jns    8007b6 <mutex_lock+0x57>
			panic("%e\n", r);
  8007a1:	50                   	push   %eax
  8007a2:	68 bd 24 80 00       	push   $0x8024bd
  8007a7:	68 02 01 00 00       	push   $0x102
  8007ac:	68 45 24 80 00       	push   $0x802445
  8007b1:	e8 10 0e 00 00       	call   8015c6 <_panic>
		}
		sys_yield();
  8007b6:	e8 9e f9 ff ff       	call   800159 <sys_yield>
v pripade, ze sa vrati 0 a necaka nikto na mutex, nastavime vlastnika na terajsi env
v opacnom pripade sa appendne tento env na koniec zoznamu a nastavi sa na NOT RUNNABLE*/
void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007bb:	eb 08                	jmp    8007c5 <mutex_lock+0x66>
		if (r < 0) {
			panic("%e\n", r);
		}
		sys_yield();
	} else {
		mtx->owner = sys_getenvid();
  8007bd:	e8 78 f9 ff ff       	call   80013a <sys_getenvid>
  8007c2:	89 43 08             	mov    %eax,0x8(%ebx)
	}
}
  8007c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007c8:	5b                   	pop    %ebx
  8007c9:	5e                   	pop    %esi
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	83 ec 04             	sub    $0x4,%esp
  8007d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8007de:	8b 43 04             	mov    0x4(%ebx),%eax
  8007e1:	83 38 00             	cmpl   $0x0,(%eax)
  8007e4:	74 33                	je     800819 <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8007e6:	83 ec 0c             	sub    $0xc,%esp
  8007e9:	50                   	push   %eax
  8007ea:	e8 41 ff ff ff       	call   800730 <queue_pop>
  8007ef:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8007f2:	83 c4 08             	add    $0x8,%esp
  8007f5:	6a 02                	push   $0x2
  8007f7:	50                   	push   %eax
  8007f8:	e8 42 fa ff ff       	call   80023f <sys_env_set_status>
		if (r < 0) {
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	85 c0                	test   %eax,%eax
  800802:	79 15                	jns    800819 <mutex_unlock+0x4d>
			panic("%e\n", r);
  800804:	50                   	push   %eax
  800805:	68 bd 24 80 00       	push   $0x8024bd
  80080a:	68 16 01 00 00       	push   $0x116
  80080f:	68 45 24 80 00       	push   $0x802445
  800814:	e8 ad 0d 00 00       	call   8015c6 <_panic>
		}
	}

	//asm volatile("pause"); 	// might be useless here
}
  800819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <mutex_init>:

/*inicializuje mutex - naalokuje pren volnu stranu a nastavi pociatocne hodnoty na 0 alebo NULL*/
void 
mutex_init(struct Mutex* mtx)
{	int r;
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	53                   	push   %ebx
  800822:	83 ec 04             	sub    $0x4,%esp
  800825:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  800828:	e8 0d f9 ff ff       	call   80013a <sys_getenvid>
  80082d:	83 ec 04             	sub    $0x4,%esp
  800830:	6a 07                	push   $0x7
  800832:	53                   	push   %ebx
  800833:	50                   	push   %eax
  800834:	e8 3f f9 ff ff       	call   800178 <sys_page_alloc>
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	85 c0                	test   %eax,%eax
  80083e:	79 15                	jns    800855 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800840:	50                   	push   %eax
  800841:	68 a8 24 80 00       	push   $0x8024a8
  800846:	68 22 01 00 00       	push   $0x122
  80084b:	68 45 24 80 00       	push   $0x802445
  800850:	e8 71 0d 00 00       	call   8015c6 <_panic>
	}	
	mtx->locked = 0;
  800855:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  80085b:	8b 43 04             	mov    0x4(%ebx),%eax
  80085e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800864:	8b 43 04             	mov    0x4(%ebx),%eax
  800867:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  80086e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  800875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	83 ec 04             	sub    $0x4,%esp
  800881:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue->first != NULL) {
  800884:	eb 21                	jmp    8008a7 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
  800886:	83 ec 0c             	sub    $0xc,%esp
  800889:	50                   	push   %eax
  80088a:	e8 a1 fe ff ff       	call   800730 <queue_pop>
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	6a 02                	push   $0x2
  800894:	50                   	push   %eax
  800895:	e8 a5 f9 ff ff       	call   80023f <sys_env_set_status>
		mtx->queue->first = mtx->queue->first->next;
  80089a:	8b 43 04             	mov    0x4(%ebx),%eax
  80089d:	8b 10                	mov    (%eax),%edx
  80089f:	8b 52 04             	mov    0x4(%edx),%edx
  8008a2:	89 10                	mov    %edx,(%eax)
  8008a4:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue->first != NULL) {
  8008a7:	8b 43 04             	mov    0x4(%ebx),%eax
  8008aa:	83 38 00             	cmpl   $0x0,(%eax)
  8008ad:	75 d7                	jne    800886 <mutex_destroy+0xc>
		sys_env_set_status(queue_pop(mtx->queue), ENV_RUNNABLE);
		mtx->queue->first = mtx->queue->first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008af:	83 ec 04             	sub    $0x4,%esp
  8008b2:	68 00 10 00 00       	push   $0x1000
  8008b7:	6a 00                	push   $0x0
  8008b9:	53                   	push   %ebx
  8008ba:	e8 aa 14 00 00       	call   801d69 <memset>
	mtx = NULL;
}
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c5:	c9                   	leave  
  8008c6:	c3                   	ret    

008008c7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	05 00 00 00 30       	add    $0x30000000,%eax
  8008d2:	c1 e8 0c             	shr    $0xc,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	05 00 00 00 30       	add    $0x30000000,%eax
  8008e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008e7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8008f9:	89 c2                	mov    %eax,%edx
  8008fb:	c1 ea 16             	shr    $0x16,%edx
  8008fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800905:	f6 c2 01             	test   $0x1,%dl
  800908:	74 11                	je     80091b <fd_alloc+0x2d>
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	c1 ea 0c             	shr    $0xc,%edx
  80090f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800916:	f6 c2 01             	test   $0x1,%dl
  800919:	75 09                	jne    800924 <fd_alloc+0x36>
			*fd_store = fd;
  80091b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
  800922:	eb 17                	jmp    80093b <fd_alloc+0x4d>
  800924:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800929:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80092e:	75 c9                	jne    8008f9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800930:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800936:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800943:	83 f8 1f             	cmp    $0x1f,%eax
  800946:	77 36                	ja     80097e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800948:	c1 e0 0c             	shl    $0xc,%eax
  80094b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800950:	89 c2                	mov    %eax,%edx
  800952:	c1 ea 16             	shr    $0x16,%edx
  800955:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80095c:	f6 c2 01             	test   $0x1,%dl
  80095f:	74 24                	je     800985 <fd_lookup+0x48>
  800961:	89 c2                	mov    %eax,%edx
  800963:	c1 ea 0c             	shr    $0xc,%edx
  800966:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80096d:	f6 c2 01             	test   $0x1,%dl
  800970:	74 1a                	je     80098c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800972:	8b 55 0c             	mov    0xc(%ebp),%edx
  800975:	89 02                	mov    %eax,(%edx)
	return 0;
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
  80097c:	eb 13                	jmp    800991 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80097e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800983:	eb 0c                	jmp    800991 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800985:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80098a:	eb 05                	jmp    800991 <fd_lookup+0x54>
  80098c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	83 ec 08             	sub    $0x8,%esp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	ba 40 25 80 00       	mov    $0x802540,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8009a1:	eb 13                	jmp    8009b6 <dev_lookup+0x23>
  8009a3:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009a6:	39 08                	cmp    %ecx,(%eax)
  8009a8:	75 0c                	jne    8009b6 <dev_lookup+0x23>
			*dev = devtab[i];
  8009aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ad:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b4:	eb 31                	jmp    8009e7 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009b6:	8b 02                	mov    (%edx),%eax
  8009b8:	85 c0                	test   %eax,%eax
  8009ba:	75 e7                	jne    8009a3 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009bc:	a1 04 40 80 00       	mov    0x804004,%eax
  8009c1:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009c7:	83 ec 04             	sub    $0x4,%esp
  8009ca:	51                   	push   %ecx
  8009cb:	50                   	push   %eax
  8009cc:	68 c4 24 80 00       	push   $0x8024c4
  8009d1:	e8 c9 0c 00 00       	call   80169f <cprintf>
	*dev = 0;
  8009d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009df:	83 c4 10             	add    $0x10,%esp
  8009e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	83 ec 10             	sub    $0x10,%esp
  8009f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8009f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009fa:	50                   	push   %eax
  8009fb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a01:	c1 e8 0c             	shr    $0xc,%eax
  800a04:	50                   	push   %eax
  800a05:	e8 33 ff ff ff       	call   80093d <fd_lookup>
  800a0a:	83 c4 08             	add    $0x8,%esp
  800a0d:	85 c0                	test   %eax,%eax
  800a0f:	78 05                	js     800a16 <fd_close+0x2d>
	    || fd != fd2)
  800a11:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a14:	74 0c                	je     800a22 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a16:	84 db                	test   %bl,%bl
  800a18:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1d:	0f 44 c2             	cmove  %edx,%eax
  800a20:	eb 41                	jmp    800a63 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a22:	83 ec 08             	sub    $0x8,%esp
  800a25:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a28:	50                   	push   %eax
  800a29:	ff 36                	pushl  (%esi)
  800a2b:	e8 63 ff ff ff       	call   800993 <dev_lookup>
  800a30:	89 c3                	mov    %eax,%ebx
  800a32:	83 c4 10             	add    $0x10,%esp
  800a35:	85 c0                	test   %eax,%eax
  800a37:	78 1a                	js     800a53 <fd_close+0x6a>
		if (dev->dev_close)
  800a39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a3c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a3f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a44:	85 c0                	test   %eax,%eax
  800a46:	74 0b                	je     800a53 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a48:	83 ec 0c             	sub    $0xc,%esp
  800a4b:	56                   	push   %esi
  800a4c:	ff d0                	call   *%eax
  800a4e:	89 c3                	mov    %eax,%ebx
  800a50:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a53:	83 ec 08             	sub    $0x8,%esp
  800a56:	56                   	push   %esi
  800a57:	6a 00                	push   $0x0
  800a59:	e8 9f f7 ff ff       	call   8001fd <sys_page_unmap>
	return r;
  800a5e:	83 c4 10             	add    $0x10,%esp
  800a61:	89 d8                	mov    %ebx,%eax
}
  800a63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a73:	50                   	push   %eax
  800a74:	ff 75 08             	pushl  0x8(%ebp)
  800a77:	e8 c1 fe ff ff       	call   80093d <fd_lookup>
  800a7c:	83 c4 08             	add    $0x8,%esp
  800a7f:	85 c0                	test   %eax,%eax
  800a81:	78 10                	js     800a93 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a83:	83 ec 08             	sub    $0x8,%esp
  800a86:	6a 01                	push   $0x1
  800a88:	ff 75 f4             	pushl  -0xc(%ebp)
  800a8b:	e8 59 ff ff ff       	call   8009e9 <fd_close>
  800a90:	83 c4 10             	add    $0x10,%esp
}
  800a93:	c9                   	leave  
  800a94:	c3                   	ret    

00800a95 <close_all>:

void
close_all(void)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	53                   	push   %ebx
  800a99:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800a9c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800aa1:	83 ec 0c             	sub    $0xc,%esp
  800aa4:	53                   	push   %ebx
  800aa5:	e8 c0 ff ff ff       	call   800a6a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800aaa:	83 c3 01             	add    $0x1,%ebx
  800aad:	83 c4 10             	add    $0x10,%esp
  800ab0:	83 fb 20             	cmp    $0x20,%ebx
  800ab3:	75 ec                	jne    800aa1 <close_all+0xc>
		close(i);
}
  800ab5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab8:	c9                   	leave  
  800ab9:	c3                   	ret    

00800aba <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	83 ec 2c             	sub    $0x2c,%esp
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ac6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ac9:	50                   	push   %eax
  800aca:	ff 75 08             	pushl  0x8(%ebp)
  800acd:	e8 6b fe ff ff       	call   80093d <fd_lookup>
  800ad2:	83 c4 08             	add    $0x8,%esp
  800ad5:	85 c0                	test   %eax,%eax
  800ad7:	0f 88 c1 00 00 00    	js     800b9e <dup+0xe4>
		return r;
	close(newfdnum);
  800add:	83 ec 0c             	sub    $0xc,%esp
  800ae0:	56                   	push   %esi
  800ae1:	e8 84 ff ff ff       	call   800a6a <close>

	newfd = INDEX2FD(newfdnum);
  800ae6:	89 f3                	mov    %esi,%ebx
  800ae8:	c1 e3 0c             	shl    $0xc,%ebx
  800aeb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800af1:	83 c4 04             	add    $0x4,%esp
  800af4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800af7:	e8 db fd ff ff       	call   8008d7 <fd2data>
  800afc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800afe:	89 1c 24             	mov    %ebx,(%esp)
  800b01:	e8 d1 fd ff ff       	call   8008d7 <fd2data>
  800b06:	83 c4 10             	add    $0x10,%esp
  800b09:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b0c:	89 f8                	mov    %edi,%eax
  800b0e:	c1 e8 16             	shr    $0x16,%eax
  800b11:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b18:	a8 01                	test   $0x1,%al
  800b1a:	74 37                	je     800b53 <dup+0x99>
  800b1c:	89 f8                	mov    %edi,%eax
  800b1e:	c1 e8 0c             	shr    $0xc,%eax
  800b21:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b28:	f6 c2 01             	test   $0x1,%dl
  800b2b:	74 26                	je     800b53 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b2d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b34:	83 ec 0c             	sub    $0xc,%esp
  800b37:	25 07 0e 00 00       	and    $0xe07,%eax
  800b3c:	50                   	push   %eax
  800b3d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b40:	6a 00                	push   $0x0
  800b42:	57                   	push   %edi
  800b43:	6a 00                	push   $0x0
  800b45:	e8 71 f6 ff ff       	call   8001bb <sys_page_map>
  800b4a:	89 c7                	mov    %eax,%edi
  800b4c:	83 c4 20             	add    $0x20,%esp
  800b4f:	85 c0                	test   %eax,%eax
  800b51:	78 2e                	js     800b81 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b53:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b56:	89 d0                	mov    %edx,%eax
  800b58:	c1 e8 0c             	shr    $0xc,%eax
  800b5b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	25 07 0e 00 00       	and    $0xe07,%eax
  800b6a:	50                   	push   %eax
  800b6b:	53                   	push   %ebx
  800b6c:	6a 00                	push   $0x0
  800b6e:	52                   	push   %edx
  800b6f:	6a 00                	push   $0x0
  800b71:	e8 45 f6 ff ff       	call   8001bb <sys_page_map>
  800b76:	89 c7                	mov    %eax,%edi
  800b78:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b7b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b7d:	85 ff                	test   %edi,%edi
  800b7f:	79 1d                	jns    800b9e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b81:	83 ec 08             	sub    $0x8,%esp
  800b84:	53                   	push   %ebx
  800b85:	6a 00                	push   $0x0
  800b87:	e8 71 f6 ff ff       	call   8001fd <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b8c:	83 c4 08             	add    $0x8,%esp
  800b8f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b92:	6a 00                	push   $0x0
  800b94:	e8 64 f6 ff ff       	call   8001fd <sys_page_unmap>
	return r;
  800b99:	83 c4 10             	add    $0x10,%esp
  800b9c:	89 f8                	mov    %edi,%eax
}
  800b9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 14             	sub    $0x14,%esp
  800bad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bb0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bb3:	50                   	push   %eax
  800bb4:	53                   	push   %ebx
  800bb5:	e8 83 fd ff ff       	call   80093d <fd_lookup>
  800bba:	83 c4 08             	add    $0x8,%esp
  800bbd:	89 c2                	mov    %eax,%edx
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	78 70                	js     800c33 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bc3:	83 ec 08             	sub    $0x8,%esp
  800bc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc9:	50                   	push   %eax
  800bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bcd:	ff 30                	pushl  (%eax)
  800bcf:	e8 bf fd ff ff       	call   800993 <dev_lookup>
  800bd4:	83 c4 10             	add    $0x10,%esp
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	78 4f                	js     800c2a <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800bdb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bde:	8b 42 08             	mov    0x8(%edx),%eax
  800be1:	83 e0 03             	and    $0x3,%eax
  800be4:	83 f8 01             	cmp    $0x1,%eax
  800be7:	75 24                	jne    800c0d <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800be9:	a1 04 40 80 00       	mov    0x804004,%eax
  800bee:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800bf4:	83 ec 04             	sub    $0x4,%esp
  800bf7:	53                   	push   %ebx
  800bf8:	50                   	push   %eax
  800bf9:	68 05 25 80 00       	push   $0x802505
  800bfe:	e8 9c 0a 00 00       	call   80169f <cprintf>
		return -E_INVAL;
  800c03:	83 c4 10             	add    $0x10,%esp
  800c06:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c0b:	eb 26                	jmp    800c33 <read+0x8d>
	}
	if (!dev->dev_read)
  800c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c10:	8b 40 08             	mov    0x8(%eax),%eax
  800c13:	85 c0                	test   %eax,%eax
  800c15:	74 17                	je     800c2e <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c17:	83 ec 04             	sub    $0x4,%esp
  800c1a:	ff 75 10             	pushl  0x10(%ebp)
  800c1d:	ff 75 0c             	pushl  0xc(%ebp)
  800c20:	52                   	push   %edx
  800c21:	ff d0                	call   *%eax
  800c23:	89 c2                	mov    %eax,%edx
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	eb 09                	jmp    800c33 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c2a:	89 c2                	mov    %eax,%edx
  800c2c:	eb 05                	jmp    800c33 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c2e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c33:	89 d0                	mov    %edx,%eax
  800c35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c38:	c9                   	leave  
  800c39:	c3                   	ret    

00800c3a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c46:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	eb 21                	jmp    800c71 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c50:	83 ec 04             	sub    $0x4,%esp
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	29 d8                	sub    %ebx,%eax
  800c57:	50                   	push   %eax
  800c58:	89 d8                	mov    %ebx,%eax
  800c5a:	03 45 0c             	add    0xc(%ebp),%eax
  800c5d:	50                   	push   %eax
  800c5e:	57                   	push   %edi
  800c5f:	e8 42 ff ff ff       	call   800ba6 <read>
		if (m < 0)
  800c64:	83 c4 10             	add    $0x10,%esp
  800c67:	85 c0                	test   %eax,%eax
  800c69:	78 10                	js     800c7b <readn+0x41>
			return m;
		if (m == 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	74 0a                	je     800c79 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c6f:	01 c3                	add    %eax,%ebx
  800c71:	39 f3                	cmp    %esi,%ebx
  800c73:	72 db                	jb     800c50 <readn+0x16>
  800c75:	89 d8                	mov    %ebx,%eax
  800c77:	eb 02                	jmp    800c7b <readn+0x41>
  800c79:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	53                   	push   %ebx
  800c87:	83 ec 14             	sub    $0x14,%esp
  800c8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c90:	50                   	push   %eax
  800c91:	53                   	push   %ebx
  800c92:	e8 a6 fc ff ff       	call   80093d <fd_lookup>
  800c97:	83 c4 08             	add    $0x8,%esp
  800c9a:	89 c2                	mov    %eax,%edx
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	78 6b                	js     800d0b <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ca0:	83 ec 08             	sub    $0x8,%esp
  800ca3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca6:	50                   	push   %eax
  800ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800caa:	ff 30                	pushl  (%eax)
  800cac:	e8 e2 fc ff ff       	call   800993 <dev_lookup>
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	78 4a                	js     800d02 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cbb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cbf:	75 24                	jne    800ce5 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800cc1:	a1 04 40 80 00       	mov    0x804004,%eax
  800cc6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800ccc:	83 ec 04             	sub    $0x4,%esp
  800ccf:	53                   	push   %ebx
  800cd0:	50                   	push   %eax
  800cd1:	68 21 25 80 00       	push   $0x802521
  800cd6:	e8 c4 09 00 00       	call   80169f <cprintf>
		return -E_INVAL;
  800cdb:	83 c4 10             	add    $0x10,%esp
  800cde:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ce3:	eb 26                	jmp    800d0b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ce5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ce8:	8b 52 0c             	mov    0xc(%edx),%edx
  800ceb:	85 d2                	test   %edx,%edx
  800ced:	74 17                	je     800d06 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800cef:	83 ec 04             	sub    $0x4,%esp
  800cf2:	ff 75 10             	pushl  0x10(%ebp)
  800cf5:	ff 75 0c             	pushl  0xc(%ebp)
  800cf8:	50                   	push   %eax
  800cf9:	ff d2                	call   *%edx
  800cfb:	89 c2                	mov    %eax,%edx
  800cfd:	83 c4 10             	add    $0x10,%esp
  800d00:	eb 09                	jmp    800d0b <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d02:	89 c2                	mov    %eax,%edx
  800d04:	eb 05                	jmp    800d0b <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d06:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d0b:	89 d0                	mov    %edx,%eax
  800d0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d18:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d1b:	50                   	push   %eax
  800d1c:	ff 75 08             	pushl  0x8(%ebp)
  800d1f:	e8 19 fc ff ff       	call   80093d <fd_lookup>
  800d24:	83 c4 08             	add    $0x8,%esp
  800d27:	85 c0                	test   %eax,%eax
  800d29:	78 0e                	js     800d39 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d31:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	53                   	push   %ebx
  800d3f:	83 ec 14             	sub    $0x14,%esp
  800d42:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d45:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d48:	50                   	push   %eax
  800d49:	53                   	push   %ebx
  800d4a:	e8 ee fb ff ff       	call   80093d <fd_lookup>
  800d4f:	83 c4 08             	add    $0x8,%esp
  800d52:	89 c2                	mov    %eax,%edx
  800d54:	85 c0                	test   %eax,%eax
  800d56:	78 68                	js     800dc0 <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d58:	83 ec 08             	sub    $0x8,%esp
  800d5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5e:	50                   	push   %eax
  800d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d62:	ff 30                	pushl  (%eax)
  800d64:	e8 2a fc ff ff       	call   800993 <dev_lookup>
  800d69:	83 c4 10             	add    $0x10,%esp
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	78 47                	js     800db7 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d73:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d77:	75 24                	jne    800d9d <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d79:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d7e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d84:	83 ec 04             	sub    $0x4,%esp
  800d87:	53                   	push   %ebx
  800d88:	50                   	push   %eax
  800d89:	68 e4 24 80 00       	push   $0x8024e4
  800d8e:	e8 0c 09 00 00       	call   80169f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d93:	83 c4 10             	add    $0x10,%esp
  800d96:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d9b:	eb 23                	jmp    800dc0 <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800d9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800da0:	8b 52 18             	mov    0x18(%edx),%edx
  800da3:	85 d2                	test   %edx,%edx
  800da5:	74 14                	je     800dbb <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800da7:	83 ec 08             	sub    $0x8,%esp
  800daa:	ff 75 0c             	pushl  0xc(%ebp)
  800dad:	50                   	push   %eax
  800dae:	ff d2                	call   *%edx
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	83 c4 10             	add    $0x10,%esp
  800db5:	eb 09                	jmp    800dc0 <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800db7:	89 c2                	mov    %eax,%edx
  800db9:	eb 05                	jmp    800dc0 <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800dbb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dc0:	89 d0                	mov    %edx,%eax
  800dc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc5:	c9                   	leave  
  800dc6:	c3                   	ret    

00800dc7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 14             	sub    $0x14,%esp
  800dce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dd1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd4:	50                   	push   %eax
  800dd5:	ff 75 08             	pushl  0x8(%ebp)
  800dd8:	e8 60 fb ff ff       	call   80093d <fd_lookup>
  800ddd:	83 c4 08             	add    $0x8,%esp
  800de0:	89 c2                	mov    %eax,%edx
  800de2:	85 c0                	test   %eax,%eax
  800de4:	78 58                	js     800e3e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800de6:	83 ec 08             	sub    $0x8,%esp
  800de9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dec:	50                   	push   %eax
  800ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df0:	ff 30                	pushl  (%eax)
  800df2:	e8 9c fb ff ff       	call   800993 <dev_lookup>
  800df7:	83 c4 10             	add    $0x10,%esp
  800dfa:	85 c0                	test   %eax,%eax
  800dfc:	78 37                	js     800e35 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e01:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e05:	74 32                	je     800e39 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e07:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e0a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e11:	00 00 00 
	stat->st_isdir = 0;
  800e14:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e1b:	00 00 00 
	stat->st_dev = dev;
  800e1e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e24:	83 ec 08             	sub    $0x8,%esp
  800e27:	53                   	push   %ebx
  800e28:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2b:	ff 50 14             	call   *0x14(%eax)
  800e2e:	89 c2                	mov    %eax,%edx
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	eb 09                	jmp    800e3e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	eb 05                	jmp    800e3e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e39:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e3e:	89 d0                	mov    %edx,%eax
  800e40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e43:	c9                   	leave  
  800e44:	c3                   	ret    

00800e45 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	6a 00                	push   $0x0
  800e4f:	ff 75 08             	pushl  0x8(%ebp)
  800e52:	e8 e3 01 00 00       	call   80103a <open>
  800e57:	89 c3                	mov    %eax,%ebx
  800e59:	83 c4 10             	add    $0x10,%esp
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	78 1b                	js     800e7b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e60:	83 ec 08             	sub    $0x8,%esp
  800e63:	ff 75 0c             	pushl  0xc(%ebp)
  800e66:	50                   	push   %eax
  800e67:	e8 5b ff ff ff       	call   800dc7 <fstat>
  800e6c:	89 c6                	mov    %eax,%esi
	close(fd);
  800e6e:	89 1c 24             	mov    %ebx,(%esp)
  800e71:	e8 f4 fb ff ff       	call   800a6a <close>
	return r;
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	89 f0                	mov    %esi,%eax
}
  800e7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7e:	5b                   	pop    %ebx
  800e7f:	5e                   	pop    %esi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	89 c6                	mov    %eax,%esi
  800e89:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e8b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e92:	75 12                	jne    800ea6 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e94:	83 ec 0c             	sub    $0xc,%esp
  800e97:	6a 01                	push   $0x1
  800e99:	e8 39 12 00 00       	call   8020d7 <ipc_find_env>
  800e9e:	a3 00 40 80 00       	mov    %eax,0x804000
  800ea3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ea6:	6a 07                	push   $0x7
  800ea8:	68 00 50 80 00       	push   $0x805000
  800ead:	56                   	push   %esi
  800eae:	ff 35 00 40 80 00    	pushl  0x804000
  800eb4:	e8 bc 11 00 00       	call   802075 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800eb9:	83 c4 0c             	add    $0xc,%esp
  800ebc:	6a 00                	push   $0x0
  800ebe:	53                   	push   %ebx
  800ebf:	6a 00                	push   $0x0
  800ec1:	e8 34 11 00 00       	call   801ffa <ipc_recv>
}
  800ec6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ed3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed6:	8b 40 0c             	mov    0xc(%eax),%eax
  800ed9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ee6:	ba 00 00 00 00       	mov    $0x0,%edx
  800eeb:	b8 02 00 00 00       	mov    $0x2,%eax
  800ef0:	e8 8d ff ff ff       	call   800e82 <fsipc>
}
  800ef5:	c9                   	leave  
  800ef6:	c3                   	ret    

00800ef7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800efd:	8b 45 08             	mov    0x8(%ebp),%eax
  800f00:	8b 40 0c             	mov    0xc(%eax),%eax
  800f03:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f08:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0d:	b8 06 00 00 00       	mov    $0x6,%eax
  800f12:	e8 6b ff ff ff       	call   800e82 <fsipc>
}
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    

00800f19 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	53                   	push   %ebx
  800f1d:	83 ec 04             	sub    $0x4,%esp
  800f20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f23:	8b 45 08             	mov    0x8(%ebp),%eax
  800f26:	8b 40 0c             	mov    0xc(%eax),%eax
  800f29:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	b8 05 00 00 00       	mov    $0x5,%eax
  800f38:	e8 45 ff ff ff       	call   800e82 <fsipc>
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	78 2c                	js     800f6d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f41:	83 ec 08             	sub    $0x8,%esp
  800f44:	68 00 50 80 00       	push   $0x805000
  800f49:	53                   	push   %ebx
  800f4a:	e8 d5 0c 00 00       	call   801c24 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f4f:	a1 80 50 80 00       	mov    0x805080,%eax
  800f54:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f5a:	a1 84 50 80 00       	mov    0x805084,%eax
  800f5f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 0c             	sub    $0xc,%esp
  800f78:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	8b 52 0c             	mov    0xc(%edx),%edx
  800f81:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f87:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f8c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800f91:	0f 47 c2             	cmova  %edx,%eax
  800f94:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800f99:	50                   	push   %eax
  800f9a:	ff 75 0c             	pushl  0xc(%ebp)
  800f9d:	68 08 50 80 00       	push   $0x805008
  800fa2:	e8 0f 0e 00 00       	call   801db6 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fac:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb1:	e8 cc fe ff ff       	call   800e82 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	56                   	push   %esi
  800fbc:	53                   	push   %ebx
  800fbd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc3:	8b 40 0c             	mov    0xc(%eax),%eax
  800fc6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fcb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd6:	b8 03 00 00 00       	mov    $0x3,%eax
  800fdb:	e8 a2 fe ff ff       	call   800e82 <fsipc>
  800fe0:	89 c3                	mov    %eax,%ebx
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 4b                	js     801031 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800fe6:	39 c6                	cmp    %eax,%esi
  800fe8:	73 16                	jae    801000 <devfile_read+0x48>
  800fea:	68 50 25 80 00       	push   $0x802550
  800fef:	68 57 25 80 00       	push   $0x802557
  800ff4:	6a 7c                	push   $0x7c
  800ff6:	68 6c 25 80 00       	push   $0x80256c
  800ffb:	e8 c6 05 00 00       	call   8015c6 <_panic>
	assert(r <= PGSIZE);
  801000:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801005:	7e 16                	jle    80101d <devfile_read+0x65>
  801007:	68 77 25 80 00       	push   $0x802577
  80100c:	68 57 25 80 00       	push   $0x802557
  801011:	6a 7d                	push   $0x7d
  801013:	68 6c 25 80 00       	push   $0x80256c
  801018:	e8 a9 05 00 00       	call   8015c6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80101d:	83 ec 04             	sub    $0x4,%esp
  801020:	50                   	push   %eax
  801021:	68 00 50 80 00       	push   $0x805000
  801026:	ff 75 0c             	pushl  0xc(%ebp)
  801029:	e8 88 0d 00 00       	call   801db6 <memmove>
	return r;
  80102e:	83 c4 10             	add    $0x10,%esp
}
  801031:	89 d8                	mov    %ebx,%eax
  801033:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801036:	5b                   	pop    %ebx
  801037:	5e                   	pop    %esi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    

0080103a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	53                   	push   %ebx
  80103e:	83 ec 20             	sub    $0x20,%esp
  801041:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801044:	53                   	push   %ebx
  801045:	e8 a1 0b 00 00       	call   801beb <strlen>
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801052:	7f 67                	jg     8010bb <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80105a:	50                   	push   %eax
  80105b:	e8 8e f8 ff ff       	call   8008ee <fd_alloc>
  801060:	83 c4 10             	add    $0x10,%esp
		return r;
  801063:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801065:	85 c0                	test   %eax,%eax
  801067:	78 57                	js     8010c0 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801069:	83 ec 08             	sub    $0x8,%esp
  80106c:	53                   	push   %ebx
  80106d:	68 00 50 80 00       	push   $0x805000
  801072:	e8 ad 0b 00 00       	call   801c24 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801077:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80107f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801082:	b8 01 00 00 00       	mov    $0x1,%eax
  801087:	e8 f6 fd ff ff       	call   800e82 <fsipc>
  80108c:	89 c3                	mov    %eax,%ebx
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	85 c0                	test   %eax,%eax
  801093:	79 14                	jns    8010a9 <open+0x6f>
		fd_close(fd, 0);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	6a 00                	push   $0x0
  80109a:	ff 75 f4             	pushl  -0xc(%ebp)
  80109d:	e8 47 f9 ff ff       	call   8009e9 <fd_close>
		return r;
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	89 da                	mov    %ebx,%edx
  8010a7:	eb 17                	jmp    8010c0 <open+0x86>
	}

	return fd2num(fd);
  8010a9:	83 ec 0c             	sub    $0xc,%esp
  8010ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8010af:	e8 13 f8 ff ff       	call   8008c7 <fd2num>
  8010b4:	89 c2                	mov    %eax,%edx
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	eb 05                	jmp    8010c0 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010bb:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010c0:	89 d0                	mov    %edx,%eax
  8010c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    

008010c7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d2:	b8 08 00 00 00       	mov    $0x8,%eax
  8010d7:	e8 a6 fd ff ff       	call   800e82 <fsipc>
}
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010e6:	83 ec 0c             	sub    $0xc,%esp
  8010e9:	ff 75 08             	pushl  0x8(%ebp)
  8010ec:	e8 e6 f7 ff ff       	call   8008d7 <fd2data>
  8010f1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	68 83 25 80 00       	push   $0x802583
  8010fb:	53                   	push   %ebx
  8010fc:	e8 23 0b 00 00       	call   801c24 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801101:	8b 46 04             	mov    0x4(%esi),%eax
  801104:	2b 06                	sub    (%esi),%eax
  801106:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80110c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801113:	00 00 00 
	stat->st_dev = &devpipe;
  801116:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80111d:	30 80 00 
	return 0;
}
  801120:	b8 00 00 00 00       	mov    $0x0,%eax
  801125:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5d                   	pop    %ebp
  80112b:	c3                   	ret    

0080112c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	53                   	push   %ebx
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801136:	53                   	push   %ebx
  801137:	6a 00                	push   $0x0
  801139:	e8 bf f0 ff ff       	call   8001fd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80113e:	89 1c 24             	mov    %ebx,(%esp)
  801141:	e8 91 f7 ff ff       	call   8008d7 <fd2data>
  801146:	83 c4 08             	add    $0x8,%esp
  801149:	50                   	push   %eax
  80114a:	6a 00                	push   $0x0
  80114c:	e8 ac f0 ff ff       	call   8001fd <sys_page_unmap>
}
  801151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	57                   	push   %edi
  80115a:	56                   	push   %esi
  80115b:	53                   	push   %ebx
  80115c:	83 ec 1c             	sub    $0x1c,%esp
  80115f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801162:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801164:	a1 04 40 80 00       	mov    0x804004,%eax
  801169:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80116f:	83 ec 0c             	sub    $0xc,%esp
  801172:	ff 75 e0             	pushl  -0x20(%ebp)
  801175:	e8 a2 0f 00 00       	call   80211c <pageref>
  80117a:	89 c3                	mov    %eax,%ebx
  80117c:	89 3c 24             	mov    %edi,(%esp)
  80117f:	e8 98 0f 00 00       	call   80211c <pageref>
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	39 c3                	cmp    %eax,%ebx
  801189:	0f 94 c1             	sete   %cl
  80118c:	0f b6 c9             	movzbl %cl,%ecx
  80118f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801192:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801198:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  80119e:	39 ce                	cmp    %ecx,%esi
  8011a0:	74 1e                	je     8011c0 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  8011a2:	39 c3                	cmp    %eax,%ebx
  8011a4:	75 be                	jne    801164 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011a6:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011af:	50                   	push   %eax
  8011b0:	56                   	push   %esi
  8011b1:	68 8a 25 80 00       	push   $0x80258a
  8011b6:	e8 e4 04 00 00       	call   80169f <cprintf>
  8011bb:	83 c4 10             	add    $0x10,%esp
  8011be:	eb a4                	jmp    801164 <_pipeisclosed+0xe>
	}
}
  8011c0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c6:	5b                   	pop    %ebx
  8011c7:	5e                   	pop    %esi
  8011c8:	5f                   	pop    %edi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	57                   	push   %edi
  8011cf:	56                   	push   %esi
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 28             	sub    $0x28,%esp
  8011d4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011d7:	56                   	push   %esi
  8011d8:	e8 fa f6 ff ff       	call   8008d7 <fd2data>
  8011dd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e7:	eb 4b                	jmp    801234 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011e9:	89 da                	mov    %ebx,%edx
  8011eb:	89 f0                	mov    %esi,%eax
  8011ed:	e8 64 ff ff ff       	call   801156 <_pipeisclosed>
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	75 48                	jne    80123e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011f6:	e8 5e ef ff ff       	call   800159 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011fb:	8b 43 04             	mov    0x4(%ebx),%eax
  8011fe:	8b 0b                	mov    (%ebx),%ecx
  801200:	8d 51 20             	lea    0x20(%ecx),%edx
  801203:	39 d0                	cmp    %edx,%eax
  801205:	73 e2                	jae    8011e9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801207:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80120e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801211:	89 c2                	mov    %eax,%edx
  801213:	c1 fa 1f             	sar    $0x1f,%edx
  801216:	89 d1                	mov    %edx,%ecx
  801218:	c1 e9 1b             	shr    $0x1b,%ecx
  80121b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80121e:	83 e2 1f             	and    $0x1f,%edx
  801221:	29 ca                	sub    %ecx,%edx
  801223:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801227:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80122b:	83 c0 01             	add    $0x1,%eax
  80122e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801231:	83 c7 01             	add    $0x1,%edi
  801234:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801237:	75 c2                	jne    8011fb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801239:	8b 45 10             	mov    0x10(%ebp),%eax
  80123c:	eb 05                	jmp    801243 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80123e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801243:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801246:	5b                   	pop    %ebx
  801247:	5e                   	pop    %esi
  801248:	5f                   	pop    %edi
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    

0080124b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	83 ec 18             	sub    $0x18,%esp
  801254:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801257:	57                   	push   %edi
  801258:	e8 7a f6 ff ff       	call   8008d7 <fd2data>
  80125d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	bb 00 00 00 00       	mov    $0x0,%ebx
  801267:	eb 3d                	jmp    8012a6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801269:	85 db                	test   %ebx,%ebx
  80126b:	74 04                	je     801271 <devpipe_read+0x26>
				return i;
  80126d:	89 d8                	mov    %ebx,%eax
  80126f:	eb 44                	jmp    8012b5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801271:	89 f2                	mov    %esi,%edx
  801273:	89 f8                	mov    %edi,%eax
  801275:	e8 dc fe ff ff       	call   801156 <_pipeisclosed>
  80127a:	85 c0                	test   %eax,%eax
  80127c:	75 32                	jne    8012b0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80127e:	e8 d6 ee ff ff       	call   800159 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801283:	8b 06                	mov    (%esi),%eax
  801285:	3b 46 04             	cmp    0x4(%esi),%eax
  801288:	74 df                	je     801269 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80128a:	99                   	cltd   
  80128b:	c1 ea 1b             	shr    $0x1b,%edx
  80128e:	01 d0                	add    %edx,%eax
  801290:	83 e0 1f             	and    $0x1f,%eax
  801293:	29 d0                	sub    %edx,%eax
  801295:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80129a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80129d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8012a0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012a3:	83 c3 01             	add    $0x1,%ebx
  8012a6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012a9:	75 d8                	jne    801283 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ae:	eb 05                	jmp    8012b5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012b0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5f                   	pop    %edi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	56                   	push   %esi
  8012c1:	53                   	push   %ebx
  8012c2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c8:	50                   	push   %eax
  8012c9:	e8 20 f6 ff ff       	call   8008ee <fd_alloc>
  8012ce:	83 c4 10             	add    $0x10,%esp
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	0f 88 2c 01 00 00    	js     801407 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012db:	83 ec 04             	sub    $0x4,%esp
  8012de:	68 07 04 00 00       	push   $0x407
  8012e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e6:	6a 00                	push   $0x0
  8012e8:	e8 8b ee ff ff       	call   800178 <sys_page_alloc>
  8012ed:	83 c4 10             	add    $0x10,%esp
  8012f0:	89 c2                	mov    %eax,%edx
  8012f2:	85 c0                	test   %eax,%eax
  8012f4:	0f 88 0d 01 00 00    	js     801407 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	e8 e8 f5 ff ff       	call   8008ee <fd_alloc>
  801306:	89 c3                	mov    %eax,%ebx
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	85 c0                	test   %eax,%eax
  80130d:	0f 88 e2 00 00 00    	js     8013f5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801313:	83 ec 04             	sub    $0x4,%esp
  801316:	68 07 04 00 00       	push   $0x407
  80131b:	ff 75 f0             	pushl  -0x10(%ebp)
  80131e:	6a 00                	push   $0x0
  801320:	e8 53 ee ff ff       	call   800178 <sys_page_alloc>
  801325:	89 c3                	mov    %eax,%ebx
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	85 c0                	test   %eax,%eax
  80132c:	0f 88 c3 00 00 00    	js     8013f5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801332:	83 ec 0c             	sub    $0xc,%esp
  801335:	ff 75 f4             	pushl  -0xc(%ebp)
  801338:	e8 9a f5 ff ff       	call   8008d7 <fd2data>
  80133d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80133f:	83 c4 0c             	add    $0xc,%esp
  801342:	68 07 04 00 00       	push   $0x407
  801347:	50                   	push   %eax
  801348:	6a 00                	push   $0x0
  80134a:	e8 29 ee ff ff       	call   800178 <sys_page_alloc>
  80134f:	89 c3                	mov    %eax,%ebx
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	85 c0                	test   %eax,%eax
  801356:	0f 88 89 00 00 00    	js     8013e5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80135c:	83 ec 0c             	sub    $0xc,%esp
  80135f:	ff 75 f0             	pushl  -0x10(%ebp)
  801362:	e8 70 f5 ff ff       	call   8008d7 <fd2data>
  801367:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80136e:	50                   	push   %eax
  80136f:	6a 00                	push   $0x0
  801371:	56                   	push   %esi
  801372:	6a 00                	push   $0x0
  801374:	e8 42 ee ff ff       	call   8001bb <sys_page_map>
  801379:	89 c3                	mov    %eax,%ebx
  80137b:	83 c4 20             	add    $0x20,%esp
  80137e:	85 c0                	test   %eax,%eax
  801380:	78 55                	js     8013d7 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801382:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801388:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80138d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801390:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801397:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80139d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8013a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b2:	e8 10 f5 ff ff       	call   8008c7 <fd2num>
  8013b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ba:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013bc:	83 c4 04             	add    $0x4,%esp
  8013bf:	ff 75 f0             	pushl  -0x10(%ebp)
  8013c2:	e8 00 f5 ff ff       	call   8008c7 <fd2num>
  8013c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ca:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d5:	eb 30                	jmp    801407 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013d7:	83 ec 08             	sub    $0x8,%esp
  8013da:	56                   	push   %esi
  8013db:	6a 00                	push   $0x0
  8013dd:	e8 1b ee ff ff       	call   8001fd <sys_page_unmap>
  8013e2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8013eb:	6a 00                	push   $0x0
  8013ed:	e8 0b ee ff ff       	call   8001fd <sys_page_unmap>
  8013f2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013fb:	6a 00                	push   $0x0
  8013fd:	e8 fb ed ff ff       	call   8001fd <sys_page_unmap>
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801407:	89 d0                	mov    %edx,%eax
  801409:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140c:	5b                   	pop    %ebx
  80140d:	5e                   	pop    %esi
  80140e:	5d                   	pop    %ebp
  80140f:	c3                   	ret    

00801410 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801416:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801419:	50                   	push   %eax
  80141a:	ff 75 08             	pushl  0x8(%ebp)
  80141d:	e8 1b f5 ff ff       	call   80093d <fd_lookup>
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	85 c0                	test   %eax,%eax
  801427:	78 18                	js     801441 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801429:	83 ec 0c             	sub    $0xc,%esp
  80142c:	ff 75 f4             	pushl  -0xc(%ebp)
  80142f:	e8 a3 f4 ff ff       	call   8008d7 <fd2data>
	return _pipeisclosed(fd, p);
  801434:	89 c2                	mov    %eax,%edx
  801436:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801439:	e8 18 fd ff ff       	call   801156 <_pipeisclosed>
  80143e:	83 c4 10             	add    $0x10,%esp
}
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801446:	b8 00 00 00 00       	mov    $0x0,%eax
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    

0080144d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801453:	68 a2 25 80 00       	push   $0x8025a2
  801458:	ff 75 0c             	pushl  0xc(%ebp)
  80145b:	e8 c4 07 00 00       	call   801c24 <strcpy>
	return 0;
}
  801460:	b8 00 00 00 00       	mov    $0x0,%eax
  801465:	c9                   	leave  
  801466:	c3                   	ret    

00801467 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	57                   	push   %edi
  80146b:	56                   	push   %esi
  80146c:	53                   	push   %ebx
  80146d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801473:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801478:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80147e:	eb 2d                	jmp    8014ad <devcons_write+0x46>
		m = n - tot;
  801480:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801483:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801485:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801488:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80148d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801490:	83 ec 04             	sub    $0x4,%esp
  801493:	53                   	push   %ebx
  801494:	03 45 0c             	add    0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	57                   	push   %edi
  801499:	e8 18 09 00 00       	call   801db6 <memmove>
		sys_cputs(buf, m);
  80149e:	83 c4 08             	add    $0x8,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	57                   	push   %edi
  8014a3:	e8 14 ec ff ff       	call   8000bc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014a8:	01 de                	add    %ebx,%esi
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	89 f0                	mov    %esi,%eax
  8014af:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014b2:	72 cc                	jb     801480 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5f                   	pop    %edi
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014cb:	74 2a                	je     8014f7 <devcons_read+0x3b>
  8014cd:	eb 05                	jmp    8014d4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014cf:	e8 85 ec ff ff       	call   800159 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014d4:	e8 01 ec ff ff       	call   8000da <sys_cgetc>
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	74 f2                	je     8014cf <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 16                	js     8014f7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014e1:	83 f8 04             	cmp    $0x4,%eax
  8014e4:	74 0c                	je     8014f2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e9:	88 02                	mov    %al,(%edx)
	return 1;
  8014eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f0:	eb 05                	jmp    8014f7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014f2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801502:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801505:	6a 01                	push   $0x1
  801507:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80150a:	50                   	push   %eax
  80150b:	e8 ac eb ff ff       	call   8000bc <sys_cputs>
}
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <getchar>:

int
getchar(void)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80151b:	6a 01                	push   $0x1
  80151d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801520:	50                   	push   %eax
  801521:	6a 00                	push   $0x0
  801523:	e8 7e f6 ff ff       	call   800ba6 <read>
	if (r < 0)
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 0f                	js     80153e <getchar+0x29>
		return r;
	if (r < 1)
  80152f:	85 c0                	test   %eax,%eax
  801531:	7e 06                	jle    801539 <getchar+0x24>
		return -E_EOF;
	return c;
  801533:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801537:	eb 05                	jmp    80153e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801539:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80153e:	c9                   	leave  
  80153f:	c3                   	ret    

00801540 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801546:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801549:	50                   	push   %eax
  80154a:	ff 75 08             	pushl  0x8(%ebp)
  80154d:	e8 eb f3 ff ff       	call   80093d <fd_lookup>
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 11                	js     80156a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801559:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801562:	39 10                	cmp    %edx,(%eax)
  801564:	0f 94 c0             	sete   %al
  801567:	0f b6 c0             	movzbl %al,%eax
}
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <opencons>:

int
opencons(void)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801572:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801575:	50                   	push   %eax
  801576:	e8 73 f3 ff ff       	call   8008ee <fd_alloc>
  80157b:	83 c4 10             	add    $0x10,%esp
		return r;
  80157e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801580:	85 c0                	test   %eax,%eax
  801582:	78 3e                	js     8015c2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	68 07 04 00 00       	push   $0x407
  80158c:	ff 75 f4             	pushl  -0xc(%ebp)
  80158f:	6a 00                	push   $0x0
  801591:	e8 e2 eb ff ff       	call   800178 <sys_page_alloc>
  801596:	83 c4 10             	add    $0x10,%esp
		return r;
  801599:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80159b:	85 c0                	test   %eax,%eax
  80159d:	78 23                	js     8015c2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80159f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ad:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	50                   	push   %eax
  8015b8:	e8 0a f3 ff ff       	call   8008c7 <fd2num>
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	83 c4 10             	add    $0x10,%esp
}
  8015c2:	89 d0                	mov    %edx,%eax
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	56                   	push   %esi
  8015ca:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015cb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015ce:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015d4:	e8 61 eb ff ff       	call   80013a <sys_getenvid>
  8015d9:	83 ec 0c             	sub    $0xc,%esp
  8015dc:	ff 75 0c             	pushl  0xc(%ebp)
  8015df:	ff 75 08             	pushl  0x8(%ebp)
  8015e2:	56                   	push   %esi
  8015e3:	50                   	push   %eax
  8015e4:	68 b0 25 80 00       	push   $0x8025b0
  8015e9:	e8 b1 00 00 00       	call   80169f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015ee:	83 c4 18             	add    $0x18,%esp
  8015f1:	53                   	push   %ebx
  8015f2:	ff 75 10             	pushl  0x10(%ebp)
  8015f5:	e8 54 00 00 00       	call   80164e <vcprintf>
	cprintf("\n");
  8015fa:	c7 04 24 a6 24 80 00 	movl   $0x8024a6,(%esp)
  801601:	e8 99 00 00 00       	call   80169f <cprintf>
  801606:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801609:	cc                   	int3   
  80160a:	eb fd                	jmp    801609 <_panic+0x43>

0080160c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	53                   	push   %ebx
  801610:	83 ec 04             	sub    $0x4,%esp
  801613:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801616:	8b 13                	mov    (%ebx),%edx
  801618:	8d 42 01             	lea    0x1(%edx),%eax
  80161b:	89 03                	mov    %eax,(%ebx)
  80161d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801620:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801624:	3d ff 00 00 00       	cmp    $0xff,%eax
  801629:	75 1a                	jne    801645 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	68 ff 00 00 00       	push   $0xff
  801633:	8d 43 08             	lea    0x8(%ebx),%eax
  801636:	50                   	push   %eax
  801637:	e8 80 ea ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  80163c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801642:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801645:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801649:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80164e:	55                   	push   %ebp
  80164f:	89 e5                	mov    %esp,%ebp
  801651:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801657:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80165e:	00 00 00 
	b.cnt = 0;
  801661:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801668:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80166b:	ff 75 0c             	pushl  0xc(%ebp)
  80166e:	ff 75 08             	pushl  0x8(%ebp)
  801671:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	68 0c 16 80 00       	push   $0x80160c
  80167d:	e8 54 01 00 00       	call   8017d6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801682:	83 c4 08             	add    $0x8,%esp
  801685:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80168b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	e8 25 ea ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  801697:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016a5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016a8:	50                   	push   %eax
  8016a9:	ff 75 08             	pushl  0x8(%ebp)
  8016ac:	e8 9d ff ff ff       	call   80164e <vcprintf>
	va_end(ap);

	return cnt;
}
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	57                   	push   %edi
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 1c             	sub    $0x1c,%esp
  8016bc:	89 c7                	mov    %eax,%edi
  8016be:	89 d6                	mov    %edx,%esi
  8016c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016cc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016d7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016da:	39 d3                	cmp    %edx,%ebx
  8016dc:	72 05                	jb     8016e3 <printnum+0x30>
  8016de:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016e1:	77 45                	ja     801728 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016e3:	83 ec 0c             	sub    $0xc,%esp
  8016e6:	ff 75 18             	pushl  0x18(%ebp)
  8016e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8016ec:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016ef:	53                   	push   %ebx
  8016f0:	ff 75 10             	pushl  0x10(%ebp)
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8016fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8016ff:	ff 75 d8             	pushl  -0x28(%ebp)
  801702:	e8 59 0a 00 00       	call   802160 <__udivdi3>
  801707:	83 c4 18             	add    $0x18,%esp
  80170a:	52                   	push   %edx
  80170b:	50                   	push   %eax
  80170c:	89 f2                	mov    %esi,%edx
  80170e:	89 f8                	mov    %edi,%eax
  801710:	e8 9e ff ff ff       	call   8016b3 <printnum>
  801715:	83 c4 20             	add    $0x20,%esp
  801718:	eb 18                	jmp    801732 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	56                   	push   %esi
  80171e:	ff 75 18             	pushl  0x18(%ebp)
  801721:	ff d7                	call   *%edi
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	eb 03                	jmp    80172b <printnum+0x78>
  801728:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80172b:	83 eb 01             	sub    $0x1,%ebx
  80172e:	85 db                	test   %ebx,%ebx
  801730:	7f e8                	jg     80171a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	56                   	push   %esi
  801736:	83 ec 04             	sub    $0x4,%esp
  801739:	ff 75 e4             	pushl  -0x1c(%ebp)
  80173c:	ff 75 e0             	pushl  -0x20(%ebp)
  80173f:	ff 75 dc             	pushl  -0x24(%ebp)
  801742:	ff 75 d8             	pushl  -0x28(%ebp)
  801745:	e8 46 0b 00 00       	call   802290 <__umoddi3>
  80174a:	83 c4 14             	add    $0x14,%esp
  80174d:	0f be 80 d3 25 80 00 	movsbl 0x8025d3(%eax),%eax
  801754:	50                   	push   %eax
  801755:	ff d7                	call   *%edi
}
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5f                   	pop    %edi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801765:	83 fa 01             	cmp    $0x1,%edx
  801768:	7e 0e                	jle    801778 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80176a:	8b 10                	mov    (%eax),%edx
  80176c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80176f:	89 08                	mov    %ecx,(%eax)
  801771:	8b 02                	mov    (%edx),%eax
  801773:	8b 52 04             	mov    0x4(%edx),%edx
  801776:	eb 22                	jmp    80179a <getuint+0x38>
	else if (lflag)
  801778:	85 d2                	test   %edx,%edx
  80177a:	74 10                	je     80178c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80177c:	8b 10                	mov    (%eax),%edx
  80177e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801781:	89 08                	mov    %ecx,(%eax)
  801783:	8b 02                	mov    (%edx),%eax
  801785:	ba 00 00 00 00       	mov    $0x0,%edx
  80178a:	eb 0e                	jmp    80179a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80178c:	8b 10                	mov    (%eax),%edx
  80178e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801791:	89 08                	mov    %ecx,(%eax)
  801793:	8b 02                	mov    (%edx),%eax
  801795:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80179a:	5d                   	pop    %ebp
  80179b:	c3                   	ret    

0080179c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80179c:	55                   	push   %ebp
  80179d:	89 e5                	mov    %esp,%ebp
  80179f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017a2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017a6:	8b 10                	mov    (%eax),%edx
  8017a8:	3b 50 04             	cmp    0x4(%eax),%edx
  8017ab:	73 0a                	jae    8017b7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017ad:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017b0:	89 08                	mov    %ecx,(%eax)
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	88 02                	mov    %al,(%edx)
}
  8017b7:	5d                   	pop    %ebp
  8017b8:	c3                   	ret    

008017b9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017bf:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017c2:	50                   	push   %eax
  8017c3:	ff 75 10             	pushl  0x10(%ebp)
  8017c6:	ff 75 0c             	pushl  0xc(%ebp)
  8017c9:	ff 75 08             	pushl  0x8(%ebp)
  8017cc:	e8 05 00 00 00       	call   8017d6 <vprintfmt>
	va_end(ap);
}
  8017d1:	83 c4 10             	add    $0x10,%esp
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	57                   	push   %edi
  8017da:	56                   	push   %esi
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 2c             	sub    $0x2c,%esp
  8017df:	8b 75 08             	mov    0x8(%ebp),%esi
  8017e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017e5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017e8:	eb 12                	jmp    8017fc <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017ea:	85 c0                	test   %eax,%eax
  8017ec:	0f 84 89 03 00 00    	je     801b7b <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	53                   	push   %ebx
  8017f6:	50                   	push   %eax
  8017f7:	ff d6                	call   *%esi
  8017f9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017fc:	83 c7 01             	add    $0x1,%edi
  8017ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801803:	83 f8 25             	cmp    $0x25,%eax
  801806:	75 e2                	jne    8017ea <vprintfmt+0x14>
  801808:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80180c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801813:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80181a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801821:	ba 00 00 00 00       	mov    $0x0,%edx
  801826:	eb 07                	jmp    80182f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801828:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80182b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182f:	8d 47 01             	lea    0x1(%edi),%eax
  801832:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801835:	0f b6 07             	movzbl (%edi),%eax
  801838:	0f b6 c8             	movzbl %al,%ecx
  80183b:	83 e8 23             	sub    $0x23,%eax
  80183e:	3c 55                	cmp    $0x55,%al
  801840:	0f 87 1a 03 00 00    	ja     801b60 <vprintfmt+0x38a>
  801846:	0f b6 c0             	movzbl %al,%eax
  801849:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  801850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801853:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801857:	eb d6                	jmp    80182f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801859:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80185c:	b8 00 00 00 00       	mov    $0x0,%eax
  801861:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801864:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801867:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80186b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80186e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801871:	83 fa 09             	cmp    $0x9,%edx
  801874:	77 39                	ja     8018af <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801876:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801879:	eb e9                	jmp    801864 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80187b:	8b 45 14             	mov    0x14(%ebp),%eax
  80187e:	8d 48 04             	lea    0x4(%eax),%ecx
  801881:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801884:	8b 00                	mov    (%eax),%eax
  801886:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801889:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80188c:	eb 27                	jmp    8018b5 <vprintfmt+0xdf>
  80188e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801891:	85 c0                	test   %eax,%eax
  801893:	b9 00 00 00 00       	mov    $0x0,%ecx
  801898:	0f 49 c8             	cmovns %eax,%ecx
  80189b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018a1:	eb 8c                	jmp    80182f <vprintfmt+0x59>
  8018a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018a6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018ad:	eb 80                	jmp    80182f <vprintfmt+0x59>
  8018af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018b2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018b9:	0f 89 70 ff ff ff    	jns    80182f <vprintfmt+0x59>
				width = precision, precision = -1;
  8018bf:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018c5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018cc:	e9 5e ff ff ff       	jmp    80182f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018d1:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018d7:	e9 53 ff ff ff       	jmp    80182f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8018df:	8d 50 04             	lea    0x4(%eax),%edx
  8018e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	53                   	push   %ebx
  8018e9:	ff 30                	pushl  (%eax)
  8018eb:	ff d6                	call   *%esi
			break;
  8018ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018f3:	e9 04 ff ff ff       	jmp    8017fc <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fb:	8d 50 04             	lea    0x4(%eax),%edx
  8018fe:	89 55 14             	mov    %edx,0x14(%ebp)
  801901:	8b 00                	mov    (%eax),%eax
  801903:	99                   	cltd   
  801904:	31 d0                	xor    %edx,%eax
  801906:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801908:	83 f8 0f             	cmp    $0xf,%eax
  80190b:	7f 0b                	jg     801918 <vprintfmt+0x142>
  80190d:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  801914:	85 d2                	test   %edx,%edx
  801916:	75 18                	jne    801930 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801918:	50                   	push   %eax
  801919:	68 eb 25 80 00       	push   $0x8025eb
  80191e:	53                   	push   %ebx
  80191f:	56                   	push   %esi
  801920:	e8 94 fe ff ff       	call   8017b9 <printfmt>
  801925:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801928:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80192b:	e9 cc fe ff ff       	jmp    8017fc <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801930:	52                   	push   %edx
  801931:	68 69 25 80 00       	push   $0x802569
  801936:	53                   	push   %ebx
  801937:	56                   	push   %esi
  801938:	e8 7c fe ff ff       	call   8017b9 <printfmt>
  80193d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801940:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801943:	e9 b4 fe ff ff       	jmp    8017fc <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801948:	8b 45 14             	mov    0x14(%ebp),%eax
  80194b:	8d 50 04             	lea    0x4(%eax),%edx
  80194e:	89 55 14             	mov    %edx,0x14(%ebp)
  801951:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801953:	85 ff                	test   %edi,%edi
  801955:	b8 e4 25 80 00       	mov    $0x8025e4,%eax
  80195a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80195d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801961:	0f 8e 94 00 00 00    	jle    8019fb <vprintfmt+0x225>
  801967:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80196b:	0f 84 98 00 00 00    	je     801a09 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	ff 75 d0             	pushl  -0x30(%ebp)
  801977:	57                   	push   %edi
  801978:	e8 86 02 00 00       	call   801c03 <strnlen>
  80197d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801980:	29 c1                	sub    %eax,%ecx
  801982:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801985:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801988:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80198c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80198f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801992:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801994:	eb 0f                	jmp    8019a5 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801996:	83 ec 08             	sub    $0x8,%esp
  801999:	53                   	push   %ebx
  80199a:	ff 75 e0             	pushl  -0x20(%ebp)
  80199d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80199f:	83 ef 01             	sub    $0x1,%edi
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	85 ff                	test   %edi,%edi
  8019a7:	7f ed                	jg     801996 <vprintfmt+0x1c0>
  8019a9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019ac:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019af:	85 c9                	test   %ecx,%ecx
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b6:	0f 49 c1             	cmovns %ecx,%eax
  8019b9:	29 c1                	sub    %eax,%ecx
  8019bb:	89 75 08             	mov    %esi,0x8(%ebp)
  8019be:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019c4:	89 cb                	mov    %ecx,%ebx
  8019c6:	eb 4d                	jmp    801a15 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019c8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019cc:	74 1b                	je     8019e9 <vprintfmt+0x213>
  8019ce:	0f be c0             	movsbl %al,%eax
  8019d1:	83 e8 20             	sub    $0x20,%eax
  8019d4:	83 f8 5e             	cmp    $0x5e,%eax
  8019d7:	76 10                	jbe    8019e9 <vprintfmt+0x213>
					putch('?', putdat);
  8019d9:	83 ec 08             	sub    $0x8,%esp
  8019dc:	ff 75 0c             	pushl  0xc(%ebp)
  8019df:	6a 3f                	push   $0x3f
  8019e1:	ff 55 08             	call   *0x8(%ebp)
  8019e4:	83 c4 10             	add    $0x10,%esp
  8019e7:	eb 0d                	jmp    8019f6 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019e9:	83 ec 08             	sub    $0x8,%esp
  8019ec:	ff 75 0c             	pushl  0xc(%ebp)
  8019ef:	52                   	push   %edx
  8019f0:	ff 55 08             	call   *0x8(%ebp)
  8019f3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019f6:	83 eb 01             	sub    $0x1,%ebx
  8019f9:	eb 1a                	jmp    801a15 <vprintfmt+0x23f>
  8019fb:	89 75 08             	mov    %esi,0x8(%ebp)
  8019fe:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a01:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a04:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a07:	eb 0c                	jmp    801a15 <vprintfmt+0x23f>
  801a09:	89 75 08             	mov    %esi,0x8(%ebp)
  801a0c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a0f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a12:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a15:	83 c7 01             	add    $0x1,%edi
  801a18:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a1c:	0f be d0             	movsbl %al,%edx
  801a1f:	85 d2                	test   %edx,%edx
  801a21:	74 23                	je     801a46 <vprintfmt+0x270>
  801a23:	85 f6                	test   %esi,%esi
  801a25:	78 a1                	js     8019c8 <vprintfmt+0x1f2>
  801a27:	83 ee 01             	sub    $0x1,%esi
  801a2a:	79 9c                	jns    8019c8 <vprintfmt+0x1f2>
  801a2c:	89 df                	mov    %ebx,%edi
  801a2e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a34:	eb 18                	jmp    801a4e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a36:	83 ec 08             	sub    $0x8,%esp
  801a39:	53                   	push   %ebx
  801a3a:	6a 20                	push   $0x20
  801a3c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a3e:	83 ef 01             	sub    $0x1,%edi
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	eb 08                	jmp    801a4e <vprintfmt+0x278>
  801a46:	89 df                	mov    %ebx,%edi
  801a48:	8b 75 08             	mov    0x8(%ebp),%esi
  801a4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a4e:	85 ff                	test   %edi,%edi
  801a50:	7f e4                	jg     801a36 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a55:	e9 a2 fd ff ff       	jmp    8017fc <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a5a:	83 fa 01             	cmp    $0x1,%edx
  801a5d:	7e 16                	jle    801a75 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a5f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a62:	8d 50 08             	lea    0x8(%eax),%edx
  801a65:	89 55 14             	mov    %edx,0x14(%ebp)
  801a68:	8b 50 04             	mov    0x4(%eax),%edx
  801a6b:	8b 00                	mov    (%eax),%eax
  801a6d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a70:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a73:	eb 32                	jmp    801aa7 <vprintfmt+0x2d1>
	else if (lflag)
  801a75:	85 d2                	test   %edx,%edx
  801a77:	74 18                	je     801a91 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a79:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7c:	8d 50 04             	lea    0x4(%eax),%edx
  801a7f:	89 55 14             	mov    %edx,0x14(%ebp)
  801a82:	8b 00                	mov    (%eax),%eax
  801a84:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a87:	89 c1                	mov    %eax,%ecx
  801a89:	c1 f9 1f             	sar    $0x1f,%ecx
  801a8c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a8f:	eb 16                	jmp    801aa7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a91:	8b 45 14             	mov    0x14(%ebp),%eax
  801a94:	8d 50 04             	lea    0x4(%eax),%edx
  801a97:	89 55 14             	mov    %edx,0x14(%ebp)
  801a9a:	8b 00                	mov    (%eax),%eax
  801a9c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a9f:	89 c1                	mov    %eax,%ecx
  801aa1:	c1 f9 1f             	sar    $0x1f,%ecx
  801aa4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801aa7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aaa:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801aad:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ab2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ab6:	79 74                	jns    801b2c <vprintfmt+0x356>
				putch('-', putdat);
  801ab8:	83 ec 08             	sub    $0x8,%esp
  801abb:	53                   	push   %ebx
  801abc:	6a 2d                	push   $0x2d
  801abe:	ff d6                	call   *%esi
				num = -(long long) num;
  801ac0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ac3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ac6:	f7 d8                	neg    %eax
  801ac8:	83 d2 00             	adc    $0x0,%edx
  801acb:	f7 da                	neg    %edx
  801acd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801ad0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ad5:	eb 55                	jmp    801b2c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ad7:	8d 45 14             	lea    0x14(%ebp),%eax
  801ada:	e8 83 fc ff ff       	call   801762 <getuint>
			base = 10;
  801adf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ae4:	eb 46                	jmp    801b2c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ae6:	8d 45 14             	lea    0x14(%ebp),%eax
  801ae9:	e8 74 fc ff ff       	call   801762 <getuint>
			base = 8;
  801aee:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801af3:	eb 37                	jmp    801b2c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801af5:	83 ec 08             	sub    $0x8,%esp
  801af8:	53                   	push   %ebx
  801af9:	6a 30                	push   $0x30
  801afb:	ff d6                	call   *%esi
			putch('x', putdat);
  801afd:	83 c4 08             	add    $0x8,%esp
  801b00:	53                   	push   %ebx
  801b01:	6a 78                	push   $0x78
  801b03:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b05:	8b 45 14             	mov    0x14(%ebp),%eax
  801b08:	8d 50 04             	lea    0x4(%eax),%edx
  801b0b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b0e:	8b 00                	mov    (%eax),%eax
  801b10:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b15:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b18:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b1d:	eb 0d                	jmp    801b2c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b1f:	8d 45 14             	lea    0x14(%ebp),%eax
  801b22:	e8 3b fc ff ff       	call   801762 <getuint>
			base = 16;
  801b27:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b2c:	83 ec 0c             	sub    $0xc,%esp
  801b2f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b33:	57                   	push   %edi
  801b34:	ff 75 e0             	pushl  -0x20(%ebp)
  801b37:	51                   	push   %ecx
  801b38:	52                   	push   %edx
  801b39:	50                   	push   %eax
  801b3a:	89 da                	mov    %ebx,%edx
  801b3c:	89 f0                	mov    %esi,%eax
  801b3e:	e8 70 fb ff ff       	call   8016b3 <printnum>
			break;
  801b43:	83 c4 20             	add    $0x20,%esp
  801b46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b49:	e9 ae fc ff ff       	jmp    8017fc <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b4e:	83 ec 08             	sub    $0x8,%esp
  801b51:	53                   	push   %ebx
  801b52:	51                   	push   %ecx
  801b53:	ff d6                	call   *%esi
			break;
  801b55:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b5b:	e9 9c fc ff ff       	jmp    8017fc <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b60:	83 ec 08             	sub    $0x8,%esp
  801b63:	53                   	push   %ebx
  801b64:	6a 25                	push   $0x25
  801b66:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	eb 03                	jmp    801b70 <vprintfmt+0x39a>
  801b6d:	83 ef 01             	sub    $0x1,%edi
  801b70:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b74:	75 f7                	jne    801b6d <vprintfmt+0x397>
  801b76:	e9 81 fc ff ff       	jmp    8017fc <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7e:	5b                   	pop    %ebx
  801b7f:	5e                   	pop    %esi
  801b80:	5f                   	pop    %edi
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	83 ec 18             	sub    $0x18,%esp
  801b89:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b8f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b92:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b96:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ba0:	85 c0                	test   %eax,%eax
  801ba2:	74 26                	je     801bca <vsnprintf+0x47>
  801ba4:	85 d2                	test   %edx,%edx
  801ba6:	7e 22                	jle    801bca <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ba8:	ff 75 14             	pushl  0x14(%ebp)
  801bab:	ff 75 10             	pushl  0x10(%ebp)
  801bae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bb1:	50                   	push   %eax
  801bb2:	68 9c 17 80 00       	push   $0x80179c
  801bb7:	e8 1a fc ff ff       	call   8017d6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bbf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	eb 05                	jmp    801bcf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bcf:	c9                   	leave  
  801bd0:	c3                   	ret    

00801bd1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bd7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bda:	50                   	push   %eax
  801bdb:	ff 75 10             	pushl  0x10(%ebp)
  801bde:	ff 75 0c             	pushl  0xc(%ebp)
  801be1:	ff 75 08             	pushl  0x8(%ebp)
  801be4:	e8 9a ff ff ff       	call   801b83 <vsnprintf>
	va_end(ap);

	return rc;
}
  801be9:	c9                   	leave  
  801bea:	c3                   	ret    

00801beb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf6:	eb 03                	jmp    801bfb <strlen+0x10>
		n++;
  801bf8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bfb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bff:	75 f7                	jne    801bf8 <strlen+0xd>
		n++;
	return n;
}
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c09:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c11:	eb 03                	jmp    801c16 <strnlen+0x13>
		n++;
  801c13:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c16:	39 c2                	cmp    %eax,%edx
  801c18:	74 08                	je     801c22 <strnlen+0x1f>
  801c1a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c1e:	75 f3                	jne    801c13 <strnlen+0x10>
  801c20:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    

00801c24 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	53                   	push   %ebx
  801c28:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c2e:	89 c2                	mov    %eax,%edx
  801c30:	83 c2 01             	add    $0x1,%edx
  801c33:	83 c1 01             	add    $0x1,%ecx
  801c36:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c3a:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c3d:	84 db                	test   %bl,%bl
  801c3f:	75 ef                	jne    801c30 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c41:	5b                   	pop    %ebx
  801c42:	5d                   	pop    %ebp
  801c43:	c3                   	ret    

00801c44 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c44:	55                   	push   %ebp
  801c45:	89 e5                	mov    %esp,%ebp
  801c47:	53                   	push   %ebx
  801c48:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c4b:	53                   	push   %ebx
  801c4c:	e8 9a ff ff ff       	call   801beb <strlen>
  801c51:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c54:	ff 75 0c             	pushl  0xc(%ebp)
  801c57:	01 d8                	add    %ebx,%eax
  801c59:	50                   	push   %eax
  801c5a:	e8 c5 ff ff ff       	call   801c24 <strcpy>
	return dst;
}
  801c5f:	89 d8                	mov    %ebx,%eax
  801c61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c64:	c9                   	leave  
  801c65:	c3                   	ret    

00801c66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	56                   	push   %esi
  801c6a:	53                   	push   %ebx
  801c6b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c71:	89 f3                	mov    %esi,%ebx
  801c73:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c76:	89 f2                	mov    %esi,%edx
  801c78:	eb 0f                	jmp    801c89 <strncpy+0x23>
		*dst++ = *src;
  801c7a:	83 c2 01             	add    $0x1,%edx
  801c7d:	0f b6 01             	movzbl (%ecx),%eax
  801c80:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c83:	80 39 01             	cmpb   $0x1,(%ecx)
  801c86:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c89:	39 da                	cmp    %ebx,%edx
  801c8b:	75 ed                	jne    801c7a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c8d:	89 f0                	mov    %esi,%eax
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5d                   	pop    %ebp
  801c92:	c3                   	ret    

00801c93 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	56                   	push   %esi
  801c97:	53                   	push   %ebx
  801c98:	8b 75 08             	mov    0x8(%ebp),%esi
  801c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9e:	8b 55 10             	mov    0x10(%ebp),%edx
  801ca1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801ca3:	85 d2                	test   %edx,%edx
  801ca5:	74 21                	je     801cc8 <strlcpy+0x35>
  801ca7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801cab:	89 f2                	mov    %esi,%edx
  801cad:	eb 09                	jmp    801cb8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801caf:	83 c2 01             	add    $0x1,%edx
  801cb2:	83 c1 01             	add    $0x1,%ecx
  801cb5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cb8:	39 c2                	cmp    %eax,%edx
  801cba:	74 09                	je     801cc5 <strlcpy+0x32>
  801cbc:	0f b6 19             	movzbl (%ecx),%ebx
  801cbf:	84 db                	test   %bl,%bl
  801cc1:	75 ec                	jne    801caf <strlcpy+0x1c>
  801cc3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cc5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cc8:	29 f0                	sub    %esi,%eax
}
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cd7:	eb 06                	jmp    801cdf <strcmp+0x11>
		p++, q++;
  801cd9:	83 c1 01             	add    $0x1,%ecx
  801cdc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cdf:	0f b6 01             	movzbl (%ecx),%eax
  801ce2:	84 c0                	test   %al,%al
  801ce4:	74 04                	je     801cea <strcmp+0x1c>
  801ce6:	3a 02                	cmp    (%edx),%al
  801ce8:	74 ef                	je     801cd9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cea:	0f b6 c0             	movzbl %al,%eax
  801ced:	0f b6 12             	movzbl (%edx),%edx
  801cf0:	29 d0                	sub    %edx,%eax
}
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    

00801cf4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	53                   	push   %ebx
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cfe:	89 c3                	mov    %eax,%ebx
  801d00:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d03:	eb 06                	jmp    801d0b <strncmp+0x17>
		n--, p++, q++;
  801d05:	83 c0 01             	add    $0x1,%eax
  801d08:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d0b:	39 d8                	cmp    %ebx,%eax
  801d0d:	74 15                	je     801d24 <strncmp+0x30>
  801d0f:	0f b6 08             	movzbl (%eax),%ecx
  801d12:	84 c9                	test   %cl,%cl
  801d14:	74 04                	je     801d1a <strncmp+0x26>
  801d16:	3a 0a                	cmp    (%edx),%cl
  801d18:	74 eb                	je     801d05 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d1a:	0f b6 00             	movzbl (%eax),%eax
  801d1d:	0f b6 12             	movzbl (%edx),%edx
  801d20:	29 d0                	sub    %edx,%eax
  801d22:	eb 05                	jmp    801d29 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d24:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d29:	5b                   	pop    %ebx
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d32:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d36:	eb 07                	jmp    801d3f <strchr+0x13>
		if (*s == c)
  801d38:	38 ca                	cmp    %cl,%dl
  801d3a:	74 0f                	je     801d4b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d3c:	83 c0 01             	add    $0x1,%eax
  801d3f:	0f b6 10             	movzbl (%eax),%edx
  801d42:	84 d2                	test   %dl,%dl
  801d44:	75 f2                	jne    801d38 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    

00801d4d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	8b 45 08             	mov    0x8(%ebp),%eax
  801d53:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d57:	eb 03                	jmp    801d5c <strfind+0xf>
  801d59:	83 c0 01             	add    $0x1,%eax
  801d5c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d5f:	38 ca                	cmp    %cl,%dl
  801d61:	74 04                	je     801d67 <strfind+0x1a>
  801d63:	84 d2                	test   %dl,%dl
  801d65:	75 f2                	jne    801d59 <strfind+0xc>
			break;
	return (char *) s;
}
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	57                   	push   %edi
  801d6d:	56                   	push   %esi
  801d6e:	53                   	push   %ebx
  801d6f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d72:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d75:	85 c9                	test   %ecx,%ecx
  801d77:	74 36                	je     801daf <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d79:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d7f:	75 28                	jne    801da9 <memset+0x40>
  801d81:	f6 c1 03             	test   $0x3,%cl
  801d84:	75 23                	jne    801da9 <memset+0x40>
		c &= 0xFF;
  801d86:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d8a:	89 d3                	mov    %edx,%ebx
  801d8c:	c1 e3 08             	shl    $0x8,%ebx
  801d8f:	89 d6                	mov    %edx,%esi
  801d91:	c1 e6 18             	shl    $0x18,%esi
  801d94:	89 d0                	mov    %edx,%eax
  801d96:	c1 e0 10             	shl    $0x10,%eax
  801d99:	09 f0                	or     %esi,%eax
  801d9b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d9d:	89 d8                	mov    %ebx,%eax
  801d9f:	09 d0                	or     %edx,%eax
  801da1:	c1 e9 02             	shr    $0x2,%ecx
  801da4:	fc                   	cld    
  801da5:	f3 ab                	rep stos %eax,%es:(%edi)
  801da7:	eb 06                	jmp    801daf <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801da9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dac:	fc                   	cld    
  801dad:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801daf:	89 f8                	mov    %edi,%eax
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5f                   	pop    %edi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	57                   	push   %edi
  801dba:	56                   	push   %esi
  801dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbe:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dc1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dc4:	39 c6                	cmp    %eax,%esi
  801dc6:	73 35                	jae    801dfd <memmove+0x47>
  801dc8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dcb:	39 d0                	cmp    %edx,%eax
  801dcd:	73 2e                	jae    801dfd <memmove+0x47>
		s += n;
		d += n;
  801dcf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dd2:	89 d6                	mov    %edx,%esi
  801dd4:	09 fe                	or     %edi,%esi
  801dd6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801ddc:	75 13                	jne    801df1 <memmove+0x3b>
  801dde:	f6 c1 03             	test   $0x3,%cl
  801de1:	75 0e                	jne    801df1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801de3:	83 ef 04             	sub    $0x4,%edi
  801de6:	8d 72 fc             	lea    -0x4(%edx),%esi
  801de9:	c1 e9 02             	shr    $0x2,%ecx
  801dec:	fd                   	std    
  801ded:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801def:	eb 09                	jmp    801dfa <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801df1:	83 ef 01             	sub    $0x1,%edi
  801df4:	8d 72 ff             	lea    -0x1(%edx),%esi
  801df7:	fd                   	std    
  801df8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801dfa:	fc                   	cld    
  801dfb:	eb 1d                	jmp    801e1a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dfd:	89 f2                	mov    %esi,%edx
  801dff:	09 c2                	or     %eax,%edx
  801e01:	f6 c2 03             	test   $0x3,%dl
  801e04:	75 0f                	jne    801e15 <memmove+0x5f>
  801e06:	f6 c1 03             	test   $0x3,%cl
  801e09:	75 0a                	jne    801e15 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e0b:	c1 e9 02             	shr    $0x2,%ecx
  801e0e:	89 c7                	mov    %eax,%edi
  801e10:	fc                   	cld    
  801e11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e13:	eb 05                	jmp    801e1a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e15:	89 c7                	mov    %eax,%edi
  801e17:	fc                   	cld    
  801e18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e1a:	5e                   	pop    %esi
  801e1b:	5f                   	pop    %edi
  801e1c:	5d                   	pop    %ebp
  801e1d:	c3                   	ret    

00801e1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e21:	ff 75 10             	pushl  0x10(%ebp)
  801e24:	ff 75 0c             	pushl  0xc(%ebp)
  801e27:	ff 75 08             	pushl  0x8(%ebp)
  801e2a:	e8 87 ff ff ff       	call   801db6 <memmove>
}
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	56                   	push   %esi
  801e35:	53                   	push   %ebx
  801e36:	8b 45 08             	mov    0x8(%ebp),%eax
  801e39:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e3c:	89 c6                	mov    %eax,%esi
  801e3e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e41:	eb 1a                	jmp    801e5d <memcmp+0x2c>
		if (*s1 != *s2)
  801e43:	0f b6 08             	movzbl (%eax),%ecx
  801e46:	0f b6 1a             	movzbl (%edx),%ebx
  801e49:	38 d9                	cmp    %bl,%cl
  801e4b:	74 0a                	je     801e57 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e4d:	0f b6 c1             	movzbl %cl,%eax
  801e50:	0f b6 db             	movzbl %bl,%ebx
  801e53:	29 d8                	sub    %ebx,%eax
  801e55:	eb 0f                	jmp    801e66 <memcmp+0x35>
		s1++, s2++;
  801e57:	83 c0 01             	add    $0x1,%eax
  801e5a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e5d:	39 f0                	cmp    %esi,%eax
  801e5f:	75 e2                	jne    801e43 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e66:	5b                   	pop    %ebx
  801e67:	5e                   	pop    %esi
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    

00801e6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	53                   	push   %ebx
  801e6e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e71:	89 c1                	mov    %eax,%ecx
  801e73:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e76:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e7a:	eb 0a                	jmp    801e86 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e7c:	0f b6 10             	movzbl (%eax),%edx
  801e7f:	39 da                	cmp    %ebx,%edx
  801e81:	74 07                	je     801e8a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e83:	83 c0 01             	add    $0x1,%eax
  801e86:	39 c8                	cmp    %ecx,%eax
  801e88:	72 f2                	jb     801e7c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e8a:	5b                   	pop    %ebx
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    

00801e8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	57                   	push   %edi
  801e91:	56                   	push   %esi
  801e92:	53                   	push   %ebx
  801e93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e99:	eb 03                	jmp    801e9e <strtol+0x11>
		s++;
  801e9b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e9e:	0f b6 01             	movzbl (%ecx),%eax
  801ea1:	3c 20                	cmp    $0x20,%al
  801ea3:	74 f6                	je     801e9b <strtol+0xe>
  801ea5:	3c 09                	cmp    $0x9,%al
  801ea7:	74 f2                	je     801e9b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ea9:	3c 2b                	cmp    $0x2b,%al
  801eab:	75 0a                	jne    801eb7 <strtol+0x2a>
		s++;
  801ead:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801eb0:	bf 00 00 00 00       	mov    $0x0,%edi
  801eb5:	eb 11                	jmp    801ec8 <strtol+0x3b>
  801eb7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ebc:	3c 2d                	cmp    $0x2d,%al
  801ebe:	75 08                	jne    801ec8 <strtol+0x3b>
		s++, neg = 1;
  801ec0:	83 c1 01             	add    $0x1,%ecx
  801ec3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ec8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801ece:	75 15                	jne    801ee5 <strtol+0x58>
  801ed0:	80 39 30             	cmpb   $0x30,(%ecx)
  801ed3:	75 10                	jne    801ee5 <strtol+0x58>
  801ed5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ed9:	75 7c                	jne    801f57 <strtol+0xca>
		s += 2, base = 16;
  801edb:	83 c1 02             	add    $0x2,%ecx
  801ede:	bb 10 00 00 00       	mov    $0x10,%ebx
  801ee3:	eb 16                	jmp    801efb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ee5:	85 db                	test   %ebx,%ebx
  801ee7:	75 12                	jne    801efb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ee9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eee:	80 39 30             	cmpb   $0x30,(%ecx)
  801ef1:	75 08                	jne    801efb <strtol+0x6e>
		s++, base = 8;
  801ef3:	83 c1 01             	add    $0x1,%ecx
  801ef6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801efb:	b8 00 00 00 00       	mov    $0x0,%eax
  801f00:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f03:	0f b6 11             	movzbl (%ecx),%edx
  801f06:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f09:	89 f3                	mov    %esi,%ebx
  801f0b:	80 fb 09             	cmp    $0x9,%bl
  801f0e:	77 08                	ja     801f18 <strtol+0x8b>
			dig = *s - '0';
  801f10:	0f be d2             	movsbl %dl,%edx
  801f13:	83 ea 30             	sub    $0x30,%edx
  801f16:	eb 22                	jmp    801f3a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f18:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f1b:	89 f3                	mov    %esi,%ebx
  801f1d:	80 fb 19             	cmp    $0x19,%bl
  801f20:	77 08                	ja     801f2a <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f22:	0f be d2             	movsbl %dl,%edx
  801f25:	83 ea 57             	sub    $0x57,%edx
  801f28:	eb 10                	jmp    801f3a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f2a:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f2d:	89 f3                	mov    %esi,%ebx
  801f2f:	80 fb 19             	cmp    $0x19,%bl
  801f32:	77 16                	ja     801f4a <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f34:	0f be d2             	movsbl %dl,%edx
  801f37:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f3a:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f3d:	7d 0b                	jge    801f4a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f3f:	83 c1 01             	add    $0x1,%ecx
  801f42:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f46:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f48:	eb b9                	jmp    801f03 <strtol+0x76>

	if (endptr)
  801f4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f4e:	74 0d                	je     801f5d <strtol+0xd0>
		*endptr = (char *) s;
  801f50:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f53:	89 0e                	mov    %ecx,(%esi)
  801f55:	eb 06                	jmp    801f5d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f57:	85 db                	test   %ebx,%ebx
  801f59:	74 98                	je     801ef3 <strtol+0x66>
  801f5b:	eb 9e                	jmp    801efb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f5d:	89 c2                	mov    %eax,%edx
  801f5f:	f7 da                	neg    %edx
  801f61:	85 ff                	test   %edi,%edi
  801f63:	0f 45 c2             	cmovne %edx,%eax
}
  801f66:	5b                   	pop    %ebx
  801f67:	5e                   	pop    %esi
  801f68:	5f                   	pop    %edi
  801f69:	5d                   	pop    %ebp
  801f6a:	c3                   	ret    

00801f6b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f6b:	55                   	push   %ebp
  801f6c:	89 e5                	mov    %esp,%ebp
  801f6e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f71:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f78:	75 2a                	jne    801fa4 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f7a:	83 ec 04             	sub    $0x4,%esp
  801f7d:	6a 07                	push   $0x7
  801f7f:	68 00 f0 bf ee       	push   $0xeebff000
  801f84:	6a 00                	push   $0x0
  801f86:	e8 ed e1 ff ff       	call   800178 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f8b:	83 c4 10             	add    $0x10,%esp
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	79 12                	jns    801fa4 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f92:	50                   	push   %eax
  801f93:	68 bd 24 80 00       	push   $0x8024bd
  801f98:	6a 23                	push   $0x23
  801f9a:	68 e0 28 80 00       	push   $0x8028e0
  801f9f:	e8 22 f6 ff ff       	call   8015c6 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa7:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fac:	83 ec 08             	sub    $0x8,%esp
  801faf:	68 d6 1f 80 00       	push   $0x801fd6
  801fb4:	6a 00                	push   $0x0
  801fb6:	e8 08 e3 ff ff       	call   8002c3 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fbb:	83 c4 10             	add    $0x10,%esp
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	79 12                	jns    801fd4 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fc2:	50                   	push   %eax
  801fc3:	68 bd 24 80 00       	push   $0x8024bd
  801fc8:	6a 2c                	push   $0x2c
  801fca:	68 e0 28 80 00       	push   $0x8028e0
  801fcf:	e8 f2 f5 ff ff       	call   8015c6 <_panic>
	}
}
  801fd4:	c9                   	leave  
  801fd5:	c3                   	ret    

00801fd6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fd6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fd7:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fdc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fde:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fe1:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fe5:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fea:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801fee:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801ff0:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801ff3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ff4:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ff7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ff8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ff9:	c3                   	ret    

00801ffa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	56                   	push   %esi
  801ffe:	53                   	push   %ebx
  801fff:	8b 75 08             	mov    0x8(%ebp),%esi
  802002:	8b 45 0c             	mov    0xc(%ebp),%eax
  802005:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802008:	85 c0                	test   %eax,%eax
  80200a:	75 12                	jne    80201e <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80200c:	83 ec 0c             	sub    $0xc,%esp
  80200f:	68 00 00 c0 ee       	push   $0xeec00000
  802014:	e8 0f e3 ff ff       	call   800328 <sys_ipc_recv>
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	eb 0c                	jmp    80202a <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80201e:	83 ec 0c             	sub    $0xc,%esp
  802021:	50                   	push   %eax
  802022:	e8 01 e3 ff ff       	call   800328 <sys_ipc_recv>
  802027:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  80202a:	85 f6                	test   %esi,%esi
  80202c:	0f 95 c1             	setne  %cl
  80202f:	85 db                	test   %ebx,%ebx
  802031:	0f 95 c2             	setne  %dl
  802034:	84 d1                	test   %dl,%cl
  802036:	74 09                	je     802041 <ipc_recv+0x47>
  802038:	89 c2                	mov    %eax,%edx
  80203a:	c1 ea 1f             	shr    $0x1f,%edx
  80203d:	84 d2                	test   %dl,%dl
  80203f:	75 2d                	jne    80206e <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  802041:	85 f6                	test   %esi,%esi
  802043:	74 0d                	je     802052 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802045:	a1 04 40 80 00       	mov    0x804004,%eax
  80204a:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  802050:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  802052:	85 db                	test   %ebx,%ebx
  802054:	74 0d                	je     802063 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802056:	a1 04 40 80 00       	mov    0x804004,%eax
  80205b:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  802061:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802063:	a1 04 40 80 00       	mov    0x804004,%eax
  802068:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80206e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802071:	5b                   	pop    %ebx
  802072:	5e                   	pop    %esi
  802073:	5d                   	pop    %ebp
  802074:	c3                   	ret    

00802075 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802075:	55                   	push   %ebp
  802076:	89 e5                	mov    %esp,%ebp
  802078:	57                   	push   %edi
  802079:	56                   	push   %esi
  80207a:	53                   	push   %ebx
  80207b:	83 ec 0c             	sub    $0xc,%esp
  80207e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802081:	8b 75 0c             	mov    0xc(%ebp),%esi
  802084:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802087:	85 db                	test   %ebx,%ebx
  802089:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80208e:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  802091:	ff 75 14             	pushl  0x14(%ebp)
  802094:	53                   	push   %ebx
  802095:	56                   	push   %esi
  802096:	57                   	push   %edi
  802097:	e8 69 e2 ff ff       	call   800305 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80209c:	89 c2                	mov    %eax,%edx
  80209e:	c1 ea 1f             	shr    $0x1f,%edx
  8020a1:	83 c4 10             	add    $0x10,%esp
  8020a4:	84 d2                	test   %dl,%dl
  8020a6:	74 17                	je     8020bf <ipc_send+0x4a>
  8020a8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020ab:	74 12                	je     8020bf <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020ad:	50                   	push   %eax
  8020ae:	68 ee 28 80 00       	push   $0x8028ee
  8020b3:	6a 47                	push   $0x47
  8020b5:	68 fc 28 80 00       	push   $0x8028fc
  8020ba:	e8 07 f5 ff ff       	call   8015c6 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020bf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c2:	75 07                	jne    8020cb <ipc_send+0x56>
			sys_yield();
  8020c4:	e8 90 e0 ff ff       	call   800159 <sys_yield>
  8020c9:	eb c6                	jmp    802091 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	75 c2                	jne    802091 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020d2:	5b                   	pop    %ebx
  8020d3:	5e                   	pop    %esi
  8020d4:	5f                   	pop    %edi
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    

008020d7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020dd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020e2:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020e8:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ee:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8020f4:	39 ca                	cmp    %ecx,%edx
  8020f6:	75 13                	jne    80210b <ipc_find_env+0x34>
			return envs[i].env_id;
  8020f8:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8020fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802103:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802109:	eb 0f                	jmp    80211a <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80210b:	83 c0 01             	add    $0x1,%eax
  80210e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802113:	75 cd                	jne    8020e2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802115:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    

0080211c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802122:	89 d0                	mov    %edx,%eax
  802124:	c1 e8 16             	shr    $0x16,%eax
  802127:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80212e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802133:	f6 c1 01             	test   $0x1,%cl
  802136:	74 1d                	je     802155 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802138:	c1 ea 0c             	shr    $0xc,%edx
  80213b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802142:	f6 c2 01             	test   $0x1,%dl
  802145:	74 0e                	je     802155 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802147:	c1 ea 0c             	shr    $0xc,%edx
  80214a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802151:	ef 
  802152:	0f b7 c0             	movzwl %ax,%eax
}
  802155:	5d                   	pop    %ebp
  802156:	c3                   	ret    
  802157:	66 90                	xchg   %ax,%ax
  802159:	66 90                	xchg   %ax,%ax
  80215b:	66 90                	xchg   %ax,%ax
  80215d:	66 90                	xchg   %ax,%ax
  80215f:	90                   	nop

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
