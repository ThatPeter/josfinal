
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
  80004e:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

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

void 
thread_main(/*uintptr_t eip*/)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

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
  8000a8:	e8 04 08 00 00       	call   8008b1 <close_all>
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
  800121:	68 2a 22 80 00       	push   $0x80222a
  800126:	6a 23                	push   $0x23
  800128:	68 47 22 80 00       	push   $0x802247
  80012d:	e8 b0 12 00 00       	call   8013e2 <_panic>

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
  8001a2:	68 2a 22 80 00       	push   $0x80222a
  8001a7:	6a 23                	push   $0x23
  8001a9:	68 47 22 80 00       	push   $0x802247
  8001ae:	e8 2f 12 00 00       	call   8013e2 <_panic>

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
  8001e4:	68 2a 22 80 00       	push   $0x80222a
  8001e9:	6a 23                	push   $0x23
  8001eb:	68 47 22 80 00       	push   $0x802247
  8001f0:	e8 ed 11 00 00       	call   8013e2 <_panic>

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
  800226:	68 2a 22 80 00       	push   $0x80222a
  80022b:	6a 23                	push   $0x23
  80022d:	68 47 22 80 00       	push   $0x802247
  800232:	e8 ab 11 00 00       	call   8013e2 <_panic>

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
  800268:	68 2a 22 80 00       	push   $0x80222a
  80026d:	6a 23                	push   $0x23
  80026f:	68 47 22 80 00       	push   $0x802247
  800274:	e8 69 11 00 00       	call   8013e2 <_panic>

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
  8002aa:	68 2a 22 80 00       	push   $0x80222a
  8002af:	6a 23                	push   $0x23
  8002b1:	68 47 22 80 00       	push   $0x802247
  8002b6:	e8 27 11 00 00       	call   8013e2 <_panic>
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
  8002ec:	68 2a 22 80 00       	push   $0x80222a
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 47 22 80 00       	push   $0x802247
  8002f8:	e8 e5 10 00 00       	call   8013e2 <_panic>

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
  800350:	68 2a 22 80 00       	push   $0x80222a
  800355:	6a 23                	push   $0x23
  800357:	68 47 22 80 00       	push   $0x802247
  80035c:	e8 81 10 00 00       	call   8013e2 <_panic>

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
  8003ef:	68 55 22 80 00       	push   $0x802255
  8003f4:	6a 1e                	push   $0x1e
  8003f6:	68 65 22 80 00       	push   $0x802265
  8003fb:	e8 e2 0f 00 00       	call   8013e2 <_panic>
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
  800419:	68 70 22 80 00       	push   $0x802270
  80041e:	6a 2c                	push   $0x2c
  800420:	68 65 22 80 00       	push   $0x802265
  800425:	e8 b8 0f 00 00       	call   8013e2 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80042a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800430:	83 ec 04             	sub    $0x4,%esp
  800433:	68 00 10 00 00       	push   $0x1000
  800438:	53                   	push   %ebx
  800439:	68 00 f0 7f 00       	push   $0x7ff000
  80043e:	e8 f7 17 00 00       	call   801c3a <memcpy>

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
  800461:	68 70 22 80 00       	push   $0x802270
  800466:	6a 33                	push   $0x33
  800468:	68 65 22 80 00       	push   $0x802265
  80046d:	e8 70 0f 00 00       	call   8013e2 <_panic>
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
  800489:	68 70 22 80 00       	push   $0x802270
  80048e:	6a 37                	push   $0x37
  800490:	68 65 22 80 00       	push   $0x802265
  800495:	e8 48 0f 00 00       	call   8013e2 <_panic>
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
  8004ad:	e8 d5 18 00 00       	call   801d87 <set_pgfault_handler>
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
  8004c6:	68 89 22 80 00       	push   $0x802289
  8004cb:	68 84 00 00 00       	push   $0x84
  8004d0:	68 65 22 80 00       	push   $0x802265
  8004d5:	e8 08 0f 00 00       	call   8013e2 <_panic>
  8004da:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e0:	75 24                	jne    800506 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004e2:	e8 53 fc ff ff       	call   80013a <sys_getenvid>
  8004e7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004ec:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  800582:	68 97 22 80 00       	push   $0x802297
  800587:	6a 54                	push   $0x54
  800589:	68 65 22 80 00       	push   $0x802265
  80058e:	e8 4f 0e 00 00       	call   8013e2 <_panic>
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
  8005c7:	68 97 22 80 00       	push   $0x802297
  8005cc:	6a 5b                	push   $0x5b
  8005ce:	68 65 22 80 00       	push   $0x802265
  8005d3:	e8 0a 0e 00 00       	call   8013e2 <_panic>
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
  8005f5:	68 97 22 80 00       	push   $0x802297
  8005fa:	6a 5f                	push   $0x5f
  8005fc:	68 65 22 80 00       	push   $0x802265
  800601:	e8 dc 0d 00 00       	call   8013e2 <_panic>
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
  80061f:	68 97 22 80 00       	push   $0x802297
  800624:	6a 64                	push   $0x64
  800626:	68 65 22 80 00       	push   $0x802265
  80062b:	e8 b2 0d 00 00       	call   8013e2 <_panic>
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
  800647:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
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
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80067c:	55                   	push   %ebp
  80067d:	89 e5                	mov    %esp,%ebp
  80067f:	56                   	push   %esi
  800680:	53                   	push   %ebx
  800681:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  800684:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	68 b0 22 80 00       	push   $0x8022b0
  800693:	e8 23 0e 00 00       	call   8014bb <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800698:	c7 04 24 82 00 80 00 	movl   $0x800082,(%esp)
  80069f:	e8 c5 fc ff ff       	call   800369 <sys_thread_create>
  8006a4:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006a6:	83 c4 08             	add    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	68 b0 22 80 00       	push   $0x8022b0
  8006af:	e8 07 0e 00 00       	call   8014bb <cprintf>
	return id;
}
  8006b4:	89 f0                	mov    %esi,%eax
  8006b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006b9:	5b                   	pop    %ebx
  8006ba:	5e                   	pop    %esi
  8006bb:	5d                   	pop    %ebp
  8006bc:	c3                   	ret    

008006bd <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  8006c3:	ff 75 08             	pushl  0x8(%ebp)
  8006c6:	e8 be fc ff ff       	call   800389 <sys_thread_free>
}
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  8006d6:	ff 75 08             	pushl  0x8(%ebp)
  8006d9:	e8 cb fc ff ff       	call   8003a9 <sys_thread_join>
}
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	05 00 00 00 30       	add    $0x30000000,%eax
  8006ee:	c1 e8 0c             	shr    $0xc,%eax
}
  8006f1:	5d                   	pop    %ebp
  8006f2:	c3                   	ret    

008006f3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f9:	05 00 00 00 30       	add    $0x30000000,%eax
  8006fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800703:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800710:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800715:	89 c2                	mov    %eax,%edx
  800717:	c1 ea 16             	shr    $0x16,%edx
  80071a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800721:	f6 c2 01             	test   $0x1,%dl
  800724:	74 11                	je     800737 <fd_alloc+0x2d>
  800726:	89 c2                	mov    %eax,%edx
  800728:	c1 ea 0c             	shr    $0xc,%edx
  80072b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800732:	f6 c2 01             	test   $0x1,%dl
  800735:	75 09                	jne    800740 <fd_alloc+0x36>
			*fd_store = fd;
  800737:	89 01                	mov    %eax,(%ecx)
			return 0;
  800739:	b8 00 00 00 00       	mov    $0x0,%eax
  80073e:	eb 17                	jmp    800757 <fd_alloc+0x4d>
  800740:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800745:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80074a:	75 c9                	jne    800715 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80074c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800752:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80075f:	83 f8 1f             	cmp    $0x1f,%eax
  800762:	77 36                	ja     80079a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800764:	c1 e0 0c             	shl    $0xc,%eax
  800767:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80076c:	89 c2                	mov    %eax,%edx
  80076e:	c1 ea 16             	shr    $0x16,%edx
  800771:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800778:	f6 c2 01             	test   $0x1,%dl
  80077b:	74 24                	je     8007a1 <fd_lookup+0x48>
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	c1 ea 0c             	shr    $0xc,%edx
  800782:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800789:	f6 c2 01             	test   $0x1,%dl
  80078c:	74 1a                	je     8007a8 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800791:	89 02                	mov    %eax,(%edx)
	return 0;
  800793:	b8 00 00 00 00       	mov    $0x0,%eax
  800798:	eb 13                	jmp    8007ad <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80079a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079f:	eb 0c                	jmp    8007ad <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a6:	eb 05                	jmp    8007ad <fd_lookup+0x54>
  8007a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	83 ec 08             	sub    $0x8,%esp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	ba 50 23 80 00       	mov    $0x802350,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007bd:	eb 13                	jmp    8007d2 <dev_lookup+0x23>
  8007bf:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007c2:	39 08                	cmp    %ecx,(%eax)
  8007c4:	75 0c                	jne    8007d2 <dev_lookup+0x23>
			*dev = devtab[i];
  8007c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	eb 31                	jmp    800803 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007d2:	8b 02                	mov    (%edx),%eax
  8007d4:	85 c0                	test   %eax,%eax
  8007d6:	75 e7                	jne    8007bf <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8007dd:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8007e3:	83 ec 04             	sub    $0x4,%esp
  8007e6:	51                   	push   %ecx
  8007e7:	50                   	push   %eax
  8007e8:	68 d4 22 80 00       	push   $0x8022d4
  8007ed:	e8 c9 0c 00 00       	call   8014bb <cprintf>
	*dev = 0;
  8007f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800803:	c9                   	leave  
  800804:	c3                   	ret    

00800805 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	83 ec 10             	sub    $0x10,%esp
  80080d:	8b 75 08             	mov    0x8(%ebp),%esi
  800810:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800813:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800816:	50                   	push   %eax
  800817:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80081d:	c1 e8 0c             	shr    $0xc,%eax
  800820:	50                   	push   %eax
  800821:	e8 33 ff ff ff       	call   800759 <fd_lookup>
  800826:	83 c4 08             	add    $0x8,%esp
  800829:	85 c0                	test   %eax,%eax
  80082b:	78 05                	js     800832 <fd_close+0x2d>
	    || fd != fd2)
  80082d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800830:	74 0c                	je     80083e <fd_close+0x39>
		return (must_exist ? r : 0);
  800832:	84 db                	test   %bl,%bl
  800834:	ba 00 00 00 00       	mov    $0x0,%edx
  800839:	0f 44 c2             	cmove  %edx,%eax
  80083c:	eb 41                	jmp    80087f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800844:	50                   	push   %eax
  800845:	ff 36                	pushl  (%esi)
  800847:	e8 63 ff ff ff       	call   8007af <dev_lookup>
  80084c:	89 c3                	mov    %eax,%ebx
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	85 c0                	test   %eax,%eax
  800853:	78 1a                	js     80086f <fd_close+0x6a>
		if (dev->dev_close)
  800855:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800858:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80085b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800860:	85 c0                	test   %eax,%eax
  800862:	74 0b                	je     80086f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800864:	83 ec 0c             	sub    $0xc,%esp
  800867:	56                   	push   %esi
  800868:	ff d0                	call   *%eax
  80086a:	89 c3                	mov    %eax,%ebx
  80086c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	56                   	push   %esi
  800873:	6a 00                	push   $0x0
  800875:	e8 83 f9 ff ff       	call   8001fd <sys_page_unmap>
	return r;
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	89 d8                	mov    %ebx,%eax
}
  80087f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80088c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088f:	50                   	push   %eax
  800890:	ff 75 08             	pushl  0x8(%ebp)
  800893:	e8 c1 fe ff ff       	call   800759 <fd_lookup>
  800898:	83 c4 08             	add    $0x8,%esp
  80089b:	85 c0                	test   %eax,%eax
  80089d:	78 10                	js     8008af <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	6a 01                	push   $0x1
  8008a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8008a7:	e8 59 ff ff ff       	call   800805 <fd_close>
  8008ac:	83 c4 10             	add    $0x10,%esp
}
  8008af:	c9                   	leave  
  8008b0:	c3                   	ret    

008008b1 <close_all>:

void
close_all(void)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008bd:	83 ec 0c             	sub    $0xc,%esp
  8008c0:	53                   	push   %ebx
  8008c1:	e8 c0 ff ff ff       	call   800886 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008c6:	83 c3 01             	add    $0x1,%ebx
  8008c9:	83 c4 10             	add    $0x10,%esp
  8008cc:	83 fb 20             	cmp    $0x20,%ebx
  8008cf:	75 ec                	jne    8008bd <close_all+0xc>
		close(i);
}
  8008d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	57                   	push   %edi
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
  8008dc:	83 ec 2c             	sub    $0x2c,%esp
  8008df:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008e5:	50                   	push   %eax
  8008e6:	ff 75 08             	pushl  0x8(%ebp)
  8008e9:	e8 6b fe ff ff       	call   800759 <fd_lookup>
  8008ee:	83 c4 08             	add    $0x8,%esp
  8008f1:	85 c0                	test   %eax,%eax
  8008f3:	0f 88 c1 00 00 00    	js     8009ba <dup+0xe4>
		return r;
	close(newfdnum);
  8008f9:	83 ec 0c             	sub    $0xc,%esp
  8008fc:	56                   	push   %esi
  8008fd:	e8 84 ff ff ff       	call   800886 <close>

	newfd = INDEX2FD(newfdnum);
  800902:	89 f3                	mov    %esi,%ebx
  800904:	c1 e3 0c             	shl    $0xc,%ebx
  800907:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80090d:	83 c4 04             	add    $0x4,%esp
  800910:	ff 75 e4             	pushl  -0x1c(%ebp)
  800913:	e8 db fd ff ff       	call   8006f3 <fd2data>
  800918:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80091a:	89 1c 24             	mov    %ebx,(%esp)
  80091d:	e8 d1 fd ff ff       	call   8006f3 <fd2data>
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800928:	89 f8                	mov    %edi,%eax
  80092a:	c1 e8 16             	shr    $0x16,%eax
  80092d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800934:	a8 01                	test   $0x1,%al
  800936:	74 37                	je     80096f <dup+0x99>
  800938:	89 f8                	mov    %edi,%eax
  80093a:	c1 e8 0c             	shr    $0xc,%eax
  80093d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800944:	f6 c2 01             	test   $0x1,%dl
  800947:	74 26                	je     80096f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800949:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800950:	83 ec 0c             	sub    $0xc,%esp
  800953:	25 07 0e 00 00       	and    $0xe07,%eax
  800958:	50                   	push   %eax
  800959:	ff 75 d4             	pushl  -0x2c(%ebp)
  80095c:	6a 00                	push   $0x0
  80095e:	57                   	push   %edi
  80095f:	6a 00                	push   $0x0
  800961:	e8 55 f8 ff ff       	call   8001bb <sys_page_map>
  800966:	89 c7                	mov    %eax,%edi
  800968:	83 c4 20             	add    $0x20,%esp
  80096b:	85 c0                	test   %eax,%eax
  80096d:	78 2e                	js     80099d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80096f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800972:	89 d0                	mov    %edx,%eax
  800974:	c1 e8 0c             	shr    $0xc,%eax
  800977:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80097e:	83 ec 0c             	sub    $0xc,%esp
  800981:	25 07 0e 00 00       	and    $0xe07,%eax
  800986:	50                   	push   %eax
  800987:	53                   	push   %ebx
  800988:	6a 00                	push   $0x0
  80098a:	52                   	push   %edx
  80098b:	6a 00                	push   $0x0
  80098d:	e8 29 f8 ff ff       	call   8001bb <sys_page_map>
  800992:	89 c7                	mov    %eax,%edi
  800994:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800997:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800999:	85 ff                	test   %edi,%edi
  80099b:	79 1d                	jns    8009ba <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80099d:	83 ec 08             	sub    $0x8,%esp
  8009a0:	53                   	push   %ebx
  8009a1:	6a 00                	push   $0x0
  8009a3:	e8 55 f8 ff ff       	call   8001fd <sys_page_unmap>
	sys_page_unmap(0, nva);
  8009a8:	83 c4 08             	add    $0x8,%esp
  8009ab:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009ae:	6a 00                	push   $0x0
  8009b0:	e8 48 f8 ff ff       	call   8001fd <sys_page_unmap>
	return r;
  8009b5:	83 c4 10             	add    $0x10,%esp
  8009b8:	89 f8                	mov    %edi,%eax
}
  8009ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009bd:	5b                   	pop    %ebx
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	53                   	push   %ebx
  8009c6:	83 ec 14             	sub    $0x14,%esp
  8009c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009cf:	50                   	push   %eax
  8009d0:	53                   	push   %ebx
  8009d1:	e8 83 fd ff ff       	call   800759 <fd_lookup>
  8009d6:	83 c4 08             	add    $0x8,%esp
  8009d9:	89 c2                	mov    %eax,%edx
  8009db:	85 c0                	test   %eax,%eax
  8009dd:	78 70                	js     800a4f <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009df:	83 ec 08             	sub    $0x8,%esp
  8009e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009e5:	50                   	push   %eax
  8009e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009e9:	ff 30                	pushl  (%eax)
  8009eb:	e8 bf fd ff ff       	call   8007af <dev_lookup>
  8009f0:	83 c4 10             	add    $0x10,%esp
  8009f3:	85 c0                	test   %eax,%eax
  8009f5:	78 4f                	js     800a46 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009f7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009fa:	8b 42 08             	mov    0x8(%edx),%eax
  8009fd:	83 e0 03             	and    $0x3,%eax
  800a00:	83 f8 01             	cmp    $0x1,%eax
  800a03:	75 24                	jne    800a29 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a05:	a1 04 40 80 00       	mov    0x804004,%eax
  800a0a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a10:	83 ec 04             	sub    $0x4,%esp
  800a13:	53                   	push   %ebx
  800a14:	50                   	push   %eax
  800a15:	68 15 23 80 00       	push   $0x802315
  800a1a:	e8 9c 0a 00 00       	call   8014bb <cprintf>
		return -E_INVAL;
  800a1f:	83 c4 10             	add    $0x10,%esp
  800a22:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a27:	eb 26                	jmp    800a4f <read+0x8d>
	}
	if (!dev->dev_read)
  800a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a2c:	8b 40 08             	mov    0x8(%eax),%eax
  800a2f:	85 c0                	test   %eax,%eax
  800a31:	74 17                	je     800a4a <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a33:	83 ec 04             	sub    $0x4,%esp
  800a36:	ff 75 10             	pushl  0x10(%ebp)
  800a39:	ff 75 0c             	pushl  0xc(%ebp)
  800a3c:	52                   	push   %edx
  800a3d:	ff d0                	call   *%eax
  800a3f:	89 c2                	mov    %eax,%edx
  800a41:	83 c4 10             	add    $0x10,%esp
  800a44:	eb 09                	jmp    800a4f <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a46:	89 c2                	mov    %eax,%edx
  800a48:	eb 05                	jmp    800a4f <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a4a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a4f:	89 d0                	mov    %edx,%eax
  800a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a54:	c9                   	leave  
  800a55:	c3                   	ret    

00800a56 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	57                   	push   %edi
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	83 ec 0c             	sub    $0xc,%esp
  800a5f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a62:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a6a:	eb 21                	jmp    800a8d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a6c:	83 ec 04             	sub    $0x4,%esp
  800a6f:	89 f0                	mov    %esi,%eax
  800a71:	29 d8                	sub    %ebx,%eax
  800a73:	50                   	push   %eax
  800a74:	89 d8                	mov    %ebx,%eax
  800a76:	03 45 0c             	add    0xc(%ebp),%eax
  800a79:	50                   	push   %eax
  800a7a:	57                   	push   %edi
  800a7b:	e8 42 ff ff ff       	call   8009c2 <read>
		if (m < 0)
  800a80:	83 c4 10             	add    $0x10,%esp
  800a83:	85 c0                	test   %eax,%eax
  800a85:	78 10                	js     800a97 <readn+0x41>
			return m;
		if (m == 0)
  800a87:	85 c0                	test   %eax,%eax
  800a89:	74 0a                	je     800a95 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a8b:	01 c3                	add    %eax,%ebx
  800a8d:	39 f3                	cmp    %esi,%ebx
  800a8f:	72 db                	jb     800a6c <readn+0x16>
  800a91:	89 d8                	mov    %ebx,%eax
  800a93:	eb 02                	jmp    800a97 <readn+0x41>
  800a95:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5f                   	pop    %edi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	53                   	push   %ebx
  800aa3:	83 ec 14             	sub    $0x14,%esp
  800aa6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800aa9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aac:	50                   	push   %eax
  800aad:	53                   	push   %ebx
  800aae:	e8 a6 fc ff ff       	call   800759 <fd_lookup>
  800ab3:	83 c4 08             	add    $0x8,%esp
  800ab6:	89 c2                	mov    %eax,%edx
  800ab8:	85 c0                	test   %eax,%eax
  800aba:	78 6b                	js     800b27 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800abc:	83 ec 08             	sub    $0x8,%esp
  800abf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac2:	50                   	push   %eax
  800ac3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ac6:	ff 30                	pushl  (%eax)
  800ac8:	e8 e2 fc ff ff       	call   8007af <dev_lookup>
  800acd:	83 c4 10             	add    $0x10,%esp
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	78 4a                	js     800b1e <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ad4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ad7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800adb:	75 24                	jne    800b01 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800add:	a1 04 40 80 00       	mov    0x804004,%eax
  800ae2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800ae8:	83 ec 04             	sub    $0x4,%esp
  800aeb:	53                   	push   %ebx
  800aec:	50                   	push   %eax
  800aed:	68 31 23 80 00       	push   $0x802331
  800af2:	e8 c4 09 00 00       	call   8014bb <cprintf>
		return -E_INVAL;
  800af7:	83 c4 10             	add    $0x10,%esp
  800afa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800aff:	eb 26                	jmp    800b27 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b04:	8b 52 0c             	mov    0xc(%edx),%edx
  800b07:	85 d2                	test   %edx,%edx
  800b09:	74 17                	je     800b22 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b0b:	83 ec 04             	sub    $0x4,%esp
  800b0e:	ff 75 10             	pushl  0x10(%ebp)
  800b11:	ff 75 0c             	pushl  0xc(%ebp)
  800b14:	50                   	push   %eax
  800b15:	ff d2                	call   *%edx
  800b17:	89 c2                	mov    %eax,%edx
  800b19:	83 c4 10             	add    $0x10,%esp
  800b1c:	eb 09                	jmp    800b27 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b1e:	89 c2                	mov    %eax,%edx
  800b20:	eb 05                	jmp    800b27 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b22:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b27:	89 d0                	mov    %edx,%eax
  800b29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <seek>:

int
seek(int fdnum, off_t offset)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b34:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b37:	50                   	push   %eax
  800b38:	ff 75 08             	pushl  0x8(%ebp)
  800b3b:	e8 19 fc ff ff       	call   800759 <fd_lookup>
  800b40:	83 c4 08             	add    $0x8,%esp
  800b43:	85 c0                	test   %eax,%eax
  800b45:	78 0e                	js     800b55 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b47:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b55:	c9                   	leave  
  800b56:	c3                   	ret    

00800b57 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	53                   	push   %ebx
  800b5b:	83 ec 14             	sub    $0x14,%esp
  800b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b61:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b64:	50                   	push   %eax
  800b65:	53                   	push   %ebx
  800b66:	e8 ee fb ff ff       	call   800759 <fd_lookup>
  800b6b:	83 c4 08             	add    $0x8,%esp
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	85 c0                	test   %eax,%eax
  800b72:	78 68                	js     800bdc <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b74:	83 ec 08             	sub    $0x8,%esp
  800b77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b7a:	50                   	push   %eax
  800b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b7e:	ff 30                	pushl  (%eax)
  800b80:	e8 2a fc ff ff       	call   8007af <dev_lookup>
  800b85:	83 c4 10             	add    $0x10,%esp
  800b88:	85 c0                	test   %eax,%eax
  800b8a:	78 47                	js     800bd3 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b8f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b93:	75 24                	jne    800bb9 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b95:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b9a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800ba0:	83 ec 04             	sub    $0x4,%esp
  800ba3:	53                   	push   %ebx
  800ba4:	50                   	push   %eax
  800ba5:	68 f4 22 80 00       	push   $0x8022f4
  800baa:	e8 0c 09 00 00       	call   8014bb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800baf:	83 c4 10             	add    $0x10,%esp
  800bb2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bb7:	eb 23                	jmp    800bdc <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800bb9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bbc:	8b 52 18             	mov    0x18(%edx),%edx
  800bbf:	85 d2                	test   %edx,%edx
  800bc1:	74 14                	je     800bd7 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800bc3:	83 ec 08             	sub    $0x8,%esp
  800bc6:	ff 75 0c             	pushl  0xc(%ebp)
  800bc9:	50                   	push   %eax
  800bca:	ff d2                	call   *%edx
  800bcc:	89 c2                	mov    %eax,%edx
  800bce:	83 c4 10             	add    $0x10,%esp
  800bd1:	eb 09                	jmp    800bdc <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bd3:	89 c2                	mov    %eax,%edx
  800bd5:	eb 05                	jmp    800bdc <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800bd7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800bdc:	89 d0                	mov    %edx,%eax
  800bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	53                   	push   %ebx
  800be7:	83 ec 14             	sub    $0x14,%esp
  800bea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bf0:	50                   	push   %eax
  800bf1:	ff 75 08             	pushl  0x8(%ebp)
  800bf4:	e8 60 fb ff ff       	call   800759 <fd_lookup>
  800bf9:	83 c4 08             	add    $0x8,%esp
  800bfc:	89 c2                	mov    %eax,%edx
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	78 58                	js     800c5a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c02:	83 ec 08             	sub    $0x8,%esp
  800c05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c08:	50                   	push   %eax
  800c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c0c:	ff 30                	pushl  (%eax)
  800c0e:	e8 9c fb ff ff       	call   8007af <dev_lookup>
  800c13:	83 c4 10             	add    $0x10,%esp
  800c16:	85 c0                	test   %eax,%eax
  800c18:	78 37                	js     800c51 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c21:	74 32                	je     800c55 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c23:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c26:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c2d:	00 00 00 
	stat->st_isdir = 0;
  800c30:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c37:	00 00 00 
	stat->st_dev = dev;
  800c3a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c40:	83 ec 08             	sub    $0x8,%esp
  800c43:	53                   	push   %ebx
  800c44:	ff 75 f0             	pushl  -0x10(%ebp)
  800c47:	ff 50 14             	call   *0x14(%eax)
  800c4a:	89 c2                	mov    %eax,%edx
  800c4c:	83 c4 10             	add    $0x10,%esp
  800c4f:	eb 09                	jmp    800c5a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c51:	89 c2                	mov    %eax,%edx
  800c53:	eb 05                	jmp    800c5a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c55:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c5a:	89 d0                	mov    %edx,%eax
  800c5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c5f:	c9                   	leave  
  800c60:	c3                   	ret    

