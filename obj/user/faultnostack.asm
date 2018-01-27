
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 c4 03 80 00       	push   $0x8003c4
  80003e:	6a 00                	push   $0x0
  800040:	e8 99 02 00 00       	call   8002de <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 f1 00 00 00       	call   800155 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 04 40 80 00       	mov    %eax,0x804004
			thisenv = &envs[i];
		}
	}*/

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 db                	test   %ebx,%ebx
  80007b:	7e 07                	jle    800084 <libmain+0x30>
		binaryname = argv[0];
  80007d:	8b 06                	mov    (%esi),%eax
  80007f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	56                   	push   %esi
  800088:	53                   	push   %ebx
  800089:	e8 a5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008e:	e8 2a 00 00 00       	call   8000bd <exit>
}
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800099:	5b                   	pop    %ebx
  80009a:	5e                   	pop    %esi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    

0080009d <thread_main>:
/*Lab 7: Multithreading thread main routine*/

void 
thread_main(/*uintptr_t eip*/)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 08             	sub    $0x8,%esp
	//thisenv = &envs[ENVX(sys_getenvid())];

	void (*func)(void) = (void (*)(void))eip;
  8000a3:	a1 08 40 80 00       	mov    0x804008,%eax
	func();
  8000a8:	ff d0                	call   *%eax
	sys_thread_free(sys_getenvid());
  8000aa:	e8 a6 00 00 00       	call   800155 <sys_getenvid>
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	50                   	push   %eax
  8000b3:	e8 ec 02 00 00       	call   8003a4 <sys_thread_free>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c3:	e8 df 07 00 00       	call   8008a7 <close_all>
	sys_env_destroy(0);
  8000c8:	83 ec 0c             	sub    $0xc,%esp
  8000cb:	6a 00                	push   $0x0
  8000cd:	e8 42 00 00 00       	call   800114 <sys_env_destroy>
}
  8000d2:	83 c4 10             	add    $0x10,%esp
  8000d5:	c9                   	leave  
  8000d6:	c3                   	ret    

008000d7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	89 c3                	mov    %eax,%ebx
  8000ea:	89 c7                	mov    %eax,%edi
  8000ec:	89 c6                	mov    %eax,%esi
  8000ee:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800100:	b8 01 00 00 00       	mov    $0x1,%eax
  800105:	89 d1                	mov    %edx,%ecx
  800107:	89 d3                	mov    %edx,%ebx
  800109:	89 d7                	mov    %edx,%edi
  80010b:	89 d6                	mov    %edx,%esi
  80010d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
  80011a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800122:	b8 03 00 00 00       	mov    $0x3,%eax
  800127:	8b 55 08             	mov    0x8(%ebp),%edx
  80012a:	89 cb                	mov    %ecx,%ebx
  80012c:	89 cf                	mov    %ecx,%edi
  80012e:	89 ce                	mov    %ecx,%esi
  800130:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800132:	85 c0                	test   %eax,%eax
  800134:	7e 17                	jle    80014d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	6a 03                	push   $0x3
  80013c:	68 ea 21 80 00       	push   $0x8021ea
  800141:	6a 23                	push   $0x23
  800143:	68 07 22 80 00       	push   $0x802207
  800148:	e8 82 12 00 00       	call   8013cf <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	b8 02 00 00 00       	mov    $0x2,%eax
  800165:	89 d1                	mov    %edx,%ecx
  800167:	89 d3                	mov    %edx,%ebx
  800169:	89 d7                	mov    %edx,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016f:	5b                   	pop    %ebx
  800170:	5e                   	pop    %esi
  800171:	5f                   	pop    %edi
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <sys_yield>:

