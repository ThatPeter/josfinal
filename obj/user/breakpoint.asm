
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
  8000a8:	e8 e4 09 00 00       	call   800a91 <close_all>
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
  80012d:	e8 90 14 00 00       	call   8015c2 <_panic>

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
  8001ae:	e8 0f 14 00 00       	call   8015c2 <_panic>

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
  8001f0:	e8 cd 13 00 00       	call   8015c2 <_panic>

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
  800232:	e8 8b 13 00 00       	call   8015c2 <_panic>

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
  800274:	e8 49 13 00 00       	call   8015c2 <_panic>

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
  8002b6:	e8 07 13 00 00       	call   8015c2 <_panic>
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
  8002f8:	e8 c5 12 00 00       	call   8015c2 <_panic>

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
  80035c:	e8 61 12 00 00       	call   8015c2 <_panic>

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
  8003fb:	e8 c2 11 00 00       	call   8015c2 <_panic>
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
  800425:	e8 98 11 00 00       	call   8015c2 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80042a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800430:	83 ec 04             	sub    $0x4,%esp
  800433:	68 00 10 00 00       	push   $0x1000
  800438:	53                   	push   %ebx
  800439:	68 00 f0 7f 00       	push   $0x7ff000
  80043e:	e8 d7 19 00 00       	call   801e1a <memcpy>

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
  80046d:	e8 50 11 00 00       	call   8015c2 <_panic>
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
  800495:	e8 28 11 00 00       	call   8015c2 <_panic>
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
  8004ad:	e8 b5 1a 00 00       	call   801f67 <set_pgfault_handler>
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
  8004d5:	e8 e8 10 00 00       	call   8015c2 <_panic>
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
  80058e:	e8 2f 10 00 00       	call   8015c2 <_panic>
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
  8005d3:	e8 ea 0f 00 00       	call   8015c2 <_panic>
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
  800601:	e8 bc 0f 00 00       	call   8015c2 <_panic>
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
  80062b:	e8 92 0f 00 00       	call   8015c2 <_panic>
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
  8006eb:	e8 d2 0e 00 00       	call   8015c2 <_panic>
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
  800751:	e8 6c 0e 00 00       	call   8015c2 <_panic>
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
  800762:	53                   	push   %ebx
  800763:	83 ec 04             	sub    $0x4,%esp
  800766:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  800769:	b8 01 00 00 00       	mov    $0x1,%eax
  80076e:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0)) {
  800771:	85 c0                	test   %eax,%eax
  800773:	74 45                	je     8007ba <mutex_lock+0x5b>
		queue_append(sys_getenvid(), &mtx->queue);		
  800775:	e8 c0 f9 ff ff       	call   80013a <sys_getenvid>
  80077a:	83 ec 08             	sub    $0x8,%esp
  80077d:	83 c3 04             	add    $0x4,%ebx
  800780:	53                   	push   %ebx
  800781:	50                   	push   %eax
  800782:	e8 35 ff ff ff       	call   8006bc <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800787:	e8 ae f9 ff ff       	call   80013a <sys_getenvid>
  80078c:	83 c4 08             	add    $0x8,%esp
  80078f:	6a 04                	push   $0x4
  800791:	50                   	push   %eax
  800792:	e8 a8 fa ff ff       	call   80023f <sys_env_set_status>

		if (r < 0) {
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	85 c0                	test   %eax,%eax
  80079c:	79 15                	jns    8007b3 <mutex_lock+0x54>
			panic("%e\n", r);
  80079e:	50                   	push   %eax
  80079f:	68 bd 24 80 00       	push   $0x8024bd
  8007a4:	68 02 01 00 00       	push   $0x102
  8007a9:	68 45 24 80 00       	push   $0x802445
  8007ae:	e8 0f 0e 00 00       	call   8015c2 <_panic>
		}
		sys_yield();
  8007b3:	e8 a1 f9 ff ff       	call   800159 <sys_yield>
  8007b8:	eb 08                	jmp    8007c2 <mutex_lock+0x63>
	} else {
		mtx->owner = sys_getenvid();
  8007ba:	e8 7b f9 ff ff       	call   80013a <sys_getenvid>
  8007bf:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <mutex_unlock>:
/*Odomykanie mutexu - zamena hodnoty locked na 0 (odomknuty), v pripade, ze zoznam
cakajucich nie je prazdny, popne sa env v poradi, nastavi sa ako owner threadu a
tento thread sa nastavi ako runnable, na konci zapauzujeme*/
void 
mutex_unlock(struct Mutex* mtx)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	83 ec 04             	sub    $0x4,%esp
  8007ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	if (mtx->queue.first != NULL) {
  8007d1:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8007d5:	74 36                	je     80080d <mutex_unlock+0x46>
		mtx->owner = queue_pop(&mtx->queue);
  8007d7:	83 ec 0c             	sub    $0xc,%esp
  8007da:	8d 43 04             	lea    0x4(%ebx),%eax
  8007dd:	50                   	push   %eax
  8007de:	e8 4d ff ff ff       	call   800730 <queue_pop>
  8007e3:	89 43 0c             	mov    %eax,0xc(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8007e6:	83 c4 08             	add    $0x8,%esp
  8007e9:	6a 02                	push   $0x2
  8007eb:	50                   	push   %eax
  8007ec:	e8 4e fa ff ff       	call   80023f <sys_env_set_status>
		if (r < 0) {
  8007f1:	83 c4 10             	add    $0x10,%esp
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	79 1d                	jns    800815 <mutex_unlock+0x4e>
			panic("%e\n", r);
  8007f8:	50                   	push   %eax
  8007f9:	68 bd 24 80 00       	push   $0x8024bd
  8007fe:	68 16 01 00 00       	push   $0x116
  800803:	68 45 24 80 00       	push   $0x802445
  800808:	e8 b5 0d 00 00       	call   8015c2 <_panic>
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
  800812:	f0 87 03             	lock xchg %eax,(%ebx)
		}
	} else xchg(&mtx->locked, 0);
	
	//asm volatile("pause"); 	// might be useless here
	sys_yield();
  800815:	e8 3f f9 ff ff       	call   800159 <sys_yield>
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
  800829:	e8 0c f9 ff ff       	call   80013a <sys_getenvid>
  80082e:	83 ec 04             	sub    $0x4,%esp
  800831:	6a 07                	push   $0x7
  800833:	53                   	push   %ebx
  800834:	50                   	push   %eax
  800835:	e8 3e f9 ff ff       	call   800178 <sys_page_alloc>
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	85 c0                	test   %eax,%eax
  80083f:	79 15                	jns    800856 <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800841:	50                   	push   %eax
  800842:	68 a8 24 80 00       	push   $0x8024a8
  800847:	68 23 01 00 00       	push   $0x123
  80084c:	68 45 24 80 00       	push   $0x802445
  800851:	e8 6c 0d 00 00       	call   8015c2 <_panic>
	}	
	mtx->locked = 0;
  800856:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue.first = NULL;
  80085c:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	mtx->queue.last = NULL;
  800863:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	mtx->owner = 0;
  80086a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
}
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <mutex_destroy>:

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (mtx->queue.first != NULL) {
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  80087e:	8d 73 04             	lea    0x4(%ebx),%esi

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  800881:	eb 20                	jmp    8008a3 <mutex_destroy+0x2d>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
  800883:	83 ec 0c             	sub    $0xc,%esp
  800886:	56                   	push   %esi
  800887:	e8 a4 fe ff ff       	call   800730 <queue_pop>
  80088c:	83 c4 08             	add    $0x8,%esp
  80088f:	6a 02                	push   $0x2
  800891:	50                   	push   %eax
  800892:	e8 a8 f9 ff ff       	call   80023f <sys_env_set_status>
		mtx->queue.first = mtx->queue.first->next;
  800897:	8b 43 04             	mov    0x4(%ebx),%eax
  80089a:	8b 40 04             	mov    0x4(%eax),%eax
  80089d:	89 43 04             	mov    %eax,0x4(%ebx)
  8008a0:	83 c4 10             	add    $0x10,%esp

// znici mutex - odstrani vsetky cakajuce thready z queue a nastavi ich ako runnable, vynuluje mutex
void 
mutex_destroy(struct Mutex* mtx)
{
	while (mtx->queue.first != NULL) {
  8008a3:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  8008a7:	75 da                	jne    800883 <mutex_destroy+0xd>
		sys_env_set_status(queue_pop(&mtx->queue), ENV_RUNNABLE);
		mtx->queue.first = mtx->queue.first->next;
	}

	memset(mtx, 0, PGSIZE);
  8008a9:	83 ec 04             	sub    $0x4,%esp
  8008ac:	68 00 10 00 00       	push   $0x1000
  8008b1:	6a 00                	push   $0x0
  8008b3:	53                   	push   %ebx
  8008b4:	e8 ac 14 00 00       	call   801d65 <memset>
	mtx = NULL;
}
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008bf:	5b                   	pop    %ebx
  8008c0:	5e                   	pop    %esi
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	05 00 00 00 30       	add    $0x30000000,%eax
  8008ce:	c1 e8 0c             	shr    $0xc,%eax
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8008de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8008e3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8008f5:	89 c2                	mov    %eax,%edx
  8008f7:	c1 ea 16             	shr    $0x16,%edx
  8008fa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800901:	f6 c2 01             	test   $0x1,%dl
  800904:	74 11                	je     800917 <fd_alloc+0x2d>
  800906:	89 c2                	mov    %eax,%edx
  800908:	c1 ea 0c             	shr    $0xc,%edx
  80090b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800912:	f6 c2 01             	test   $0x1,%dl
  800915:	75 09                	jne    800920 <fd_alloc+0x36>
			*fd_store = fd;
  800917:	89 01                	mov    %eax,(%ecx)
			return 0;
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	eb 17                	jmp    800937 <fd_alloc+0x4d>
  800920:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800925:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80092a:	75 c9                	jne    8008f5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80092c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800932:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80093f:	83 f8 1f             	cmp    $0x1f,%eax
  800942:	77 36                	ja     80097a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800944:	c1 e0 0c             	shl    $0xc,%eax
  800947:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80094c:	89 c2                	mov    %eax,%edx
  80094e:	c1 ea 16             	shr    $0x16,%edx
  800951:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800958:	f6 c2 01             	test   $0x1,%dl
  80095b:	74 24                	je     800981 <fd_lookup+0x48>
  80095d:	89 c2                	mov    %eax,%edx
  80095f:	c1 ea 0c             	shr    $0xc,%edx
  800962:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800969:	f6 c2 01             	test   $0x1,%dl
  80096c:	74 1a                	je     800988 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800971:	89 02                	mov    %eax,(%edx)
	return 0;
  800973:	b8 00 00 00 00       	mov    $0x0,%eax
  800978:	eb 13                	jmp    80098d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80097a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80097f:	eb 0c                	jmp    80098d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800981:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800986:	eb 05                	jmp    80098d <fd_lookup+0x54>
  800988:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	83 ec 08             	sub    $0x8,%esp
  800995:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800998:	ba 40 25 80 00       	mov    $0x802540,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80099d:	eb 13                	jmp    8009b2 <dev_lookup+0x23>
  80099f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8009a2:	39 08                	cmp    %ecx,(%eax)
  8009a4:	75 0c                	jne    8009b2 <dev_lookup+0x23>
			*dev = devtab[i];
  8009a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b0:	eb 31                	jmp    8009e3 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8009b2:	8b 02                	mov    (%edx),%eax
  8009b4:	85 c0                	test   %eax,%eax
  8009b6:	75 e7                	jne    80099f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8009b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8009bd:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  8009c3:	83 ec 04             	sub    $0x4,%esp
  8009c6:	51                   	push   %ecx
  8009c7:	50                   	push   %eax
  8009c8:	68 c4 24 80 00       	push   $0x8024c4
  8009cd:	e8 c9 0c 00 00       	call   80169b <cprintf>
	*dev = 0;
  8009d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8009db:	83 c4 10             	add    $0x10,%esp
  8009de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	83 ec 10             	sub    $0x10,%esp
  8009ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8009f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009f6:	50                   	push   %eax
  8009f7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8009fd:	c1 e8 0c             	shr    $0xc,%eax
  800a00:	50                   	push   %eax
  800a01:	e8 33 ff ff ff       	call   800939 <fd_lookup>
  800a06:	83 c4 08             	add    $0x8,%esp
  800a09:	85 c0                	test   %eax,%eax
  800a0b:	78 05                	js     800a12 <fd_close+0x2d>
	    || fd != fd2)
  800a0d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a10:	74 0c                	je     800a1e <fd_close+0x39>
		return (must_exist ? r : 0);
  800a12:	84 db                	test   %bl,%bl
  800a14:	ba 00 00 00 00       	mov    $0x0,%edx
  800a19:	0f 44 c2             	cmove  %edx,%eax
  800a1c:	eb 41                	jmp    800a5f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800a1e:	83 ec 08             	sub    $0x8,%esp
  800a21:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a24:	50                   	push   %eax
  800a25:	ff 36                	pushl  (%esi)
  800a27:	e8 63 ff ff ff       	call   80098f <dev_lookup>
  800a2c:	89 c3                	mov    %eax,%ebx
  800a2e:	83 c4 10             	add    $0x10,%esp
  800a31:	85 c0                	test   %eax,%eax
  800a33:	78 1a                	js     800a4f <fd_close+0x6a>
		if (dev->dev_close)
  800a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a38:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800a3b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800a40:	85 c0                	test   %eax,%eax
  800a42:	74 0b                	je     800a4f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800a44:	83 ec 0c             	sub    $0xc,%esp
  800a47:	56                   	push   %esi
  800a48:	ff d0                	call   *%eax
  800a4a:	89 c3                	mov    %eax,%ebx
  800a4c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800a4f:	83 ec 08             	sub    $0x8,%esp
  800a52:	56                   	push   %esi
  800a53:	6a 00                	push   $0x0
  800a55:	e8 a3 f7 ff ff       	call   8001fd <sys_page_unmap>
	return r;
  800a5a:	83 c4 10             	add    $0x10,%esp
  800a5d:	89 d8                	mov    %ebx,%eax
}
  800a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a6f:	50                   	push   %eax
  800a70:	ff 75 08             	pushl  0x8(%ebp)
  800a73:	e8 c1 fe ff ff       	call   800939 <fd_lookup>
  800a78:	83 c4 08             	add    $0x8,%esp
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	78 10                	js     800a8f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800a7f:	83 ec 08             	sub    $0x8,%esp
  800a82:	6a 01                	push   $0x1
  800a84:	ff 75 f4             	pushl  -0xc(%ebp)
  800a87:	e8 59 ff ff ff       	call   8009e5 <fd_close>
  800a8c:	83 c4 10             	add    $0x10,%esp
}
  800a8f:	c9                   	leave  
  800a90:	c3                   	ret    

