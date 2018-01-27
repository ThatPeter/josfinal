
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
  80004e:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
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
  8000a8:	e8 bb 07 00 00       	call   800868 <close_all>
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
  800121:	68 ca 21 80 00       	push   $0x8021ca
  800126:	6a 23                	push   $0x23
  800128:	68 e7 21 80 00       	push   $0x8021e7
  80012d:	e8 5e 12 00 00       	call   801390 <_panic>

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
  8001a2:	68 ca 21 80 00       	push   $0x8021ca
  8001a7:	6a 23                	push   $0x23
  8001a9:	68 e7 21 80 00       	push   $0x8021e7
  8001ae:	e8 dd 11 00 00       	call   801390 <_panic>

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
  8001e4:	68 ca 21 80 00       	push   $0x8021ca
  8001e9:	6a 23                	push   $0x23
  8001eb:	68 e7 21 80 00       	push   $0x8021e7
  8001f0:	e8 9b 11 00 00       	call   801390 <_panic>

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
  800226:	68 ca 21 80 00       	push   $0x8021ca
  80022b:	6a 23                	push   $0x23
  80022d:	68 e7 21 80 00       	push   $0x8021e7
  800232:	e8 59 11 00 00       	call   801390 <_panic>

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
  800268:	68 ca 21 80 00       	push   $0x8021ca
  80026d:	6a 23                	push   $0x23
  80026f:	68 e7 21 80 00       	push   $0x8021e7
  800274:	e8 17 11 00 00       	call   801390 <_panic>

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
  8002aa:	68 ca 21 80 00       	push   $0x8021ca
  8002af:	6a 23                	push   $0x23
  8002b1:	68 e7 21 80 00       	push   $0x8021e7
  8002b6:	e8 d5 10 00 00       	call   801390 <_panic>
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
  8002ec:	68 ca 21 80 00       	push   $0x8021ca
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 e7 21 80 00       	push   $0x8021e7
  8002f8:	e8 93 10 00 00       	call   801390 <_panic>

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
  800350:	68 ca 21 80 00       	push   $0x8021ca
  800355:	6a 23                	push   $0x23
  800357:	68 e7 21 80 00       	push   $0x8021e7
  80035c:	e8 2f 10 00 00       	call   801390 <_panic>

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