void
sys_yield(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017a:	ba 00 00 00 00       	mov    $0x0,%edx
  80017f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800184:	89 d1                	mov    %edx,%ecx
  800186:	89 d3                	mov    %edx,%ebx
  800188:	89 d7                	mov    %edx,%edi
  80018a:	89 d6                	mov    %edx,%esi
  80018c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018e:	5b                   	pop    %ebx
  80018f:	5e                   	pop    %esi
  800190:	5f                   	pop    %edi
  800191:	5d                   	pop    %ebp
  800192:	c3                   	ret    

00800193 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	57                   	push   %edi
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
  800199:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019c:	be 00 00 00 00       	mov    $0x0,%esi
  8001a1:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	89 f7                	mov    %esi,%edi
  8001b1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b3:	85 c0                	test   %eax,%eax
  8001b5:	7e 17                	jle    8001ce <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	50                   	push   %eax
  8001bb:	6a 04                	push   $0x4
  8001bd:	68 ea 21 80 00       	push   $0x8021ea
  8001c2:	6a 23                	push   $0x23
  8001c4:	68 07 22 80 00       	push   $0x802207
  8001c9:	e8 01 12 00 00       	call   8013cf <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	57                   	push   %edi
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001df:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ed:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f5:	85 c0                	test   %eax,%eax
  8001f7:	7e 17                	jle    800210 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f9:	83 ec 0c             	sub    $0xc,%esp
  8001fc:	50                   	push   %eax
  8001fd:	6a 05                	push   $0x5
  8001ff:	68 ea 21 80 00       	push   $0x8021ea
  800204:	6a 23                	push   $0x23
  800206:	68 07 22 80 00       	push   $0x802207
  80020b:	e8 bf 11 00 00       	call   8013cf <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    

00800218 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	b8 06 00 00 00       	mov    $0x6,%eax
  80022b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022e:	8b 55 08             	mov    0x8(%ebp),%edx
  800231:	89 df                	mov    %ebx,%edi
  800233:	89 de                	mov    %ebx,%esi
  800235:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800237:	85 c0                	test   %eax,%eax
  800239:	7e 17                	jle    800252 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	50                   	push   %eax
  80023f:	6a 06                	push   $0x6
  800241:	68 ea 21 80 00       	push   $0x8021ea
  800246:	6a 23                	push   $0x23
  800248:	68 07 22 80 00       	push   $0x802207
  80024d:	e8 7d 11 00 00       	call   8013cf <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    

0080025a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	57                   	push   %edi
  80025e:	56                   	push   %esi
  80025f:	53                   	push   %ebx
  800260:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800263:	bb 00 00 00 00       	mov    $0x0,%ebx
  800268:	b8 08 00 00 00       	mov    $0x8,%eax
  80026d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800270:	8b 55 08             	mov    0x8(%ebp),%edx
  800273:	89 df                	mov    %ebx,%edi
  800275:	89 de                	mov    %ebx,%esi
  800277:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800279:	85 c0                	test   %eax,%eax
  80027b:	7e 17                	jle    800294 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	50                   	push   %eax
  800281:	6a 08                	push   $0x8
  800283:	68 ea 21 80 00       	push   $0x8021ea
  800288:	6a 23                	push   $0x23
  80028a:	68 07 22 80 00       	push   $0x802207
  80028f:	e8 3b 11 00 00       	call   8013cf <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    

0080029c <sys_env_set_trapframe>:

int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002aa:	b8 09 00 00 00       	mov    $0x9,%eax
  8002af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b5:	89 df                	mov    %ebx,%edi
  8002b7:	89 de                	mov    %ebx,%esi
  8002b9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bb:	85 c0                	test   %eax,%eax
  8002bd:	7e 17                	jle    8002d6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	50                   	push   %eax
  8002c3:	6a 09                	push   $0x9
  8002c5:	68 ea 21 80 00       	push   $0x8021ea
  8002ca:	6a 23                	push   $0x23
  8002cc:	68 07 22 80 00       	push   $0x802207
  8002d1:	e8 f9 10 00 00       	call   8013cf <_panic>
int

sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ec:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	89 df                	mov    %ebx,%edi
  8002f9:	89 de                	mov    %ebx,%esi
  8002fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	7e 17                	jle    800318 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800301:	83 ec 0c             	sub    $0xc,%esp
  800304:	50                   	push   %eax
  800305:	6a 0a                	push   $0xa
  800307:	68 ea 21 80 00       	push   $0x8021ea
  80030c:	6a 23                	push   $0x23
  80030e:	68 07 22 80 00       	push   $0x802207
  800313:	e8 b7 10 00 00       	call   8013cf <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800318:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800326:	be 00 00 00 00       	mov    $0x0,%esi
  80032b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800339:	8b 7d 14             	mov    0x14(%ebp),%edi
  80033c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80033e:	5b                   	pop    %ebx
  80033f:	5e                   	pop    %esi
  800340:	5f                   	pop    %edi
  800341:	5d                   	pop    %ebp
  800342:	c3                   	ret    

00800343 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	57                   	push   %edi
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
  800349:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800351:	b8 0d 00 00 00       	mov    $0xd,%eax
  800356:	8b 55 08             	mov    0x8(%ebp),%edx
  800359:	89 cb                	mov    %ecx,%ebx
  80035b:	89 cf                	mov    %ecx,%edi
  80035d:	89 ce                	mov    %ecx,%esi
  80035f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800361:	85 c0                	test   %eax,%eax
  800363:	7e 17                	jle    80037c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	50                   	push   %eax
  800369:	6a 0d                	push   $0xd
  80036b:	68 ea 21 80 00       	push   $0x8021ea
  800370:	6a 23                	push   $0x23
  800372:	68 07 22 80 00       	push   $0x802207
  800377:	e8 53 10 00 00       	call   8013cf <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80037c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sys_thread_create>:

/*Lab 7: Multithreading*/

envid_t
sys_thread_create(uintptr_t func)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800394:	8b 55 08             	mov    0x8(%ebp),%edx
  800397:	89 cb                	mov    %ecx,%ebx
  800399:	89 cf                	mov    %ecx,%edi
  80039b:	89 ce                	mov    %ecx,%esi
  80039d:	cd 30                	int    $0x30

envid_t
sys_thread_create(uintptr_t func)
{
	return syscall(SYS_thread_create, 0, func, 0, 0, 0, 0);
}
  80039f:	5b                   	pop    %ebx
  8003a0:	5e                   	pop    %esi
  8003a1:	5f                   	pop    %edi
  8003a2:	5d                   	pop    %ebp
  8003a3:	c3                   	ret    

008003a4 <sys_thread_free>:

void 	
sys_thread_free(envid_t envid)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003af:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b7:	89 cb                	mov    %ecx,%ebx
  8003b9:	89 cf                	mov    %ecx,%edi
  8003bb:	89 ce                	mov    %ecx,%esi
  8003bd:	cd 30                	int    $0x30

void 	
sys_thread_free(envid_t envid)
{
 	syscall(SYS_thread_free, 0, envid, 0, 0, 0, 0);
}
  8003bf:	5b                   	pop    %ebx
  8003c0:	5e                   	pop    %esi
  8003c1:	5f                   	pop    %edi
  8003c2:	5d                   	pop    %ebp
  8003c3:	c3                   	ret    

008003c4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003c4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003c5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8003ca:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003cc:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8003cf:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8003d3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8003d8:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8003dc:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8003de:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  8003e1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  8003e2:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  8003e5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  8003e6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8003e7:	c3                   	ret    

008003e8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	53                   	push   %ebx
  8003ec:	83 ec 04             	sub    $0x4,%esp
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8003f2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  8003f4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  8003f8:	74 11                	je     80040b <pgfault+0x23>
  8003fa:	89 d8                	mov    %ebx,%eax
  8003fc:	c1 e8 0c             	shr    $0xc,%eax
  8003ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800406:	f6 c4 08             	test   $0x8,%ah
  800409:	75 14                	jne    80041f <pgfault+0x37>
		panic("faulting access");
  80040b:	83 ec 04             	sub    $0x4,%esp
  80040e:	68 15 22 80 00       	push   $0x802215
  800413:	6a 1e                	push   $0x1e
  800415:	68 25 22 80 00       	push   $0x802225
  80041a:	e8 b0 0f 00 00       	call   8013cf <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  80041f:	83 ec 04             	sub    $0x4,%esp
  800422:	6a 07                	push   $0x7
  800424:	68 00 f0 7f 00       	push   $0x7ff000
  800429:	6a 00                	push   $0x0
  80042b:	e8 63 fd ff ff       	call   800193 <sys_page_alloc>
	if (r < 0) {
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	85 c0                	test   %eax,%eax
  800435:	79 12                	jns    800449 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800437:	50                   	push   %eax
  800438:	68 30 22 80 00       	push   $0x802230
  80043d:	6a 2c                	push   $0x2c
  80043f:	68 25 22 80 00       	push   $0x802225
  800444:	e8 86 0f 00 00       	call   8013cf <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800449:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80044f:	83 ec 04             	sub    $0x4,%esp
  800452:	68 00 10 00 00       	push   $0x1000
  800457:	53                   	push   %ebx
  800458:	68 00 f0 7f 00       	push   $0x7ff000
  80045d:	e8 c5 17 00 00       	call   801c27 <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800462:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800469:	53                   	push   %ebx
  80046a:	6a 00                	push   $0x0
  80046c:	68 00 f0 7f 00       	push   $0x7ff000
  800471:	6a 00                	push   $0x0
  800473:	e8 5e fd ff ff       	call   8001d6 <sys_page_map>
	if (r < 0) {
  800478:	83 c4 20             	add    $0x20,%esp
  80047b:	85 c0                	test   %eax,%eax
  80047d:	79 12                	jns    800491 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80047f:	50                   	push   %eax
  800480:	68 30 22 80 00       	push   $0x802230
  800485:	6a 33                	push   $0x33
  800487:	68 25 22 80 00       	push   $0x802225
  80048c:	e8 3e 0f 00 00       	call   8013cf <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	68 00 f0 7f 00       	push   $0x7ff000
  800499:	6a 00                	push   $0x0
  80049b:	e8 78 fd ff ff       	call   800218 <sys_page_unmap>
	if (r < 0) {
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	79 12                	jns    8004b9 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8004a7:	50                   	push   %eax
  8004a8:	68 30 22 80 00       	push   $0x802230
  8004ad:	6a 37                	push   $0x37
  8004af:	68 25 22 80 00       	push   $0x802225
  8004b4:	e8 16 0f 00 00       	call   8013cf <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004bc:	c9                   	leave  
  8004bd:	c3                   	ret    

008004be <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	57                   	push   %edi
  8004c2:	56                   	push   %esi
  8004c3:	53                   	push   %ebx
  8004c4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004c7:	68 e8 03 80 00       	push   $0x8003e8
  8004cc:	e8 a3 18 00 00       	call   801d74 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004d1:	b8 07 00 00 00       	mov    $0x7,%eax
  8004d6:	cd 30                	int    $0x30
  8004d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	79 17                	jns    8004f9 <fork+0x3b>
		panic("fork fault %e");
  8004e2:	83 ec 04             	sub    $0x4,%esp
  8004e5:	68 49 22 80 00       	push   $0x802249
  8004ea:	68 84 00 00 00       	push   $0x84
  8004ef:	68 25 22 80 00       	push   $0x802225
  8004f4:	e8 d6 0e 00 00       	call   8013cf <_panic>
  8004f9:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  8004fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ff:	75 24                	jne    800525 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800501:	e8 4f fc ff ff       	call   800155 <sys_getenvid>
  800506:	25 ff 03 00 00       	and    $0x3ff,%eax
  80050b:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  800511:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800516:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80051b:	b8 00 00 00 00       	mov    $0x0,%eax
  800520:	e9 64 01 00 00       	jmp    800689 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800525:	83 ec 04             	sub    $0x4,%esp
  800528:	6a 07                	push   $0x7
  80052a:	68 00 f0 bf ee       	push   $0xeebff000
  80052f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800532:	e8 5c fc ff ff       	call   800193 <sys_page_alloc>
  800537:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80053a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80053f:	89 d8                	mov    %ebx,%eax
  800541:	c1 e8 16             	shr    $0x16,%eax
  800544:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80054b:	a8 01                	test   $0x1,%al
  80054d:	0f 84 fc 00 00 00    	je     80064f <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800553:	89 d8                	mov    %ebx,%eax
  800555:	c1 e8 0c             	shr    $0xc,%eax
  800558:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80055f:	f6 c2 01             	test   $0x1,%dl
  800562:	0f 84 e7 00 00 00    	je     80064f <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800568:	89 c6                	mov    %eax,%esi
  80056a:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80056d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800574:	f6 c6 04             	test   $0x4,%dh
  800577:	74 39                	je     8005b2 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800579:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800580:	83 ec 0c             	sub    $0xc,%esp
  800583:	25 07 0e 00 00       	and    $0xe07,%eax
  800588:	50                   	push   %eax
  800589:	56                   	push   %esi
  80058a:	57                   	push   %edi
  80058b:	56                   	push   %esi
  80058c:	6a 00                	push   $0x0
  80058e:	e8 43 fc ff ff       	call   8001d6 <sys_page_map>
		if (r < 0) {
  800593:	83 c4 20             	add    $0x20,%esp
  800596:	85 c0                	test   %eax,%eax
  800598:	0f 89 b1 00 00 00    	jns    80064f <fork+0x191>
		    	panic("sys page map fault %e");
  80059e:	83 ec 04             	sub    $0x4,%esp
  8005a1:	68 57 22 80 00       	push   $0x802257
  8005a6:	6a 54                	push   $0x54
  8005a8:	68 25 22 80 00       	push   $0x802225
  8005ad:	e8 1d 0e 00 00       	call   8013cf <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 02             	test   $0x2,%dl
  8005bc:	75 0c                	jne    8005ca <fork+0x10c>
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	f6 c4 08             	test   $0x8,%ah
  8005c8:	74 5b                	je     800625 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005ca:	83 ec 0c             	sub    $0xc,%esp
  8005cd:	68 05 08 00 00       	push   $0x805
  8005d2:	56                   	push   %esi
  8005d3:	57                   	push   %edi
  8005d4:	56                   	push   %esi
  8005d5:	6a 00                	push   $0x0
  8005d7:	e8 fa fb ff ff       	call   8001d6 <sys_page_map>
		if (r < 0) {
  8005dc:	83 c4 20             	add    $0x20,%esp
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	79 14                	jns    8005f7 <fork+0x139>
		    	panic("sys page map fault %e");
  8005e3:	83 ec 04             	sub    $0x4,%esp
  8005e6:	68 57 22 80 00       	push   $0x802257
  8005eb:	6a 5b                	push   $0x5b
  8005ed:	68 25 22 80 00       	push   $0x802225
  8005f2:	e8 d8 0d 00 00       	call   8013cf <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  8005f7:	83 ec 0c             	sub    $0xc,%esp
  8005fa:	68 05 08 00 00       	push   $0x805
  8005ff:	56                   	push   %esi
  800600:	6a 00                	push   $0x0
  800602:	56                   	push   %esi
  800603:	6a 00                	push   $0x0
  800605:	e8 cc fb ff ff       	call   8001d6 <sys_page_map>
		if (r < 0) {
  80060a:	83 c4 20             	add    $0x20,%esp
  80060d:	85 c0                	test   %eax,%eax
  80060f:	79 3e                	jns    80064f <fork+0x191>
		    	panic("sys page map fault %e");
  800611:	83 ec 04             	sub    $0x4,%esp
  800614:	68 57 22 80 00       	push   $0x802257
  800619:	6a 5f                	push   $0x5f
  80061b:	68 25 22 80 00       	push   $0x802225
  800620:	e8 aa 0d 00 00       	call   8013cf <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800625:	83 ec 0c             	sub    $0xc,%esp
  800628:	6a 05                	push   $0x5
  80062a:	56                   	push   %esi
  80062b:	57                   	push   %edi
  80062c:	56                   	push   %esi
  80062d:	6a 00                	push   $0x0
  80062f:	e8 a2 fb ff ff       	call   8001d6 <sys_page_map>
		if (r < 0) {
  800634:	83 c4 20             	add    $0x20,%esp
  800637:	85 c0                	test   %eax,%eax
  800639:	79 14                	jns    80064f <fork+0x191>
		    	panic("sys page map fault %e");
  80063b:	83 ec 04             	sub    $0x4,%esp
  80063e:	68 57 22 80 00       	push   $0x802257
  800643:	6a 64                	push   $0x64
  800645:	68 25 22 80 00       	push   $0x802225
  80064a:	e8 80 0d 00 00       	call   8013cf <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80064f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800655:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80065b:	0f 85 de fe ff ff    	jne    80053f <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800661:	a1 04 40 80 00       	mov    0x804004,%eax
  800666:	8b 80 98 00 00 00    	mov    0x98(%eax),%eax
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	50                   	push   %eax
  800670:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800673:	57                   	push   %edi
  800674:	e8 65 fc ff ff       	call   8002de <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800679:	83 c4 08             	add    $0x8,%esp
  80067c:	6a 02                	push   $0x2
  80067e:	57                   	push   %edi
  80067f:	e8 d6 fb ff ff       	call   80025a <sys_env_set_status>
	
	return envid;
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  800689:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80068c:	5b                   	pop    %ebx
  80068d:	5e                   	pop    %esi
  80068e:	5f                   	pop    %edi
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    

00800691 <sfork>:

envid_t
sfork(void)
{
  800691:	55                   	push   %ebp
  800692:	89 e5                	mov    %esp,%ebp
	return 0;
}
  800694:	b8 00 00 00 00       	mov    $0x0,%eax
  800699:	5d                   	pop    %ebp
  80069a:	c3                   	ret    

0080069b <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	56                   	push   %esi
  80069f:	53                   	push   %ebx
  8006a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8006a3:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	68 70 22 80 00       	push   $0x802270
  8006b2:	e8 f1 0d 00 00       	call   8014a8 <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006b7:	c7 04 24 9d 00 80 00 	movl   $0x80009d,(%esp)
  8006be:	e8 c1 fc ff ff       	call   800384 <sys_thread_create>
  8006c3:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006c5:	83 c4 08             	add    $0x8,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	68 70 22 80 00       	push   $0x802270
  8006ce:	e8 d5 0d 00 00       	call   8014a8 <cprintf>
	return id;
}
  8006d3:	89 f0                	mov    %esi,%eax
  8006d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006d8:	5b                   	pop    %ebx
  8006d9:	5e                   	pop    %esi
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8006df:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e2:	05 00 00 00 30       	add    $0x30000000,%eax
  8006e7:	c1 e8 0c             	shr    $0xc,%eax
}
  8006ea:	5d                   	pop    %ebp
  8006eb:	c3                   	ret    

008006ec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8006f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8006fc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800701:	5d                   	pop    %ebp
  800702:	c3                   	ret    

00800703 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800709:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80070e:	89 c2                	mov    %eax,%edx
  800710:	c1 ea 16             	shr    $0x16,%edx
  800713:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80071a:	f6 c2 01             	test   $0x1,%dl
  80071d:	74 11                	je     800730 <fd_alloc+0x2d>
  80071f:	89 c2                	mov    %eax,%edx
  800721:	c1 ea 0c             	shr    $0xc,%edx
  800724:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80072b:	f6 c2 01             	test   $0x1,%dl
  80072e:	75 09                	jne    800739 <fd_alloc+0x36>
			*fd_store = fd;
  800730:	89 01                	mov    %eax,(%ecx)
			return 0;
  800732:	b8 00 00 00 00       	mov    $0x0,%eax
  800737:	eb 17                	jmp    800750 <fd_alloc+0x4d>
  800739:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80073e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800743:	75 c9                	jne    80070e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800745:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80074b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800758:	83 f8 1f             	cmp    $0x1f,%eax
  80075b:	77 36                	ja     800793 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80075d:	c1 e0 0c             	shl    $0xc,%eax
  800760:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800765:	89 c2                	mov    %eax,%edx
  800767:	c1 ea 16             	shr    $0x16,%edx
  80076a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800771:	f6 c2 01             	test   $0x1,%dl
  800774:	74 24                	je     80079a <fd_lookup+0x48>
  800776:	89 c2                	mov    %eax,%edx
  800778:	c1 ea 0c             	shr    $0xc,%edx
  80077b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800782:	f6 c2 01             	test   $0x1,%dl
  800785:	74 1a                	je     8007a1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078a:	89 02                	mov    %eax,(%edx)
	return 0;
  80078c:	b8 00 00 00 00       	mov    $0x0,%eax
  800791:	eb 13                	jmp    8007a6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800793:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800798:	eb 0c                	jmp    8007a6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80079a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80079f:	eb 05                	jmp    8007a6 <fd_lookup+0x54>
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b1:	ba 10 23 80 00       	mov    $0x802310,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007b6:	eb 13                	jmp    8007cb <dev_lookup+0x23>
  8007b8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8007bb:	39 08                	cmp    %ecx,(%eax)
  8007bd:	75 0c                	jne    8007cb <dev_lookup+0x23>
			*dev = devtab[i];
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c9:	eb 2e                	jmp    8007f9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8007cb:	8b 02                	mov    (%edx),%eax
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	75 e7                	jne    8007b8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8007d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8007d6:	8b 40 7c             	mov    0x7c(%eax),%eax
  8007d9:	83 ec 04             	sub    $0x4,%esp
  8007dc:	51                   	push   %ecx
  8007dd:	50                   	push   %eax
  8007de:	68 94 22 80 00       	push   $0x802294
  8007e3:	e8 c0 0c 00 00       	call   8014a8 <cprintf>
	*dev = 0;
  8007e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8007f1:	83 c4 10             	add    $0x10,%esp
  8007f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	83 ec 10             	sub    $0x10,%esp
  800803:	8b 75 08             	mov    0x8(%ebp),%esi
  800806:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800809:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80080c:	50                   	push   %eax
  80080d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800813:	c1 e8 0c             	shr    $0xc,%eax
  800816:	50                   	push   %eax
  800817:	e8 36 ff ff ff       	call   800752 <fd_lookup>
  80081c:	83 c4 08             	add    $0x8,%esp
  80081f:	85 c0                	test   %eax,%eax
  800821:	78 05                	js     800828 <fd_close+0x2d>
	    || fd != fd2)
  800823:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800826:	74 0c                	je     800834 <fd_close+0x39>
		return (must_exist ? r : 0);
  800828:	84 db                	test   %bl,%bl
  80082a:	ba 00 00 00 00       	mov    $0x0,%edx
  80082f:	0f 44 c2             	cmove  %edx,%eax
  800832:	eb 41                	jmp    800875 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80083a:	50                   	push   %eax
  80083b:	ff 36                	pushl  (%esi)
  80083d:	e8 66 ff ff ff       	call   8007a8 <dev_lookup>
  800842:	89 c3                	mov    %eax,%ebx
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	85 c0                	test   %eax,%eax
  800849:	78 1a                	js     800865 <fd_close+0x6a>
		if (dev->dev_close)
  80084b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800851:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800856:	85 c0                	test   %eax,%eax
  800858:	74 0b                	je     800865 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80085a:	83 ec 0c             	sub    $0xc,%esp
  80085d:	56                   	push   %esi
  80085e:	ff d0                	call   *%eax
  800860:	89 c3                	mov    %eax,%ebx
  800862:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	56                   	push   %esi
  800869:	6a 00                	push   $0x0
  80086b:	e8 a8 f9 ff ff       	call   800218 <sys_page_unmap>
	return r;
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	89 d8                	mov    %ebx,%eax
}
  800875:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800878:	5b                   	pop    %ebx
  800879:	5e                   	pop    %esi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800882:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800885:	50                   	push   %eax
  800886:	ff 75 08             	pushl  0x8(%ebp)
  800889:	e8 c4 fe ff ff       	call   800752 <fd_lookup>
  80088e:	83 c4 08             	add    $0x8,%esp
  800891:	85 c0                	test   %eax,%eax
  800893:	78 10                	js     8008a5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	6a 01                	push   $0x1
  80089a:	ff 75 f4             	pushl  -0xc(%ebp)
  80089d:	e8 59 ff ff ff       	call   8007fb <fd_close>
  8008a2:	83 c4 10             	add    $0x10,%esp
}
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    

008008a7 <close_all>:

void
close_all(void)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008ae:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008b3:	83 ec 0c             	sub    $0xc,%esp
  8008b6:	53                   	push   %ebx
  8008b7:	e8 c0 ff ff ff       	call   80087c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8008bc:	83 c3 01             	add    $0x1,%ebx
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	83 fb 20             	cmp    $0x20,%ebx
  8008c5:	75 ec                	jne    8008b3 <close_all+0xc>
		close(i);
}
  8008c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ca:	c9                   	leave  
  8008cb:	c3                   	ret    

008008cc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	57                   	push   %edi
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
  8008d2:	83 ec 2c             	sub    $0x2c,%esp
  8008d5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8008d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8008db:	50                   	push   %eax
  8008dc:	ff 75 08             	pushl  0x8(%ebp)
  8008df:	e8 6e fe ff ff       	call   800752 <fd_lookup>
  8008e4:	83 c4 08             	add    $0x8,%esp
  8008e7:	85 c0                	test   %eax,%eax
  8008e9:	0f 88 c1 00 00 00    	js     8009b0 <dup+0xe4>
		return r;
	close(newfdnum);
  8008ef:	83 ec 0c             	sub    $0xc,%esp
  8008f2:	56                   	push   %esi
  8008f3:	e8 84 ff ff ff       	call   80087c <close>

	newfd = INDEX2FD(newfdnum);
  8008f8:	89 f3                	mov    %esi,%ebx
  8008fa:	c1 e3 0c             	shl    $0xc,%ebx
  8008fd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800903:	83 c4 04             	add    $0x4,%esp
  800906:	ff 75 e4             	pushl  -0x1c(%ebp)
  800909:	e8 de fd ff ff       	call   8006ec <fd2data>
  80090e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800910:	89 1c 24             	mov    %ebx,(%esp)
  800913:	e8 d4 fd ff ff       	call   8006ec <fd2data>
  800918:	83 c4 10             	add    $0x10,%esp
  80091b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80091e:	89 f8                	mov    %edi,%eax
  800920:	c1 e8 16             	shr    $0x16,%eax
  800923:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80092a:	a8 01                	test   $0x1,%al
  80092c:	74 37                	je     800965 <dup+0x99>
  80092e:	89 f8                	mov    %edi,%eax
  800930:	c1 e8 0c             	shr    $0xc,%eax
  800933:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80093a:	f6 c2 01             	test   $0x1,%dl
  80093d:	74 26                	je     800965 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80093f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800946:	83 ec 0c             	sub    $0xc,%esp
  800949:	25 07 0e 00 00       	and    $0xe07,%eax
  80094e:	50                   	push   %eax
  80094f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800952:	6a 00                	push   $0x0
  800954:	57                   	push   %edi
  800955:	6a 00                	push   $0x0
  800957:	e8 7a f8 ff ff       	call   8001d6 <sys_page_map>
  80095c:	89 c7                	mov    %eax,%edi
  80095e:	83 c4 20             	add    $0x20,%esp
  800961:	85 c0                	test   %eax,%eax
  800963:	78 2e                	js     800993 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800965:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800968:	89 d0                	mov    %edx,%eax
  80096a:	c1 e8 0c             	shr    $0xc,%eax
  80096d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800974:	83 ec 0c             	sub    $0xc,%esp
  800977:	25 07 0e 00 00       	and    $0xe07,%eax
  80097c:	50                   	push   %eax
  80097d:	53                   	push   %ebx
  80097e:	6a 00                	push   $0x0
  800980:	52                   	push   %edx
  800981:	6a 00                	push   $0x0
  800983:	e8 4e f8 ff ff       	call   8001d6 <sys_page_map>
  800988:	89 c7                	mov    %eax,%edi
  80098a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80098d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80098f:	85 ff                	test   %edi,%edi
  800991:	79 1d                	jns    8009b0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800993:	83 ec 08             	sub    $0x8,%esp
  800996:	53                   	push   %ebx
  800997:	6a 00                	push   $0x0
  800999:	e8 7a f8 ff ff       	call   800218 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80099e:	83 c4 08             	add    $0x8,%esp
  8009a1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009a4:	6a 00                	push   $0x0
  8009a6:	e8 6d f8 ff ff       	call   800218 <sys_page_unmap>
	return r;
  8009ab:	83 c4 10             	add    $0x10,%esp
  8009ae:	89 f8                	mov    %edi,%eax
}
  8009b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b3:	5b                   	pop    %ebx
  8009b4:	5e                   	pop    %esi
  8009b5:	5f                   	pop    %edi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 14             	sub    $0x14,%esp
  8009bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009c5:	50                   	push   %eax
  8009c6:	53                   	push   %ebx
  8009c7:	e8 86 fd ff ff       	call   800752 <fd_lookup>
  8009cc:	83 c4 08             	add    $0x8,%esp
  8009cf:	89 c2                	mov    %eax,%edx
  8009d1:	85 c0                	test   %eax,%eax
  8009d3:	78 6d                	js     800a42 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009d5:	83 ec 08             	sub    $0x8,%esp
  8009d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009db:	50                   	push   %eax
  8009dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009df:	ff 30                	pushl  (%eax)
  8009e1:	e8 c2 fd ff ff       	call   8007a8 <dev_lookup>
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	85 c0                	test   %eax,%eax
  8009eb:	78 4c                	js     800a39 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8009ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009f0:	8b 42 08             	mov    0x8(%edx),%eax
  8009f3:	83 e0 03             	and    $0x3,%eax
  8009f6:	83 f8 01             	cmp    $0x1,%eax
  8009f9:	75 21                	jne    800a1c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8009fb:	a1 04 40 80 00       	mov    0x804004,%eax
  800a00:	8b 40 7c             	mov    0x7c(%eax),%eax
  800a03:	83 ec 04             	sub    $0x4,%esp
  800a06:	53                   	push   %ebx
  800a07:	50                   	push   %eax
  800a08:	68 d5 22 80 00       	push   $0x8022d5
  800a0d:	e8 96 0a 00 00       	call   8014a8 <cprintf>
		return -E_INVAL;
  800a12:	83 c4 10             	add    $0x10,%esp
  800a15:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a1a:	eb 26                	jmp    800a42 <read+0x8a>
	}
	if (!dev->dev_read)
  800a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a1f:	8b 40 08             	mov    0x8(%eax),%eax
  800a22:	85 c0                	test   %eax,%eax
  800a24:	74 17                	je     800a3d <read+0x85>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a26:	83 ec 04             	sub    $0x4,%esp
  800a29:	ff 75 10             	pushl  0x10(%ebp)
  800a2c:	ff 75 0c             	pushl  0xc(%ebp)
  800a2f:	52                   	push   %edx
  800a30:	ff d0                	call   *%eax
  800a32:	89 c2                	mov    %eax,%edx
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	eb 09                	jmp    800a42 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a39:	89 c2                	mov    %eax,%edx
  800a3b:	eb 05                	jmp    800a42 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a3d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a42:	89 d0                	mov    %edx,%eax
  800a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a47:	c9                   	leave  
  800a48:	c3                   	ret    

