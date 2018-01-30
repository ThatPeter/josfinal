
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
  8000a8:	e8 66 0a 00 00       	call   800b13 <close_all>
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
  800121:	68 8a 24 80 00       	push   $0x80248a
  800126:	6a 23                	push   $0x23
  800128:	68 a7 24 80 00       	push   $0x8024a7
  80012d:	e8 12 15 00 00       	call   801644 <_panic>

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
  8001a2:	68 8a 24 80 00       	push   $0x80248a
  8001a7:	6a 23                	push   $0x23
  8001a9:	68 a7 24 80 00       	push   $0x8024a7
  8001ae:	e8 91 14 00 00       	call   801644 <_panic>

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
  8001e4:	68 8a 24 80 00       	push   $0x80248a
  8001e9:	6a 23                	push   $0x23
  8001eb:	68 a7 24 80 00       	push   $0x8024a7
  8001f0:	e8 4f 14 00 00       	call   801644 <_panic>

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
  800226:	68 8a 24 80 00       	push   $0x80248a
  80022b:	6a 23                	push   $0x23
  80022d:	68 a7 24 80 00       	push   $0x8024a7
  800232:	e8 0d 14 00 00       	call   801644 <_panic>

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
  800268:	68 8a 24 80 00       	push   $0x80248a
  80026d:	6a 23                	push   $0x23
  80026f:	68 a7 24 80 00       	push   $0x8024a7
  800274:	e8 cb 13 00 00       	call   801644 <_panic>

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
  8002aa:	68 8a 24 80 00       	push   $0x80248a
  8002af:	6a 23                	push   $0x23
  8002b1:	68 a7 24 80 00       	push   $0x8024a7
  8002b6:	e8 89 13 00 00       	call   801644 <_panic>
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
  8002ec:	68 8a 24 80 00       	push   $0x80248a
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 a7 24 80 00       	push   $0x8024a7
  8002f8:	e8 47 13 00 00       	call   801644 <_panic>

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
  800350:	68 8a 24 80 00       	push   $0x80248a
  800355:	6a 23                	push   $0x23
  800357:	68 a7 24 80 00       	push   $0x8024a7
  80035c:	e8 e3 12 00 00       	call   801644 <_panic>

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
  8003ef:	68 b5 24 80 00       	push   $0x8024b5
  8003f4:	6a 1f                	push   $0x1f
  8003f6:	68 c5 24 80 00       	push   $0x8024c5
  8003fb:	e8 44 12 00 00       	call   801644 <_panic>
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
  800419:	68 d0 24 80 00       	push   $0x8024d0
  80041e:	6a 2d                	push   $0x2d
  800420:	68 c5 24 80 00       	push   $0x8024c5
  800425:	e8 1a 12 00 00       	call   801644 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  80042a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  800430:	83 ec 04             	sub    $0x4,%esp
  800433:	68 00 10 00 00       	push   $0x1000
  800438:	53                   	push   %ebx
  800439:	68 00 f0 7f 00       	push   $0x7ff000
  80043e:	e8 59 1a 00 00       	call   801e9c <memcpy>

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
  800461:	68 d0 24 80 00       	push   $0x8024d0
  800466:	6a 34                	push   $0x34
  800468:	68 c5 24 80 00       	push   $0x8024c5
  80046d:	e8 d2 11 00 00       	call   801644 <_panic>
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
  800489:	68 d0 24 80 00       	push   $0x8024d0
  80048e:	6a 38                	push   $0x38
  800490:	68 c5 24 80 00       	push   $0x8024c5
  800495:	e8 aa 11 00 00       	call   801644 <_panic>
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
  8004ad:	e8 37 1b 00 00       	call   801fe9 <set_pgfault_handler>
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
  8004c6:	68 e9 24 80 00       	push   $0x8024e9
  8004cb:	68 85 00 00 00       	push   $0x85
  8004d0:	68 c5 24 80 00       	push   $0x8024c5
  8004d5:	e8 6a 11 00 00       	call   801644 <_panic>
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
  800582:	68 f7 24 80 00       	push   $0x8024f7
  800587:	6a 55                	push   $0x55
  800589:	68 c5 24 80 00       	push   $0x8024c5
  80058e:	e8 b1 10 00 00       	call   801644 <_panic>
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
  8005c7:	68 f7 24 80 00       	push   $0x8024f7
  8005cc:	6a 5c                	push   $0x5c
  8005ce:	68 c5 24 80 00       	push   $0x8024c5
  8005d3:	e8 6c 10 00 00       	call   801644 <_panic>
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
  8005f5:	68 f7 24 80 00       	push   $0x8024f7
  8005fa:	6a 60                	push   $0x60
  8005fc:	68 c5 24 80 00       	push   $0x8024c5
  800601:	e8 3e 10 00 00       	call   801644 <_panic>
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
  80061f:	68 f7 24 80 00       	push   $0x8024f7
  800624:	6a 65                	push   $0x65
  800626:	68 c5 24 80 00       	push   $0x8024c5
  80062b:	e8 14 10 00 00       	call   801644 <_panic>
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
  80068e:	68 88 25 80 00       	push   $0x802588
  800693:	e8 85 10 00 00       	call   80171d <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  800698:	c7 04 24 82 00 80 00 	movl   $0x800082,(%esp)
  80069f:	e8 c5 fc ff ff       	call   800369 <sys_thread_create>
  8006a4:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006a6:	83 c4 08             	add    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	68 88 25 80 00       	push   $0x802588
  8006af:	e8 69 10 00 00       	call   80171d <cprintf>
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

008006e3 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	56                   	push   %esi
  8006e7:	53                   	push   %ebx
  8006e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  8006ee:	83 ec 04             	sub    $0x4,%esp
  8006f1:	6a 07                	push   $0x7
  8006f3:	6a 00                	push   $0x0
  8006f5:	56                   	push   %esi
  8006f6:	e8 7d fa ff ff       	call   800178 <sys_page_alloc>
	if (r < 0) {
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	85 c0                	test   %eax,%eax
  800700:	79 15                	jns    800717 <queue_append+0x34>
		panic("%e\n", r);
  800702:	50                   	push   %eax
  800703:	68 83 25 80 00       	push   $0x802583
  800708:	68 c4 00 00 00       	push   $0xc4
  80070d:	68 c5 24 80 00       	push   $0x8024c5
  800712:	e8 2d 0f 00 00       	call   801644 <_panic>
	}	
	wt->envid = envid;
  800717:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  80071d:	83 ec 04             	sub    $0x4,%esp
  800720:	ff 33                	pushl  (%ebx)
  800722:	56                   	push   %esi
  800723:	68 ac 25 80 00       	push   $0x8025ac
  800728:	e8 f0 0f 00 00       	call   80171d <cprintf>
	if (queue->first == NULL) {
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	83 3b 00             	cmpl   $0x0,(%ebx)
  800733:	75 29                	jne    80075e <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  800735:	83 ec 0c             	sub    $0xc,%esp
  800738:	68 0d 25 80 00       	push   $0x80250d
  80073d:	e8 db 0f 00 00       	call   80171d <cprintf>
		queue->first = wt;
  800742:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  800748:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80074f:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800756:	00 00 00 
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 2b                	jmp    800789 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  80075e:	83 ec 0c             	sub    $0xc,%esp
  800761:	68 27 25 80 00       	push   $0x802527
  800766:	e8 b2 0f 00 00       	call   80171d <cprintf>
		queue->last->next = wt;
  80076b:	8b 43 04             	mov    0x4(%ebx),%eax
  80076e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  800775:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  80077c:	00 00 00 
		queue->last = wt;
  80077f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  800786:	83 c4 10             	add    $0x10,%esp
	}
}
  800789:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80078c:	5b                   	pop    %ebx
  80078d:	5e                   	pop    %esi
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	83 ec 04             	sub    $0x4,%esp
  800797:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  80079a:	8b 02                	mov    (%edx),%eax
  80079c:	85 c0                	test   %eax,%eax
  80079e:	75 17                	jne    8007b7 <queue_pop+0x27>
		panic("queue empty!\n");
  8007a0:	83 ec 04             	sub    $0x4,%esp
  8007a3:	68 45 25 80 00       	push   $0x802545
  8007a8:	68 d8 00 00 00       	push   $0xd8
  8007ad:	68 c5 24 80 00       	push   $0x8024c5
  8007b2:	e8 8d 0e 00 00       	call   801644 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8007b7:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ba:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8007bc:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	68 53 25 80 00       	push   $0x802553
  8007c7:	e8 51 0f 00 00       	call   80171d <cprintf>
	return envid;
}
  8007cc:	89 d8                	mov    %ebx,%eax
  8007ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d1:	c9                   	leave  
  8007d2:	c3                   	ret    

008007d3 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	83 ec 04             	sub    $0x4,%esp
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  8007dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8007e2:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	74 5a                	je     800843 <mutex_lock+0x70>
  8007e9:	8b 43 04             	mov    0x4(%ebx),%eax
  8007ec:	83 38 00             	cmpl   $0x0,(%eax)
  8007ef:	75 52                	jne    800843 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  8007f1:	83 ec 0c             	sub    $0xc,%esp
  8007f4:	68 d4 25 80 00       	push   $0x8025d4
  8007f9:	e8 1f 0f 00 00       	call   80171d <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  8007fe:	8b 5b 04             	mov    0x4(%ebx),%ebx
  800801:	e8 34 f9 ff ff       	call   80013a <sys_getenvid>
  800806:	83 c4 08             	add    $0x8,%esp
  800809:	53                   	push   %ebx
  80080a:	50                   	push   %eax
  80080b:	e8 d3 fe ff ff       	call   8006e3 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  800810:	e8 25 f9 ff ff       	call   80013a <sys_getenvid>
  800815:	83 c4 08             	add    $0x8,%esp
  800818:	6a 04                	push   $0x4
  80081a:	50                   	push   %eax
  80081b:	e8 1f fa ff ff       	call   80023f <sys_env_set_status>
		if (r < 0) {
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	85 c0                	test   %eax,%eax
  800825:	79 15                	jns    80083c <mutex_lock+0x69>
			panic("%e\n", r);
  800827:	50                   	push   %eax
  800828:	68 83 25 80 00       	push   $0x802583
  80082d:	68 eb 00 00 00       	push   $0xeb
  800832:	68 c5 24 80 00       	push   $0x8024c5
  800837:	e8 08 0e 00 00       	call   801644 <_panic>
		}
		sys_yield();
  80083c:	e8 18 f9 ff ff       	call   800159 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800841:	eb 18                	jmp    80085b <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  800843:	83 ec 0c             	sub    $0xc,%esp
  800846:	68 f4 25 80 00       	push   $0x8025f4
  80084b:	e8 cd 0e 00 00       	call   80171d <cprintf>
	mtx->owner = sys_getenvid();}
  800850:	e8 e5 f8 ff ff       	call   80013a <sys_getenvid>
  800855:	89 43 08             	mov    %eax,0x8(%ebx)
  800858:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80085b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	53                   	push   %ebx
  800864:	83 ec 04             	sub    $0x4,%esp
  800867:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80086a:	b8 00 00 00 00       	mov    $0x0,%eax
  80086f:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  800872:	8b 43 04             	mov    0x4(%ebx),%eax
  800875:	83 38 00             	cmpl   $0x0,(%eax)
  800878:	74 33                	je     8008ad <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  80087a:	83 ec 0c             	sub    $0xc,%esp
  80087d:	50                   	push   %eax
  80087e:	e8 0d ff ff ff       	call   800790 <queue_pop>
  800883:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  800886:	83 c4 08             	add    $0x8,%esp
  800889:	6a 02                	push   $0x2
  80088b:	50                   	push   %eax
  80088c:	e8 ae f9 ff ff       	call   80023f <sys_env_set_status>
		if (r < 0) {
  800891:	83 c4 10             	add    $0x10,%esp
  800894:	85 c0                	test   %eax,%eax
  800896:	79 15                	jns    8008ad <mutex_unlock+0x4d>
			panic("%e\n", r);
  800898:	50                   	push   %eax
  800899:	68 83 25 80 00       	push   $0x802583
  80089e:	68 00 01 00 00       	push   $0x100
  8008a3:	68 c5 24 80 00       	push   $0x8024c5
  8008a8:	e8 97 0d 00 00       	call   801644 <_panic>
		}
	}

	asm volatile("pause");
  8008ad:	f3 90                	pause  
	//sys_yield();
}
  8008af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b2:	c9                   	leave  
  8008b3:	c3                   	ret    