008003a9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	53                   	push   %ebx
  8003ad:	83 ec 04             	sub    $0x4,%esp
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003b3:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003b5:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003b9:	74 11                	je     8003cc <pgfault+0x23>
  8003bb:	89 d8                	mov    %ebx,%eax
  8003bd:	c1 e8 0c             	shr    $0xc,%eax
  8003c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003c7:	f6 c4 08             	test   $0x8,%ah
  8003ca:	75 14                	jne    8003e0 <pgfault+0x37>
		panic("faulting access");
  8003cc:	83 ec 04             	sub    $0x4,%esp
  8003cf:	68 f5 21 80 00       	push   $0x8021f5
  8003d4:	6a 1e                	push   $0x1e
  8003d6:	68 05 22 80 00       	push   $0x802205
  8003db:	e8 b0 0f 00 00       	call   801390 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  8003e0:	83 ec 04             	sub    $0x4,%esp
  8003e3:	6a 07                	push   $0x7
  8003e5:	68 00 f0 7f 00       	push   $0x7ff000
  8003ea:	6a 00                	push   $0x0
  8003ec:	e8 87 fd ff ff       	call   800178 <sys_page_alloc>
	if (r < 0) {
  8003f1:	83 c4 10             	add    $0x10,%esp
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	79 12                	jns    80040a <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  8003f8:	50                   	push   %eax
  8003f9:	68 10 22 80 00       	push   $0x802210
  8003fe:	6a 2c                	push   $0x2c
  800400:	68 05 22 80 00       	push   $0x802205
  800405:	e8 86 0f 00 00       	call   801390 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80040a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800410:	83 ec 04             	sub    $0x4,%esp
  800413:	68 00 10 00 00       	push   $0x1000
  800418:	53                   	push   %ebx
  800419:	68 00 f0 7f 00       	push   $0x7ff000
  80041e:	e8 c5 17 00 00       	call   801be8 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800423:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80042a:	53                   	push   %ebx
  80042b:	6a 00                	push   $0x0
  80042d:	68 00 f0 7f 00       	push   $0x7ff000
  800432:	6a 00                	push   $0x0
  800434:	e8 82 fd ff ff       	call   8001bb <sys_page_map>
	if (r < 0) {
  800439:	83 c4 20             	add    $0x20,%esp
  80043c:	85 c0                	test   %eax,%eax
  80043e:	79 12                	jns    800452 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  800440:	50                   	push   %eax
  800441:	68 10 22 80 00       	push   $0x802210
  800446:	6a 33                	push   $0x33
  800448:	68 05 22 80 00       	push   $0x802205
  80044d:	e8 3e 0f 00 00       	call   801390 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	68 00 f0 7f 00       	push   $0x7ff000
  80045a:	6a 00                	push   $0x0
  80045c:	e8 9c fd ff ff       	call   8001fd <sys_page_unmap>
	if (r < 0) {
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	85 c0                	test   %eax,%eax
  800466:	79 12                	jns    80047a <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  800468:	50                   	push   %eax
  800469:	68 10 22 80 00       	push   $0x802210
  80046e:	6a 37                	push   $0x37
  800470:	68 05 22 80 00       	push   $0x802205
  800475:	e8 16 0f 00 00       	call   801390 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  80047a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80047d:	c9                   	leave  
  80047e:	c3                   	ret    

0080047f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	57                   	push   %edi
  800483:	56                   	push   %esi
  800484:	53                   	push   %ebx
  800485:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  800488:	68 a9 03 80 00       	push   $0x8003a9
  80048d:	e8 a3 18 00 00       	call   801d35 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800492:	b8 07 00 00 00       	mov    $0x7,%eax
  800497:	cd 30                	int    $0x30
  800499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	79 17                	jns    8004ba <fork+0x3b>
		panic("fork fault %e");
  8004a3:	83 ec 04             	sub    $0x4,%esp
  8004a6:	68 29 22 80 00       	push   $0x802229
  8004ab:	68 84 00 00 00       	push   $0x84
  8004b0:	68 05 22 80 00       	push   $0x802205
  8004b5:	e8 d6 0e 00 00       	call   801390 <_panic>
  8004ba:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004c0:	75 24                	jne    8004e6 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  8004c2:	e8 73 fc ff ff       	call   80013a <sys_getenvid>
  8004c7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004cc:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  8004d2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004d7:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8004dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e1:	e9 64 01 00 00       	jmp    80064a <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  8004e6:	83 ec 04             	sub    $0x4,%esp
  8004e9:	6a 07                	push   $0x7
  8004eb:	68 00 f0 bf ee       	push   $0xeebff000
  8004f0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004f3:	e8 80 fc ff ff       	call   800178 <sys_page_alloc>
  8004f8:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  8004fb:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800500:	89 d8                	mov    %ebx,%eax
  800502:	c1 e8 16             	shr    $0x16,%eax
  800505:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80050c:	a8 01                	test   $0x1,%al
  80050e:	0f 84 fc 00 00 00    	je     800610 <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800514:	89 d8                	mov    %ebx,%eax
  800516:	c1 e8 0c             	shr    $0xc,%eax
  800519:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  800520:	f6 c2 01             	test   $0x1,%dl
  800523:	0f 84 e7 00 00 00    	je     800610 <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800529:	89 c6                	mov    %eax,%esi
  80052b:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80052e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800535:	f6 c6 04             	test   $0x4,%dh
  800538:	74 39                	je     800573 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  80053a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800541:	83 ec 0c             	sub    $0xc,%esp
  800544:	25 07 0e 00 00       	and    $0xe07,%eax
  800549:	50                   	push   %eax
  80054a:	56                   	push   %esi
  80054b:	57                   	push   %edi
  80054c:	56                   	push   %esi
  80054d:	6a 00                	push   $0x0
  80054f:	e8 67 fc ff ff       	call   8001bb <sys_page_map>
		if (r < 0) {
  800554:	83 c4 20             	add    $0x20,%esp
  800557:	85 c0                	test   %eax,%eax
  800559:	0f 89 b1 00 00 00    	jns    800610 <fork+0x191>
		    	panic("sys page map fault %e");
  80055f:	83 ec 04             	sub    $0x4,%esp
  800562:	68 37 22 80 00       	push   $0x802237
  800567:	6a 54                	push   $0x54
  800569:	68 05 22 80 00       	push   $0x802205
  80056e:	e8 1d 0e 00 00       	call   801390 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800573:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80057a:	f6 c2 02             	test   $0x2,%dl
  80057d:	75 0c                	jne    80058b <fork+0x10c>
  80057f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800586:	f6 c4 08             	test   $0x8,%ah
  800589:	74 5b                	je     8005e6 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  80058b:	83 ec 0c             	sub    $0xc,%esp
  80058e:	68 05 08 00 00       	push   $0x805
  800593:	56                   	push   %esi
  800594:	57                   	push   %edi
  800595:	56                   	push   %esi
  800596:	6a 00                	push   $0x0
  800598:	e8 1e fc ff ff       	call   8001bb <sys_page_map>
		if (r < 0) {
  80059d:	83 c4 20             	add    $0x20,%esp
  8005a0:	85 c0                	test   %eax,%eax
  8005a2:	79 14                	jns    8005b8 <fork+0x139>
		    	panic("sys page map fault %e");
  8005a4:	83 ec 04             	sub    $0x4,%esp
  8005a7:	68 37 22 80 00       	push   $0x802237
  8005ac:	6a 5b                	push   $0x5b
  8005ae:	68 05 22 80 00       	push   $0x802205
  8005b3:	e8 d8 0d 00 00       	call   801390 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005b8:	83 ec 0c             	sub    $0xc,%esp
  8005bb:	68 05 08 00 00       	push   $0x805
  8005c0:	56                   	push   %esi
  8005c1:	6a 00                	push   $0x0
  8005c3:	56                   	push   %esi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 f0 fb ff ff       	call   8001bb <sys_page_map>
		if (r < 0) {
  8005cb:	83 c4 20             	add    $0x20,%esp
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	79 3e                	jns    800610 <fork+0x191>
		    	panic("sys page map fault %e");
  8005d2:	83 ec 04             	sub    $0x4,%esp
  8005d5:	68 37 22 80 00       	push   $0x802237
  8005da:	6a 5f                	push   $0x5f
  8005dc:	68 05 22 80 00       	push   $0x802205
  8005e1:	e8 aa 0d 00 00       	call   801390 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  8005e6:	83 ec 0c             	sub    $0xc,%esp
  8005e9:	6a 05                	push   $0x5
  8005eb:	56                   	push   %esi
  8005ec:	57                   	push   %edi
  8005ed:	56                   	push   %esi
  8005ee:	6a 00                	push   $0x0
  8005f0:	e8 c6 fb ff ff       	call   8001bb <sys_page_map>
		if (r < 0) {
  8005f5:	83 c4 20             	add    $0x20,%esp
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	79 14                	jns    800610 <fork+0x191>
		    	panic("sys page map fault %e");
  8005fc:	83 ec 04             	sub    $0x4,%esp
  8005ff:	68 37 22 80 00       	push   $0x802237
  800604:	6a 64                	push   $0x64
  800606:	68 05 22 80 00       	push   $0x802205
  80060b:	e8 80 0d 00 00       	call   801390 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  800610:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800616:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80061c:	0f 85 de fe ff ff    	jne    800500 <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800622:	a1 04 40 80 00       	mov    0x804004,%eax
  800627:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	50                   	push   %eax
  800631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800634:	57                   	push   %edi
  800635:	e8 89 fc ff ff       	call   8002c3 <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  80063a:	83 c4 08             	add    $0x8,%esp
  80063d:	6a 02                	push   $0x2
  80063f:	57                   	push   %edi
  800640:	e8 fa fb ff ff       	call   80023f <sys_env_set_status>
	
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
  80066e:	68 50 22 80 00       	push   $0x802250
  800673:	e8 f1 0d 00 00       	call   801469 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800678:	c7 04 24 82 00 80 00 	movl   $0x800082,(%esp)
  80067f:	e8 e5 fc ff ff       	call   800369 <sys_thread_create>
  800684:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  800686:	83 c4 08             	add    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	68 50 22 80 00       	push   $0x802250
  80068f:	e8 d5 0d 00 00       	call   801469 <cprintf>
	return id;
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
  800772:	ba f0 22 80 00       	mov    $0x8022f0,%edx
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
  800797:	8b 40 7c             	mov    0x7c(%eax),%eax
  80079a:	83 ec 04             	sub    $0x4,%esp
  80079d:	51                   	push   %ecx
  80079e:	50                   	push   %eax
  80079f:	68 74 22 80 00       	push   $0x802274
  8007a4:	e8 c0 0c 00 00       	call   801469 <cprintf>
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
  80082c:	e8 cc f9 ff ff       	call   8001fd <sys_page_unmap>
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
  800918:	e8 9e f8 ff ff       	call   8001bb <sys_page_map>
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
  800944:	e8 72 f8 ff ff       	call   8001bb <sys_page_map>
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
  80095a:	e8 9e f8 ff ff       	call   8001fd <sys_page_unmap>
	sys_page_unmap(0, nva);
  80095f:	83 c4 08             	add    $0x8,%esp
  800962:	ff 75 d4             	pushl  -0x2c(%ebp)
  800965:	6a 00                	push   $0x0
  800967:	e8 91 f8 ff ff       	call   8001fd <sys_page_unmap>
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
  8009c1:	8b 40 7c             	mov    0x7c(%eax),%eax
  8009c4:	83 ec 04             	sub    $0x4,%esp
  8009c7:	53                   	push   %ebx
  8009c8:	50                   	push   %eax
  8009c9:	68 b5 22 80 00       	push   $0x8022b5
  8009ce:	e8 96 0a 00 00       	call   801469 <cprintf>
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
  800a96:	8b 40 7c             	mov    0x7c(%eax),%eax
  800a99:	83 ec 04             	sub    $0x4,%esp
  800a9c:	53                   	push   %ebx
  800a9d:	50                   	push   %eax
  800a9e:	68 d1 22 80 00       	push   $0x8022d1
  800aa3:	e8 c1 09 00 00       	call   801469 <cprintf>
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
  800b4b:	8b 40 7c             	mov    0x7c(%eax),%eax
  800b4e:	83 ec 04             	sub    $0x4,%esp
  800b51:	53                   	push   %ebx
  800b52:	50                   	push   %eax
  800b53:	68 94 22 80 00       	push   $0x802294
  800b58:	e8 0c 09 00 00       	call   801469 <cprintf>
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
  800c63:	e8 39 12 00 00       	call   801ea1 <ipc_find_env>
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
  800c7e:	e8 bc 11 00 00       	call   801e3f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c83:	83 c4 0c             	add    $0xc,%esp
  800c86:	6a 00                	push   $0x0
  800c88:	53                   	push   %ebx
  800c89:	6a 00                	push   $0x0
  800c8b:	e8 34 11 00 00       	call   801dc4 <ipc_recv>
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
  800d14:	e8 d5 0c 00 00       	call   8019ee <strcpy>
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
  800d6c:	e8 0f 0e 00 00       	call   801b80 <memmove>

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
  800db4:	68 00 23 80 00       	push   $0x802300
  800db9:	68 07 23 80 00       	push   $0x802307
  800dbe:	6a 7c                	push   $0x7c
  800dc0:	68 1c 23 80 00       	push   $0x80231c
  800dc5:	e8 c6 05 00 00       	call   801390 <_panic>
	assert(r <= PGSIZE);
  800dca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800dcf:	7e 16                	jle    800de7 <devfile_read+0x65>
  800dd1:	68 27 23 80 00       	push   $0x802327
  800dd6:	68 07 23 80 00       	push   $0x802307
  800ddb:	6a 7d                	push   $0x7d
  800ddd:	68 1c 23 80 00       	push   $0x80231c
  800de2:	e8 a9 05 00 00       	call   801390 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800de7:	83 ec 04             	sub    $0x4,%esp
  800dea:	50                   	push   %eax
  800deb:	68 00 50 80 00       	push   $0x805000
  800df0:	ff 75 0c             	pushl  0xc(%ebp)
  800df3:	e8 88 0d 00 00       	call   801b80 <memmove>
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
  800e0f:	e8 a1 0b 00 00       	call   8019b5 <strlen>
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
  800e3c:	e8 ad 0b 00 00       	call   8019ee <strcpy>
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
  800ec0:	68 33 23 80 00       	push   $0x802333
  800ec5:	53                   	push   %ebx
  800ec6:	e8 23 0b 00 00       	call   8019ee <strcpy>
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
  800f03:	e8 f5 f2 ff ff       	call   8001fd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f08:	89 1c 24             	mov    %ebx,(%esp)
  800f0b:	e8 9d f7 ff ff       	call   8006ad <fd2data>
  800f10:	83 c4 08             	add    $0x8,%esp
  800f13:	50                   	push   %eax
  800f14:	6a 00                	push   $0x0
  800f16:	e8 e2 f2 ff ff       	call   8001fd <sys_page_unmap>
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
  800f33:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	ff 75 e0             	pushl  -0x20(%ebp)
  800f3f:	e8 9f 0f 00 00       	call   801ee3 <pageref>
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	89 3c 24             	mov    %edi,(%esp)
  800f49:	e8 95 0f 00 00       	call   801ee3 <pageref>
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	39 c3                	cmp    %eax,%ebx
  800f53:	0f 94 c1             	sete   %cl
  800f56:	0f b6 c9             	movzbl %cl,%ecx
  800f59:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f5c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800f62:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  800f68:	39 ce                	cmp    %ecx,%esi
  800f6a:	74 1e                	je     800f8a <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800f6c:	39 c3                	cmp    %eax,%ebx
  800f6e:	75 be                	jne    800f2e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800f70:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  800f76:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f79:	50                   	push   %eax
  800f7a:	56                   	push   %esi
  800f7b:	68 3a 23 80 00       	push   $0x80233a
  800f80:	e8 e4 04 00 00       	call   801469 <cprintf>
  800f85:	83 c4 10             	add    $0x10,%esp
  800f88:	eb a4                	jmp    800f2e <_pipeisclosed+0xe>
	}
}
  800f8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    

00800f95 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	57                   	push   %edi
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 28             	sub    $0x28,%esp
  800f9e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fa1:	56                   	push   %esi
  800fa2:	e8 06 f7 ff ff       	call   8006ad <fd2data>
  800fa7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	bf 00 00 00 00       	mov    $0x0,%edi
  800fb1:	eb 4b                	jmp    800ffe <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800fb3:	89 da                	mov    %ebx,%edx
  800fb5:	89 f0                	mov    %esi,%eax
  800fb7:	e8 64 ff ff ff       	call   800f20 <_pipeisclosed>
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	75 48                	jne    801008 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fc0:	e8 94 f1 ff ff       	call   800159 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800fc5:	8b 43 04             	mov    0x4(%ebx),%eax
  800fc8:	8b 0b                	mov    (%ebx),%ecx
  800fca:	8d 51 20             	lea    0x20(%ecx),%edx
  800fcd:	39 d0                	cmp    %edx,%eax
  800fcf:	73 e2                	jae    800fb3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800fd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800fd8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800fdb:	89 c2                	mov    %eax,%edx
  800fdd:	c1 fa 1f             	sar    $0x1f,%edx
  800fe0:	89 d1                	mov    %edx,%ecx
  800fe2:	c1 e9 1b             	shr    $0x1b,%ecx
  800fe5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800fe8:	83 e2 1f             	and    $0x1f,%edx
  800feb:	29 ca                	sub    %ecx,%edx
  800fed:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ff1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ff5:	83 c0 01             	add    $0x1,%eax
  800ff8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ffb:	83 c7 01             	add    $0x1,%edi
  800ffe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801001:	75 c2                	jne    800fc5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801003:	8b 45 10             	mov    0x10(%ebp),%eax
  801006:	eb 05                	jmp    80100d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801008:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80100d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	57                   	push   %edi
  801019:	56                   	push   %esi
  80101a:	53                   	push   %ebx
  80101b:	83 ec 18             	sub    $0x18,%esp
  80101e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801021:	57                   	push   %edi
  801022:	e8 86 f6 ff ff       	call   8006ad <fd2data>
  801027:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801029:	83 c4 10             	add    $0x10,%esp
  80102c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801031:	eb 3d                	jmp    801070 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801033:	85 db                	test   %ebx,%ebx
  801035:	74 04                	je     80103b <devpipe_read+0x26>
				return i;
  801037:	89 d8                	mov    %ebx,%eax
  801039:	eb 44                	jmp    80107f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80103b:	89 f2                	mov    %esi,%edx
  80103d:	89 f8                	mov    %edi,%eax
  80103f:	e8 dc fe ff ff       	call   800f20 <_pipeisclosed>
  801044:	85 c0                	test   %eax,%eax
  801046:	75 32                	jne    80107a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801048:	e8 0c f1 ff ff       	call   800159 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80104d:	8b 06                	mov    (%esi),%eax
  80104f:	3b 46 04             	cmp    0x4(%esi),%eax
  801052:	74 df                	je     801033 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801054:	99                   	cltd   
  801055:	c1 ea 1b             	shr    $0x1b,%edx
  801058:	01 d0                	add    %edx,%eax
  80105a:	83 e0 1f             	and    $0x1f,%eax
  80105d:	29 d0                	sub    %edx,%eax
  80105f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801064:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801067:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80106a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80106d:	83 c3 01             	add    $0x1,%ebx
  801070:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801073:	75 d8                	jne    80104d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801075:	8b 45 10             	mov    0x10(%ebp),%eax
  801078:	eb 05                	jmp    80107f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80107a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80107f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	56                   	push   %esi
  80108b:	53                   	push   %ebx
  80108c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80108f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801092:	50                   	push   %eax
  801093:	e8 2c f6 ff ff       	call   8006c4 <fd_alloc>
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	89 c2                	mov    %eax,%edx
  80109d:	85 c0                	test   %eax,%eax
  80109f:	0f 88 2c 01 00 00    	js     8011d1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	68 07 04 00 00       	push   $0x407
  8010ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8010b0:	6a 00                	push   $0x0
  8010b2:	e8 c1 f0 ff ff       	call   800178 <sys_page_alloc>
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	0f 88 0d 01 00 00    	js     8011d1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ca:	50                   	push   %eax
  8010cb:	e8 f4 f5 ff ff       	call   8006c4 <fd_alloc>
  8010d0:	89 c3                	mov    %eax,%ebx
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	0f 88 e2 00 00 00    	js     8011bf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010dd:	83 ec 04             	sub    $0x4,%esp
  8010e0:	68 07 04 00 00       	push   $0x407
  8010e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8010e8:	6a 00                	push   $0x0
  8010ea:	e8 89 f0 ff ff       	call   800178 <sys_page_alloc>
  8010ef:	89 c3                	mov    %eax,%ebx
  8010f1:	83 c4 10             	add    $0x10,%esp
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	0f 88 c3 00 00 00    	js     8011bf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8010fc:	83 ec 0c             	sub    $0xc,%esp
  8010ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801102:	e8 a6 f5 ff ff       	call   8006ad <fd2data>
  801107:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801109:	83 c4 0c             	add    $0xc,%esp
  80110c:	68 07 04 00 00       	push   $0x407
  801111:	50                   	push   %eax
  801112:	6a 00                	push   $0x0
  801114:	e8 5f f0 ff ff       	call   800178 <sys_page_alloc>
  801119:	89 c3                	mov    %eax,%ebx
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	85 c0                	test   %eax,%eax
  801120:	0f 88 89 00 00 00    	js     8011af <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801126:	83 ec 0c             	sub    $0xc,%esp
  801129:	ff 75 f0             	pushl  -0x10(%ebp)
  80112c:	e8 7c f5 ff ff       	call   8006ad <fd2data>
  801131:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801138:	50                   	push   %eax
  801139:	6a 00                	push   $0x0
  80113b:	56                   	push   %esi
  80113c:	6a 00                	push   $0x0
  80113e:	e8 78 f0 ff ff       	call   8001bb <sys_page_map>
  801143:	89 c3                	mov    %eax,%ebx
  801145:	83 c4 20             	add    $0x20,%esp
  801148:	85 c0                	test   %eax,%eax
  80114a:	78 55                	js     8011a1 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80114c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801152:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801155:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801157:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801161:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801167:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80116c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	ff 75 f4             	pushl  -0xc(%ebp)
  80117c:	e8 1c f5 ff ff       	call   80069d <fd2num>
  801181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801184:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801186:	83 c4 04             	add    $0x4,%esp
  801189:	ff 75 f0             	pushl  -0x10(%ebp)
  80118c:	e8 0c f5 ff ff       	call   80069d <fd2num>
  801191:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801194:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	ba 00 00 00 00       	mov    $0x0,%edx
  80119f:	eb 30                	jmp    8011d1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011a1:	83 ec 08             	sub    $0x8,%esp
  8011a4:	56                   	push   %esi
  8011a5:	6a 00                	push   $0x0
  8011a7:	e8 51 f0 ff ff       	call   8001fd <sys_page_unmap>
  8011ac:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8011b5:	6a 00                	push   $0x0
  8011b7:	e8 41 f0 ff ff       	call   8001fd <sys_page_unmap>
  8011bc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011bf:	83 ec 08             	sub    $0x8,%esp
  8011c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8011c5:	6a 00                	push   $0x0
  8011c7:	e8 31 f0 ff ff       	call   8001fd <sys_page_unmap>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8011d1:	89 d0                	mov    %edx,%eax
  8011d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d6:	5b                   	pop    %ebx
  8011d7:	5e                   	pop    %esi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e3:	50                   	push   %eax
  8011e4:	ff 75 08             	pushl  0x8(%ebp)
  8011e7:	e8 27 f5 ff ff       	call   800713 <fd_lookup>
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	78 18                	js     80120b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8011f3:	83 ec 0c             	sub    $0xc,%esp
  8011f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f9:	e8 af f4 ff ff       	call   8006ad <fd2data>
	return _pipeisclosed(fd, p);
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801203:	e8 18 fd ff ff       	call   800f20 <_pipeisclosed>
  801208:	83 c4 10             	add    $0x10,%esp
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80121d:	68 52 23 80 00       	push   $0x802352
  801222:	ff 75 0c             	pushl  0xc(%ebp)
  801225:	e8 c4 07 00 00       	call   8019ee <strcpy>
	return 0;
}
  80122a:	b8 00 00 00 00       	mov    $0x0,%eax
  80122f:	c9                   	leave  
  801230:	c3                   	ret    

00801231 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	57                   	push   %edi
  801235:	56                   	push   %esi
  801236:	53                   	push   %ebx
  801237:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80123d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801242:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801248:	eb 2d                	jmp    801277 <devcons_write+0x46>
		m = n - tot;
  80124a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80124d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80124f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801252:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801257:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	53                   	push   %ebx
  80125e:	03 45 0c             	add    0xc(%ebp),%eax
  801261:	50                   	push   %eax
  801262:	57                   	push   %edi
  801263:	e8 18 09 00 00       	call   801b80 <memmove>
		sys_cputs(buf, m);
  801268:	83 c4 08             	add    $0x8,%esp
  80126b:	53                   	push   %ebx
  80126c:	57                   	push   %edi
  80126d:	e8 4a ee ff ff       	call   8000bc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801272:	01 de                	add    %ebx,%esi
  801274:	83 c4 10             	add    $0x10,%esp
  801277:	89 f0                	mov    %esi,%eax
  801279:	3b 75 10             	cmp    0x10(%ebp),%esi
  80127c:	72 cc                	jb     80124a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80127e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801281:	5b                   	pop    %ebx
  801282:	5e                   	pop    %esi
  801283:	5f                   	pop    %edi
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    

00801286 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	83 ec 08             	sub    $0x8,%esp
  80128c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801291:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801295:	74 2a                	je     8012c1 <devcons_read+0x3b>
  801297:	eb 05                	jmp    80129e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801299:	e8 bb ee ff ff       	call   800159 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80129e:	e8 37 ee ff ff       	call   8000da <sys_cgetc>
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	74 f2                	je     801299 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012a7:	85 c0                	test   %eax,%eax
  8012a9:	78 16                	js     8012c1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012ab:	83 f8 04             	cmp    $0x4,%eax
  8012ae:	74 0c                	je     8012bc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b3:	88 02                	mov    %al,(%edx)
	return 1;
  8012b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8012ba:	eb 05                	jmp    8012c1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012bc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8012c1:	c9                   	leave  
  8012c2:	c3                   	ret    

008012c3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8012c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8012cf:	6a 01                	push   $0x1
  8012d1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012d4:	50                   	push   %eax
  8012d5:	e8 e2 ed ff ff       	call   8000bc <sys_cputs>
}
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <getchar>:

int
getchar(void)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8012e5:	6a 01                	push   $0x1
  8012e7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 87 f6 ff ff       	call   800979 <read>
	if (r < 0)
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 0f                	js     801308 <getchar+0x29>
		return r;
	if (r < 1)
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	7e 06                	jle    801303 <getchar+0x24>
		return -E_EOF;
	return c;
  8012fd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801301:	eb 05                	jmp    801308 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801303:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801308:	c9                   	leave  
  801309:	c3                   	ret    

0080130a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80130a:	55                   	push   %ebp
  80130b:	89 e5                	mov    %esp,%ebp
  80130d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801310:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801313:	50                   	push   %eax
  801314:	ff 75 08             	pushl  0x8(%ebp)
  801317:	e8 f7 f3 ff ff       	call   800713 <fd_lookup>
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 11                	js     801334 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801323:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801326:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80132c:	39 10                	cmp    %edx,(%eax)
  80132e:	0f 94 c0             	sete   %al
  801331:	0f b6 c0             	movzbl %al,%eax
}
  801334:	c9                   	leave  
  801335:	c3                   	ret    

00801336 <opencons>:

int
opencons(void)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80133c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	e8 7f f3 ff ff       	call   8006c4 <fd_alloc>
  801345:	83 c4 10             	add    $0x10,%esp
		return r;
  801348:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80134a:	85 c0                	test   %eax,%eax
  80134c:	78 3e                	js     80138c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	68 07 04 00 00       	push   $0x407
  801356:	ff 75 f4             	pushl  -0xc(%ebp)
  801359:	6a 00                	push   $0x0
  80135b:	e8 18 ee ff ff       	call   800178 <sys_page_alloc>
  801360:	83 c4 10             	add    $0x10,%esp
		return r;
  801363:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801365:	85 c0                	test   %eax,%eax
  801367:	78 23                	js     80138c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801369:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80136f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801372:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801374:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801377:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80137e:	83 ec 0c             	sub    $0xc,%esp
  801381:	50                   	push   %eax
  801382:	e8 16 f3 ff ff       	call   80069d <fd2num>
  801387:	89 c2                	mov    %eax,%edx
  801389:	83 c4 10             	add    $0x10,%esp
}
  80138c:	89 d0                	mov    %edx,%eax
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	56                   	push   %esi
  801394:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801395:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801398:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80139e:	e8 97 ed ff ff       	call   80013a <sys_getenvid>
  8013a3:	83 ec 0c             	sub    $0xc,%esp
  8013a6:	ff 75 0c             	pushl  0xc(%ebp)
  8013a9:	ff 75 08             	pushl  0x8(%ebp)
  8013ac:	56                   	push   %esi
  8013ad:	50                   	push   %eax
  8013ae:	68 60 23 80 00       	push   $0x802360
  8013b3:	e8 b1 00 00 00       	call   801469 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013b8:	83 c4 18             	add    $0x18,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	ff 75 10             	pushl  0x10(%ebp)
  8013bf:	e8 54 00 00 00       	call   801418 <vcprintf>
	cprintf("\n");
  8013c4:	c7 04 24 4b 23 80 00 	movl   $0x80234b,(%esp)
  8013cb:	e8 99 00 00 00       	call   801469 <cprintf>
  8013d0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013d3:	cc                   	int3   
  8013d4:	eb fd                	jmp    8013d3 <_panic+0x43>

008013d6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 04             	sub    $0x4,%esp
  8013dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013e0:	8b 13                	mov    (%ebx),%edx
  8013e2:	8d 42 01             	lea    0x1(%edx),%eax
  8013e5:	89 03                	mov    %eax,(%ebx)
  8013e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ea:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8013ee:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013f3:	75 1a                	jne    80140f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	68 ff 00 00 00       	push   $0xff
  8013fd:	8d 43 08             	lea    0x8(%ebx),%eax
  801400:	50                   	push   %eax
  801401:	e8 b6 ec ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  801406:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80140c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80140f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801413:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801416:	c9                   	leave  
  801417:	c3                   	ret    

00801418 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801421:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801428:	00 00 00 
	b.cnt = 0;
  80142b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801432:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801435:	ff 75 0c             	pushl  0xc(%ebp)
  801438:	ff 75 08             	pushl  0x8(%ebp)
  80143b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	68 d6 13 80 00       	push   $0x8013d6
  801447:	e8 54 01 00 00       	call   8015a0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80144c:	83 c4 08             	add    $0x8,%esp
  80144f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801455:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80145b:	50                   	push   %eax
  80145c:	e8 5b ec ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  801461:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801467:	c9                   	leave  
  801468:	c3                   	ret    

00801469 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80146f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801472:	50                   	push   %eax
  801473:	ff 75 08             	pushl  0x8(%ebp)
  801476:	e8 9d ff ff ff       	call   801418 <vcprintf>
	va_end(ap);

	return cnt;
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	57                   	push   %edi
  801481:	56                   	push   %esi
  801482:	53                   	push   %ebx
  801483:	83 ec 1c             	sub    $0x1c,%esp
  801486:	89 c7                	mov    %eax,%edi
  801488:	89 d6                	mov    %edx,%esi
  80148a:	8b 45 08             	mov    0x8(%ebp),%eax
  80148d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801490:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801493:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801496:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801499:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014a1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014a4:	39 d3                	cmp    %edx,%ebx
  8014a6:	72 05                	jb     8014ad <printnum+0x30>
  8014a8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014ab:	77 45                	ja     8014f2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014ad:	83 ec 0c             	sub    $0xc,%esp
  8014b0:	ff 75 18             	pushl  0x18(%ebp)
  8014b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014b9:	53                   	push   %ebx
  8014ba:	ff 75 10             	pushl  0x10(%ebp)
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8014c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8014c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8014cc:	e8 4f 0a 00 00       	call   801f20 <__udivdi3>
  8014d1:	83 c4 18             	add    $0x18,%esp
  8014d4:	52                   	push   %edx
  8014d5:	50                   	push   %eax
  8014d6:	89 f2                	mov    %esi,%edx
  8014d8:	89 f8                	mov    %edi,%eax
  8014da:	e8 9e ff ff ff       	call   80147d <printnum>
  8014df:	83 c4 20             	add    $0x20,%esp
  8014e2:	eb 18                	jmp    8014fc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	56                   	push   %esi
  8014e8:	ff 75 18             	pushl  0x18(%ebp)
  8014eb:	ff d7                	call   *%edi
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	eb 03                	jmp    8014f5 <printnum+0x78>
  8014f2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014f5:	83 eb 01             	sub    $0x1,%ebx
  8014f8:	85 db                	test   %ebx,%ebx
  8014fa:	7f e8                	jg     8014e4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	56                   	push   %esi
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	ff 75 e4             	pushl  -0x1c(%ebp)
  801506:	ff 75 e0             	pushl  -0x20(%ebp)
  801509:	ff 75 dc             	pushl  -0x24(%ebp)
  80150c:	ff 75 d8             	pushl  -0x28(%ebp)
  80150f:	e8 3c 0b 00 00       	call   802050 <__umoddi3>
  801514:	83 c4 14             	add    $0x14,%esp
  801517:	0f be 80 83 23 80 00 	movsbl 0x802383(%eax),%eax
  80151e:	50                   	push   %eax
  80151f:	ff d7                	call   *%edi
}
  801521:	83 c4 10             	add    $0x10,%esp
  801524:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801527:	5b                   	pop    %ebx
  801528:	5e                   	pop    %esi
  801529:	5f                   	pop    %edi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80152f:	83 fa 01             	cmp    $0x1,%edx
  801532:	7e 0e                	jle    801542 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801534:	8b 10                	mov    (%eax),%edx
  801536:	8d 4a 08             	lea    0x8(%edx),%ecx
  801539:	89 08                	mov    %ecx,(%eax)
  80153b:	8b 02                	mov    (%edx),%eax
  80153d:	8b 52 04             	mov    0x4(%edx),%edx
  801540:	eb 22                	jmp    801564 <getuint+0x38>
	else if (lflag)
  801542:	85 d2                	test   %edx,%edx
  801544:	74 10                	je     801556 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801546:	8b 10                	mov    (%eax),%edx
  801548:	8d 4a 04             	lea    0x4(%edx),%ecx
  80154b:	89 08                	mov    %ecx,(%eax)
  80154d:	8b 02                	mov    (%edx),%eax
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	eb 0e                	jmp    801564 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801556:	8b 10                	mov    (%eax),%edx
  801558:	8d 4a 04             	lea    0x4(%edx),%ecx
  80155b:	89 08                	mov    %ecx,(%eax)
  80155d:	8b 02                	mov    (%edx),%eax
  80155f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80156c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801570:	8b 10                	mov    (%eax),%edx
  801572:	3b 50 04             	cmp    0x4(%eax),%edx
  801575:	73 0a                	jae    801581 <sprintputch+0x1b>
		*b->buf++ = ch;
  801577:	8d 4a 01             	lea    0x1(%edx),%ecx
  80157a:	89 08                	mov    %ecx,(%eax)
  80157c:	8b 45 08             	mov    0x8(%ebp),%eax
  80157f:	88 02                	mov    %al,(%edx)
}
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    