00800c61 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c66:	83 ec 08             	sub    $0x8,%esp
  800c69:	6a 00                	push   $0x0
  800c6b:	ff 75 08             	pushl  0x8(%ebp)
  800c6e:	e8 e3 01 00 00       	call   800e56 <open>
  800c73:	89 c3                	mov    %eax,%ebx
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	78 1b                	js     800c97 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c7c:	83 ec 08             	sub    $0x8,%esp
  800c7f:	ff 75 0c             	pushl  0xc(%ebp)
  800c82:	50                   	push   %eax
  800c83:	e8 5b ff ff ff       	call   800be3 <fstat>
  800c88:	89 c6                	mov    %eax,%esi
	close(fd);
  800c8a:	89 1c 24             	mov    %ebx,(%esp)
  800c8d:	e8 f4 fb ff ff       	call   800886 <close>
	return r;
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	89 f0                	mov    %esi,%eax
}
  800c97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	89 c6                	mov    %eax,%esi
  800ca5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800ca7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800cae:	75 12                	jne    800cc2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	6a 01                	push   $0x1
  800cb5:	e8 39 12 00 00       	call   801ef3 <ipc_find_env>
  800cba:	a3 00 40 80 00       	mov    %eax,0x804000
  800cbf:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800cc2:	6a 07                	push   $0x7
  800cc4:	68 00 50 80 00       	push   $0x805000
  800cc9:	56                   	push   %esi
  800cca:	ff 35 00 40 80 00    	pushl  0x804000
  800cd0:	e8 bc 11 00 00       	call   801e91 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800cd5:	83 c4 0c             	add    $0xc,%esp
  800cd8:	6a 00                	push   $0x0
  800cda:	53                   	push   %ebx
  800cdb:	6a 00                	push   $0x0
  800cdd:	e8 34 11 00 00       	call   801e16 <ipc_recv>
}
  800ce2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cef:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf2:	8b 40 0c             	mov    0xc(%eax),%eax
  800cf5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfd:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d02:	ba 00 00 00 00       	mov    $0x0,%edx
  800d07:	b8 02 00 00 00       	mov    $0x2,%eax
  800d0c:	e8 8d ff ff ff       	call   800c9e <fsipc>
}
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    

00800d13 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	8b 40 0c             	mov    0xc(%eax),%eax
  800d1f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d24:	ba 00 00 00 00       	mov    $0x0,%edx
  800d29:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2e:	e8 6b ff ff ff       	call   800c9e <fsipc>
}
  800d33:	c9                   	leave  
  800d34:	c3                   	ret    

00800d35 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	53                   	push   %ebx
  800d39:	83 ec 04             	sub    $0x4,%esp
  800d3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	8b 40 0c             	mov    0xc(%eax),%eax
  800d45:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800d54:	e8 45 ff ff ff       	call   800c9e <fsipc>
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	78 2c                	js     800d89 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d5d:	83 ec 08             	sub    $0x8,%esp
  800d60:	68 00 50 80 00       	push   $0x805000
  800d65:	53                   	push   %ebx
  800d66:	e8 d5 0c 00 00       	call   801a40 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d6b:	a1 80 50 80 00       	mov    0x805080,%eax
  800d70:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d76:	a1 84 50 80 00       	mov    0x805084,%eax
  800d7b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d81:	83 c4 10             	add    $0x10,%esp
  800d84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d8c:	c9                   	leave  
  800d8d:	c3                   	ret    

00800d8e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	8b 52 0c             	mov    0xc(%edx),%edx
  800d9d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800da3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800da8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800dad:	0f 47 c2             	cmova  %edx,%eax
  800db0:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800db5:	50                   	push   %eax
  800db6:	ff 75 0c             	pushl  0xc(%ebp)
  800db9:	68 08 50 80 00       	push   $0x805008
  800dbe:	e8 0f 0e 00 00       	call   801bd2 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800dc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc8:	b8 04 00 00 00       	mov    $0x4,%eax
  800dcd:	e8 cc fe ff ff       	call   800c9e <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800dd2:	c9                   	leave  
  800dd3:	c3                   	ret    

00800dd4 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	8b 40 0c             	mov    0xc(%eax),%eax
  800de2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800de7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ded:	ba 00 00 00 00       	mov    $0x0,%edx
  800df2:	b8 03 00 00 00       	mov    $0x3,%eax
  800df7:	e8 a2 fe ff ff       	call   800c9e <fsipc>
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	78 4b                	js     800e4d <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e02:	39 c6                	cmp    %eax,%esi
  800e04:	73 16                	jae    800e1c <devfile_read+0x48>
  800e06:	68 60 23 80 00       	push   $0x802360
  800e0b:	68 67 23 80 00       	push   $0x802367
  800e10:	6a 7c                	push   $0x7c
  800e12:	68 7c 23 80 00       	push   $0x80237c
  800e17:	e8 c6 05 00 00       	call   8013e2 <_panic>
	assert(r <= PGSIZE);
  800e1c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e21:	7e 16                	jle    800e39 <devfile_read+0x65>
  800e23:	68 87 23 80 00       	push   $0x802387
  800e28:	68 67 23 80 00       	push   $0x802367
  800e2d:	6a 7d                	push   $0x7d
  800e2f:	68 7c 23 80 00       	push   $0x80237c
  800e34:	e8 a9 05 00 00       	call   8013e2 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e39:	83 ec 04             	sub    $0x4,%esp
  800e3c:	50                   	push   %eax
  800e3d:	68 00 50 80 00       	push   $0x805000
  800e42:	ff 75 0c             	pushl  0xc(%ebp)
  800e45:	e8 88 0d 00 00       	call   801bd2 <memmove>
	return r;
  800e4a:	83 c4 10             	add    $0x10,%esp
}
  800e4d:	89 d8                	mov    %ebx,%eax
  800e4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e52:	5b                   	pop    %ebx
  800e53:	5e                   	pop    %esi
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 20             	sub    $0x20,%esp
  800e5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e60:	53                   	push   %ebx
  800e61:	e8 a1 0b 00 00       	call   801a07 <strlen>
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e6e:	7f 67                	jg     800ed7 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e70:	83 ec 0c             	sub    $0xc,%esp
  800e73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e76:	50                   	push   %eax
  800e77:	e8 8e f8 ff ff       	call   80070a <fd_alloc>
  800e7c:	83 c4 10             	add    $0x10,%esp
		return r;
  800e7f:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e81:	85 c0                	test   %eax,%eax
  800e83:	78 57                	js     800edc <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e85:	83 ec 08             	sub    $0x8,%esp
  800e88:	53                   	push   %ebx
  800e89:	68 00 50 80 00       	push   $0x805000
  800e8e:	e8 ad 0b 00 00       	call   801a40 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e96:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea3:	e8 f6 fd ff ff       	call   800c9e <fsipc>
  800ea8:	89 c3                	mov    %eax,%ebx
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	79 14                	jns    800ec5 <open+0x6f>
		fd_close(fd, 0);
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	6a 00                	push   $0x0
  800eb6:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb9:	e8 47 f9 ff ff       	call   800805 <fd_close>
		return r;
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	89 da                	mov    %ebx,%edx
  800ec3:	eb 17                	jmp    800edc <open+0x86>
	}

	return fd2num(fd);
  800ec5:	83 ec 0c             	sub    $0xc,%esp
  800ec8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ecb:	e8 13 f8 ff ff       	call   8006e3 <fd2num>
  800ed0:	89 c2                	mov    %eax,%edx
  800ed2:	83 c4 10             	add    $0x10,%esp
  800ed5:	eb 05                	jmp    800edc <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ed7:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800edc:	89 d0                	mov    %edx,%eax
  800ede:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    

00800ee3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ee9:	ba 00 00 00 00       	mov    $0x0,%edx
  800eee:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef3:	e8 a6 fd ff ff       	call   800c9e <fsipc>
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f02:	83 ec 0c             	sub    $0xc,%esp
  800f05:	ff 75 08             	pushl  0x8(%ebp)
  800f08:	e8 e6 f7 ff ff       	call   8006f3 <fd2data>
  800f0d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f0f:	83 c4 08             	add    $0x8,%esp
  800f12:	68 93 23 80 00       	push   $0x802393
  800f17:	53                   	push   %ebx
  800f18:	e8 23 0b 00 00       	call   801a40 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f1d:	8b 46 04             	mov    0x4(%esi),%eax
  800f20:	2b 06                	sub    (%esi),%eax
  800f22:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f28:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f2f:	00 00 00 
	stat->st_dev = &devpipe;
  800f32:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f39:	30 80 00 
	return 0;
}
  800f3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	53                   	push   %ebx
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f52:	53                   	push   %ebx
  800f53:	6a 00                	push   $0x0
  800f55:	e8 a3 f2 ff ff       	call   8001fd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f5a:	89 1c 24             	mov    %ebx,(%esp)
  800f5d:	e8 91 f7 ff ff       	call   8006f3 <fd2data>
  800f62:	83 c4 08             	add    $0x8,%esp
  800f65:	50                   	push   %eax
  800f66:	6a 00                	push   $0x0
  800f68:	e8 90 f2 ff ff       	call   8001fd <sys_page_unmap>
}
  800f6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 1c             	sub    $0x1c,%esp
  800f7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f7e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f80:	a1 04 40 80 00       	mov    0x804004,%eax
  800f85:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	ff 75 e0             	pushl  -0x20(%ebp)
  800f91:	e8 a2 0f 00 00       	call   801f38 <pageref>
  800f96:	89 c3                	mov    %eax,%ebx
  800f98:	89 3c 24             	mov    %edi,(%esp)
  800f9b:	e8 98 0f 00 00       	call   801f38 <pageref>
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	39 c3                	cmp    %eax,%ebx
  800fa5:	0f 94 c1             	sete   %cl
  800fa8:	0f b6 c9             	movzbl %cl,%ecx
  800fab:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800fae:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fb4:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  800fba:	39 ce                	cmp    %ecx,%esi
  800fbc:	74 1e                	je     800fdc <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800fbe:	39 c3                	cmp    %eax,%ebx
  800fc0:	75 be                	jne    800f80 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fc2:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  800fc8:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fcb:	50                   	push   %eax
  800fcc:	56                   	push   %esi
  800fcd:	68 9a 23 80 00       	push   $0x80239a
  800fd2:	e8 e4 04 00 00       	call   8014bb <cprintf>
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	eb a4                	jmp    800f80 <_pipeisclosed+0xe>
	}
}
  800fdc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe2:	5b                   	pop    %ebx
  800fe3:	5e                   	pop    %esi
  800fe4:	5f                   	pop    %edi
  800fe5:	5d                   	pop    %ebp
  800fe6:	c3                   	ret    

00800fe7 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	57                   	push   %edi
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
  800fed:	83 ec 28             	sub    $0x28,%esp
  800ff0:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800ff3:	56                   	push   %esi
  800ff4:	e8 fa f6 ff ff       	call   8006f3 <fd2data>
  800ff9:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ffb:	83 c4 10             	add    $0x10,%esp
  800ffe:	bf 00 00 00 00       	mov    $0x0,%edi
  801003:	eb 4b                	jmp    801050 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801005:	89 da                	mov    %ebx,%edx
  801007:	89 f0                	mov    %esi,%eax
  801009:	e8 64 ff ff ff       	call   800f72 <_pipeisclosed>
  80100e:	85 c0                	test   %eax,%eax
  801010:	75 48                	jne    80105a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801012:	e8 42 f1 ff ff       	call   800159 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801017:	8b 43 04             	mov    0x4(%ebx),%eax
  80101a:	8b 0b                	mov    (%ebx),%ecx
  80101c:	8d 51 20             	lea    0x20(%ecx),%edx
  80101f:	39 d0                	cmp    %edx,%eax
  801021:	73 e2                	jae    801005 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801026:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80102a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80102d:	89 c2                	mov    %eax,%edx
  80102f:	c1 fa 1f             	sar    $0x1f,%edx
  801032:	89 d1                	mov    %edx,%ecx
  801034:	c1 e9 1b             	shr    $0x1b,%ecx
  801037:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80103a:	83 e2 1f             	and    $0x1f,%edx
  80103d:	29 ca                	sub    %ecx,%edx
  80103f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801043:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801047:	83 c0 01             	add    $0x1,%eax
  80104a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80104d:	83 c7 01             	add    $0x1,%edi
  801050:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801053:	75 c2                	jne    801017 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801055:	8b 45 10             	mov    0x10(%ebp),%eax
  801058:	eb 05                	jmp    80105f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80105a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80105f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801062:	5b                   	pop    %ebx
  801063:	5e                   	pop    %esi
  801064:	5f                   	pop    %edi
  801065:	5d                   	pop    %ebp
  801066:	c3                   	ret    