00800a91 <close_all>:

void
close_all(void)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	53                   	push   %ebx
  800a95:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800a98:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800a9d:	83 ec 0c             	sub    $0xc,%esp
  800aa0:	53                   	push   %ebx
  800aa1:	e8 c0 ff ff ff       	call   800a66 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800aa6:	83 c3 01             	add    $0x1,%ebx
  800aa9:	83 c4 10             	add    $0x10,%esp
  800aac:	83 fb 20             	cmp    $0x20,%ebx
  800aaf:	75 ec                	jne    800a9d <close_all+0xc>
		close(i);
}
  800ab1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab4:	c9                   	leave  
  800ab5:	c3                   	ret    

00800ab6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	83 ec 2c             	sub    $0x2c,%esp
  800abf:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ac2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ac5:	50                   	push   %eax
  800ac6:	ff 75 08             	pushl  0x8(%ebp)
  800ac9:	e8 6b fe ff ff       	call   800939 <fd_lookup>
  800ace:	83 c4 08             	add    $0x8,%esp
  800ad1:	85 c0                	test   %eax,%eax
  800ad3:	0f 88 c1 00 00 00    	js     800b9a <dup+0xe4>
		return r;
	close(newfdnum);
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	56                   	push   %esi
  800add:	e8 84 ff ff ff       	call   800a66 <close>

	newfd = INDEX2FD(newfdnum);
  800ae2:	89 f3                	mov    %esi,%ebx
  800ae4:	c1 e3 0c             	shl    $0xc,%ebx
  800ae7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800aed:	83 c4 04             	add    $0x4,%esp
  800af0:	ff 75 e4             	pushl  -0x1c(%ebp)
  800af3:	e8 db fd ff ff       	call   8008d3 <fd2data>
  800af8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800afa:	89 1c 24             	mov    %ebx,(%esp)
  800afd:	e8 d1 fd ff ff       	call   8008d3 <fd2data>
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b08:	89 f8                	mov    %edi,%eax
  800b0a:	c1 e8 16             	shr    $0x16,%eax
  800b0d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b14:	a8 01                	test   $0x1,%al
  800b16:	74 37                	je     800b4f <dup+0x99>
  800b18:	89 f8                	mov    %edi,%eax
  800b1a:	c1 e8 0c             	shr    $0xc,%eax
  800b1d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800b24:	f6 c2 01             	test   $0x1,%dl
  800b27:	74 26                	je     800b4f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b29:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b30:	83 ec 0c             	sub    $0xc,%esp
  800b33:	25 07 0e 00 00       	and    $0xe07,%eax
  800b38:	50                   	push   %eax
  800b39:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b3c:	6a 00                	push   $0x0
  800b3e:	57                   	push   %edi
  800b3f:	6a 00                	push   $0x0
  800b41:	e8 75 f6 ff ff       	call   8001bb <sys_page_map>
  800b46:	89 c7                	mov    %eax,%edi
  800b48:	83 c4 20             	add    $0x20,%esp
  800b4b:	85 c0                	test   %eax,%eax
  800b4d:	78 2e                	js     800b7d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b4f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b52:	89 d0                	mov    %edx,%eax
  800b54:	c1 e8 0c             	shr    $0xc,%eax
  800b57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	25 07 0e 00 00       	and    $0xe07,%eax
  800b66:	50                   	push   %eax
  800b67:	53                   	push   %ebx
  800b68:	6a 00                	push   $0x0
  800b6a:	52                   	push   %edx
  800b6b:	6a 00                	push   $0x0
  800b6d:	e8 49 f6 ff ff       	call   8001bb <sys_page_map>
  800b72:	89 c7                	mov    %eax,%edi
  800b74:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800b77:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b79:	85 ff                	test   %edi,%edi
  800b7b:	79 1d                	jns    800b9a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b7d:	83 ec 08             	sub    $0x8,%esp
  800b80:	53                   	push   %ebx
  800b81:	6a 00                	push   $0x0
  800b83:	e8 75 f6 ff ff       	call   8001fd <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b88:	83 c4 08             	add    $0x8,%esp
  800b8b:	ff 75 d4             	pushl  -0x2c(%ebp)
  800b8e:	6a 00                	push   $0x0
  800b90:	e8 68 f6 ff ff       	call   8001fd <sys_page_unmap>
	return r;
  800b95:	83 c4 10             	add    $0x10,%esp
  800b98:	89 f8                	mov    %edi,%eax
}
  800b9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 14             	sub    $0x14,%esp
  800ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800baf:	50                   	push   %eax
  800bb0:	53                   	push   %ebx
  800bb1:	e8 83 fd ff ff       	call   800939 <fd_lookup>
  800bb6:	83 c4 08             	add    $0x8,%esp
  800bb9:	89 c2                	mov    %eax,%edx
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	78 70                	js     800c2f <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bbf:	83 ec 08             	sub    $0x8,%esp
  800bc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bc5:	50                   	push   %eax
  800bc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc9:	ff 30                	pushl  (%eax)
  800bcb:	e8 bf fd ff ff       	call   80098f <dev_lookup>
  800bd0:	83 c4 10             	add    $0x10,%esp
  800bd3:	85 c0                	test   %eax,%eax
  800bd5:	78 4f                	js     800c26 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800bd7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800bda:	8b 42 08             	mov    0x8(%edx),%eax
  800bdd:	83 e0 03             	and    $0x3,%eax
  800be0:	83 f8 01             	cmp    $0x1,%eax
  800be3:	75 24                	jne    800c09 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800be5:	a1 04 40 80 00       	mov    0x804004,%eax
  800bea:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800bf0:	83 ec 04             	sub    $0x4,%esp
  800bf3:	53                   	push   %ebx
  800bf4:	50                   	push   %eax
  800bf5:	68 05 25 80 00       	push   $0x802505
  800bfa:	e8 9c 0a 00 00       	call   80169b <cprintf>
		return -E_INVAL;
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c07:	eb 26                	jmp    800c2f <read+0x8d>
	}
	if (!dev->dev_read)
  800c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0c:	8b 40 08             	mov    0x8(%eax),%eax
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	74 17                	je     800c2a <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c13:	83 ec 04             	sub    $0x4,%esp
  800c16:	ff 75 10             	pushl  0x10(%ebp)
  800c19:	ff 75 0c             	pushl  0xc(%ebp)
  800c1c:	52                   	push   %edx
  800c1d:	ff d0                	call   *%eax
  800c1f:	89 c2                	mov    %eax,%edx
  800c21:	83 c4 10             	add    $0x10,%esp
  800c24:	eb 09                	jmp    800c2f <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c26:	89 c2                	mov    %eax,%edx
  800c28:	eb 05                	jmp    800c2f <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800c2a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800c2f:	89 d0                	mov    %edx,%eax
  800c31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c42:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4a:	eb 21                	jmp    800c6d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c4c:	83 ec 04             	sub    $0x4,%esp
  800c4f:	89 f0                	mov    %esi,%eax
  800c51:	29 d8                	sub    %ebx,%eax
  800c53:	50                   	push   %eax
  800c54:	89 d8                	mov    %ebx,%eax
  800c56:	03 45 0c             	add    0xc(%ebp),%eax
  800c59:	50                   	push   %eax
  800c5a:	57                   	push   %edi
  800c5b:	e8 42 ff ff ff       	call   800ba2 <read>
		if (m < 0)
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	85 c0                	test   %eax,%eax
  800c65:	78 10                	js     800c77 <readn+0x41>
			return m;
		if (m == 0)
  800c67:	85 c0                	test   %eax,%eax
  800c69:	74 0a                	je     800c75 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c6b:	01 c3                	add    %eax,%ebx
  800c6d:	39 f3                	cmp    %esi,%ebx
  800c6f:	72 db                	jb     800c4c <readn+0x16>
  800c71:	89 d8                	mov    %ebx,%eax
  800c73:	eb 02                	jmp    800c77 <readn+0x41>
  800c75:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	53                   	push   %ebx
  800c83:	83 ec 14             	sub    $0x14,%esp
  800c86:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c89:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c8c:	50                   	push   %eax
  800c8d:	53                   	push   %ebx
  800c8e:	e8 a6 fc ff ff       	call   800939 <fd_lookup>
  800c93:	83 c4 08             	add    $0x8,%esp
  800c96:	89 c2                	mov    %eax,%edx
  800c98:	85 c0                	test   %eax,%eax
  800c9a:	78 6b                	js     800d07 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c9c:	83 ec 08             	sub    $0x8,%esp
  800c9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca2:	50                   	push   %eax
  800ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ca6:	ff 30                	pushl  (%eax)
  800ca8:	e8 e2 fc ff ff       	call   80098f <dev_lookup>
  800cad:	83 c4 10             	add    $0x10,%esp
  800cb0:	85 c0                	test   %eax,%eax
  800cb2:	78 4a                	js     800cfe <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cb7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800cbb:	75 24                	jne    800ce1 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800cbd:	a1 04 40 80 00       	mov    0x804004,%eax
  800cc2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800cc8:	83 ec 04             	sub    $0x4,%esp
  800ccb:	53                   	push   %ebx
  800ccc:	50                   	push   %eax
  800ccd:	68 21 25 80 00       	push   $0x802521
  800cd2:	e8 c4 09 00 00       	call   80169b <cprintf>
		return -E_INVAL;
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800cdf:	eb 26                	jmp    800d07 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ce1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ce4:	8b 52 0c             	mov    0xc(%edx),%edx
  800ce7:	85 d2                	test   %edx,%edx
  800ce9:	74 17                	je     800d02 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800ceb:	83 ec 04             	sub    $0x4,%esp
  800cee:	ff 75 10             	pushl  0x10(%ebp)
  800cf1:	ff 75 0c             	pushl  0xc(%ebp)
  800cf4:	50                   	push   %eax
  800cf5:	ff d2                	call   *%edx
  800cf7:	89 c2                	mov    %eax,%edx
  800cf9:	83 c4 10             	add    $0x10,%esp
  800cfc:	eb 09                	jmp    800d07 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cfe:	89 c2                	mov    %eax,%edx
  800d00:	eb 05                	jmp    800d07 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d02:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d07:	89 d0                	mov    %edx,%eax
  800d09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d0c:	c9                   	leave  
  800d0d:	c3                   	ret    