008008b4 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	83 ec 04             	sub    $0x4,%esp
  8008bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8008be:	e8 77 f8 ff ff       	call   80013a <sys_getenvid>
  8008c3:	83 ec 04             	sub    $0x4,%esp
  8008c6:	6a 07                	push   $0x7
  8008c8:	53                   	push   %ebx
  8008c9:	50                   	push   %eax
  8008ca:	e8 a9 f8 ff ff       	call   800178 <sys_page_alloc>
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	85 c0                	test   %eax,%eax
  8008d4:	79 15                	jns    8008eb <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  8008d6:	50                   	push   %eax
  8008d7:	68 6e 25 80 00       	push   $0x80256e
  8008dc:	68 0d 01 00 00       	push   $0x10d
  8008e1:	68 c5 24 80 00       	push   $0x8024c5
  8008e6:	e8 59 0d 00 00       	call   801644 <_panic>
	}	
	mtx->locked = 0;
  8008eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  8008f1:	8b 43 04             	mov    0x4(%ebx),%eax
  8008f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  8008fa:	8b 43 04             	mov    0x4(%ebx),%eax
  8008fd:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800904:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80090b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  800916:	e8 1f f8 ff ff       	call   80013a <sys_getenvid>
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	ff 75 08             	pushl  0x8(%ebp)
  800921:	50                   	push   %eax
  800922:	e8 d6 f8 ff ff       	call   8001fd <sys_page_unmap>
	if (r < 0) {
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	85 c0                	test   %eax,%eax
  80092c:	79 15                	jns    800943 <mutex_destroy+0x33>
		panic("%e\n", r);
  80092e:	50                   	push   %eax
  80092f:	68 83 25 80 00       	push   $0x802583
  800934:	68 1a 01 00 00       	push   $0x11a
  800939:	68 c5 24 80 00       	push   $0x8024c5
  80093e:	e8 01 0d 00 00       	call   801644 <_panic>
	}
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800948:	8b 45 08             	mov    0x8(%ebp),%eax
  80094b:	05 00 00 00 30       	add    $0x30000000,%eax
  800950:	c1 e8 0c             	shr    $0xc,%eax
}
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800958:	8b 45 08             	mov    0x8(%ebp),%eax
  80095b:	05 00 00 00 30       	add    $0x30000000,%eax
  800960:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800965:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800972:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800977:	89 c2                	mov    %eax,%edx
  800979:	c1 ea 16             	shr    $0x16,%edx
  80097c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800983:	f6 c2 01             	test   $0x1,%dl
  800986:	74 11                	je     800999 <fd_alloc+0x2d>
  800988:	89 c2                	mov    %eax,%edx
  80098a:	c1 ea 0c             	shr    $0xc,%edx
  80098d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800994:	f6 c2 01             	test   $0x1,%dl
  800997:	75 09                	jne    8009a2 <fd_alloc+0x36>
			*fd_store = fd;
  800999:	89 01                	mov    %eax,(%ecx)
			return 0;
  80099b:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a0:	eb 17                	jmp    8009b9 <fd_alloc+0x4d>
  8009a2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8009a7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8009ac:	75 c9                	jne    800977 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8009ae:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8009b4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8009c1:	83 f8 1f             	cmp    $0x1f,%eax
  8009c4:	77 36                	ja     8009fc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8009c6:	c1 e0 0c             	shl    $0xc,%eax
  8009c9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8009ce:	89 c2                	mov    %eax,%edx
  8009d0:	c1 ea 16             	shr    $0x16,%edx
  8009d3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8009da:	f6 c2 01             	test   $0x1,%dl
  8009dd:	74 24                	je     800a03 <fd_lookup+0x48>
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	c1 ea 0c             	shr    $0xc,%edx
  8009e4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009eb:	f6 c2 01             	test   $0x1,%dl
  8009ee:	74 1a                	je     800a0a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f3:	89 02                	mov    %eax,(%edx)
	return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fa:	eb 13                	jmp    800a0f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8009fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a01:	eb 0c                	jmp    800a0f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a08:	eb 05                	jmp    800a0f <fd_lookup+0x54>
  800a0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 08             	sub    $0x8,%esp
  800a17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1a:	ba 90 26 80 00       	mov    $0x802690,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800a1f:	eb 13                	jmp    800a34 <dev_lookup+0x23>
  800a21:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800a24:	39 08                	cmp    %ecx,(%eax)
  800a26:	75 0c                	jne    800a34 <dev_lookup+0x23>
			*dev = devtab[i];
  800a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2b:	89 01                	mov    %eax,(%ecx)
			return 0;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a32:	eb 31                	jmp    800a65 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800a34:	8b 02                	mov    (%edx),%eax
  800a36:	85 c0                	test   %eax,%eax
  800a38:	75 e7                	jne    800a21 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800a3a:	a1 04 40 80 00       	mov    0x804004,%eax
  800a3f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a45:	83 ec 04             	sub    $0x4,%esp
  800a48:	51                   	push   %ecx
  800a49:	50                   	push   %eax
  800a4a:	68 14 26 80 00       	push   $0x802614
  800a4f:	e8 c9 0c 00 00       	call   80171d <cprintf>
	*dev = 0;
  800a54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a57:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a5d:	83 c4 10             	add    $0x10,%esp
  800a60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	83 ec 10             	sub    $0x10,%esp
  800a6f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800a75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a78:	50                   	push   %eax
  800a79:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800a7f:	c1 e8 0c             	shr    $0xc,%eax
  800a82:	50                   	push   %eax
  800a83:	e8 33 ff ff ff       	call   8009bb <fd_lookup>
  800a88:	83 c4 08             	add    $0x8,%esp
  800a8b:	85 c0                	test   %eax,%eax
  800a8d:	78 05                	js     800a94 <fd_close+0x2d>
	    || fd != fd2)
  800a8f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800a92:	74 0c                	je     800aa0 <fd_close+0x39>
		return (must_exist ? r : 0);
  800a94:	84 db                	test   %bl,%bl
  800a96:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9b:	0f 44 c2             	cmove  %edx,%eax
  800a9e:	eb 41                	jmp    800ae1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800aa0:	83 ec 08             	sub    $0x8,%esp
  800aa3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aa6:	50                   	push   %eax
  800aa7:	ff 36                	pushl  (%esi)
  800aa9:	e8 63 ff ff ff       	call   800a11 <dev_lookup>
  800aae:	89 c3                	mov    %eax,%ebx
  800ab0:	83 c4 10             	add    $0x10,%esp
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	78 1a                	js     800ad1 <fd_close+0x6a>
		if (dev->dev_close)
  800ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aba:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800abd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	74 0b                	je     800ad1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ac6:	83 ec 0c             	sub    $0xc,%esp
  800ac9:	56                   	push   %esi
  800aca:	ff d0                	call   *%eax
  800acc:	89 c3                	mov    %eax,%ebx
  800ace:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ad1:	83 ec 08             	sub    $0x8,%esp
  800ad4:	56                   	push   %esi
  800ad5:	6a 00                	push   $0x0
  800ad7:	e8 21 f7 ff ff       	call   8001fd <sys_page_unmap>
	return r;
  800adc:	83 c4 10             	add    $0x10,%esp
  800adf:	89 d8                	mov    %ebx,%eax
}
  800ae1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800aee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af1:	50                   	push   %eax
  800af2:	ff 75 08             	pushl  0x8(%ebp)
  800af5:	e8 c1 fe ff ff       	call   8009bb <fd_lookup>
  800afa:	83 c4 08             	add    $0x8,%esp
  800afd:	85 c0                	test   %eax,%eax
  800aff:	78 10                	js     800b11 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800b01:	83 ec 08             	sub    $0x8,%esp
  800b04:	6a 01                	push   $0x1
  800b06:	ff 75 f4             	pushl  -0xc(%ebp)
  800b09:	e8 59 ff ff ff       	call   800a67 <fd_close>
  800b0e:	83 c4 10             	add    $0x10,%esp
}
  800b11:	c9                   	leave  
  800b12:	c3                   	ret    

00800b13 <close_all>:

void
close_all(void)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	53                   	push   %ebx
  800b17:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800b1a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	53                   	push   %ebx
  800b23:	e8 c0 ff ff ff       	call   800ae8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b28:	83 c3 01             	add    $0x1,%ebx
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	83 fb 20             	cmp    $0x20,%ebx
  800b31:	75 ec                	jne    800b1f <close_all+0xc>
		close(i);
}
  800b33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	83 ec 2c             	sub    $0x2c,%esp
  800b41:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b44:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b47:	50                   	push   %eax
  800b48:	ff 75 08             	pushl  0x8(%ebp)
  800b4b:	e8 6b fe ff ff       	call   8009bb <fd_lookup>
  800b50:	83 c4 08             	add    $0x8,%esp
  800b53:	85 c0                	test   %eax,%eax
  800b55:	0f 88 c1 00 00 00    	js     800c1c <dup+0xe4>
		return r;
	close(newfdnum);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	56                   	push   %esi
  800b5f:	e8 84 ff ff ff       	call   800ae8 <close>

	newfd = INDEX2FD(newfdnum);
  800b64:	89 f3                	mov    %esi,%ebx
  800b66:	c1 e3 0c             	shl    $0xc,%ebx
  800b69:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800b6f:	83 c4 04             	add    $0x4,%esp
  800b72:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b75:	e8 db fd ff ff       	call   800955 <fd2data>
  800b7a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800b7c:	89 1c 24             	mov    %ebx,(%esp)
  800b7f:	e8 d1 fd ff ff       	call   800955 <fd2data>
  800b84:	83 c4 10             	add    $0x10,%esp
  800b87:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800b8a:	89 f8                	mov    %edi,%eax
  800b8c:	c1 e8 16             	shr    $0x16,%eax
  800b8f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b96:	a8 01                	test   $0x1,%al
  800b98:	74 37                	je     800bd1 <dup+0x99>
  800b9a:	89 f8                	mov    %edi,%eax
  800b9c:	c1 e8 0c             	shr    $0xc,%eax
  800b9f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ba6:	f6 c2 01             	test   $0x1,%dl
  800ba9:	74 26                	je     800bd1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800bab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	25 07 0e 00 00       	and    $0xe07,%eax
  800bba:	50                   	push   %eax
  800bbb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bbe:	6a 00                	push   $0x0
  800bc0:	57                   	push   %edi
  800bc1:	6a 00                	push   $0x0
  800bc3:	e8 f3 f5 ff ff       	call   8001bb <sys_page_map>
  800bc8:	89 c7                	mov    %eax,%edi
  800bca:	83 c4 20             	add    $0x20,%esp
  800bcd:	85 c0                	test   %eax,%eax
  800bcf:	78 2e                	js     800bff <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bd1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800bd4:	89 d0                	mov    %edx,%eax
  800bd6:	c1 e8 0c             	shr    $0xc,%eax
  800bd9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	25 07 0e 00 00       	and    $0xe07,%eax
  800be8:	50                   	push   %eax
  800be9:	53                   	push   %ebx
  800bea:	6a 00                	push   $0x0
  800bec:	52                   	push   %edx
  800bed:	6a 00                	push   $0x0
  800bef:	e8 c7 f5 ff ff       	call   8001bb <sys_page_map>
  800bf4:	89 c7                	mov    %eax,%edi
  800bf6:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800bf9:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800bfb:	85 ff                	test   %edi,%edi
  800bfd:	79 1d                	jns    800c1c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800bff:	83 ec 08             	sub    $0x8,%esp
  800c02:	53                   	push   %ebx
  800c03:	6a 00                	push   $0x0
  800c05:	e8 f3 f5 ff ff       	call   8001fd <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c0a:	83 c4 08             	add    $0x8,%esp
  800c0d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c10:	6a 00                	push   $0x0
  800c12:	e8 e6 f5 ff ff       	call   8001fd <sys_page_unmap>
	return r;
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	89 f8                	mov    %edi,%eax
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	53                   	push   %ebx
  800c28:	83 ec 14             	sub    $0x14,%esp
  800c2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c31:	50                   	push   %eax
  800c32:	53                   	push   %ebx
  800c33:	e8 83 fd ff ff       	call   8009bb <fd_lookup>
  800c38:	83 c4 08             	add    $0x8,%esp
  800c3b:	89 c2                	mov    %eax,%edx
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	78 70                	js     800cb1 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c47:	50                   	push   %eax
  800c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c4b:	ff 30                	pushl  (%eax)
  800c4d:	e8 bf fd ff ff       	call   800a11 <dev_lookup>
  800c52:	83 c4 10             	add    $0x10,%esp
  800c55:	85 c0                	test   %eax,%eax
  800c57:	78 4f                	js     800ca8 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c59:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c5c:	8b 42 08             	mov    0x8(%edx),%eax
  800c5f:	83 e0 03             	and    $0x3,%eax
  800c62:	83 f8 01             	cmp    $0x1,%eax
  800c65:	75 24                	jne    800c8b <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800c67:	a1 04 40 80 00       	mov    0x804004,%eax
  800c6c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800c72:	83 ec 04             	sub    $0x4,%esp
  800c75:	53                   	push   %ebx
  800c76:	50                   	push   %eax
  800c77:	68 55 26 80 00       	push   $0x802655
  800c7c:	e8 9c 0a 00 00       	call   80171d <cprintf>
		return -E_INVAL;
  800c81:	83 c4 10             	add    $0x10,%esp
  800c84:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c89:	eb 26                	jmp    800cb1 <read+0x8d>
	}
	if (!dev->dev_read)
  800c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8e:	8b 40 08             	mov    0x8(%eax),%eax
  800c91:	85 c0                	test   %eax,%eax
  800c93:	74 17                	je     800cac <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800c95:	83 ec 04             	sub    $0x4,%esp
  800c98:	ff 75 10             	pushl  0x10(%ebp)
  800c9b:	ff 75 0c             	pushl  0xc(%ebp)
  800c9e:	52                   	push   %edx
  800c9f:	ff d0                	call   *%eax
  800ca1:	89 c2                	mov    %eax,%edx
  800ca3:	83 c4 10             	add    $0x10,%esp
  800ca6:	eb 09                	jmp    800cb1 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ca8:	89 c2                	mov    %eax,%edx
  800caa:	eb 05                	jmp    800cb1 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800cac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800cb1:	89 d0                	mov    %edx,%eax
  800cb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cb6:	c9                   	leave  
  800cb7:	c3                   	ret    

00800cb8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cc4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	eb 21                	jmp    800cef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800cce:	83 ec 04             	sub    $0x4,%esp
  800cd1:	89 f0                	mov    %esi,%eax
  800cd3:	29 d8                	sub    %ebx,%eax
  800cd5:	50                   	push   %eax
  800cd6:	89 d8                	mov    %ebx,%eax
  800cd8:	03 45 0c             	add    0xc(%ebp),%eax
  800cdb:	50                   	push   %eax
  800cdc:	57                   	push   %edi
  800cdd:	e8 42 ff ff ff       	call   800c24 <read>
		if (m < 0)
  800ce2:	83 c4 10             	add    $0x10,%esp
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	78 10                	js     800cf9 <readn+0x41>
			return m;
		if (m == 0)
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	74 0a                	je     800cf7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800ced:	01 c3                	add    %eax,%ebx
  800cef:	39 f3                	cmp    %esi,%ebx
  800cf1:	72 db                	jb     800cce <readn+0x16>
  800cf3:	89 d8                	mov    %ebx,%eax
  800cf5:	eb 02                	jmp    800cf9 <readn+0x41>
  800cf7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	53                   	push   %ebx
  800d05:	83 ec 14             	sub    $0x14,%esp
  800d08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d0b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d0e:	50                   	push   %eax
  800d0f:	53                   	push   %ebx
  800d10:	e8 a6 fc ff ff       	call   8009bb <fd_lookup>
  800d15:	83 c4 08             	add    $0x8,%esp
  800d18:	89 c2                	mov    %eax,%edx
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	78 6b                	js     800d89 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d1e:	83 ec 08             	sub    $0x8,%esp
  800d21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d24:	50                   	push   %eax
  800d25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d28:	ff 30                	pushl  (%eax)
  800d2a:	e8 e2 fc ff ff       	call   800a11 <dev_lookup>
  800d2f:	83 c4 10             	add    $0x10,%esp
  800d32:	85 c0                	test   %eax,%eax
  800d34:	78 4a                	js     800d80 <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d39:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d3d:	75 24                	jne    800d63 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d3f:	a1 04 40 80 00       	mov    0x804004,%eax
  800d44:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800d4a:	83 ec 04             	sub    $0x4,%esp
  800d4d:	53                   	push   %ebx
  800d4e:	50                   	push   %eax
  800d4f:	68 71 26 80 00       	push   $0x802671
  800d54:	e8 c4 09 00 00       	call   80171d <cprintf>
		return -E_INVAL;
  800d59:	83 c4 10             	add    $0x10,%esp
  800d5c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800d61:	eb 26                	jmp    800d89 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800d63:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d66:	8b 52 0c             	mov    0xc(%edx),%edx
  800d69:	85 d2                	test   %edx,%edx
  800d6b:	74 17                	je     800d84 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800d6d:	83 ec 04             	sub    $0x4,%esp
  800d70:	ff 75 10             	pushl  0x10(%ebp)
  800d73:	ff 75 0c             	pushl  0xc(%ebp)
  800d76:	50                   	push   %eax
  800d77:	ff d2                	call   *%edx
  800d79:	89 c2                	mov    %eax,%edx
  800d7b:	83 c4 10             	add    $0x10,%esp
  800d7e:	eb 09                	jmp    800d89 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d80:	89 c2                	mov    %eax,%edx
  800d82:	eb 05                	jmp    800d89 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800d84:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800d89:	89 d0                	mov    %edx,%eax
  800d8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <seek>:

int
seek(int fdnum, off_t offset)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800d96:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800d99:	50                   	push   %eax
  800d9a:	ff 75 08             	pushl  0x8(%ebp)
  800d9d:	e8 19 fc ff ff       	call   8009bb <fd_lookup>
  800da2:	83 c4 08             	add    $0x8,%esp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	78 0e                	js     800db7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800da9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800dac:	8b 55 0c             	mov    0xc(%ebp),%edx
  800daf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800db2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	53                   	push   %ebx
  800dbd:	83 ec 14             	sub    $0x14,%esp
  800dc0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800dc3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc6:	50                   	push   %eax
  800dc7:	53                   	push   %ebx
  800dc8:	e8 ee fb ff ff       	call   8009bb <fd_lookup>
  800dcd:	83 c4 08             	add    $0x8,%esp
  800dd0:	89 c2                	mov    %eax,%edx
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	78 68                	js     800e3e <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dd6:	83 ec 08             	sub    $0x8,%esp
  800dd9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ddc:	50                   	push   %eax
  800ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de0:	ff 30                	pushl  (%eax)
  800de2:	e8 2a fc ff ff       	call   800a11 <dev_lookup>
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	78 47                	js     800e35 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800df5:	75 24                	jne    800e1b <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800df7:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800dfc:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e02:	83 ec 04             	sub    $0x4,%esp
  800e05:	53                   	push   %ebx
  800e06:	50                   	push   %eax
  800e07:	68 34 26 80 00       	push   $0x802634
  800e0c:	e8 0c 09 00 00       	call   80171d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800e11:	83 c4 10             	add    $0x10,%esp
  800e14:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e19:	eb 23                	jmp    800e3e <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800e1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e1e:	8b 52 18             	mov    0x18(%edx),%edx
  800e21:	85 d2                	test   %edx,%edx
  800e23:	74 14                	je     800e39 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800e25:	83 ec 08             	sub    $0x8,%esp
  800e28:	ff 75 0c             	pushl  0xc(%ebp)
  800e2b:	50                   	push   %eax
  800e2c:	ff d2                	call   *%edx
  800e2e:	89 c2                	mov    %eax,%edx
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	eb 09                	jmp    800e3e <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	eb 05                	jmp    800e3e <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800e39:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800e3e:	89 d0                	mov    %edx,%eax
  800e40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e43:	c9                   	leave  
  800e44:	c3                   	ret    

00800e45 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	53                   	push   %ebx
  800e49:	83 ec 14             	sub    $0x14,%esp
  800e4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e4f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e52:	50                   	push   %eax
  800e53:	ff 75 08             	pushl  0x8(%ebp)
  800e56:	e8 60 fb ff ff       	call   8009bb <fd_lookup>
  800e5b:	83 c4 08             	add    $0x8,%esp
  800e5e:	89 c2                	mov    %eax,%edx
  800e60:	85 c0                	test   %eax,%eax
  800e62:	78 58                	js     800ebc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e64:	83 ec 08             	sub    $0x8,%esp
  800e67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e6a:	50                   	push   %eax
  800e6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e6e:	ff 30                	pushl  (%eax)
  800e70:	e8 9c fb ff ff       	call   800a11 <dev_lookup>
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	78 37                	js     800eb3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800e83:	74 32                	je     800eb7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800e85:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800e88:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800e8f:	00 00 00 
	stat->st_isdir = 0;
  800e92:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800e99:	00 00 00 
	stat->st_dev = dev;
  800e9c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ea2:	83 ec 08             	sub    $0x8,%esp
  800ea5:	53                   	push   %ebx
  800ea6:	ff 75 f0             	pushl  -0x10(%ebp)
  800ea9:	ff 50 14             	call   *0x14(%eax)
  800eac:	89 c2                	mov    %eax,%edx
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	eb 09                	jmp    800ebc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	eb 05                	jmp    800ebc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800eb7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800ebc:	89 d0                	mov    %edx,%eax
  800ebe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ec8:	83 ec 08             	sub    $0x8,%esp
  800ecb:	6a 00                	push   $0x0
  800ecd:	ff 75 08             	pushl  0x8(%ebp)
  800ed0:	e8 e3 01 00 00       	call   8010b8 <open>
  800ed5:	89 c3                	mov    %eax,%ebx
  800ed7:	83 c4 10             	add    $0x10,%esp
  800eda:	85 c0                	test   %eax,%eax
  800edc:	78 1b                	js     800ef9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800ede:	83 ec 08             	sub    $0x8,%esp
  800ee1:	ff 75 0c             	pushl  0xc(%ebp)
  800ee4:	50                   	push   %eax
  800ee5:	e8 5b ff ff ff       	call   800e45 <fstat>
  800eea:	89 c6                	mov    %eax,%esi
	close(fd);
  800eec:	89 1c 24             	mov    %ebx,(%esp)
  800eef:	e8 f4 fb ff ff       	call   800ae8 <close>
	return r;
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	89 f0                	mov    %esi,%eax
}
  800ef9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800efc:	5b                   	pop    %ebx
  800efd:	5e                   	pop    %esi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	56                   	push   %esi
  800f04:	53                   	push   %ebx
  800f05:	89 c6                	mov    %eax,%esi
  800f07:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800f09:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800f10:	75 12                	jne    800f24 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800f12:	83 ec 0c             	sub    $0xc,%esp
  800f15:	6a 01                	push   $0x1
  800f17:	e8 39 12 00 00       	call   802155 <ipc_find_env>
  800f1c:	a3 00 40 80 00       	mov    %eax,0x804000
  800f21:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800f24:	6a 07                	push   $0x7
  800f26:	68 00 50 80 00       	push   $0x805000
  800f2b:	56                   	push   %esi
  800f2c:	ff 35 00 40 80 00    	pushl  0x804000
  800f32:	e8 bc 11 00 00       	call   8020f3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800f37:	83 c4 0c             	add    $0xc,%esp
  800f3a:	6a 00                	push   $0x0
  800f3c:	53                   	push   %ebx
  800f3d:	6a 00                	push   $0x0
  800f3f:	e8 34 11 00 00       	call   802078 <ipc_recv>
}
  800f44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f51:	8b 45 08             	mov    0x8(%ebp),%eax
  800f54:	8b 40 0c             	mov    0xc(%eax),%eax
  800f57:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800f64:	ba 00 00 00 00       	mov    $0x0,%edx
  800f69:	b8 02 00 00 00       	mov    $0x2,%eax
  800f6e:	e8 8d ff ff ff       	call   800f00 <fsipc>
}
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7e:	8b 40 0c             	mov    0xc(%eax),%eax
  800f81:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800f86:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8b:	b8 06 00 00 00       	mov    $0x6,%eax
  800f90:	e8 6b ff ff ff       	call   800f00 <fsipc>
}
  800f95:	c9                   	leave  
  800f96:	c3                   	ret    

00800f97 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa4:	8b 40 0c             	mov    0xc(%eax),%eax
  800fa7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800fac:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb1:	b8 05 00 00 00       	mov    $0x5,%eax
  800fb6:	e8 45 ff ff ff       	call   800f00 <fsipc>
  800fbb:	85 c0                	test   %eax,%eax
  800fbd:	78 2c                	js     800feb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800fbf:	83 ec 08             	sub    $0x8,%esp
  800fc2:	68 00 50 80 00       	push   $0x805000
  800fc7:	53                   	push   %ebx
  800fc8:	e8 d5 0c 00 00       	call   801ca2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800fcd:	a1 80 50 80 00       	mov    0x805080,%eax
  800fd2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800fd8:	a1 84 50 80 00       	mov    0x805084,%eax
  800fdd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800feb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	8b 52 0c             	mov    0xc(%edx),%edx
  800fff:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801005:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80100a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80100f:	0f 47 c2             	cmova  %edx,%eax
  801012:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801017:	50                   	push   %eax
  801018:	ff 75 0c             	pushl  0xc(%ebp)
  80101b:	68 08 50 80 00       	push   $0x805008
  801020:	e8 0f 0e 00 00       	call   801e34 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801025:	ba 00 00 00 00       	mov    $0x0,%edx
  80102a:	b8 04 00 00 00       	mov    $0x4,%eax
  80102f:	e8 cc fe ff ff       	call   800f00 <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80103e:	8b 45 08             	mov    0x8(%ebp),%eax
  801041:	8b 40 0c             	mov    0xc(%eax),%eax
  801044:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801049:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80104f:	ba 00 00 00 00       	mov    $0x0,%edx
  801054:	b8 03 00 00 00       	mov    $0x3,%eax
  801059:	e8 a2 fe ff ff       	call   800f00 <fsipc>
  80105e:	89 c3                	mov    %eax,%ebx
  801060:	85 c0                	test   %eax,%eax
  801062:	78 4b                	js     8010af <devfile_read+0x79>
		return r;
	assert(r <= n);
  801064:	39 c6                	cmp    %eax,%esi
  801066:	73 16                	jae    80107e <devfile_read+0x48>
  801068:	68 a0 26 80 00       	push   $0x8026a0
  80106d:	68 a7 26 80 00       	push   $0x8026a7
  801072:	6a 7c                	push   $0x7c
  801074:	68 bc 26 80 00       	push   $0x8026bc
  801079:	e8 c6 05 00 00       	call   801644 <_panic>
	assert(r <= PGSIZE);
  80107e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801083:	7e 16                	jle    80109b <devfile_read+0x65>
  801085:	68 c7 26 80 00       	push   $0x8026c7
  80108a:	68 a7 26 80 00       	push   $0x8026a7
  80108f:	6a 7d                	push   $0x7d
  801091:	68 bc 26 80 00       	push   $0x8026bc
  801096:	e8 a9 05 00 00       	call   801644 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80109b:	83 ec 04             	sub    $0x4,%esp
  80109e:	50                   	push   %eax
  80109f:	68 00 50 80 00       	push   $0x805000
  8010a4:	ff 75 0c             	pushl  0xc(%ebp)
  8010a7:	e8 88 0d 00 00       	call   801e34 <memmove>
	return r;
  8010ac:	83 c4 10             	add    $0x10,%esp
}
  8010af:	89 d8                	mov    %ebx,%eax
  8010b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b4:	5b                   	pop    %ebx
  8010b5:	5e                   	pop    %esi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	53                   	push   %ebx
  8010bc:	83 ec 20             	sub    $0x20,%esp
  8010bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8010c2:	53                   	push   %ebx
  8010c3:	e8 a1 0b 00 00       	call   801c69 <strlen>
  8010c8:	83 c4 10             	add    $0x10,%esp
  8010cb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8010d0:	7f 67                	jg     801139 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010d2:	83 ec 0c             	sub    $0xc,%esp
  8010d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d8:	50                   	push   %eax
  8010d9:	e8 8e f8 ff ff       	call   80096c <fd_alloc>
  8010de:	83 c4 10             	add    $0x10,%esp
		return r;
  8010e1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 57                	js     80113e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8010e7:	83 ec 08             	sub    $0x8,%esp
  8010ea:	53                   	push   %ebx
  8010eb:	68 00 50 80 00       	push   $0x805000
  8010f0:	e8 ad 0b 00 00       	call   801ca2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8010f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8010fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801100:	b8 01 00 00 00       	mov    $0x1,%eax
  801105:	e8 f6 fd ff ff       	call   800f00 <fsipc>
  80110a:	89 c3                	mov    %eax,%ebx
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	79 14                	jns    801127 <open+0x6f>
		fd_close(fd, 0);
  801113:	83 ec 08             	sub    $0x8,%esp
  801116:	6a 00                	push   $0x0
  801118:	ff 75 f4             	pushl  -0xc(%ebp)
  80111b:	e8 47 f9 ff ff       	call   800a67 <fd_close>
		return r;
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	89 da                	mov    %ebx,%edx
  801125:	eb 17                	jmp    80113e <open+0x86>
	}

	return fd2num(fd);
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	ff 75 f4             	pushl  -0xc(%ebp)
  80112d:	e8 13 f8 ff ff       	call   800945 <fd2num>
  801132:	89 c2                	mov    %eax,%edx
  801134:	83 c4 10             	add    $0x10,%esp
  801137:	eb 05                	jmp    80113e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801139:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80113e:	89 d0                	mov    %edx,%eax
  801140:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80114b:	ba 00 00 00 00       	mov    $0x0,%edx
  801150:	b8 08 00 00 00       	mov    $0x8,%eax
  801155:	e8 a6 fd ff ff       	call   800f00 <fsipc>
}
  80115a:	c9                   	leave  
  80115b:	c3                   	ret    

0080115c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801164:	83 ec 0c             	sub    $0xc,%esp
  801167:	ff 75 08             	pushl  0x8(%ebp)
  80116a:	e8 e6 f7 ff ff       	call   800955 <fd2data>
  80116f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801171:	83 c4 08             	add    $0x8,%esp
  801174:	68 d3 26 80 00       	push   $0x8026d3
  801179:	53                   	push   %ebx
  80117a:	e8 23 0b 00 00       	call   801ca2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80117f:	8b 46 04             	mov    0x4(%esi),%eax
  801182:	2b 06                	sub    (%esi),%eax
  801184:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80118a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801191:	00 00 00 
	stat->st_dev = &devpipe;
  801194:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80119b:	30 80 00 
	return 0;
}
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 0c             	sub    $0xc,%esp
  8011b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8011b4:	53                   	push   %ebx
  8011b5:	6a 00                	push   $0x0
  8011b7:	e8 41 f0 ff ff       	call   8001fd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8011bc:	89 1c 24             	mov    %ebx,(%esp)
  8011bf:	e8 91 f7 ff ff       	call   800955 <fd2data>
  8011c4:	83 c4 08             	add    $0x8,%esp
  8011c7:	50                   	push   %eax
  8011c8:	6a 00                	push   $0x0
  8011ca:	e8 2e f0 ff ff       	call   8001fd <sys_page_unmap>
}
  8011cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d2:	c9                   	leave  
  8011d3:	c3                   	ret    