00801067 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	57                   	push   %edi
  80106b:	56                   	push   %esi
  80106c:	53                   	push   %ebx
  80106d:	83 ec 18             	sub    $0x18,%esp
  801070:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801073:	57                   	push   %edi
  801074:	e8 7a f6 ff ff       	call   8006f3 <fd2data>
  801079:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801083:	eb 3d                	jmp    8010c2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801085:	85 db                	test   %ebx,%ebx
  801087:	74 04                	je     80108d <devpipe_read+0x26>
				return i;
  801089:	89 d8                	mov    %ebx,%eax
  80108b:	eb 44                	jmp    8010d1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80108d:	89 f2                	mov    %esi,%edx
  80108f:	89 f8                	mov    %edi,%eax
  801091:	e8 dc fe ff ff       	call   800f72 <_pipeisclosed>
  801096:	85 c0                	test   %eax,%eax
  801098:	75 32                	jne    8010cc <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80109a:	e8 ba f0 ff ff       	call   800159 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80109f:	8b 06                	mov    (%esi),%eax
  8010a1:	3b 46 04             	cmp    0x4(%esi),%eax
  8010a4:	74 df                	je     801085 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010a6:	99                   	cltd   
  8010a7:	c1 ea 1b             	shr    $0x1b,%edx
  8010aa:	01 d0                	add    %edx,%eax
  8010ac:	83 e0 1f             	and    $0x1f,%eax
  8010af:	29 d0                	sub    %edx,%eax
  8010b1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010bc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010bf:	83 c3 01             	add    $0x1,%ebx
  8010c2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010c5:	75 d8                	jne    80109f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8010ca:	eb 05                	jmp    8010d1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010cc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    

008010d9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010d9:	55                   	push   %ebp
  8010da:	89 e5                	mov    %esp,%ebp
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e4:	50                   	push   %eax
  8010e5:	e8 20 f6 ff ff       	call   80070a <fd_alloc>
  8010ea:	83 c4 10             	add    $0x10,%esp
  8010ed:	89 c2                	mov    %eax,%edx
  8010ef:	85 c0                	test   %eax,%eax
  8010f1:	0f 88 2c 01 00 00    	js     801223 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010f7:	83 ec 04             	sub    $0x4,%esp
  8010fa:	68 07 04 00 00       	push   $0x407
  8010ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801102:	6a 00                	push   $0x0
  801104:	e8 6f f0 ff ff       	call   800178 <sys_page_alloc>
  801109:	83 c4 10             	add    $0x10,%esp
  80110c:	89 c2                	mov    %eax,%edx
  80110e:	85 c0                	test   %eax,%eax
  801110:	0f 88 0d 01 00 00    	js     801223 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801116:	83 ec 0c             	sub    $0xc,%esp
  801119:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111c:	50                   	push   %eax
  80111d:	e8 e8 f5 ff ff       	call   80070a <fd_alloc>
  801122:	89 c3                	mov    %eax,%ebx
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	0f 88 e2 00 00 00    	js     801211 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80112f:	83 ec 04             	sub    $0x4,%esp
  801132:	68 07 04 00 00       	push   $0x407
  801137:	ff 75 f0             	pushl  -0x10(%ebp)
  80113a:	6a 00                	push   $0x0
  80113c:	e8 37 f0 ff ff       	call   800178 <sys_page_alloc>
  801141:	89 c3                	mov    %eax,%ebx
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	0f 88 c3 00 00 00    	js     801211 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80114e:	83 ec 0c             	sub    $0xc,%esp
  801151:	ff 75 f4             	pushl  -0xc(%ebp)
  801154:	e8 9a f5 ff ff       	call   8006f3 <fd2data>
  801159:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80115b:	83 c4 0c             	add    $0xc,%esp
  80115e:	68 07 04 00 00       	push   $0x407
  801163:	50                   	push   %eax
  801164:	6a 00                	push   $0x0
  801166:	e8 0d f0 ff ff       	call   800178 <sys_page_alloc>
  80116b:	89 c3                	mov    %eax,%ebx
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	85 c0                	test   %eax,%eax
  801172:	0f 88 89 00 00 00    	js     801201 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801178:	83 ec 0c             	sub    $0xc,%esp
  80117b:	ff 75 f0             	pushl  -0x10(%ebp)
  80117e:	e8 70 f5 ff ff       	call   8006f3 <fd2data>
  801183:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80118a:	50                   	push   %eax
  80118b:	6a 00                	push   $0x0
  80118d:	56                   	push   %esi
  80118e:	6a 00                	push   $0x0
  801190:	e8 26 f0 ff ff       	call   8001bb <sys_page_map>
  801195:	89 c3                	mov    %eax,%ebx
  801197:	83 c4 20             	add    $0x20,%esp
  80119a:	85 c0                	test   %eax,%eax
  80119c:	78 55                	js     8011f3 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80119e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ac:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011b3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011bc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011c8:	83 ec 0c             	sub    $0xc,%esp
  8011cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ce:	e8 10 f5 ff ff       	call   8006e3 <fd2num>
  8011d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011d8:	83 c4 04             	add    $0x4,%esp
  8011db:	ff 75 f0             	pushl  -0x10(%ebp)
  8011de:	e8 00 f5 ff ff       	call   8006e3 <fd2num>
  8011e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e6:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f1:	eb 30                	jmp    801223 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011f3:	83 ec 08             	sub    $0x8,%esp
  8011f6:	56                   	push   %esi
  8011f7:	6a 00                	push   $0x0
  8011f9:	e8 ff ef ff ff       	call   8001fd <sys_page_unmap>
  8011fe:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801201:	83 ec 08             	sub    $0x8,%esp
  801204:	ff 75 f0             	pushl  -0x10(%ebp)
  801207:	6a 00                	push   $0x0
  801209:	e8 ef ef ff ff       	call   8001fd <sys_page_unmap>
  80120e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801211:	83 ec 08             	sub    $0x8,%esp
  801214:	ff 75 f4             	pushl  -0xc(%ebp)
  801217:	6a 00                	push   $0x0
  801219:	e8 df ef ff ff       	call   8001fd <sys_page_unmap>
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801223:	89 d0                	mov    %edx,%eax
  801225:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801235:	50                   	push   %eax
  801236:	ff 75 08             	pushl  0x8(%ebp)
  801239:	e8 1b f5 ff ff       	call   800759 <fd_lookup>
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	85 c0                	test   %eax,%eax
  801243:	78 18                	js     80125d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801245:	83 ec 0c             	sub    $0xc,%esp
  801248:	ff 75 f4             	pushl  -0xc(%ebp)
  80124b:	e8 a3 f4 ff ff       	call   8006f3 <fd2data>
	return _pipeisclosed(fd, p);
  801250:	89 c2                	mov    %eax,%edx
  801252:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801255:	e8 18 fd ff ff       	call   800f72 <_pipeisclosed>
  80125a:	83 c4 10             	add    $0x10,%esp
}
  80125d:	c9                   	leave  
  80125e:	c3                   	ret    

0080125f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801262:	b8 00 00 00 00       	mov    $0x0,%eax
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801269:	55                   	push   %ebp
  80126a:	89 e5                	mov    %esp,%ebp
  80126c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80126f:	68 b2 23 80 00       	push   $0x8023b2
  801274:	ff 75 0c             	pushl  0xc(%ebp)
  801277:	e8 c4 07 00 00       	call   801a40 <strcpy>
	return 0;
}
  80127c:	b8 00 00 00 00       	mov    $0x0,%eax
  801281:	c9                   	leave  
  801282:	c3                   	ret    

00801283 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	57                   	push   %edi
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80128f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801294:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80129a:	eb 2d                	jmp    8012c9 <devcons_write+0x46>
		m = n - tot;
  80129c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80129f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8012a1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012a4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8012a9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012ac:	83 ec 04             	sub    $0x4,%esp
  8012af:	53                   	push   %ebx
  8012b0:	03 45 0c             	add    0xc(%ebp),%eax
  8012b3:	50                   	push   %eax
  8012b4:	57                   	push   %edi
  8012b5:	e8 18 09 00 00       	call   801bd2 <memmove>
		sys_cputs(buf, m);
  8012ba:	83 c4 08             	add    $0x8,%esp
  8012bd:	53                   	push   %ebx
  8012be:	57                   	push   %edi
  8012bf:	e8 f8 ed ff ff       	call   8000bc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012c4:	01 de                	add    %ebx,%esi
  8012c6:	83 c4 10             	add    $0x10,%esp
  8012c9:	89 f0                	mov    %esi,%eax
  8012cb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012ce:	72 cc                	jb     80129c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d3:	5b                   	pop    %ebx
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    

008012d8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012d8:	55                   	push   %ebp
  8012d9:	89 e5                	mov    %esp,%ebp
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012e7:	74 2a                	je     801313 <devcons_read+0x3b>
  8012e9:	eb 05                	jmp    8012f0 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012eb:	e8 69 ee ff ff       	call   800159 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012f0:	e8 e5 ed ff ff       	call   8000da <sys_cgetc>
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	74 f2                	je     8012eb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	78 16                	js     801313 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012fd:	83 f8 04             	cmp    $0x4,%eax
  801300:	74 0c                	je     80130e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801302:	8b 55 0c             	mov    0xc(%ebp),%edx
  801305:	88 02                	mov    %al,(%edx)
	return 1;
  801307:	b8 01 00 00 00       	mov    $0x1,%eax
  80130c:	eb 05                	jmp    801313 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80130e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801313:	c9                   	leave  
  801314:	c3                   	ret    

00801315 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80131b:	8b 45 08             	mov    0x8(%ebp),%eax
  80131e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801321:	6a 01                	push   $0x1
  801323:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	e8 90 ed ff ff       	call   8000bc <sys_cputs>
}
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	c9                   	leave  
  801330:	c3                   	ret    

00801331 <getchar>:

int
getchar(void)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801337:	6a 01                	push   $0x1
  801339:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80133c:	50                   	push   %eax
  80133d:	6a 00                	push   $0x0
  80133f:	e8 7e f6 ff ff       	call   8009c2 <read>
	if (r < 0)
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 0f                	js     80135a <getchar+0x29>
		return r;
	if (r < 1)
  80134b:	85 c0                	test   %eax,%eax
  80134d:	7e 06                	jle    801355 <getchar+0x24>
		return -E_EOF;
	return c;
  80134f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801353:	eb 05                	jmp    80135a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801355:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80135a:	c9                   	leave  
  80135b:	c3                   	ret    

0080135c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801362:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	ff 75 08             	pushl  0x8(%ebp)
  801369:	e8 eb f3 ff ff       	call   800759 <fd_lookup>
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	85 c0                	test   %eax,%eax
  801373:	78 11                	js     801386 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801375:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801378:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80137e:	39 10                	cmp    %edx,(%eax)
  801380:	0f 94 c0             	sete   %al
  801383:	0f b6 c0             	movzbl %al,%eax
}
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <opencons>:

int
opencons(void)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80138e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801391:	50                   	push   %eax
  801392:	e8 73 f3 ff ff       	call   80070a <fd_alloc>
  801397:	83 c4 10             	add    $0x10,%esp
		return r;
  80139a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80139c:	85 c0                	test   %eax,%eax
  80139e:	78 3e                	js     8013de <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013a0:	83 ec 04             	sub    $0x4,%esp
  8013a3:	68 07 04 00 00       	push   $0x407
  8013a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ab:	6a 00                	push   $0x0
  8013ad:	e8 c6 ed ff ff       	call   800178 <sys_page_alloc>
  8013b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8013b5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 23                	js     8013de <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013bb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	50                   	push   %eax
  8013d4:	e8 0a f3 ff ff       	call   8006e3 <fd2num>
  8013d9:	89 c2                	mov    %eax,%edx
  8013db:	83 c4 10             	add    $0x10,%esp
}
  8013de:	89 d0                	mov    %edx,%eax
  8013e0:	c9                   	leave  
  8013e1:	c3                   	ret    

008013e2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	56                   	push   %esi
  8013e6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013e7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013ea:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013f0:	e8 45 ed ff ff       	call   80013a <sys_getenvid>
  8013f5:	83 ec 0c             	sub    $0xc,%esp
  8013f8:	ff 75 0c             	pushl  0xc(%ebp)
  8013fb:	ff 75 08             	pushl  0x8(%ebp)
  8013fe:	56                   	push   %esi
  8013ff:	50                   	push   %eax
  801400:	68 c0 23 80 00       	push   $0x8023c0
  801405:	e8 b1 00 00 00       	call   8014bb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80140a:	83 c4 18             	add    $0x18,%esp
  80140d:	53                   	push   %ebx
  80140e:	ff 75 10             	pushl  0x10(%ebp)
  801411:	e8 54 00 00 00       	call   80146a <vcprintf>
	cprintf("\n");
  801416:	c7 04 24 ab 23 80 00 	movl   $0x8023ab,(%esp)
  80141d:	e8 99 00 00 00       	call   8014bb <cprintf>
  801422:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801425:	cc                   	int3   
  801426:	eb fd                	jmp    801425 <_panic+0x43>

00801428 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 04             	sub    $0x4,%esp
  80142f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801432:	8b 13                	mov    (%ebx),%edx
  801434:	8d 42 01             	lea    0x1(%edx),%eax
  801437:	89 03                	mov    %eax,(%ebx)
  801439:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80143c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801440:	3d ff 00 00 00       	cmp    $0xff,%eax
  801445:	75 1a                	jne    801461 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	68 ff 00 00 00       	push   $0xff
  80144f:	8d 43 08             	lea    0x8(%ebx),%eax
  801452:	50                   	push   %eax
  801453:	e8 64 ec ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  801458:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80145e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801461:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801465:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801468:	c9                   	leave  
  801469:	c3                   	ret    