00800d0e <seek>:

int
seek(int fdnum, off_t offset)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d14:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d17:	50                   	push   %eax
  800d18:	ff 75 08             	pushl  0x8(%ebp)
  800d1b:	e8 19 fc ff ff       	call   800939 <fd_lookup>
  800d20:	83 c4 08             	add    $0x8,%esp
  800d23:	85 c0                	test   %eax,%eax
  800d25:	78 0e                	js     800d35 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800d27:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d2d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800d30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 14             	sub    $0x14,%esp
  800d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d44:	50                   	push   %eax
  800d45:	53                   	push   %ebx
  800d46:	e8 ee fb ff ff       	call   800939 <fd_lookup>
  800d4b:	83 c4 08             	add    $0x8,%esp
  800d4e:	89 c2                	mov    %eax,%edx
  800d50:	85 c0                	test   %eax,%eax
  800d52:	78 68                	js     800dbc <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d54:	83 ec 08             	sub    $0x8,%esp
  800d57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5a:	50                   	push   %eax
  800d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d5e:	ff 30                	pushl  (%eax)
  800d60:	e8 2a fc ff ff       	call   80098f <dev_lookup>
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	78 47                	js     800db3 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d6f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d73:	75 24                	jne    800d99 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d75:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d7a:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  800d80:	83 ec 04             	sub    $0x4,%esp
  800d83:	53                   	push   %ebx
  800d84:	50                   	push   %eax
  800d85:	68 e4 24 80 00       	push   $0x8024e4
  800d8a:	e8 0c 09 00 00       	call   80169b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d97:	eb 23                	jmp    800dbc <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800d99:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d9c:	8b 52 18             	mov    0x18(%edx),%edx
  800d9f:	85 d2                	test   %edx,%edx
  800da1:	74 14                	je     800db7 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800da3:	83 ec 08             	sub    $0x8,%esp
  800da6:	ff 75 0c             	pushl  0xc(%ebp)
  800da9:	50                   	push   %eax
  800daa:	ff d2                	call   *%edx
  800dac:	89 c2                	mov    %eax,%edx
  800dae:	83 c4 10             	add    $0x10,%esp
  800db1:	eb 09                	jmp    800dbc <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800db3:	89 c2                	mov    %eax,%edx
  800db5:	eb 05                	jmp    800dbc <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800db7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800dbc:	89 d0                	mov    %edx,%eax
  800dbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 14             	sub    $0x14,%esp
  800dca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dcd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dd0:	50                   	push   %eax
  800dd1:	ff 75 08             	pushl  0x8(%ebp)
  800dd4:	e8 60 fb ff ff       	call   800939 <fd_lookup>
  800dd9:	83 c4 08             	add    $0x8,%esp
  800ddc:	89 c2                	mov    %eax,%edx
  800dde:	85 c0                	test   %eax,%eax
  800de0:	78 58                	js     800e3a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800de2:	83 ec 08             	sub    $0x8,%esp
  800de5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800de8:	50                   	push   %eax
  800de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dec:	ff 30                	pushl  (%eax)
  800dee:	e8 9c fb ff ff       	call   80098f <dev_lookup>
  800df3:	83 c4 10             	add    $0x10,%esp
  800df6:	85 c0                	test   %eax,%eax
  800df8:	78 37                	js     800e31 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e01:	74 32                	je     800e35 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e03:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e06:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e0d:	00 00 00 
	stat->st_isdir = 0;
  800e10:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e17:	00 00 00 
	stat->st_dev = dev;
  800e1a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800e20:	83 ec 08             	sub    $0x8,%esp
  800e23:	53                   	push   %ebx
  800e24:	ff 75 f0             	pushl  -0x10(%ebp)
  800e27:	ff 50 14             	call   *0x14(%eax)
  800e2a:	89 c2                	mov    %eax,%edx
  800e2c:	83 c4 10             	add    $0x10,%esp
  800e2f:	eb 09                	jmp    800e3a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e31:	89 c2                	mov    %eax,%edx
  800e33:	eb 05                	jmp    800e3a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800e35:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800e3a:	89 d0                	mov    %edx,%eax
  800e3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3f:	c9                   	leave  
  800e40:	c3                   	ret    

00800e41 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e46:	83 ec 08             	sub    $0x8,%esp
  800e49:	6a 00                	push   $0x0
  800e4b:	ff 75 08             	pushl  0x8(%ebp)
  800e4e:	e8 e3 01 00 00       	call   801036 <open>
  800e53:	89 c3                	mov    %eax,%ebx
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	78 1b                	js     800e77 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	ff 75 0c             	pushl  0xc(%ebp)
  800e62:	50                   	push   %eax
  800e63:	e8 5b ff ff ff       	call   800dc3 <fstat>
  800e68:	89 c6                	mov    %eax,%esi
	close(fd);
  800e6a:	89 1c 24             	mov    %ebx,(%esp)
  800e6d:	e8 f4 fb ff ff       	call   800a66 <close>
	return r;
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	89 f0                	mov    %esi,%eax
}
  800e77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7a:	5b                   	pop    %ebx
  800e7b:	5e                   	pop    %esi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
  800e83:	89 c6                	mov    %eax,%esi
  800e85:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800e87:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e8e:	75 12                	jne    800ea2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	6a 01                	push   $0x1
  800e95:	e8 39 12 00 00       	call   8020d3 <ipc_find_env>
  800e9a:	a3 00 40 80 00       	mov    %eax,0x804000
  800e9f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ea2:	6a 07                	push   $0x7
  800ea4:	68 00 50 80 00       	push   $0x805000
  800ea9:	56                   	push   %esi
  800eaa:	ff 35 00 40 80 00    	pushl  0x804000
  800eb0:	e8 bc 11 00 00       	call   802071 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800eb5:	83 c4 0c             	add    $0xc,%esp
  800eb8:	6a 00                	push   $0x0
  800eba:	53                   	push   %ebx
  800ebb:	6a 00                	push   $0x0
  800ebd:	e8 34 11 00 00       	call   801ff6 <ipc_recv>
}
  800ec2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ecf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed2:	8b 40 0c             	mov    0xc(%eax),%eax
  800ed5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ee2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee7:	b8 02 00 00 00       	mov    $0x2,%eax
  800eec:	e8 8d ff ff ff       	call   800e7e <fsipc>
}
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	8b 40 0c             	mov    0xc(%eax),%eax
  800eff:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f04:	ba 00 00 00 00       	mov    $0x0,%edx
  800f09:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0e:	e8 6b ff ff ff       	call   800e7e <fsipc>
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	53                   	push   %ebx
  800f19:	83 ec 04             	sub    $0x4,%esp
  800f1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	8b 40 0c             	mov    0xc(%eax),%eax
  800f25:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2f:	b8 05 00 00 00       	mov    $0x5,%eax
  800f34:	e8 45 ff ff ff       	call   800e7e <fsipc>
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	78 2c                	js     800f69 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f3d:	83 ec 08             	sub    $0x8,%esp
  800f40:	68 00 50 80 00       	push   $0x805000
  800f45:	53                   	push   %ebx
  800f46:	e8 d5 0c 00 00       	call   801c20 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f4b:	a1 80 50 80 00       	mov    0x805080,%eax
  800f50:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f56:	a1 84 50 80 00       	mov    0x805084,%eax
  800f5b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f61:	83 c4 10             	add    $0x10,%esp
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f6c:	c9                   	leave  
  800f6d:	c3                   	ret    

00800f6e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 0c             	sub    $0xc,%esp
  800f74:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f77:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7a:	8b 52 0c             	mov    0xc(%edx),%edx
  800f7d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800f83:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f88:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800f8d:	0f 47 c2             	cmova  %edx,%eax
  800f90:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800f95:	50                   	push   %eax
  800f96:	ff 75 0c             	pushl  0xc(%ebp)
  800f99:	68 08 50 80 00       	push   $0x805008
  800f9e:	e8 0f 0e 00 00       	call   801db2 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800fa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa8:	b8 04 00 00 00       	mov    $0x4,%eax
  800fad:	e8 cc fe ff ff       	call   800e7e <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbf:	8b 40 0c             	mov    0xc(%eax),%eax
  800fc2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fc7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd2:	b8 03 00 00 00       	mov    $0x3,%eax
  800fd7:	e8 a2 fe ff ff       	call   800e7e <fsipc>
  800fdc:	89 c3                	mov    %eax,%ebx
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 4b                	js     80102d <devfile_read+0x79>
		return r;
	assert(r <= n);
  800fe2:	39 c6                	cmp    %eax,%esi
  800fe4:	73 16                	jae    800ffc <devfile_read+0x48>
  800fe6:	68 50 25 80 00       	push   $0x802550
  800feb:	68 57 25 80 00       	push   $0x802557
  800ff0:	6a 7c                	push   $0x7c
  800ff2:	68 6c 25 80 00       	push   $0x80256c
  800ff7:	e8 c6 05 00 00       	call   8015c2 <_panic>
	assert(r <= PGSIZE);
  800ffc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801001:	7e 16                	jle    801019 <devfile_read+0x65>
  801003:	68 77 25 80 00       	push   $0x802577
  801008:	68 57 25 80 00       	push   $0x802557
  80100d:	6a 7d                	push   $0x7d
  80100f:	68 6c 25 80 00       	push   $0x80256c
  801014:	e8 a9 05 00 00       	call   8015c2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801019:	83 ec 04             	sub    $0x4,%esp
  80101c:	50                   	push   %eax
  80101d:	68 00 50 80 00       	push   $0x805000
  801022:	ff 75 0c             	pushl  0xc(%ebp)
  801025:	e8 88 0d 00 00       	call   801db2 <memmove>
	return r;
  80102a:	83 c4 10             	add    $0x10,%esp
}
  80102d:	89 d8                	mov    %ebx,%eax
  80102f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801032:	5b                   	pop    %ebx
  801033:	5e                   	pop    %esi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	53                   	push   %ebx
  80103a:	83 ec 20             	sub    $0x20,%esp
  80103d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801040:	53                   	push   %ebx
  801041:	e8 a1 0b 00 00       	call   801be7 <strlen>
  801046:	83 c4 10             	add    $0x10,%esp
  801049:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80104e:	7f 67                	jg     8010b7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801050:	83 ec 0c             	sub    $0xc,%esp
  801053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801056:	50                   	push   %eax
  801057:	e8 8e f8 ff ff       	call   8008ea <fd_alloc>
  80105c:	83 c4 10             	add    $0x10,%esp
		return r;
  80105f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801061:	85 c0                	test   %eax,%eax
  801063:	78 57                	js     8010bc <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801065:	83 ec 08             	sub    $0x8,%esp
  801068:	53                   	push   %ebx
  801069:	68 00 50 80 00       	push   $0x805000
  80106e:	e8 ad 0b 00 00       	call   801c20 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801073:	8b 45 0c             	mov    0xc(%ebp),%eax
  801076:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80107b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80107e:	b8 01 00 00 00       	mov    $0x1,%eax
  801083:	e8 f6 fd ff ff       	call   800e7e <fsipc>
  801088:	89 c3                	mov    %eax,%ebx
  80108a:	83 c4 10             	add    $0x10,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	79 14                	jns    8010a5 <open+0x6f>
		fd_close(fd, 0);
  801091:	83 ec 08             	sub    $0x8,%esp
  801094:	6a 00                	push   $0x0
  801096:	ff 75 f4             	pushl  -0xc(%ebp)
  801099:	e8 47 f9 ff ff       	call   8009e5 <fd_close>
		return r;
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	89 da                	mov    %ebx,%edx
  8010a3:	eb 17                	jmp    8010bc <open+0x86>
	}

	return fd2num(fd);
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ab:	e8 13 f8 ff ff       	call   8008c3 <fd2num>
  8010b0:	89 c2                	mov    %eax,%edx
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	eb 05                	jmp    8010bc <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010b7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010bc:	89 d0                	mov    %edx,%eax
  8010be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    

008010c3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ce:	b8 08 00 00 00       	mov    $0x8,%eax
  8010d3:	e8 a6 fd ff ff       	call   800e7e <fsipc>
}
  8010d8:	c9                   	leave  
  8010d9:	c3                   	ret    