00801583 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801589:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80158c:	50                   	push   %eax
  80158d:	ff 75 10             	pushl  0x10(%ebp)
  801590:	ff 75 0c             	pushl  0xc(%ebp)
  801593:	ff 75 08             	pushl  0x8(%ebp)
  801596:	e8 05 00 00 00       	call   8015a0 <vprintfmt>
	va_end(ap);
}
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	57                   	push   %edi
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 2c             	sub    $0x2c,%esp
  8015a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015af:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015b2:	eb 12                	jmp    8015c6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	0f 84 89 03 00 00    	je     801945 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	50                   	push   %eax
  8015c1:	ff d6                	call   *%esi
  8015c3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015c6:	83 c7 01             	add    $0x1,%edi
  8015c9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015cd:	83 f8 25             	cmp    $0x25,%eax
  8015d0:	75 e2                	jne    8015b4 <vprintfmt+0x14>
  8015d2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8015d6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8015e4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8015eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f0:	eb 07                	jmp    8015f9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8015f5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f9:	8d 47 01             	lea    0x1(%edi),%eax
  8015fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015ff:	0f b6 07             	movzbl (%edi),%eax
  801602:	0f b6 c8             	movzbl %al,%ecx
  801605:	83 e8 23             	sub    $0x23,%eax
  801608:	3c 55                	cmp    $0x55,%al
  80160a:	0f 87 1a 03 00 00    	ja     80192a <vprintfmt+0x38a>
  801610:	0f b6 c0             	movzbl %al,%eax
  801613:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  80161a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80161d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801621:	eb d6                	jmp    8015f9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801626:	b8 00 00 00 00       	mov    $0x0,%eax
  80162b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80162e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801631:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801635:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801638:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80163b:	83 fa 09             	cmp    $0x9,%edx
  80163e:	77 39                	ja     801679 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801640:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801643:	eb e9                	jmp    80162e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801645:	8b 45 14             	mov    0x14(%ebp),%eax
  801648:	8d 48 04             	lea    0x4(%eax),%ecx
  80164b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80164e:	8b 00                	mov    (%eax),%eax
  801650:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801653:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801656:	eb 27                	jmp    80167f <vprintfmt+0xdf>
  801658:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80165b:	85 c0                	test   %eax,%eax
  80165d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801662:	0f 49 c8             	cmovns %eax,%ecx
  801665:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80166b:	eb 8c                	jmp    8015f9 <vprintfmt+0x59>
  80166d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801670:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801677:	eb 80                	jmp    8015f9 <vprintfmt+0x59>
  801679:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80167c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80167f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801683:	0f 89 70 ff ff ff    	jns    8015f9 <vprintfmt+0x59>
				width = precision, precision = -1;
  801689:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80168c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80168f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801696:	e9 5e ff ff ff       	jmp    8015f9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80169b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80169e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016a1:	e9 53 ff ff ff       	jmp    8015f9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016a9:	8d 50 04             	lea    0x4(%eax),%edx
  8016ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8016af:	83 ec 08             	sub    $0x8,%esp
  8016b2:	53                   	push   %ebx
  8016b3:	ff 30                	pushl  (%eax)
  8016b5:	ff d6                	call   *%esi
			break;
  8016b7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016bd:	e9 04 ff ff ff       	jmp    8015c6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8016c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c5:	8d 50 04             	lea    0x4(%eax),%edx
  8016c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8016cb:	8b 00                	mov    (%eax),%eax
  8016cd:	99                   	cltd   
  8016ce:	31 d0                	xor    %edx,%eax
  8016d0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016d2:	83 f8 0f             	cmp    $0xf,%eax
  8016d5:	7f 0b                	jg     8016e2 <vprintfmt+0x142>
  8016d7:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8016de:	85 d2                	test   %edx,%edx
  8016e0:	75 18                	jne    8016fa <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8016e2:	50                   	push   %eax
  8016e3:	68 9b 23 80 00       	push   $0x80239b
  8016e8:	53                   	push   %ebx
  8016e9:	56                   	push   %esi
  8016ea:	e8 94 fe ff ff       	call   801583 <printfmt>
  8016ef:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8016f5:	e9 cc fe ff ff       	jmp    8015c6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8016fa:	52                   	push   %edx
  8016fb:	68 19 23 80 00       	push   $0x802319
  801700:	53                   	push   %ebx
  801701:	56                   	push   %esi
  801702:	e8 7c fe ff ff       	call   801583 <printfmt>
  801707:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80170d:	e9 b4 fe ff ff       	jmp    8015c6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801712:	8b 45 14             	mov    0x14(%ebp),%eax
  801715:	8d 50 04             	lea    0x4(%eax),%edx
  801718:	89 55 14             	mov    %edx,0x14(%ebp)
  80171b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80171d:	85 ff                	test   %edi,%edi
  80171f:	b8 94 23 80 00       	mov    $0x802394,%eax
  801724:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801727:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80172b:	0f 8e 94 00 00 00    	jle    8017c5 <vprintfmt+0x225>
  801731:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801735:	0f 84 98 00 00 00    	je     8017d3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80173b:	83 ec 08             	sub    $0x8,%esp
  80173e:	ff 75 d0             	pushl  -0x30(%ebp)
  801741:	57                   	push   %edi
  801742:	e8 86 02 00 00       	call   8019cd <strnlen>
  801747:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80174a:	29 c1                	sub    %eax,%ecx
  80174c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80174f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801752:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801756:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801759:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80175c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80175e:	eb 0f                	jmp    80176f <vprintfmt+0x1cf>
					putch(padc, putdat);
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	53                   	push   %ebx
  801764:	ff 75 e0             	pushl  -0x20(%ebp)
  801767:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801769:	83 ef 01             	sub    $0x1,%edi
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	85 ff                	test   %edi,%edi
  801771:	7f ed                	jg     801760 <vprintfmt+0x1c0>
  801773:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801776:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801779:	85 c9                	test   %ecx,%ecx
  80177b:	b8 00 00 00 00       	mov    $0x0,%eax
  801780:	0f 49 c1             	cmovns %ecx,%eax
  801783:	29 c1                	sub    %eax,%ecx
  801785:	89 75 08             	mov    %esi,0x8(%ebp)
  801788:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80178b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80178e:	89 cb                	mov    %ecx,%ebx
  801790:	eb 4d                	jmp    8017df <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801792:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801796:	74 1b                	je     8017b3 <vprintfmt+0x213>
  801798:	0f be c0             	movsbl %al,%eax
  80179b:	83 e8 20             	sub    $0x20,%eax
  80179e:	83 f8 5e             	cmp    $0x5e,%eax
  8017a1:	76 10                	jbe    8017b3 <vprintfmt+0x213>
					putch('?', putdat);
  8017a3:	83 ec 08             	sub    $0x8,%esp
  8017a6:	ff 75 0c             	pushl  0xc(%ebp)
  8017a9:	6a 3f                	push   $0x3f
  8017ab:	ff 55 08             	call   *0x8(%ebp)
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	eb 0d                	jmp    8017c0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017b3:	83 ec 08             	sub    $0x8,%esp
  8017b6:	ff 75 0c             	pushl  0xc(%ebp)
  8017b9:	52                   	push   %edx
  8017ba:	ff 55 08             	call   *0x8(%ebp)
  8017bd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017c0:	83 eb 01             	sub    $0x1,%ebx
  8017c3:	eb 1a                	jmp    8017df <vprintfmt+0x23f>
  8017c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8017c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017d1:	eb 0c                	jmp    8017df <vprintfmt+0x23f>
  8017d3:	89 75 08             	mov    %esi,0x8(%ebp)
  8017d6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017d9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017dc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8017df:	83 c7 01             	add    $0x1,%edi
  8017e2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8017e6:	0f be d0             	movsbl %al,%edx
  8017e9:	85 d2                	test   %edx,%edx
  8017eb:	74 23                	je     801810 <vprintfmt+0x270>
  8017ed:	85 f6                	test   %esi,%esi
  8017ef:	78 a1                	js     801792 <vprintfmt+0x1f2>
  8017f1:	83 ee 01             	sub    $0x1,%esi
  8017f4:	79 9c                	jns    801792 <vprintfmt+0x1f2>
  8017f6:	89 df                	mov    %ebx,%edi
  8017f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8017fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017fe:	eb 18                	jmp    801818 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801800:	83 ec 08             	sub    $0x8,%esp
  801803:	53                   	push   %ebx
  801804:	6a 20                	push   $0x20
  801806:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801808:	83 ef 01             	sub    $0x1,%edi
  80180b:	83 c4 10             	add    $0x10,%esp
  80180e:	eb 08                	jmp    801818 <vprintfmt+0x278>
  801810:	89 df                	mov    %ebx,%edi
  801812:	8b 75 08             	mov    0x8(%ebp),%esi
  801815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801818:	85 ff                	test   %edi,%edi
  80181a:	7f e4                	jg     801800 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80181f:	e9 a2 fd ff ff       	jmp    8015c6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801824:	83 fa 01             	cmp    $0x1,%edx
  801827:	7e 16                	jle    80183f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801829:	8b 45 14             	mov    0x14(%ebp),%eax
  80182c:	8d 50 08             	lea    0x8(%eax),%edx
  80182f:	89 55 14             	mov    %edx,0x14(%ebp)
  801832:	8b 50 04             	mov    0x4(%eax),%edx
  801835:	8b 00                	mov    (%eax),%eax
  801837:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80183a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80183d:	eb 32                	jmp    801871 <vprintfmt+0x2d1>
	else if (lflag)
  80183f:	85 d2                	test   %edx,%edx
  801841:	74 18                	je     80185b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801843:	8b 45 14             	mov    0x14(%ebp),%eax
  801846:	8d 50 04             	lea    0x4(%eax),%edx
  801849:	89 55 14             	mov    %edx,0x14(%ebp)
  80184c:	8b 00                	mov    (%eax),%eax
  80184e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801851:	89 c1                	mov    %eax,%ecx
  801853:	c1 f9 1f             	sar    $0x1f,%ecx
  801856:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801859:	eb 16                	jmp    801871 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80185b:	8b 45 14             	mov    0x14(%ebp),%eax
  80185e:	8d 50 04             	lea    0x4(%eax),%edx
  801861:	89 55 14             	mov    %edx,0x14(%ebp)
  801864:	8b 00                	mov    (%eax),%eax
  801866:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801869:	89 c1                	mov    %eax,%ecx
  80186b:	c1 f9 1f             	sar    $0x1f,%ecx
  80186e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801871:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801874:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801877:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80187c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801880:	79 74                	jns    8018f6 <vprintfmt+0x356>
				putch('-', putdat);
  801882:	83 ec 08             	sub    $0x8,%esp
  801885:	53                   	push   %ebx
  801886:	6a 2d                	push   $0x2d
  801888:	ff d6                	call   *%esi
				num = -(long long) num;
  80188a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80188d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801890:	f7 d8                	neg    %eax
  801892:	83 d2 00             	adc    $0x0,%edx
  801895:	f7 da                	neg    %edx
  801897:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80189a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80189f:	eb 55                	jmp    8018f6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8018a4:	e8 83 fc ff ff       	call   80152c <getuint>
			base = 10;
  8018a9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018ae:	eb 46                	jmp    8018f6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b3:	e8 74 fc ff ff       	call   80152c <getuint>
			base = 8;
  8018b8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018bd:	eb 37                	jmp    8018f6 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018bf:	83 ec 08             	sub    $0x8,%esp
  8018c2:	53                   	push   %ebx
  8018c3:	6a 30                	push   $0x30
  8018c5:	ff d6                	call   *%esi
			putch('x', putdat);
  8018c7:	83 c4 08             	add    $0x8,%esp
  8018ca:	53                   	push   %ebx
  8018cb:	6a 78                	push   $0x78
  8018cd:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8018cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d2:	8d 50 04             	lea    0x4(%eax),%edx
  8018d5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8018d8:	8b 00                	mov    (%eax),%eax
  8018da:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018df:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8018e2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8018e7:	eb 0d                	jmp    8018f6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8018ec:	e8 3b fc ff ff       	call   80152c <getuint>
			base = 16;
  8018f1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018f6:	83 ec 0c             	sub    $0xc,%esp
  8018f9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8018fd:	57                   	push   %edi
  8018fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801901:	51                   	push   %ecx
  801902:	52                   	push   %edx
  801903:	50                   	push   %eax
  801904:	89 da                	mov    %ebx,%edx
  801906:	89 f0                	mov    %esi,%eax
  801908:	e8 70 fb ff ff       	call   80147d <printnum>
			break;
  80190d:	83 c4 20             	add    $0x20,%esp
  801910:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801913:	e9 ae fc ff ff       	jmp    8015c6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801918:	83 ec 08             	sub    $0x8,%esp
  80191b:	53                   	push   %ebx
  80191c:	51                   	push   %ecx
  80191d:	ff d6                	call   *%esi
			break;
  80191f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801922:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801925:	e9 9c fc ff ff       	jmp    8015c6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80192a:	83 ec 08             	sub    $0x8,%esp
  80192d:	53                   	push   %ebx
  80192e:	6a 25                	push   $0x25
  801930:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	eb 03                	jmp    80193a <vprintfmt+0x39a>
  801937:	83 ef 01             	sub    $0x1,%edi
  80193a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80193e:	75 f7                	jne    801937 <vprintfmt+0x397>
  801940:	e9 81 fc ff ff       	jmp    8015c6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801945:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801948:	5b                   	pop    %ebx
  801949:	5e                   	pop    %esi
  80194a:	5f                   	pop    %edi
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    