00800a49 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	83 ec 0c             	sub    $0xc,%esp
  800a52:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a55:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a5d:	eb 21                	jmp    800a80 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800a5f:	83 ec 04             	sub    $0x4,%esp
  800a62:	89 f0                	mov    %esi,%eax
  800a64:	29 d8                	sub    %ebx,%eax
  800a66:	50                   	push   %eax
  800a67:	89 d8                	mov    %ebx,%eax
  800a69:	03 45 0c             	add    0xc(%ebp),%eax
  800a6c:	50                   	push   %eax
  800a6d:	57                   	push   %edi
  800a6e:	e8 45 ff ff ff       	call   8009b8 <read>
		if (m < 0)
  800a73:	83 c4 10             	add    $0x10,%esp
  800a76:	85 c0                	test   %eax,%eax
  800a78:	78 10                	js     800a8a <readn+0x41>
			return m;
		if (m == 0)
  800a7a:	85 c0                	test   %eax,%eax
  800a7c:	74 0a                	je     800a88 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800a7e:	01 c3                	add    %eax,%ebx
  800a80:	39 f3                	cmp    %esi,%ebx
  800a82:	72 db                	jb     800a5f <readn+0x16>
  800a84:	89 d8                	mov    %ebx,%eax
  800a86:	eb 02                	jmp    800a8a <readn+0x41>
  800a88:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800a8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5f                   	pop    %edi
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	53                   	push   %ebx
  800a96:	83 ec 14             	sub    $0x14,%esp
  800a99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a9f:	50                   	push   %eax
  800aa0:	53                   	push   %ebx
  800aa1:	e8 ac fc ff ff       	call   800752 <fd_lookup>
  800aa6:	83 c4 08             	add    $0x8,%esp
  800aa9:	89 c2                	mov    %eax,%edx
  800aab:	85 c0                	test   %eax,%eax
  800aad:	78 68                	js     800b17 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800aaf:	83 ec 08             	sub    $0x8,%esp
  800ab2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab5:	50                   	push   %eax
  800ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ab9:	ff 30                	pushl  (%eax)
  800abb:	e8 e8 fc ff ff       	call   8007a8 <dev_lookup>
  800ac0:	83 c4 10             	add    $0x10,%esp
  800ac3:	85 c0                	test   %eax,%eax
  800ac5:	78 47                	js     800b0e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ace:	75 21                	jne    800af1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800ad0:	a1 04 40 80 00       	mov    0x804004,%eax
  800ad5:	8b 40 7c             	mov    0x7c(%eax),%eax
  800ad8:	83 ec 04             	sub    $0x4,%esp
  800adb:	53                   	push   %ebx
  800adc:	50                   	push   %eax
  800add:	68 f1 22 80 00       	push   $0x8022f1
  800ae2:	e8 c1 09 00 00       	call   8014a8 <cprintf>
		return -E_INVAL;
  800ae7:	83 c4 10             	add    $0x10,%esp
  800aea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800aef:	eb 26                	jmp    800b17 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800af1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af4:	8b 52 0c             	mov    0xc(%edx),%edx
  800af7:	85 d2                	test   %edx,%edx
  800af9:	74 17                	je     800b12 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800afb:	83 ec 04             	sub    $0x4,%esp
  800afe:	ff 75 10             	pushl  0x10(%ebp)
  800b01:	ff 75 0c             	pushl  0xc(%ebp)
  800b04:	50                   	push   %eax
  800b05:	ff d2                	call   *%edx
  800b07:	89 c2                	mov    %eax,%edx
  800b09:	83 c4 10             	add    $0x10,%esp
  800b0c:	eb 09                	jmp    800b17 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b0e:	89 c2                	mov    %eax,%edx
  800b10:	eb 05                	jmp    800b17 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b12:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b17:	89 d0                	mov    %edx,%eax
  800b19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b1c:	c9                   	leave  
  800b1d:	c3                   	ret    

00800b1e <seek>:

int
seek(int fdnum, off_t offset)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b24:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b27:	50                   	push   %eax
  800b28:	ff 75 08             	pushl  0x8(%ebp)
  800b2b:	e8 22 fc ff ff       	call   800752 <fd_lookup>
  800b30:	83 c4 08             	add    $0x8,%esp
  800b33:	85 c0                	test   %eax,%eax
  800b35:	78 0e                	js     800b45 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b37:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b45:	c9                   	leave  
  800b46:	c3                   	ret    

00800b47 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	53                   	push   %ebx
  800b4b:	83 ec 14             	sub    $0x14,%esp
  800b4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b51:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b54:	50                   	push   %eax
  800b55:	53                   	push   %ebx
  800b56:	e8 f7 fb ff ff       	call   800752 <fd_lookup>
  800b5b:	83 c4 08             	add    $0x8,%esp
  800b5e:	89 c2                	mov    %eax,%edx
  800b60:	85 c0                	test   %eax,%eax
  800b62:	78 65                	js     800bc9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b64:	83 ec 08             	sub    $0x8,%esp
  800b67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b6a:	50                   	push   %eax
  800b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b6e:	ff 30                	pushl  (%eax)
  800b70:	e8 33 fc ff ff       	call   8007a8 <dev_lookup>
  800b75:	83 c4 10             	add    $0x10,%esp
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	78 44                	js     800bc0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b7f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b83:	75 21                	jne    800ba6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800b85:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800b8a:	8b 40 7c             	mov    0x7c(%eax),%eax
  800b8d:	83 ec 04             	sub    $0x4,%esp
  800b90:	53                   	push   %ebx
  800b91:	50                   	push   %eax
  800b92:	68 b4 22 80 00       	push   $0x8022b4
  800b97:	e8 0c 09 00 00       	call   8014a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800b9c:	83 c4 10             	add    $0x10,%esp
  800b9f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ba4:	eb 23                	jmp    800bc9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800ba6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ba9:	8b 52 18             	mov    0x18(%edx),%edx
  800bac:	85 d2                	test   %edx,%edx
  800bae:	74 14                	je     800bc4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800bb0:	83 ec 08             	sub    $0x8,%esp
  800bb3:	ff 75 0c             	pushl  0xc(%ebp)
  800bb6:	50                   	push   %eax
  800bb7:	ff d2                	call   *%edx
  800bb9:	89 c2                	mov    %eax,%edx
  800bbb:	83 c4 10             	add    $0x10,%esp
  800bbe:	eb 09                	jmp    800bc9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bc0:	89 c2                	mov    %eax,%edx
  800bc2:	eb 05                	jmp    800bc9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800bc4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800bc9:	89 d0                	mov    %edx,%eax
  800bcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 14             	sub    $0x14,%esp
  800bd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bda:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bdd:	50                   	push   %eax
  800bde:	ff 75 08             	pushl  0x8(%ebp)
  800be1:	e8 6c fb ff ff       	call   800752 <fd_lookup>
  800be6:	83 c4 08             	add    $0x8,%esp
  800be9:	89 c2                	mov    %eax,%edx
  800beb:	85 c0                	test   %eax,%eax
  800bed:	78 58                	js     800c47 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bef:	83 ec 08             	sub    $0x8,%esp
  800bf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bf5:	50                   	push   %eax
  800bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bf9:	ff 30                	pushl  (%eax)
  800bfb:	e8 a8 fb ff ff       	call   8007a8 <dev_lookup>
  800c00:	83 c4 10             	add    $0x10,%esp
  800c03:	85 c0                	test   %eax,%eax
  800c05:	78 37                	js     800c3e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c0e:	74 32                	je     800c42 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c10:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c13:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c1a:	00 00 00 
	stat->st_isdir = 0;
  800c1d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c24:	00 00 00 
	stat->st_dev = dev;
  800c27:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c2d:	83 ec 08             	sub    $0x8,%esp
  800c30:	53                   	push   %ebx
  800c31:	ff 75 f0             	pushl  -0x10(%ebp)
  800c34:	ff 50 14             	call   *0x14(%eax)
  800c37:	89 c2                	mov    %eax,%edx
  800c39:	83 c4 10             	add    $0x10,%esp
  800c3c:	eb 09                	jmp    800c47 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c3e:	89 c2                	mov    %eax,%edx
  800c40:	eb 05                	jmp    800c47 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c42:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c47:	89 d0                	mov    %edx,%eax
  800c49:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c4c:	c9                   	leave  
  800c4d:	c3                   	ret    

00800c4e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800c53:	83 ec 08             	sub    $0x8,%esp
  800c56:	6a 00                	push   $0x0
  800c58:	ff 75 08             	pushl  0x8(%ebp)
  800c5b:	e8 e3 01 00 00       	call   800e43 <open>
  800c60:	89 c3                	mov    %eax,%ebx
  800c62:	83 c4 10             	add    $0x10,%esp
  800c65:	85 c0                	test   %eax,%eax
  800c67:	78 1b                	js     800c84 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800c69:	83 ec 08             	sub    $0x8,%esp
  800c6c:	ff 75 0c             	pushl  0xc(%ebp)
  800c6f:	50                   	push   %eax
  800c70:	e8 5b ff ff ff       	call   800bd0 <fstat>
  800c75:	89 c6                	mov    %eax,%esi
	close(fd);
  800c77:	89 1c 24             	mov    %ebx,(%esp)
  800c7a:	e8 fd fb ff ff       	call   80087c <close>
	return r;
  800c7f:	83 c4 10             	add    $0x10,%esp
  800c82:	89 f0                	mov    %esi,%eax
}
  800c84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	89 c6                	mov    %eax,%esi
  800c92:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800c94:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800c9b:	75 12                	jne    800caf <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	6a 01                	push   $0x1
  800ca2:	e8 15 12 00 00       	call   801ebc <ipc_find_env>
  800ca7:	a3 00 40 80 00       	mov    %eax,0x804000
  800cac:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800caf:	6a 07                	push   $0x7
  800cb1:	68 00 50 80 00       	push   $0x805000
  800cb6:	56                   	push   %esi
  800cb7:	ff 35 00 40 80 00    	pushl  0x804000
  800cbd:	e8 98 11 00 00       	call   801e5a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800cc2:	83 c4 0c             	add    $0xc,%esp
  800cc5:	6a 00                	push   $0x0
  800cc7:	53                   	push   %ebx
  800cc8:	6a 00                	push   $0x0
  800cca:	e8 10 11 00 00       	call   801ddf <ipc_recv>
}
  800ccf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	8b 40 0c             	mov    0xc(%eax),%eax
  800ce2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cea:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800cef:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf4:	b8 02 00 00 00       	mov    $0x2,%eax
  800cf9:	e8 8d ff ff ff       	call   800c8b <fsipc>
}
  800cfe:	c9                   	leave  
  800cff:	c3                   	ret    