008010da <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8010da:	55                   	push   %ebp
  8010db:	89 e5                	mov    %esp,%ebp
  8010dd:	56                   	push   %esi
  8010de:	53                   	push   %ebx
  8010df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8010e2:	83 ec 0c             	sub    $0xc,%esp
  8010e5:	ff 75 08             	pushl  0x8(%ebp)
  8010e8:	e8 e6 f7 ff ff       	call   8008d3 <fd2data>
  8010ed:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8010ef:	83 c4 08             	add    $0x8,%esp
  8010f2:	68 83 25 80 00       	push   $0x802583
  8010f7:	53                   	push   %ebx
  8010f8:	e8 23 0b 00 00       	call   801c20 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8010fd:	8b 46 04             	mov    0x4(%esi),%eax
  801100:	2b 06                	sub    (%esi),%eax
  801102:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801108:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80110f:	00 00 00 
	stat->st_dev = &devpipe;
  801112:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801119:	30 80 00 
	return 0;
}
  80111c:	b8 00 00 00 00       	mov    $0x0,%eax
  801121:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801124:	5b                   	pop    %ebx
  801125:	5e                   	pop    %esi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	53                   	push   %ebx
  80112c:	83 ec 0c             	sub    $0xc,%esp
  80112f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801132:	53                   	push   %ebx
  801133:	6a 00                	push   $0x0
  801135:	e8 c3 f0 ff ff       	call   8001fd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80113a:	89 1c 24             	mov    %ebx,(%esp)
  80113d:	e8 91 f7 ff ff       	call   8008d3 <fd2data>
  801142:	83 c4 08             	add    $0x8,%esp
  801145:	50                   	push   %eax
  801146:	6a 00                	push   $0x0
  801148:	e8 b0 f0 ff ff       	call   8001fd <sys_page_unmap>
}
  80114d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801150:	c9                   	leave  
  801151:	c3                   	ret    

00801152 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	57                   	push   %edi
  801156:	56                   	push   %esi
  801157:	53                   	push   %ebx
  801158:	83 ec 1c             	sub    $0x1c,%esp
  80115b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80115e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801160:	a1 04 40 80 00       	mov    0x804004,%eax
  801165:	8b b0 b0 00 00 00    	mov    0xb0(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80116b:	83 ec 0c             	sub    $0xc,%esp
  80116e:	ff 75 e0             	pushl  -0x20(%ebp)
  801171:	e8 a2 0f 00 00       	call   802118 <pageref>
  801176:	89 c3                	mov    %eax,%ebx
  801178:	89 3c 24             	mov    %edi,(%esp)
  80117b:	e8 98 0f 00 00       	call   802118 <pageref>
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	39 c3                	cmp    %eax,%ebx
  801185:	0f 94 c1             	sete   %cl
  801188:	0f b6 c9             	movzbl %cl,%ecx
  80118b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80118e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801194:	8b 8a b0 00 00 00    	mov    0xb0(%edx),%ecx
		if (n == nn)
  80119a:	39 ce                	cmp    %ecx,%esi
  80119c:	74 1e                	je     8011bc <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  80119e:	39 c3                	cmp    %eax,%ebx
  8011a0:	75 be                	jne    801160 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8011a2:	8b 82 b0 00 00 00    	mov    0xb0(%edx),%eax
  8011a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ab:	50                   	push   %eax
  8011ac:	56                   	push   %esi
  8011ad:	68 8a 25 80 00       	push   $0x80258a
  8011b2:	e8 e4 04 00 00       	call   80169b <cprintf>
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	eb a4                	jmp    801160 <_pipeisclosed+0xe>
	}
}
  8011bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	57                   	push   %edi
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 28             	sub    $0x28,%esp
  8011d0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8011d3:	56                   	push   %esi
  8011d4:	e8 fa f6 ff ff       	call   8008d3 <fd2data>
  8011d9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	bf 00 00 00 00       	mov    $0x0,%edi
  8011e3:	eb 4b                	jmp    801230 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8011e5:	89 da                	mov    %ebx,%edx
  8011e7:	89 f0                	mov    %esi,%eax
  8011e9:	e8 64 ff ff ff       	call   801152 <_pipeisclosed>
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	75 48                	jne    80123a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8011f2:	e8 62 ef ff ff       	call   800159 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8011f7:	8b 43 04             	mov    0x4(%ebx),%eax
  8011fa:	8b 0b                	mov    (%ebx),%ecx
  8011fc:	8d 51 20             	lea    0x20(%ecx),%edx
  8011ff:	39 d0                	cmp    %edx,%eax
  801201:	73 e2                	jae    8011e5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801203:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801206:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80120a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	c1 fa 1f             	sar    $0x1f,%edx
  801212:	89 d1                	mov    %edx,%ecx
  801214:	c1 e9 1b             	shr    $0x1b,%ecx
  801217:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80121a:	83 e2 1f             	and    $0x1f,%edx
  80121d:	29 ca                	sub    %ecx,%edx
  80121f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801223:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801227:	83 c0 01             	add    $0x1,%eax
  80122a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80122d:	83 c7 01             	add    $0x1,%edi
  801230:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801233:	75 c2                	jne    8011f7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801235:	8b 45 10             	mov    0x10(%ebp),%eax
  801238:	eb 05                	jmp    80123f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80123f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801242:	5b                   	pop    %ebx
  801243:	5e                   	pop    %esi
  801244:	5f                   	pop    %edi
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    

00801247 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	57                   	push   %edi
  80124b:	56                   	push   %esi
  80124c:	53                   	push   %ebx
  80124d:	83 ec 18             	sub    $0x18,%esp
  801250:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801253:	57                   	push   %edi
  801254:	e8 7a f6 ff ff       	call   8008d3 <fd2data>
  801259:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801263:	eb 3d                	jmp    8012a2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801265:	85 db                	test   %ebx,%ebx
  801267:	74 04                	je     80126d <devpipe_read+0x26>
				return i;
  801269:	89 d8                	mov    %ebx,%eax
  80126b:	eb 44                	jmp    8012b1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80126d:	89 f2                	mov    %esi,%edx
  80126f:	89 f8                	mov    %edi,%eax
  801271:	e8 dc fe ff ff       	call   801152 <_pipeisclosed>
  801276:	85 c0                	test   %eax,%eax
  801278:	75 32                	jne    8012ac <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80127a:	e8 da ee ff ff       	call   800159 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80127f:	8b 06                	mov    (%esi),%eax
  801281:	3b 46 04             	cmp    0x4(%esi),%eax
  801284:	74 df                	je     801265 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801286:	99                   	cltd   
  801287:	c1 ea 1b             	shr    $0x1b,%edx
  80128a:	01 d0                	add    %edx,%eax
  80128c:	83 e0 1f             	and    $0x1f,%eax
  80128f:	29 d0                	sub    %edx,%eax
  801291:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801299:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80129c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80129f:	83 c3 01             	add    $0x1,%ebx
  8012a2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8012a5:	75 d8                	jne    80127f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8012a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8012aa:	eb 05                	jmp    8012b1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012ac:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8012b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b4:	5b                   	pop    %ebx
  8012b5:	5e                   	pop    %esi
  8012b6:	5f                   	pop    %edi
  8012b7:	5d                   	pop    %ebp
  8012b8:	c3                   	ret    

008012b9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
  8012bc:	56                   	push   %esi
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8012c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	e8 20 f6 ff ff       	call   8008ea <fd_alloc>
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	89 c2                	mov    %eax,%edx
  8012cf:	85 c0                	test   %eax,%eax
  8012d1:	0f 88 2c 01 00 00    	js     801403 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012d7:	83 ec 04             	sub    $0x4,%esp
  8012da:	68 07 04 00 00       	push   $0x407
  8012df:	ff 75 f4             	pushl  -0xc(%ebp)
  8012e2:	6a 00                	push   $0x0
  8012e4:	e8 8f ee ff ff       	call   800178 <sys_page_alloc>
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	0f 88 0d 01 00 00    	js     801403 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8012f6:	83 ec 0c             	sub    $0xc,%esp
  8012f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fc:	50                   	push   %eax
  8012fd:	e8 e8 f5 ff ff       	call   8008ea <fd_alloc>
  801302:	89 c3                	mov    %eax,%ebx
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	0f 88 e2 00 00 00    	js     8013f1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80130f:	83 ec 04             	sub    $0x4,%esp
  801312:	68 07 04 00 00       	push   $0x407
  801317:	ff 75 f0             	pushl  -0x10(%ebp)
  80131a:	6a 00                	push   $0x0
  80131c:	e8 57 ee ff ff       	call   800178 <sys_page_alloc>
  801321:	89 c3                	mov    %eax,%ebx
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	0f 88 c3 00 00 00    	js     8013f1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	ff 75 f4             	pushl  -0xc(%ebp)
  801334:	e8 9a f5 ff ff       	call   8008d3 <fd2data>
  801339:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80133b:	83 c4 0c             	add    $0xc,%esp
  80133e:	68 07 04 00 00       	push   $0x407
  801343:	50                   	push   %eax
  801344:	6a 00                	push   $0x0
  801346:	e8 2d ee ff ff       	call   800178 <sys_page_alloc>
  80134b:	89 c3                	mov    %eax,%ebx
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	85 c0                	test   %eax,%eax
  801352:	0f 88 89 00 00 00    	js     8013e1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	ff 75 f0             	pushl  -0x10(%ebp)
  80135e:	e8 70 f5 ff ff       	call   8008d3 <fd2data>
  801363:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80136a:	50                   	push   %eax
  80136b:	6a 00                	push   $0x0
  80136d:	56                   	push   %esi
  80136e:	6a 00                	push   $0x0
  801370:	e8 46 ee ff ff       	call   8001bb <sys_page_map>
  801375:	89 c3                	mov    %eax,%ebx
  801377:	83 c4 20             	add    $0x20,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 55                	js     8013d3 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80137e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801384:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801387:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801393:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801399:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8013a8:	83 ec 0c             	sub    $0xc,%esp
  8013ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ae:	e8 10 f5 ff ff       	call   8008c3 <fd2num>
  8013b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8013b8:	83 c4 04             	add    $0x4,%esp
  8013bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8013be:	e8 00 f5 ff ff       	call   8008c3 <fd2num>
  8013c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013c6:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8013c9:	83 c4 10             	add    $0x10,%esp
  8013cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d1:	eb 30                	jmp    801403 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	56                   	push   %esi
  8013d7:	6a 00                	push   $0x0
  8013d9:	e8 1f ee ff ff       	call   8001fd <sys_page_unmap>
  8013de:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e7:	6a 00                	push   $0x0
  8013e9:	e8 0f ee ff ff       	call   8001fd <sys_page_unmap>
  8013ee:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8013f7:	6a 00                	push   $0x0
  8013f9:	e8 ff ed ff ff       	call   8001fd <sys_page_unmap>
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801403:	89 d0                	mov    %edx,%eax
  801405:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801408:	5b                   	pop    %ebx
  801409:	5e                   	pop    %esi
  80140a:	5d                   	pop    %ebp
  80140b:	c3                   	ret    

0080140c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801412:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801415:	50                   	push   %eax
  801416:	ff 75 08             	pushl  0x8(%ebp)
  801419:	e8 1b f5 ff ff       	call   800939 <fd_lookup>
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 18                	js     80143d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	ff 75 f4             	pushl  -0xc(%ebp)
  80142b:	e8 a3 f4 ff ff       	call   8008d3 <fd2data>
	return _pipeisclosed(fd, p);
  801430:	89 c2                	mov    %eax,%edx
  801432:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801435:	e8 18 fd ff ff       	call   801152 <_pipeisclosed>
  80143a:	83 c4 10             	add    $0x10,%esp
}
  80143d:	c9                   	leave  
  80143e:	c3                   	ret    

0080143f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80143f:	55                   	push   %ebp
  801440:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801442:	b8 00 00 00 00       	mov    $0x0,%eax
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    