0080194d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	83 ec 18             	sub    $0x18,%esp
  801953:	8b 45 08             	mov    0x8(%ebp),%eax
  801956:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801959:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80195c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801960:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801963:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80196a:	85 c0                	test   %eax,%eax
  80196c:	74 26                	je     801994 <vsnprintf+0x47>
  80196e:	85 d2                	test   %edx,%edx
  801970:	7e 22                	jle    801994 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801972:	ff 75 14             	pushl  0x14(%ebp)
  801975:	ff 75 10             	pushl  0x10(%ebp)
  801978:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80197b:	50                   	push   %eax
  80197c:	68 66 15 80 00       	push   $0x801566
  801981:	e8 1a fc ff ff       	call   8015a0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801986:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801989:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80198c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	eb 05                	jmp    801999 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801994:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019a1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019a4:	50                   	push   %eax
  8019a5:	ff 75 10             	pushl  0x10(%ebp)
  8019a8:	ff 75 0c             	pushl  0xc(%ebp)
  8019ab:	ff 75 08             	pushl  0x8(%ebp)
  8019ae:	e8 9a ff ff ff       	call   80194d <vsnprintf>
	va_end(ap);

	return rc;
}
  8019b3:	c9                   	leave  
  8019b4:	c3                   	ret    

008019b5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c0:	eb 03                	jmp    8019c5 <strlen+0x10>
		n++;
  8019c2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8019c5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8019c9:	75 f7                	jne    8019c2 <strlen+0xd>
		n++;
	return n;
}
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    