0080146a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801473:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80147a:	00 00 00 
	b.cnt = 0;
  80147d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801484:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801487:	ff 75 0c             	pushl  0xc(%ebp)
  80148a:	ff 75 08             	pushl  0x8(%ebp)
  80148d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801493:	50                   	push   %eax
  801494:	68 28 14 80 00       	push   $0x801428
  801499:	e8 54 01 00 00       	call   8015f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80149e:	83 c4 08             	add    $0x8,%esp
  8014a1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014a7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	e8 09 ec ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  8014b3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014c1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014c4:	50                   	push   %eax
  8014c5:	ff 75 08             	pushl  0x8(%ebp)
  8014c8:	e8 9d ff ff ff       	call   80146a <vcprintf>
	va_end(ap);

	return cnt;
}
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	57                   	push   %edi
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 1c             	sub    $0x1c,%esp
  8014d8:	89 c7                	mov    %eax,%edi
  8014da:	89 d6                	mov    %edx,%esi
  8014dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8014df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014f3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014f6:	39 d3                	cmp    %edx,%ebx
  8014f8:	72 05                	jb     8014ff <printnum+0x30>
  8014fa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014fd:	77 45                	ja     801544 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	ff 75 18             	pushl  0x18(%ebp)
  801505:	8b 45 14             	mov    0x14(%ebp),%eax
  801508:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80150b:	53                   	push   %ebx
  80150c:	ff 75 10             	pushl  0x10(%ebp)
  80150f:	83 ec 08             	sub    $0x8,%esp
  801512:	ff 75 e4             	pushl  -0x1c(%ebp)
  801515:	ff 75 e0             	pushl  -0x20(%ebp)
  801518:	ff 75 dc             	pushl  -0x24(%ebp)
  80151b:	ff 75 d8             	pushl  -0x28(%ebp)
  80151e:	e8 5d 0a 00 00       	call   801f80 <__udivdi3>
  801523:	83 c4 18             	add    $0x18,%esp
  801526:	52                   	push   %edx
  801527:	50                   	push   %eax
  801528:	89 f2                	mov    %esi,%edx
  80152a:	89 f8                	mov    %edi,%eax
  80152c:	e8 9e ff ff ff       	call   8014cf <printnum>
  801531:	83 c4 20             	add    $0x20,%esp
  801534:	eb 18                	jmp    80154e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	56                   	push   %esi
  80153a:	ff 75 18             	pushl  0x18(%ebp)
  80153d:	ff d7                	call   *%edi
  80153f:	83 c4 10             	add    $0x10,%esp
  801542:	eb 03                	jmp    801547 <printnum+0x78>
  801544:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801547:	83 eb 01             	sub    $0x1,%ebx
  80154a:	85 db                	test   %ebx,%ebx
  80154c:	7f e8                	jg     801536 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	56                   	push   %esi
  801552:	83 ec 04             	sub    $0x4,%esp
  801555:	ff 75 e4             	pushl  -0x1c(%ebp)
  801558:	ff 75 e0             	pushl  -0x20(%ebp)
  80155b:	ff 75 dc             	pushl  -0x24(%ebp)
  80155e:	ff 75 d8             	pushl  -0x28(%ebp)
  801561:	e8 4a 0b 00 00       	call   8020b0 <__umoddi3>
  801566:	83 c4 14             	add    $0x14,%esp
  801569:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  801570:	50                   	push   %eax
  801571:	ff d7                	call   *%edi
}
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801579:	5b                   	pop    %ebx
  80157a:	5e                   	pop    %esi
  80157b:	5f                   	pop    %edi
  80157c:	5d                   	pop    %ebp
  80157d:	c3                   	ret    

0080157e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801581:	83 fa 01             	cmp    $0x1,%edx
  801584:	7e 0e                	jle    801594 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801586:	8b 10                	mov    (%eax),%edx
  801588:	8d 4a 08             	lea    0x8(%edx),%ecx
  80158b:	89 08                	mov    %ecx,(%eax)
  80158d:	8b 02                	mov    (%edx),%eax
  80158f:	8b 52 04             	mov    0x4(%edx),%edx
  801592:	eb 22                	jmp    8015b6 <getuint+0x38>
	else if (lflag)
  801594:	85 d2                	test   %edx,%edx
  801596:	74 10                	je     8015a8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801598:	8b 10                	mov    (%eax),%edx
  80159a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80159d:	89 08                	mov    %ecx,(%eax)
  80159f:	8b 02                	mov    (%edx),%eax
  8015a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a6:	eb 0e                	jmp    8015b6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015a8:	8b 10                	mov    (%eax),%edx
  8015aa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015ad:	89 08                	mov    %ecx,(%eax)
  8015af:	8b 02                	mov    (%edx),%eax
  8015b1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015b6:	5d                   	pop    %ebp
  8015b7:	c3                   	ret    

008015b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015be:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015c2:	8b 10                	mov    (%eax),%edx
  8015c4:	3b 50 04             	cmp    0x4(%eax),%edx
  8015c7:	73 0a                	jae    8015d3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8015c9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015cc:	89 08                	mov    %ecx,(%eax)
  8015ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d1:	88 02                	mov    %al,(%edx)
}
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    

008015d5 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015de:	50                   	push   %eax
  8015df:	ff 75 10             	pushl  0x10(%ebp)
  8015e2:	ff 75 0c             	pushl  0xc(%ebp)
  8015e5:	ff 75 08             	pushl  0x8(%ebp)
  8015e8:	e8 05 00 00 00       	call   8015f2 <vprintfmt>
	va_end(ap);
}
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	57                   	push   %edi
  8015f6:	56                   	push   %esi
  8015f7:	53                   	push   %ebx
  8015f8:	83 ec 2c             	sub    $0x2c,%esp
  8015fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8015fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801601:	8b 7d 10             	mov    0x10(%ebp),%edi
  801604:	eb 12                	jmp    801618 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801606:	85 c0                	test   %eax,%eax
  801608:	0f 84 89 03 00 00    	je     801997 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	53                   	push   %ebx
  801612:	50                   	push   %eax
  801613:	ff d6                	call   *%esi
  801615:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801618:	83 c7 01             	add    $0x1,%edi
  80161b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80161f:	83 f8 25             	cmp    $0x25,%eax
  801622:	75 e2                	jne    801606 <vprintfmt+0x14>
  801624:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801628:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80162f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801636:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80163d:	ba 00 00 00 00       	mov    $0x0,%edx
  801642:	eb 07                	jmp    80164b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801644:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801647:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164b:	8d 47 01             	lea    0x1(%edi),%eax
  80164e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801651:	0f b6 07             	movzbl (%edi),%eax
  801654:	0f b6 c8             	movzbl %al,%ecx
  801657:	83 e8 23             	sub    $0x23,%eax
  80165a:	3c 55                	cmp    $0x55,%al
  80165c:	0f 87 1a 03 00 00    	ja     80197c <vprintfmt+0x38a>
  801662:	0f b6 c0             	movzbl %al,%eax
  801665:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80166c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80166f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801673:	eb d6                	jmp    80164b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801675:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801678:	b8 00 00 00 00       	mov    $0x0,%eax
  80167d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801680:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801683:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801687:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80168a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80168d:	83 fa 09             	cmp    $0x9,%edx
  801690:	77 39                	ja     8016cb <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801692:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801695:	eb e9                	jmp    801680 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801697:	8b 45 14             	mov    0x14(%ebp),%eax
  80169a:	8d 48 04             	lea    0x4(%eax),%ecx
  80169d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8016a0:	8b 00                	mov    (%eax),%eax
  8016a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016a8:	eb 27                	jmp    8016d1 <vprintfmt+0xdf>
  8016aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016b4:	0f 49 c8             	cmovns %eax,%ecx
  8016b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016bd:	eb 8c                	jmp    80164b <vprintfmt+0x59>
  8016bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8016c2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016c9:	eb 80                	jmp    80164b <vprintfmt+0x59>
  8016cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016ce:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016d5:	0f 89 70 ff ff ff    	jns    80164b <vprintfmt+0x59>
				width = precision, precision = -1;
  8016db:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016e1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016e8:	e9 5e ff ff ff       	jmp    80164b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016ed:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016f3:	e9 53 ff ff ff       	jmp    80164b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016fb:	8d 50 04             	lea    0x4(%eax),%edx
  8016fe:	89 55 14             	mov    %edx,0x14(%ebp)
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	53                   	push   %ebx
  801705:	ff 30                	pushl  (%eax)
  801707:	ff d6                	call   *%esi
			break;
  801709:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80170f:	e9 04 ff ff ff       	jmp    801618 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801714:	8b 45 14             	mov    0x14(%ebp),%eax
  801717:	8d 50 04             	lea    0x4(%eax),%edx
  80171a:	89 55 14             	mov    %edx,0x14(%ebp)
  80171d:	8b 00                	mov    (%eax),%eax
  80171f:	99                   	cltd   
  801720:	31 d0                	xor    %edx,%eax
  801722:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801724:	83 f8 0f             	cmp    $0xf,%eax
  801727:	7f 0b                	jg     801734 <vprintfmt+0x142>
  801729:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  801730:	85 d2                	test   %edx,%edx
  801732:	75 18                	jne    80174c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801734:	50                   	push   %eax
  801735:	68 fb 23 80 00       	push   $0x8023fb
  80173a:	53                   	push   %ebx
  80173b:	56                   	push   %esi
  80173c:	e8 94 fe ff ff       	call   8015d5 <printfmt>
  801741:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801747:	e9 cc fe ff ff       	jmp    801618 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80174c:	52                   	push   %edx
  80174d:	68 79 23 80 00       	push   $0x802379
  801752:	53                   	push   %ebx
  801753:	56                   	push   %esi
  801754:	e8 7c fe ff ff       	call   8015d5 <printfmt>
  801759:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80175f:	e9 b4 fe ff ff       	jmp    801618 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801764:	8b 45 14             	mov    0x14(%ebp),%eax
  801767:	8d 50 04             	lea    0x4(%eax),%edx
  80176a:	89 55 14             	mov    %edx,0x14(%ebp)
  80176d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80176f:	85 ff                	test   %edi,%edi
  801771:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  801776:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801779:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80177d:	0f 8e 94 00 00 00    	jle    801817 <vprintfmt+0x225>
  801783:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801787:	0f 84 98 00 00 00    	je     801825 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80178d:	83 ec 08             	sub    $0x8,%esp
  801790:	ff 75 d0             	pushl  -0x30(%ebp)
  801793:	57                   	push   %edi
  801794:	e8 86 02 00 00       	call   801a1f <strnlen>
  801799:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80179c:	29 c1                	sub    %eax,%ecx
  80179e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8017a1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017a4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ab:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017ae:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017b0:	eb 0f                	jmp    8017c1 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	53                   	push   %ebx
  8017b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017bb:	83 ef 01             	sub    $0x1,%edi
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	85 ff                	test   %edi,%edi
  8017c3:	7f ed                	jg     8017b2 <vprintfmt+0x1c0>
  8017c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017c8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017cb:	85 c9                	test   %ecx,%ecx
  8017cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d2:	0f 49 c1             	cmovns %ecx,%eax
  8017d5:	29 c1                	sub    %eax,%ecx
  8017d7:	89 75 08             	mov    %esi,0x8(%ebp)
  8017da:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017dd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017e0:	89 cb                	mov    %ecx,%ebx
  8017e2:	eb 4d                	jmp    801831 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017e8:	74 1b                	je     801805 <vprintfmt+0x213>
  8017ea:	0f be c0             	movsbl %al,%eax
  8017ed:	83 e8 20             	sub    $0x20,%eax
  8017f0:	83 f8 5e             	cmp    $0x5e,%eax
  8017f3:	76 10                	jbe    801805 <vprintfmt+0x213>
					putch('?', putdat);
  8017f5:	83 ec 08             	sub    $0x8,%esp
  8017f8:	ff 75 0c             	pushl  0xc(%ebp)
  8017fb:	6a 3f                	push   $0x3f
  8017fd:	ff 55 08             	call   *0x8(%ebp)
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	eb 0d                	jmp    801812 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801805:	83 ec 08             	sub    $0x8,%esp
  801808:	ff 75 0c             	pushl  0xc(%ebp)
  80180b:	52                   	push   %edx
  80180c:	ff 55 08             	call   *0x8(%ebp)
  80180f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801812:	83 eb 01             	sub    $0x1,%ebx
  801815:	eb 1a                	jmp    801831 <vprintfmt+0x23f>
  801817:	89 75 08             	mov    %esi,0x8(%ebp)
  80181a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80181d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801820:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801823:	eb 0c                	jmp    801831 <vprintfmt+0x23f>
  801825:	89 75 08             	mov    %esi,0x8(%ebp)
  801828:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80182b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80182e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801831:	83 c7 01             	add    $0x1,%edi
  801834:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801838:	0f be d0             	movsbl %al,%edx
  80183b:	85 d2                	test   %edx,%edx
  80183d:	74 23                	je     801862 <vprintfmt+0x270>
  80183f:	85 f6                	test   %esi,%esi
  801841:	78 a1                	js     8017e4 <vprintfmt+0x1f2>
  801843:	83 ee 01             	sub    $0x1,%esi
  801846:	79 9c                	jns    8017e4 <vprintfmt+0x1f2>
  801848:	89 df                	mov    %ebx,%edi
  80184a:	8b 75 08             	mov    0x8(%ebp),%esi
  80184d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801850:	eb 18                	jmp    80186a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	53                   	push   %ebx
  801856:	6a 20                	push   $0x20
  801858:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80185a:	83 ef 01             	sub    $0x1,%edi
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	eb 08                	jmp    80186a <vprintfmt+0x278>
  801862:	89 df                	mov    %ebx,%edi
  801864:	8b 75 08             	mov    0x8(%ebp),%esi
  801867:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80186a:	85 ff                	test   %edi,%edi
  80186c:	7f e4                	jg     801852 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801871:	e9 a2 fd ff ff       	jmp    801618 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801876:	83 fa 01             	cmp    $0x1,%edx
  801879:	7e 16                	jle    801891 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80187b:	8b 45 14             	mov    0x14(%ebp),%eax
  80187e:	8d 50 08             	lea    0x8(%eax),%edx
  801881:	89 55 14             	mov    %edx,0x14(%ebp)
  801884:	8b 50 04             	mov    0x4(%eax),%edx
  801887:	8b 00                	mov    (%eax),%eax
  801889:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80188c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80188f:	eb 32                	jmp    8018c3 <vprintfmt+0x2d1>
	else if (lflag)
  801891:	85 d2                	test   %edx,%edx
  801893:	74 18                	je     8018ad <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801895:	8b 45 14             	mov    0x14(%ebp),%eax
  801898:	8d 50 04             	lea    0x4(%eax),%edx
  80189b:	89 55 14             	mov    %edx,0x14(%ebp)
  80189e:	8b 00                	mov    (%eax),%eax
  8018a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018a3:	89 c1                	mov    %eax,%ecx
  8018a5:	c1 f9 1f             	sar    $0x1f,%ecx
  8018a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018ab:	eb 16                	jmp    8018c3 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8018ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b0:	8d 50 04             	lea    0x4(%eax),%edx
  8018b3:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b6:	8b 00                	mov    (%eax),%eax
  8018b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018bb:	89 c1                	mov    %eax,%ecx
  8018bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8018c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018c9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018ce:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018d2:	79 74                	jns    801948 <vprintfmt+0x356>
				putch('-', putdat);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	53                   	push   %ebx
  8018d8:	6a 2d                	push   $0x2d
  8018da:	ff d6                	call   *%esi
				num = -(long long) num;
  8018dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018e2:	f7 d8                	neg    %eax
  8018e4:	83 d2 00             	adc    $0x0,%edx
  8018e7:	f7 da                	neg    %edx
  8018e9:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018f1:	eb 55                	jmp    801948 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8018f6:	e8 83 fc ff ff       	call   80157e <getuint>
			base = 10;
  8018fb:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801900:	eb 46                	jmp    801948 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801902:	8d 45 14             	lea    0x14(%ebp),%eax
  801905:	e8 74 fc ff ff       	call   80157e <getuint>
			base = 8;
  80190a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80190f:	eb 37                	jmp    801948 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801911:	83 ec 08             	sub    $0x8,%esp
  801914:	53                   	push   %ebx
  801915:	6a 30                	push   $0x30
  801917:	ff d6                	call   *%esi
			putch('x', putdat);
  801919:	83 c4 08             	add    $0x8,%esp
  80191c:	53                   	push   %ebx
  80191d:	6a 78                	push   $0x78
  80191f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801921:	8b 45 14             	mov    0x14(%ebp),%eax
  801924:	8d 50 04             	lea    0x4(%eax),%edx
  801927:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80192a:	8b 00                	mov    (%eax),%eax
  80192c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801931:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801934:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801939:	eb 0d                	jmp    801948 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80193b:	8d 45 14             	lea    0x14(%ebp),%eax
  80193e:	e8 3b fc ff ff       	call   80157e <getuint>
			base = 16;
  801943:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801948:	83 ec 0c             	sub    $0xc,%esp
  80194b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80194f:	57                   	push   %edi
  801950:	ff 75 e0             	pushl  -0x20(%ebp)
  801953:	51                   	push   %ecx
  801954:	52                   	push   %edx
  801955:	50                   	push   %eax
  801956:	89 da                	mov    %ebx,%edx
  801958:	89 f0                	mov    %esi,%eax
  80195a:	e8 70 fb ff ff       	call   8014cf <printnum>
			break;
  80195f:	83 c4 20             	add    $0x20,%esp
  801962:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801965:	e9 ae fc ff ff       	jmp    801618 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80196a:	83 ec 08             	sub    $0x8,%esp
  80196d:	53                   	push   %ebx
  80196e:	51                   	push   %ecx
  80196f:	ff d6                	call   *%esi
			break;
  801971:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801974:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801977:	e9 9c fc ff ff       	jmp    801618 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80197c:	83 ec 08             	sub    $0x8,%esp
  80197f:	53                   	push   %ebx
  801980:	6a 25                	push   $0x25
  801982:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	eb 03                	jmp    80198c <vprintfmt+0x39a>
  801989:	83 ef 01             	sub    $0x1,%edi
  80198c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801990:	75 f7                	jne    801989 <vprintfmt+0x397>
  801992:	e9 81 fc ff ff       	jmp    801618 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801997:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5f                   	pop    %edi
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	83 ec 18             	sub    $0x18,%esp
  8019a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019ae:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019b2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	74 26                	je     8019e6 <vsnprintf+0x47>
  8019c0:	85 d2                	test   %edx,%edx
  8019c2:	7e 22                	jle    8019e6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019c4:	ff 75 14             	pushl  0x14(%ebp)
  8019c7:	ff 75 10             	pushl  0x10(%ebp)
  8019ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019cd:	50                   	push   %eax
  8019ce:	68 b8 15 80 00       	push   $0x8015b8
  8019d3:	e8 1a fc ff ff       	call   8015f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e1:	83 c4 10             	add    $0x10,%esp
  8019e4:	eb 05                	jmp    8019eb <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019eb:	c9                   	leave  
  8019ec:	c3                   	ret    