00801449 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80144f:	68 a2 25 80 00       	push   $0x8025a2
  801454:	ff 75 0c             	pushl  0xc(%ebp)
  801457:	e8 c4 07 00 00       	call   801c20 <strcpy>
	return 0;
}
  80145c:	b8 00 00 00 00       	mov    $0x0,%eax
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	57                   	push   %edi
  801467:	56                   	push   %esi
  801468:	53                   	push   %ebx
  801469:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80146f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801474:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80147a:	eb 2d                	jmp    8014a9 <devcons_write+0x46>
		m = n - tot;
  80147c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80147f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801481:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801484:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801489:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80148c:	83 ec 04             	sub    $0x4,%esp
  80148f:	53                   	push   %ebx
  801490:	03 45 0c             	add    0xc(%ebp),%eax
  801493:	50                   	push   %eax
  801494:	57                   	push   %edi
  801495:	e8 18 09 00 00       	call   801db2 <memmove>
		sys_cputs(buf, m);
  80149a:	83 c4 08             	add    $0x8,%esp
  80149d:	53                   	push   %ebx
  80149e:	57                   	push   %edi
  80149f:	e8 18 ec ff ff       	call   8000bc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014a4:	01 de                	add    %ebx,%esi
  8014a6:	83 c4 10             	add    $0x10,%esp
  8014a9:	89 f0                	mov    %esi,%eax
  8014ab:	3b 75 10             	cmp    0x10(%ebp),%esi
  8014ae:	72 cc                	jb     80147c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8014b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5e                   	pop    %esi
  8014b5:	5f                   	pop    %edi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    

008014b8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8014c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8014c7:	74 2a                	je     8014f3 <devcons_read+0x3b>
  8014c9:	eb 05                	jmp    8014d0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8014cb:	e8 89 ec ff ff       	call   800159 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8014d0:	e8 05 ec ff ff       	call   8000da <sys_cgetc>
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	74 f2                	je     8014cb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 16                	js     8014f3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8014dd:	83 f8 04             	cmp    $0x4,%eax
  8014e0:	74 0c                	je     8014ee <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8014e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e5:	88 02                	mov    %al,(%edx)
	return 1;
  8014e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ec:	eb 05                	jmp    8014f3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8014ee:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014f3:	c9                   	leave  
  8014f4:	c3                   	ret    

008014f5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8014fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801501:	6a 01                	push   $0x1
  801503:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801506:	50                   	push   %eax
  801507:	e8 b0 eb ff ff       	call   8000bc <sys_cputs>
}
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	c9                   	leave  
  801510:	c3                   	ret    

00801511 <getchar>:

int
getchar(void)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801517:	6a 01                	push   $0x1
  801519:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80151c:	50                   	push   %eax
  80151d:	6a 00                	push   $0x0
  80151f:	e8 7e f6 ff ff       	call   800ba2 <read>
	if (r < 0)
  801524:	83 c4 10             	add    $0x10,%esp
  801527:	85 c0                	test   %eax,%eax
  801529:	78 0f                	js     80153a <getchar+0x29>
		return r;
	if (r < 1)
  80152b:	85 c0                	test   %eax,%eax
  80152d:	7e 06                	jle    801535 <getchar+0x24>
		return -E_EOF;
	return c;
  80152f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801533:	eb 05                	jmp    80153a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801535:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801542:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801545:	50                   	push   %eax
  801546:	ff 75 08             	pushl  0x8(%ebp)
  801549:	e8 eb f3 ff ff       	call   800939 <fd_lookup>
  80154e:	83 c4 10             	add    $0x10,%esp
  801551:	85 c0                	test   %eax,%eax
  801553:	78 11                	js     801566 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801555:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801558:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80155e:	39 10                	cmp    %edx,(%eax)
  801560:	0f 94 c0             	sete   %al
  801563:	0f b6 c0             	movzbl %al,%eax
}
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <opencons>:

int
opencons(void)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80156e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	e8 73 f3 ff ff       	call   8008ea <fd_alloc>
  801577:	83 c4 10             	add    $0x10,%esp
		return r;
  80157a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 3e                	js     8015be <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801580:	83 ec 04             	sub    $0x4,%esp
  801583:	68 07 04 00 00       	push   $0x407
  801588:	ff 75 f4             	pushl  -0xc(%ebp)
  80158b:	6a 00                	push   $0x0
  80158d:	e8 e6 eb ff ff       	call   800178 <sys_page_alloc>
  801592:	83 c4 10             	add    $0x10,%esp
		return r;
  801595:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801597:	85 c0                	test   %eax,%eax
  801599:	78 23                	js     8015be <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80159b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8015a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8015b0:	83 ec 0c             	sub    $0xc,%esp
  8015b3:	50                   	push   %eax
  8015b4:	e8 0a f3 ff ff       	call   8008c3 <fd2num>
  8015b9:	89 c2                	mov    %eax,%edx
  8015bb:	83 c4 10             	add    $0x10,%esp
}
  8015be:	89 d0                	mov    %edx,%eax
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	56                   	push   %esi
  8015c6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8015c7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015ca:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8015d0:	e8 65 eb ff ff       	call   80013a <sys_getenvid>
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	ff 75 0c             	pushl  0xc(%ebp)
  8015db:	ff 75 08             	pushl  0x8(%ebp)
  8015de:	56                   	push   %esi
  8015df:	50                   	push   %eax
  8015e0:	68 b0 25 80 00       	push   $0x8025b0
  8015e5:	e8 b1 00 00 00       	call   80169b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015ea:	83 c4 18             	add    $0x18,%esp
  8015ed:	53                   	push   %ebx
  8015ee:	ff 75 10             	pushl  0x10(%ebp)
  8015f1:	e8 54 00 00 00       	call   80164a <vcprintf>
	cprintf("\n");
  8015f6:	c7 04 24 a6 24 80 00 	movl   $0x8024a6,(%esp)
  8015fd:	e8 99 00 00 00       	call   80169b <cprintf>
  801602:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801605:	cc                   	int3   
  801606:	eb fd                	jmp    801605 <_panic+0x43>

00801608 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	53                   	push   %ebx
  80160c:	83 ec 04             	sub    $0x4,%esp
  80160f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801612:	8b 13                	mov    (%ebx),%edx
  801614:	8d 42 01             	lea    0x1(%edx),%eax
  801617:	89 03                	mov    %eax,(%ebx)
  801619:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80161c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801620:	3d ff 00 00 00       	cmp    $0xff,%eax
  801625:	75 1a                	jne    801641 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	68 ff 00 00 00       	push   $0xff
  80162f:	8d 43 08             	lea    0x8(%ebx),%eax
  801632:	50                   	push   %eax
  801633:	e8 84 ea ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  801638:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80163e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801641:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801645:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801648:	c9                   	leave  
  801649:	c3                   	ret    

0080164a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801653:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80165a:	00 00 00 
	b.cnt = 0;
  80165d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801664:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801667:	ff 75 0c             	pushl  0xc(%ebp)
  80166a:	ff 75 08             	pushl  0x8(%ebp)
  80166d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801673:	50                   	push   %eax
  801674:	68 08 16 80 00       	push   $0x801608
  801679:	e8 54 01 00 00       	call   8017d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80167e:	83 c4 08             	add    $0x8,%esp
  801681:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801687:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80168d:	50                   	push   %eax
  80168e:	e8 29 ea ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  801693:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801699:	c9                   	leave  
  80169a:	c3                   	ret    

0080169b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016a4:	50                   	push   %eax
  8016a5:	ff 75 08             	pushl  0x8(%ebp)
  8016a8:	e8 9d ff ff ff       	call   80164a <vcprintf>
	va_end(ap);

	return cnt;
}
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	57                   	push   %edi
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 1c             	sub    $0x1c,%esp
  8016b8:	89 c7                	mov    %eax,%edi
  8016ba:	89 d6                	mov    %edx,%esi
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016c5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8016d3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8016d6:	39 d3                	cmp    %edx,%ebx
  8016d8:	72 05                	jb     8016df <printnum+0x30>
  8016da:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016dd:	77 45                	ja     801724 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016df:	83 ec 0c             	sub    $0xc,%esp
  8016e2:	ff 75 18             	pushl  0x18(%ebp)
  8016e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8016eb:	53                   	push   %ebx
  8016ec:	ff 75 10             	pushl  0x10(%ebp)
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8016f8:	ff 75 dc             	pushl  -0x24(%ebp)
  8016fb:	ff 75 d8             	pushl  -0x28(%ebp)
  8016fe:	e8 5d 0a 00 00       	call   802160 <__udivdi3>
  801703:	83 c4 18             	add    $0x18,%esp
  801706:	52                   	push   %edx
  801707:	50                   	push   %eax
  801708:	89 f2                	mov    %esi,%edx
  80170a:	89 f8                	mov    %edi,%eax
  80170c:	e8 9e ff ff ff       	call   8016af <printnum>
  801711:	83 c4 20             	add    $0x20,%esp
  801714:	eb 18                	jmp    80172e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801716:	83 ec 08             	sub    $0x8,%esp
  801719:	56                   	push   %esi
  80171a:	ff 75 18             	pushl  0x18(%ebp)
  80171d:	ff d7                	call   *%edi
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	eb 03                	jmp    801727 <printnum+0x78>
  801724:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801727:	83 eb 01             	sub    $0x1,%ebx
  80172a:	85 db                	test   %ebx,%ebx
  80172c:	7f e8                	jg     801716 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	56                   	push   %esi
  801732:	83 ec 04             	sub    $0x4,%esp
  801735:	ff 75 e4             	pushl  -0x1c(%ebp)
  801738:	ff 75 e0             	pushl  -0x20(%ebp)
  80173b:	ff 75 dc             	pushl  -0x24(%ebp)
  80173e:	ff 75 d8             	pushl  -0x28(%ebp)
  801741:	e8 4a 0b 00 00       	call   802290 <__umoddi3>
  801746:	83 c4 14             	add    $0x14,%esp
  801749:	0f be 80 d3 25 80 00 	movsbl 0x8025d3(%eax),%eax
  801750:	50                   	push   %eax
  801751:	ff d7                	call   *%edi
}
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801759:	5b                   	pop    %ebx
  80175a:	5e                   	pop    %esi
  80175b:	5f                   	pop    %edi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801761:	83 fa 01             	cmp    $0x1,%edx
  801764:	7e 0e                	jle    801774 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801766:	8b 10                	mov    (%eax),%edx
  801768:	8d 4a 08             	lea    0x8(%edx),%ecx
  80176b:	89 08                	mov    %ecx,(%eax)
  80176d:	8b 02                	mov    (%edx),%eax
  80176f:	8b 52 04             	mov    0x4(%edx),%edx
  801772:	eb 22                	jmp    801796 <getuint+0x38>
	else if (lflag)
  801774:	85 d2                	test   %edx,%edx
  801776:	74 10                	je     801788 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801778:	8b 10                	mov    (%eax),%edx
  80177a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80177d:	89 08                	mov    %ecx,(%eax)
  80177f:	8b 02                	mov    (%edx),%eax
  801781:	ba 00 00 00 00       	mov    $0x0,%edx
  801786:	eb 0e                	jmp    801796 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801788:	8b 10                	mov    (%eax),%edx
  80178a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80178d:	89 08                	mov    %ecx,(%eax)
  80178f:	8b 02                	mov    (%edx),%eax
  801791:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80179e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017a2:	8b 10                	mov    (%eax),%edx
  8017a4:	3b 50 04             	cmp    0x4(%eax),%edx
  8017a7:	73 0a                	jae    8017b3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8017a9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017ac:	89 08                	mov    %ecx,(%eax)
  8017ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b1:	88 02                	mov    %al,(%edx)
}
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8017bb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017be:	50                   	push   %eax
  8017bf:	ff 75 10             	pushl  0x10(%ebp)
  8017c2:	ff 75 0c             	pushl  0xc(%ebp)
  8017c5:	ff 75 08             	pushl  0x8(%ebp)
  8017c8:	e8 05 00 00 00       	call   8017d2 <vprintfmt>
	va_end(ap);
}
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    