008011d4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	57                   	push   %edi
  8011d8:	56                   	push   %esi
  8011d9:	53                   	push   %ebx
  8011da:	83 ec 1c             	sub    $0x1c,%esp
  8011dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8011e0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8011e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e7:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8011ed:	83 ec 0c             	sub    $0xc,%esp
  8011f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f3:	e8 a2 0f 00 00       	call   80219a <pageref>
  8011f8:	89 c3                	mov    %eax,%ebx
  8011fa:	89 3c 24             	mov    %edi,(%esp)
  8011fd:	e8 98 0f 00 00       	call   80219a <pageref>
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	39 c3                	cmp    %eax,%ebx
  801207:	0f 94 c1             	sete   %cl
  80120a:	0f b6 c9             	movzbl %cl,%ecx
  80120d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801210:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801216:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  80121c:	39 ce                	cmp    %ecx,%esi
  80121e:	74 1e                	je     80123e <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  801220:	39 c3                	cmp    %eax,%ebx
  801222:	75 be                	jne    8011e2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801224:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  80122a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80122d:	50                   	push   %eax
  80122e:	56                   	push   %esi
  80122f:	68 da 26 80 00       	push   $0x8026da
  801234:	e8 e4 04 00 00       	call   80171d <cprintf>
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	eb a4                	jmp    8011e2 <_pipeisclosed+0xe>
	}
}
  80123e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	57                   	push   %edi
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
  80124f:	83 ec 28             	sub    $0x28,%esp
  801252:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801255:	56                   	push   %esi
  801256:	e8 fa f6 ff ff       	call   800955 <fd2data>
  80125b:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	bf 00 00 00 00       	mov    $0x0,%edi
  801265:	eb 4b                	jmp    8012b2 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801267:	89 da                	mov    %ebx,%edx
  801269:	89 f0                	mov    %esi,%eax
  80126b:	e8 64 ff ff ff       	call   8011d4 <_pipeisclosed>
  801270:	85 c0                	test   %eax,%eax
  801272:	75 48                	jne    8012bc <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801274:	e8 e0 ee ff ff       	call   800159 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801279:	8b 43 04             	mov    0x4(%ebx),%eax
  80127c:	8b 0b                	mov    (%ebx),%ecx
  80127e:	8d 51 20             	lea    0x20(%ecx),%edx
  801281:	39 d0                	cmp    %edx,%eax
  801283:	73 e2                	jae    801267 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801288:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80128c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80128f:	89 c2                	mov    %eax,%edx
  801291:	c1 fa 1f             	sar    $0x1f,%edx
  801294:	89 d1                	mov    %edx,%ecx
  801296:	c1 e9 1b             	shr    $0x1b,%ecx
  801299:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80129c:	83 e2 1f             	and    $0x1f,%edx
  80129f:	29 ca                	sub    %ecx,%edx
  8012a1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8012a5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8012a9:	83 c0 01             	add    $0x1,%eax
  8012ac:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012af:	83 c7 01             	add    $0x1,%edi
  8012b2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8012b5:	75 c2                	jne    801279 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8012b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ba:	eb 05                	jmp    8012c1 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012bc:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8012c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 18             	sub    $0x18,%esp
  8012d2:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8012d5:	57                   	push   %edi
  8012d6:	e8 7a f6 ff ff       	call   800955 <fd2data>
  8012db:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e5:	eb 3d                	jmp    801324 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8012e7:	85 db                	test   %ebx,%ebx
  8012e9:	74 04                	je     8012ef <devpipe_read+0x26>
				return i;
  8012eb:	89 d8                	mov    %ebx,%eax
  8012ed:	eb 44                	jmp    801333 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8012ef:	89 f2                	mov    %esi,%edx
  8012f1:	89 f8                	mov    %edi,%eax
  8012f3:	e8 dc fe ff ff       	call   8011d4 <_pipeisclosed>
  8012f8:	85 c0                	test   %eax,%eax
  8012fa:	75 32                	jne    80132e <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8012fc:	e8 58 ee ff ff       	call   800159 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801301:	8b 06                	mov    (%esi),%eax
  801303:	3b 46 04             	cmp    0x4(%esi),%eax
  801306:	74 df                	je     8012e7 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801308:	99                   	cltd   
  801309:	c1 ea 1b             	shr    $0x1b,%edx
  80130c:	01 d0                	add    %edx,%eax
  80130e:	83 e0 1f             	and    $0x1f,%eax
  801311:	29 d0                	sub    %edx,%eax
  801313:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131b:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80131e:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801321:	83 c3 01             	add    $0x1,%ebx
  801324:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801327:	75 d8                	jne    801301 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801329:	8b 45 10             	mov    0x10(%ebp),%eax
  80132c:	eb 05                	jmp    801333 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80132e:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801333:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801336:	5b                   	pop    %ebx
  801337:	5e                   	pop    %esi
  801338:	5f                   	pop    %edi
  801339:	5d                   	pop    %ebp
  80133a:	c3                   	ret    

0080133b <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	56                   	push   %esi
  80133f:	53                   	push   %ebx
  801340:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	e8 20 f6 ff ff       	call   80096c <fd_alloc>
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	89 c2                	mov    %eax,%edx
  801351:	85 c0                	test   %eax,%eax
  801353:	0f 88 2c 01 00 00    	js     801485 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801359:	83 ec 04             	sub    $0x4,%esp
  80135c:	68 07 04 00 00       	push   $0x407
  801361:	ff 75 f4             	pushl  -0xc(%ebp)
  801364:	6a 00                	push   $0x0
  801366:	e8 0d ee ff ff       	call   800178 <sys_page_alloc>
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	89 c2                	mov    %eax,%edx
  801370:	85 c0                	test   %eax,%eax
  801372:	0f 88 0d 01 00 00    	js     801485 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801378:	83 ec 0c             	sub    $0xc,%esp
  80137b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	e8 e8 f5 ff ff       	call   80096c <fd_alloc>
  801384:	89 c3                	mov    %eax,%ebx
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	85 c0                	test   %eax,%eax
  80138b:	0f 88 e2 00 00 00    	js     801473 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801391:	83 ec 04             	sub    $0x4,%esp
  801394:	68 07 04 00 00       	push   $0x407
  801399:	ff 75 f0             	pushl  -0x10(%ebp)
  80139c:	6a 00                	push   $0x0
  80139e:	e8 d5 ed ff ff       	call   800178 <sys_page_alloc>
  8013a3:	89 c3                	mov    %eax,%ebx
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	0f 88 c3 00 00 00    	js     801473 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8013b0:	83 ec 0c             	sub    $0xc,%esp
  8013b3:	ff 75 f4             	pushl  -0xc(%ebp)
  8013b6:	e8 9a f5 ff ff       	call   800955 <fd2data>
  8013bb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013bd:	83 c4 0c             	add    $0xc,%esp
  8013c0:	68 07 04 00 00       	push   $0x407
  8013c5:	50                   	push   %eax
  8013c6:	6a 00                	push   $0x0
  8013c8:	e8 ab ed ff ff       	call   800178 <sys_page_alloc>
  8013cd:	89 c3                	mov    %eax,%ebx
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	0f 88 89 00 00 00    	js     801463 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013da:	83 ec 0c             	sub    $0xc,%esp
  8013dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e0:	e8 70 f5 ff ff       	call   800955 <fd2data>
  8013e5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8013ec:	50                   	push   %eax
  8013ed:	6a 00                	push   $0x0
  8013ef:	56                   	push   %esi
  8013f0:	6a 00                	push   $0x0
  8013f2:	e8 c4 ed ff ff       	call   8001bb <sys_page_map>
  8013f7:	89 c3                	mov    %eax,%ebx
  8013f9:	83 c4 20             	add    $0x20,%esp
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 55                	js     801455 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801400:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801406:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801409:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80140b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801415:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80141b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801420:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801423:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80142a:	83 ec 0c             	sub    $0xc,%esp
  80142d:	ff 75 f4             	pushl  -0xc(%ebp)
  801430:	e8 10 f5 ff ff       	call   800945 <fd2num>
  801435:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801438:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80143a:	83 c4 04             	add    $0x4,%esp
  80143d:	ff 75 f0             	pushl  -0x10(%ebp)
  801440:	e8 00 f5 ff ff       	call   800945 <fd2num>
  801445:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801448:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	ba 00 00 00 00       	mov    $0x0,%edx
  801453:	eb 30                	jmp    801485 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	56                   	push   %esi
  801459:	6a 00                	push   $0x0
  80145b:	e8 9d ed ff ff       	call   8001fd <sys_page_unmap>
  801460:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	ff 75 f0             	pushl  -0x10(%ebp)
  801469:	6a 00                	push   $0x0
  80146b:	e8 8d ed ff ff       	call   8001fd <sys_page_unmap>
  801470:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	ff 75 f4             	pushl  -0xc(%ebp)
  801479:	6a 00                	push   $0x0
  80147b:	e8 7d ed ff ff       	call   8001fd <sys_page_unmap>
  801480:	83 c4 10             	add    $0x10,%esp
  801483:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801485:	89 d0                	mov    %edx,%eax
  801487:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80148a:	5b                   	pop    %ebx
  80148b:	5e                   	pop    %esi
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
  801491:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	ff 75 08             	pushl  0x8(%ebp)
  80149b:	e8 1b f5 ff ff       	call   8009bb <fd_lookup>
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 18                	js     8014bf <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8014a7:	83 ec 0c             	sub    $0xc,%esp
  8014aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ad:	e8 a3 f4 ff ff       	call   800955 <fd2data>
	return _pipeisclosed(fd, p);
  8014b2:	89 c2                	mov    %eax,%edx
  8014b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b7:	e8 18 fd ff ff       	call   8011d4 <_pipeisclosed>
  8014bc:	83 c4 10             	add    $0x10,%esp
}
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8014c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c9:	5d                   	pop    %ebp
  8014ca:	c3                   	ret    

008014cb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8014d1:	68 f2 26 80 00       	push   $0x8026f2
  8014d6:	ff 75 0c             	pushl  0xc(%ebp)
  8014d9:	e8 c4 07 00 00       	call   801ca2 <strcpy>
	return 0;
}
  8014de:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e3:	c9                   	leave  
  8014e4:	c3                   	ret    

008014e5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	57                   	push   %edi
  8014e9:	56                   	push   %esi
  8014ea:	53                   	push   %ebx
  8014eb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014f1:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8014f6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8014fc:	eb 2d                	jmp    80152b <devcons_write+0x46>
		m = n - tot;
  8014fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801501:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801503:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801506:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80150b:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80150e:	83 ec 04             	sub    $0x4,%esp
  801511:	53                   	push   %ebx
  801512:	03 45 0c             	add    0xc(%ebp),%eax
  801515:	50                   	push   %eax
  801516:	57                   	push   %edi
  801517:	e8 18 09 00 00       	call   801e34 <memmove>
		sys_cputs(buf, m);
  80151c:	83 c4 08             	add    $0x8,%esp
  80151f:	53                   	push   %ebx
  801520:	57                   	push   %edi
  801521:	e8 96 eb ff ff       	call   8000bc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801526:	01 de                	add    %ebx,%esi
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	89 f0                	mov    %esi,%eax
  80152d:	3b 75 10             	cmp    0x10(%ebp),%esi
  801530:	72 cc                	jb     8014fe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801532:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801535:	5b                   	pop    %ebx
  801536:	5e                   	pop    %esi
  801537:	5f                   	pop    %edi
  801538:	5d                   	pop    %ebp
  801539:	c3                   	ret    

0080153a <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	83 ec 08             	sub    $0x8,%esp
  801540:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801545:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801549:	74 2a                	je     801575 <devcons_read+0x3b>
  80154b:	eb 05                	jmp    801552 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80154d:	e8 07 ec ff ff       	call   800159 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801552:	e8 83 eb ff ff       	call   8000da <sys_cgetc>
  801557:	85 c0                	test   %eax,%eax
  801559:	74 f2                	je     80154d <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80155b:	85 c0                	test   %eax,%eax
  80155d:	78 16                	js     801575 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80155f:	83 f8 04             	cmp    $0x4,%eax
  801562:	74 0c                	je     801570 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801564:	8b 55 0c             	mov    0xc(%ebp),%edx
  801567:	88 02                	mov    %al,(%edx)
	return 1;
  801569:	b8 01 00 00 00       	mov    $0x1,%eax
  80156e:	eb 05                	jmp    801575 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801570:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801575:	c9                   	leave  
  801576:	c3                   	ret    

00801577 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80157d:	8b 45 08             	mov    0x8(%ebp),%eax
  801580:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801583:	6a 01                	push   $0x1
  801585:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	e8 2e eb ff ff       	call   8000bc <sys_cputs>
}
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <getchar>:

int
getchar(void)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801599:	6a 01                	push   $0x1
  80159b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80159e:	50                   	push   %eax
  80159f:	6a 00                	push   $0x0
  8015a1:	e8 7e f6 ff ff       	call   800c24 <read>
	if (r < 0)
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 0f                	js     8015bc <getchar+0x29>
		return r;
	if (r < 1)
  8015ad:	85 c0                	test   %eax,%eax
  8015af:	7e 06                	jle    8015b7 <getchar+0x24>
		return -E_EOF;
	return c;
  8015b1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8015b5:	eb 05                	jmp    8015bc <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8015b7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8015bc:	c9                   	leave  
  8015bd:	c3                   	ret    

008015be <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	ff 75 08             	pushl  0x8(%ebp)
  8015cb:	e8 eb f3 ff ff       	call   8009bb <fd_lookup>
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 11                	js     8015e8 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8015d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015da:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8015e0:	39 10                	cmp    %edx,(%eax)
  8015e2:	0f 94 c0             	sete   %al
  8015e5:	0f b6 c0             	movzbl %al,%eax
}
  8015e8:	c9                   	leave  
  8015e9:	c3                   	ret    

008015ea <opencons>:

int
opencons(void)
{
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	e8 73 f3 ff ff       	call   80096c <fd_alloc>
  8015f9:	83 c4 10             	add    $0x10,%esp
		return r;
  8015fc:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 3e                	js     801640 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801602:	83 ec 04             	sub    $0x4,%esp
  801605:	68 07 04 00 00       	push   $0x407
  80160a:	ff 75 f4             	pushl  -0xc(%ebp)
  80160d:	6a 00                	push   $0x0
  80160f:	e8 64 eb ff ff       	call   800178 <sys_page_alloc>
  801614:	83 c4 10             	add    $0x10,%esp
		return r;
  801617:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 23                	js     801640 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80161d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801623:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801626:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801628:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801632:	83 ec 0c             	sub    $0xc,%esp
  801635:	50                   	push   %eax
  801636:	e8 0a f3 ff ff       	call   800945 <fd2num>
  80163b:	89 c2                	mov    %eax,%edx
  80163d:	83 c4 10             	add    $0x10,%esp
}
  801640:	89 d0                	mov    %edx,%eax
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	56                   	push   %esi
  801648:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801649:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80164c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801652:	e8 e3 ea ff ff       	call   80013a <sys_getenvid>
  801657:	83 ec 0c             	sub    $0xc,%esp
  80165a:	ff 75 0c             	pushl  0xc(%ebp)
  80165d:	ff 75 08             	pushl  0x8(%ebp)
  801660:	56                   	push   %esi
  801661:	50                   	push   %eax
  801662:	68 00 27 80 00       	push   $0x802700
  801667:	e8 b1 00 00 00       	call   80171d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80166c:	83 c4 18             	add    $0x18,%esp
  80166f:	53                   	push   %ebx
  801670:	ff 75 10             	pushl  0x10(%ebp)
  801673:	e8 54 00 00 00       	call   8016cc <vcprintf>
	cprintf("\n");
  801678:	c7 04 24 51 25 80 00 	movl   $0x802551,(%esp)
  80167f:	e8 99 00 00 00       	call   80171d <cprintf>
  801684:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801687:	cc                   	int3   
  801688:	eb fd                	jmp    801687 <_panic+0x43>

0080168a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	53                   	push   %ebx
  80168e:	83 ec 04             	sub    $0x4,%esp
  801691:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801694:	8b 13                	mov    (%ebx),%edx
  801696:	8d 42 01             	lea    0x1(%edx),%eax
  801699:	89 03                	mov    %eax,(%ebx)
  80169b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8016a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8016a7:	75 1a                	jne    8016c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8016a9:	83 ec 08             	sub    $0x8,%esp
  8016ac:	68 ff 00 00 00       	push   $0xff
  8016b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8016b4:	50                   	push   %eax
  8016b5:	e8 02 ea ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  8016ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8016c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8016c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8016d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016dc:	00 00 00 
	b.cnt = 0;
  8016df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8016e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8016e9:	ff 75 0c             	pushl  0xc(%ebp)
  8016ec:	ff 75 08             	pushl  0x8(%ebp)
  8016ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	68 8a 16 80 00       	push   $0x80168a
  8016fb:	e8 54 01 00 00       	call   801854 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801700:	83 c4 08             	add    $0x8,%esp
  801703:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801709:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80170f:	50                   	push   %eax
  801710:	e8 a7 e9 ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  801715:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801723:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801726:	50                   	push   %eax
  801727:	ff 75 08             	pushl  0x8(%ebp)
  80172a:	e8 9d ff ff ff       	call   8016cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	57                   	push   %edi
  801735:	56                   	push   %esi
  801736:	53                   	push   %ebx
  801737:	83 ec 1c             	sub    $0x1c,%esp
  80173a:	89 c7                	mov    %eax,%edi
  80173c:	89 d6                	mov    %edx,%esi
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	8b 55 0c             	mov    0xc(%ebp),%edx
  801744:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801747:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80174a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80174d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801752:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801755:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801758:	39 d3                	cmp    %edx,%ebx
  80175a:	72 05                	jb     801761 <printnum+0x30>
  80175c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80175f:	77 45                	ja     8017a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801761:	83 ec 0c             	sub    $0xc,%esp
  801764:	ff 75 18             	pushl  0x18(%ebp)
  801767:	8b 45 14             	mov    0x14(%ebp),%eax
  80176a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80176d:	53                   	push   %ebx
  80176e:	ff 75 10             	pushl  0x10(%ebp)
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	ff 75 e4             	pushl  -0x1c(%ebp)
  801777:	ff 75 e0             	pushl  -0x20(%ebp)
  80177a:	ff 75 dc             	pushl  -0x24(%ebp)
  80177d:	ff 75 d8             	pushl  -0x28(%ebp)
  801780:	e8 5b 0a 00 00       	call   8021e0 <__udivdi3>
  801785:	83 c4 18             	add    $0x18,%esp
  801788:	52                   	push   %edx
  801789:	50                   	push   %eax
  80178a:	89 f2                	mov    %esi,%edx
  80178c:	89 f8                	mov    %edi,%eax
  80178e:	e8 9e ff ff ff       	call   801731 <printnum>
  801793:	83 c4 20             	add    $0x20,%esp
  801796:	eb 18                	jmp    8017b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	56                   	push   %esi
  80179c:	ff 75 18             	pushl  0x18(%ebp)
  80179f:	ff d7                	call   *%edi
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	eb 03                	jmp    8017a9 <printnum+0x78>
  8017a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017a9:	83 eb 01             	sub    $0x1,%ebx
  8017ac:	85 db                	test   %ebx,%ebx
  8017ae:	7f e8                	jg     801798 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	56                   	push   %esi
  8017b4:	83 ec 04             	sub    $0x4,%esp
  8017b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8017bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8017c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8017c3:	e8 48 0b 00 00       	call   802310 <__umoddi3>
  8017c8:	83 c4 14             	add    $0x14,%esp
  8017cb:	0f be 80 23 27 80 00 	movsbl 0x802723(%eax),%eax
  8017d2:	50                   	push   %eax
  8017d3:	ff d7                	call   *%edi
}
  8017d5:	83 c4 10             	add    $0x10,%esp
  8017d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017db:	5b                   	pop    %ebx
  8017dc:	5e                   	pop    %esi
  8017dd:	5f                   	pop    %edi
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8017e3:	83 fa 01             	cmp    $0x1,%edx
  8017e6:	7e 0e                	jle    8017f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8017e8:	8b 10                	mov    (%eax),%edx
  8017ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017ed:	89 08                	mov    %ecx,(%eax)
  8017ef:	8b 02                	mov    (%edx),%eax
  8017f1:	8b 52 04             	mov    0x4(%edx),%edx
  8017f4:	eb 22                	jmp    801818 <getuint+0x38>
	else if (lflag)
  8017f6:	85 d2                	test   %edx,%edx
  8017f8:	74 10                	je     80180a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8017fa:	8b 10                	mov    (%eax),%edx
  8017fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017ff:	89 08                	mov    %ecx,(%eax)
  801801:	8b 02                	mov    (%edx),%eax
  801803:	ba 00 00 00 00       	mov    $0x0,%edx
  801808:	eb 0e                	jmp    801818 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80180a:	8b 10                	mov    (%eax),%edx
  80180c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80180f:	89 08                	mov    %ecx,(%eax)
  801811:	8b 02                	mov    (%edx),%eax
  801813:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801818:	5d                   	pop    %ebp
  801819:	c3                   	ret    