008019cd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019db:	eb 03                	jmp    8019e0 <strnlen+0x13>
		n++;
  8019dd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8019e0:	39 c2                	cmp    %eax,%edx
  8019e2:	74 08                	je     8019ec <strnlen+0x1f>
  8019e4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8019e8:	75 f3                	jne    8019dd <strnlen+0x10>
  8019ea:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	53                   	push   %ebx
  8019f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8019f8:	89 c2                	mov    %eax,%edx
  8019fa:	83 c2 01             	add    $0x1,%edx
  8019fd:	83 c1 01             	add    $0x1,%ecx
  801a00:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a04:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a07:	84 db                	test   %bl,%bl
  801a09:	75 ef                	jne    8019fa <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a0b:	5b                   	pop    %ebx
  801a0c:	5d                   	pop    %ebp
  801a0d:	c3                   	ret    

00801a0e <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	53                   	push   %ebx
  801a12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a15:	53                   	push   %ebx
  801a16:	e8 9a ff ff ff       	call   8019b5 <strlen>
  801a1b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a1e:	ff 75 0c             	pushl  0xc(%ebp)
  801a21:	01 d8                	add    %ebx,%eax
  801a23:	50                   	push   %eax
  801a24:	e8 c5 ff ff ff       	call   8019ee <strcpy>
	return dst;
}
  801a29:	89 d8                	mov    %ebx,%eax
  801a2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    