008017d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	57                   	push   %edi
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 2c             	sub    $0x2c,%esp
  8017db:	8b 75 08             	mov    0x8(%ebp),%esi
  8017de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017e1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017e4:	eb 12                	jmp    8017f8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	0f 84 89 03 00 00    	je     801b77 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8017ee:	83 ec 08             	sub    $0x8,%esp
  8017f1:	53                   	push   %ebx
  8017f2:	50                   	push   %eax
  8017f3:	ff d6                	call   *%esi
  8017f5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017f8:	83 c7 01             	add    $0x1,%edi
  8017fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017ff:	83 f8 25             	cmp    $0x25,%eax
  801802:	75 e2                	jne    8017e6 <vprintfmt+0x14>
  801804:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801808:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80180f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801816:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
  801822:	eb 07                	jmp    80182b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801824:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801827:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182b:	8d 47 01             	lea    0x1(%edi),%eax
  80182e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801831:	0f b6 07             	movzbl (%edi),%eax
  801834:	0f b6 c8             	movzbl %al,%ecx
  801837:	83 e8 23             	sub    $0x23,%eax
  80183a:	3c 55                	cmp    $0x55,%al
  80183c:	0f 87 1a 03 00 00    	ja     801b5c <vprintfmt+0x38a>
  801842:	0f b6 c0             	movzbl %al,%eax
  801845:	ff 24 85 20 27 80 00 	jmp    *0x802720(,%eax,4)
  80184c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80184f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801853:	eb d6                	jmp    80182b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801855:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801858:	b8 00 00 00 00       	mov    $0x0,%eax
  80185d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801860:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801863:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801867:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80186a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80186d:	83 fa 09             	cmp    $0x9,%edx
  801870:	77 39                	ja     8018ab <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801872:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801875:	eb e9                	jmp    801860 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801877:	8b 45 14             	mov    0x14(%ebp),%eax
  80187a:	8d 48 04             	lea    0x4(%eax),%ecx
  80187d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801880:	8b 00                	mov    (%eax),%eax
  801882:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801885:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801888:	eb 27                	jmp    8018b1 <vprintfmt+0xdf>
  80188a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80188d:	85 c0                	test   %eax,%eax
  80188f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801894:	0f 49 c8             	cmovns %eax,%ecx
  801897:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80189a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80189d:	eb 8c                	jmp    80182b <vprintfmt+0x59>
  80189f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018a2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018a9:	eb 80                	jmp    80182b <vprintfmt+0x59>
  8018ab:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8018ae:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018b1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018b5:	0f 89 70 ff ff ff    	jns    80182b <vprintfmt+0x59>
				width = precision, precision = -1;
  8018bb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8018be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018c1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018c8:	e9 5e ff ff ff       	jmp    80182b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018cd:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018d3:	e9 53 ff ff ff       	jmp    80182b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018db:	8d 50 04             	lea    0x4(%eax),%edx
  8018de:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	53                   	push   %ebx
  8018e5:	ff 30                	pushl  (%eax)
  8018e7:	ff d6                	call   *%esi
			break;
  8018e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018ef:	e9 04 ff ff ff       	jmp    8017f8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f7:	8d 50 04             	lea    0x4(%eax),%edx
  8018fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8018fd:	8b 00                	mov    (%eax),%eax
  8018ff:	99                   	cltd   
  801900:	31 d0                	xor    %edx,%eax
  801902:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801904:	83 f8 0f             	cmp    $0xf,%eax
  801907:	7f 0b                	jg     801914 <vprintfmt+0x142>
  801909:	8b 14 85 80 28 80 00 	mov    0x802880(,%eax,4),%edx
  801910:	85 d2                	test   %edx,%edx
  801912:	75 18                	jne    80192c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801914:	50                   	push   %eax
  801915:	68 eb 25 80 00       	push   $0x8025eb
  80191a:	53                   	push   %ebx
  80191b:	56                   	push   %esi
  80191c:	e8 94 fe ff ff       	call   8017b5 <printfmt>
  801921:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801924:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801927:	e9 cc fe ff ff       	jmp    8017f8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80192c:	52                   	push   %edx
  80192d:	68 69 25 80 00       	push   $0x802569
  801932:	53                   	push   %ebx
  801933:	56                   	push   %esi
  801934:	e8 7c fe ff ff       	call   8017b5 <printfmt>
  801939:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80193c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80193f:	e9 b4 fe ff ff       	jmp    8017f8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801944:	8b 45 14             	mov    0x14(%ebp),%eax
  801947:	8d 50 04             	lea    0x4(%eax),%edx
  80194a:	89 55 14             	mov    %edx,0x14(%ebp)
  80194d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80194f:	85 ff                	test   %edi,%edi
  801951:	b8 e4 25 80 00       	mov    $0x8025e4,%eax
  801956:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801959:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80195d:	0f 8e 94 00 00 00    	jle    8019f7 <vprintfmt+0x225>
  801963:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801967:	0f 84 98 00 00 00    	je     801a05 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80196d:	83 ec 08             	sub    $0x8,%esp
  801970:	ff 75 d0             	pushl  -0x30(%ebp)
  801973:	57                   	push   %edi
  801974:	e8 86 02 00 00       	call   801bff <strnlen>
  801979:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80197c:	29 c1                	sub    %eax,%ecx
  80197e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801981:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801984:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801988:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80198b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80198e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801990:	eb 0f                	jmp    8019a1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801992:	83 ec 08             	sub    $0x8,%esp
  801995:	53                   	push   %ebx
  801996:	ff 75 e0             	pushl  -0x20(%ebp)
  801999:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80199b:	83 ef 01             	sub    $0x1,%edi
  80199e:	83 c4 10             	add    $0x10,%esp
  8019a1:	85 ff                	test   %edi,%edi
  8019a3:	7f ed                	jg     801992 <vprintfmt+0x1c0>
  8019a5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019a8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019ab:	85 c9                	test   %ecx,%ecx
  8019ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b2:	0f 49 c1             	cmovns %ecx,%eax
  8019b5:	29 c1                	sub    %eax,%ecx
  8019b7:	89 75 08             	mov    %esi,0x8(%ebp)
  8019ba:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019bd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019c0:	89 cb                	mov    %ecx,%ebx
  8019c2:	eb 4d                	jmp    801a11 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019c4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019c8:	74 1b                	je     8019e5 <vprintfmt+0x213>
  8019ca:	0f be c0             	movsbl %al,%eax
  8019cd:	83 e8 20             	sub    $0x20,%eax
  8019d0:	83 f8 5e             	cmp    $0x5e,%eax
  8019d3:	76 10                	jbe    8019e5 <vprintfmt+0x213>
					putch('?', putdat);
  8019d5:	83 ec 08             	sub    $0x8,%esp
  8019d8:	ff 75 0c             	pushl  0xc(%ebp)
  8019db:	6a 3f                	push   $0x3f
  8019dd:	ff 55 08             	call   *0x8(%ebp)
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	eb 0d                	jmp    8019f2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8019e5:	83 ec 08             	sub    $0x8,%esp
  8019e8:	ff 75 0c             	pushl  0xc(%ebp)
  8019eb:	52                   	push   %edx
  8019ec:	ff 55 08             	call   *0x8(%ebp)
  8019ef:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8019f2:	83 eb 01             	sub    $0x1,%ebx
  8019f5:	eb 1a                	jmp    801a11 <vprintfmt+0x23f>
  8019f7:	89 75 08             	mov    %esi,0x8(%ebp)
  8019fa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a00:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a03:	eb 0c                	jmp    801a11 <vprintfmt+0x23f>
  801a05:	89 75 08             	mov    %esi,0x8(%ebp)
  801a08:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a0b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a0e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a11:	83 c7 01             	add    $0x1,%edi
  801a14:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a18:	0f be d0             	movsbl %al,%edx
  801a1b:	85 d2                	test   %edx,%edx
  801a1d:	74 23                	je     801a42 <vprintfmt+0x270>
  801a1f:	85 f6                	test   %esi,%esi
  801a21:	78 a1                	js     8019c4 <vprintfmt+0x1f2>
  801a23:	83 ee 01             	sub    $0x1,%esi
  801a26:	79 9c                	jns    8019c4 <vprintfmt+0x1f2>
  801a28:	89 df                	mov    %ebx,%edi
  801a2a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a2d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a30:	eb 18                	jmp    801a4a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a32:	83 ec 08             	sub    $0x8,%esp
  801a35:	53                   	push   %ebx
  801a36:	6a 20                	push   $0x20
  801a38:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a3a:	83 ef 01             	sub    $0x1,%edi
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	eb 08                	jmp    801a4a <vprintfmt+0x278>
  801a42:	89 df                	mov    %ebx,%edi
  801a44:	8b 75 08             	mov    0x8(%ebp),%esi
  801a47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a4a:	85 ff                	test   %edi,%edi
  801a4c:	7f e4                	jg     801a32 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a51:	e9 a2 fd ff ff       	jmp    8017f8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a56:	83 fa 01             	cmp    $0x1,%edx
  801a59:	7e 16                	jle    801a71 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801a5b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5e:	8d 50 08             	lea    0x8(%eax),%edx
  801a61:	89 55 14             	mov    %edx,0x14(%ebp)
  801a64:	8b 50 04             	mov    0x4(%eax),%edx
  801a67:	8b 00                	mov    (%eax),%eax
  801a69:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a6c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a6f:	eb 32                	jmp    801aa3 <vprintfmt+0x2d1>
	else if (lflag)
  801a71:	85 d2                	test   %edx,%edx
  801a73:	74 18                	je     801a8d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801a75:	8b 45 14             	mov    0x14(%ebp),%eax
  801a78:	8d 50 04             	lea    0x4(%eax),%edx
  801a7b:	89 55 14             	mov    %edx,0x14(%ebp)
  801a7e:	8b 00                	mov    (%eax),%eax
  801a80:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a83:	89 c1                	mov    %eax,%ecx
  801a85:	c1 f9 1f             	sar    $0x1f,%ecx
  801a88:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801a8b:	eb 16                	jmp    801aa3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801a8d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a90:	8d 50 04             	lea    0x4(%eax),%edx
  801a93:	89 55 14             	mov    %edx,0x14(%ebp)
  801a96:	8b 00                	mov    (%eax),%eax
  801a98:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a9b:	89 c1                	mov    %eax,%ecx
  801a9d:	c1 f9 1f             	sar    $0x1f,%ecx
  801aa0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801aa3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801aa6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801aa9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801aae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ab2:	79 74                	jns    801b28 <vprintfmt+0x356>
				putch('-', putdat);
  801ab4:	83 ec 08             	sub    $0x8,%esp
  801ab7:	53                   	push   %ebx
  801ab8:	6a 2d                	push   $0x2d
  801aba:	ff d6                	call   *%esi
				num = -(long long) num;
  801abc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801abf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ac2:	f7 d8                	neg    %eax
  801ac4:	83 d2 00             	adc    $0x0,%edx
  801ac7:	f7 da                	neg    %edx
  801ac9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801acc:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801ad1:	eb 55                	jmp    801b28 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801ad3:	8d 45 14             	lea    0x14(%ebp),%eax
  801ad6:	e8 83 fc ff ff       	call   80175e <getuint>
			base = 10;
  801adb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ae0:	eb 46                	jmp    801b28 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ae2:	8d 45 14             	lea    0x14(%ebp),%eax
  801ae5:	e8 74 fc ff ff       	call   80175e <getuint>
			base = 8;
  801aea:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801aef:	eb 37                	jmp    801b28 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801af1:	83 ec 08             	sub    $0x8,%esp
  801af4:	53                   	push   %ebx
  801af5:	6a 30                	push   $0x30
  801af7:	ff d6                	call   *%esi
			putch('x', putdat);
  801af9:	83 c4 08             	add    $0x8,%esp
  801afc:	53                   	push   %ebx
  801afd:	6a 78                	push   $0x78
  801aff:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b01:	8b 45 14             	mov    0x14(%ebp),%eax
  801b04:	8d 50 04             	lea    0x4(%eax),%edx
  801b07:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b0a:	8b 00                	mov    (%eax),%eax
  801b0c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b11:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b14:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b19:	eb 0d                	jmp    801b28 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b1b:	8d 45 14             	lea    0x14(%ebp),%eax
  801b1e:	e8 3b fc ff ff       	call   80175e <getuint>
			base = 16;
  801b23:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b28:	83 ec 0c             	sub    $0xc,%esp
  801b2b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b2f:	57                   	push   %edi
  801b30:	ff 75 e0             	pushl  -0x20(%ebp)
  801b33:	51                   	push   %ecx
  801b34:	52                   	push   %edx
  801b35:	50                   	push   %eax
  801b36:	89 da                	mov    %ebx,%edx
  801b38:	89 f0                	mov    %esi,%eax
  801b3a:	e8 70 fb ff ff       	call   8016af <printnum>
			break;
  801b3f:	83 c4 20             	add    $0x20,%esp
  801b42:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b45:	e9 ae fc ff ff       	jmp    8017f8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b4a:	83 ec 08             	sub    $0x8,%esp
  801b4d:	53                   	push   %ebx
  801b4e:	51                   	push   %ecx
  801b4f:	ff d6                	call   *%esi
			break;
  801b51:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b57:	e9 9c fc ff ff       	jmp    8017f8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b5c:	83 ec 08             	sub    $0x8,%esp
  801b5f:	53                   	push   %ebx
  801b60:	6a 25                	push   $0x25
  801b62:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	eb 03                	jmp    801b6c <vprintfmt+0x39a>
  801b69:	83 ef 01             	sub    $0x1,%edi
  801b6c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b70:	75 f7                	jne    801b69 <vprintfmt+0x397>
  801b72:	e9 81 fc ff ff       	jmp    8017f8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7a:	5b                   	pop    %ebx
  801b7b:	5e                   	pop    %esi
  801b7c:	5f                   	pop    %edi
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    