00800d00 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d06:	8b 45 08             	mov    0x8(%ebp),%eax
  800d09:	8b 40 0c             	mov    0xc(%eax),%eax
  800d0c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d11:	ba 00 00 00 00       	mov    $0x0,%edx
  800d16:	b8 06 00 00 00       	mov    $0x6,%eax
  800d1b:	e8 6b ff ff ff       	call   800c8b <fsipc>
}
  800d20:	c9                   	leave  
  800d21:	c3                   	ret    

00800d22 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	53                   	push   %ebx
  800d26:	83 ec 04             	sub    $0x4,%esp
  800d29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2f:	8b 40 0c             	mov    0xc(%eax),%eax
  800d32:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d37:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3c:	b8 05 00 00 00       	mov    $0x5,%eax
  800d41:	e8 45 ff ff ff       	call   800c8b <fsipc>
  800d46:	85 c0                	test   %eax,%eax
  800d48:	78 2c                	js     800d76 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d4a:	83 ec 08             	sub    $0x8,%esp
  800d4d:	68 00 50 80 00       	push   $0x805000
  800d52:	53                   	push   %ebx
  800d53:	e8 d5 0c 00 00       	call   801a2d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800d58:	a1 80 50 80 00       	mov    0x805080,%eax
  800d5d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800d63:	a1 84 50 80 00       	mov    0x805084,%eax
  800d68:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d79:	c9                   	leave  
  800d7a:	c3                   	ret    

00800d7b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	8b 52 0c             	mov    0xc(%edx),%edx
  800d8a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800d90:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d95:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d9a:	0f 47 c2             	cmova  %edx,%eax
  800d9d:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800da2:	50                   	push   %eax
  800da3:	ff 75 0c             	pushl  0xc(%ebp)
  800da6:	68 08 50 80 00       	push   $0x805008
  800dab:	e8 0f 0e 00 00       	call   801bbf <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800db0:	ba 00 00 00 00       	mov    $0x0,%edx
  800db5:	b8 04 00 00 00       	mov    $0x4,%eax
  800dba:	e8 cc fe ff ff       	call   800c8b <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	8b 40 0c             	mov    0xc(%eax),%eax
  800dcf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800dd4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800dda:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddf:	b8 03 00 00 00       	mov    $0x3,%eax
  800de4:	e8 a2 fe ff ff       	call   800c8b <fsipc>
  800de9:	89 c3                	mov    %eax,%ebx
  800deb:	85 c0                	test   %eax,%eax
  800ded:	78 4b                	js     800e3a <devfile_read+0x79>
		return r;
	assert(r <= n);
  800def:	39 c6                	cmp    %eax,%esi
  800df1:	73 16                	jae    800e09 <devfile_read+0x48>
  800df3:	68 20 23 80 00       	push   $0x802320
  800df8:	68 27 23 80 00       	push   $0x802327
  800dfd:	6a 7c                	push   $0x7c
  800dff:	68 3c 23 80 00       	push   $0x80233c
  800e04:	e8 c6 05 00 00       	call   8013cf <_panic>
	assert(r <= PGSIZE);
  800e09:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e0e:	7e 16                	jle    800e26 <devfile_read+0x65>
  800e10:	68 47 23 80 00       	push   $0x802347
  800e15:	68 27 23 80 00       	push   $0x802327
  800e1a:	6a 7d                	push   $0x7d
  800e1c:	68 3c 23 80 00       	push   $0x80233c
  800e21:	e8 a9 05 00 00       	call   8013cf <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	50                   	push   %eax
  800e2a:	68 00 50 80 00       	push   $0x805000
  800e2f:	ff 75 0c             	pushl  0xc(%ebp)
  800e32:	e8 88 0d 00 00       	call   801bbf <memmove>
	return r;
  800e37:	83 c4 10             	add    $0x10,%esp
}
  800e3a:	89 d8                	mov    %ebx,%eax
  800e3c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e3f:	5b                   	pop    %ebx
  800e40:	5e                   	pop    %esi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	53                   	push   %ebx
  800e47:	83 ec 20             	sub    $0x20,%esp
  800e4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e4d:	53                   	push   %ebx
  800e4e:	e8 a1 0b 00 00       	call   8019f4 <strlen>
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800e5b:	7f 67                	jg     800ec4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e63:	50                   	push   %eax
  800e64:	e8 9a f8 ff ff       	call   800703 <fd_alloc>
  800e69:	83 c4 10             	add    $0x10,%esp
		return r;
  800e6c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	78 57                	js     800ec9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800e72:	83 ec 08             	sub    $0x8,%esp
  800e75:	53                   	push   %ebx
  800e76:	68 00 50 80 00       	push   $0x805000
  800e7b:	e8 ad 0b 00 00       	call   801a2d <strcpy>
	fsipcbuf.open.req_omode = mode;
  800e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e83:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800e88:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800e90:	e8 f6 fd ff ff       	call   800c8b <fsipc>
  800e95:	89 c3                	mov    %eax,%ebx
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	79 14                	jns    800eb2 <open+0x6f>
		fd_close(fd, 0);
  800e9e:	83 ec 08             	sub    $0x8,%esp
  800ea1:	6a 00                	push   $0x0
  800ea3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea6:	e8 50 f9 ff ff       	call   8007fb <fd_close>
		return r;
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	89 da                	mov    %ebx,%edx
  800eb0:	eb 17                	jmp    800ec9 <open+0x86>
	}

	return fd2num(fd);
  800eb2:	83 ec 0c             	sub    $0xc,%esp
  800eb5:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb8:	e8 1f f8 ff ff       	call   8006dc <fd2num>
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	83 c4 10             	add    $0x10,%esp
  800ec2:	eb 05                	jmp    800ec9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ec4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800ec9:	89 d0                	mov    %edx,%eax
  800ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ed6:	ba 00 00 00 00       	mov    $0x0,%edx
  800edb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ee0:	e8 a6 fd ff ff       	call   800c8b <fsipc>
}
  800ee5:	c9                   	leave  
  800ee6:	c3                   	ret    

00800ee7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ee7:	55                   	push   %ebp
  800ee8:	89 e5                	mov    %esp,%ebp
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800eef:	83 ec 0c             	sub    $0xc,%esp
  800ef2:	ff 75 08             	pushl  0x8(%ebp)
  800ef5:	e8 f2 f7 ff ff       	call   8006ec <fd2data>
  800efa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800efc:	83 c4 08             	add    $0x8,%esp
  800eff:	68 53 23 80 00       	push   $0x802353
  800f04:	53                   	push   %ebx
  800f05:	e8 23 0b 00 00       	call   801a2d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f0a:	8b 46 04             	mov    0x4(%esi),%eax
  800f0d:	2b 06                	sub    (%esi),%eax
  800f0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f15:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f1c:	00 00 00 
	stat->st_dev = &devpipe;
  800f1f:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f26:	30 80 00 
	return 0;
}
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	53                   	push   %ebx
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f3f:	53                   	push   %ebx
  800f40:	6a 00                	push   $0x0
  800f42:	e8 d1 f2 ff ff       	call   800218 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f47:	89 1c 24             	mov    %ebx,(%esp)
  800f4a:	e8 9d f7 ff ff       	call   8006ec <fd2data>
  800f4f:	83 c4 08             	add    $0x8,%esp
  800f52:	50                   	push   %eax
  800f53:	6a 00                	push   $0x0
  800f55:	e8 be f2 ff ff       	call   800218 <sys_page_unmap>
}
  800f5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    

00800f5f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	57                   	push   %edi
  800f63:	56                   	push   %esi
  800f64:	53                   	push   %ebx
  800f65:	83 ec 1c             	sub    $0x1c,%esp
  800f68:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f6b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800f6d:	a1 04 40 80 00       	mov    0x804004,%eax
  800f72:	8b b0 8c 00 00 00    	mov    0x8c(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800f78:	83 ec 0c             	sub    $0xc,%esp
  800f7b:	ff 75 e0             	pushl  -0x20(%ebp)
  800f7e:	e8 7b 0f 00 00       	call   801efe <pageref>
  800f83:	89 c3                	mov    %eax,%ebx
  800f85:	89 3c 24             	mov    %edi,(%esp)
  800f88:	e8 71 0f 00 00       	call   801efe <pageref>
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	39 c3                	cmp    %eax,%ebx
  800f92:	0f 94 c1             	sete   %cl
  800f95:	0f b6 c9             	movzbl %cl,%ecx
  800f98:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800f9b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800fa1:	8b 8a 8c 00 00 00    	mov    0x8c(%edx),%ecx
		if (n == nn)
  800fa7:	39 ce                	cmp    %ecx,%esi
  800fa9:	74 1e                	je     800fc9 <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800fab:	39 c3                	cmp    %eax,%ebx
  800fad:	75 be                	jne    800f6d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800faf:	8b 82 8c 00 00 00    	mov    0x8c(%edx),%eax
  800fb5:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb8:	50                   	push   %eax
  800fb9:	56                   	push   %esi
  800fba:	68 5a 23 80 00       	push   $0x80235a
  800fbf:	e8 e4 04 00 00       	call   8014a8 <cprintf>
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	eb a4                	jmp    800f6d <_pipeisclosed+0xe>
	}
}
  800fc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 28             	sub    $0x28,%esp
  800fdd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800fe0:	56                   	push   %esi
  800fe1:	e8 06 f7 ff ff       	call   8006ec <fd2data>
  800fe6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	bf 00 00 00 00       	mov    $0x0,%edi
  800ff0:	eb 4b                	jmp    80103d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800ff2:	89 da                	mov    %ebx,%edx
  800ff4:	89 f0                	mov    %esi,%eax
  800ff6:	e8 64 ff ff ff       	call   800f5f <_pipeisclosed>
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	75 48                	jne    801047 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800fff:	e8 70 f1 ff ff       	call   800174 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801004:	8b 43 04             	mov    0x4(%ebx),%eax
  801007:	8b 0b                	mov    (%ebx),%ecx
  801009:	8d 51 20             	lea    0x20(%ecx),%edx
  80100c:	39 d0                	cmp    %edx,%eax
  80100e:	73 e2                	jae    800ff2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801010:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801013:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801017:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80101a:	89 c2                	mov    %eax,%edx
  80101c:	c1 fa 1f             	sar    $0x1f,%edx
  80101f:	89 d1                	mov    %edx,%ecx
  801021:	c1 e9 1b             	shr    $0x1b,%ecx
  801024:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801027:	83 e2 1f             	and    $0x1f,%edx
  80102a:	29 ca                	sub    %ecx,%edx
  80102c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801030:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801034:	83 c0 01             	add    $0x1,%eax
  801037:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80103a:	83 c7 01             	add    $0x1,%edi
  80103d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801040:	75 c2                	jne    801004 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801042:	8b 45 10             	mov    0x10(%ebp),%eax
  801045:	eb 05                	jmp    80104c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801047:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80104c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	57                   	push   %edi
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
  80105a:	83 ec 18             	sub    $0x18,%esp
  80105d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801060:	57                   	push   %edi
  801061:	e8 86 f6 ff ff       	call   8006ec <fd2data>
  801066:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801070:	eb 3d                	jmp    8010af <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801072:	85 db                	test   %ebx,%ebx
  801074:	74 04                	je     80107a <devpipe_read+0x26>
				return i;
  801076:	89 d8                	mov    %ebx,%eax
  801078:	eb 44                	jmp    8010be <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80107a:	89 f2                	mov    %esi,%edx
  80107c:	89 f8                	mov    %edi,%eax
  80107e:	e8 dc fe ff ff       	call   800f5f <_pipeisclosed>
  801083:	85 c0                	test   %eax,%eax
  801085:	75 32                	jne    8010b9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801087:	e8 e8 f0 ff ff       	call   800174 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80108c:	8b 06                	mov    (%esi),%eax
  80108e:	3b 46 04             	cmp    0x4(%esi),%eax
  801091:	74 df                	je     801072 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801093:	99                   	cltd   
  801094:	c1 ea 1b             	shr    $0x1b,%edx
  801097:	01 d0                	add    %edx,%eax
  801099:	83 e0 1f             	and    $0x1f,%eax
  80109c:	29 d0                	sub    %edx,%eax
  80109e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010a9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010ac:	83 c3 01             	add    $0x1,%ebx
  8010af:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8010b2:	75 d8                	jne    80108c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8010b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8010b7:	eb 05                	jmp    8010be <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010b9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8010be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c1:	5b                   	pop    %ebx
  8010c2:	5e                   	pop    %esi
  8010c3:	5f                   	pop    %edi
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8010ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d1:	50                   	push   %eax
  8010d2:	e8 2c f6 ff ff       	call   800703 <fd_alloc>
  8010d7:	83 c4 10             	add    $0x10,%esp
  8010da:	89 c2                	mov    %eax,%edx
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	0f 88 2c 01 00 00    	js     801210 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8010e4:	83 ec 04             	sub    $0x4,%esp
  8010e7:	68 07 04 00 00       	push   $0x407
  8010ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8010ef:	6a 00                	push   $0x0
  8010f1:	e8 9d f0 ff ff       	call   800193 <sys_page_alloc>
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	89 c2                	mov    %eax,%edx
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	0f 88 0d 01 00 00    	js     801210 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801103:	83 ec 0c             	sub    $0xc,%esp
  801106:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801109:	50                   	push   %eax
  80110a:	e8 f4 f5 ff ff       	call   800703 <fd_alloc>
  80110f:	89 c3                	mov    %eax,%ebx
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 c0                	test   %eax,%eax
  801116:	0f 88 e2 00 00 00    	js     8011fe <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80111c:	83 ec 04             	sub    $0x4,%esp
  80111f:	68 07 04 00 00       	push   $0x407
  801124:	ff 75 f0             	pushl  -0x10(%ebp)
  801127:	6a 00                	push   $0x0
  801129:	e8 65 f0 ff ff       	call   800193 <sys_page_alloc>
  80112e:	89 c3                	mov    %eax,%ebx
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	85 c0                	test   %eax,%eax
  801135:	0f 88 c3 00 00 00    	js     8011fe <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	ff 75 f4             	pushl  -0xc(%ebp)
  801141:	e8 a6 f5 ff ff       	call   8006ec <fd2data>
  801146:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801148:	83 c4 0c             	add    $0xc,%esp
  80114b:	68 07 04 00 00       	push   $0x407
  801150:	50                   	push   %eax
  801151:	6a 00                	push   $0x0
  801153:	e8 3b f0 ff ff       	call   800193 <sys_page_alloc>
  801158:	89 c3                	mov    %eax,%ebx
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	85 c0                	test   %eax,%eax
  80115f:	0f 88 89 00 00 00    	js     8011ee <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	ff 75 f0             	pushl  -0x10(%ebp)
  80116b:	e8 7c f5 ff ff       	call   8006ec <fd2data>
  801170:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801177:	50                   	push   %eax
  801178:	6a 00                	push   $0x0
  80117a:	56                   	push   %esi
  80117b:	6a 00                	push   $0x0
  80117d:	e8 54 f0 ff ff       	call   8001d6 <sys_page_map>
  801182:	89 c3                	mov    %eax,%ebx
  801184:	83 c4 20             	add    $0x20,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	78 55                	js     8011e0 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80118b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801191:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801194:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801199:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011a0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8011b5:	83 ec 0c             	sub    $0xc,%esp
  8011b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8011bb:	e8 1c f5 ff ff       	call   8006dc <fd2num>
  8011c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8011c5:	83 c4 04             	add    $0x4,%esp
  8011c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8011cb:	e8 0c f5 ff ff       	call   8006dc <fd2num>
  8011d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d3:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8011de:	eb 30                	jmp    801210 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8011e0:	83 ec 08             	sub    $0x8,%esp
  8011e3:	56                   	push   %esi
  8011e4:	6a 00                	push   $0x0
  8011e6:	e8 2d f0 ff ff       	call   800218 <sys_page_unmap>
  8011eb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8011ee:	83 ec 08             	sub    $0x8,%esp
  8011f1:	ff 75 f0             	pushl  -0x10(%ebp)
  8011f4:	6a 00                	push   $0x0
  8011f6:	e8 1d f0 ff ff       	call   800218 <sys_page_unmap>
  8011fb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8011fe:	83 ec 08             	sub    $0x8,%esp
  801201:	ff 75 f4             	pushl  -0xc(%ebp)
  801204:	6a 00                	push   $0x0
  801206:	e8 0d f0 ff ff       	call   800218 <sys_page_unmap>
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801210:	89 d0                	mov    %edx,%eax
  801212:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	ff 75 08             	pushl  0x8(%ebp)
  801226:	e8 27 f5 ff ff       	call   800752 <fd_lookup>
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	78 18                	js     80124a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801232:	83 ec 0c             	sub    $0xc,%esp
  801235:	ff 75 f4             	pushl  -0xc(%ebp)
  801238:	e8 af f4 ff ff       	call   8006ec <fd2data>
	return _pipeisclosed(fd, p);
  80123d:	89 c2                	mov    %eax,%edx
  80123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801242:	e8 18 fd ff ff       	call   800f5f <_pipeisclosed>
  801247:	83 c4 10             	add    $0x10,%esp
}
  80124a:	c9                   	leave  
  80124b:	c3                   	ret    