00801a30 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	8b 75 08             	mov    0x8(%ebp),%esi
  801a38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a3b:	89 f3                	mov    %esi,%ebx
  801a3d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a40:	89 f2                	mov    %esi,%edx
  801a42:	eb 0f                	jmp    801a53 <strncpy+0x23>
		*dst++ = *src;
  801a44:	83 c2 01             	add    $0x1,%edx
  801a47:	0f b6 01             	movzbl (%ecx),%eax
  801a4a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a4d:	80 39 01             	cmpb   $0x1,(%ecx)
  801a50:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a53:	39 da                	cmp    %ebx,%edx
  801a55:	75 ed                	jne    801a44 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a57:	89 f0                	mov    %esi,%eax
  801a59:	5b                   	pop    %ebx
  801a5a:	5e                   	pop    %esi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	56                   	push   %esi
  801a61:	53                   	push   %ebx
  801a62:	8b 75 08             	mov    0x8(%ebp),%esi
  801a65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a68:	8b 55 10             	mov    0x10(%ebp),%edx
  801a6b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801a6d:	85 d2                	test   %edx,%edx
  801a6f:	74 21                	je     801a92 <strlcpy+0x35>
  801a71:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801a75:	89 f2                	mov    %esi,%edx
  801a77:	eb 09                	jmp    801a82 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801a79:	83 c2 01             	add    $0x1,%edx
  801a7c:	83 c1 01             	add    $0x1,%ecx
  801a7f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801a82:	39 c2                	cmp    %eax,%edx
  801a84:	74 09                	je     801a8f <strlcpy+0x32>
  801a86:	0f b6 19             	movzbl (%ecx),%ebx
  801a89:	84 db                	test   %bl,%bl
  801a8b:	75 ec                	jne    801a79 <strlcpy+0x1c>
  801a8d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801a8f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801a92:	29 f0                	sub    %esi,%eax
}
  801a94:	5b                   	pop    %ebx
  801a95:	5e                   	pop    %esi
  801a96:	5d                   	pop    %ebp
  801a97:	c3                   	ret    

00801a98 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801aa1:	eb 06                	jmp    801aa9 <strcmp+0x11>
		p++, q++;
  801aa3:	83 c1 01             	add    $0x1,%ecx
  801aa6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801aa9:	0f b6 01             	movzbl (%ecx),%eax
  801aac:	84 c0                	test   %al,%al
  801aae:	74 04                	je     801ab4 <strcmp+0x1c>
  801ab0:	3a 02                	cmp    (%edx),%al
  801ab2:	74 ef                	je     801aa3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ab4:	0f b6 c0             	movzbl %al,%eax
  801ab7:	0f b6 12             	movzbl (%edx),%edx
  801aba:	29 d0                	sub    %edx,%eax
}
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	53                   	push   %ebx
  801ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ac8:	89 c3                	mov    %eax,%ebx
  801aca:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801acd:	eb 06                	jmp    801ad5 <strncmp+0x17>
		n--, p++, q++;
  801acf:	83 c0 01             	add    $0x1,%eax
  801ad2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ad5:	39 d8                	cmp    %ebx,%eax
  801ad7:	74 15                	je     801aee <strncmp+0x30>
  801ad9:	0f b6 08             	movzbl (%eax),%ecx
  801adc:	84 c9                	test   %cl,%cl
  801ade:	74 04                	je     801ae4 <strncmp+0x26>
  801ae0:	3a 0a                	cmp    (%edx),%cl
  801ae2:	74 eb                	je     801acf <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ae4:	0f b6 00             	movzbl (%eax),%eax
  801ae7:	0f b6 12             	movzbl (%edx),%edx
  801aea:	29 d0                	sub    %edx,%eax
  801aec:	eb 05                	jmp    801af3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801aee:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801af3:	5b                   	pop    %ebx
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b00:	eb 07                	jmp    801b09 <strchr+0x13>
		if (*s == c)
  801b02:	38 ca                	cmp    %cl,%dl
  801b04:	74 0f                	je     801b15 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b06:	83 c0 01             	add    $0x1,%eax
  801b09:	0f b6 10             	movzbl (%eax),%edx
  801b0c:	84 d2                	test   %dl,%dl
  801b0e:	75 f2                	jne    801b02 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b21:	eb 03                	jmp    801b26 <strfind+0xf>
  801b23:	83 c0 01             	add    $0x1,%eax
  801b26:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b29:	38 ca                	cmp    %cl,%dl
  801b2b:	74 04                	je     801b31 <strfind+0x1a>
  801b2d:	84 d2                	test   %dl,%dl
  801b2f:	75 f2                	jne    801b23 <strfind+0xc>
			break;
	return (char *) s;
}
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	57                   	push   %edi
  801b37:	56                   	push   %esi
  801b38:	53                   	push   %ebx
  801b39:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b3c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b3f:	85 c9                	test   %ecx,%ecx
  801b41:	74 36                	je     801b79 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b43:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b49:	75 28                	jne    801b73 <memset+0x40>
  801b4b:	f6 c1 03             	test   $0x3,%cl
  801b4e:	75 23                	jne    801b73 <memset+0x40>
		c &= 0xFF;
  801b50:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b54:	89 d3                	mov    %edx,%ebx
  801b56:	c1 e3 08             	shl    $0x8,%ebx
  801b59:	89 d6                	mov    %edx,%esi
  801b5b:	c1 e6 18             	shl    $0x18,%esi
  801b5e:	89 d0                	mov    %edx,%eax
  801b60:	c1 e0 10             	shl    $0x10,%eax
  801b63:	09 f0                	or     %esi,%eax
  801b65:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801b67:	89 d8                	mov    %ebx,%eax
  801b69:	09 d0                	or     %edx,%eax
  801b6b:	c1 e9 02             	shr    $0x2,%ecx
  801b6e:	fc                   	cld    
  801b6f:	f3 ab                	rep stos %eax,%es:(%edi)
  801b71:	eb 06                	jmp    801b79 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b76:	fc                   	cld    
  801b77:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801b79:	89 f8                	mov    %edi,%eax
  801b7b:	5b                   	pop    %ebx
  801b7c:	5e                   	pop    %esi
  801b7d:	5f                   	pop    %edi
  801b7e:	5d                   	pop    %ebp
  801b7f:	c3                   	ret    

00801b80 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	57                   	push   %edi
  801b84:	56                   	push   %esi
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801b8e:	39 c6                	cmp    %eax,%esi
  801b90:	73 35                	jae    801bc7 <memmove+0x47>
  801b92:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801b95:	39 d0                	cmp    %edx,%eax
  801b97:	73 2e                	jae    801bc7 <memmove+0x47>
		s += n;
		d += n;
  801b99:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801b9c:	89 d6                	mov    %edx,%esi
  801b9e:	09 fe                	or     %edi,%esi
  801ba0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801ba6:	75 13                	jne    801bbb <memmove+0x3b>
  801ba8:	f6 c1 03             	test   $0x3,%cl
  801bab:	75 0e                	jne    801bbb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bad:	83 ef 04             	sub    $0x4,%edi
  801bb0:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bb3:	c1 e9 02             	shr    $0x2,%ecx
  801bb6:	fd                   	std    
  801bb7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bb9:	eb 09                	jmp    801bc4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bbb:	83 ef 01             	sub    $0x1,%edi
  801bbe:	8d 72 ff             	lea    -0x1(%edx),%esi
  801bc1:	fd                   	std    
  801bc2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801bc4:	fc                   	cld    
  801bc5:	eb 1d                	jmp    801be4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bc7:	89 f2                	mov    %esi,%edx
  801bc9:	09 c2                	or     %eax,%edx
  801bcb:	f6 c2 03             	test   $0x3,%dl
  801bce:	75 0f                	jne    801bdf <memmove+0x5f>
  801bd0:	f6 c1 03             	test   $0x3,%cl
  801bd3:	75 0a                	jne    801bdf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801bd5:	c1 e9 02             	shr    $0x2,%ecx
  801bd8:	89 c7                	mov    %eax,%edi
  801bda:	fc                   	cld    
  801bdb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bdd:	eb 05                	jmp    801be4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801bdf:	89 c7                	mov    %eax,%edi
  801be1:	fc                   	cld    
  801be2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801beb:	ff 75 10             	pushl  0x10(%ebp)
  801bee:	ff 75 0c             	pushl  0xc(%ebp)
  801bf1:	ff 75 08             	pushl  0x8(%ebp)
  801bf4:	e8 87 ff ff ff       	call   801b80 <memmove>
}
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	56                   	push   %esi
  801bff:	53                   	push   %ebx
  801c00:	8b 45 08             	mov    0x8(%ebp),%eax
  801c03:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c06:	89 c6                	mov    %eax,%esi
  801c08:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c0b:	eb 1a                	jmp    801c27 <memcmp+0x2c>
		if (*s1 != *s2)
  801c0d:	0f b6 08             	movzbl (%eax),%ecx
  801c10:	0f b6 1a             	movzbl (%edx),%ebx
  801c13:	38 d9                	cmp    %bl,%cl
  801c15:	74 0a                	je     801c21 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c17:	0f b6 c1             	movzbl %cl,%eax
  801c1a:	0f b6 db             	movzbl %bl,%ebx
  801c1d:	29 d8                	sub    %ebx,%eax
  801c1f:	eb 0f                	jmp    801c30 <memcmp+0x35>
		s1++, s2++;
  801c21:	83 c0 01             	add    $0x1,%eax
  801c24:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c27:	39 f0                	cmp    %esi,%eax
  801c29:	75 e2                	jne    801c0d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c30:	5b                   	pop    %ebx
  801c31:	5e                   	pop    %esi
  801c32:	5d                   	pop    %ebp
  801c33:	c3                   	ret    