008019ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019f6:	50                   	push   %eax
  8019f7:	ff 75 10             	pushl  0x10(%ebp)
  8019fa:	ff 75 0c             	pushl  0xc(%ebp)
  8019fd:	ff 75 08             	pushl  0x8(%ebp)
  801a00:	e8 9a ff ff ff       	call   80199f <vsnprintf>
	va_end(ap);

	return rc;
}
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  801a12:	eb 03                	jmp    801a17 <strlen+0x10>
		n++;
  801a14:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a17:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a1b:	75 f7                	jne    801a14 <strlen+0xd>
		n++;
	return n;
}
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    

00801a1f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a1f:	55                   	push   %ebp
  801a20:	89 e5                	mov    %esp,%ebp
  801a22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a25:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a28:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2d:	eb 03                	jmp    801a32 <strnlen+0x13>
		n++;
  801a2f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a32:	39 c2                	cmp    %eax,%edx
  801a34:	74 08                	je     801a3e <strnlen+0x1f>
  801a36:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a3a:	75 f3                	jne    801a2f <strnlen+0x10>
  801a3c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	53                   	push   %ebx
  801a44:	8b 45 08             	mov    0x8(%ebp),%eax
  801a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a4a:	89 c2                	mov    %eax,%edx
  801a4c:	83 c2 01             	add    $0x1,%edx
  801a4f:	83 c1 01             	add    $0x1,%ecx
  801a52:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a56:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a59:	84 db                	test   %bl,%bl
  801a5b:	75 ef                	jne    801a4c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a5d:	5b                   	pop    %ebx
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    

00801a60 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	53                   	push   %ebx
  801a64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a67:	53                   	push   %ebx
  801a68:	e8 9a ff ff ff       	call   801a07 <strlen>
  801a6d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a70:	ff 75 0c             	pushl  0xc(%ebp)
  801a73:	01 d8                	add    %ebx,%eax
  801a75:	50                   	push   %eax
  801a76:	e8 c5 ff ff ff       	call   801a40 <strcpy>
	return dst;
}
  801a7b:	89 d8                	mov    %ebx,%eax
  801a7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	56                   	push   %esi
  801a86:	53                   	push   %ebx
  801a87:	8b 75 08             	mov    0x8(%ebp),%esi
  801a8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8d:	89 f3                	mov    %esi,%ebx
  801a8f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a92:	89 f2                	mov    %esi,%edx
  801a94:	eb 0f                	jmp    801aa5 <strncpy+0x23>
		*dst++ = *src;
  801a96:	83 c2 01             	add    $0x1,%edx
  801a99:	0f b6 01             	movzbl (%ecx),%eax
  801a9c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a9f:	80 39 01             	cmpb   $0x1,(%ecx)
  801aa2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801aa5:	39 da                	cmp    %ebx,%edx
  801aa7:	75 ed                	jne    801a96 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801aa9:	89 f0                	mov    %esi,%eax
  801aab:	5b                   	pop    %ebx
  801aac:	5e                   	pop    %esi
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    

00801aaf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	56                   	push   %esi
  801ab3:	53                   	push   %ebx
  801ab4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aba:	8b 55 10             	mov    0x10(%ebp),%edx
  801abd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801abf:	85 d2                	test   %edx,%edx
  801ac1:	74 21                	je     801ae4 <strlcpy+0x35>
  801ac3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ac7:	89 f2                	mov    %esi,%edx
  801ac9:	eb 09                	jmp    801ad4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801acb:	83 c2 01             	add    $0x1,%edx
  801ace:	83 c1 01             	add    $0x1,%ecx
  801ad1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ad4:	39 c2                	cmp    %eax,%edx
  801ad6:	74 09                	je     801ae1 <strlcpy+0x32>
  801ad8:	0f b6 19             	movzbl (%ecx),%ebx
  801adb:	84 db                	test   %bl,%bl
  801add:	75 ec                	jne    801acb <strlcpy+0x1c>
  801adf:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ae1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801ae4:	29 f0                	sub    %esi,%eax
}
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801af3:	eb 06                	jmp    801afb <strcmp+0x11>
		p++, q++;
  801af5:	83 c1 01             	add    $0x1,%ecx
  801af8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801afb:	0f b6 01             	movzbl (%ecx),%eax
  801afe:	84 c0                	test   %al,%al
  801b00:	74 04                	je     801b06 <strcmp+0x1c>
  801b02:	3a 02                	cmp    (%edx),%al
  801b04:	74 ef                	je     801af5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b06:	0f b6 c0             	movzbl %al,%eax
  801b09:	0f b6 12             	movzbl (%edx),%edx
  801b0c:	29 d0                	sub    %edx,%eax
}
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	53                   	push   %ebx
  801b14:	8b 45 08             	mov    0x8(%ebp),%eax
  801b17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1a:	89 c3                	mov    %eax,%ebx
  801b1c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b1f:	eb 06                	jmp    801b27 <strncmp+0x17>
		n--, p++, q++;
  801b21:	83 c0 01             	add    $0x1,%eax
  801b24:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b27:	39 d8                	cmp    %ebx,%eax
  801b29:	74 15                	je     801b40 <strncmp+0x30>
  801b2b:	0f b6 08             	movzbl (%eax),%ecx
  801b2e:	84 c9                	test   %cl,%cl
  801b30:	74 04                	je     801b36 <strncmp+0x26>
  801b32:	3a 0a                	cmp    (%edx),%cl
  801b34:	74 eb                	je     801b21 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b36:	0f b6 00             	movzbl (%eax),%eax
  801b39:	0f b6 12             	movzbl (%edx),%edx
  801b3c:	29 d0                	sub    %edx,%eax
  801b3e:	eb 05                	jmp    801b45 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b45:	5b                   	pop    %ebx
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b52:	eb 07                	jmp    801b5b <strchr+0x13>
		if (*s == c)
  801b54:	38 ca                	cmp    %cl,%dl
  801b56:	74 0f                	je     801b67 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b58:	83 c0 01             	add    $0x1,%eax
  801b5b:	0f b6 10             	movzbl (%eax),%edx
  801b5e:	84 d2                	test   %dl,%dl
  801b60:	75 f2                	jne    801b54 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b73:	eb 03                	jmp    801b78 <strfind+0xf>
  801b75:	83 c0 01             	add    $0x1,%eax
  801b78:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b7b:	38 ca                	cmp    %cl,%dl
  801b7d:	74 04                	je     801b83 <strfind+0x1a>
  801b7f:	84 d2                	test   %dl,%dl
  801b81:	75 f2                	jne    801b75 <strfind+0xc>
			break;
	return (char *) s;
}
  801b83:	5d                   	pop    %ebp
  801b84:	c3                   	ret    