0080124c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80124f:	b8 00 00 00 00       	mov    $0x0,%eax
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80125c:	68 72 23 80 00       	push   $0x802372
  801261:	ff 75 0c             	pushl  0xc(%ebp)
  801264:	e8 c4 07 00 00       	call   801a2d <strcpy>
	return 0;
}
  801269:	b8 00 00 00 00       	mov    $0x0,%eax
  80126e:	c9                   	leave  
  80126f:	c3                   	ret    

00801270 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	57                   	push   %edi
  801274:	56                   	push   %esi
  801275:	53                   	push   %ebx
  801276:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80127c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801281:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801287:	eb 2d                	jmp    8012b6 <devcons_write+0x46>
		m = n - tot;
  801289:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80128e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801291:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801296:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801299:	83 ec 04             	sub    $0x4,%esp
  80129c:	53                   	push   %ebx
  80129d:	03 45 0c             	add    0xc(%ebp),%eax
  8012a0:	50                   	push   %eax
  8012a1:	57                   	push   %edi
  8012a2:	e8 18 09 00 00       	call   801bbf <memmove>
		sys_cputs(buf, m);
  8012a7:	83 c4 08             	add    $0x8,%esp
  8012aa:	53                   	push   %ebx
  8012ab:	57                   	push   %edi
  8012ac:	e8 26 ee ff ff       	call   8000d7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012b1:	01 de                	add    %ebx,%esi
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	89 f0                	mov    %esi,%eax
  8012b8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8012bb:	72 cc                	jb     801289 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8012bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8012d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8012d4:	74 2a                	je     801300 <devcons_read+0x3b>
  8012d6:	eb 05                	jmp    8012dd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8012d8:	e8 97 ee ff ff       	call   800174 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8012dd:	e8 13 ee ff ff       	call   8000f5 <sys_cgetc>
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	74 f2                	je     8012d8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	78 16                	js     801300 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8012ea:	83 f8 04             	cmp    $0x4,%eax
  8012ed:	74 0c                	je     8012fb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8012ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f2:	88 02                	mov    %al,(%edx)
	return 1;
  8012f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012f9:	eb 05                	jmp    801300 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8012fb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801308:	8b 45 08             	mov    0x8(%ebp),%eax
  80130b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80130e:	6a 01                	push   $0x1
  801310:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801313:	50                   	push   %eax
  801314:	e8 be ed ff ff       	call   8000d7 <sys_cputs>
}
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <getchar>:

int
getchar(void)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801324:	6a 01                	push   $0x1
  801326:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801329:	50                   	push   %eax
  80132a:	6a 00                	push   $0x0
  80132c:	e8 87 f6 ff ff       	call   8009b8 <read>
	if (r < 0)
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 0f                	js     801347 <getchar+0x29>
		return r;
	if (r < 1)
  801338:	85 c0                	test   %eax,%eax
  80133a:	7e 06                	jle    801342 <getchar+0x24>
		return -E_EOF;
	return c;
  80133c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801340:	eb 05                	jmp    801347 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801342:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801347:	c9                   	leave  
  801348:	c3                   	ret    

00801349 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801349:	55                   	push   %ebp
  80134a:	89 e5                	mov    %esp,%ebp
  80134c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	ff 75 08             	pushl  0x8(%ebp)
  801356:	e8 f7 f3 ff ff       	call   800752 <fd_lookup>
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 11                	js     801373 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801362:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801365:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80136b:	39 10                	cmp    %edx,(%eax)
  80136d:	0f 94 c0             	sete   %al
  801370:	0f b6 c0             	movzbl %al,%eax
}
  801373:	c9                   	leave  
  801374:	c3                   	ret    

00801375 <opencons>:

int
opencons(void)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80137b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	e8 7f f3 ff ff       	call   800703 <fd_alloc>
  801384:	83 c4 10             	add    $0x10,%esp
		return r;
  801387:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801389:	85 c0                	test   %eax,%eax
  80138b:	78 3e                	js     8013cb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	68 07 04 00 00       	push   $0x407
  801395:	ff 75 f4             	pushl  -0xc(%ebp)
  801398:	6a 00                	push   $0x0
  80139a:	e8 f4 ed ff ff       	call   800193 <sys_page_alloc>
  80139f:	83 c4 10             	add    $0x10,%esp
		return r;
  8013a2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 23                	js     8013cb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013a8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8013bd:	83 ec 0c             	sub    $0xc,%esp
  8013c0:	50                   	push   %eax
  8013c1:	e8 16 f3 ff ff       	call   8006dc <fd2num>
  8013c6:	89 c2                	mov    %eax,%edx
  8013c8:	83 c4 10             	add    $0x10,%esp
}
  8013cb:	89 d0                	mov    %edx,%eax
  8013cd:	c9                   	leave  
  8013ce:	c3                   	ret    

008013cf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013cf:	55                   	push   %ebp
  8013d0:	89 e5                	mov    %esp,%ebp
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8013d4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013d7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8013dd:	e8 73 ed ff ff       	call   800155 <sys_getenvid>
  8013e2:	83 ec 0c             	sub    $0xc,%esp
  8013e5:	ff 75 0c             	pushl  0xc(%ebp)
  8013e8:	ff 75 08             	pushl  0x8(%ebp)
  8013eb:	56                   	push   %esi
  8013ec:	50                   	push   %eax
  8013ed:	68 80 23 80 00       	push   $0x802380
  8013f2:	e8 b1 00 00 00       	call   8014a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013f7:	83 c4 18             	add    $0x18,%esp
  8013fa:	53                   	push   %ebx
  8013fb:	ff 75 10             	pushl  0x10(%ebp)
  8013fe:	e8 54 00 00 00       	call   801457 <vcprintf>
	cprintf("\n");
  801403:	c7 04 24 6b 23 80 00 	movl   $0x80236b,(%esp)
  80140a:	e8 99 00 00 00       	call   8014a8 <cprintf>
  80140f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801412:	cc                   	int3   
  801413:	eb fd                	jmp    801412 <_panic+0x43>

00801415 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	53                   	push   %ebx
  801419:	83 ec 04             	sub    $0x4,%esp
  80141c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80141f:	8b 13                	mov    (%ebx),%edx
  801421:	8d 42 01             	lea    0x1(%edx),%eax
  801424:	89 03                	mov    %eax,(%ebx)
  801426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801429:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80142d:	3d ff 00 00 00       	cmp    $0xff,%eax
  801432:	75 1a                	jne    80144e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	68 ff 00 00 00       	push   $0xff
  80143c:	8d 43 08             	lea    0x8(%ebx),%eax
  80143f:	50                   	push   %eax
  801440:	e8 92 ec ff ff       	call   8000d7 <sys_cputs>
		b->idx = 0;
  801445:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80144b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80144e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801452:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801460:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801467:	00 00 00 
	b.cnt = 0;
  80146a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801471:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	ff 75 08             	pushl  0x8(%ebp)
  80147a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	68 15 14 80 00       	push   $0x801415
  801486:	e8 54 01 00 00       	call   8015df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80148b:	83 c4 08             	add    $0x8,%esp
  80148e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801494:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	e8 37 ec ff ff       	call   8000d7 <sys_cputs>

	return b.cnt;
}
  8014a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014b1:	50                   	push   %eax
  8014b2:	ff 75 08             	pushl  0x8(%ebp)
  8014b5:	e8 9d ff ff ff       	call   801457 <vcprintf>
	va_end(ap);

	return cnt;
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	57                   	push   %edi
  8014c0:	56                   	push   %esi
  8014c1:	53                   	push   %ebx
  8014c2:	83 ec 1c             	sub    $0x1c,%esp
  8014c5:	89 c7                	mov    %eax,%edi
  8014c7:	89 d6                	mov    %edx,%esi
  8014c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8014e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8014e3:	39 d3                	cmp    %edx,%ebx
  8014e5:	72 05                	jb     8014ec <printnum+0x30>
  8014e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8014ea:	77 45                	ja     801531 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014ec:	83 ec 0c             	sub    $0xc,%esp
  8014ef:	ff 75 18             	pushl  0x18(%ebp)
  8014f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8014f8:	53                   	push   %ebx
  8014f9:	ff 75 10             	pushl  0x10(%ebp)
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  801502:	ff 75 e0             	pushl  -0x20(%ebp)
  801505:	ff 75 dc             	pushl  -0x24(%ebp)
  801508:	ff 75 d8             	pushl  -0x28(%ebp)
  80150b:	e8 30 0a 00 00       	call   801f40 <__udivdi3>
  801510:	83 c4 18             	add    $0x18,%esp
  801513:	52                   	push   %edx
  801514:	50                   	push   %eax
  801515:	89 f2                	mov    %esi,%edx
  801517:	89 f8                	mov    %edi,%eax
  801519:	e8 9e ff ff ff       	call   8014bc <printnum>
  80151e:	83 c4 20             	add    $0x20,%esp
  801521:	eb 18                	jmp    80153b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	56                   	push   %esi
  801527:	ff 75 18             	pushl  0x18(%ebp)
  80152a:	ff d7                	call   *%edi
  80152c:	83 c4 10             	add    $0x10,%esp
  80152f:	eb 03                	jmp    801534 <printnum+0x78>
  801531:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801534:	83 eb 01             	sub    $0x1,%ebx
  801537:	85 db                	test   %ebx,%ebx
  801539:	7f e8                	jg     801523 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	56                   	push   %esi
  80153f:	83 ec 04             	sub    $0x4,%esp
  801542:	ff 75 e4             	pushl  -0x1c(%ebp)
  801545:	ff 75 e0             	pushl  -0x20(%ebp)
  801548:	ff 75 dc             	pushl  -0x24(%ebp)
  80154b:	ff 75 d8             	pushl  -0x28(%ebp)
  80154e:	e8 1d 0b 00 00       	call   802070 <__umoddi3>
  801553:	83 c4 14             	add    $0x14,%esp
  801556:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  80155d:	50                   	push   %eax
  80155e:	ff d7                	call   *%edi
}
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801566:	5b                   	pop    %ebx
  801567:	5e                   	pop    %esi
  801568:	5f                   	pop    %edi
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80156e:	83 fa 01             	cmp    $0x1,%edx
  801571:	7e 0e                	jle    801581 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801573:	8b 10                	mov    (%eax),%edx
  801575:	8d 4a 08             	lea    0x8(%edx),%ecx
  801578:	89 08                	mov    %ecx,(%eax)
  80157a:	8b 02                	mov    (%edx),%eax
  80157c:	8b 52 04             	mov    0x4(%edx),%edx
  80157f:	eb 22                	jmp    8015a3 <getuint+0x38>
	else if (lflag)
  801581:	85 d2                	test   %edx,%edx
  801583:	74 10                	je     801595 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801585:	8b 10                	mov    (%eax),%edx
  801587:	8d 4a 04             	lea    0x4(%edx),%ecx
  80158a:	89 08                	mov    %ecx,(%eax)
  80158c:	8b 02                	mov    (%edx),%eax
  80158e:	ba 00 00 00 00       	mov    $0x0,%edx
  801593:	eb 0e                	jmp    8015a3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801595:	8b 10                	mov    (%eax),%edx
  801597:	8d 4a 04             	lea    0x4(%edx),%ecx
  80159a:	89 08                	mov    %ecx,(%eax)
  80159c:	8b 02                	mov    (%edx),%eax
  80159e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015af:	8b 10                	mov    (%eax),%edx
  8015b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8015b4:	73 0a                	jae    8015c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8015b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015b9:	89 08                	mov    %ecx,(%eax)
  8015bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015be:	88 02                	mov    %al,(%edx)
}
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    