00801c34 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	53                   	push   %ebx
  801c38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c3b:	89 c1                	mov    %eax,%ecx
  801c3d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c40:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c44:	eb 0a                	jmp    801c50 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c46:	0f b6 10             	movzbl (%eax),%edx
  801c49:	39 da                	cmp    %ebx,%edx
  801c4b:	74 07                	je     801c54 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c4d:	83 c0 01             	add    $0x1,%eax
  801c50:	39 c8                	cmp    %ecx,%eax
  801c52:	72 f2                	jb     801c46 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c54:	5b                   	pop    %ebx
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	57                   	push   %edi
  801c5b:	56                   	push   %esi
  801c5c:	53                   	push   %ebx
  801c5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c63:	eb 03                	jmp    801c68 <strtol+0x11>
		s++;
  801c65:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801c68:	0f b6 01             	movzbl (%ecx),%eax
  801c6b:	3c 20                	cmp    $0x20,%al
  801c6d:	74 f6                	je     801c65 <strtol+0xe>
  801c6f:	3c 09                	cmp    $0x9,%al
  801c71:	74 f2                	je     801c65 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801c73:	3c 2b                	cmp    $0x2b,%al
  801c75:	75 0a                	jne    801c81 <strtol+0x2a>
		s++;
  801c77:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801c7a:	bf 00 00 00 00       	mov    $0x0,%edi
  801c7f:	eb 11                	jmp    801c92 <strtol+0x3b>
  801c81:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801c86:	3c 2d                	cmp    $0x2d,%al
  801c88:	75 08                	jne    801c92 <strtol+0x3b>
		s++, neg = 1;
  801c8a:	83 c1 01             	add    $0x1,%ecx
  801c8d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801c92:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801c98:	75 15                	jne    801caf <strtol+0x58>
  801c9a:	80 39 30             	cmpb   $0x30,(%ecx)
  801c9d:	75 10                	jne    801caf <strtol+0x58>
  801c9f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ca3:	75 7c                	jne    801d21 <strtol+0xca>
		s += 2, base = 16;
  801ca5:	83 c1 02             	add    $0x2,%ecx
  801ca8:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cad:	eb 16                	jmp    801cc5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801caf:	85 db                	test   %ebx,%ebx
  801cb1:	75 12                	jne    801cc5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cb3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cb8:	80 39 30             	cmpb   $0x30,(%ecx)
  801cbb:	75 08                	jne    801cc5 <strtol+0x6e>
		s++, base = 8;
  801cbd:	83 c1 01             	add    $0x1,%ecx
  801cc0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cca:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ccd:	0f b6 11             	movzbl (%ecx),%edx
  801cd0:	8d 72 d0             	lea    -0x30(%edx),%esi
  801cd3:	89 f3                	mov    %esi,%ebx
  801cd5:	80 fb 09             	cmp    $0x9,%bl
  801cd8:	77 08                	ja     801ce2 <strtol+0x8b>
			dig = *s - '0';
  801cda:	0f be d2             	movsbl %dl,%edx
  801cdd:	83 ea 30             	sub    $0x30,%edx
  801ce0:	eb 22                	jmp    801d04 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ce2:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ce5:	89 f3                	mov    %esi,%ebx
  801ce7:	80 fb 19             	cmp    $0x19,%bl
  801cea:	77 08                	ja     801cf4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801cec:	0f be d2             	movsbl %dl,%edx
  801cef:	83 ea 57             	sub    $0x57,%edx
  801cf2:	eb 10                	jmp    801d04 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801cf4:	8d 72 bf             	lea    -0x41(%edx),%esi
  801cf7:	89 f3                	mov    %esi,%ebx
  801cf9:	80 fb 19             	cmp    $0x19,%bl
  801cfc:	77 16                	ja     801d14 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801cfe:	0f be d2             	movsbl %dl,%edx
  801d01:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d04:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d07:	7d 0b                	jge    801d14 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d09:	83 c1 01             	add    $0x1,%ecx
  801d0c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d10:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d12:	eb b9                	jmp    801ccd <strtol+0x76>

	if (endptr)
  801d14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d18:	74 0d                	je     801d27 <strtol+0xd0>
		*endptr = (char *) s;
  801d1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d1d:	89 0e                	mov    %ecx,(%esi)
  801d1f:	eb 06                	jmp    801d27 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d21:	85 db                	test   %ebx,%ebx
  801d23:	74 98                	je     801cbd <strtol+0x66>
  801d25:	eb 9e                	jmp    801cc5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d27:	89 c2                	mov    %eax,%edx
  801d29:	f7 da                	neg    %edx
  801d2b:	85 ff                	test   %edi,%edi
  801d2d:	0f 45 c2             	cmovne %edx,%eax
}
  801d30:	5b                   	pop    %ebx
  801d31:	5e                   	pop    %esi
  801d32:	5f                   	pop    %edi
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    

00801d35 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d3b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d42:	75 2a                	jne    801d6e <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d44:	83 ec 04             	sub    $0x4,%esp
  801d47:	6a 07                	push   $0x7
  801d49:	68 00 f0 bf ee       	push   $0xeebff000
  801d4e:	6a 00                	push   $0x0
  801d50:	e8 23 e4 ff ff       	call   800178 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d55:	83 c4 10             	add    $0x10,%esp
  801d58:	85 c0                	test   %eax,%eax
  801d5a:	79 12                	jns    801d6e <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d5c:	50                   	push   %eax
  801d5d:	68 80 26 80 00       	push   $0x802680
  801d62:	6a 23                	push   $0x23
  801d64:	68 84 26 80 00       	push   $0x802684
  801d69:	e8 22 f6 ff ff       	call   801390 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d71:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801d76:	83 ec 08             	sub    $0x8,%esp
  801d79:	68 a0 1d 80 00       	push   $0x801da0
  801d7e:	6a 00                	push   $0x0
  801d80:	e8 3e e5 ff ff       	call   8002c3 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801d85:	83 c4 10             	add    $0x10,%esp
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	79 12                	jns    801d9e <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801d8c:	50                   	push   %eax
  801d8d:	68 80 26 80 00       	push   $0x802680
  801d92:	6a 2c                	push   $0x2c
  801d94:	68 84 26 80 00       	push   $0x802684
  801d99:	e8 f2 f5 ff ff       	call   801390 <_panic>
	}
}
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801da0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801da1:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801da6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801da8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  801dab:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  801daf:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  801db4:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  801db8:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  801dba:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  801dbd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  801dbe:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  801dc1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  801dc2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dc3:	c3                   	ret    

00801dc4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	56                   	push   %esi
  801dc8:	53                   	push   %ebx
  801dc9:	8b 75 08             	mov    0x8(%ebp),%esi
  801dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801dd2:	85 c0                	test   %eax,%eax
  801dd4:	75 12                	jne    801de8 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801dd6:	83 ec 0c             	sub    $0xc,%esp
  801dd9:	68 00 00 c0 ee       	push   $0xeec00000
  801dde:	e8 45 e5 ff ff       	call   800328 <sys_ipc_recv>
  801de3:	83 c4 10             	add    $0x10,%esp
  801de6:	eb 0c                	jmp    801df4 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801de8:	83 ec 0c             	sub    $0xc,%esp
  801deb:	50                   	push   %eax
  801dec:	e8 37 e5 ff ff       	call   800328 <sys_ipc_recv>
  801df1:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801df4:	85 f6                	test   %esi,%esi
  801df6:	0f 95 c1             	setne  %cl
  801df9:	85 db                	test   %ebx,%ebx
  801dfb:	0f 95 c2             	setne  %dl
  801dfe:	84 d1                	test   %dl,%cl
  801e00:	74 09                	je     801e0b <ipc_recv+0x47>
  801e02:	89 c2                	mov    %eax,%edx
  801e04:	c1 ea 1f             	shr    $0x1f,%edx
  801e07:	84 d2                	test   %dl,%dl
  801e09:	75 2d                	jne    801e38 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e0b:	85 f6                	test   %esi,%esi
  801e0d:	74 0d                	je     801e1c <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e0f:	a1 04 40 80 00       	mov    0x804004,%eax
  801e14:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e1a:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e1c:	85 db                	test   %ebx,%ebx
  801e1e:	74 0d                	je     801e2d <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e20:	a1 04 40 80 00       	mov    0x804004,%eax
  801e25:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e2b:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e2d:	a1 04 40 80 00       	mov    0x804004,%eax
  801e32:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3b:	5b                   	pop    %ebx
  801e3c:	5e                   	pop    %esi
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	57                   	push   %edi
  801e43:	56                   	push   %esi
  801e44:	53                   	push   %ebx
  801e45:	83 ec 0c             	sub    $0xc,%esp
  801e48:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e51:	85 db                	test   %ebx,%ebx
  801e53:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e58:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e5b:	ff 75 14             	pushl  0x14(%ebp)
  801e5e:	53                   	push   %ebx
  801e5f:	56                   	push   %esi
  801e60:	57                   	push   %edi
  801e61:	e8 9f e4 ff ff       	call   800305 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e66:	89 c2                	mov    %eax,%edx
  801e68:	c1 ea 1f             	shr    $0x1f,%edx
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	84 d2                	test   %dl,%dl
  801e70:	74 17                	je     801e89 <ipc_send+0x4a>
  801e72:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e75:	74 12                	je     801e89 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e77:	50                   	push   %eax
  801e78:	68 92 26 80 00       	push   $0x802692
  801e7d:	6a 47                	push   $0x47
  801e7f:	68 a0 26 80 00       	push   $0x8026a0
  801e84:	e8 07 f5 ff ff       	call   801390 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801e89:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e8c:	75 07                	jne    801e95 <ipc_send+0x56>
			sys_yield();
  801e8e:	e8 c6 e2 ff ff       	call   800159 <sys_yield>
  801e93:	eb c6                	jmp    801e5b <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801e95:	85 c0                	test   %eax,%eax
  801e97:	75 c2                	jne    801e5b <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801e99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e9c:	5b                   	pop    %ebx
  801e9d:	5e                   	pop    %esi
  801e9e:	5f                   	pop    %edi
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801eac:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801eb2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801eb8:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ebe:	39 ca                	cmp    %ecx,%edx
  801ec0:	75 10                	jne    801ed2 <ipc_find_env+0x31>
			return envs[i].env_id;
  801ec2:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801ec8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ecd:	8b 40 7c             	mov    0x7c(%eax),%eax
  801ed0:	eb 0f                	jmp    801ee1 <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed2:	83 c0 01             	add    $0x1,%eax
  801ed5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eda:	75 d0                	jne    801eac <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801edc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    