0080181a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80181a:	55                   	push   %ebp
  80181b:	89 e5                	mov    %esp,%ebp
  80181d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801820:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801824:	8b 10                	mov    (%eax),%edx
  801826:	3b 50 04             	cmp    0x4(%eax),%edx
  801829:	73 0a                	jae    801835 <sprintputch+0x1b>
		*b->buf++ = ch;
  80182b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80182e:	89 08                	mov    %ecx,(%eax)
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	88 02                	mov    %al,(%edx)
}
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80183d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801840:	50                   	push   %eax
  801841:	ff 75 10             	pushl  0x10(%ebp)
  801844:	ff 75 0c             	pushl  0xc(%ebp)
  801847:	ff 75 08             	pushl  0x8(%ebp)
  80184a:	e8 05 00 00 00       	call   801854 <vprintfmt>
	va_end(ap);
}
  80184f:	83 c4 10             	add    $0x10,%esp
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	57                   	push   %edi
  801858:	56                   	push   %esi
  801859:	53                   	push   %ebx
  80185a:	83 ec 2c             	sub    $0x2c,%esp
  80185d:	8b 75 08             	mov    0x8(%ebp),%esi
  801860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801863:	8b 7d 10             	mov    0x10(%ebp),%edi
  801866:	eb 12                	jmp    80187a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801868:	85 c0                	test   %eax,%eax
  80186a:	0f 84 89 03 00 00    	je     801bf9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  801870:	83 ec 08             	sub    $0x8,%esp
  801873:	53                   	push   %ebx
  801874:	50                   	push   %eax
  801875:	ff d6                	call   *%esi
  801877:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80187a:	83 c7 01             	add    $0x1,%edi
  80187d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801881:	83 f8 25             	cmp    $0x25,%eax
  801884:	75 e2                	jne    801868 <vprintfmt+0x14>
  801886:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80188a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801891:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801898:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80189f:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a4:	eb 07                	jmp    8018ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ad:	8d 47 01             	lea    0x1(%edi),%eax
  8018b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018b3:	0f b6 07             	movzbl (%edi),%eax
  8018b6:	0f b6 c8             	movzbl %al,%ecx
  8018b9:	83 e8 23             	sub    $0x23,%eax
  8018bc:	3c 55                	cmp    $0x55,%al
  8018be:	0f 87 1a 03 00 00    	ja     801bde <vprintfmt+0x38a>
  8018c4:	0f b6 c0             	movzbl %al,%eax
  8018c7:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  8018ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8018d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8018d5:	eb d6                	jmp    8018ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018da:	b8 00 00 00 00       	mov    $0x0,%eax
  8018df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8018e5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8018e9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8018ec:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8018ef:	83 fa 09             	cmp    $0x9,%edx
  8018f2:	77 39                	ja     80192d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8018f7:	eb e9                	jmp    8018e2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8018ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801902:	8b 00                	mov    (%eax),%eax
  801904:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801907:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80190a:	eb 27                	jmp    801933 <vprintfmt+0xdf>
  80190c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80190f:	85 c0                	test   %eax,%eax
  801911:	b9 00 00 00 00       	mov    $0x0,%ecx
  801916:	0f 49 c8             	cmovns %eax,%ecx
  801919:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80191c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80191f:	eb 8c                	jmp    8018ad <vprintfmt+0x59>
  801921:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801924:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80192b:	eb 80                	jmp    8018ad <vprintfmt+0x59>
  80192d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801930:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801933:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801937:	0f 89 70 ff ff ff    	jns    8018ad <vprintfmt+0x59>
				width = precision, precision = -1;
  80193d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801940:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801943:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80194a:	e9 5e ff ff ff       	jmp    8018ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80194f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801952:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801955:	e9 53 ff ff ff       	jmp    8018ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80195a:	8b 45 14             	mov    0x14(%ebp),%eax
  80195d:	8d 50 04             	lea    0x4(%eax),%edx
  801960:	89 55 14             	mov    %edx,0x14(%ebp)
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	53                   	push   %ebx
  801967:	ff 30                	pushl  (%eax)
  801969:	ff d6                	call   *%esi
			break;
  80196b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80196e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801971:	e9 04 ff ff ff       	jmp    80187a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801976:	8b 45 14             	mov    0x14(%ebp),%eax
  801979:	8d 50 04             	lea    0x4(%eax),%edx
  80197c:	89 55 14             	mov    %edx,0x14(%ebp)
  80197f:	8b 00                	mov    (%eax),%eax
  801981:	99                   	cltd   
  801982:	31 d0                	xor    %edx,%eax
  801984:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801986:	83 f8 0f             	cmp    $0xf,%eax
  801989:	7f 0b                	jg     801996 <vprintfmt+0x142>
  80198b:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  801992:	85 d2                	test   %edx,%edx
  801994:	75 18                	jne    8019ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801996:	50                   	push   %eax
  801997:	68 3b 27 80 00       	push   $0x80273b
  80199c:	53                   	push   %ebx
  80199d:	56                   	push   %esi
  80199e:	e8 94 fe ff ff       	call   801837 <printfmt>
  8019a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019a9:	e9 cc fe ff ff       	jmp    80187a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8019ae:	52                   	push   %edx
  8019af:	68 b9 26 80 00       	push   $0x8026b9
  8019b4:	53                   	push   %ebx
  8019b5:	56                   	push   %esi
  8019b6:	e8 7c fe ff ff       	call   801837 <printfmt>
  8019bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019c1:	e9 b4 fe ff ff       	jmp    80187a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8019c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c9:	8d 50 04             	lea    0x4(%eax),%edx
  8019cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8019cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8019d1:	85 ff                	test   %edi,%edi
  8019d3:	b8 34 27 80 00       	mov    $0x802734,%eax
  8019d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8019db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8019df:	0f 8e 94 00 00 00    	jle    801a79 <vprintfmt+0x225>
  8019e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8019e9:	0f 84 98 00 00 00    	je     801a87 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8019ef:	83 ec 08             	sub    $0x8,%esp
  8019f2:	ff 75 d0             	pushl  -0x30(%ebp)
  8019f5:	57                   	push   %edi
  8019f6:	e8 86 02 00 00       	call   801c81 <strnlen>
  8019fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8019fe:	29 c1                	sub    %eax,%ecx
  801a00:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801a03:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801a06:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801a0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a0d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801a10:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a12:	eb 0f                	jmp    801a23 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801a14:	83 ec 08             	sub    $0x8,%esp
  801a17:	53                   	push   %ebx
  801a18:	ff 75 e0             	pushl  -0x20(%ebp)
  801a1b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a1d:	83 ef 01             	sub    $0x1,%edi
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	85 ff                	test   %edi,%edi
  801a25:	7f ed                	jg     801a14 <vprintfmt+0x1c0>
  801a27:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801a2a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801a2d:	85 c9                	test   %ecx,%ecx
  801a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a34:	0f 49 c1             	cmovns %ecx,%eax
  801a37:	29 c1                	sub    %eax,%ecx
  801a39:	89 75 08             	mov    %esi,0x8(%ebp)
  801a3c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a3f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a42:	89 cb                	mov    %ecx,%ebx
  801a44:	eb 4d                	jmp    801a93 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a46:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a4a:	74 1b                	je     801a67 <vprintfmt+0x213>
  801a4c:	0f be c0             	movsbl %al,%eax
  801a4f:	83 e8 20             	sub    $0x20,%eax
  801a52:	83 f8 5e             	cmp    $0x5e,%eax
  801a55:	76 10                	jbe    801a67 <vprintfmt+0x213>
					putch('?', putdat);
  801a57:	83 ec 08             	sub    $0x8,%esp
  801a5a:	ff 75 0c             	pushl  0xc(%ebp)
  801a5d:	6a 3f                	push   $0x3f
  801a5f:	ff 55 08             	call   *0x8(%ebp)
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	eb 0d                	jmp    801a74 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	ff 75 0c             	pushl  0xc(%ebp)
  801a6d:	52                   	push   %edx
  801a6e:	ff 55 08             	call   *0x8(%ebp)
  801a71:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a74:	83 eb 01             	sub    $0x1,%ebx
  801a77:	eb 1a                	jmp    801a93 <vprintfmt+0x23f>
  801a79:	89 75 08             	mov    %esi,0x8(%ebp)
  801a7c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a7f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a82:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a85:	eb 0c                	jmp    801a93 <vprintfmt+0x23f>
  801a87:	89 75 08             	mov    %esi,0x8(%ebp)
  801a8a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a8d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a90:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a93:	83 c7 01             	add    $0x1,%edi
  801a96:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801a9a:	0f be d0             	movsbl %al,%edx
  801a9d:	85 d2                	test   %edx,%edx
  801a9f:	74 23                	je     801ac4 <vprintfmt+0x270>
  801aa1:	85 f6                	test   %esi,%esi
  801aa3:	78 a1                	js     801a46 <vprintfmt+0x1f2>
  801aa5:	83 ee 01             	sub    $0x1,%esi
  801aa8:	79 9c                	jns    801a46 <vprintfmt+0x1f2>
  801aaa:	89 df                	mov    %ebx,%edi
  801aac:	8b 75 08             	mov    0x8(%ebp),%esi
  801aaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ab2:	eb 18                	jmp    801acc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801ab4:	83 ec 08             	sub    $0x8,%esp
  801ab7:	53                   	push   %ebx
  801ab8:	6a 20                	push   $0x20
  801aba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801abc:	83 ef 01             	sub    $0x1,%edi
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	eb 08                	jmp    801acc <vprintfmt+0x278>
  801ac4:	89 df                	mov    %ebx,%edi
  801ac6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801acc:	85 ff                	test   %edi,%edi
  801ace:	7f e4                	jg     801ab4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ad0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ad3:	e9 a2 fd ff ff       	jmp    80187a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801ad8:	83 fa 01             	cmp    $0x1,%edx
  801adb:	7e 16                	jle    801af3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801add:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae0:	8d 50 08             	lea    0x8(%eax),%edx
  801ae3:	89 55 14             	mov    %edx,0x14(%ebp)
  801ae6:	8b 50 04             	mov    0x4(%eax),%edx
  801ae9:	8b 00                	mov    (%eax),%eax
  801aeb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801af1:	eb 32                	jmp    801b25 <vprintfmt+0x2d1>
	else if (lflag)
  801af3:	85 d2                	test   %edx,%edx
  801af5:	74 18                	je     801b0f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801af7:	8b 45 14             	mov    0x14(%ebp),%eax
  801afa:	8d 50 04             	lea    0x4(%eax),%edx
  801afd:	89 55 14             	mov    %edx,0x14(%ebp)
  801b00:	8b 00                	mov    (%eax),%eax
  801b02:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b05:	89 c1                	mov    %eax,%ecx
  801b07:	c1 f9 1f             	sar    $0x1f,%ecx
  801b0a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801b0d:	eb 16                	jmp    801b25 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801b0f:	8b 45 14             	mov    0x14(%ebp),%eax
  801b12:	8d 50 04             	lea    0x4(%eax),%edx
  801b15:	89 55 14             	mov    %edx,0x14(%ebp)
  801b18:	8b 00                	mov    (%eax),%eax
  801b1a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b1d:	89 c1                	mov    %eax,%ecx
  801b1f:	c1 f9 1f             	sar    $0x1f,%ecx
  801b22:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b25:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b28:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801b2b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b30:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b34:	79 74                	jns    801baa <vprintfmt+0x356>
				putch('-', putdat);
  801b36:	83 ec 08             	sub    $0x8,%esp
  801b39:	53                   	push   %ebx
  801b3a:	6a 2d                	push   $0x2d
  801b3c:	ff d6                	call   *%esi
				num = -(long long) num;
  801b3e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b41:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b44:	f7 d8                	neg    %eax
  801b46:	83 d2 00             	adc    $0x0,%edx
  801b49:	f7 da                	neg    %edx
  801b4b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b4e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b53:	eb 55                	jmp    801baa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b55:	8d 45 14             	lea    0x14(%ebp),%eax
  801b58:	e8 83 fc ff ff       	call   8017e0 <getuint>
			base = 10;
  801b5d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801b62:	eb 46                	jmp    801baa <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801b64:	8d 45 14             	lea    0x14(%ebp),%eax
  801b67:	e8 74 fc ff ff       	call   8017e0 <getuint>
			base = 8;
  801b6c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801b71:	eb 37                	jmp    801baa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801b73:	83 ec 08             	sub    $0x8,%esp
  801b76:	53                   	push   %ebx
  801b77:	6a 30                	push   $0x30
  801b79:	ff d6                	call   *%esi
			putch('x', putdat);
  801b7b:	83 c4 08             	add    $0x8,%esp
  801b7e:	53                   	push   %ebx
  801b7f:	6a 78                	push   $0x78
  801b81:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b83:	8b 45 14             	mov    0x14(%ebp),%eax
  801b86:	8d 50 04             	lea    0x4(%eax),%edx
  801b89:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b8c:	8b 00                	mov    (%eax),%eax
  801b8e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801b93:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b96:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801b9b:	eb 0d                	jmp    801baa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b9d:	8d 45 14             	lea    0x14(%ebp),%eax
  801ba0:	e8 3b fc ff ff       	call   8017e0 <getuint>
			base = 16;
  801ba5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801baa:	83 ec 0c             	sub    $0xc,%esp
  801bad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801bb1:	57                   	push   %edi
  801bb2:	ff 75 e0             	pushl  -0x20(%ebp)
  801bb5:	51                   	push   %ecx
  801bb6:	52                   	push   %edx
  801bb7:	50                   	push   %eax
  801bb8:	89 da                	mov    %ebx,%edx
  801bba:	89 f0                	mov    %esi,%eax
  801bbc:	e8 70 fb ff ff       	call   801731 <printnum>
			break;
  801bc1:	83 c4 20             	add    $0x20,%esp
  801bc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bc7:	e9 ae fc ff ff       	jmp    80187a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801bcc:	83 ec 08             	sub    $0x8,%esp
  801bcf:	53                   	push   %ebx
  801bd0:	51                   	push   %ecx
  801bd1:	ff d6                	call   *%esi
			break;
  801bd3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bd6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801bd9:	e9 9c fc ff ff       	jmp    80187a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801bde:	83 ec 08             	sub    $0x8,%esp
  801be1:	53                   	push   %ebx
  801be2:	6a 25                	push   $0x25
  801be4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	eb 03                	jmp    801bee <vprintfmt+0x39a>
  801beb:	83 ef 01             	sub    $0x1,%edi
  801bee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801bf2:	75 f7                	jne    801beb <vprintfmt+0x397>
  801bf4:	e9 81 fc ff ff       	jmp    80187a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfc:	5b                   	pop    %ebx
  801bfd:	5e                   	pop    %esi
  801bfe:	5f                   	pop    %edi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	83 ec 18             	sub    $0x18,%esp
  801c07:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c0d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c10:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c14:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	74 26                	je     801c48 <vsnprintf+0x47>
  801c22:	85 d2                	test   %edx,%edx
  801c24:	7e 22                	jle    801c48 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c26:	ff 75 14             	pushl  0x14(%ebp)
  801c29:	ff 75 10             	pushl  0x10(%ebp)
  801c2c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c2f:	50                   	push   %eax
  801c30:	68 1a 18 80 00       	push   $0x80181a
  801c35:	e8 1a fc ff ff       	call   801854 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c3d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c43:	83 c4 10             	add    $0x10,%esp
  801c46:	eb 05                	jmp    801c4d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c4d:	c9                   	leave  
  801c4e:	c3                   	ret    

00801c4f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c55:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c58:	50                   	push   %eax
  801c59:	ff 75 10             	pushl  0x10(%ebp)
  801c5c:	ff 75 0c             	pushl  0xc(%ebp)
  801c5f:	ff 75 08             	pushl  0x8(%ebp)
  801c62:	e8 9a ff ff ff       	call   801c01 <vsnprintf>
	va_end(ap);

	return rc;
}
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    

00801c69 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c74:	eb 03                	jmp    801c79 <strlen+0x10>
		n++;
  801c76:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c79:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c7d:	75 f7                	jne    801c76 <strlen+0xd>
		n++;
	return n;
}
  801c7f:	5d                   	pop    %ebp
  801c80:	c3                   	ret    

00801c81 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c87:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8f:	eb 03                	jmp    801c94 <strnlen+0x13>
		n++;
  801c91:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c94:	39 c2                	cmp    %eax,%edx
  801c96:	74 08                	je     801ca0 <strnlen+0x1f>
  801c98:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801c9c:	75 f3                	jne    801c91 <strnlen+0x10>
  801c9e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	53                   	push   %ebx
  801ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801cac:	89 c2                	mov    %eax,%edx
  801cae:	83 c2 01             	add    $0x1,%edx
  801cb1:	83 c1 01             	add    $0x1,%ecx
  801cb4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801cb8:	88 5a ff             	mov    %bl,-0x1(%edx)
  801cbb:	84 db                	test   %bl,%bl
  801cbd:	75 ef                	jne    801cae <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801cbf:	5b                   	pop    %ebx
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	53                   	push   %ebx
  801cc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801cc9:	53                   	push   %ebx
  801cca:	e8 9a ff ff ff       	call   801c69 <strlen>
  801ccf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801cd2:	ff 75 0c             	pushl  0xc(%ebp)
  801cd5:	01 d8                	add    %ebx,%eax
  801cd7:	50                   	push   %eax
  801cd8:	e8 c5 ff ff ff       	call   801ca2 <strcpy>
	return dst;
}
  801cdd:	89 d8                	mov    %ebx,%eax
  801cdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    

00801ce4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ce4:	55                   	push   %ebp
  801ce5:	89 e5                	mov    %esp,%ebp
  801ce7:	56                   	push   %esi
  801ce8:	53                   	push   %ebx
  801ce9:	8b 75 08             	mov    0x8(%ebp),%esi
  801cec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cef:	89 f3                	mov    %esi,%ebx
  801cf1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cf4:	89 f2                	mov    %esi,%edx
  801cf6:	eb 0f                	jmp    801d07 <strncpy+0x23>
		*dst++ = *src;
  801cf8:	83 c2 01             	add    $0x1,%edx
  801cfb:	0f b6 01             	movzbl (%ecx),%eax
  801cfe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d01:	80 39 01             	cmpb   $0x1,(%ecx)
  801d04:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d07:	39 da                	cmp    %ebx,%edx
  801d09:	75 ed                	jne    801cf8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d0b:	89 f0                	mov    %esi,%eax
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	56                   	push   %esi
  801d15:	53                   	push   %ebx
  801d16:	8b 75 08             	mov    0x8(%ebp),%esi
  801d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d1c:	8b 55 10             	mov    0x10(%ebp),%edx
  801d1f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d21:	85 d2                	test   %edx,%edx
  801d23:	74 21                	je     801d46 <strlcpy+0x35>
  801d25:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801d29:	89 f2                	mov    %esi,%edx
  801d2b:	eb 09                	jmp    801d36 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d2d:	83 c2 01             	add    $0x1,%edx
  801d30:	83 c1 01             	add    $0x1,%ecx
  801d33:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801d36:	39 c2                	cmp    %eax,%edx
  801d38:	74 09                	je     801d43 <strlcpy+0x32>
  801d3a:	0f b6 19             	movzbl (%ecx),%ebx
  801d3d:	84 db                	test   %bl,%bl
  801d3f:	75 ec                	jne    801d2d <strlcpy+0x1c>
  801d41:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d43:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d46:	29 f0                	sub    %esi,%eax
}
  801d48:	5b                   	pop    %ebx
  801d49:	5e                   	pop    %esi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    

00801d4c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d52:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d55:	eb 06                	jmp    801d5d <strcmp+0x11>
		p++, q++;
  801d57:	83 c1 01             	add    $0x1,%ecx
  801d5a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d5d:	0f b6 01             	movzbl (%ecx),%eax
  801d60:	84 c0                	test   %al,%al
  801d62:	74 04                	je     801d68 <strcmp+0x1c>
  801d64:	3a 02                	cmp    (%edx),%al
  801d66:	74 ef                	je     801d57 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d68:	0f b6 c0             	movzbl %al,%eax
  801d6b:	0f b6 12             	movzbl (%edx),%edx
  801d6e:	29 d0                	sub    %edx,%eax
}
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    

00801d72 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	53                   	push   %ebx
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d7c:	89 c3                	mov    %eax,%ebx
  801d7e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801d81:	eb 06                	jmp    801d89 <strncmp+0x17>
		n--, p++, q++;
  801d83:	83 c0 01             	add    $0x1,%eax
  801d86:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d89:	39 d8                	cmp    %ebx,%eax
  801d8b:	74 15                	je     801da2 <strncmp+0x30>
  801d8d:	0f b6 08             	movzbl (%eax),%ecx
  801d90:	84 c9                	test   %cl,%cl
  801d92:	74 04                	je     801d98 <strncmp+0x26>
  801d94:	3a 0a                	cmp    (%edx),%cl
  801d96:	74 eb                	je     801d83 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d98:	0f b6 00             	movzbl (%eax),%eax
  801d9b:	0f b6 12             	movzbl (%edx),%edx
  801d9e:	29 d0                	sub    %edx,%eax
  801da0:	eb 05                	jmp    801da7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801da2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801da7:	5b                   	pop    %ebx
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    

00801daa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	8b 45 08             	mov    0x8(%ebp),%eax
  801db0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801db4:	eb 07                	jmp    801dbd <strchr+0x13>
		if (*s == c)
  801db6:	38 ca                	cmp    %cl,%dl
  801db8:	74 0f                	je     801dc9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801dba:	83 c0 01             	add    $0x1,%eax
  801dbd:	0f b6 10             	movzbl (%eax),%edx
  801dc0:	84 d2                	test   %dl,%dl
  801dc2:	75 f2                	jne    801db6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801dc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    