008015c2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8015c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015cb:	50                   	push   %eax
  8015cc:	ff 75 10             	pushl  0x10(%ebp)
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	ff 75 08             	pushl  0x8(%ebp)
  8015d5:	e8 05 00 00 00       	call   8015df <vprintfmt>
	va_end(ap);
}
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	57                   	push   %edi
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	83 ec 2c             	sub    $0x2c,%esp
  8015e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8015eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015f1:	eb 12                	jmp    801605 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	0f 84 89 03 00 00    	je     801984 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	50                   	push   %eax
  801600:	ff d6                	call   *%esi
  801602:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801605:	83 c7 01             	add    $0x1,%edi
  801608:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80160c:	83 f8 25             	cmp    $0x25,%eax
  80160f:	75 e2                	jne    8015f3 <vprintfmt+0x14>
  801611:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801615:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80161c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801623:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80162a:	ba 00 00 00 00       	mov    $0x0,%edx
  80162f:	eb 07                	jmp    801638 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801631:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801634:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801638:	8d 47 01             	lea    0x1(%edi),%eax
  80163b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80163e:	0f b6 07             	movzbl (%edi),%eax
  801641:	0f b6 c8             	movzbl %al,%ecx
  801644:	83 e8 23             	sub    $0x23,%eax
  801647:	3c 55                	cmp    $0x55,%al
  801649:	0f 87 1a 03 00 00    	ja     801969 <vprintfmt+0x38a>
  80164f:	0f b6 c0             	movzbl %al,%eax
  801652:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  801659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80165c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801660:	eb d6                	jmp    801638 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801665:	b8 00 00 00 00       	mov    $0x0,%eax
  80166a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80166d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801670:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801674:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801677:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80167a:	83 fa 09             	cmp    $0x9,%edx
  80167d:	77 39                	ja     8016b8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80167f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801682:	eb e9                	jmp    80166d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801684:	8b 45 14             	mov    0x14(%ebp),%eax
  801687:	8d 48 04             	lea    0x4(%eax),%ecx
  80168a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80168d:	8b 00                	mov    (%eax),%eax
  80168f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801695:	eb 27                	jmp    8016be <vprintfmt+0xdf>
  801697:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80169a:	85 c0                	test   %eax,%eax
  80169c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016a1:	0f 49 c8             	cmovns %eax,%ecx
  8016a4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016aa:	eb 8c                	jmp    801638 <vprintfmt+0x59>
  8016ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8016af:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016b6:	eb 80                	jmp    801638 <vprintfmt+0x59>
  8016b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016bb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8016be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016c2:	0f 89 70 ff ff ff    	jns    801638 <vprintfmt+0x59>
				width = precision, precision = -1;
  8016c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8016cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016d5:	e9 5e ff ff ff       	jmp    801638 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016da:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8016e0:	e9 53 ff ff ff       	jmp    801638 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8016e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8016e8:	8d 50 04             	lea    0x4(%eax),%edx
  8016eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ee:	83 ec 08             	sub    $0x8,%esp
  8016f1:	53                   	push   %ebx
  8016f2:	ff 30                	pushl  (%eax)
  8016f4:	ff d6                	call   *%esi
			break;
  8016f6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8016fc:	e9 04 ff ff ff       	jmp    801605 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801701:	8b 45 14             	mov    0x14(%ebp),%eax
  801704:	8d 50 04             	lea    0x4(%eax),%edx
  801707:	89 55 14             	mov    %edx,0x14(%ebp)
  80170a:	8b 00                	mov    (%eax),%eax
  80170c:	99                   	cltd   
  80170d:	31 d0                	xor    %edx,%eax
  80170f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801711:	83 f8 0f             	cmp    $0xf,%eax
  801714:	7f 0b                	jg     801721 <vprintfmt+0x142>
  801716:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  80171d:	85 d2                	test   %edx,%edx
  80171f:	75 18                	jne    801739 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801721:	50                   	push   %eax
  801722:	68 bb 23 80 00       	push   $0x8023bb
  801727:	53                   	push   %ebx
  801728:	56                   	push   %esi
  801729:	e8 94 fe ff ff       	call   8015c2 <printfmt>
  80172e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801734:	e9 cc fe ff ff       	jmp    801605 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801739:	52                   	push   %edx
  80173a:	68 39 23 80 00       	push   $0x802339
  80173f:	53                   	push   %ebx
  801740:	56                   	push   %esi
  801741:	e8 7c fe ff ff       	call   8015c2 <printfmt>
  801746:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801749:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80174c:	e9 b4 fe ff ff       	jmp    801605 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801751:	8b 45 14             	mov    0x14(%ebp),%eax
  801754:	8d 50 04             	lea    0x4(%eax),%edx
  801757:	89 55 14             	mov    %edx,0x14(%ebp)
  80175a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80175c:	85 ff                	test   %edi,%edi
  80175e:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  801763:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801766:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80176a:	0f 8e 94 00 00 00    	jle    801804 <vprintfmt+0x225>
  801770:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801774:	0f 84 98 00 00 00    	je     801812 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80177a:	83 ec 08             	sub    $0x8,%esp
  80177d:	ff 75 d0             	pushl  -0x30(%ebp)
  801780:	57                   	push   %edi
  801781:	e8 86 02 00 00       	call   801a0c <strnlen>
  801786:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801789:	29 c1                	sub    %eax,%ecx
  80178b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80178e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801791:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801795:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801798:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80179b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80179d:	eb 0f                	jmp    8017ae <vprintfmt+0x1cf>
					putch(padc, putdat);
  80179f:	83 ec 08             	sub    $0x8,%esp
  8017a2:	53                   	push   %ebx
  8017a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8017a6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017a8:	83 ef 01             	sub    $0x1,%edi
  8017ab:	83 c4 10             	add    $0x10,%esp
  8017ae:	85 ff                	test   %edi,%edi
  8017b0:	7f ed                	jg     80179f <vprintfmt+0x1c0>
  8017b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017b5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8017b8:	85 c9                	test   %ecx,%ecx
  8017ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bf:	0f 49 c1             	cmovns %ecx,%eax
  8017c2:	29 c1                	sub    %eax,%ecx
  8017c4:	89 75 08             	mov    %esi,0x8(%ebp)
  8017c7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017ca:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017cd:	89 cb                	mov    %ecx,%ebx
  8017cf:	eb 4d                	jmp    80181e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017d5:	74 1b                	je     8017f2 <vprintfmt+0x213>
  8017d7:	0f be c0             	movsbl %al,%eax
  8017da:	83 e8 20             	sub    $0x20,%eax
  8017dd:	83 f8 5e             	cmp    $0x5e,%eax
  8017e0:	76 10                	jbe    8017f2 <vprintfmt+0x213>
					putch('?', putdat);
  8017e2:	83 ec 08             	sub    $0x8,%esp
  8017e5:	ff 75 0c             	pushl  0xc(%ebp)
  8017e8:	6a 3f                	push   $0x3f
  8017ea:	ff 55 08             	call   *0x8(%ebp)
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	eb 0d                	jmp    8017ff <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	ff 75 0c             	pushl  0xc(%ebp)
  8017f8:	52                   	push   %edx
  8017f9:	ff 55 08             	call   *0x8(%ebp)
  8017fc:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017ff:	83 eb 01             	sub    $0x1,%ebx
  801802:	eb 1a                	jmp    80181e <vprintfmt+0x23f>
  801804:	89 75 08             	mov    %esi,0x8(%ebp)
  801807:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80180a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80180d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801810:	eb 0c                	jmp    80181e <vprintfmt+0x23f>
  801812:	89 75 08             	mov    %esi,0x8(%ebp)
  801815:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801818:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80181b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80181e:	83 c7 01             	add    $0x1,%edi
  801821:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801825:	0f be d0             	movsbl %al,%edx
  801828:	85 d2                	test   %edx,%edx
  80182a:	74 23                	je     80184f <vprintfmt+0x270>
  80182c:	85 f6                	test   %esi,%esi
  80182e:	78 a1                	js     8017d1 <vprintfmt+0x1f2>
  801830:	83 ee 01             	sub    $0x1,%esi
  801833:	79 9c                	jns    8017d1 <vprintfmt+0x1f2>
  801835:	89 df                	mov    %ebx,%edi
  801837:	8b 75 08             	mov    0x8(%ebp),%esi
  80183a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80183d:	eb 18                	jmp    801857 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80183f:	83 ec 08             	sub    $0x8,%esp
  801842:	53                   	push   %ebx
  801843:	6a 20                	push   $0x20
  801845:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801847:	83 ef 01             	sub    $0x1,%edi
  80184a:	83 c4 10             	add    $0x10,%esp
  80184d:	eb 08                	jmp    801857 <vprintfmt+0x278>
  80184f:	89 df                	mov    %ebx,%edi
  801851:	8b 75 08             	mov    0x8(%ebp),%esi
  801854:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801857:	85 ff                	test   %edi,%edi
  801859:	7f e4                	jg     80183f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80185e:	e9 a2 fd ff ff       	jmp    801605 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801863:	83 fa 01             	cmp    $0x1,%edx
  801866:	7e 16                	jle    80187e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801868:	8b 45 14             	mov    0x14(%ebp),%eax
  80186b:	8d 50 08             	lea    0x8(%eax),%edx
  80186e:	89 55 14             	mov    %edx,0x14(%ebp)
  801871:	8b 50 04             	mov    0x4(%eax),%edx
  801874:	8b 00                	mov    (%eax),%eax
  801876:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801879:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80187c:	eb 32                	jmp    8018b0 <vprintfmt+0x2d1>
	else if (lflag)
  80187e:	85 d2                	test   %edx,%edx
  801880:	74 18                	je     80189a <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801882:	8b 45 14             	mov    0x14(%ebp),%eax
  801885:	8d 50 04             	lea    0x4(%eax),%edx
  801888:	89 55 14             	mov    %edx,0x14(%ebp)
  80188b:	8b 00                	mov    (%eax),%eax
  80188d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801890:	89 c1                	mov    %eax,%ecx
  801892:	c1 f9 1f             	sar    $0x1f,%ecx
  801895:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801898:	eb 16                	jmp    8018b0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80189a:	8b 45 14             	mov    0x14(%ebp),%eax
  80189d:	8d 50 04             	lea    0x4(%eax),%edx
  8018a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a3:	8b 00                	mov    (%eax),%eax
  8018a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018a8:	89 c1                	mov    %eax,%ecx
  8018aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8018ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8018b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8018b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8018bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8018bf:	79 74                	jns    801935 <vprintfmt+0x356>
				putch('-', putdat);
  8018c1:	83 ec 08             	sub    $0x8,%esp
  8018c4:	53                   	push   %ebx
  8018c5:	6a 2d                	push   $0x2d
  8018c7:	ff d6                	call   *%esi
				num = -(long long) num;
  8018c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8018cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018cf:	f7 d8                	neg    %eax
  8018d1:	83 d2 00             	adc    $0x0,%edx
  8018d4:	f7 da                	neg    %edx
  8018d6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8018d9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8018de:	eb 55                	jmp    801935 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018e0:	8d 45 14             	lea    0x14(%ebp),%eax
  8018e3:	e8 83 fc ff ff       	call   80156b <getuint>
			base = 10;
  8018e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8018ed:	eb 46                	jmp    801935 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8018ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8018f2:	e8 74 fc ff ff       	call   80156b <getuint>
			base = 8;
  8018f7:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8018fc:	eb 37                	jmp    801935 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	53                   	push   %ebx
  801902:	6a 30                	push   $0x30
  801904:	ff d6                	call   *%esi
			putch('x', putdat);
  801906:	83 c4 08             	add    $0x8,%esp
  801909:	53                   	push   %ebx
  80190a:	6a 78                	push   $0x78
  80190c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80190e:	8b 45 14             	mov    0x14(%ebp),%eax
  801911:	8d 50 04             	lea    0x4(%eax),%edx
  801914:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801917:	8b 00                	mov    (%eax),%eax
  801919:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80191e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801921:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801926:	eb 0d                	jmp    801935 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801928:	8d 45 14             	lea    0x14(%ebp),%eax
  80192b:	e8 3b fc ff ff       	call   80156b <getuint>
			base = 16;
  801930:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801935:	83 ec 0c             	sub    $0xc,%esp
  801938:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80193c:	57                   	push   %edi
  80193d:	ff 75 e0             	pushl  -0x20(%ebp)
  801940:	51                   	push   %ecx
  801941:	52                   	push   %edx
  801942:	50                   	push   %eax
  801943:	89 da                	mov    %ebx,%edx
  801945:	89 f0                	mov    %esi,%eax
  801947:	e8 70 fb ff ff       	call   8014bc <printnum>
			break;
  80194c:	83 c4 20             	add    $0x20,%esp
  80194f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801952:	e9 ae fc ff ff       	jmp    801605 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801957:	83 ec 08             	sub    $0x8,%esp
  80195a:	53                   	push   %ebx
  80195b:	51                   	push   %ecx
  80195c:	ff d6                	call   *%esi
			break;
  80195e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801961:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801964:	e9 9c fc ff ff       	jmp    801605 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801969:	83 ec 08             	sub    $0x8,%esp
  80196c:	53                   	push   %ebx
  80196d:	6a 25                	push   $0x25
  80196f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	eb 03                	jmp    801979 <vprintfmt+0x39a>
  801976:	83 ef 01             	sub    $0x1,%edi
  801979:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80197d:	75 f7                	jne    801976 <vprintfmt+0x397>
  80197f:	e9 81 fc ff ff       	jmp    801605 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801984:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801987:	5b                   	pop    %ebx
  801988:	5e                   	pop    %esi
  801989:	5f                   	pop    %edi
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	83 ec 18             	sub    $0x18,%esp
  801992:	8b 45 08             	mov    0x8(%ebp),%eax
  801995:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801998:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80199b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80199f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	74 26                	je     8019d3 <vsnprintf+0x47>
  8019ad:	85 d2                	test   %edx,%edx
  8019af:	7e 22                	jle    8019d3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019b1:	ff 75 14             	pushl  0x14(%ebp)
  8019b4:	ff 75 10             	pushl  0x10(%ebp)
  8019b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019ba:	50                   	push   %eax
  8019bb:	68 a5 15 80 00       	push   $0x8015a5
  8019c0:	e8 1a fc ff ff       	call   8015df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	eb 05                	jmp    8019d8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8019d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8019d8:	c9                   	leave  
  8019d9:	c3                   	ret    

008019da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8019e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8019e3:	50                   	push   %eax
  8019e4:	ff 75 10             	pushl  0x10(%ebp)
  8019e7:	ff 75 0c             	pushl  0xc(%ebp)
  8019ea:	ff 75 08             	pushl  0x8(%ebp)
  8019ed:	e8 9a ff ff ff       	call   80198c <vsnprintf>
	va_end(ap);

	return rc;
}
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8019fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ff:	eb 03                	jmp    801a04 <strlen+0x10>
		n++;
  801a01:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a04:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a08:	75 f7                	jne    801a01 <strlen+0xd>
		n++;
	return n;
}
  801a0a:	5d                   	pop    %ebp
  801a0b:	c3                   	ret    

00801a0c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a12:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a15:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1a:	eb 03                	jmp    801a1f <strnlen+0x13>
		n++;
  801a1c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a1f:	39 c2                	cmp    %eax,%edx
  801a21:	74 08                	je     801a2b <strnlen+0x1f>
  801a23:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a27:	75 f3                	jne    801a1c <strnlen+0x10>
  801a29:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    

00801a2d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	53                   	push   %ebx
  801a31:	8b 45 08             	mov    0x8(%ebp),%eax
  801a34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a37:	89 c2                	mov    %eax,%edx
  801a39:	83 c2 01             	add    $0x1,%edx
  801a3c:	83 c1 01             	add    $0x1,%ecx
  801a3f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a43:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a46:	84 db                	test   %bl,%bl
  801a48:	75 ef                	jne    801a39 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a4a:	5b                   	pop    %ebx
  801a4b:	5d                   	pop    %ebp
  801a4c:	c3                   	ret    