00801ee3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ee9:	89 d0                	mov    %edx,%eax
  801eeb:	c1 e8 16             	shr    $0x16,%eax
  801eee:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ef5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801efa:	f6 c1 01             	test   $0x1,%cl
  801efd:	74 1d                	je     801f1c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801eff:	c1 ea 0c             	shr    $0xc,%edx
  801f02:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f09:	f6 c2 01             	test   $0x1,%dl
  801f0c:	74 0e                	je     801f1c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f0e:	c1 ea 0c             	shr    $0xc,%edx
  801f11:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f18:	ef 
  801f19:	0f b7 c0             	movzwl %ax,%eax
}
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    
  801f1e:	66 90                	xchg   %ax,%ax

00801f20 <__udivdi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
  801f27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f37:	85 f6                	test   %esi,%esi
  801f39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f3d:	89 ca                	mov    %ecx,%edx
  801f3f:	89 f8                	mov    %edi,%eax
  801f41:	75 3d                	jne    801f80 <__udivdi3+0x60>
  801f43:	39 cf                	cmp    %ecx,%edi
  801f45:	0f 87 c5 00 00 00    	ja     802010 <__udivdi3+0xf0>
  801f4b:	85 ff                	test   %edi,%edi
  801f4d:	89 fd                	mov    %edi,%ebp
  801f4f:	75 0b                	jne    801f5c <__udivdi3+0x3c>
  801f51:	b8 01 00 00 00       	mov    $0x1,%eax
  801f56:	31 d2                	xor    %edx,%edx
  801f58:	f7 f7                	div    %edi
  801f5a:	89 c5                	mov    %eax,%ebp
  801f5c:	89 c8                	mov    %ecx,%eax
  801f5e:	31 d2                	xor    %edx,%edx
  801f60:	f7 f5                	div    %ebp
  801f62:	89 c1                	mov    %eax,%ecx
  801f64:	89 d8                	mov    %ebx,%eax
  801f66:	89 cf                	mov    %ecx,%edi
  801f68:	f7 f5                	div    %ebp
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	89 d8                	mov    %ebx,%eax
  801f6e:	89 fa                	mov    %edi,%edx
  801f70:	83 c4 1c             	add    $0x1c,%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
  801f78:	90                   	nop
  801f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f80:	39 ce                	cmp    %ecx,%esi
  801f82:	77 74                	ja     801ff8 <__udivdi3+0xd8>
  801f84:	0f bd fe             	bsr    %esi,%edi
  801f87:	83 f7 1f             	xor    $0x1f,%edi
  801f8a:	0f 84 98 00 00 00    	je     802028 <__udivdi3+0x108>
  801f90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	89 c5                	mov    %eax,%ebp
  801f99:	29 fb                	sub    %edi,%ebx
  801f9b:	d3 e6                	shl    %cl,%esi
  801f9d:	89 d9                	mov    %ebx,%ecx
  801f9f:	d3 ed                	shr    %cl,%ebp
  801fa1:	89 f9                	mov    %edi,%ecx
  801fa3:	d3 e0                	shl    %cl,%eax
  801fa5:	09 ee                	or     %ebp,%esi
  801fa7:	89 d9                	mov    %ebx,%ecx
  801fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fad:	89 d5                	mov    %edx,%ebp
  801faf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fb3:	d3 ed                	shr    %cl,%ebp
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e2                	shl    %cl,%edx
  801fb9:	89 d9                	mov    %ebx,%ecx
  801fbb:	d3 e8                	shr    %cl,%eax
  801fbd:	09 c2                	or     %eax,%edx
  801fbf:	89 d0                	mov    %edx,%eax
  801fc1:	89 ea                	mov    %ebp,%edx
  801fc3:	f7 f6                	div    %esi
  801fc5:	89 d5                	mov    %edx,%ebp
  801fc7:	89 c3                	mov    %eax,%ebx
  801fc9:	f7 64 24 0c          	mull   0xc(%esp)
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	72 10                	jb     801fe1 <__udivdi3+0xc1>
  801fd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e6                	shl    %cl,%esi
  801fd9:	39 c6                	cmp    %eax,%esi
  801fdb:	73 07                	jae    801fe4 <__udivdi3+0xc4>
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	75 03                	jne    801fe4 <__udivdi3+0xc4>
  801fe1:	83 eb 01             	sub    $0x1,%ebx
  801fe4:	31 ff                	xor    %edi,%edi
  801fe6:	89 d8                	mov    %ebx,%eax
  801fe8:	89 fa                	mov    %edi,%edx
  801fea:	83 c4 1c             	add    $0x1c,%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
  801ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff8:	31 ff                	xor    %edi,%edi
  801ffa:	31 db                	xor    %ebx,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	89 d8                	mov    %ebx,%eax
  802012:	f7 f7                	div    %edi
  802014:	31 ff                	xor    %edi,%edi
  802016:	89 c3                	mov    %eax,%ebx
  802018:	89 d8                	mov    %ebx,%eax
  80201a:	89 fa                	mov    %edi,%edx
  80201c:	83 c4 1c             	add    $0x1c,%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    
  802024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802028:	39 ce                	cmp    %ecx,%esi
  80202a:	72 0c                	jb     802038 <__udivdi3+0x118>
  80202c:	31 db                	xor    %ebx,%ebx
  80202e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802032:	0f 87 34 ff ff ff    	ja     801f6c <__udivdi3+0x4c>
  802038:	bb 01 00 00 00       	mov    $0x1,%ebx
  80203d:	e9 2a ff ff ff       	jmp    801f6c <__udivdi3+0x4c>
  802042:	66 90                	xchg   %ax,%ax
  802044:	66 90                	xchg   %ax,%ax
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__umoddi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80205b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80205f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 d2                	test   %edx,%edx
  802069:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80206d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802071:	89 f3                	mov    %esi,%ebx
  802073:	89 3c 24             	mov    %edi,(%esp)
  802076:	89 74 24 04          	mov    %esi,0x4(%esp)
  80207a:	75 1c                	jne    802098 <__umoddi3+0x48>
  80207c:	39 f7                	cmp    %esi,%edi
  80207e:	76 50                	jbe    8020d0 <__umoddi3+0x80>
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	f7 f7                	div    %edi
  802086:	89 d0                	mov    %edx,%eax
  802088:	31 d2                	xor    %edx,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	39 f2                	cmp    %esi,%edx
  80209a:	89 d0                	mov    %edx,%eax
  80209c:	77 52                	ja     8020f0 <__umoddi3+0xa0>
  80209e:	0f bd ea             	bsr    %edx,%ebp
  8020a1:	83 f5 1f             	xor    $0x1f,%ebp
  8020a4:	75 5a                	jne    802100 <__umoddi3+0xb0>
  8020a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020aa:	0f 82 e0 00 00 00    	jb     802190 <__umoddi3+0x140>
  8020b0:	39 0c 24             	cmp    %ecx,(%esp)
  8020b3:	0f 86 d7 00 00 00    	jbe    802190 <__umoddi3+0x140>
  8020b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020c1:	83 c4 1c             	add    $0x1c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	85 ff                	test   %edi,%edi
  8020d2:	89 fd                	mov    %edi,%ebp
  8020d4:	75 0b                	jne    8020e1 <__umoddi3+0x91>
  8020d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	f7 f7                	div    %edi
  8020df:	89 c5                	mov    %eax,%ebp
  8020e1:	89 f0                	mov    %esi,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  8020e5:	f7 f5                	div    %ebp
  8020e7:	89 c8                	mov    %ecx,%eax
  8020e9:	f7 f5                	div    %ebp
  8020eb:	89 d0                	mov    %edx,%eax
  8020ed:	eb 99                	jmp    802088 <__umoddi3+0x38>
  8020ef:	90                   	nop
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	83 c4 1c             	add    $0x1c,%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    
  8020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802100:	8b 34 24             	mov    (%esp),%esi
  802103:	bf 20 00 00 00       	mov    $0x20,%edi
  802108:	89 e9                	mov    %ebp,%ecx
  80210a:	29 ef                	sub    %ebp,%edi
  80210c:	d3 e0                	shl    %cl,%eax
  80210e:	89 f9                	mov    %edi,%ecx
  802110:	89 f2                	mov    %esi,%edx
  802112:	d3 ea                	shr    %cl,%edx
  802114:	89 e9                	mov    %ebp,%ecx
  802116:	09 c2                	or     %eax,%edx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 14 24             	mov    %edx,(%esp)
  80211d:	89 f2                	mov    %esi,%edx
  80211f:	d3 e2                	shl    %cl,%edx
  802121:	89 f9                	mov    %edi,%ecx
  802123:	89 54 24 04          	mov    %edx,0x4(%esp)
  802127:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	89 e9                	mov    %ebp,%ecx
  80212f:	89 c6                	mov    %eax,%esi
  802131:	d3 e3                	shl    %cl,%ebx
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 d0                	mov    %edx,%eax
  802137:	d3 e8                	shr    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	09 d8                	or     %ebx,%eax
  80213d:	89 d3                	mov    %edx,%ebx
  80213f:	89 f2                	mov    %esi,%edx
  802141:	f7 34 24             	divl   (%esp)
  802144:	89 d6                	mov    %edx,%esi
  802146:	d3 e3                	shl    %cl,%ebx
  802148:	f7 64 24 04          	mull   0x4(%esp)
  80214c:	39 d6                	cmp    %edx,%esi
  80214e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802152:	89 d1                	mov    %edx,%ecx
  802154:	89 c3                	mov    %eax,%ebx
  802156:	72 08                	jb     802160 <__umoddi3+0x110>
  802158:	75 11                	jne    80216b <__umoddi3+0x11b>
  80215a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80215e:	73 0b                	jae    80216b <__umoddi3+0x11b>
  802160:	2b 44 24 04          	sub    0x4(%esp),%eax
  802164:	1b 14 24             	sbb    (%esp),%edx
  802167:	89 d1                	mov    %edx,%ecx
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80216f:	29 da                	sub    %ebx,%edx
  802171:	19 ce                	sbb    %ecx,%esi
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 f0                	mov    %esi,%eax
  802177:	d3 e0                	shl    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	d3 ea                	shr    %cl,%edx
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	d3 ee                	shr    %cl,%esi
  802181:	09 d0                	or     %edx,%eax
  802183:	89 f2                	mov    %esi,%edx
  802185:	83 c4 1c             	add    $0x1c,%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    
  80218d:	8d 76 00             	lea    0x0(%esi),%esi
  802190:	29 f9                	sub    %edi,%ecx
  802192:	19 d6                	sbb    %edx,%esi
  802194:	89 74 24 04          	mov    %esi,0x4(%esp)
  802198:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80219c:	e9 18 ff ff ff       	jmp    8020b9 <__umoddi3+0x69>