00801b7f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	83 ec 18             	sub    $0x18,%esp
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b8b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b8e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b92:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	74 26                	je     801bc6 <vsnprintf+0x47>
  801ba0:	85 d2                	test   %edx,%edx
  801ba2:	7e 22                	jle    801bc6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ba4:	ff 75 14             	pushl  0x14(%ebp)
  801ba7:	ff 75 10             	pushl  0x10(%ebp)
  801baa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bad:	50                   	push   %eax
  801bae:	68 98 17 80 00       	push   $0x801798
  801bb3:	e8 1a fc ff ff       	call   8017d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801bb8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801bbb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	eb 05                	jmp    801bcb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801bc6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801bd3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801bd6:	50                   	push   %eax
  801bd7:	ff 75 10             	pushl  0x10(%ebp)
  801bda:	ff 75 0c             	pushl  0xc(%ebp)
  801bdd:	ff 75 08             	pushl  0x8(%ebp)
  801be0:	e8 9a ff ff ff       	call   801b7f <vsnprintf>
	va_end(ap);

	return rc;
}
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bed:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf2:	eb 03                	jmp    801bf7 <strlen+0x10>
		n++;
  801bf4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bf7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bfb:	75 f7                	jne    801bf4 <strlen+0xd>
		n++;
	return n;
}
  801bfd:	5d                   	pop    %ebp
  801bfe:	c3                   	ret    

00801bff <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c05:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c08:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0d:	eb 03                	jmp    801c12 <strnlen+0x13>
		n++;
  801c0f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c12:	39 c2                	cmp    %eax,%edx
  801c14:	74 08                	je     801c1e <strnlen+0x1f>
  801c16:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c1a:	75 f3                	jne    801c0f <strnlen+0x10>
  801c1c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801c1e:	5d                   	pop    %ebp
  801c1f:	c3                   	ret    

00801c20 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	53                   	push   %ebx
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c2a:	89 c2                	mov    %eax,%edx
  801c2c:	83 c2 01             	add    $0x1,%edx
  801c2f:	83 c1 01             	add    $0x1,%ecx
  801c32:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c36:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c39:	84 db                	test   %bl,%bl
  801c3b:	75 ef                	jne    801c2c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c3d:	5b                   	pop    %ebx
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	53                   	push   %ebx
  801c44:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c47:	53                   	push   %ebx
  801c48:	e8 9a ff ff ff       	call   801be7 <strlen>
  801c4d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c50:	ff 75 0c             	pushl  0xc(%ebp)
  801c53:	01 d8                	add    %ebx,%eax
  801c55:	50                   	push   %eax
  801c56:	e8 c5 ff ff ff       	call   801c20 <strcpy>
	return dst;
}
  801c5b:	89 d8                	mov    %ebx,%eax
  801c5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	56                   	push   %esi
  801c66:	53                   	push   %ebx
  801c67:	8b 75 08             	mov    0x8(%ebp),%esi
  801c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6d:	89 f3                	mov    %esi,%ebx
  801c6f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c72:	89 f2                	mov    %esi,%edx
  801c74:	eb 0f                	jmp    801c85 <strncpy+0x23>
		*dst++ = *src;
  801c76:	83 c2 01             	add    $0x1,%edx
  801c79:	0f b6 01             	movzbl (%ecx),%eax
  801c7c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c7f:	80 39 01             	cmpb   $0x1,(%ecx)
  801c82:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c85:	39 da                	cmp    %ebx,%edx
  801c87:	75 ed                	jne    801c76 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c89:	89 f0                	mov    %esi,%eax
  801c8b:	5b                   	pop    %ebx
  801c8c:	5e                   	pop    %esi
  801c8d:	5d                   	pop    %ebp
  801c8e:	c3                   	ret    

00801c8f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	8b 75 08             	mov    0x8(%ebp),%esi
  801c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9a:	8b 55 10             	mov    0x10(%ebp),%edx
  801c9d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c9f:	85 d2                	test   %edx,%edx
  801ca1:	74 21                	je     801cc4 <strlcpy+0x35>
  801ca3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ca7:	89 f2                	mov    %esi,%edx
  801ca9:	eb 09                	jmp    801cb4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801cab:	83 c2 01             	add    $0x1,%edx
  801cae:	83 c1 01             	add    $0x1,%ecx
  801cb1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801cb4:	39 c2                	cmp    %eax,%edx
  801cb6:	74 09                	je     801cc1 <strlcpy+0x32>
  801cb8:	0f b6 19             	movzbl (%ecx),%ebx
  801cbb:	84 db                	test   %bl,%bl
  801cbd:	75 ec                	jne    801cab <strlcpy+0x1c>
  801cbf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801cc1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801cc4:	29 f0                	sub    %esi,%eax
}
  801cc6:	5b                   	pop    %ebx
  801cc7:	5e                   	pop    %esi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    

00801cca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801cd3:	eb 06                	jmp    801cdb <strcmp+0x11>
		p++, q++;
  801cd5:	83 c1 01             	add    $0x1,%ecx
  801cd8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cdb:	0f b6 01             	movzbl (%ecx),%eax
  801cde:	84 c0                	test   %al,%al
  801ce0:	74 04                	je     801ce6 <strcmp+0x1c>
  801ce2:	3a 02                	cmp    (%edx),%al
  801ce4:	74 ef                	je     801cd5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ce6:	0f b6 c0             	movzbl %al,%eax
  801ce9:	0f b6 12             	movzbl (%edx),%edx
  801cec:	29 d0                	sub    %edx,%eax
}
  801cee:	5d                   	pop    %ebp
  801cef:	c3                   	ret    

00801cf0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	53                   	push   %ebx
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cfa:	89 c3                	mov    %eax,%ebx
  801cfc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cff:	eb 06                	jmp    801d07 <strncmp+0x17>
		n--, p++, q++;
  801d01:	83 c0 01             	add    $0x1,%eax
  801d04:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d07:	39 d8                	cmp    %ebx,%eax
  801d09:	74 15                	je     801d20 <strncmp+0x30>
  801d0b:	0f b6 08             	movzbl (%eax),%ecx
  801d0e:	84 c9                	test   %cl,%cl
  801d10:	74 04                	je     801d16 <strncmp+0x26>
  801d12:	3a 0a                	cmp    (%edx),%cl
  801d14:	74 eb                	je     801d01 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d16:	0f b6 00             	movzbl (%eax),%eax
  801d19:	0f b6 12             	movzbl (%edx),%edx
  801d1c:	29 d0                	sub    %edx,%eax
  801d1e:	eb 05                	jmp    801d25 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d25:	5b                   	pop    %ebx
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    

00801d28 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d32:	eb 07                	jmp    801d3b <strchr+0x13>
		if (*s == c)
  801d34:	38 ca                	cmp    %cl,%dl
  801d36:	74 0f                	je     801d47 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d38:	83 c0 01             	add    $0x1,%eax
  801d3b:	0f b6 10             	movzbl (%eax),%edx
  801d3e:	84 d2                	test   %dl,%dl
  801d40:	75 f2                	jne    801d34 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d42:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    

00801d49 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d53:	eb 03                	jmp    801d58 <strfind+0xf>
  801d55:	83 c0 01             	add    $0x1,%eax
  801d58:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d5b:	38 ca                	cmp    %cl,%dl
  801d5d:	74 04                	je     801d63 <strfind+0x1a>
  801d5f:	84 d2                	test   %dl,%dl
  801d61:	75 f2                	jne    801d55 <strfind+0xc>
			break;
	return (char *) s;
}
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    

00801d65 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	57                   	push   %edi
  801d69:	56                   	push   %esi
  801d6a:	53                   	push   %ebx
  801d6b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d71:	85 c9                	test   %ecx,%ecx
  801d73:	74 36                	je     801dab <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d75:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d7b:	75 28                	jne    801da5 <memset+0x40>
  801d7d:	f6 c1 03             	test   $0x3,%cl
  801d80:	75 23                	jne    801da5 <memset+0x40>
		c &= 0xFF;
  801d82:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d86:	89 d3                	mov    %edx,%ebx
  801d88:	c1 e3 08             	shl    $0x8,%ebx
  801d8b:	89 d6                	mov    %edx,%esi
  801d8d:	c1 e6 18             	shl    $0x18,%esi
  801d90:	89 d0                	mov    %edx,%eax
  801d92:	c1 e0 10             	shl    $0x10,%eax
  801d95:	09 f0                	or     %esi,%eax
  801d97:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d99:	89 d8                	mov    %ebx,%eax
  801d9b:	09 d0                	or     %edx,%eax
  801d9d:	c1 e9 02             	shr    $0x2,%ecx
  801da0:	fc                   	cld    
  801da1:	f3 ab                	rep stos %eax,%es:(%edi)
  801da3:	eb 06                	jmp    801dab <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801da5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da8:	fc                   	cld    
  801da9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801dab:	89 f8                	mov    %edi,%eax
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    

00801db2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801db2:	55                   	push   %ebp
  801db3:	89 e5                	mov    %esp,%ebp
  801db5:	57                   	push   %edi
  801db6:	56                   	push   %esi
  801db7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dba:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801dc0:	39 c6                	cmp    %eax,%esi
  801dc2:	73 35                	jae    801df9 <memmove+0x47>
  801dc4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801dc7:	39 d0                	cmp    %edx,%eax
  801dc9:	73 2e                	jae    801df9 <memmove+0x47>
		s += n;
		d += n;
  801dcb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dce:	89 d6                	mov    %edx,%esi
  801dd0:	09 fe                	or     %edi,%esi
  801dd2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801dd8:	75 13                	jne    801ded <memmove+0x3b>
  801dda:	f6 c1 03             	test   $0x3,%cl
  801ddd:	75 0e                	jne    801ded <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801ddf:	83 ef 04             	sub    $0x4,%edi
  801de2:	8d 72 fc             	lea    -0x4(%edx),%esi
  801de5:	c1 e9 02             	shr    $0x2,%ecx
  801de8:	fd                   	std    
  801de9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801deb:	eb 09                	jmp    801df6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801ded:	83 ef 01             	sub    $0x1,%edi
  801df0:	8d 72 ff             	lea    -0x1(%edx),%esi
  801df3:	fd                   	std    
  801df4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801df6:	fc                   	cld    
  801df7:	eb 1d                	jmp    801e16 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801df9:	89 f2                	mov    %esi,%edx
  801dfb:	09 c2                	or     %eax,%edx
  801dfd:	f6 c2 03             	test   $0x3,%dl
  801e00:	75 0f                	jne    801e11 <memmove+0x5f>
  801e02:	f6 c1 03             	test   $0x3,%cl
  801e05:	75 0a                	jne    801e11 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e07:	c1 e9 02             	shr    $0x2,%ecx
  801e0a:	89 c7                	mov    %eax,%edi
  801e0c:	fc                   	cld    
  801e0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e0f:	eb 05                	jmp    801e16 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e11:	89 c7                	mov    %eax,%edi
  801e13:	fc                   	cld    
  801e14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e16:	5e                   	pop    %esi
  801e17:	5f                   	pop    %edi
  801e18:	5d                   	pop    %ebp
  801e19:	c3                   	ret    

00801e1a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e1d:	ff 75 10             	pushl  0x10(%ebp)
  801e20:	ff 75 0c             	pushl  0xc(%ebp)
  801e23:	ff 75 08             	pushl  0x8(%ebp)
  801e26:	e8 87 ff ff ff       	call   801db2 <memmove>
}
  801e2b:	c9                   	leave  
  801e2c:	c3                   	ret    

00801e2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	56                   	push   %esi
  801e31:	53                   	push   %ebx
  801e32:	8b 45 08             	mov    0x8(%ebp),%eax
  801e35:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e38:	89 c6                	mov    %eax,%esi
  801e3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e3d:	eb 1a                	jmp    801e59 <memcmp+0x2c>
		if (*s1 != *s2)
  801e3f:	0f b6 08             	movzbl (%eax),%ecx
  801e42:	0f b6 1a             	movzbl (%edx),%ebx
  801e45:	38 d9                	cmp    %bl,%cl
  801e47:	74 0a                	je     801e53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e49:	0f b6 c1             	movzbl %cl,%eax
  801e4c:	0f b6 db             	movzbl %bl,%ebx
  801e4f:	29 d8                	sub    %ebx,%eax
  801e51:	eb 0f                	jmp    801e62 <memcmp+0x35>
		s1++, s2++;
  801e53:	83 c0 01             	add    $0x1,%eax
  801e56:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e59:	39 f0                	cmp    %esi,%eax
  801e5b:	75 e2                	jne    801e3f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e62:	5b                   	pop    %ebx
  801e63:	5e                   	pop    %esi
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    