00801dcb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801dd5:	eb 03                	jmp    801dda <strfind+0xf>
  801dd7:	83 c0 01             	add    $0x1,%eax
  801dda:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801ddd:	38 ca                	cmp    %cl,%dl
  801ddf:	74 04                	je     801de5 <strfind+0x1a>
  801de1:	84 d2                	test   %dl,%dl
  801de3:	75 f2                	jne    801dd7 <strfind+0xc>
			break;
	return (char *) s;
}
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	57                   	push   %edi
  801deb:	56                   	push   %esi
  801dec:	53                   	push   %ebx
  801ded:	8b 7d 08             	mov    0x8(%ebp),%edi
  801df0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801df3:	85 c9                	test   %ecx,%ecx
  801df5:	74 36                	je     801e2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801df7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801dfd:	75 28                	jne    801e27 <memset+0x40>
  801dff:	f6 c1 03             	test   $0x3,%cl
  801e02:	75 23                	jne    801e27 <memset+0x40>
		c &= 0xFF;
  801e04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e08:	89 d3                	mov    %edx,%ebx
  801e0a:	c1 e3 08             	shl    $0x8,%ebx
  801e0d:	89 d6                	mov    %edx,%esi
  801e0f:	c1 e6 18             	shl    $0x18,%esi
  801e12:	89 d0                	mov    %edx,%eax
  801e14:	c1 e0 10             	shl    $0x10,%eax
  801e17:	09 f0                	or     %esi,%eax
  801e19:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801e1b:	89 d8                	mov    %ebx,%eax
  801e1d:	09 d0                	or     %edx,%eax
  801e1f:	c1 e9 02             	shr    $0x2,%ecx
  801e22:	fc                   	cld    
  801e23:	f3 ab                	rep stos %eax,%es:(%edi)
  801e25:	eb 06                	jmp    801e2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2a:	fc                   	cld    
  801e2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e2d:	89 f8                	mov    %edi,%eax
  801e2f:	5b                   	pop    %ebx
  801e30:	5e                   	pop    %esi
  801e31:	5f                   	pop    %edi
  801e32:	5d                   	pop    %ebp
  801e33:	c3                   	ret    

00801e34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	57                   	push   %edi
  801e38:	56                   	push   %esi
  801e39:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e42:	39 c6                	cmp    %eax,%esi
  801e44:	73 35                	jae    801e7b <memmove+0x47>
  801e46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e49:	39 d0                	cmp    %edx,%eax
  801e4b:	73 2e                	jae    801e7b <memmove+0x47>
		s += n;
		d += n;
  801e4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e50:	89 d6                	mov    %edx,%esi
  801e52:	09 fe                	or     %edi,%esi
  801e54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e5a:	75 13                	jne    801e6f <memmove+0x3b>
  801e5c:	f6 c1 03             	test   $0x3,%cl
  801e5f:	75 0e                	jne    801e6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801e61:	83 ef 04             	sub    $0x4,%edi
  801e64:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e67:	c1 e9 02             	shr    $0x2,%ecx
  801e6a:	fd                   	std    
  801e6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e6d:	eb 09                	jmp    801e78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e6f:	83 ef 01             	sub    $0x1,%edi
  801e72:	8d 72 ff             	lea    -0x1(%edx),%esi
  801e75:	fd                   	std    
  801e76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e78:	fc                   	cld    
  801e79:	eb 1d                	jmp    801e98 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e7b:	89 f2                	mov    %esi,%edx
  801e7d:	09 c2                	or     %eax,%edx
  801e7f:	f6 c2 03             	test   $0x3,%dl
  801e82:	75 0f                	jne    801e93 <memmove+0x5f>
  801e84:	f6 c1 03             	test   $0x3,%cl
  801e87:	75 0a                	jne    801e93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801e89:	c1 e9 02             	shr    $0x2,%ecx
  801e8c:	89 c7                	mov    %eax,%edi
  801e8e:	fc                   	cld    
  801e8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e91:	eb 05                	jmp    801e98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e93:	89 c7                	mov    %eax,%edi
  801e95:	fc                   	cld    
  801e96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    

00801e9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801e9f:	ff 75 10             	pushl  0x10(%ebp)
  801ea2:	ff 75 0c             	pushl  0xc(%ebp)
  801ea5:	ff 75 08             	pushl  0x8(%ebp)
  801ea8:	e8 87 ff ff ff       	call   801e34 <memmove>
}
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	56                   	push   %esi
  801eb3:	53                   	push   %ebx
  801eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eba:	89 c6                	mov    %eax,%esi
  801ebc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ebf:	eb 1a                	jmp    801edb <memcmp+0x2c>
		if (*s1 != *s2)
  801ec1:	0f b6 08             	movzbl (%eax),%ecx
  801ec4:	0f b6 1a             	movzbl (%edx),%ebx
  801ec7:	38 d9                	cmp    %bl,%cl
  801ec9:	74 0a                	je     801ed5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ecb:	0f b6 c1             	movzbl %cl,%eax
  801ece:	0f b6 db             	movzbl %bl,%ebx
  801ed1:	29 d8                	sub    %ebx,%eax
  801ed3:	eb 0f                	jmp    801ee4 <memcmp+0x35>
		s1++, s2++;
  801ed5:	83 c0 01             	add    $0x1,%eax
  801ed8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801edb:	39 f0                	cmp    %esi,%eax
  801edd:	75 e2                	jne    801ec1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801edf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee4:	5b                   	pop    %ebx
  801ee5:	5e                   	pop    %esi
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    

00801ee8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	53                   	push   %ebx
  801eec:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801eef:	89 c1                	mov    %eax,%ecx
  801ef1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801ef4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ef8:	eb 0a                	jmp    801f04 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801efa:	0f b6 10             	movzbl (%eax),%edx
  801efd:	39 da                	cmp    %ebx,%edx
  801eff:	74 07                	je     801f08 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f01:	83 c0 01             	add    $0x1,%eax
  801f04:	39 c8                	cmp    %ecx,%eax
  801f06:	72 f2                	jb     801efa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801f08:	5b                   	pop    %ebx
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    

00801f0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	57                   	push   %edi
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
  801f11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f17:	eb 03                	jmp    801f1c <strtol+0x11>
		s++;
  801f19:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f1c:	0f b6 01             	movzbl (%ecx),%eax
  801f1f:	3c 20                	cmp    $0x20,%al
  801f21:	74 f6                	je     801f19 <strtol+0xe>
  801f23:	3c 09                	cmp    $0x9,%al
  801f25:	74 f2                	je     801f19 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801f27:	3c 2b                	cmp    $0x2b,%al
  801f29:	75 0a                	jne    801f35 <strtol+0x2a>
		s++;
  801f2b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f2e:	bf 00 00 00 00       	mov    $0x0,%edi
  801f33:	eb 11                	jmp    801f46 <strtol+0x3b>
  801f35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801f3a:	3c 2d                	cmp    $0x2d,%al
  801f3c:	75 08                	jne    801f46 <strtol+0x3b>
		s++, neg = 1;
  801f3e:	83 c1 01             	add    $0x1,%ecx
  801f41:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f4c:	75 15                	jne    801f63 <strtol+0x58>
  801f4e:	80 39 30             	cmpb   $0x30,(%ecx)
  801f51:	75 10                	jne    801f63 <strtol+0x58>
  801f53:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f57:	75 7c                	jne    801fd5 <strtol+0xca>
		s += 2, base = 16;
  801f59:	83 c1 02             	add    $0x2,%ecx
  801f5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f61:	eb 16                	jmp    801f79 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801f63:	85 db                	test   %ebx,%ebx
  801f65:	75 12                	jne    801f79 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801f67:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f6c:	80 39 30             	cmpb   $0x30,(%ecx)
  801f6f:	75 08                	jne    801f79 <strtol+0x6e>
		s++, base = 8;
  801f71:	83 c1 01             	add    $0x1,%ecx
  801f74:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801f79:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f81:	0f b6 11             	movzbl (%ecx),%edx
  801f84:	8d 72 d0             	lea    -0x30(%edx),%esi
  801f87:	89 f3                	mov    %esi,%ebx
  801f89:	80 fb 09             	cmp    $0x9,%bl
  801f8c:	77 08                	ja     801f96 <strtol+0x8b>
			dig = *s - '0';
  801f8e:	0f be d2             	movsbl %dl,%edx
  801f91:	83 ea 30             	sub    $0x30,%edx
  801f94:	eb 22                	jmp    801fb8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801f96:	8d 72 9f             	lea    -0x61(%edx),%esi
  801f99:	89 f3                	mov    %esi,%ebx
  801f9b:	80 fb 19             	cmp    $0x19,%bl
  801f9e:	77 08                	ja     801fa8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801fa0:	0f be d2             	movsbl %dl,%edx
  801fa3:	83 ea 57             	sub    $0x57,%edx
  801fa6:	eb 10                	jmp    801fb8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801fa8:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fab:	89 f3                	mov    %esi,%ebx
  801fad:	80 fb 19             	cmp    $0x19,%bl
  801fb0:	77 16                	ja     801fc8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801fb2:	0f be d2             	movsbl %dl,%edx
  801fb5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801fb8:	3b 55 10             	cmp    0x10(%ebp),%edx
  801fbb:	7d 0b                	jge    801fc8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801fbd:	83 c1 01             	add    $0x1,%ecx
  801fc0:	0f af 45 10          	imul   0x10(%ebp),%eax
  801fc4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801fc6:	eb b9                	jmp    801f81 <strtol+0x76>

	if (endptr)
  801fc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801fcc:	74 0d                	je     801fdb <strtol+0xd0>
		*endptr = (char *) s;
  801fce:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd1:	89 0e                	mov    %ecx,(%esi)
  801fd3:	eb 06                	jmp    801fdb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801fd5:	85 db                	test   %ebx,%ebx
  801fd7:	74 98                	je     801f71 <strtol+0x66>
  801fd9:	eb 9e                	jmp    801f79 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801fdb:	89 c2                	mov    %eax,%edx
  801fdd:	f7 da                	neg    %edx
  801fdf:	85 ff                	test   %edi,%edi
  801fe1:	0f 45 c2             	cmovne %edx,%eax
}
  801fe4:	5b                   	pop    %ebx
  801fe5:	5e                   	pop    %esi
  801fe6:	5f                   	pop    %edi
  801fe7:	5d                   	pop    %ebp
  801fe8:	c3                   	ret    

00801fe9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fef:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ff6:	75 2a                	jne    802022 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801ff8:	83 ec 04             	sub    $0x4,%esp
  801ffb:	6a 07                	push   $0x7
  801ffd:	68 00 f0 bf ee       	push   $0xeebff000
  802002:	6a 00                	push   $0x0
  802004:	e8 6f e1 ff ff       	call   800178 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	85 c0                	test   %eax,%eax
  80200e:	79 12                	jns    802022 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  802010:	50                   	push   %eax
  802011:	68 83 25 80 00       	push   $0x802583
  802016:	6a 23                	push   $0x23
  802018:	68 20 2a 80 00       	push   $0x802a20
  80201d:	e8 22 f6 ff ff       	call   801644 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802022:	8b 45 08             	mov    0x8(%ebp),%eax
  802025:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  80202a:	83 ec 08             	sub    $0x8,%esp
  80202d:	68 54 20 80 00       	push   $0x802054
  802032:	6a 00                	push   $0x0
  802034:	e8 8a e2 ff ff       	call   8002c3 <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802039:	83 c4 10             	add    $0x10,%esp
  80203c:	85 c0                	test   %eax,%eax
  80203e:	79 12                	jns    802052 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  802040:	50                   	push   %eax
  802041:	68 83 25 80 00       	push   $0x802583
  802046:	6a 2c                	push   $0x2c
  802048:	68 20 2a 80 00       	push   $0x802a20
  80204d:	e8 f2 f5 ff ff       	call   801644 <_panic>
	}
}
  802052:	c9                   	leave  
  802053:	c3                   	ret    

00802054 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802054:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802055:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80205a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80205c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  80205f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  802063:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  802068:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  80206c:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  80206e:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  802071:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  802072:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  802075:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  802076:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802077:	c3                   	ret    

00802078 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	56                   	push   %esi
  80207c:	53                   	push   %ebx
  80207d:	8b 75 08             	mov    0x8(%ebp),%esi
  802080:	8b 45 0c             	mov    0xc(%ebp),%eax
  802083:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  802086:	85 c0                	test   %eax,%eax
  802088:	75 12                	jne    80209c <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  80208a:	83 ec 0c             	sub    $0xc,%esp
  80208d:	68 00 00 c0 ee       	push   $0xeec00000
  802092:	e8 91 e2 ff ff       	call   800328 <sys_ipc_recv>
  802097:	83 c4 10             	add    $0x10,%esp
  80209a:	eb 0c                	jmp    8020a8 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  80209c:	83 ec 0c             	sub    $0xc,%esp
  80209f:	50                   	push   %eax
  8020a0:	e8 83 e2 ff ff       	call   800328 <sys_ipc_recv>
  8020a5:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020a8:	85 f6                	test   %esi,%esi
  8020aa:	0f 95 c1             	setne  %cl
  8020ad:	85 db                	test   %ebx,%ebx
  8020af:	0f 95 c2             	setne  %dl
  8020b2:	84 d1                	test   %dl,%cl
  8020b4:	74 09                	je     8020bf <ipc_recv+0x47>
  8020b6:	89 c2                	mov    %eax,%edx
  8020b8:	c1 ea 1f             	shr    $0x1f,%edx
  8020bb:	84 d2                	test   %dl,%dl
  8020bd:	75 2d                	jne    8020ec <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020bf:	85 f6                	test   %esi,%esi
  8020c1:	74 0d                	je     8020d0 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020c3:	a1 04 40 80 00       	mov    0x804004,%eax
  8020c8:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020ce:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020d0:	85 db                	test   %ebx,%ebx
  8020d2:	74 0d                	je     8020e1 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020d4:	a1 04 40 80 00       	mov    0x804004,%eax
  8020d9:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8020df:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e6:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  8020ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5d                   	pop    %ebp
  8020f2:	c3                   	ret    