00801a4d <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a4d:	55                   	push   %ebp
  801a4e:	89 e5                	mov    %esp,%ebp
  801a50:	53                   	push   %ebx
  801a51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801a54:	53                   	push   %ebx
  801a55:	e8 9a ff ff ff       	call   8019f4 <strlen>
  801a5a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801a5d:	ff 75 0c             	pushl  0xc(%ebp)
  801a60:	01 d8                	add    %ebx,%eax
  801a62:	50                   	push   %eax
  801a63:	e8 c5 ff ff ff       	call   801a2d <strcpy>
	return dst;
}
  801a68:	89 d8                	mov    %ebx,%eax
  801a6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	56                   	push   %esi
  801a73:	53                   	push   %ebx
  801a74:	8b 75 08             	mov    0x8(%ebp),%esi
  801a77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a7a:	89 f3                	mov    %esi,%ebx
  801a7c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a7f:	89 f2                	mov    %esi,%edx
  801a81:	eb 0f                	jmp    801a92 <strncpy+0x23>
		*dst++ = *src;
  801a83:	83 c2 01             	add    $0x1,%edx
  801a86:	0f b6 01             	movzbl (%ecx),%eax
  801a89:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801a8c:	80 39 01             	cmpb   $0x1,(%ecx)
  801a8f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801a92:	39 da                	cmp    %ebx,%edx
  801a94:	75 ed                	jne    801a83 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801a96:	89 f0                	mov    %esi,%eax
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	8b 75 08             	mov    0x8(%ebp),%esi
  801aa4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801aa7:	8b 55 10             	mov    0x10(%ebp),%edx
  801aaa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801aac:	85 d2                	test   %edx,%edx
  801aae:	74 21                	je     801ad1 <strlcpy+0x35>
  801ab0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801ab4:	89 f2                	mov    %esi,%edx
  801ab6:	eb 09                	jmp    801ac1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801ab8:	83 c2 01             	add    $0x1,%edx
  801abb:	83 c1 01             	add    $0x1,%ecx
  801abe:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801ac1:	39 c2                	cmp    %eax,%edx
  801ac3:	74 09                	je     801ace <strlcpy+0x32>
  801ac5:	0f b6 19             	movzbl (%ecx),%ebx
  801ac8:	84 db                	test   %bl,%bl
  801aca:	75 ec                	jne    801ab8 <strlcpy+0x1c>
  801acc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801ace:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801ad1:	29 f0                	sub    %esi,%eax
}
  801ad3:	5b                   	pop    %ebx
  801ad4:	5e                   	pop    %esi
  801ad5:	5d                   	pop    %ebp
  801ad6:	c3                   	ret    

00801ad7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ad7:	55                   	push   %ebp
  801ad8:	89 e5                	mov    %esp,%ebp
  801ada:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801add:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ae0:	eb 06                	jmp    801ae8 <strcmp+0x11>
		p++, q++;
  801ae2:	83 c1 01             	add    $0x1,%ecx
  801ae5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ae8:	0f b6 01             	movzbl (%ecx),%eax
  801aeb:	84 c0                	test   %al,%al
  801aed:	74 04                	je     801af3 <strcmp+0x1c>
  801aef:	3a 02                	cmp    (%edx),%al
  801af1:	74 ef                	je     801ae2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801af3:	0f b6 c0             	movzbl %al,%eax
  801af6:	0f b6 12             	movzbl (%edx),%edx
  801af9:	29 d0                	sub    %edx,%eax
}
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    

00801afd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801afd:	55                   	push   %ebp
  801afe:	89 e5                	mov    %esp,%ebp
  801b00:	53                   	push   %ebx
  801b01:	8b 45 08             	mov    0x8(%ebp),%eax
  801b04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b07:	89 c3                	mov    %eax,%ebx
  801b09:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b0c:	eb 06                	jmp    801b14 <strncmp+0x17>
		n--, p++, q++;
  801b0e:	83 c0 01             	add    $0x1,%eax
  801b11:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b14:	39 d8                	cmp    %ebx,%eax
  801b16:	74 15                	je     801b2d <strncmp+0x30>
  801b18:	0f b6 08             	movzbl (%eax),%ecx
  801b1b:	84 c9                	test   %cl,%cl
  801b1d:	74 04                	je     801b23 <strncmp+0x26>
  801b1f:	3a 0a                	cmp    (%edx),%cl
  801b21:	74 eb                	je     801b0e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b23:	0f b6 00             	movzbl (%eax),%eax
  801b26:	0f b6 12             	movzbl (%edx),%edx
  801b29:	29 d0                	sub    %edx,%eax
  801b2b:	eb 05                	jmp    801b32 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b32:	5b                   	pop    %ebx
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b3f:	eb 07                	jmp    801b48 <strchr+0x13>
		if (*s == c)
  801b41:	38 ca                	cmp    %cl,%dl
  801b43:	74 0f                	je     801b54 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b45:	83 c0 01             	add    $0x1,%eax
  801b48:	0f b6 10             	movzbl (%eax),%edx
  801b4b:	84 d2                	test   %dl,%dl
  801b4d:	75 f2                	jne    801b41 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b60:	eb 03                	jmp    801b65 <strfind+0xf>
  801b62:	83 c0 01             	add    $0x1,%eax
  801b65:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801b68:	38 ca                	cmp    %cl,%dl
  801b6a:	74 04                	je     801b70 <strfind+0x1a>
  801b6c:	84 d2                	test   %dl,%dl
  801b6e:	75 f2                	jne    801b62 <strfind+0xc>
			break;
	return (char *) s;
}
  801b70:	5d                   	pop    %ebp
  801b71:	c3                   	ret    

00801b72 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	57                   	push   %edi
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801b7e:	85 c9                	test   %ecx,%ecx
  801b80:	74 36                	je     801bb8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801b82:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801b88:	75 28                	jne    801bb2 <memset+0x40>
  801b8a:	f6 c1 03             	test   $0x3,%cl
  801b8d:	75 23                	jne    801bb2 <memset+0x40>
		c &= 0xFF;
  801b8f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801b93:	89 d3                	mov    %edx,%ebx
  801b95:	c1 e3 08             	shl    $0x8,%ebx
  801b98:	89 d6                	mov    %edx,%esi
  801b9a:	c1 e6 18             	shl    $0x18,%esi
  801b9d:	89 d0                	mov    %edx,%eax
  801b9f:	c1 e0 10             	shl    $0x10,%eax
  801ba2:	09 f0                	or     %esi,%eax
  801ba4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801ba6:	89 d8                	mov    %ebx,%eax
  801ba8:	09 d0                	or     %edx,%eax
  801baa:	c1 e9 02             	shr    $0x2,%ecx
  801bad:	fc                   	cld    
  801bae:	f3 ab                	rep stos %eax,%es:(%edi)
  801bb0:	eb 06                	jmp    801bb8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb5:	fc                   	cld    
  801bb6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801bb8:	89 f8                	mov    %edi,%eax
  801bba:	5b                   	pop    %ebx
  801bbb:	5e                   	pop    %esi
  801bbc:	5f                   	pop    %edi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    

00801bbf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	57                   	push   %edi
  801bc3:	56                   	push   %esi
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801bcd:	39 c6                	cmp    %eax,%esi
  801bcf:	73 35                	jae    801c06 <memmove+0x47>
  801bd1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801bd4:	39 d0                	cmp    %edx,%eax
  801bd6:	73 2e                	jae    801c06 <memmove+0x47>
		s += n;
		d += n;
  801bd8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801bdb:	89 d6                	mov    %edx,%esi
  801bdd:	09 fe                	or     %edi,%esi
  801bdf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801be5:	75 13                	jne    801bfa <memmove+0x3b>
  801be7:	f6 c1 03             	test   $0x3,%cl
  801bea:	75 0e                	jne    801bfa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801bec:	83 ef 04             	sub    $0x4,%edi
  801bef:	8d 72 fc             	lea    -0x4(%edx),%esi
  801bf2:	c1 e9 02             	shr    $0x2,%ecx
  801bf5:	fd                   	std    
  801bf6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801bf8:	eb 09                	jmp    801c03 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801bfa:	83 ef 01             	sub    $0x1,%edi
  801bfd:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c00:	fd                   	std    
  801c01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c03:	fc                   	cld    
  801c04:	eb 1d                	jmp    801c23 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c06:	89 f2                	mov    %esi,%edx
  801c08:	09 c2                	or     %eax,%edx
  801c0a:	f6 c2 03             	test   $0x3,%dl
  801c0d:	75 0f                	jne    801c1e <memmove+0x5f>
  801c0f:	f6 c1 03             	test   $0x3,%cl
  801c12:	75 0a                	jne    801c1e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c14:	c1 e9 02             	shr    $0x2,%ecx
  801c17:	89 c7                	mov    %eax,%edi
  801c19:	fc                   	cld    
  801c1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c1c:	eb 05                	jmp    801c23 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c1e:	89 c7                	mov    %eax,%edi
  801c20:	fc                   	cld    
  801c21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c23:	5e                   	pop    %esi
  801c24:	5f                   	pop    %edi
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c2a:	ff 75 10             	pushl  0x10(%ebp)
  801c2d:	ff 75 0c             	pushl  0xc(%ebp)
  801c30:	ff 75 08             	pushl  0x8(%ebp)
  801c33:	e8 87 ff ff ff       	call   801bbf <memmove>
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	56                   	push   %esi
  801c3e:	53                   	push   %ebx
  801c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c45:	89 c6                	mov    %eax,%esi
  801c47:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c4a:	eb 1a                	jmp    801c66 <memcmp+0x2c>
		if (*s1 != *s2)
  801c4c:	0f b6 08             	movzbl (%eax),%ecx
  801c4f:	0f b6 1a             	movzbl (%edx),%ebx
  801c52:	38 d9                	cmp    %bl,%cl
  801c54:	74 0a                	je     801c60 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801c56:	0f b6 c1             	movzbl %cl,%eax
  801c59:	0f b6 db             	movzbl %bl,%ebx
  801c5c:	29 d8                	sub    %ebx,%eax
  801c5e:	eb 0f                	jmp    801c6f <memcmp+0x35>
		s1++, s2++;
  801c60:	83 c0 01             	add    $0x1,%eax
  801c63:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c66:	39 f0                	cmp    %esi,%eax
  801c68:	75 e2                	jne    801c4c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801c6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5d                   	pop    %ebp
  801c72:	c3                   	ret    

00801c73 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801c73:	55                   	push   %ebp
  801c74:	89 e5                	mov    %esp,%ebp
  801c76:	53                   	push   %ebx
  801c77:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801c7a:	89 c1                	mov    %eax,%ecx
  801c7c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801c7f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c83:	eb 0a                	jmp    801c8f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801c85:	0f b6 10             	movzbl (%eax),%edx
  801c88:	39 da                	cmp    %ebx,%edx
  801c8a:	74 07                	je     801c93 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801c8c:	83 c0 01             	add    $0x1,%eax
  801c8f:	39 c8                	cmp    %ecx,%eax
  801c91:	72 f2                	jb     801c85 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801c93:	5b                   	pop    %ebx
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    

00801c96 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	57                   	push   %edi
  801c9a:	56                   	push   %esi
  801c9b:	53                   	push   %ebx
  801c9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ca2:	eb 03                	jmp    801ca7 <strtol+0x11>
		s++;
  801ca4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ca7:	0f b6 01             	movzbl (%ecx),%eax
  801caa:	3c 20                	cmp    $0x20,%al
  801cac:	74 f6                	je     801ca4 <strtol+0xe>
  801cae:	3c 09                	cmp    $0x9,%al
  801cb0:	74 f2                	je     801ca4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801cb2:	3c 2b                	cmp    $0x2b,%al
  801cb4:	75 0a                	jne    801cc0 <strtol+0x2a>
		s++;
  801cb6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801cb9:	bf 00 00 00 00       	mov    $0x0,%edi
  801cbe:	eb 11                	jmp    801cd1 <strtol+0x3b>
  801cc0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801cc5:	3c 2d                	cmp    $0x2d,%al
  801cc7:	75 08                	jne    801cd1 <strtol+0x3b>
		s++, neg = 1;
  801cc9:	83 c1 01             	add    $0x1,%ecx
  801ccc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801cd1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801cd7:	75 15                	jne    801cee <strtol+0x58>
  801cd9:	80 39 30             	cmpb   $0x30,(%ecx)
  801cdc:	75 10                	jne    801cee <strtol+0x58>
  801cde:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ce2:	75 7c                	jne    801d60 <strtol+0xca>
		s += 2, base = 16;
  801ce4:	83 c1 02             	add    $0x2,%ecx
  801ce7:	bb 10 00 00 00       	mov    $0x10,%ebx
  801cec:	eb 16                	jmp    801d04 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801cee:	85 db                	test   %ebx,%ebx
  801cf0:	75 12                	jne    801d04 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801cf2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801cf7:	80 39 30             	cmpb   $0x30,(%ecx)
  801cfa:	75 08                	jne    801d04 <strtol+0x6e>
		s++, base = 8;
  801cfc:	83 c1 01             	add    $0x1,%ecx
  801cff:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
  801d09:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d0c:	0f b6 11             	movzbl (%ecx),%edx
  801d0f:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d12:	89 f3                	mov    %esi,%ebx
  801d14:	80 fb 09             	cmp    $0x9,%bl
  801d17:	77 08                	ja     801d21 <strtol+0x8b>
			dig = *s - '0';
  801d19:	0f be d2             	movsbl %dl,%edx
  801d1c:	83 ea 30             	sub    $0x30,%edx
  801d1f:	eb 22                	jmp    801d43 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d21:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d24:	89 f3                	mov    %esi,%ebx
  801d26:	80 fb 19             	cmp    $0x19,%bl
  801d29:	77 08                	ja     801d33 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d2b:	0f be d2             	movsbl %dl,%edx
  801d2e:	83 ea 57             	sub    $0x57,%edx
  801d31:	eb 10                	jmp    801d43 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d33:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d36:	89 f3                	mov    %esi,%ebx
  801d38:	80 fb 19             	cmp    $0x19,%bl
  801d3b:	77 16                	ja     801d53 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d3d:	0f be d2             	movsbl %dl,%edx
  801d40:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d43:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d46:	7d 0b                	jge    801d53 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d48:	83 c1 01             	add    $0x1,%ecx
  801d4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  801d4f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801d51:	eb b9                	jmp    801d0c <strtol+0x76>

	if (endptr)
  801d53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d57:	74 0d                	je     801d66 <strtol+0xd0>
		*endptr = (char *) s;
  801d59:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d5c:	89 0e                	mov    %ecx,(%esi)
  801d5e:	eb 06                	jmp    801d66 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d60:	85 db                	test   %ebx,%ebx
  801d62:	74 98                	je     801cfc <strtol+0x66>
  801d64:	eb 9e                	jmp    801d04 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801d66:	89 c2                	mov    %eax,%edx
  801d68:	f7 da                	neg    %edx
  801d6a:	85 ff                	test   %edi,%edi
  801d6c:	0f 45 c2             	cmovne %edx,%eax
}
  801d6f:	5b                   	pop    %ebx
  801d70:	5e                   	pop    %esi
  801d71:	5f                   	pop    %edi
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    