00801b85 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	57                   	push   %edi
  801b89:	56                   	push   %esi
  801b8a:	53                   	push   %ebx
  801b8b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b91:	85 c9                	test   %ecx,%ecx
  801b93:	74 36                	je     801bcb <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b95:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b9b:	75 28                	jne    801bc5 <memset+0x40>
  801b9d:	f6 c1 03             	test   $0x3,%cl
  801ba0:	75 23                	jne    801bc5 <memset+0x40>
		c &= 0xFF;
  801ba2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ba6:	89 d3                	mov    %edx,%ebx
  801ba8:	c1 e3 08             	shl    $0x8,%ebx
  801bab:	89 d6                	mov    %edx,%esi
  801bad:	c1 e6 18             	shl    $0x18,%esi
  801bb0:	89 d0                	mov    %edx,%eax
  801bb2:	c1 e0 10             	shl    $0x10,%eax
  801bb5:	09 f0                	or     %esi,%eax
  801bb7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801bb9:	89 d8                	mov    %ebx,%eax
  801bbb:	09 d0                	or     %edx,%eax
  801bbd:	c1 e9 02             	shr    $0x2,%ecx
  801bc0:	fc                   	cld    
  801bc1:	f3 ab                	rep stos %eax,%es:(%edi)
  801bc3:	eb 06                	jmp    801bcb <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc8:	fc                   	cld    
  801bc9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bcb:	89 f8                	mov    %edi,%eax
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	57                   	push   %edi
  801bd6:	56                   	push   %esi
  801bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bda:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bdd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801be0:	39 c6                	cmp    %eax,%esi
  801be2:	73 35                	jae    801c19 <memmove+0x47>
  801be4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801be7:	39 d0                	cmp    %edx,%eax
  801be9:	73 2e                	jae    801c19 <memmove+0x47>
		s += n;
		d += n;
  801beb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bee:	89 d6                	mov    %edx,%esi
  801bf0:	09 fe                	or     %edi,%esi
  801bf2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801bf8:	75 13                	jne    801c0d <memmove+0x3b>
  801bfa:	f6 c1 03             	test   $0x3,%cl
  801bfd:	75 0e                	jne    801c0d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bff:	83 ef 04             	sub    $0x4,%edi
  801c02:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c05:	c1 e9 02             	shr    $0x2,%ecx
  801c08:	fd                   	std    
  801c09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c0b:	eb 09                	jmp    801c16 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c0d:	83 ef 01             	sub    $0x1,%edi
  801c10:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c13:	fd                   	std    
  801c14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c16:	fc                   	cld    
  801c17:	eb 1d                	jmp    801c36 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c19:	89 f2                	mov    %esi,%edx
  801c1b:	09 c2                	or     %eax,%edx
  801c1d:	f6 c2 03             	test   $0x3,%dl
  801c20:	75 0f                	jne    801c31 <memmove+0x5f>
  801c22:	f6 c1 03             	test   $0x3,%cl
  801c25:	75 0a                	jne    801c31 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c27:	c1 e9 02             	shr    $0x2,%ecx
  801c2a:	89 c7                	mov    %eax,%edi
  801c2c:	fc                   	cld    
  801c2d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c2f:	eb 05                	jmp    801c36 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c31:	89 c7                	mov    %eax,%edi
  801c33:	fc                   	cld    
  801c34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c36:	5e                   	pop    %esi
  801c37:	5f                   	pop    %edi
  801c38:	5d                   	pop    %ebp
  801c39:	c3                   	ret    

00801c3a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c3d:	ff 75 10             	pushl  0x10(%ebp)
  801c40:	ff 75 0c             	pushl  0xc(%ebp)
  801c43:	ff 75 08             	pushl  0x8(%ebp)
  801c46:	e8 87 ff ff ff       	call   801bd2 <memmove>
}
  801c4b:	c9                   	leave  
  801c4c:	c3                   	ret    

00801c4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	56                   	push   %esi
  801c51:	53                   	push   %ebx
  801c52:	8b 45 08             	mov    0x8(%ebp),%eax
  801c55:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c58:	89 c6                	mov    %eax,%esi
  801c5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c5d:	eb 1a                	jmp    801c79 <memcmp+0x2c>
		if (*s1 != *s2)
  801c5f:	0f b6 08             	movzbl (%eax),%ecx
  801c62:	0f b6 1a             	movzbl (%edx),%ebx
  801c65:	38 d9                	cmp    %bl,%cl
  801c67:	74 0a                	je     801c73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c69:	0f b6 c1             	movzbl %cl,%eax
  801c6c:	0f b6 db             	movzbl %bl,%ebx
  801c6f:	29 d8                	sub    %ebx,%eax
  801c71:	eb 0f                	jmp    801c82 <memcmp+0x35>
		s1++, s2++;
  801c73:	83 c0 01             	add    $0x1,%eax
  801c76:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c79:	39 f0                	cmp    %esi,%eax
  801c7b:	75 e2                	jne    801c5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c82:	5b                   	pop    %ebx
  801c83:	5e                   	pop    %esi
  801c84:	5d                   	pop    %ebp
  801c85:	c3                   	ret    

00801c86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	53                   	push   %ebx
  801c8a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c8d:	89 c1                	mov    %eax,%ecx
  801c8f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c92:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c96:	eb 0a                	jmp    801ca2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c98:	0f b6 10             	movzbl (%eax),%edx
  801c9b:	39 da                	cmp    %ebx,%edx
  801c9d:	74 07                	je     801ca6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c9f:	83 c0 01             	add    $0x1,%eax
  801ca2:	39 c8                	cmp    %ecx,%eax
  801ca4:	72 f2                	jb     801c98 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801ca6:	5b                   	pop    %ebx
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	57                   	push   %edi
  801cad:	56                   	push   %esi
  801cae:	53                   	push   %ebx
  801caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cb5:	eb 03                	jmp    801cba <strtol+0x11>
		s++;
  801cb7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cba:	0f b6 01             	movzbl (%ecx),%eax
  801cbd:	3c 20                	cmp    $0x20,%al
  801cbf:	74 f6                	je     801cb7 <strtol+0xe>
  801cc1:	3c 09                	cmp    $0x9,%al
  801cc3:	74 f2                	je     801cb7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801cc5:	3c 2b                	cmp    $0x2b,%al
  801cc7:	75 0a                	jne    801cd3 <strtol+0x2a>
		s++;
  801cc9:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ccc:	bf 00 00 00 00       	mov    $0x0,%edi
  801cd1:	eb 11                	jmp    801ce4 <strtol+0x3b>
  801cd3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801cd8:	3c 2d                	cmp    $0x2d,%al
  801cda:	75 08                	jne    801ce4 <strtol+0x3b>
		s++, neg = 1;
  801cdc:	83 c1 01             	add    $0x1,%ecx
  801cdf:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ce4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cea:	75 15                	jne    801d01 <strtol+0x58>
  801cec:	80 39 30             	cmpb   $0x30,(%ecx)
  801cef:	75 10                	jne    801d01 <strtol+0x58>
  801cf1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801cf5:	75 7c                	jne    801d73 <strtol+0xca>
		s += 2, base = 16;
  801cf7:	83 c1 02             	add    $0x2,%ecx
  801cfa:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cff:	eb 16                	jmp    801d17 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801d01:	85 db                	test   %ebx,%ebx
  801d03:	75 12                	jne    801d17 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d05:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d0a:	80 39 30             	cmpb   $0x30,(%ecx)
  801d0d:	75 08                	jne    801d17 <strtol+0x6e>
		s++, base = 8;
  801d0f:	83 c1 01             	add    $0x1,%ecx
  801d12:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d17:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d1f:	0f b6 11             	movzbl (%ecx),%edx
  801d22:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d25:	89 f3                	mov    %esi,%ebx
  801d27:	80 fb 09             	cmp    $0x9,%bl
  801d2a:	77 08                	ja     801d34 <strtol+0x8b>
			dig = *s - '0';
  801d2c:	0f be d2             	movsbl %dl,%edx
  801d2f:	83 ea 30             	sub    $0x30,%edx
  801d32:	eb 22                	jmp    801d56 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d34:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d37:	89 f3                	mov    %esi,%ebx
  801d39:	80 fb 19             	cmp    $0x19,%bl
  801d3c:	77 08                	ja     801d46 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d3e:	0f be d2             	movsbl %dl,%edx
  801d41:	83 ea 57             	sub    $0x57,%edx
  801d44:	eb 10                	jmp    801d56 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d46:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d49:	89 f3                	mov    %esi,%ebx
  801d4b:	80 fb 19             	cmp    $0x19,%bl
  801d4e:	77 16                	ja     801d66 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d50:	0f be d2             	movsbl %dl,%edx
  801d53:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d56:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d59:	7d 0b                	jge    801d66 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d5b:	83 c1 01             	add    $0x1,%ecx
  801d5e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d62:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d64:	eb b9                	jmp    801d1f <strtol+0x76>

	if (endptr)
  801d66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d6a:	74 0d                	je     801d79 <strtol+0xd0>
		*endptr = (char *) s;
  801d6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d6f:	89 0e                	mov    %ecx,(%esi)
  801d71:	eb 06                	jmp    801d79 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d73:	85 db                	test   %ebx,%ebx
  801d75:	74 98                	je     801d0f <strtol+0x66>
  801d77:	eb 9e                	jmp    801d17 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d79:	89 c2                	mov    %eax,%edx
  801d7b:	f7 da                	neg    %edx
  801d7d:	85 ff                	test   %edi,%edi
  801d7f:	0f 45 c2             	cmovne %edx,%eax
}
  801d82:	5b                   	pop    %ebx
  801d83:	5e                   	pop    %esi
  801d84:	5f                   	pop    %edi
  801d85:	5d                   	pop    %ebp
  801d86:	c3                   	ret    

00801d87 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d8d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d94:	75 2a                	jne    801dc0 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d96:	83 ec 04             	sub    $0x4,%esp
  801d99:	6a 07                	push   $0x7
  801d9b:	68 00 f0 bf ee       	push   $0xeebff000
  801da0:	6a 00                	push   $0x0
  801da2:	e8 d1 e3 ff ff       	call   800178 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	85 c0                	test   %eax,%eax
  801dac:	79 12                	jns    801dc0 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801dae:	50                   	push   %eax
  801daf:	68 e0 26 80 00       	push   $0x8026e0
  801db4:	6a 23                	push   $0x23
  801db6:	68 e4 26 80 00       	push   $0x8026e4
  801dbb:	e8 22 f6 ff ff       	call   8013e2 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc3:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801dc8:	83 ec 08             	sub    $0x8,%esp
  801dcb:	68 f2 1d 80 00       	push   $0x801df2
  801dd0:	6a 00                	push   $0x0
  801dd2:	e8 ec e4 ff ff       	call   8002c3 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801dd7:	83 c4 10             	add    $0x10,%esp
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	79 12                	jns    801df0 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801dde:	50                   	push   %eax
  801ddf:	68 e0 26 80 00       	push   $0x8026e0
  801de4:	6a 2c                	push   $0x2c
  801de6:	68 e4 26 80 00       	push   $0x8026e4
  801deb:	e8 f2 f5 ff ff       	call   8013e2 <_panic>
	}
}
  801df0:	c9                   	leave  
  801df1:	c3                   	ret    

00801df2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801df2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801df3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801df8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dfa:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dfd:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801e01:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801e06:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801e0a:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801e0c:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801e0f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801e10:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801e13:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801e14:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e15:	c3                   	ret    

00801e16 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	56                   	push   %esi
  801e1a:	53                   	push   %ebx
  801e1b:	8b 75 08             	mov    0x8(%ebp),%esi
  801e1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e24:	85 c0                	test   %eax,%eax
  801e26:	75 12                	jne    801e3a <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	68 00 00 c0 ee       	push   $0xeec00000
  801e30:	e8 f3 e4 ff ff       	call   800328 <sys_ipc_recv>
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	eb 0c                	jmp    801e46 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e3a:	83 ec 0c             	sub    $0xc,%esp
  801e3d:	50                   	push   %eax
  801e3e:	e8 e5 e4 ff ff       	call   800328 <sys_ipc_recv>
  801e43:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e46:	85 f6                	test   %esi,%esi
  801e48:	0f 95 c1             	setne  %cl
  801e4b:	85 db                	test   %ebx,%ebx
  801e4d:	0f 95 c2             	setne  %dl
  801e50:	84 d1                	test   %dl,%cl
  801e52:	74 09                	je     801e5d <ipc_recv+0x47>
  801e54:	89 c2                	mov    %eax,%edx
  801e56:	c1 ea 1f             	shr    $0x1f,%edx
  801e59:	84 d2                	test   %dl,%dl
  801e5b:	75 2d                	jne    801e8a <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e5d:	85 f6                	test   %esi,%esi
  801e5f:	74 0d                	je     801e6e <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e61:	a1 04 40 80 00       	mov    0x804004,%eax
  801e66:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801e6c:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e6e:	85 db                	test   %ebx,%ebx
  801e70:	74 0d                	je     801e7f <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e72:	a1 04 40 80 00       	mov    0x804004,%eax
  801e77:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801e7d:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e84:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801e8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	57                   	push   %edi
  801e95:	56                   	push   %esi
  801e96:	53                   	push   %ebx
  801e97:	83 ec 0c             	sub    $0xc,%esp
  801e9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ea0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ea3:	85 db                	test   %ebx,%ebx
  801ea5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801eaa:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ead:	ff 75 14             	pushl  0x14(%ebp)
  801eb0:	53                   	push   %ebx
  801eb1:	56                   	push   %esi
  801eb2:	57                   	push   %edi
  801eb3:	e8 4d e4 ff ff       	call   800305 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801eb8:	89 c2                	mov    %eax,%edx
  801eba:	c1 ea 1f             	shr    $0x1f,%edx
  801ebd:	83 c4 10             	add    $0x10,%esp
  801ec0:	84 d2                	test   %dl,%dl
  801ec2:	74 17                	je     801edb <ipc_send+0x4a>
  801ec4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ec7:	74 12                	je     801edb <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ec9:	50                   	push   %eax
  801eca:	68 f2 26 80 00       	push   $0x8026f2
  801ecf:	6a 47                	push   $0x47
  801ed1:	68 00 27 80 00       	push   $0x802700
  801ed6:	e8 07 f5 ff ff       	call   8013e2 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801edb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ede:	75 07                	jne    801ee7 <ipc_send+0x56>
			sys_yield();
  801ee0:	e8 74 e2 ff ff       	call   800159 <sys_yield>
  801ee5:	eb c6                	jmp    801ead <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	75 c2                	jne    801ead <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eee:	5b                   	pop    %ebx
  801eef:	5e                   	pop    %esi
  801ef0:	5f                   	pop    %edi
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    