008020f3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020f3:	55                   	push   %ebp
  8020f4:	89 e5                	mov    %esp,%ebp
  8020f6:	57                   	push   %edi
  8020f7:	56                   	push   %esi
  8020f8:	53                   	push   %ebx
  8020f9:	83 ec 0c             	sub    $0xc,%esp
  8020fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  802102:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802105:	85 db                	test   %ebx,%ebx
  802107:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80210c:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80210f:	ff 75 14             	pushl  0x14(%ebp)
  802112:	53                   	push   %ebx
  802113:	56                   	push   %esi
  802114:	57                   	push   %edi
  802115:	e8 eb e1 ff ff       	call   800305 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  80211a:	89 c2                	mov    %eax,%edx
  80211c:	c1 ea 1f             	shr    $0x1f,%edx
  80211f:	83 c4 10             	add    $0x10,%esp
  802122:	84 d2                	test   %dl,%dl
  802124:	74 17                	je     80213d <ipc_send+0x4a>
  802126:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802129:	74 12                	je     80213d <ipc_send+0x4a>
			panic("failed ipc %e", r);
  80212b:	50                   	push   %eax
  80212c:	68 2e 2a 80 00       	push   $0x802a2e
  802131:	6a 47                	push   $0x47
  802133:	68 3c 2a 80 00       	push   $0x802a3c
  802138:	e8 07 f5 ff ff       	call   801644 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  80213d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802140:	75 07                	jne    802149 <ipc_send+0x56>
			sys_yield();
  802142:	e8 12 e0 ff ff       	call   800159 <sys_yield>
  802147:	eb c6                	jmp    80210f <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802149:	85 c0                	test   %eax,%eax
  80214b:	75 c2                	jne    80210f <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  80214d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    

00802155 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80215b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802160:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802166:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80216c:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  802172:	39 ca                	cmp    %ecx,%edx
  802174:	75 13                	jne    802189 <ipc_find_env+0x34>
			return envs[i].env_id;
  802176:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  80217c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802181:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  802187:	eb 0f                	jmp    802198 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802189:	83 c0 01             	add    $0x1,%eax
  80218c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802191:	75 cd                	jne    802160 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802193:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802198:	5d                   	pop    %ebp
  802199:	c3                   	ret    

0080219a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80219a:	55                   	push   %ebp
  80219b:	89 e5                	mov    %esp,%ebp
  80219d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021a0:	89 d0                	mov    %edx,%eax
  8021a2:	c1 e8 16             	shr    $0x16,%eax
  8021a5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021ac:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b1:	f6 c1 01             	test   $0x1,%cl
  8021b4:	74 1d                	je     8021d3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021b6:	c1 ea 0c             	shr    $0xc,%edx
  8021b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021c0:	f6 c2 01             	test   $0x1,%dl
  8021c3:	74 0e                	je     8021d3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021c5:	c1 ea 0c             	shr    $0xc,%edx
  8021c8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021cf:	ef 
  8021d0:	0f b7 c0             	movzwl %ax,%eax
}
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    
  8021d5:	66 90                	xchg   %ax,%ax
  8021d7:	66 90                	xchg   %ax,%ax
  8021d9:	66 90                	xchg   %ax,%ax
  8021db:	66 90                	xchg   %ax,%ax
  8021dd:	66 90                	xchg   %ax,%ax
  8021df:	90                   	nop

008021e0 <__udivdi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	57                   	push   %edi
  8021e2:	56                   	push   %esi
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 1c             	sub    $0x1c,%esp
  8021e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8021f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021f7:	85 f6                	test   %esi,%esi
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 ca                	mov    %ecx,%edx
  8021ff:	89 f8                	mov    %edi,%eax
  802201:	75 3d                	jne    802240 <__udivdi3+0x60>
  802203:	39 cf                	cmp    %ecx,%edi
  802205:	0f 87 c5 00 00 00    	ja     8022d0 <__udivdi3+0xf0>
  80220b:	85 ff                	test   %edi,%edi
  80220d:	89 fd                	mov    %edi,%ebp
  80220f:	75 0b                	jne    80221c <__udivdi3+0x3c>
  802211:	b8 01 00 00 00       	mov    $0x1,%eax
  802216:	31 d2                	xor    %edx,%edx
  802218:	f7 f7                	div    %edi
  80221a:	89 c5                	mov    %eax,%ebp
  80221c:	89 c8                	mov    %ecx,%eax
  80221e:	31 d2                	xor    %edx,%edx
  802220:	f7 f5                	div    %ebp
  802222:	89 c1                	mov    %eax,%ecx
  802224:	89 d8                	mov    %ebx,%eax
  802226:	89 cf                	mov    %ecx,%edi
  802228:	f7 f5                	div    %ebp
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	89 d8                	mov    %ebx,%eax
  80222e:	89 fa                	mov    %edi,%edx
  802230:	83 c4 1c             	add    $0x1c,%esp
  802233:	5b                   	pop    %ebx
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	90                   	nop
  802239:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802240:	39 ce                	cmp    %ecx,%esi
  802242:	77 74                	ja     8022b8 <__udivdi3+0xd8>
  802244:	0f bd fe             	bsr    %esi,%edi
  802247:	83 f7 1f             	xor    $0x1f,%edi
  80224a:	0f 84 98 00 00 00    	je     8022e8 <__udivdi3+0x108>
  802250:	bb 20 00 00 00       	mov    $0x20,%ebx
  802255:	89 f9                	mov    %edi,%ecx
  802257:	89 c5                	mov    %eax,%ebp
  802259:	29 fb                	sub    %edi,%ebx
  80225b:	d3 e6                	shl    %cl,%esi
  80225d:	89 d9                	mov    %ebx,%ecx
  80225f:	d3 ed                	shr    %cl,%ebp
  802261:	89 f9                	mov    %edi,%ecx
  802263:	d3 e0                	shl    %cl,%eax
  802265:	09 ee                	or     %ebp,%esi
  802267:	89 d9                	mov    %ebx,%ecx
  802269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80226d:	89 d5                	mov    %edx,%ebp
  80226f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802273:	d3 ed                	shr    %cl,%ebp
  802275:	89 f9                	mov    %edi,%ecx
  802277:	d3 e2                	shl    %cl,%edx
  802279:	89 d9                	mov    %ebx,%ecx
  80227b:	d3 e8                	shr    %cl,%eax
  80227d:	09 c2                	or     %eax,%edx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	89 ea                	mov    %ebp,%edx
  802283:	f7 f6                	div    %esi
  802285:	89 d5                	mov    %edx,%ebp
  802287:	89 c3                	mov    %eax,%ebx
  802289:	f7 64 24 0c          	mull   0xc(%esp)
  80228d:	39 d5                	cmp    %edx,%ebp
  80228f:	72 10                	jb     8022a1 <__udivdi3+0xc1>
  802291:	8b 74 24 08          	mov    0x8(%esp),%esi
  802295:	89 f9                	mov    %edi,%ecx
  802297:	d3 e6                	shl    %cl,%esi
  802299:	39 c6                	cmp    %eax,%esi
  80229b:	73 07                	jae    8022a4 <__udivdi3+0xc4>
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	75 03                	jne    8022a4 <__udivdi3+0xc4>
  8022a1:	83 eb 01             	sub    $0x1,%ebx
  8022a4:	31 ff                	xor    %edi,%edi
  8022a6:	89 d8                	mov    %ebx,%eax
  8022a8:	89 fa                	mov    %edi,%edx
  8022aa:	83 c4 1c             	add    $0x1c,%esp
  8022ad:	5b                   	pop    %ebx
  8022ae:	5e                   	pop    %esi
  8022af:	5f                   	pop    %edi
  8022b0:	5d                   	pop    %ebp
  8022b1:	c3                   	ret    
  8022b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 db                	xor    %ebx,%ebx
  8022bc:	89 d8                	mov    %ebx,%eax
  8022be:	89 fa                	mov    %edi,%edx
  8022c0:	83 c4 1c             	add    $0x1c,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	90                   	nop
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d8                	mov    %ebx,%eax
  8022d2:	f7 f7                	div    %edi
  8022d4:	31 ff                	xor    %edi,%edi
  8022d6:	89 c3                	mov    %eax,%ebx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 fa                	mov    %edi,%edx
  8022dc:	83 c4 1c             	add    $0x1c,%esp
  8022df:	5b                   	pop    %ebx
  8022e0:	5e                   	pop    %esi
  8022e1:	5f                   	pop    %edi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 ce                	cmp    %ecx,%esi
  8022ea:	72 0c                	jb     8022f8 <__udivdi3+0x118>
  8022ec:	31 db                	xor    %ebx,%ebx
  8022ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8022f2:	0f 87 34 ff ff ff    	ja     80222c <__udivdi3+0x4c>
  8022f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8022fd:	e9 2a ff ff ff       	jmp    80222c <__udivdi3+0x4c>
  802302:	66 90                	xchg   %ax,%ax
  802304:	66 90                	xchg   %ax,%ax
  802306:	66 90                	xchg   %ax,%ax
  802308:	66 90                	xchg   %ax,%ax
  80230a:	66 90                	xchg   %ax,%ax
  80230c:	66 90                	xchg   %ax,%ax
  80230e:	66 90                	xchg   %ax,%ax

00802310 <__umoddi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	53                   	push   %ebx
  802314:	83 ec 1c             	sub    $0x1c,%esp
  802317:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80231b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80231f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802323:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802327:	85 d2                	test   %edx,%edx
  802329:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80232d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802331:	89 f3                	mov    %esi,%ebx
  802333:	89 3c 24             	mov    %edi,(%esp)
  802336:	89 74 24 04          	mov    %esi,0x4(%esp)
  80233a:	75 1c                	jne    802358 <__umoddi3+0x48>
  80233c:	39 f7                	cmp    %esi,%edi
  80233e:	76 50                	jbe    802390 <__umoddi3+0x80>
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	f7 f7                	div    %edi
  802346:	89 d0                	mov    %edx,%eax
  802348:	31 d2                	xor    %edx,%edx
  80234a:	83 c4 1c             	add    $0x1c,%esp
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    
  802352:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	89 d0                	mov    %edx,%eax
  80235c:	77 52                	ja     8023b0 <__umoddi3+0xa0>
  80235e:	0f bd ea             	bsr    %edx,%ebp
  802361:	83 f5 1f             	xor    $0x1f,%ebp
  802364:	75 5a                	jne    8023c0 <__umoddi3+0xb0>
  802366:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80236a:	0f 82 e0 00 00 00    	jb     802450 <__umoddi3+0x140>
  802370:	39 0c 24             	cmp    %ecx,(%esp)
  802373:	0f 86 d7 00 00 00    	jbe    802450 <__umoddi3+0x140>
  802379:	8b 44 24 08          	mov    0x8(%esp),%eax
  80237d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802381:	83 c4 1c             	add    $0x1c,%esp
  802384:	5b                   	pop    %ebx
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	85 ff                	test   %edi,%edi
  802392:	89 fd                	mov    %edi,%ebp
  802394:	75 0b                	jne    8023a1 <__umoddi3+0x91>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f7                	div    %edi
  80239f:	89 c5                	mov    %eax,%ebp
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	31 d2                	xor    %edx,%edx
  8023a5:	f7 f5                	div    %ebp
  8023a7:	89 c8                	mov    %ecx,%eax
  8023a9:	f7 f5                	div    %ebp
  8023ab:	89 d0                	mov    %edx,%eax
  8023ad:	eb 99                	jmp    802348 <__umoddi3+0x38>
  8023af:	90                   	nop
  8023b0:	89 c8                	mov    %ecx,%eax
  8023b2:	89 f2                	mov    %esi,%edx
  8023b4:	83 c4 1c             	add    $0x1c,%esp
  8023b7:	5b                   	pop    %ebx
  8023b8:	5e                   	pop    %esi
  8023b9:	5f                   	pop    %edi
  8023ba:	5d                   	pop    %ebp
  8023bb:	c3                   	ret    
  8023bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	8b 34 24             	mov    (%esp),%esi
  8023c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c8:	89 e9                	mov    %ebp,%ecx
  8023ca:	29 ef                	sub    %ebp,%edi
  8023cc:	d3 e0                	shl    %cl,%eax
  8023ce:	89 f9                	mov    %edi,%ecx
  8023d0:	89 f2                	mov    %esi,%edx
  8023d2:	d3 ea                	shr    %cl,%edx
  8023d4:	89 e9                	mov    %ebp,%ecx
  8023d6:	09 c2                	or     %eax,%edx
  8023d8:	89 d8                	mov    %ebx,%eax
  8023da:	89 14 24             	mov    %edx,(%esp)
  8023dd:	89 f2                	mov    %esi,%edx
  8023df:	d3 e2                	shl    %cl,%edx
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023eb:	d3 e8                	shr    %cl,%eax
  8023ed:	89 e9                	mov    %ebp,%ecx
  8023ef:	89 c6                	mov    %eax,%esi
  8023f1:	d3 e3                	shl    %cl,%ebx
  8023f3:	89 f9                	mov    %edi,%ecx
  8023f5:	89 d0                	mov    %edx,%eax
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 e9                	mov    %ebp,%ecx
  8023fb:	09 d8                	or     %ebx,%eax
  8023fd:	89 d3                	mov    %edx,%ebx
  8023ff:	89 f2                	mov    %esi,%edx
  802401:	f7 34 24             	divl   (%esp)
  802404:	89 d6                	mov    %edx,%esi
  802406:	d3 e3                	shl    %cl,%ebx
  802408:	f7 64 24 04          	mull   0x4(%esp)
  80240c:	39 d6                	cmp    %edx,%esi
  80240e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802412:	89 d1                	mov    %edx,%ecx
  802414:	89 c3                	mov    %eax,%ebx
  802416:	72 08                	jb     802420 <__umoddi3+0x110>
  802418:	75 11                	jne    80242b <__umoddi3+0x11b>
  80241a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80241e:	73 0b                	jae    80242b <__umoddi3+0x11b>
  802420:	2b 44 24 04          	sub    0x4(%esp),%eax
  802424:	1b 14 24             	sbb    (%esp),%edx
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 c3                	mov    %eax,%ebx
  80242b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80242f:	29 da                	sub    %ebx,%edx
  802431:	19 ce                	sbb    %ecx,%esi
  802433:	89 f9                	mov    %edi,%ecx
  802435:	89 f0                	mov    %esi,%eax
  802437:	d3 e0                	shl    %cl,%eax
  802439:	89 e9                	mov    %ebp,%ecx
  80243b:	d3 ea                	shr    %cl,%edx
  80243d:	89 e9                	mov    %ebp,%ecx
  80243f:	d3 ee                	shr    %cl,%esi
  802441:	09 d0                	or     %edx,%eax
  802443:	89 f2                	mov    %esi,%edx
  802445:	83 c4 1c             	add    $0x1c,%esp
  802448:	5b                   	pop    %ebx
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	29 f9                	sub    %edi,%ecx
  802452:	19 d6                	sbb    %edx,%esi
  802454:	89 74 24 04          	mov    %esi,0x4(%esp)
  802458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80245c:	e9 18 ff ff ff       	jmp    802379 <__umoddi3+0x69>