00801d74 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d7a:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d81:	75 2a                	jne    801dad <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801d83:	83 ec 04             	sub    $0x4,%esp
  801d86:	6a 07                	push   $0x7
  801d88:	68 00 f0 bf ee       	push   $0xeebff000
  801d8d:	6a 00                	push   $0x0
  801d8f:	e8 ff e3 ff ff       	call   800193 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	85 c0                	test   %eax,%eax
  801d99:	79 12                	jns    801dad <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801d9b:	50                   	push   %eax
  801d9c:	68 a0 26 80 00       	push   $0x8026a0
  801da1:	6a 23                	push   $0x23
  801da3:	68 a4 26 80 00       	push   $0x8026a4
  801da8:	e8 22 f6 ff ff       	call   8013cf <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dad:	8b 45 08             	mov    0x8(%ebp),%eax
  801db0:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801db5:	83 ec 08             	sub    $0x8,%esp
  801db8:	68 c4 03 80 00       	push   $0x8003c4
  801dbd:	6a 00                	push   $0x0
  801dbf:	e8 1a e5 ff ff       	call   8002de <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	79 12                	jns    801ddd <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801dcb:	50                   	push   %eax
  801dcc:	68 a0 26 80 00       	push   $0x8026a0
  801dd1:	6a 2c                	push   $0x2c
  801dd3:	68 a4 26 80 00       	push   $0x8026a4
  801dd8:	e8 f2 f5 ff ff       	call   8013cf <_panic>
	}
}
  801ddd:	c9                   	leave  
  801dde:	c3                   	ret    

00801ddf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	56                   	push   %esi
  801de3:	53                   	push   %ebx
  801de4:	8b 75 08             	mov    0x8(%ebp),%esi
  801de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801ded:	85 c0                	test   %eax,%eax
  801def:	75 12                	jne    801e03 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801df1:	83 ec 0c             	sub    $0xc,%esp
  801df4:	68 00 00 c0 ee       	push   $0xeec00000
  801df9:	e8 45 e5 ff ff       	call   800343 <sys_ipc_recv>
  801dfe:	83 c4 10             	add    $0x10,%esp
  801e01:	eb 0c                	jmp    801e0f <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e03:	83 ec 0c             	sub    $0xc,%esp
  801e06:	50                   	push   %eax
  801e07:	e8 37 e5 ff ff       	call   800343 <sys_ipc_recv>
  801e0c:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e0f:	85 f6                	test   %esi,%esi
  801e11:	0f 95 c1             	setne  %cl
  801e14:	85 db                	test   %ebx,%ebx
  801e16:	0f 95 c2             	setne  %dl
  801e19:	84 d1                	test   %dl,%cl
  801e1b:	74 09                	je     801e26 <ipc_recv+0x47>
  801e1d:	89 c2                	mov    %eax,%edx
  801e1f:	c1 ea 1f             	shr    $0x1f,%edx
  801e22:	84 d2                	test   %dl,%dl
  801e24:	75 2d                	jne    801e53 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e26:	85 f6                	test   %esi,%esi
  801e28:	74 0d                	je     801e37 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e2f:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
  801e35:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e37:	85 db                	test   %ebx,%ebx
  801e39:	74 0d                	je     801e48 <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e3b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e40:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
  801e46:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e48:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4d:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
}
  801e53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e56:	5b                   	pop    %ebx
  801e57:	5e                   	pop    %esi
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    

00801e5a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	57                   	push   %edi
  801e5e:	56                   	push   %esi
  801e5f:	53                   	push   %ebx
  801e60:	83 ec 0c             	sub    $0xc,%esp
  801e63:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e66:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801e6c:	85 db                	test   %ebx,%ebx
  801e6e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e73:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e76:	ff 75 14             	pushl  0x14(%ebp)
  801e79:	53                   	push   %ebx
  801e7a:	56                   	push   %esi
  801e7b:	57                   	push   %edi
  801e7c:	e8 9f e4 ff ff       	call   800320 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801e81:	89 c2                	mov    %eax,%edx
  801e83:	c1 ea 1f             	shr    $0x1f,%edx
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	84 d2                	test   %dl,%dl
  801e8b:	74 17                	je     801ea4 <ipc_send+0x4a>
  801e8d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e90:	74 12                	je     801ea4 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801e92:	50                   	push   %eax
  801e93:	68 b2 26 80 00       	push   $0x8026b2
  801e98:	6a 47                	push   $0x47
  801e9a:	68 c0 26 80 00       	push   $0x8026c0
  801e9f:	e8 2b f5 ff ff       	call   8013cf <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ea4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ea7:	75 07                	jne    801eb0 <ipc_send+0x56>
			sys_yield();
  801ea9:	e8 c6 e2 ff ff       	call   800174 <sys_yield>
  801eae:	eb c6                	jmp    801e76 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	75 c2                	jne    801e76 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801eb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eb7:	5b                   	pop    %ebx
  801eb8:	5e                   	pop    %esi
  801eb9:	5f                   	pop    %edi
  801eba:	5d                   	pop    %ebp
  801ebb:	c3                   	ret    

00801ebc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ec2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ec7:	69 d0 b0 00 00 00    	imul   $0xb0,%eax,%edx
  801ecd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ed3:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ed9:	39 ca                	cmp    %ecx,%edx
  801edb:	75 10                	jne    801eed <ipc_find_env+0x31>
			return envs[i].env_id;
  801edd:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
  801ee3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ee8:	8b 40 7c             	mov    0x7c(%eax),%eax
  801eeb:	eb 0f                	jmp    801efc <ipc_find_env+0x40>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eed:	83 c0 01             	add    $0x1,%eax
  801ef0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ef5:	75 d0                	jne    801ec7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ef7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801efc:	5d                   	pop    %ebp
  801efd:	c3                   	ret    

00801efe <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f04:	89 d0                	mov    %edx,%eax
  801f06:	c1 e8 16             	shr    $0x16,%eax
  801f09:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f15:	f6 c1 01             	test   $0x1,%cl
  801f18:	74 1d                	je     801f37 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f1a:	c1 ea 0c             	shr    $0xc,%edx
  801f1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f24:	f6 c2 01             	test   $0x1,%dl
  801f27:	74 0e                	je     801f37 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f29:	c1 ea 0c             	shr    $0xc,%edx
  801f2c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f33:	ef 
  801f34:	0f b7 c0             	movzwl %ax,%eax
}
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    
  801f39:	66 90                	xchg   %ax,%ax
  801f3b:	66 90                	xchg   %ax,%ax
  801f3d:	66 90                	xchg   %ax,%ax
  801f3f:	90                   	nop

00801f40 <__udivdi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 1c             	sub    $0x1c,%esp
  801f47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f57:	85 f6                	test   %esi,%esi
  801f59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5d:	89 ca                	mov    %ecx,%edx
  801f5f:	89 f8                	mov    %edi,%eax
  801f61:	75 3d                	jne    801fa0 <__udivdi3+0x60>
  801f63:	39 cf                	cmp    %ecx,%edi
  801f65:	0f 87 c5 00 00 00    	ja     802030 <__udivdi3+0xf0>
  801f6b:	85 ff                	test   %edi,%edi
  801f6d:	89 fd                	mov    %edi,%ebp
  801f6f:	75 0b                	jne    801f7c <__udivdi3+0x3c>
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
  801f76:	31 d2                	xor    %edx,%edx
  801f78:	f7 f7                	div    %edi
  801f7a:	89 c5                	mov    %eax,%ebp
  801f7c:	89 c8                	mov    %ecx,%eax
  801f7e:	31 d2                	xor    %edx,%edx
  801f80:	f7 f5                	div    %ebp
  801f82:	89 c1                	mov    %eax,%ecx
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	89 cf                	mov    %ecx,%edi
  801f88:	f7 f5                	div    %ebp
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	39 ce                	cmp    %ecx,%esi
  801fa2:	77 74                	ja     802018 <__udivdi3+0xd8>
  801fa4:	0f bd fe             	bsr    %esi,%edi
  801fa7:	83 f7 1f             	xor    $0x1f,%edi
  801faa:	0f 84 98 00 00 00    	je     802048 <__udivdi3+0x108>
  801fb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	89 c5                	mov    %eax,%ebp
  801fb9:	29 fb                	sub    %edi,%ebx
  801fbb:	d3 e6                	shl    %cl,%esi
  801fbd:	89 d9                	mov    %ebx,%ecx
  801fbf:	d3 ed                	shr    %cl,%ebp
  801fc1:	89 f9                	mov    %edi,%ecx
  801fc3:	d3 e0                	shl    %cl,%eax
  801fc5:	09 ee                	or     %ebp,%esi
  801fc7:	89 d9                	mov    %ebx,%ecx
  801fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcd:	89 d5                	mov    %edx,%ebp
  801fcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fd3:	d3 ed                	shr    %cl,%ebp
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e2                	shl    %cl,%edx
  801fd9:	89 d9                	mov    %ebx,%ecx
  801fdb:	d3 e8                	shr    %cl,%eax
  801fdd:	09 c2                	or     %eax,%edx
  801fdf:	89 d0                	mov    %edx,%eax
  801fe1:	89 ea                	mov    %ebp,%edx
  801fe3:	f7 f6                	div    %esi
  801fe5:	89 d5                	mov    %edx,%ebp
  801fe7:	89 c3                	mov    %eax,%ebx
  801fe9:	f7 64 24 0c          	mull   0xc(%esp)
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	72 10                	jb     802001 <__udivdi3+0xc1>
  801ff1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e6                	shl    %cl,%esi
  801ff9:	39 c6                	cmp    %eax,%esi
  801ffb:	73 07                	jae    802004 <__udivdi3+0xc4>
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	75 03                	jne    802004 <__udivdi3+0xc4>
  802001:	83 eb 01             	sub    $0x1,%ebx
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 d8                	mov    %ebx,%eax
  802008:	89 fa                	mov    %edi,%edx
  80200a:	83 c4 1c             	add    $0x1c,%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802018:	31 ff                	xor    %edi,%edi
  80201a:	31 db                	xor    %ebx,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 d8                	mov    %ebx,%eax
  802032:	f7 f7                	div    %edi
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 c3                	mov    %eax,%ebx
  802038:	89 d8                	mov    %ebx,%eax
  80203a:	89 fa                	mov    %edi,%edx
  80203c:	83 c4 1c             	add    $0x1c,%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	39 ce                	cmp    %ecx,%esi
  80204a:	72 0c                	jb     802058 <__udivdi3+0x118>
  80204c:	31 db                	xor    %ebx,%ebx
  80204e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802052:	0f 87 34 ff ff ff    	ja     801f8c <__udivdi3+0x4c>
  802058:	bb 01 00 00 00       	mov    $0x1,%ebx
  80205d:	e9 2a ff ff ff       	jmp    801f8c <__udivdi3+0x4c>
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80207b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80207f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 d2                	test   %edx,%edx
  802089:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80208d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802091:	89 f3                	mov    %esi,%ebx
  802093:	89 3c 24             	mov    %edi,(%esp)
  802096:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209a:	75 1c                	jne    8020b8 <__umoddi3+0x48>
  80209c:	39 f7                	cmp    %esi,%edi
  80209e:	76 50                	jbe    8020f0 <__umoddi3+0x80>
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	f7 f7                	div    %edi
  8020a6:	89 d0                	mov    %edx,%eax
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	39 f2                	cmp    %esi,%edx
  8020ba:	89 d0                	mov    %edx,%eax
  8020bc:	77 52                	ja     802110 <__umoddi3+0xa0>
  8020be:	0f bd ea             	bsr    %edx,%ebp
  8020c1:	83 f5 1f             	xor    $0x1f,%ebp
  8020c4:	75 5a                	jne    802120 <__umoddi3+0xb0>
  8020c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ca:	0f 82 e0 00 00 00    	jb     8021b0 <__umoddi3+0x140>
  8020d0:	39 0c 24             	cmp    %ecx,(%esp)
  8020d3:	0f 86 d7 00 00 00    	jbe    8021b0 <__umoddi3+0x140>
  8020d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020e1:	83 c4 1c             	add    $0x1c,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	85 ff                	test   %edi,%edi
  8020f2:	89 fd                	mov    %edi,%ebp
  8020f4:	75 0b                	jne    802101 <__umoddi3+0x91>
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f7                	div    %edi
  8020ff:	89 c5                	mov    %eax,%ebp
  802101:	89 f0                	mov    %esi,%eax
  802103:	31 d2                	xor    %edx,%edx
  802105:	f7 f5                	div    %ebp
  802107:	89 c8                	mov    %ecx,%eax
  802109:	f7 f5                	div    %ebp
  80210b:	89 d0                	mov    %edx,%eax
  80210d:	eb 99                	jmp    8020a8 <__umoddi3+0x38>
  80210f:	90                   	nop
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	8b 34 24             	mov    (%esp),%esi
  802123:	bf 20 00 00 00       	mov    $0x20,%edi
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	29 ef                	sub    %ebp,%edi
  80212c:	d3 e0                	shl    %cl,%eax
  80212e:	89 f9                	mov    %edi,%ecx
  802130:	89 f2                	mov    %esi,%edx
  802132:	d3 ea                	shr    %cl,%edx
  802134:	89 e9                	mov    %ebp,%ecx
  802136:	09 c2                	or     %eax,%edx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 14 24             	mov    %edx,(%esp)
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	d3 e2                	shl    %cl,%edx
  802141:	89 f9                	mov    %edi,%ecx
  802143:	89 54 24 04          	mov    %edx,0x4(%esp)
  802147:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	89 e9                	mov    %ebp,%ecx
  80214f:	89 c6                	mov    %eax,%esi
  802151:	d3 e3                	shl    %cl,%ebx
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 d0                	mov    %edx,%eax
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	09 d8                	or     %ebx,%eax
  80215d:	89 d3                	mov    %edx,%ebx
  80215f:	89 f2                	mov    %esi,%edx
  802161:	f7 34 24             	divl   (%esp)
  802164:	89 d6                	mov    %edx,%esi
  802166:	d3 e3                	shl    %cl,%ebx
  802168:	f7 64 24 04          	mull   0x4(%esp)
  80216c:	39 d6                	cmp    %edx,%esi
  80216e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802172:	89 d1                	mov    %edx,%ecx
  802174:	89 c3                	mov    %eax,%ebx
  802176:	72 08                	jb     802180 <__umoddi3+0x110>
  802178:	75 11                	jne    80218b <__umoddi3+0x11b>
  80217a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80217e:	73 0b                	jae    80218b <__umoddi3+0x11b>
  802180:	2b 44 24 04          	sub    0x4(%esp),%eax
  802184:	1b 14 24             	sbb    (%esp),%edx
  802187:	89 d1                	mov    %edx,%ecx
  802189:	89 c3                	mov    %eax,%ebx
  80218b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80218f:	29 da                	sub    %ebx,%edx
  802191:	19 ce                	sbb    %ecx,%esi
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 f0                	mov    %esi,%eax
  802197:	d3 e0                	shl    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	d3 ea                	shr    %cl,%edx
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	d3 ee                	shr    %cl,%esi
  8021a1:	09 d0                	or     %edx,%eax
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	83 c4 1c             	add    $0x1c,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	29 f9                	sub    %edi,%ecx
  8021b2:	19 d6                	sbb    %edx,%esi
  8021b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bc:	e9 18 ff ff ff       	jmp    8020d9 <__umoddi3+0x69>