00801ef3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ef9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801efe:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f04:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f0a:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f10:	39 ca                	cmp    %ecx,%edx
  801f12:	75 13                	jne    801f27 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f14:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f1a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f1f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f25:	eb 0f                	jmp    801f36 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f27:	83 c0 01             	add    $0x1,%eax
  801f2a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f2f:	75 cd                	jne    801efe <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f31:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    

00801f38 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f38:	55                   	push   %ebp
  801f39:	89 e5                	mov    %esp,%ebp
  801f3b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f3e:	89 d0                	mov    %edx,%eax
  801f40:	c1 e8 16             	shr    $0x16,%eax
  801f43:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f4a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f4f:	f6 c1 01             	test   $0x1,%cl
  801f52:	74 1d                	je     801f71 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f54:	c1 ea 0c             	shr    $0xc,%edx
  801f57:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f5e:	f6 c2 01             	test   $0x1,%dl
  801f61:	74 0e                	je     801f71 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f63:	c1 ea 0c             	shr    $0xc,%edx
  801f66:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f6d:	ef 
  801f6e:	0f b7 c0             	movzwl %ax,%eax
}
  801f71:	5d                   	pop    %ebp
  801f72:	c3                   	ret    
  801f73:	66 90                	xchg   %ax,%ax
  801f75:	66 90                	xchg   %ax,%ax
  801f77:	66 90                	xchg   %ax,%ax
  801f79:	66 90                	xchg   %ax,%ax
  801f7b:	66 90                	xchg   %ax,%ax
  801f7d:	66 90                	xchg   %ax,%ax
  801f7f:	90                   	nop

00801f80 <__udivdi3>:
  801f80:	55                   	push   %ebp
  801f81:	57                   	push   %edi
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 1c             	sub    $0x1c,%esp
  801f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f97:	85 f6                	test   %esi,%esi
  801f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f9d:	89 ca                	mov    %ecx,%edx
  801f9f:	89 f8                	mov    %edi,%eax
  801fa1:	75 3d                	jne    801fe0 <__udivdi3+0x60>
  801fa3:	39 cf                	cmp    %ecx,%edi
  801fa5:	0f 87 c5 00 00 00    	ja     802070 <__udivdi3+0xf0>
  801fab:	85 ff                	test   %edi,%edi
  801fad:	89 fd                	mov    %edi,%ebp
  801faf:	75 0b                	jne    801fbc <__udivdi3+0x3c>
  801fb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fb6:	31 d2                	xor    %edx,%edx
  801fb8:	f7 f7                	div    %edi
  801fba:	89 c5                	mov    %eax,%ebp
  801fbc:	89 c8                	mov    %ecx,%eax
  801fbe:	31 d2                	xor    %edx,%edx
  801fc0:	f7 f5                	div    %ebp
  801fc2:	89 c1                	mov    %eax,%ecx
  801fc4:	89 d8                	mov    %ebx,%eax
  801fc6:	89 cf                	mov    %ecx,%edi
  801fc8:	f7 f5                	div    %ebp
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	89 d8                	mov    %ebx,%eax
  801fce:	89 fa                	mov    %edi,%edx
  801fd0:	83 c4 1c             	add    $0x1c,%esp
  801fd3:	5b                   	pop    %ebx
  801fd4:	5e                   	pop    %esi
  801fd5:	5f                   	pop    %edi
  801fd6:	5d                   	pop    %ebp
  801fd7:	c3                   	ret    
  801fd8:	90                   	nop
  801fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fe0:	39 ce                	cmp    %ecx,%esi
  801fe2:	77 74                	ja     802058 <__udivdi3+0xd8>
  801fe4:	0f bd fe             	bsr    %esi,%edi
  801fe7:	83 f7 1f             	xor    $0x1f,%edi
  801fea:	0f 84 98 00 00 00    	je     802088 <__udivdi3+0x108>
  801ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	89 c5                	mov    %eax,%ebp
  801ff9:	29 fb                	sub    %edi,%ebx
  801ffb:	d3 e6                	shl    %cl,%esi
  801ffd:	89 d9                	mov    %ebx,%ecx
  801fff:	d3 ed                	shr    %cl,%ebp
  802001:	89 f9                	mov    %edi,%ecx
  802003:	d3 e0                	shl    %cl,%eax
  802005:	09 ee                	or     %ebp,%esi
  802007:	89 d9                	mov    %ebx,%ecx
  802009:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80200d:	89 d5                	mov    %edx,%ebp
  80200f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802013:	d3 ed                	shr    %cl,%ebp
  802015:	89 f9                	mov    %edi,%ecx
  802017:	d3 e2                	shl    %cl,%edx
  802019:	89 d9                	mov    %ebx,%ecx
  80201b:	d3 e8                	shr    %cl,%eax
  80201d:	09 c2                	or     %eax,%edx
  80201f:	89 d0                	mov    %edx,%eax
  802021:	89 ea                	mov    %ebp,%edx
  802023:	f7 f6                	div    %esi
  802025:	89 d5                	mov    %edx,%ebp
  802027:	89 c3                	mov    %eax,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	72 10                	jb     802041 <__udivdi3+0xc1>
  802031:	8b 74 24 08          	mov    0x8(%esp),%esi
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e6                	shl    %cl,%esi
  802039:	39 c6                	cmp    %eax,%esi
  80203b:	73 07                	jae    802044 <__udivdi3+0xc4>
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	75 03                	jne    802044 <__udivdi3+0xc4>
  802041:	83 eb 01             	sub    $0x1,%ebx
  802044:	31 ff                	xor    %edi,%edi
  802046:	89 d8                	mov    %ebx,%eax
  802048:	89 fa                	mov    %edi,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	31 ff                	xor    %edi,%edi
  80205a:	31 db                	xor    %ebx,%ebx
  80205c:	89 d8                	mov    %ebx,%eax
  80205e:	89 fa                	mov    %edi,%edx
  802060:	83 c4 1c             	add    $0x1c,%esp
  802063:	5b                   	pop    %ebx
  802064:	5e                   	pop    %esi
  802065:	5f                   	pop    %edi
  802066:	5d                   	pop    %ebp
  802067:	c3                   	ret    
  802068:	90                   	nop
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d8                	mov    %ebx,%eax
  802072:	f7 f7                	div    %edi
  802074:	31 ff                	xor    %edi,%edi
  802076:	89 c3                	mov    %eax,%ebx
  802078:	89 d8                	mov    %ebx,%eax
  80207a:	89 fa                	mov    %edi,%edx
  80207c:	83 c4 1c             	add    $0x1c,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5f                   	pop    %edi
  802082:	5d                   	pop    %ebp
  802083:	c3                   	ret    
  802084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802088:	39 ce                	cmp    %ecx,%esi
  80208a:	72 0c                	jb     802098 <__udivdi3+0x118>
  80208c:	31 db                	xor    %ebx,%ebx
  80208e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802092:	0f 87 34 ff ff ff    	ja     801fcc <__udivdi3+0x4c>
  802098:	bb 01 00 00 00       	mov    $0x1,%ebx
  80209d:	e9 2a ff ff ff       	jmp    801fcc <__udivdi3+0x4c>
  8020a2:	66 90                	xchg   %ax,%ax
  8020a4:	66 90                	xchg   %ax,%ax
  8020a6:	66 90                	xchg   %ax,%ax
  8020a8:	66 90                	xchg   %ax,%ax
  8020aa:	66 90                	xchg   %ax,%ax
  8020ac:	66 90                	xchg   %ax,%ax
  8020ae:	66 90                	xchg   %ax,%ax

008020b0 <__umoddi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	57                   	push   %edi
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
  8020b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020c7:	85 d2                	test   %edx,%edx
  8020c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f3                	mov    %esi,%ebx
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020da:	75 1c                	jne    8020f8 <__umoddi3+0x48>
  8020dc:	39 f7                	cmp    %esi,%edi
  8020de:	76 50                	jbe    802130 <__umoddi3+0x80>
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	f7 f7                	div    %edi
  8020e6:	89 d0                	mov    %edx,%eax
  8020e8:	31 d2                	xor    %edx,%edx
  8020ea:	83 c4 1c             	add    $0x1c,%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
  8020f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f8:	39 f2                	cmp    %esi,%edx
  8020fa:	89 d0                	mov    %edx,%eax
  8020fc:	77 52                	ja     802150 <__umoddi3+0xa0>
  8020fe:	0f bd ea             	bsr    %edx,%ebp
  802101:	83 f5 1f             	xor    $0x1f,%ebp
  802104:	75 5a                	jne    802160 <__umoddi3+0xb0>
  802106:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80210a:	0f 82 e0 00 00 00    	jb     8021f0 <__umoddi3+0x140>
  802110:	39 0c 24             	cmp    %ecx,(%esp)
  802113:	0f 86 d7 00 00 00    	jbe    8021f0 <__umoddi3+0x140>
  802119:	8b 44 24 08          	mov    0x8(%esp),%eax
  80211d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802121:	83 c4 1c             	add    $0x1c,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5f                   	pop    %edi
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	85 ff                	test   %edi,%edi
  802132:	89 fd                	mov    %edi,%ebp
  802134:	75 0b                	jne    802141 <__umoddi3+0x91>
  802136:	b8 01 00 00 00       	mov    $0x1,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	f7 f7                	div    %edi
  80213f:	89 c5                	mov    %eax,%ebp
  802141:	89 f0                	mov    %esi,%eax
  802143:	31 d2                	xor    %edx,%edx
  802145:	f7 f5                	div    %ebp
  802147:	89 c8                	mov    %ecx,%eax
  802149:	f7 f5                	div    %ebp
  80214b:	89 d0                	mov    %edx,%eax
  80214d:	eb 99                	jmp    8020e8 <__umoddi3+0x38>
  80214f:	90                   	nop
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	83 c4 1c             	add    $0x1c,%esp
  802157:	5b                   	pop    %ebx
  802158:	5e                   	pop    %esi
  802159:	5f                   	pop    %edi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    
  80215c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802160:	8b 34 24             	mov    (%esp),%esi
  802163:	bf 20 00 00 00       	mov    $0x20,%edi
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	29 ef                	sub    %ebp,%edi
  80216c:	d3 e0                	shl    %cl,%eax
  80216e:	89 f9                	mov    %edi,%ecx
  802170:	89 f2                	mov    %esi,%edx
  802172:	d3 ea                	shr    %cl,%edx
  802174:	89 e9                	mov    %ebp,%ecx
  802176:	09 c2                	or     %eax,%edx
  802178:	89 d8                	mov    %ebx,%eax
  80217a:	89 14 24             	mov    %edx,(%esp)
  80217d:	89 f2                	mov    %esi,%edx
  80217f:	d3 e2                	shl    %cl,%edx
  802181:	89 f9                	mov    %edi,%ecx
  802183:	89 54 24 04          	mov    %edx,0x4(%esp)
  802187:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80218b:	d3 e8                	shr    %cl,%eax
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	89 c6                	mov    %eax,%esi
  802191:	d3 e3                	shl    %cl,%ebx
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 d0                	mov    %edx,%eax
  802197:	d3 e8                	shr    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	09 d8                	or     %ebx,%eax
  80219d:	89 d3                	mov    %edx,%ebx
  80219f:	89 f2                	mov    %esi,%edx
  8021a1:	f7 34 24             	divl   (%esp)
  8021a4:	89 d6                	mov    %edx,%esi
  8021a6:	d3 e3                	shl    %cl,%ebx
  8021a8:	f7 64 24 04          	mull   0x4(%esp)
  8021ac:	39 d6                	cmp    %edx,%esi
  8021ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021b2:	89 d1                	mov    %edx,%ecx
  8021b4:	89 c3                	mov    %eax,%ebx
  8021b6:	72 08                	jb     8021c0 <__umoddi3+0x110>
  8021b8:	75 11                	jne    8021cb <__umoddi3+0x11b>
  8021ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021be:	73 0b                	jae    8021cb <__umoddi3+0x11b>
  8021c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021c4:	1b 14 24             	sbb    (%esp),%edx
  8021c7:	89 d1                	mov    %edx,%ecx
  8021c9:	89 c3                	mov    %eax,%ebx
  8021cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021cf:	29 da                	sub    %ebx,%edx
  8021d1:	19 ce                	sbb    %ecx,%esi
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 f0                	mov    %esi,%eax
  8021d7:	d3 e0                	shl    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	d3 ea                	shr    %cl,%edx
  8021dd:	89 e9                	mov    %ebp,%ecx
  8021df:	d3 ee                	shr    %cl,%esi
  8021e1:	09 d0                	or     %edx,%eax
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	83 c4 1c             	add    $0x1c,%esp
  8021e8:	5b                   	pop    %ebx
  8021e9:	5e                   	pop    %esi
  8021ea:	5f                   	pop    %edi
  8021eb:	5d                   	pop    %ebp
  8021ec:	c3                   	ret    
  8021ed:	8d 76 00             	lea    0x0(%esi),%esi
  8021f0:	29 f9                	sub    %edi,%ecx
  8021f2:	19 d6                	sbb    %edx,%esi
  8021f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021fc:	e9 18 ff ff ff       	jmp    802119 <__umoddi3+0x69>