00801e66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	53                   	push   %ebx
  801e6a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e6d:	89 c1                	mov    %eax,%ecx
  801e6f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e72:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e76:	eb 0a                	jmp    801e82 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e78:	0f b6 10             	movzbl (%eax),%edx
  801e7b:	39 da                	cmp    %ebx,%edx
  801e7d:	74 07                	je     801e86 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e7f:	83 c0 01             	add    $0x1,%eax
  801e82:	39 c8                	cmp    %ecx,%eax
  801e84:	72 f2                	jb     801e78 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e86:	5b                   	pop    %ebx
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    

00801e89 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	57                   	push   %edi
  801e8d:	56                   	push   %esi
  801e8e:	53                   	push   %ebx
  801e8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e95:	eb 03                	jmp    801e9a <strtol+0x11>
		s++;
  801e97:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e9a:	0f b6 01             	movzbl (%ecx),%eax
  801e9d:	3c 20                	cmp    $0x20,%al
  801e9f:	74 f6                	je     801e97 <strtol+0xe>
  801ea1:	3c 09                	cmp    $0x9,%al
  801ea3:	74 f2                	je     801e97 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ea5:	3c 2b                	cmp    $0x2b,%al
  801ea7:	75 0a                	jne    801eb3 <strtol+0x2a>
		s++;
  801ea9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801eac:	bf 00 00 00 00       	mov    $0x0,%edi
  801eb1:	eb 11                	jmp    801ec4 <strtol+0x3b>
  801eb3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801eb8:	3c 2d                	cmp    $0x2d,%al
  801eba:	75 08                	jne    801ec4 <strtol+0x3b>
		s++, neg = 1;
  801ebc:	83 c1 01             	add    $0x1,%ecx
  801ebf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ec4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801eca:	75 15                	jne    801ee1 <strtol+0x58>
  801ecc:	80 39 30             	cmpb   $0x30,(%ecx)
  801ecf:	75 10                	jne    801ee1 <strtol+0x58>
  801ed1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ed5:	75 7c                	jne    801f53 <strtol+0xca>
		s += 2, base = 16;
  801ed7:	83 c1 02             	add    $0x2,%ecx
  801eda:	bb 10 00 00 00       	mov    $0x10,%ebx
  801edf:	eb 16                	jmp    801ef7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ee1:	85 db                	test   %ebx,%ebx
  801ee3:	75 12                	jne    801ef7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ee5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eea:	80 39 30             	cmpb   $0x30,(%ecx)
  801eed:	75 08                	jne    801ef7 <strtol+0x6e>
		s++, base = 8;
  801eef:	83 c1 01             	add    $0x1,%ecx
  801ef2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
  801efc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801eff:	0f b6 11             	movzbl (%ecx),%edx
  801f02:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f05:	89 f3                	mov    %esi,%ebx
  801f07:	80 fb 09             	cmp    $0x9,%bl
  801f0a:	77 08                	ja     801f14 <strtol+0x8b>
			dig = *s - '0';
  801f0c:	0f be d2             	movsbl %dl,%edx
  801f0f:	83 ea 30             	sub    $0x30,%edx
  801f12:	eb 22                	jmp    801f36 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f14:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f17:	89 f3                	mov    %esi,%ebx
  801f19:	80 fb 19             	cmp    $0x19,%bl
  801f1c:	77 08                	ja     801f26 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801f1e:	0f be d2             	movsbl %dl,%edx
  801f21:	83 ea 57             	sub    $0x57,%edx
  801f24:	eb 10                	jmp    801f36 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801f26:	8d 72 bf             	lea    -0x41(%edx),%esi
  801f29:	89 f3                	mov    %esi,%ebx
  801f2b:	80 fb 19             	cmp    $0x19,%bl
  801f2e:	77 16                	ja     801f46 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f30:	0f be d2             	movsbl %dl,%edx
  801f33:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f36:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f39:	7d 0b                	jge    801f46 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f3b:	83 c1 01             	add    $0x1,%ecx
  801f3e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f42:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f44:	eb b9                	jmp    801eff <strtol+0x76>

	if (endptr)
  801f46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f4a:	74 0d                	je     801f59 <strtol+0xd0>
		*endptr = (char *) s;
  801f4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f4f:	89 0e                	mov    %ecx,(%esi)
  801f51:	eb 06                	jmp    801f59 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f53:	85 db                	test   %ebx,%ebx
  801f55:	74 98                	je     801eef <strtol+0x66>
  801f57:	eb 9e                	jmp    801ef7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f59:	89 c2                	mov    %eax,%edx
  801f5b:	f7 da                	neg    %edx
  801f5d:	85 ff                	test   %edi,%edi
  801f5f:	0f 45 c2             	cmovne %edx,%eax
}
  801f62:	5b                   	pop    %ebx
  801f63:	5e                   	pop    %esi
  801f64:	5f                   	pop    %edi
  801f65:	5d                   	pop    %ebp
  801f66:	c3                   	ret    

00801f67 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f6d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f74:	75 2a                	jne    801fa0 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801f76:	83 ec 04             	sub    $0x4,%esp
  801f79:	6a 07                	push   $0x7
  801f7b:	68 00 f0 bf ee       	push   $0xeebff000
  801f80:	6a 00                	push   $0x0
  801f82:	e8 f1 e1 ff ff       	call   800178 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	79 12                	jns    801fa0 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801f8e:	50                   	push   %eax
  801f8f:	68 bd 24 80 00       	push   $0x8024bd
  801f94:	6a 23                	push   $0x23
  801f96:	68 e0 28 80 00       	push   $0x8028e0
  801f9b:	e8 22 f6 ff ff       	call   8015c2 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa3:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801fa8:	83 ec 08             	sub    $0x8,%esp
  801fab:	68 d2 1f 80 00       	push   $0x801fd2
  801fb0:	6a 00                	push   $0x0
  801fb2:	e8 0c e3 ff ff       	call   8002c3 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801fb7:	83 c4 10             	add    $0x10,%esp
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	79 12                	jns    801fd0 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801fbe:	50                   	push   %eax
  801fbf:	68 bd 24 80 00       	push   $0x8024bd
  801fc4:	6a 2c                	push   $0x2c
  801fc6:	68 e0 28 80 00       	push   $0x8028e0
  801fcb:	e8 f2 f5 ff ff       	call   8015c2 <_panic>
	}
}
  801fd0:	c9                   	leave  
  801fd1:	c3                   	ret    

00801fd2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fd2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fd3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fd8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fda:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801fdd:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801fe1:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801fe6:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801fea:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801fec:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801fef:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801ff0:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801ff3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801ff4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801ff5:	c3                   	ret    

00801ff6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	56                   	push   %esi
  801ffa:	53                   	push   %ebx
  801ffb:	8b 75 08             	mov    0x8(%ebp),%esi
  801ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802001:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802004:	85 c0                	test   %eax,%eax
  802006:	75 12                	jne    80201a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  802008:	83 ec 0c             	sub    $0xc,%esp
  80200b:	68 00 00 c0 ee       	push   $0xeec00000
  802010:	e8 13 e3 ff ff       	call   800328 <sys_ipc_recv>
  802015:	83 c4 10             	add    $0x10,%esp
  802018:	eb 0c                	jmp    802026 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80201a:	83 ec 0c             	sub    $0xc,%esp
  80201d:	50                   	push   %eax
  80201e:	e8 05 e3 ff ff       	call   800328 <sys_ipc_recv>
  802023:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  802026:	85 f6                	test   %esi,%esi
  802028:	0f 95 c1             	setne  %cl
  80202b:	85 db                	test   %ebx,%ebx
  80202d:	0f 95 c2             	setne  %dl
  802030:	84 d1                	test   %dl,%cl
  802032:	74 09                	je     80203d <ipc_recv+0x47>
  802034:	89 c2                	mov    %eax,%edx
  802036:	c1 ea 1f             	shr    $0x1f,%edx
  802039:	84 d2                	test   %dl,%dl
  80203b:	75 2d                	jne    80206a <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  80203d:	85 f6                	test   %esi,%esi
  80203f:	74 0d                	je     80204e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  802041:	a1 04 40 80 00       	mov    0x804004,%eax
  802046:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
  80204c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  80204e:	85 db                	test   %ebx,%ebx
  802050:	74 0d                	je     80205f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  802052:	a1 04 40 80 00       	mov    0x804004,%eax
  802057:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  80205d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80205f:	a1 04 40 80 00       	mov    0x804004,%eax
  802064:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
}
  80206a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5d                   	pop    %ebp
  802070:	c3                   	ret    

00802071 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	57                   	push   %edi
  802075:	56                   	push   %esi
  802076:	53                   	push   %ebx
  802077:	83 ec 0c             	sub    $0xc,%esp
  80207a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80207d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802080:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802083:	85 db                	test   %ebx,%ebx
  802085:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80208a:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80208d:	ff 75 14             	pushl  0x14(%ebp)
  802090:	53                   	push   %ebx
  802091:	56                   	push   %esi
  802092:	57                   	push   %edi
  802093:	e8 6d e2 ff ff       	call   800305 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802098:	89 c2                	mov    %eax,%edx
  80209a:	c1 ea 1f             	shr    $0x1f,%edx
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	84 d2                	test   %dl,%dl
  8020a2:	74 17                	je     8020bb <ipc_send+0x4a>
  8020a4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020a7:	74 12                	je     8020bb <ipc_send+0x4a>
			panic("failed ipc %e", r);
  8020a9:	50                   	push   %eax
  8020aa:	68 ee 28 80 00       	push   $0x8028ee
  8020af:	6a 47                	push   $0x47
  8020b1:	68 fc 28 80 00       	push   $0x8028fc
  8020b6:	e8 07 f5 ff ff       	call   8015c2 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  8020bb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020be:	75 07                	jne    8020c7 <ipc_send+0x56>
			sys_yield();
  8020c0:	e8 94 e0 ff ff       	call   800159 <sys_yield>
  8020c5:	eb c6                	jmp    80208d <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  8020c7:	85 c0                	test   %eax,%eax
  8020c9:	75 c2                	jne    80208d <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  8020cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ce:	5b                   	pop    %ebx
  8020cf:	5e                   	pop    %esi
  8020d0:	5f                   	pop    %edi
  8020d1:	5d                   	pop    %ebp
  8020d2:	c3                   	ret    

008020d3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020d3:	55                   	push   %ebp
  8020d4:	89 e5                	mov    %esp,%ebp
  8020d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020d9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020de:	69 d0 d4 00 00 00    	imul   $0xd4,%eax,%edx
  8020e4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ea:	8b 92 a8 00 00 00    	mov    0xa8(%edx),%edx
  8020f0:	39 ca                	cmp    %ecx,%edx
  8020f2:	75 13                	jne    802107 <ipc_find_env+0x34>
			return envs[i].env_id;
  8020f4:	69 c0 d4 00 00 00    	imul   $0xd4,%eax,%eax
  8020fa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020ff:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
  802105:	eb 0f                	jmp    802116 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802107:	83 c0 01             	add    $0x1,%eax
  80210a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80210f:	75 cd                	jne    8020de <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802111:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    

00802118 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80211e:	89 d0                	mov    %edx,%eax
  802120:	c1 e8 16             	shr    $0x16,%eax
  802123:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80212a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80212f:	f6 c1 01             	test   $0x1,%cl
  802132:	74 1d                	je     802151 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802134:	c1 ea 0c             	shr    $0xc,%edx
  802137:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80213e:	f6 c2 01             	test   $0x1,%dl
  802141:	74 0e                	je     802151 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802143:	c1 ea 0c             	shr    $0xc,%edx
  802146:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80214d:	ef 
  80214e:	0f b7 c0             	movzwl %ax,%eax
}
  802151:	5d                   	pop    %ebp
  802152:	c3                   	ret    
  802153:	66 90                	xchg   %ax,%ax
  802155:	66 90                	xchg   %ax,%ax
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
