
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
  800039:	68 e4 03 80 00       	push   $0x8003e4
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
  800069:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
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
  8000c3:	e8 8a 0a 00 00       	call   800b52 <close_all>
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
  80013c:	68 8a 24 80 00       	push   $0x80248a
  800141:	6a 23                	push   $0x23
  800143:	68 a7 24 80 00       	push   $0x8024a7
  800148:	e8 36 15 00 00       	call   801683 <_panic>

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
  8001bd:	68 8a 24 80 00       	push   $0x80248a
  8001c2:	6a 23                	push   $0x23
  8001c4:	68 a7 24 80 00       	push   $0x8024a7
  8001c9:	e8 b5 14 00 00       	call   801683 <_panic>

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
  8001ff:	68 8a 24 80 00       	push   $0x80248a
  800204:	6a 23                	push   $0x23
  800206:	68 a7 24 80 00       	push   $0x8024a7
  80020b:	e8 73 14 00 00       	call   801683 <_panic>

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
  800241:	68 8a 24 80 00       	push   $0x80248a
  800246:	6a 23                	push   $0x23
  800248:	68 a7 24 80 00       	push   $0x8024a7
  80024d:	e8 31 14 00 00       	call   801683 <_panic>

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
  800283:	68 8a 24 80 00       	push   $0x80248a
  800288:	6a 23                	push   $0x23
  80028a:	68 a7 24 80 00       	push   $0x8024a7
  80028f:	e8 ef 13 00 00       	call   801683 <_panic>

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
  8002c5:	68 8a 24 80 00       	push   $0x80248a
  8002ca:	6a 23                	push   $0x23
  8002cc:	68 a7 24 80 00       	push   $0x8024a7
  8002d1:	e8 ad 13 00 00       	call   801683 <_panic>
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
  800307:	68 8a 24 80 00       	push   $0x80248a
  80030c:	6a 23                	push   $0x23
  80030e:	68 a7 24 80 00       	push   $0x8024a7
  800313:	e8 6b 13 00 00       	call   801683 <_panic>

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
  80036b:	68 8a 24 80 00       	push   $0x80248a
  800370:	6a 23                	push   $0x23
  800372:	68 a7 24 80 00       	push   $0x8024a7
  800377:	e8 07 13 00 00       	call   801683 <_panic>

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

008003c4 <sys_thread_join>:

void 	
sys_thread_join(envid_t envid) 
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	57                   	push   %edi
  8003c8:	56                   	push   %esi
  8003c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003cf:	b8 10 00 00 00       	mov    $0x10,%eax
  8003d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8003d7:	89 cb                	mov    %ecx,%ebx
  8003d9:	89 cf                	mov    %ecx,%edi
  8003db:	89 ce                	mov    %ecx,%esi
  8003dd:	cd 30                	int    $0x30

void 	
sys_thread_join(envid_t envid) 
{
	syscall(SYS_thread_join, 0, envid, 0, 0, 0, 0);
}
  8003df:	5b                   	pop    %ebx
  8003e0:	5e                   	pop    %esi
  8003e1:	5f                   	pop    %edi
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    

008003e4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003e4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003e5:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8003ea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003ec:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp), %ebx 	// utf_eip (eip in trap-time)
  8003ef:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	subl $0x4, 0x30(%esp)	// we will store return eip onto stack *in-trap-time*
  8003f3:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
				// so we need update orig esp (allocate space)
	movl 0x30(%esp), %eax 	// utf_esp (esp trap-time stack to return to)
  8003f8:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl %ebx, (%eax)	// we save the eip causing page fault
  8003fc:	89 18                	mov    %ebx,(%eax)
	addl $0x8, %esp		// skip utf_fault_va and utf_err
  8003fe:	83 c4 08             	add    $0x8,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal			// from utf_regs restore regs
  800401:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp 	// skip utf_eip, now saved above struct UTF
  800402:	83 c4 04             	add    $0x4,%esp
	popfl			// from utf_eflags restore eflags
  800405:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp		// from utf_esp restore original esp
  800406:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800407:	c3                   	ret    

00800408 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	53                   	push   %ebx
  80040c:	83 ec 04             	sub    $0x4,%esp
  80040f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800412:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) != FEC_WR || (uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW) {
  800414:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800418:	74 11                	je     80042b <pgfault+0x23>
  80041a:	89 d8                	mov    %ebx,%eax
  80041c:	c1 e8 0c             	shr    $0xc,%eax
  80041f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800426:	f6 c4 08             	test   $0x8,%ah
  800429:	75 14                	jne    80043f <pgfault+0x37>
		panic("faulting access");
  80042b:	83 ec 04             	sub    $0x4,%esp
  80042e:	68 b5 24 80 00       	push   $0x8024b5
  800433:	6a 1f                	push   $0x1f
  800435:	68 c5 24 80 00       	push   $0x8024c5
  80043a:	e8 44 12 00 00       	call   801683 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	r = sys_page_alloc(0, PFTEMP, PTE_P | PTE_W | PTE_U);
  80043f:	83 ec 04             	sub    $0x4,%esp
  800442:	6a 07                	push   $0x7
  800444:	68 00 f0 7f 00       	push   $0x7ff000
  800449:	6a 00                	push   $0x0
  80044b:	e8 43 fd ff ff       	call   800193 <sys_page_alloc>
	if (r < 0) {
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	85 c0                	test   %eax,%eax
  800455:	79 12                	jns    800469 <pgfault+0x61>
		panic("sys page alloc failed %e", r);
  800457:	50                   	push   %eax
  800458:	68 d0 24 80 00       	push   $0x8024d0
  80045d:	6a 2d                	push   $0x2d
  80045f:	68 c5 24 80 00       	push   $0x8024c5
  800464:	e8 1a 12 00 00       	call   801683 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800469:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	68 00 10 00 00       	push   $0x1000
  800477:	53                   	push   %ebx
  800478:	68 00 f0 7f 00       	push   $0x7ff000
  80047d:	e8 59 1a 00 00       	call   801edb <memcpy>

	r = sys_page_map(0, (void*)PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U);
  800482:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800489:	53                   	push   %ebx
  80048a:	6a 00                	push   $0x0
  80048c:	68 00 f0 7f 00       	push   $0x7ff000
  800491:	6a 00                	push   $0x0
  800493:	e8 3e fd ff ff       	call   8001d6 <sys_page_map>
	if (r < 0) {
  800498:	83 c4 20             	add    $0x20,%esp
  80049b:	85 c0                	test   %eax,%eax
  80049d:	79 12                	jns    8004b1 <pgfault+0xa9>
		panic("sys page alloc failed %e", r);
  80049f:	50                   	push   %eax
  8004a0:	68 d0 24 80 00       	push   $0x8024d0
  8004a5:	6a 34                	push   $0x34
  8004a7:	68 c5 24 80 00       	push   $0x8024c5
  8004ac:	e8 d2 11 00 00       	call   801683 <_panic>
	}
	r = sys_page_unmap(0, PFTEMP);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	68 00 f0 7f 00       	push   $0x7ff000
  8004b9:	6a 00                	push   $0x0
  8004bb:	e8 58 fd ff ff       	call   800218 <sys_page_unmap>
	if (r < 0) {
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	85 c0                	test   %eax,%eax
  8004c5:	79 12                	jns    8004d9 <pgfault+0xd1>
		panic("sys page alloc failed %e", r);
  8004c7:	50                   	push   %eax
  8004c8:	68 d0 24 80 00       	push   $0x8024d0
  8004cd:	6a 38                	push   $0x38
  8004cf:	68 c5 24 80 00       	push   $0x8024c5
  8004d4:	e8 aa 11 00 00       	call   801683 <_panic>
	}
	//panic("pgfault not implemented");
	return;
}
  8004d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    

008004de <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	57                   	push   %edi
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
  8004e4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.

	set_pgfault_handler(pgfault);
  8004e7:	68 08 04 80 00       	push   $0x800408
  8004ec:	e8 37 1b 00 00       	call   802028 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8004f1:	b8 07 00 00 00       	mov    $0x7,%eax
  8004f6:	cd 30                	int    $0x30
  8004f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();

	if (envid < 0) {
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 c0                	test   %eax,%eax
  800500:	79 17                	jns    800519 <fork+0x3b>
		panic("fork fault %e");
  800502:	83 ec 04             	sub    $0x4,%esp
  800505:	68 e9 24 80 00       	push   $0x8024e9
  80050a:	68 85 00 00 00       	push   $0x85
  80050f:	68 c5 24 80 00       	push   $0x8024c5
  800514:	e8 6a 11 00 00       	call   801683 <_panic>
  800519:	89 c7                	mov    %eax,%edi
	}
	
	if (!envid) {
  80051b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80051f:	75 24                	jne    800545 <fork+0x67>
		thisenv = &envs[ENVX(sys_getenvid())];
  800521:	e8 2f fc ff ff       	call   800155 <sys_getenvid>
  800526:	25 ff 03 00 00       	and    $0x3ff,%eax
  80052b:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  800531:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800536:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80053b:	b8 00 00 00 00       	mov    $0x0,%eax
  800540:	e9 64 01 00 00       	jmp    8006a9 <fork+0x1cb>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
  800545:	83 ec 04             	sub    $0x4,%esp
  800548:	6a 07                	push   $0x7
  80054a:	68 00 f0 bf ee       	push   $0xeebff000
  80054f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800552:	e8 3c fc ff ff       	call   800193 <sys_page_alloc>
  800557:	83 c4 10             	add    $0x10,%esp
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80055a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80055f:	89 d8                	mov    %ebx,%eax
  800561:	c1 e8 16             	shr    $0x16,%eax
  800564:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80056b:	a8 01                	test   $0x1,%al
  80056d:	0f 84 fc 00 00 00    	je     80066f <fork+0x191>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
  800573:	89 d8                	mov    %ebx,%eax
  800575:	c1 e8 0c             	shr    $0xc,%eax
  800578:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P && 
  80057f:	f6 c2 01             	test   $0x1,%dl
  800582:	0f 84 e7 00 00 00    	je     80066f <fork+0x191>
{
	int r;

	// LAB 4: Your code here.

	void *addr = (void*)(pn * PGSIZE);
  800588:	89 c6                	mov    %eax,%esi
  80058a:	c1 e6 0c             	shl    $0xc,%esi

	if ((uvpt[pn] & PTE_SHARE) == PTE_SHARE) {
  80058d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800594:	f6 c6 04             	test   $0x4,%dh
  800597:	74 39                	je     8005d2 <fork+0xf4>
		r = sys_page_map(0, addr, envid, addr, uvpt[pn] & PTE_SYSCALL);
  800599:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005a0:	83 ec 0c             	sub    $0xc,%esp
  8005a3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a8:	50                   	push   %eax
  8005a9:	56                   	push   %esi
  8005aa:	57                   	push   %edi
  8005ab:	56                   	push   %esi
  8005ac:	6a 00                	push   $0x0
  8005ae:	e8 23 fc ff ff       	call   8001d6 <sys_page_map>
		if (r < 0) {
  8005b3:	83 c4 20             	add    $0x20,%esp
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	0f 89 b1 00 00 00    	jns    80066f <fork+0x191>
		    	panic("sys page map fault %e");
  8005be:	83 ec 04             	sub    $0x4,%esp
  8005c1:	68 f7 24 80 00       	push   $0x8024f7
  8005c6:	6a 55                	push   $0x55
  8005c8:	68 c5 24 80 00       	push   $0x8024c5
  8005cd:	e8 b1 10 00 00       	call   801683 <_panic>
		} 
	}	

	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8005d2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d9:	f6 c2 02             	test   $0x2,%dl
  8005dc:	75 0c                	jne    8005ea <fork+0x10c>
  8005de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e5:	f6 c4 08             	test   $0x8,%ah
  8005e8:	74 5b                	je     800645 <fork+0x167>
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U | PTE_COW);
  8005ea:	83 ec 0c             	sub    $0xc,%esp
  8005ed:	68 05 08 00 00       	push   $0x805
  8005f2:	56                   	push   %esi
  8005f3:	57                   	push   %edi
  8005f4:	56                   	push   %esi
  8005f5:	6a 00                	push   $0x0
  8005f7:	e8 da fb ff ff       	call   8001d6 <sys_page_map>
		if (r < 0) {
  8005fc:	83 c4 20             	add    $0x20,%esp
  8005ff:	85 c0                	test   %eax,%eax
  800601:	79 14                	jns    800617 <fork+0x139>
		    	panic("sys page map fault %e");
  800603:	83 ec 04             	sub    $0x4,%esp
  800606:	68 f7 24 80 00       	push   $0x8024f7
  80060b:	6a 5c                	push   $0x5c
  80060d:	68 c5 24 80 00       	push   $0x8024c5
  800612:	e8 6c 10 00 00       	call   801683 <_panic>
		}
		r = sys_page_map(0, addr, 0, addr, PTE_P | PTE_U | PTE_COW);
  800617:	83 ec 0c             	sub    $0xc,%esp
  80061a:	68 05 08 00 00       	push   $0x805
  80061f:	56                   	push   %esi
  800620:	6a 00                	push   $0x0
  800622:	56                   	push   %esi
  800623:	6a 00                	push   $0x0
  800625:	e8 ac fb ff ff       	call   8001d6 <sys_page_map>
		if (r < 0) {
  80062a:	83 c4 20             	add    $0x20,%esp
  80062d:	85 c0                	test   %eax,%eax
  80062f:	79 3e                	jns    80066f <fork+0x191>
		    	panic("sys page map fault %e");
  800631:	83 ec 04             	sub    $0x4,%esp
  800634:	68 f7 24 80 00       	push   $0x8024f7
  800639:	6a 60                	push   $0x60
  80063b:	68 c5 24 80 00       	push   $0x8024c5
  800640:	e8 3e 10 00 00       	call   801683 <_panic>
		}		
	} else { 
		r = sys_page_map(0, addr, envid, addr, PTE_P | PTE_U);
  800645:	83 ec 0c             	sub    $0xc,%esp
  800648:	6a 05                	push   $0x5
  80064a:	56                   	push   %esi
  80064b:	57                   	push   %edi
  80064c:	56                   	push   %esi
  80064d:	6a 00                	push   $0x0
  80064f:	e8 82 fb ff ff       	call   8001d6 <sys_page_map>
		if (r < 0) {
  800654:	83 c4 20             	add    $0x20,%esp
  800657:	85 c0                	test   %eax,%eax
  800659:	79 14                	jns    80066f <fork+0x191>
		    	panic("sys page map fault %e");
  80065b:	83 ec 04             	sub    $0x4,%esp
  80065e:	68 f7 24 80 00       	push   $0x8024f7
  800663:	6a 65                	push   $0x65
  800665:	68 c5 24 80 00       	push   $0x8024c5
  80066a:	e8 14 10 00 00       	call   801683 <_panic>
	}

	sys_page_alloc(envid, (void*)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W |PTE_U);
	
	uintptr_t addr;
	for (addr = 0; addr < UTOP - PGSIZE; addr += PGSIZE) {
  80066f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800675:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80067b:	0f 85 de fe ff ff    	jne    80055f <fork+0x81>
		    (uvpt[PGNUM(addr)] & PTE_P) == PTE_P) 			
			duppage(envid, PGNUM(addr));

	}

	sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall);
  800681:	a1 04 40 80 00       	mov    0x804004,%eax
  800686:	8b 80 c0 00 00 00    	mov    0xc0(%eax),%eax
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	50                   	push   %eax
  800690:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800693:	57                   	push   %edi
  800694:	e8 45 fc ff ff       	call   8002de <sys_env_set_pgfault_upcall>

	sys_env_set_status(envid, ENV_RUNNABLE);
  800699:	83 c4 08             	add    $0x8,%esp
  80069c:	6a 02                	push   $0x2
  80069e:	57                   	push   %edi
  80069f:	e8 b6 fb ff ff       	call   80025a <sys_env_set_status>
	
	return envid;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	89 f8                	mov    %edi,%eax
	//panic("fork not implemented");
}
  8006a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ac:	5b                   	pop    %ebx
  8006ad:	5e                   	pop    %esi
  8006ae:	5f                   	pop    %edi
  8006af:	5d                   	pop    %ebp
  8006b0:	c3                   	ret    

008006b1 <sfork>:

envid_t
sfork(void)
{
  8006b1:	55                   	push   %ebp
  8006b2:	89 e5                	mov    %esp,%ebp
	return 0;
}
  8006b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b9:	5d                   	pop    %ebp
  8006ba:	c3                   	ret    

008006bb <thread_create>:
/*Lab 7 Multithreading 
produce a syscall to create a thread, return its id*/
envid_t
thread_create(void (*func)())
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	56                   	push   %esi
  8006bf:	53                   	push   %ebx
  8006c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	eip = (uintptr_t )func;
  8006c3:	89 1d 08 40 80 00    	mov    %ebx,0x804008
	cprintf("in fork.c thread create. func: %x\n", func);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	68 88 25 80 00       	push   $0x802588
  8006d2:	e8 85 10 00 00       	call   80175c <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006d7:	c7 04 24 9d 00 80 00 	movl   $0x80009d,(%esp)
  8006de:	e8 a1 fc ff ff       	call   800384 <sys_thread_create>
  8006e3:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006e5:	83 c4 08             	add    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	68 88 25 80 00       	push   $0x802588
  8006ee:	e8 69 10 00 00       	call   80175c <cprintf>
	return id;
}
  8006f3:	89 f0                	mov    %esi,%eax
  8006f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <thread_interrupt>:

void 	
thread_interrupt(envid_t thread_id) 
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	83 ec 14             	sub    $0x14,%esp
	sys_thread_free(thread_id);
  800702:	ff 75 08             	pushl  0x8(%ebp)
  800705:	e8 9a fc ff ff       	call   8003a4 <sys_thread_free>
}
  80070a:	83 c4 10             	add    $0x10,%esp
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    

0080070f <thread_join>:

void 
thread_join(envid_t thread_id) 
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	83 ec 14             	sub    $0x14,%esp
	sys_thread_join(thread_id);
  800715:	ff 75 08             	pushl  0x8(%ebp)
  800718:	e8 a7 fc ff ff       	call   8003c4 <sys_thread_join>
}
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	c9                   	leave  
  800721:	c3                   	ret    

00800722 <queue_append>:

/*Lab 7: Multithreading - mutex*/

void 
queue_append(envid_t envid, struct waiting_queue* queue) {
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	56                   	push   %esi
  800726:	53                   	push   %ebx
  800727:	8b 75 08             	mov    0x8(%ebp),%esi
  80072a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct waiting_thread* wt = NULL;
	int r = sys_page_alloc(envid,(void*) wt, PTE_P | PTE_W | PTE_U);
  80072d:	83 ec 04             	sub    $0x4,%esp
  800730:	6a 07                	push   $0x7
  800732:	6a 00                	push   $0x0
  800734:	56                   	push   %esi
  800735:	e8 59 fa ff ff       	call   800193 <sys_page_alloc>
	if (r < 0) {
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	85 c0                	test   %eax,%eax
  80073f:	79 15                	jns    800756 <queue_append+0x34>
		panic("%e\n", r);
  800741:	50                   	push   %eax
  800742:	68 83 25 80 00       	push   $0x802583
  800747:	68 c4 00 00 00       	push   $0xc4
  80074c:	68 c5 24 80 00       	push   $0x8024c5
  800751:	e8 2d 0f 00 00       	call   801683 <_panic>
	}	
	wt->envid = envid;
  800756:	89 35 00 00 00 00    	mov    %esi,0x0
	cprintf("In append - envid: %d\nqueue first: %x\n", wt->envid, queue->first);
  80075c:	83 ec 04             	sub    $0x4,%esp
  80075f:	ff 33                	pushl  (%ebx)
  800761:	56                   	push   %esi
  800762:	68 ac 25 80 00       	push   $0x8025ac
  800767:	e8 f0 0f 00 00       	call   80175c <cprintf>
	if (queue->first == NULL) {
  80076c:	83 c4 10             	add    $0x10,%esp
  80076f:	83 3b 00             	cmpl   $0x0,(%ebx)
  800772:	75 29                	jne    80079d <queue_append+0x7b>
		cprintf("In append queue is empty\n");
  800774:	83 ec 0c             	sub    $0xc,%esp
  800777:	68 0d 25 80 00       	push   $0x80250d
  80077c:	e8 db 0f 00 00       	call   80175c <cprintf>
		queue->first = wt;
  800781:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		queue->last = wt;
  800787:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
		wt->next = NULL;
  80078e:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  800795:	00 00 00 
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	eb 2b                	jmp    8007c8 <queue_append+0xa6>
	} else {
		cprintf("In append queue is not empty\n");
  80079d:	83 ec 0c             	sub    $0xc,%esp
  8007a0:	68 27 25 80 00       	push   $0x802527
  8007a5:	e8 b2 0f 00 00       	call   80175c <cprintf>
		queue->last->next = wt;
  8007aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8007ad:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		wt->next = NULL;
  8007b4:	c7 05 04 00 00 00 00 	movl   $0x0,0x4
  8007bb:	00 00 00 
		queue->last = wt;
  8007be:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  8007c5:	83 c4 10             	add    $0x10,%esp
	}
}
  8007c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <queue_pop>:

envid_t 
queue_pop(struct waiting_queue* queue) {
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	83 ec 04             	sub    $0x4,%esp
  8007d6:	8b 55 08             	mov    0x8(%ebp),%edx
	if(queue->first == NULL) {
  8007d9:	8b 02                	mov    (%edx),%eax
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	75 17                	jne    8007f6 <queue_pop+0x27>
		panic("queue empty!\n");
  8007df:	83 ec 04             	sub    $0x4,%esp
  8007e2:	68 45 25 80 00       	push   $0x802545
  8007e7:	68 d8 00 00 00       	push   $0xd8
  8007ec:	68 c5 24 80 00       	push   $0x8024c5
  8007f1:	e8 8d 0e 00 00       	call   801683 <_panic>
	}
	struct waiting_thread* popped = queue->first;
	queue->first = popped->next;
  8007f6:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f9:	89 0a                	mov    %ecx,(%edx)
	envid_t envid = popped->envid;
  8007fb:	8b 18                	mov    (%eax),%ebx
	cprintf("In popping queue - id: %d\n", envid);
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	53                   	push   %ebx
  800801:	68 53 25 80 00       	push   $0x802553
  800806:	e8 51 0f 00 00       	call   80175c <cprintf>
	return envid;
}
  80080b:	89 d8                	mov    %ebx,%eax
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <mutex_lock>:

void 
mutex_lock(struct Mutex* mtx)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	83 ec 04             	sub    $0x4,%esp
  800819:	8b 5d 08             	mov    0x8(%ebp),%ebx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
  80081c:	b8 01 00 00 00       	mov    $0x1,%eax
  800821:	f0 87 03             	lock xchg %eax,(%ebx)
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800824:	85 c0                	test   %eax,%eax
  800826:	74 5a                	je     800882 <mutex_lock+0x70>
  800828:	8b 43 04             	mov    0x4(%ebx),%eax
  80082b:	83 38 00             	cmpl   $0x0,(%eax)
  80082e:	75 52                	jne    800882 <mutex_lock+0x70>
		/*if we failed to acquire the lock, set our status to not runnable 
		and append us to the waiting list*/	
		cprintf("IN MUTEX LOCK, fAILED TO LOCK2\n");
  800830:	83 ec 0c             	sub    $0xc,%esp
  800833:	68 d4 25 80 00       	push   $0x8025d4
  800838:	e8 1f 0f 00 00       	call   80175c <cprintf>
		queue_append(sys_getenvid(), mtx->queue);		
  80083d:	8b 5b 04             	mov    0x4(%ebx),%ebx
  800840:	e8 10 f9 ff ff       	call   800155 <sys_getenvid>
  800845:	83 c4 08             	add    $0x8,%esp
  800848:	53                   	push   %ebx
  800849:	50                   	push   %eax
  80084a:	e8 d3 fe ff ff       	call   800722 <queue_append>
		int r = sys_env_set_status(sys_getenvid(), ENV_NOT_RUNNABLE);	
  80084f:	e8 01 f9 ff ff       	call   800155 <sys_getenvid>
  800854:	83 c4 08             	add    $0x8,%esp
  800857:	6a 04                	push   $0x4
  800859:	50                   	push   %eax
  80085a:	e8 fb f9 ff ff       	call   80025a <sys_env_set_status>
		if (r < 0) {
  80085f:	83 c4 10             	add    $0x10,%esp
  800862:	85 c0                	test   %eax,%eax
  800864:	79 15                	jns    80087b <mutex_lock+0x69>
			panic("%e\n", r);
  800866:	50                   	push   %eax
  800867:	68 83 25 80 00       	push   $0x802583
  80086c:	68 eb 00 00 00       	push   $0xeb
  800871:	68 c5 24 80 00       	push   $0x8024c5
  800876:	e8 08 0e 00 00       	call   801683 <_panic>
		}
		sys_yield();
  80087b:	e8 f4 f8 ff ff       	call   800174 <sys_yield>
}

void 
mutex_lock(struct Mutex* mtx)
{
	if ((xchg(&mtx->locked, 1) != 0) && mtx->queue->first == 0) {
  800880:	eb 18                	jmp    80089a <mutex_lock+0x88>
			panic("%e\n", r);
		}
		sys_yield();
	} 
		
	else {cprintf("IN MUTEX LOCK, SUCCESSFUL LOCK\n");
  800882:	83 ec 0c             	sub    $0xc,%esp
  800885:	68 f4 25 80 00       	push   $0x8025f4
  80088a:	e8 cd 0e 00 00       	call   80175c <cprintf>
	mtx->owner = sys_getenvid();}
  80088f:	e8 c1 f8 ff ff       	call   800155 <sys_getenvid>
  800894:	89 43 08             	mov    %eax,0x8(%ebx)
  800897:	83 c4 10             	add    $0x10,%esp
	
	/*if we acquired the lock, silently return (do nothing)*/
	return;
}
  80089a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089d:	c9                   	leave  
  80089e:	c3                   	ret    

0080089f <mutex_unlock>:

void 
mutex_unlock(struct Mutex* mtx)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	53                   	push   %ebx
  8008a3:	83 ec 04             	sub    $0x4,%esp
  8008a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ae:	f0 87 03             	lock xchg %eax,(%ebx)
	xchg(&mtx->locked, 0);
	
	if (mtx->queue->first != NULL) {
  8008b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8008b4:	83 38 00             	cmpl   $0x0,(%eax)
  8008b7:	74 33                	je     8008ec <mutex_unlock+0x4d>
		mtx->owner = queue_pop(mtx->queue);
  8008b9:	83 ec 0c             	sub    $0xc,%esp
  8008bc:	50                   	push   %eax
  8008bd:	e8 0d ff ff ff       	call   8007cf <queue_pop>
  8008c2:	89 43 08             	mov    %eax,0x8(%ebx)
		int r = sys_env_set_status(mtx->owner, ENV_RUNNABLE);
  8008c5:	83 c4 08             	add    $0x8,%esp
  8008c8:	6a 02                	push   $0x2
  8008ca:	50                   	push   %eax
  8008cb:	e8 8a f9 ff ff       	call   80025a <sys_env_set_status>
		if (r < 0) {
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	79 15                	jns    8008ec <mutex_unlock+0x4d>
			panic("%e\n", r);
  8008d7:	50                   	push   %eax
  8008d8:	68 83 25 80 00       	push   $0x802583
  8008dd:	68 00 01 00 00       	push   $0x100
  8008e2:	68 c5 24 80 00       	push   $0x8024c5
  8008e7:	e8 97 0d 00 00       	call   801683 <_panic>
		}
	}

	asm volatile("pause");
  8008ec:	f3 90                	pause  
	//sys_yield();
}
  8008ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f1:	c9                   	leave  
  8008f2:	c3                   	ret    

008008f3 <mutex_init>:


void 
mutex_init(struct Mutex* mtx)
{	int r;
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	53                   	push   %ebx
  8008f7:	83 ec 04             	sub    $0x4,%esp
  8008fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if ((r = sys_page_alloc(sys_getenvid(), mtx, PTE_P | PTE_W | PTE_U)) < 0) {
  8008fd:	e8 53 f8 ff ff       	call   800155 <sys_getenvid>
  800902:	83 ec 04             	sub    $0x4,%esp
  800905:	6a 07                	push   $0x7
  800907:	53                   	push   %ebx
  800908:	50                   	push   %eax
  800909:	e8 85 f8 ff ff       	call   800193 <sys_page_alloc>
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	85 c0                	test   %eax,%eax
  800913:	79 15                	jns    80092a <mutex_init+0x37>
		panic("panic at mutex init: %e\n", r);
  800915:	50                   	push   %eax
  800916:	68 6e 25 80 00       	push   $0x80256e
  80091b:	68 0d 01 00 00       	push   $0x10d
  800920:	68 c5 24 80 00       	push   $0x8024c5
  800925:	e8 59 0d 00 00       	call   801683 <_panic>
	}	
	mtx->locked = 0;
  80092a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	mtx->queue->first = NULL;
  800930:	8b 43 04             	mov    0x4(%ebx),%eax
  800933:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	mtx->queue->last = NULL;
  800939:	8b 43 04             	mov    0x4(%ebx),%eax
  80093c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	mtx->owner = 0;
  800943:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
}
  80094a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <mutex_destroy>:

void 
mutex_destroy(struct Mutex* mtx)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 08             	sub    $0x8,%esp
	int r = sys_page_unmap(sys_getenvid(), mtx);
  800955:	e8 fb f7 ff ff       	call   800155 <sys_getenvid>
  80095a:	83 ec 08             	sub    $0x8,%esp
  80095d:	ff 75 08             	pushl  0x8(%ebp)
  800960:	50                   	push   %eax
  800961:	e8 b2 f8 ff ff       	call   800218 <sys_page_unmap>
	if (r < 0) {
  800966:	83 c4 10             	add    $0x10,%esp
  800969:	85 c0                	test   %eax,%eax
  80096b:	79 15                	jns    800982 <mutex_destroy+0x33>
		panic("%e\n", r);
  80096d:	50                   	push   %eax
  80096e:	68 83 25 80 00       	push   $0x802583
  800973:	68 1a 01 00 00       	push   $0x11a
  800978:	68 c5 24 80 00       	push   $0x8024c5
  80097d:	e8 01 0d 00 00       	call   801683 <_panic>
	}
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	05 00 00 00 30       	add    $0x30000000,%eax
  80098f:	c1 e8 0c             	shr    $0xc,%eax
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	05 00 00 00 30       	add    $0x30000000,%eax
  80099f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8009a4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8009b6:	89 c2                	mov    %eax,%edx
  8009b8:	c1 ea 16             	shr    $0x16,%edx
  8009bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8009c2:	f6 c2 01             	test   $0x1,%dl
  8009c5:	74 11                	je     8009d8 <fd_alloc+0x2d>
  8009c7:	89 c2                	mov    %eax,%edx
  8009c9:	c1 ea 0c             	shr    $0xc,%edx
  8009cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8009d3:	f6 c2 01             	test   $0x1,%dl
  8009d6:	75 09                	jne    8009e1 <fd_alloc+0x36>
			*fd_store = fd;
  8009d8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
  8009df:	eb 17                	jmp    8009f8 <fd_alloc+0x4d>
  8009e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8009e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8009eb:	75 c9                	jne    8009b6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8009ed:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8009f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800a00:	83 f8 1f             	cmp    $0x1f,%eax
  800a03:	77 36                	ja     800a3b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800a05:	c1 e0 0c             	shl    $0xc,%eax
  800a08:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800a0d:	89 c2                	mov    %eax,%edx
  800a0f:	c1 ea 16             	shr    $0x16,%edx
  800a12:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800a19:	f6 c2 01             	test   $0x1,%dl
  800a1c:	74 24                	je     800a42 <fd_lookup+0x48>
  800a1e:	89 c2                	mov    %eax,%edx
  800a20:	c1 ea 0c             	shr    $0xc,%edx
  800a23:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a2a:	f6 c2 01             	test   $0x1,%dl
  800a2d:	74 1a                	je     800a49 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a32:	89 02                	mov    %eax,(%edx)
	return 0;
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
  800a39:	eb 13                	jmp    800a4e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a3b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a40:	eb 0c                	jmp    800a4e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800a42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a47:	eb 05                	jmp    800a4e <fd_lookup+0x54>
  800a49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	83 ec 08             	sub    $0x8,%esp
  800a56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a59:	ba 90 26 80 00       	mov    $0x802690,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800a5e:	eb 13                	jmp    800a73 <dev_lookup+0x23>
  800a60:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800a63:	39 08                	cmp    %ecx,(%eax)
  800a65:	75 0c                	jne    800a73 <dev_lookup+0x23>
			*dev = devtab[i];
  800a67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	eb 31                	jmp    800aa4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800a73:	8b 02                	mov    (%edx),%eax
  800a75:	85 c0                	test   %eax,%eax
  800a77:	75 e7                	jne    800a60 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800a79:	a1 04 40 80 00       	mov    0x804004,%eax
  800a7e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a84:	83 ec 04             	sub    $0x4,%esp
  800a87:	51                   	push   %ecx
  800a88:	50                   	push   %eax
  800a89:	68 14 26 80 00       	push   $0x802614
  800a8e:	e8 c9 0c 00 00       	call   80175c <cprintf>
	*dev = 0;
  800a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800a9c:	83 c4 10             	add    $0x10,%esp
  800a9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800aa4:	c9                   	leave  
  800aa5:	c3                   	ret    

00800aa6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 10             	sub    $0x10,%esp
  800aae:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab7:	50                   	push   %eax
  800ab8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800abe:	c1 e8 0c             	shr    $0xc,%eax
  800ac1:	50                   	push   %eax
  800ac2:	e8 33 ff ff ff       	call   8009fa <fd_lookup>
  800ac7:	83 c4 08             	add    $0x8,%esp
  800aca:	85 c0                	test   %eax,%eax
  800acc:	78 05                	js     800ad3 <fd_close+0x2d>
	    || fd != fd2)
  800ace:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ad1:	74 0c                	je     800adf <fd_close+0x39>
		return (must_exist ? r : 0);
  800ad3:	84 db                	test   %bl,%bl
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	0f 44 c2             	cmove  %edx,%eax
  800add:	eb 41                	jmp    800b20 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800adf:	83 ec 08             	sub    $0x8,%esp
  800ae2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ae5:	50                   	push   %eax
  800ae6:	ff 36                	pushl  (%esi)
  800ae8:	e8 63 ff ff ff       	call   800a50 <dev_lookup>
  800aed:	89 c3                	mov    %eax,%ebx
  800aef:	83 c4 10             	add    $0x10,%esp
  800af2:	85 c0                	test   %eax,%eax
  800af4:	78 1a                	js     800b10 <fd_close+0x6a>
		if (dev->dev_close)
  800af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800af9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800afc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800b01:	85 c0                	test   %eax,%eax
  800b03:	74 0b                	je     800b10 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800b05:	83 ec 0c             	sub    $0xc,%esp
  800b08:	56                   	push   %esi
  800b09:	ff d0                	call   *%eax
  800b0b:	89 c3                	mov    %eax,%ebx
  800b0d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800b10:	83 ec 08             	sub    $0x8,%esp
  800b13:	56                   	push   %esi
  800b14:	6a 00                	push   $0x0
  800b16:	e8 fd f6 ff ff       	call   800218 <sys_page_unmap>
	return r;
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	89 d8                	mov    %ebx,%eax
}
  800b20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b30:	50                   	push   %eax
  800b31:	ff 75 08             	pushl  0x8(%ebp)
  800b34:	e8 c1 fe ff ff       	call   8009fa <fd_lookup>
  800b39:	83 c4 08             	add    $0x8,%esp
  800b3c:	85 c0                	test   %eax,%eax
  800b3e:	78 10                	js     800b50 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800b40:	83 ec 08             	sub    $0x8,%esp
  800b43:	6a 01                	push   $0x1
  800b45:	ff 75 f4             	pushl  -0xc(%ebp)
  800b48:	e8 59 ff ff ff       	call   800aa6 <fd_close>
  800b4d:	83 c4 10             	add    $0x10,%esp
}
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <close_all>:

void
close_all(void)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	53                   	push   %ebx
  800b56:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800b59:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	53                   	push   %ebx
  800b62:	e8 c0 ff ff ff       	call   800b27 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800b67:	83 c3 01             	add    $0x1,%ebx
  800b6a:	83 c4 10             	add    $0x10,%esp
  800b6d:	83 fb 20             	cmp    $0x20,%ebx
  800b70:	75 ec                	jne    800b5e <close_all+0xc>
		close(i);
}
  800b72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b75:	c9                   	leave  
  800b76:	c3                   	ret    

00800b77 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	83 ec 2c             	sub    $0x2c,%esp
  800b80:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800b83:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800b86:	50                   	push   %eax
  800b87:	ff 75 08             	pushl  0x8(%ebp)
  800b8a:	e8 6b fe ff ff       	call   8009fa <fd_lookup>
  800b8f:	83 c4 08             	add    $0x8,%esp
  800b92:	85 c0                	test   %eax,%eax
  800b94:	0f 88 c1 00 00 00    	js     800c5b <dup+0xe4>
		return r;
	close(newfdnum);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	56                   	push   %esi
  800b9e:	e8 84 ff ff ff       	call   800b27 <close>

	newfd = INDEX2FD(newfdnum);
  800ba3:	89 f3                	mov    %esi,%ebx
  800ba5:	c1 e3 0c             	shl    $0xc,%ebx
  800ba8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800bae:	83 c4 04             	add    $0x4,%esp
  800bb1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bb4:	e8 db fd ff ff       	call   800994 <fd2data>
  800bb9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800bbb:	89 1c 24             	mov    %ebx,(%esp)
  800bbe:	e8 d1 fd ff ff       	call   800994 <fd2data>
  800bc3:	83 c4 10             	add    $0x10,%esp
  800bc6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800bc9:	89 f8                	mov    %edi,%eax
  800bcb:	c1 e8 16             	shr    $0x16,%eax
  800bce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800bd5:	a8 01                	test   $0x1,%al
  800bd7:	74 37                	je     800c10 <dup+0x99>
  800bd9:	89 f8                	mov    %edi,%eax
  800bdb:	c1 e8 0c             	shr    $0xc,%eax
  800bde:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800be5:	f6 c2 01             	test   $0x1,%dl
  800be8:	74 26                	je     800c10 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800bea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800bf1:	83 ec 0c             	sub    $0xc,%esp
  800bf4:	25 07 0e 00 00       	and    $0xe07,%eax
  800bf9:	50                   	push   %eax
  800bfa:	ff 75 d4             	pushl  -0x2c(%ebp)
  800bfd:	6a 00                	push   $0x0
  800bff:	57                   	push   %edi
  800c00:	6a 00                	push   $0x0
  800c02:	e8 cf f5 ff ff       	call   8001d6 <sys_page_map>
  800c07:	89 c7                	mov    %eax,%edi
  800c09:	83 c4 20             	add    $0x20,%esp
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	78 2e                	js     800c3e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c13:	89 d0                	mov    %edx,%eax
  800c15:	c1 e8 0c             	shr    $0xc,%eax
  800c18:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	25 07 0e 00 00       	and    $0xe07,%eax
  800c27:	50                   	push   %eax
  800c28:	53                   	push   %ebx
  800c29:	6a 00                	push   $0x0
  800c2b:	52                   	push   %edx
  800c2c:	6a 00                	push   $0x0
  800c2e:	e8 a3 f5 ff ff       	call   8001d6 <sys_page_map>
  800c33:	89 c7                	mov    %eax,%edi
  800c35:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800c38:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800c3a:	85 ff                	test   %edi,%edi
  800c3c:	79 1d                	jns    800c5b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800c3e:	83 ec 08             	sub    $0x8,%esp
  800c41:	53                   	push   %ebx
  800c42:	6a 00                	push   $0x0
  800c44:	e8 cf f5 ff ff       	call   800218 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800c49:	83 c4 08             	add    $0x8,%esp
  800c4c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800c4f:	6a 00                	push   $0x0
  800c51:	e8 c2 f5 ff ff       	call   800218 <sys_page_unmap>
	return r;
  800c56:	83 c4 10             	add    $0x10,%esp
  800c59:	89 f8                	mov    %edi,%eax
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	53                   	push   %ebx
  800c67:	83 ec 14             	sub    $0x14,%esp
  800c6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c70:	50                   	push   %eax
  800c71:	53                   	push   %ebx
  800c72:	e8 83 fd ff ff       	call   8009fa <fd_lookup>
  800c77:	83 c4 08             	add    $0x8,%esp
  800c7a:	89 c2                	mov    %eax,%edx
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	78 70                	js     800cf0 <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c80:	83 ec 08             	sub    $0x8,%esp
  800c83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c86:	50                   	push   %eax
  800c87:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c8a:	ff 30                	pushl  (%eax)
  800c8c:	e8 bf fd ff ff       	call   800a50 <dev_lookup>
  800c91:	83 c4 10             	add    $0x10,%esp
  800c94:	85 c0                	test   %eax,%eax
  800c96:	78 4f                	js     800ce7 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800c98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800c9b:	8b 42 08             	mov    0x8(%edx),%eax
  800c9e:	83 e0 03             	and    $0x3,%eax
  800ca1:	83 f8 01             	cmp    $0x1,%eax
  800ca4:	75 24                	jne    800cca <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ca6:	a1 04 40 80 00       	mov    0x804004,%eax
  800cab:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800cb1:	83 ec 04             	sub    $0x4,%esp
  800cb4:	53                   	push   %ebx
  800cb5:	50                   	push   %eax
  800cb6:	68 55 26 80 00       	push   $0x802655
  800cbb:	e8 9c 0a 00 00       	call   80175c <cprintf>
		return -E_INVAL;
  800cc0:	83 c4 10             	add    $0x10,%esp
  800cc3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800cc8:	eb 26                	jmp    800cf0 <read+0x8d>
	}
	if (!dev->dev_read)
  800cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ccd:	8b 40 08             	mov    0x8(%eax),%eax
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	74 17                	je     800ceb <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800cd4:	83 ec 04             	sub    $0x4,%esp
  800cd7:	ff 75 10             	pushl  0x10(%ebp)
  800cda:	ff 75 0c             	pushl  0xc(%ebp)
  800cdd:	52                   	push   %edx
  800cde:	ff d0                	call   *%eax
  800ce0:	89 c2                	mov    %eax,%edx
  800ce2:	83 c4 10             	add    $0x10,%esp
  800ce5:	eb 09                	jmp    800cf0 <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ce7:	89 c2                	mov    %eax,%edx
  800ce9:	eb 05                	jmp    800cf0 <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800ceb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800cf0:	89 d0                	mov    %edx,%eax
  800cf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d03:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800d06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0b:	eb 21                	jmp    800d2e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800d0d:	83 ec 04             	sub    $0x4,%esp
  800d10:	89 f0                	mov    %esi,%eax
  800d12:	29 d8                	sub    %ebx,%eax
  800d14:	50                   	push   %eax
  800d15:	89 d8                	mov    %ebx,%eax
  800d17:	03 45 0c             	add    0xc(%ebp),%eax
  800d1a:	50                   	push   %eax
  800d1b:	57                   	push   %edi
  800d1c:	e8 42 ff ff ff       	call   800c63 <read>
		if (m < 0)
  800d21:	83 c4 10             	add    $0x10,%esp
  800d24:	85 c0                	test   %eax,%eax
  800d26:	78 10                	js     800d38 <readn+0x41>
			return m;
		if (m == 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	74 0a                	je     800d36 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800d2c:	01 c3                	add    %eax,%ebx
  800d2e:	39 f3                	cmp    %esi,%ebx
  800d30:	72 db                	jb     800d0d <readn+0x16>
  800d32:	89 d8                	mov    %ebx,%eax
  800d34:	eb 02                	jmp    800d38 <readn+0x41>
  800d36:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	53                   	push   %ebx
  800d44:	83 ec 14             	sub    $0x14,%esp
  800d47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d4a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d4d:	50                   	push   %eax
  800d4e:	53                   	push   %ebx
  800d4f:	e8 a6 fc ff ff       	call   8009fa <fd_lookup>
  800d54:	83 c4 08             	add    $0x8,%esp
  800d57:	89 c2                	mov    %eax,%edx
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	78 6b                	js     800dc8 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d5d:	83 ec 08             	sub    $0x8,%esp
  800d60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d63:	50                   	push   %eax
  800d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d67:	ff 30                	pushl  (%eax)
  800d69:	e8 e2 fc ff ff       	call   800a50 <dev_lookup>
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	85 c0                	test   %eax,%eax
  800d73:	78 4a                	js     800dbf <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d78:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d7c:	75 24                	jne    800da2 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800d7e:	a1 04 40 80 00       	mov    0x804004,%eax
  800d83:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800d89:	83 ec 04             	sub    $0x4,%esp
  800d8c:	53                   	push   %ebx
  800d8d:	50                   	push   %eax
  800d8e:	68 71 26 80 00       	push   $0x802671
  800d93:	e8 c4 09 00 00       	call   80175c <cprintf>
		return -E_INVAL;
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800da0:	eb 26                	jmp    800dc8 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800da2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800da5:	8b 52 0c             	mov    0xc(%edx),%edx
  800da8:	85 d2                	test   %edx,%edx
  800daa:	74 17                	je     800dc3 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800dac:	83 ec 04             	sub    $0x4,%esp
  800daf:	ff 75 10             	pushl  0x10(%ebp)
  800db2:	ff 75 0c             	pushl  0xc(%ebp)
  800db5:	50                   	push   %eax
  800db6:	ff d2                	call   *%edx
  800db8:	89 c2                	mov    %eax,%edx
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	eb 09                	jmp    800dc8 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800dbf:	89 c2                	mov    %eax,%edx
  800dc1:	eb 05                	jmp    800dc8 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800dc3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800dc8:	89 d0                	mov    %edx,%eax
  800dca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dcd:	c9                   	leave  
  800dce:	c3                   	ret    

00800dcf <seek>:

int
seek(int fdnum, off_t offset)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800dd5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800dd8:	50                   	push   %eax
  800dd9:	ff 75 08             	pushl  0x8(%ebp)
  800ddc:	e8 19 fc ff ff       	call   8009fa <fd_lookup>
  800de1:	83 c4 08             	add    $0x8,%esp
  800de4:	85 c0                	test   %eax,%eax
  800de6:	78 0e                	js     800df6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800de8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800deb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dee:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800df1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df6:	c9                   	leave  
  800df7:	c3                   	ret    

00800df8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	53                   	push   %ebx
  800dfc:	83 ec 14             	sub    $0x14,%esp
  800dff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e05:	50                   	push   %eax
  800e06:	53                   	push   %ebx
  800e07:	e8 ee fb ff ff       	call   8009fa <fd_lookup>
  800e0c:	83 c4 08             	add    $0x8,%esp
  800e0f:	89 c2                	mov    %eax,%edx
  800e11:	85 c0                	test   %eax,%eax
  800e13:	78 68                	js     800e7d <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e15:	83 ec 08             	sub    $0x8,%esp
  800e18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e1b:	50                   	push   %eax
  800e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1f:	ff 30                	pushl  (%eax)
  800e21:	e8 2a fc ff ff       	call   800a50 <dev_lookup>
  800e26:	83 c4 10             	add    $0x10,%esp
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	78 47                	js     800e74 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800e2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e30:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800e34:	75 24                	jne    800e5a <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800e36:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800e3b:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800e41:	83 ec 04             	sub    $0x4,%esp
  800e44:	53                   	push   %ebx
  800e45:	50                   	push   %eax
  800e46:	68 34 26 80 00       	push   $0x802634
  800e4b:	e8 0c 09 00 00       	call   80175c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800e50:	83 c4 10             	add    $0x10,%esp
  800e53:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800e58:	eb 23                	jmp    800e7d <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800e5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e5d:	8b 52 18             	mov    0x18(%edx),%edx
  800e60:	85 d2                	test   %edx,%edx
  800e62:	74 14                	je     800e78 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800e64:	83 ec 08             	sub    $0x8,%esp
  800e67:	ff 75 0c             	pushl  0xc(%ebp)
  800e6a:	50                   	push   %eax
  800e6b:	ff d2                	call   *%edx
  800e6d:	89 c2                	mov    %eax,%edx
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	eb 09                	jmp    800e7d <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800e74:	89 c2                	mov    %eax,%edx
  800e76:	eb 05                	jmp    800e7d <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800e78:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800e7d:	89 d0                	mov    %edx,%eax
  800e7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	53                   	push   %ebx
  800e88:	83 ec 14             	sub    $0x14,%esp
  800e8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800e8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e91:	50                   	push   %eax
  800e92:	ff 75 08             	pushl  0x8(%ebp)
  800e95:	e8 60 fb ff ff       	call   8009fa <fd_lookup>
  800e9a:	83 c4 08             	add    $0x8,%esp
  800e9d:	89 c2                	mov    %eax,%edx
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	78 58                	js     800efb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ea3:	83 ec 08             	sub    $0x8,%esp
  800ea6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea9:	50                   	push   %eax
  800eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ead:	ff 30                	pushl  (%eax)
  800eaf:	e8 9c fb ff ff       	call   800a50 <dev_lookup>
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	78 37                	js     800ef2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800ec2:	74 32                	je     800ef6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800ec4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800ec7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800ece:	00 00 00 
	stat->st_isdir = 0;
  800ed1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ed8:	00 00 00 
	stat->st_dev = dev;
  800edb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ee1:	83 ec 08             	sub    $0x8,%esp
  800ee4:	53                   	push   %ebx
  800ee5:	ff 75 f0             	pushl  -0x10(%ebp)
  800ee8:	ff 50 14             	call   *0x14(%eax)
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	83 c4 10             	add    $0x10,%esp
  800ef0:	eb 09                	jmp    800efb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ef2:	89 c2                	mov    %eax,%edx
  800ef4:	eb 05                	jmp    800efb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800ef6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800efb:	89 d0                	mov    %edx,%eax
  800efd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800f07:	83 ec 08             	sub    $0x8,%esp
  800f0a:	6a 00                	push   $0x0
  800f0c:	ff 75 08             	pushl  0x8(%ebp)
  800f0f:	e8 e3 01 00 00       	call   8010f7 <open>
  800f14:	89 c3                	mov    %eax,%ebx
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 1b                	js     800f38 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800f1d:	83 ec 08             	sub    $0x8,%esp
  800f20:	ff 75 0c             	pushl  0xc(%ebp)
  800f23:	50                   	push   %eax
  800f24:	e8 5b ff ff ff       	call   800e84 <fstat>
  800f29:	89 c6                	mov    %eax,%esi
	close(fd);
  800f2b:	89 1c 24             	mov    %ebx,(%esp)
  800f2e:	e8 f4 fb ff ff       	call   800b27 <close>
	return r;
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	89 f0                	mov    %esi,%eax
}
  800f38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	89 c6                	mov    %eax,%esi
  800f46:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800f48:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800f4f:	75 12                	jne    800f63 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	6a 01                	push   $0x1
  800f56:	e8 15 12 00 00       	call   802170 <ipc_find_env>
  800f5b:	a3 00 40 80 00       	mov    %eax,0x804000
  800f60:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800f63:	6a 07                	push   $0x7
  800f65:	68 00 50 80 00       	push   $0x805000
  800f6a:	56                   	push   %esi
  800f6b:	ff 35 00 40 80 00    	pushl  0x804000
  800f71:	e8 98 11 00 00       	call   80210e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800f76:	83 c4 0c             	add    $0xc,%esp
  800f79:	6a 00                	push   $0x0
  800f7b:	53                   	push   %ebx
  800f7c:	6a 00                	push   $0x0
  800f7e:	e8 10 11 00 00       	call   802093 <ipc_recv>
}
  800f83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f86:	5b                   	pop    %ebx
  800f87:	5e                   	pop    %esi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
  800f93:	8b 40 0c             	mov    0xc(%eax),%eax
  800f96:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800fa3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa8:	b8 02 00 00 00       	mov    $0x2,%eax
  800fad:	e8 8d ff ff ff       	call   800f3f <fsipc>
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	8b 40 0c             	mov    0xc(%eax),%eax
  800fc0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800fc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fca:	b8 06 00 00 00       	mov    $0x6,%eax
  800fcf:	e8 6b ff ff ff       	call   800f3f <fsipc>
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	53                   	push   %ebx
  800fda:	83 ec 04             	sub    $0x4,%esp
  800fdd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800fe0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe3:	8b 40 0c             	mov    0xc(%eax),%eax
  800fe6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800feb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ff5:	e8 45 ff ff ff       	call   800f3f <fsipc>
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	78 2c                	js     80102a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ffe:	83 ec 08             	sub    $0x8,%esp
  801001:	68 00 50 80 00       	push   $0x805000
  801006:	53                   	push   %ebx
  801007:	e8 d5 0c 00 00       	call   801ce1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80100c:	a1 80 50 80 00       	mov    0x805080,%eax
  801011:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801017:	a1 84 50 80 00       	mov    0x805084,%eax
  80101c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801022:	83 c4 10             	add    $0x10,%esp
  801025:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80102a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801038:	8b 55 08             	mov    0x8(%ebp),%edx
  80103b:	8b 52 0c             	mov    0xc(%edx),%edx
  80103e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801044:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801049:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80104e:	0f 47 c2             	cmova  %edx,%eax
  801051:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801056:	50                   	push   %eax
  801057:	ff 75 0c             	pushl  0xc(%ebp)
  80105a:	68 08 50 80 00       	push   $0x805008
  80105f:	e8 0f 0e 00 00       	call   801e73 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  801064:	ba 00 00 00 00       	mov    $0x0,%edx
  801069:	b8 04 00 00 00       	mov    $0x4,%eax
  80106e:	e8 cc fe ff ff       	call   800f3f <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80107d:	8b 45 08             	mov    0x8(%ebp),%eax
  801080:	8b 40 0c             	mov    0xc(%eax),%eax
  801083:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801088:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80108e:	ba 00 00 00 00       	mov    $0x0,%edx
  801093:	b8 03 00 00 00       	mov    $0x3,%eax
  801098:	e8 a2 fe ff ff       	call   800f3f <fsipc>
  80109d:	89 c3                	mov    %eax,%ebx
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	78 4b                	js     8010ee <devfile_read+0x79>
		return r;
	assert(r <= n);
  8010a3:	39 c6                	cmp    %eax,%esi
  8010a5:	73 16                	jae    8010bd <devfile_read+0x48>
  8010a7:	68 a0 26 80 00       	push   $0x8026a0
  8010ac:	68 a7 26 80 00       	push   $0x8026a7
  8010b1:	6a 7c                	push   $0x7c
  8010b3:	68 bc 26 80 00       	push   $0x8026bc
  8010b8:	e8 c6 05 00 00       	call   801683 <_panic>
	assert(r <= PGSIZE);
  8010bd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8010c2:	7e 16                	jle    8010da <devfile_read+0x65>
  8010c4:	68 c7 26 80 00       	push   $0x8026c7
  8010c9:	68 a7 26 80 00       	push   $0x8026a7
  8010ce:	6a 7d                	push   $0x7d
  8010d0:	68 bc 26 80 00       	push   $0x8026bc
  8010d5:	e8 a9 05 00 00       	call   801683 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8010da:	83 ec 04             	sub    $0x4,%esp
  8010dd:	50                   	push   %eax
  8010de:	68 00 50 80 00       	push   $0x805000
  8010e3:	ff 75 0c             	pushl  0xc(%ebp)
  8010e6:	e8 88 0d 00 00       	call   801e73 <memmove>
	return r;
  8010eb:	83 c4 10             	add    $0x10,%esp
}
  8010ee:	89 d8                	mov    %ebx,%eax
  8010f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    

008010f7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 20             	sub    $0x20,%esp
  8010fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801101:	53                   	push   %ebx
  801102:	e8 a1 0b 00 00       	call   801ca8 <strlen>
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80110f:	7f 67                	jg     801178 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801111:	83 ec 0c             	sub    $0xc,%esp
  801114:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801117:	50                   	push   %eax
  801118:	e8 8e f8 ff ff       	call   8009ab <fd_alloc>
  80111d:	83 c4 10             	add    $0x10,%esp
		return r;
  801120:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801122:	85 c0                	test   %eax,%eax
  801124:	78 57                	js     80117d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801126:	83 ec 08             	sub    $0x8,%esp
  801129:	53                   	push   %ebx
  80112a:	68 00 50 80 00       	push   $0x805000
  80112f:	e8 ad 0b 00 00       	call   801ce1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801134:	8b 45 0c             	mov    0xc(%ebp),%eax
  801137:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80113c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80113f:	b8 01 00 00 00       	mov    $0x1,%eax
  801144:	e8 f6 fd ff ff       	call   800f3f <fsipc>
  801149:	89 c3                	mov    %eax,%ebx
  80114b:	83 c4 10             	add    $0x10,%esp
  80114e:	85 c0                	test   %eax,%eax
  801150:	79 14                	jns    801166 <open+0x6f>
		fd_close(fd, 0);
  801152:	83 ec 08             	sub    $0x8,%esp
  801155:	6a 00                	push   $0x0
  801157:	ff 75 f4             	pushl  -0xc(%ebp)
  80115a:	e8 47 f9 ff ff       	call   800aa6 <fd_close>
		return r;
  80115f:	83 c4 10             	add    $0x10,%esp
  801162:	89 da                	mov    %ebx,%edx
  801164:	eb 17                	jmp    80117d <open+0x86>
	}

	return fd2num(fd);
  801166:	83 ec 0c             	sub    $0xc,%esp
  801169:	ff 75 f4             	pushl  -0xc(%ebp)
  80116c:	e8 13 f8 ff ff       	call   800984 <fd2num>
  801171:	89 c2                	mov    %eax,%edx
  801173:	83 c4 10             	add    $0x10,%esp
  801176:	eb 05                	jmp    80117d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801178:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80117d:	89 d0                	mov    %edx,%eax
  80117f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801182:	c9                   	leave  
  801183:	c3                   	ret    

00801184 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80118a:	ba 00 00 00 00       	mov    $0x0,%edx
  80118f:	b8 08 00 00 00       	mov    $0x8,%eax
  801194:	e8 a6 fd ff ff       	call   800f3f <fsipc>
}
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	56                   	push   %esi
  80119f:	53                   	push   %ebx
  8011a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	ff 75 08             	pushl  0x8(%ebp)
  8011a9:	e8 e6 f7 ff ff       	call   800994 <fd2data>
  8011ae:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8011b0:	83 c4 08             	add    $0x8,%esp
  8011b3:	68 d3 26 80 00       	push   $0x8026d3
  8011b8:	53                   	push   %ebx
  8011b9:	e8 23 0b 00 00       	call   801ce1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8011be:	8b 46 04             	mov    0x4(%esi),%eax
  8011c1:	2b 06                	sub    (%esi),%eax
  8011c3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8011c9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011d0:	00 00 00 
	stat->st_dev = &devpipe;
  8011d3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8011da:	30 80 00 
	return 0;
}
  8011dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5e                   	pop    %esi
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	53                   	push   %ebx
  8011ed:	83 ec 0c             	sub    $0xc,%esp
  8011f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8011f3:	53                   	push   %ebx
  8011f4:	6a 00                	push   $0x0
  8011f6:	e8 1d f0 ff ff       	call   800218 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8011fb:	89 1c 24             	mov    %ebx,(%esp)
  8011fe:	e8 91 f7 ff ff       	call   800994 <fd2data>
  801203:	83 c4 08             	add    $0x8,%esp
  801206:	50                   	push   %eax
  801207:	6a 00                	push   $0x0
  801209:	e8 0a f0 ff ff       	call   800218 <sys_page_unmap>
}
  80120e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	57                   	push   %edi
  801217:	56                   	push   %esi
  801218:	53                   	push   %ebx
  801219:	83 ec 1c             	sub    $0x1c,%esp
  80121c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80121f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801221:	a1 04 40 80 00       	mov    0x804004,%eax
  801226:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80122c:	83 ec 0c             	sub    $0xc,%esp
  80122f:	ff 75 e0             	pushl  -0x20(%ebp)
  801232:	e8 7e 0f 00 00       	call   8021b5 <pageref>
  801237:	89 c3                	mov    %eax,%ebx
  801239:	89 3c 24             	mov    %edi,(%esp)
  80123c:	e8 74 0f 00 00       	call   8021b5 <pageref>
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	39 c3                	cmp    %eax,%ebx
  801246:	0f 94 c1             	sete   %cl
  801249:	0f b6 c9             	movzbl %cl,%ecx
  80124c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80124f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801255:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  80125b:	39 ce                	cmp    %ecx,%esi
  80125d:	74 1e                	je     80127d <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  80125f:	39 c3                	cmp    %eax,%ebx
  801261:	75 be                	jne    801221 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801263:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801269:	ff 75 e4             	pushl  -0x1c(%ebp)
  80126c:	50                   	push   %eax
  80126d:	56                   	push   %esi
  80126e:	68 da 26 80 00       	push   $0x8026da
  801273:	e8 e4 04 00 00       	call   80175c <cprintf>
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	eb a4                	jmp    801221 <_pipeisclosed+0xe>
	}
}
  80127d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801280:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    

00801288 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	57                   	push   %edi
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	83 ec 28             	sub    $0x28,%esp
  801291:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801294:	56                   	push   %esi
  801295:	e8 fa f6 ff ff       	call   800994 <fd2data>
  80129a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	bf 00 00 00 00       	mov    $0x0,%edi
  8012a4:	eb 4b                	jmp    8012f1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8012a6:	89 da                	mov    %ebx,%edx
  8012a8:	89 f0                	mov    %esi,%eax
  8012aa:	e8 64 ff ff ff       	call   801213 <_pipeisclosed>
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	75 48                	jne    8012fb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8012b3:	e8 bc ee ff ff       	call   800174 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8012b8:	8b 43 04             	mov    0x4(%ebx),%eax
  8012bb:	8b 0b                	mov    (%ebx),%ecx
  8012bd:	8d 51 20             	lea    0x20(%ecx),%edx
  8012c0:	39 d0                	cmp    %edx,%eax
  8012c2:	73 e2                	jae    8012a6 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8012c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8012cb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	c1 fa 1f             	sar    $0x1f,%edx
  8012d3:	89 d1                	mov    %edx,%ecx
  8012d5:	c1 e9 1b             	shr    $0x1b,%ecx
  8012d8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8012db:	83 e2 1f             	and    $0x1f,%edx
  8012de:	29 ca                	sub    %ecx,%edx
  8012e0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8012e4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8012e8:	83 c0 01             	add    $0x1,%eax
  8012eb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012ee:	83 c7 01             	add    $0x1,%edi
  8012f1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8012f4:	75 c2                	jne    8012b8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8012f6:	8b 45 10             	mov    0x10(%ebp),%eax
  8012f9:	eb 05                	jmp    801300 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8012fb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801300:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801303:	5b                   	pop    %ebx
  801304:	5e                   	pop    %esi
  801305:	5f                   	pop    %edi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	57                   	push   %edi
  80130c:	56                   	push   %esi
  80130d:	53                   	push   %ebx
  80130e:	83 ec 18             	sub    $0x18,%esp
  801311:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801314:	57                   	push   %edi
  801315:	e8 7a f6 ff ff       	call   800994 <fd2data>
  80131a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801324:	eb 3d                	jmp    801363 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801326:	85 db                	test   %ebx,%ebx
  801328:	74 04                	je     80132e <devpipe_read+0x26>
				return i;
  80132a:	89 d8                	mov    %ebx,%eax
  80132c:	eb 44                	jmp    801372 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80132e:	89 f2                	mov    %esi,%edx
  801330:	89 f8                	mov    %edi,%eax
  801332:	e8 dc fe ff ff       	call   801213 <_pipeisclosed>
  801337:	85 c0                	test   %eax,%eax
  801339:	75 32                	jne    80136d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80133b:	e8 34 ee ff ff       	call   800174 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801340:	8b 06                	mov    (%esi),%eax
  801342:	3b 46 04             	cmp    0x4(%esi),%eax
  801345:	74 df                	je     801326 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801347:	99                   	cltd   
  801348:	c1 ea 1b             	shr    $0x1b,%edx
  80134b:	01 d0                	add    %edx,%eax
  80134d:	83 e0 1f             	and    $0x1f,%eax
  801350:	29 d0                	sub    %edx,%eax
  801352:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801357:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80135a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80135d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801360:	83 c3 01             	add    $0x1,%ebx
  801363:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801366:	75 d8                	jne    801340 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801368:	8b 45 10             	mov    0x10(%ebp),%eax
  80136b:	eb 05                	jmp    801372 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5f                   	pop    %edi
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	56                   	push   %esi
  80137e:	53                   	push   %ebx
  80137f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801385:	50                   	push   %eax
  801386:	e8 20 f6 ff ff       	call   8009ab <fd_alloc>
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	89 c2                	mov    %eax,%edx
  801390:	85 c0                	test   %eax,%eax
  801392:	0f 88 2c 01 00 00    	js     8014c4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801398:	83 ec 04             	sub    $0x4,%esp
  80139b:	68 07 04 00 00       	push   $0x407
  8013a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a3:	6a 00                	push   $0x0
  8013a5:	e8 e9 ed ff ff       	call   800193 <sys_page_alloc>
  8013aa:	83 c4 10             	add    $0x10,%esp
  8013ad:	89 c2                	mov    %eax,%edx
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	0f 88 0d 01 00 00    	js     8014c4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	e8 e8 f5 ff ff       	call   8009ab <fd_alloc>
  8013c3:	89 c3                	mov    %eax,%ebx
  8013c5:	83 c4 10             	add    $0x10,%esp
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	0f 88 e2 00 00 00    	js     8014b2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013d0:	83 ec 04             	sub    $0x4,%esp
  8013d3:	68 07 04 00 00       	push   $0x407
  8013d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8013db:	6a 00                	push   $0x0
  8013dd:	e8 b1 ed ff ff       	call   800193 <sys_page_alloc>
  8013e2:	89 c3                	mov    %eax,%ebx
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	0f 88 c3 00 00 00    	js     8014b2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8013ef:	83 ec 0c             	sub    $0xc,%esp
  8013f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8013f5:	e8 9a f5 ff ff       	call   800994 <fd2data>
  8013fa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013fc:	83 c4 0c             	add    $0xc,%esp
  8013ff:	68 07 04 00 00       	push   $0x407
  801404:	50                   	push   %eax
  801405:	6a 00                	push   $0x0
  801407:	e8 87 ed ff ff       	call   800193 <sys_page_alloc>
  80140c:	89 c3                	mov    %eax,%ebx
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	85 c0                	test   %eax,%eax
  801413:	0f 88 89 00 00 00    	js     8014a2 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801419:	83 ec 0c             	sub    $0xc,%esp
  80141c:	ff 75 f0             	pushl  -0x10(%ebp)
  80141f:	e8 70 f5 ff ff       	call   800994 <fd2data>
  801424:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80142b:	50                   	push   %eax
  80142c:	6a 00                	push   $0x0
  80142e:	56                   	push   %esi
  80142f:	6a 00                	push   $0x0
  801431:	e8 a0 ed ff ff       	call   8001d6 <sys_page_map>
  801436:	89 c3                	mov    %eax,%ebx
  801438:	83 c4 20             	add    $0x20,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 55                	js     801494 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80143f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801445:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801448:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80144a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801454:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80145a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80145f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801462:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801469:	83 ec 0c             	sub    $0xc,%esp
  80146c:	ff 75 f4             	pushl  -0xc(%ebp)
  80146f:	e8 10 f5 ff ff       	call   800984 <fd2num>
  801474:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801477:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801479:	83 c4 04             	add    $0x4,%esp
  80147c:	ff 75 f0             	pushl  -0x10(%ebp)
  80147f:	e8 00 f5 ff ff       	call   800984 <fd2num>
  801484:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801487:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	ba 00 00 00 00       	mov    $0x0,%edx
  801492:	eb 30                	jmp    8014c4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	56                   	push   %esi
  801498:	6a 00                	push   $0x0
  80149a:	e8 79 ed ff ff       	call   800218 <sys_page_unmap>
  80149f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8014a2:	83 ec 08             	sub    $0x8,%esp
  8014a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8014a8:	6a 00                	push   $0x0
  8014aa:	e8 69 ed ff ff       	call   800218 <sys_page_unmap>
  8014af:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8014b2:	83 ec 08             	sub    $0x8,%esp
  8014b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b8:	6a 00                	push   $0x0
  8014ba:	e8 59 ed ff ff       	call   800218 <sys_page_unmap>
  8014bf:	83 c4 10             	add    $0x10,%esp
  8014c2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8014c4:	89 d0                	mov    %edx,%eax
  8014c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c9:	5b                   	pop    %ebx
  8014ca:	5e                   	pop    %esi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	ff 75 08             	pushl  0x8(%ebp)
  8014da:	e8 1b f5 ff ff       	call   8009fa <fd_lookup>
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 18                	js     8014fe <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8014e6:	83 ec 0c             	sub    $0xc,%esp
  8014e9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ec:	e8 a3 f4 ff ff       	call   800994 <fd2data>
	return _pipeisclosed(fd, p);
  8014f1:	89 c2                	mov    %eax,%edx
  8014f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f6:	e8 18 fd ff ff       	call   801213 <_pipeisclosed>
  8014fb:	83 c4 10             	add    $0x10,%esp
}
  8014fe:	c9                   	leave  
  8014ff:	c3                   	ret    

00801500 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801503:	b8 00 00 00 00       	mov    $0x0,%eax
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    

0080150a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80150a:	55                   	push   %ebp
  80150b:	89 e5                	mov    %esp,%ebp
  80150d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801510:	68 f2 26 80 00       	push   $0x8026f2
  801515:	ff 75 0c             	pushl  0xc(%ebp)
  801518:	e8 c4 07 00 00       	call   801ce1 <strcpy>
	return 0;
}
  80151d:	b8 00 00 00 00       	mov    $0x0,%eax
  801522:	c9                   	leave  
  801523:	c3                   	ret    

00801524 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	57                   	push   %edi
  801528:	56                   	push   %esi
  801529:	53                   	push   %ebx
  80152a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801530:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801535:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80153b:	eb 2d                	jmp    80156a <devcons_write+0x46>
		m = n - tot;
  80153d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801540:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801542:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801545:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80154a:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80154d:	83 ec 04             	sub    $0x4,%esp
  801550:	53                   	push   %ebx
  801551:	03 45 0c             	add    0xc(%ebp),%eax
  801554:	50                   	push   %eax
  801555:	57                   	push   %edi
  801556:	e8 18 09 00 00       	call   801e73 <memmove>
		sys_cputs(buf, m);
  80155b:	83 c4 08             	add    $0x8,%esp
  80155e:	53                   	push   %ebx
  80155f:	57                   	push   %edi
  801560:	e8 72 eb ff ff       	call   8000d7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801565:	01 de                	add    %ebx,%esi
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	89 f0                	mov    %esi,%eax
  80156c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80156f:	72 cc                	jb     80153d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801571:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801574:	5b                   	pop    %ebx
  801575:	5e                   	pop    %esi
  801576:	5f                   	pop    %edi
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    

00801579 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801579:	55                   	push   %ebp
  80157a:	89 e5                	mov    %esp,%ebp
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801584:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801588:	74 2a                	je     8015b4 <devcons_read+0x3b>
  80158a:	eb 05                	jmp    801591 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80158c:	e8 e3 eb ff ff       	call   800174 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801591:	e8 5f eb ff ff       	call   8000f5 <sys_cgetc>
  801596:	85 c0                	test   %eax,%eax
  801598:	74 f2                	je     80158c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 16                	js     8015b4 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80159e:	83 f8 04             	cmp    $0x4,%eax
  8015a1:	74 0c                	je     8015af <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8015a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a6:	88 02                	mov    %al,(%edx)
	return 1;
  8015a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ad:	eb 05                	jmp    8015b4 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8015af:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8015bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8015c2:	6a 01                	push   $0x1
  8015c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8015c7:	50                   	push   %eax
  8015c8:	e8 0a eb ff ff       	call   8000d7 <sys_cputs>
}
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <getchar>:

int
getchar(void)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8015d8:	6a 01                	push   $0x1
  8015da:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	6a 00                	push   $0x0
  8015e0:	e8 7e f6 ff ff       	call   800c63 <read>
	if (r < 0)
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 0f                	js     8015fb <getchar+0x29>
		return r;
	if (r < 1)
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	7e 06                	jle    8015f6 <getchar+0x24>
		return -E_EOF;
	return c;
  8015f0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8015f4:	eb 05                	jmp    8015fb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8015f6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801603:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	ff 75 08             	pushl  0x8(%ebp)
  80160a:	e8 eb f3 ff ff       	call   8009fa <fd_lookup>
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 11                	js     801627 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801616:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801619:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80161f:	39 10                	cmp    %edx,(%eax)
  801621:	0f 94 c0             	sete   %al
  801624:	0f b6 c0             	movzbl %al,%eax
}
  801627:	c9                   	leave  
  801628:	c3                   	ret    

00801629 <opencons>:

int
opencons(void)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80162f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801632:	50                   	push   %eax
  801633:	e8 73 f3 ff ff       	call   8009ab <fd_alloc>
  801638:	83 c4 10             	add    $0x10,%esp
		return r;
  80163b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 3e                	js     80167f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801641:	83 ec 04             	sub    $0x4,%esp
  801644:	68 07 04 00 00       	push   $0x407
  801649:	ff 75 f4             	pushl  -0xc(%ebp)
  80164c:	6a 00                	push   $0x0
  80164e:	e8 40 eb ff ff       	call   800193 <sys_page_alloc>
  801653:	83 c4 10             	add    $0x10,%esp
		return r;
  801656:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 23                	js     80167f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80165c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801662:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801665:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801667:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801671:	83 ec 0c             	sub    $0xc,%esp
  801674:	50                   	push   %eax
  801675:	e8 0a f3 ff ff       	call   800984 <fd2num>
  80167a:	89 c2                	mov    %eax,%edx
  80167c:	83 c4 10             	add    $0x10,%esp
}
  80167f:	89 d0                	mov    %edx,%eax
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	56                   	push   %esi
  801687:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801688:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80168b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801691:	e8 bf ea ff ff       	call   800155 <sys_getenvid>
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	56                   	push   %esi
  8016a0:	50                   	push   %eax
  8016a1:	68 00 27 80 00       	push   $0x802700
  8016a6:	e8 b1 00 00 00       	call   80175c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8016ab:	83 c4 18             	add    $0x18,%esp
  8016ae:	53                   	push   %ebx
  8016af:	ff 75 10             	pushl  0x10(%ebp)
  8016b2:	e8 54 00 00 00       	call   80170b <vcprintf>
	cprintf("\n");
  8016b7:	c7 04 24 51 25 80 00 	movl   $0x802551,(%esp)
  8016be:	e8 99 00 00 00       	call   80175c <cprintf>
  8016c3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8016c6:	cc                   	int3   
  8016c7:	eb fd                	jmp    8016c6 <_panic+0x43>

008016c9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 04             	sub    $0x4,%esp
  8016d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8016d3:	8b 13                	mov    (%ebx),%edx
  8016d5:	8d 42 01             	lea    0x1(%edx),%eax
  8016d8:	89 03                	mov    %eax,(%ebx)
  8016da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016dd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8016e1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8016e6:	75 1a                	jne    801702 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8016e8:	83 ec 08             	sub    $0x8,%esp
  8016eb:	68 ff 00 00 00       	push   $0xff
  8016f0:	8d 43 08             	lea    0x8(%ebx),%eax
  8016f3:	50                   	push   %eax
  8016f4:	e8 de e9 ff ff       	call   8000d7 <sys_cputs>
		b->idx = 0;
  8016f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016ff:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801702:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801714:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80171b:	00 00 00 
	b.cnt = 0;
  80171e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801725:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801728:	ff 75 0c             	pushl  0xc(%ebp)
  80172b:	ff 75 08             	pushl  0x8(%ebp)
  80172e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801734:	50                   	push   %eax
  801735:	68 c9 16 80 00       	push   $0x8016c9
  80173a:	e8 54 01 00 00       	call   801893 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80173f:	83 c4 08             	add    $0x8,%esp
  801742:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801748:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80174e:	50                   	push   %eax
  80174f:	e8 83 e9 ff ff       	call   8000d7 <sys_cputs>

	return b.cnt;
}
  801754:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801762:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801765:	50                   	push   %eax
  801766:	ff 75 08             	pushl  0x8(%ebp)
  801769:	e8 9d ff ff ff       	call   80170b <vcprintf>
	va_end(ap);

	return cnt;
}
  80176e:	c9                   	leave  
  80176f:	c3                   	ret    

00801770 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	57                   	push   %edi
  801774:	56                   	push   %esi
  801775:	53                   	push   %ebx
  801776:	83 ec 1c             	sub    $0x1c,%esp
  801779:	89 c7                	mov    %eax,%edi
  80177b:	89 d6                	mov    %edx,%esi
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 55 0c             	mov    0xc(%ebp),%edx
  801783:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801786:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801789:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80178c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801791:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801794:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801797:	39 d3                	cmp    %edx,%ebx
  801799:	72 05                	jb     8017a0 <printnum+0x30>
  80179b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80179e:	77 45                	ja     8017e5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8017a0:	83 ec 0c             	sub    $0xc,%esp
  8017a3:	ff 75 18             	pushl  0x18(%ebp)
  8017a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8017ac:	53                   	push   %ebx
  8017ad:	ff 75 10             	pushl  0x10(%ebp)
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8017bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8017bf:	e8 2c 0a 00 00       	call   8021f0 <__udivdi3>
  8017c4:	83 c4 18             	add    $0x18,%esp
  8017c7:	52                   	push   %edx
  8017c8:	50                   	push   %eax
  8017c9:	89 f2                	mov    %esi,%edx
  8017cb:	89 f8                	mov    %edi,%eax
  8017cd:	e8 9e ff ff ff       	call   801770 <printnum>
  8017d2:	83 c4 20             	add    $0x20,%esp
  8017d5:	eb 18                	jmp    8017ef <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8017d7:	83 ec 08             	sub    $0x8,%esp
  8017da:	56                   	push   %esi
  8017db:	ff 75 18             	pushl  0x18(%ebp)
  8017de:	ff d7                	call   *%edi
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	eb 03                	jmp    8017e8 <printnum+0x78>
  8017e5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8017e8:	83 eb 01             	sub    $0x1,%ebx
  8017eb:	85 db                	test   %ebx,%ebx
  8017ed:	7f e8                	jg     8017d7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8017ef:	83 ec 08             	sub    $0x8,%esp
  8017f2:	56                   	push   %esi
  8017f3:	83 ec 04             	sub    $0x4,%esp
  8017f6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8017fc:	ff 75 dc             	pushl  -0x24(%ebp)
  8017ff:	ff 75 d8             	pushl  -0x28(%ebp)
  801802:	e8 19 0b 00 00       	call   802320 <__umoddi3>
  801807:	83 c4 14             	add    $0x14,%esp
  80180a:	0f be 80 23 27 80 00 	movsbl 0x802723(%eax),%eax
  801811:	50                   	push   %eax
  801812:	ff d7                	call   *%edi
}
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181a:	5b                   	pop    %ebx
  80181b:	5e                   	pop    %esi
  80181c:	5f                   	pop    %edi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801822:	83 fa 01             	cmp    $0x1,%edx
  801825:	7e 0e                	jle    801835 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801827:	8b 10                	mov    (%eax),%edx
  801829:	8d 4a 08             	lea    0x8(%edx),%ecx
  80182c:	89 08                	mov    %ecx,(%eax)
  80182e:	8b 02                	mov    (%edx),%eax
  801830:	8b 52 04             	mov    0x4(%edx),%edx
  801833:	eb 22                	jmp    801857 <getuint+0x38>
	else if (lflag)
  801835:	85 d2                	test   %edx,%edx
  801837:	74 10                	je     801849 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801839:	8b 10                	mov    (%eax),%edx
  80183b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80183e:	89 08                	mov    %ecx,(%eax)
  801840:	8b 02                	mov    (%edx),%eax
  801842:	ba 00 00 00 00       	mov    $0x0,%edx
  801847:	eb 0e                	jmp    801857 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801849:	8b 10                	mov    (%eax),%edx
  80184b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80184e:	89 08                	mov    %ecx,(%eax)
  801850:	8b 02                	mov    (%edx),%eax
  801852:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    

00801859 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801859:	55                   	push   %ebp
  80185a:	89 e5                	mov    %esp,%ebp
  80185c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80185f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801863:	8b 10                	mov    (%eax),%edx
  801865:	3b 50 04             	cmp    0x4(%eax),%edx
  801868:	73 0a                	jae    801874 <sprintputch+0x1b>
		*b->buf++ = ch;
  80186a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80186d:	89 08                	mov    %ecx,(%eax)
  80186f:	8b 45 08             	mov    0x8(%ebp),%eax
  801872:	88 02                	mov    %al,(%edx)
}
  801874:	5d                   	pop    %ebp
  801875:	c3                   	ret    

00801876 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80187c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80187f:	50                   	push   %eax
  801880:	ff 75 10             	pushl  0x10(%ebp)
  801883:	ff 75 0c             	pushl  0xc(%ebp)
  801886:	ff 75 08             	pushl  0x8(%ebp)
  801889:	e8 05 00 00 00       	call   801893 <vprintfmt>
	va_end(ap);
}
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	57                   	push   %edi
  801897:	56                   	push   %esi
  801898:	53                   	push   %ebx
  801899:	83 ec 2c             	sub    $0x2c,%esp
  80189c:	8b 75 08             	mov    0x8(%ebp),%esi
  80189f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018a2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8018a5:	eb 12                	jmp    8018b9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	0f 84 89 03 00 00    	je     801c38 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8018af:	83 ec 08             	sub    $0x8,%esp
  8018b2:	53                   	push   %ebx
  8018b3:	50                   	push   %eax
  8018b4:	ff d6                	call   *%esi
  8018b6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8018b9:	83 c7 01             	add    $0x1,%edi
  8018bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018c0:	83 f8 25             	cmp    $0x25,%eax
  8018c3:	75 e2                	jne    8018a7 <vprintfmt+0x14>
  8018c5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8018c9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8018d0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8018d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8018de:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e3:	eb 07                	jmp    8018ec <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8018e8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ec:	8d 47 01             	lea    0x1(%edi),%eax
  8018ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018f2:	0f b6 07             	movzbl (%edi),%eax
  8018f5:	0f b6 c8             	movzbl %al,%ecx
  8018f8:	83 e8 23             	sub    $0x23,%eax
  8018fb:	3c 55                	cmp    $0x55,%al
  8018fd:	0f 87 1a 03 00 00    	ja     801c1d <vprintfmt+0x38a>
  801903:	0f b6 c0             	movzbl %al,%eax
  801906:	ff 24 85 60 28 80 00 	jmp    *0x802860(,%eax,4)
  80190d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801910:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801914:	eb d6                	jmp    8018ec <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801916:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801919:	b8 00 00 00 00       	mov    $0x0,%eax
  80191e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801921:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801924:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801928:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80192b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80192e:	83 fa 09             	cmp    $0x9,%edx
  801931:	77 39                	ja     80196c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801933:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801936:	eb e9                	jmp    801921 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801938:	8b 45 14             	mov    0x14(%ebp),%eax
  80193b:	8d 48 04             	lea    0x4(%eax),%ecx
  80193e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801941:	8b 00                	mov    (%eax),%eax
  801943:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801946:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801949:	eb 27                	jmp    801972 <vprintfmt+0xdf>
  80194b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80194e:	85 c0                	test   %eax,%eax
  801950:	b9 00 00 00 00       	mov    $0x0,%ecx
  801955:	0f 49 c8             	cmovns %eax,%ecx
  801958:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80195b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80195e:	eb 8c                	jmp    8018ec <vprintfmt+0x59>
  801960:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801963:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80196a:	eb 80                	jmp    8018ec <vprintfmt+0x59>
  80196c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80196f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801972:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801976:	0f 89 70 ff ff ff    	jns    8018ec <vprintfmt+0x59>
				width = precision, precision = -1;
  80197c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80197f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801982:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801989:	e9 5e ff ff ff       	jmp    8018ec <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80198e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801991:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801994:	e9 53 ff ff ff       	jmp    8018ec <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801999:	8b 45 14             	mov    0x14(%ebp),%eax
  80199c:	8d 50 04             	lea    0x4(%eax),%edx
  80199f:	89 55 14             	mov    %edx,0x14(%ebp)
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	53                   	push   %ebx
  8019a6:	ff 30                	pushl  (%eax)
  8019a8:	ff d6                	call   *%esi
			break;
  8019aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8019b0:	e9 04 ff ff ff       	jmp    8018b9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8019b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b8:	8d 50 04             	lea    0x4(%eax),%edx
  8019bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8019be:	8b 00                	mov    (%eax),%eax
  8019c0:	99                   	cltd   
  8019c1:	31 d0                	xor    %edx,%eax
  8019c3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8019c5:	83 f8 0f             	cmp    $0xf,%eax
  8019c8:	7f 0b                	jg     8019d5 <vprintfmt+0x142>
  8019ca:	8b 14 85 c0 29 80 00 	mov    0x8029c0(,%eax,4),%edx
  8019d1:	85 d2                	test   %edx,%edx
  8019d3:	75 18                	jne    8019ed <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8019d5:	50                   	push   %eax
  8019d6:	68 3b 27 80 00       	push   $0x80273b
  8019db:	53                   	push   %ebx
  8019dc:	56                   	push   %esi
  8019dd:	e8 94 fe ff ff       	call   801876 <printfmt>
  8019e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8019e8:	e9 cc fe ff ff       	jmp    8018b9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8019ed:	52                   	push   %edx
  8019ee:	68 b9 26 80 00       	push   $0x8026b9
  8019f3:	53                   	push   %ebx
  8019f4:	56                   	push   %esi
  8019f5:	e8 7c fe ff ff       	call   801876 <printfmt>
  8019fa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a00:	e9 b4 fe ff ff       	jmp    8018b9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801a05:	8b 45 14             	mov    0x14(%ebp),%eax
  801a08:	8d 50 04             	lea    0x4(%eax),%edx
  801a0b:	89 55 14             	mov    %edx,0x14(%ebp)
  801a0e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801a10:	85 ff                	test   %edi,%edi
  801a12:	b8 34 27 80 00       	mov    $0x802734,%eax
  801a17:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801a1a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801a1e:	0f 8e 94 00 00 00    	jle    801ab8 <vprintfmt+0x225>
  801a24:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801a28:	0f 84 98 00 00 00    	je     801ac6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801a2e:	83 ec 08             	sub    $0x8,%esp
  801a31:	ff 75 d0             	pushl  -0x30(%ebp)
  801a34:	57                   	push   %edi
  801a35:	e8 86 02 00 00       	call   801cc0 <strnlen>
  801a3a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801a3d:	29 c1                	sub    %eax,%ecx
  801a3f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801a42:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801a45:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801a49:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a4c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801a4f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a51:	eb 0f                	jmp    801a62 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801a53:	83 ec 08             	sub    $0x8,%esp
  801a56:	53                   	push   %ebx
  801a57:	ff 75 e0             	pushl  -0x20(%ebp)
  801a5a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801a5c:	83 ef 01             	sub    $0x1,%edi
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	85 ff                	test   %edi,%edi
  801a64:	7f ed                	jg     801a53 <vprintfmt+0x1c0>
  801a66:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801a69:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801a6c:	85 c9                	test   %ecx,%ecx
  801a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a73:	0f 49 c1             	cmovns %ecx,%eax
  801a76:	29 c1                	sub    %eax,%ecx
  801a78:	89 75 08             	mov    %esi,0x8(%ebp)
  801a7b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a7e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a81:	89 cb                	mov    %ecx,%ebx
  801a83:	eb 4d                	jmp    801ad2 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a85:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a89:	74 1b                	je     801aa6 <vprintfmt+0x213>
  801a8b:	0f be c0             	movsbl %al,%eax
  801a8e:	83 e8 20             	sub    $0x20,%eax
  801a91:	83 f8 5e             	cmp    $0x5e,%eax
  801a94:	76 10                	jbe    801aa6 <vprintfmt+0x213>
					putch('?', putdat);
  801a96:	83 ec 08             	sub    $0x8,%esp
  801a99:	ff 75 0c             	pushl  0xc(%ebp)
  801a9c:	6a 3f                	push   $0x3f
  801a9e:	ff 55 08             	call   *0x8(%ebp)
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	eb 0d                	jmp    801ab3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801aa6:	83 ec 08             	sub    $0x8,%esp
  801aa9:	ff 75 0c             	pushl  0xc(%ebp)
  801aac:	52                   	push   %edx
  801aad:	ff 55 08             	call   *0x8(%ebp)
  801ab0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801ab3:	83 eb 01             	sub    $0x1,%ebx
  801ab6:	eb 1a                	jmp    801ad2 <vprintfmt+0x23f>
  801ab8:	89 75 08             	mov    %esi,0x8(%ebp)
  801abb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801abe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801ac1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ac4:	eb 0c                	jmp    801ad2 <vprintfmt+0x23f>
  801ac6:	89 75 08             	mov    %esi,0x8(%ebp)
  801ac9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801acc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801acf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801ad2:	83 c7 01             	add    $0x1,%edi
  801ad5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801ad9:	0f be d0             	movsbl %al,%edx
  801adc:	85 d2                	test   %edx,%edx
  801ade:	74 23                	je     801b03 <vprintfmt+0x270>
  801ae0:	85 f6                	test   %esi,%esi
  801ae2:	78 a1                	js     801a85 <vprintfmt+0x1f2>
  801ae4:	83 ee 01             	sub    $0x1,%esi
  801ae7:	79 9c                	jns    801a85 <vprintfmt+0x1f2>
  801ae9:	89 df                	mov    %ebx,%edi
  801aeb:	8b 75 08             	mov    0x8(%ebp),%esi
  801aee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801af1:	eb 18                	jmp    801b0b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801af3:	83 ec 08             	sub    $0x8,%esp
  801af6:	53                   	push   %ebx
  801af7:	6a 20                	push   $0x20
  801af9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801afb:	83 ef 01             	sub    $0x1,%edi
  801afe:	83 c4 10             	add    $0x10,%esp
  801b01:	eb 08                	jmp    801b0b <vprintfmt+0x278>
  801b03:	89 df                	mov    %ebx,%edi
  801b05:	8b 75 08             	mov    0x8(%ebp),%esi
  801b08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b0b:	85 ff                	test   %edi,%edi
  801b0d:	7f e4                	jg     801af3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b0f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b12:	e9 a2 fd ff ff       	jmp    8018b9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801b17:	83 fa 01             	cmp    $0x1,%edx
  801b1a:	7e 16                	jle    801b32 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  801b1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801b1f:	8d 50 08             	lea    0x8(%eax),%edx
  801b22:	89 55 14             	mov    %edx,0x14(%ebp)
  801b25:	8b 50 04             	mov    0x4(%eax),%edx
  801b28:	8b 00                	mov    (%eax),%eax
  801b2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b2d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801b30:	eb 32                	jmp    801b64 <vprintfmt+0x2d1>
	else if (lflag)
  801b32:	85 d2                	test   %edx,%edx
  801b34:	74 18                	je     801b4e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801b36:	8b 45 14             	mov    0x14(%ebp),%eax
  801b39:	8d 50 04             	lea    0x4(%eax),%edx
  801b3c:	89 55 14             	mov    %edx,0x14(%ebp)
  801b3f:	8b 00                	mov    (%eax),%eax
  801b41:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b44:	89 c1                	mov    %eax,%ecx
  801b46:	c1 f9 1f             	sar    $0x1f,%ecx
  801b49:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801b4c:	eb 16                	jmp    801b64 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801b4e:	8b 45 14             	mov    0x14(%ebp),%eax
  801b51:	8d 50 04             	lea    0x4(%eax),%edx
  801b54:	89 55 14             	mov    %edx,0x14(%ebp)
  801b57:	8b 00                	mov    (%eax),%eax
  801b59:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801b5c:	89 c1                	mov    %eax,%ecx
  801b5e:	c1 f9 1f             	sar    $0x1f,%ecx
  801b61:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801b64:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b67:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801b6a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b6f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b73:	79 74                	jns    801be9 <vprintfmt+0x356>
				putch('-', putdat);
  801b75:	83 ec 08             	sub    $0x8,%esp
  801b78:	53                   	push   %ebx
  801b79:	6a 2d                	push   $0x2d
  801b7b:	ff d6                	call   *%esi
				num = -(long long) num;
  801b7d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801b80:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801b83:	f7 d8                	neg    %eax
  801b85:	83 d2 00             	adc    $0x0,%edx
  801b88:	f7 da                	neg    %edx
  801b8a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801b8d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801b92:	eb 55                	jmp    801be9 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801b94:	8d 45 14             	lea    0x14(%ebp),%eax
  801b97:	e8 83 fc ff ff       	call   80181f <getuint>
			base = 10;
  801b9c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ba1:	eb 46                	jmp    801be9 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ba3:	8d 45 14             	lea    0x14(%ebp),%eax
  801ba6:	e8 74 fc ff ff       	call   80181f <getuint>
			base = 8;
  801bab:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801bb0:	eb 37                	jmp    801be9 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801bb2:	83 ec 08             	sub    $0x8,%esp
  801bb5:	53                   	push   %ebx
  801bb6:	6a 30                	push   $0x30
  801bb8:	ff d6                	call   *%esi
			putch('x', putdat);
  801bba:	83 c4 08             	add    $0x8,%esp
  801bbd:	53                   	push   %ebx
  801bbe:	6a 78                	push   $0x78
  801bc0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801bc2:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc5:	8d 50 04             	lea    0x4(%eax),%edx
  801bc8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801bcb:	8b 00                	mov    (%eax),%eax
  801bcd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801bd2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801bd5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801bda:	eb 0d                	jmp    801be9 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801bdc:	8d 45 14             	lea    0x14(%ebp),%eax
  801bdf:	e8 3b fc ff ff       	call   80181f <getuint>
			base = 16;
  801be4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801be9:	83 ec 0c             	sub    $0xc,%esp
  801bec:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801bf0:	57                   	push   %edi
  801bf1:	ff 75 e0             	pushl  -0x20(%ebp)
  801bf4:	51                   	push   %ecx
  801bf5:	52                   	push   %edx
  801bf6:	50                   	push   %eax
  801bf7:	89 da                	mov    %ebx,%edx
  801bf9:	89 f0                	mov    %esi,%eax
  801bfb:	e8 70 fb ff ff       	call   801770 <printnum>
			break;
  801c00:	83 c4 20             	add    $0x20,%esp
  801c03:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c06:	e9 ae fc ff ff       	jmp    8018b9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801c0b:	83 ec 08             	sub    $0x8,%esp
  801c0e:	53                   	push   %ebx
  801c0f:	51                   	push   %ecx
  801c10:	ff d6                	call   *%esi
			break;
  801c12:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c15:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801c18:	e9 9c fc ff ff       	jmp    8018b9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801c1d:	83 ec 08             	sub    $0x8,%esp
  801c20:	53                   	push   %ebx
  801c21:	6a 25                	push   $0x25
  801c23:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	eb 03                	jmp    801c2d <vprintfmt+0x39a>
  801c2a:	83 ef 01             	sub    $0x1,%edi
  801c2d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801c31:	75 f7                	jne    801c2a <vprintfmt+0x397>
  801c33:	e9 81 fc ff ff       	jmp    8018b9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c3b:	5b                   	pop    %ebx
  801c3c:	5e                   	pop    %esi
  801c3d:	5f                   	pop    %edi
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 18             	sub    $0x18,%esp
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c4f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c53:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	74 26                	je     801c87 <vsnprintf+0x47>
  801c61:	85 d2                	test   %edx,%edx
  801c63:	7e 22                	jle    801c87 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c65:	ff 75 14             	pushl  0x14(%ebp)
  801c68:	ff 75 10             	pushl  0x10(%ebp)
  801c6b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c6e:	50                   	push   %eax
  801c6f:	68 59 18 80 00       	push   $0x801859
  801c74:	e8 1a fc ff ff       	call   801893 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c79:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c7c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c82:	83 c4 10             	add    $0x10,%esp
  801c85:	eb 05                	jmp    801c8c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c94:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c97:	50                   	push   %eax
  801c98:	ff 75 10             	pushl  0x10(%ebp)
  801c9b:	ff 75 0c             	pushl  0xc(%ebp)
  801c9e:	ff 75 08             	pushl  0x8(%ebp)
  801ca1:	e8 9a ff ff ff       	call   801c40 <vsnprintf>
	va_end(ap);

	return rc;
}
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801cae:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb3:	eb 03                	jmp    801cb8 <strlen+0x10>
		n++;
  801cb5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801cb8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801cbc:	75 f7                	jne    801cb5 <strlen+0xd>
		n++;
	return n;
}
  801cbe:	5d                   	pop    %ebp
  801cbf:	c3                   	ret    

00801cc0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cce:	eb 03                	jmp    801cd3 <strnlen+0x13>
		n++;
  801cd0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801cd3:	39 c2                	cmp    %eax,%edx
  801cd5:	74 08                	je     801cdf <strnlen+0x1f>
  801cd7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801cdb:	75 f3                	jne    801cd0 <strnlen+0x10>
  801cdd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    

00801ce1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	53                   	push   %ebx
  801ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801ceb:	89 c2                	mov    %eax,%edx
  801ced:	83 c2 01             	add    $0x1,%edx
  801cf0:	83 c1 01             	add    $0x1,%ecx
  801cf3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801cf7:	88 5a ff             	mov    %bl,-0x1(%edx)
  801cfa:	84 db                	test   %bl,%bl
  801cfc:	75 ef                	jne    801ced <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801cfe:	5b                   	pop    %ebx
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	53                   	push   %ebx
  801d05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801d08:	53                   	push   %ebx
  801d09:	e8 9a ff ff ff       	call   801ca8 <strlen>
  801d0e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801d11:	ff 75 0c             	pushl  0xc(%ebp)
  801d14:	01 d8                	add    %ebx,%eax
  801d16:	50                   	push   %eax
  801d17:	e8 c5 ff ff ff       	call   801ce1 <strcpy>
	return dst;
}
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d21:	c9                   	leave  
  801d22:	c3                   	ret    

00801d23 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	8b 75 08             	mov    0x8(%ebp),%esi
  801d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d2e:	89 f3                	mov    %esi,%ebx
  801d30:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d33:	89 f2                	mov    %esi,%edx
  801d35:	eb 0f                	jmp    801d46 <strncpy+0x23>
		*dst++ = *src;
  801d37:	83 c2 01             	add    $0x1,%edx
  801d3a:	0f b6 01             	movzbl (%ecx),%eax
  801d3d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d40:	80 39 01             	cmpb   $0x1,(%ecx)
  801d43:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d46:	39 da                	cmp    %ebx,%edx
  801d48:	75 ed                	jne    801d37 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d4a:	89 f0                	mov    %esi,%eax
  801d4c:	5b                   	pop    %ebx
  801d4d:	5e                   	pop    %esi
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	56                   	push   %esi
  801d54:	53                   	push   %ebx
  801d55:	8b 75 08             	mov    0x8(%ebp),%esi
  801d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d5b:	8b 55 10             	mov    0x10(%ebp),%edx
  801d5e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d60:	85 d2                	test   %edx,%edx
  801d62:	74 21                	je     801d85 <strlcpy+0x35>
  801d64:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801d68:	89 f2                	mov    %esi,%edx
  801d6a:	eb 09                	jmp    801d75 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d6c:	83 c2 01             	add    $0x1,%edx
  801d6f:	83 c1 01             	add    $0x1,%ecx
  801d72:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801d75:	39 c2                	cmp    %eax,%edx
  801d77:	74 09                	je     801d82 <strlcpy+0x32>
  801d79:	0f b6 19             	movzbl (%ecx),%ebx
  801d7c:	84 db                	test   %bl,%bl
  801d7e:	75 ec                	jne    801d6c <strlcpy+0x1c>
  801d80:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801d82:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801d85:	29 f0                	sub    %esi,%eax
}
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d91:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d94:	eb 06                	jmp    801d9c <strcmp+0x11>
		p++, q++;
  801d96:	83 c1 01             	add    $0x1,%ecx
  801d99:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d9c:	0f b6 01             	movzbl (%ecx),%eax
  801d9f:	84 c0                	test   %al,%al
  801da1:	74 04                	je     801da7 <strcmp+0x1c>
  801da3:	3a 02                	cmp    (%edx),%al
  801da5:	74 ef                	je     801d96 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801da7:	0f b6 c0             	movzbl %al,%eax
  801daa:	0f b6 12             	movzbl (%edx),%edx
  801dad:	29 d0                	sub    %edx,%eax
}
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	53                   	push   %ebx
  801db5:	8b 45 08             	mov    0x8(%ebp),%eax
  801db8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dbb:	89 c3                	mov    %eax,%ebx
  801dbd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801dc0:	eb 06                	jmp    801dc8 <strncmp+0x17>
		n--, p++, q++;
  801dc2:	83 c0 01             	add    $0x1,%eax
  801dc5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801dc8:	39 d8                	cmp    %ebx,%eax
  801dca:	74 15                	je     801de1 <strncmp+0x30>
  801dcc:	0f b6 08             	movzbl (%eax),%ecx
  801dcf:	84 c9                	test   %cl,%cl
  801dd1:	74 04                	je     801dd7 <strncmp+0x26>
  801dd3:	3a 0a                	cmp    (%edx),%cl
  801dd5:	74 eb                	je     801dc2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801dd7:	0f b6 00             	movzbl (%eax),%eax
  801dda:	0f b6 12             	movzbl (%edx),%edx
  801ddd:	29 d0                	sub    %edx,%eax
  801ddf:	eb 05                	jmp    801de6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801de1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801de6:	5b                   	pop    %ebx
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    

00801de9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801df3:	eb 07                	jmp    801dfc <strchr+0x13>
		if (*s == c)
  801df5:	38 ca                	cmp    %cl,%dl
  801df7:	74 0f                	je     801e08 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801df9:	83 c0 01             	add    $0x1,%eax
  801dfc:	0f b6 10             	movzbl (%eax),%edx
  801dff:	84 d2                	test   %dl,%dl
  801e01:	75 f2                	jne    801df5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801e03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e08:	5d                   	pop    %ebp
  801e09:	c3                   	ret    

00801e0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e10:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801e14:	eb 03                	jmp    801e19 <strfind+0xf>
  801e16:	83 c0 01             	add    $0x1,%eax
  801e19:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801e1c:	38 ca                	cmp    %cl,%dl
  801e1e:	74 04                	je     801e24 <strfind+0x1a>
  801e20:	84 d2                	test   %dl,%dl
  801e22:	75 f2                	jne    801e16 <strfind+0xc>
			break;
	return (char *) s;
}
  801e24:	5d                   	pop    %ebp
  801e25:	c3                   	ret    

00801e26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	57                   	push   %edi
  801e2a:	56                   	push   %esi
  801e2b:	53                   	push   %ebx
  801e2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801e32:	85 c9                	test   %ecx,%ecx
  801e34:	74 36                	je     801e6c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801e36:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801e3c:	75 28                	jne    801e66 <memset+0x40>
  801e3e:	f6 c1 03             	test   $0x3,%cl
  801e41:	75 23                	jne    801e66 <memset+0x40>
		c &= 0xFF;
  801e43:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e47:	89 d3                	mov    %edx,%ebx
  801e49:	c1 e3 08             	shl    $0x8,%ebx
  801e4c:	89 d6                	mov    %edx,%esi
  801e4e:	c1 e6 18             	shl    $0x18,%esi
  801e51:	89 d0                	mov    %edx,%eax
  801e53:	c1 e0 10             	shl    $0x10,%eax
  801e56:	09 f0                	or     %esi,%eax
  801e58:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801e5a:	89 d8                	mov    %ebx,%eax
  801e5c:	09 d0                	or     %edx,%eax
  801e5e:	c1 e9 02             	shr    $0x2,%ecx
  801e61:	fc                   	cld    
  801e62:	f3 ab                	rep stos %eax,%es:(%edi)
  801e64:	eb 06                	jmp    801e6c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e69:	fc                   	cld    
  801e6a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801e6c:	89 f8                	mov    %edi,%eax
  801e6e:	5b                   	pop    %ebx
  801e6f:	5e                   	pop    %esi
  801e70:	5f                   	pop    %edi
  801e71:	5d                   	pop    %ebp
  801e72:	c3                   	ret    

00801e73 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	57                   	push   %edi
  801e77:	56                   	push   %esi
  801e78:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e81:	39 c6                	cmp    %eax,%esi
  801e83:	73 35                	jae    801eba <memmove+0x47>
  801e85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e88:	39 d0                	cmp    %edx,%eax
  801e8a:	73 2e                	jae    801eba <memmove+0x47>
		s += n;
		d += n;
  801e8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e8f:	89 d6                	mov    %edx,%esi
  801e91:	09 fe                	or     %edi,%esi
  801e93:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e99:	75 13                	jne    801eae <memmove+0x3b>
  801e9b:	f6 c1 03             	test   $0x3,%cl
  801e9e:	75 0e                	jne    801eae <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801ea0:	83 ef 04             	sub    $0x4,%edi
  801ea3:	8d 72 fc             	lea    -0x4(%edx),%esi
  801ea6:	c1 e9 02             	shr    $0x2,%ecx
  801ea9:	fd                   	std    
  801eaa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801eac:	eb 09                	jmp    801eb7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801eae:	83 ef 01             	sub    $0x1,%edi
  801eb1:	8d 72 ff             	lea    -0x1(%edx),%esi
  801eb4:	fd                   	std    
  801eb5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801eb7:	fc                   	cld    
  801eb8:	eb 1d                	jmp    801ed7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801eba:	89 f2                	mov    %esi,%edx
  801ebc:	09 c2                	or     %eax,%edx
  801ebe:	f6 c2 03             	test   $0x3,%dl
  801ec1:	75 0f                	jne    801ed2 <memmove+0x5f>
  801ec3:	f6 c1 03             	test   $0x3,%cl
  801ec6:	75 0a                	jne    801ed2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801ec8:	c1 e9 02             	shr    $0x2,%ecx
  801ecb:	89 c7                	mov    %eax,%edi
  801ecd:	fc                   	cld    
  801ece:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801ed0:	eb 05                	jmp    801ed7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801ed2:	89 c7                	mov    %eax,%edi
  801ed4:	fc                   	cld    
  801ed5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801ed7:	5e                   	pop    %esi
  801ed8:	5f                   	pop    %edi
  801ed9:	5d                   	pop    %ebp
  801eda:	c3                   	ret    

00801edb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801ede:	ff 75 10             	pushl  0x10(%ebp)
  801ee1:	ff 75 0c             	pushl  0xc(%ebp)
  801ee4:	ff 75 08             	pushl  0x8(%ebp)
  801ee7:	e8 87 ff ff ff       	call   801e73 <memmove>
}
  801eec:	c9                   	leave  
  801eed:	c3                   	ret    

00801eee <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	56                   	push   %esi
  801ef2:	53                   	push   %ebx
  801ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef9:	89 c6                	mov    %eax,%esi
  801efb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801efe:	eb 1a                	jmp    801f1a <memcmp+0x2c>
		if (*s1 != *s2)
  801f00:	0f b6 08             	movzbl (%eax),%ecx
  801f03:	0f b6 1a             	movzbl (%edx),%ebx
  801f06:	38 d9                	cmp    %bl,%cl
  801f08:	74 0a                	je     801f14 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801f0a:	0f b6 c1             	movzbl %cl,%eax
  801f0d:	0f b6 db             	movzbl %bl,%ebx
  801f10:	29 d8                	sub    %ebx,%eax
  801f12:	eb 0f                	jmp    801f23 <memcmp+0x35>
		s1++, s2++;
  801f14:	83 c0 01             	add    $0x1,%eax
  801f17:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801f1a:	39 f0                	cmp    %esi,%eax
  801f1c:	75 e2                	jne    801f00 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801f1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	53                   	push   %ebx
  801f2b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801f2e:	89 c1                	mov    %eax,%ecx
  801f30:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801f33:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f37:	eb 0a                	jmp    801f43 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801f39:	0f b6 10             	movzbl (%eax),%edx
  801f3c:	39 da                	cmp    %ebx,%edx
  801f3e:	74 07                	je     801f47 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f40:	83 c0 01             	add    $0x1,%eax
  801f43:	39 c8                	cmp    %ecx,%eax
  801f45:	72 f2                	jb     801f39 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801f47:	5b                   	pop    %ebx
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    

00801f4a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	57                   	push   %edi
  801f4e:	56                   	push   %esi
  801f4f:	53                   	push   %ebx
  801f50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f56:	eb 03                	jmp    801f5b <strtol+0x11>
		s++;
  801f58:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801f5b:	0f b6 01             	movzbl (%ecx),%eax
  801f5e:	3c 20                	cmp    $0x20,%al
  801f60:	74 f6                	je     801f58 <strtol+0xe>
  801f62:	3c 09                	cmp    $0x9,%al
  801f64:	74 f2                	je     801f58 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801f66:	3c 2b                	cmp    $0x2b,%al
  801f68:	75 0a                	jne    801f74 <strtol+0x2a>
		s++;
  801f6a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f6d:	bf 00 00 00 00       	mov    $0x0,%edi
  801f72:	eb 11                	jmp    801f85 <strtol+0x3b>
  801f74:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801f79:	3c 2d                	cmp    $0x2d,%al
  801f7b:	75 08                	jne    801f85 <strtol+0x3b>
		s++, neg = 1;
  801f7d:	83 c1 01             	add    $0x1,%ecx
  801f80:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f85:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801f8b:	75 15                	jne    801fa2 <strtol+0x58>
  801f8d:	80 39 30             	cmpb   $0x30,(%ecx)
  801f90:	75 10                	jne    801fa2 <strtol+0x58>
  801f92:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801f96:	75 7c                	jne    802014 <strtol+0xca>
		s += 2, base = 16;
  801f98:	83 c1 02             	add    $0x2,%ecx
  801f9b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801fa0:	eb 16                	jmp    801fb8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801fa2:	85 db                	test   %ebx,%ebx
  801fa4:	75 12                	jne    801fb8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801fa6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801fab:	80 39 30             	cmpb   $0x30,(%ecx)
  801fae:	75 08                	jne    801fb8 <strtol+0x6e>
		s++, base = 8;
  801fb0:	83 c1 01             	add    $0x1,%ecx
  801fb3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801fb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801fc0:	0f b6 11             	movzbl (%ecx),%edx
  801fc3:	8d 72 d0             	lea    -0x30(%edx),%esi
  801fc6:	89 f3                	mov    %esi,%ebx
  801fc8:	80 fb 09             	cmp    $0x9,%bl
  801fcb:	77 08                	ja     801fd5 <strtol+0x8b>
			dig = *s - '0';
  801fcd:	0f be d2             	movsbl %dl,%edx
  801fd0:	83 ea 30             	sub    $0x30,%edx
  801fd3:	eb 22                	jmp    801ff7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801fd5:	8d 72 9f             	lea    -0x61(%edx),%esi
  801fd8:	89 f3                	mov    %esi,%ebx
  801fda:	80 fb 19             	cmp    $0x19,%bl
  801fdd:	77 08                	ja     801fe7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801fdf:	0f be d2             	movsbl %dl,%edx
  801fe2:	83 ea 57             	sub    $0x57,%edx
  801fe5:	eb 10                	jmp    801ff7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801fe7:	8d 72 bf             	lea    -0x41(%edx),%esi
  801fea:	89 f3                	mov    %esi,%ebx
  801fec:	80 fb 19             	cmp    $0x19,%bl
  801fef:	77 16                	ja     802007 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ff1:	0f be d2             	movsbl %dl,%edx
  801ff4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ff7:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ffa:	7d 0b                	jge    802007 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ffc:	83 c1 01             	add    $0x1,%ecx
  801fff:	0f af 45 10          	imul   0x10(%ebp),%eax
  802003:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  802005:	eb b9                	jmp    801fc0 <strtol+0x76>

	if (endptr)
  802007:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80200b:	74 0d                	je     80201a <strtol+0xd0>
		*endptr = (char *) s;
  80200d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802010:	89 0e                	mov    %ecx,(%esi)
  802012:	eb 06                	jmp    80201a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802014:	85 db                	test   %ebx,%ebx
  802016:	74 98                	je     801fb0 <strtol+0x66>
  802018:	eb 9e                	jmp    801fb8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80201a:	89 c2                	mov    %eax,%edx
  80201c:	f7 da                	neg    %edx
  80201e:	85 ff                	test   %edi,%edi
  802020:	0f 45 c2             	cmovne %edx,%eax
}
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    

00802028 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80202e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802035:	75 2a                	jne    802061 <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  802037:	83 ec 04             	sub    $0x4,%esp
  80203a:	6a 07                	push   $0x7
  80203c:	68 00 f0 bf ee       	push   $0xeebff000
  802041:	6a 00                	push   $0x0
  802043:	e8 4b e1 ff ff       	call   800193 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  802048:	83 c4 10             	add    $0x10,%esp
  80204b:	85 c0                	test   %eax,%eax
  80204d:	79 12                	jns    802061 <set_pgfault_handler+0x39>
			panic("%e\n", r);
  80204f:	50                   	push   %eax
  802050:	68 83 25 80 00       	push   $0x802583
  802055:	6a 23                	push   $0x23
  802057:	68 20 2a 80 00       	push   $0x802a20
  80205c:	e8 22 f6 ff ff       	call   801683 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802061:	8b 45 08             	mov    0x8(%ebp),%eax
  802064:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  802069:	83 ec 08             	sub    $0x8,%esp
  80206c:	68 e4 03 80 00       	push   $0x8003e4
  802071:	6a 00                	push   $0x0
  802073:	e8 66 e2 ff ff       	call   8002de <sys_env_set_pgfault_upcall>
	if (r < 0) {
  802078:	83 c4 10             	add    $0x10,%esp
  80207b:	85 c0                	test   %eax,%eax
  80207d:	79 12                	jns    802091 <set_pgfault_handler+0x69>
		panic("%e\n", r);
  80207f:	50                   	push   %eax
  802080:	68 83 25 80 00       	push   $0x802583
  802085:	6a 2c                	push   $0x2c
  802087:	68 20 2a 80 00       	push   $0x802a20
  80208c:	e8 f2 f5 ff ff       	call   801683 <_panic>
	}
}
  802091:	c9                   	leave  
  802092:	c3                   	ret    

00802093 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	56                   	push   %esi
  802097:	53                   	push   %ebx
  802098:	8b 75 08             	mov    0x8(%ebp),%esi
  80209b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  8020a1:	85 c0                	test   %eax,%eax
  8020a3:	75 12                	jne    8020b7 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  8020a5:	83 ec 0c             	sub    $0xc,%esp
  8020a8:	68 00 00 c0 ee       	push   $0xeec00000
  8020ad:	e8 91 e2 ff ff       	call   800343 <sys_ipc_recv>
  8020b2:	83 c4 10             	add    $0x10,%esp
  8020b5:	eb 0c                	jmp    8020c3 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  8020b7:	83 ec 0c             	sub    $0xc,%esp
  8020ba:	50                   	push   %eax
  8020bb:	e8 83 e2 ff ff       	call   800343 <sys_ipc_recv>
  8020c0:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  8020c3:	85 f6                	test   %esi,%esi
  8020c5:	0f 95 c1             	setne  %cl
  8020c8:	85 db                	test   %ebx,%ebx
  8020ca:	0f 95 c2             	setne  %dl
  8020cd:	84 d1                	test   %dl,%cl
  8020cf:	74 09                	je     8020da <ipc_recv+0x47>
  8020d1:	89 c2                	mov    %eax,%edx
  8020d3:	c1 ea 1f             	shr    $0x1f,%edx
  8020d6:	84 d2                	test   %dl,%dl
  8020d8:	75 2d                	jne    802107 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  8020da:	85 f6                	test   %esi,%esi
  8020dc:	74 0d                	je     8020eb <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  8020de:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e3:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  8020e9:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  8020eb:	85 db                	test   %ebx,%ebx
  8020ed:	74 0d                	je     8020fc <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  8020ef:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f4:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  8020fa:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020fc:	a1 04 40 80 00       	mov    0x804004,%eax
  802101:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  802107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80210a:	5b                   	pop    %ebx
  80210b:	5e                   	pop    %esi
  80210c:	5d                   	pop    %ebp
  80210d:	c3                   	ret    

0080210e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 0c             	sub    $0xc,%esp
  802117:	8b 7d 08             	mov    0x8(%ebp),%edi
  80211a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80211d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  802120:	85 db                	test   %ebx,%ebx
  802122:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802127:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80212a:	ff 75 14             	pushl  0x14(%ebp)
  80212d:	53                   	push   %ebx
  80212e:	56                   	push   %esi
  80212f:	57                   	push   %edi
  802130:	e8 eb e1 ff ff       	call   800320 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  802135:	89 c2                	mov    %eax,%edx
  802137:	c1 ea 1f             	shr    $0x1f,%edx
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	84 d2                	test   %dl,%dl
  80213f:	74 17                	je     802158 <ipc_send+0x4a>
  802141:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802144:	74 12                	je     802158 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  802146:	50                   	push   %eax
  802147:	68 2e 2a 80 00       	push   $0x802a2e
  80214c:	6a 47                	push   $0x47
  80214e:	68 3c 2a 80 00       	push   $0x802a3c
  802153:	e8 2b f5 ff ff       	call   801683 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  802158:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80215b:	75 07                	jne    802164 <ipc_send+0x56>
			sys_yield();
  80215d:	e8 12 e0 ff ff       	call   800174 <sys_yield>
  802162:	eb c6                	jmp    80212a <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  802164:	85 c0                	test   %eax,%eax
  802166:	75 c2                	jne    80212a <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  802168:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80216b:	5b                   	pop    %ebx
  80216c:	5e                   	pop    %esi
  80216d:	5f                   	pop    %edi
  80216e:	5d                   	pop    %ebp
  80216f:	c3                   	ret    

00802170 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802176:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80217b:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  802181:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802187:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  80218d:	39 ca                	cmp    %ecx,%edx
  80218f:	75 13                	jne    8021a4 <ipc_find_env+0x34>
			return envs[i].env_id;
  802191:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  802197:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80219c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  8021a2:	eb 0f                	jmp    8021b3 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021a4:	83 c0 01             	add    $0x1,%eax
  8021a7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021ac:	75 cd                	jne    80217b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021b3:	5d                   	pop    %ebp
  8021b4:	c3                   	ret    

008021b5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	c1 e8 16             	shr    $0x16,%eax
  8021c0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021c7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021cc:	f6 c1 01             	test   $0x1,%cl
  8021cf:	74 1d                	je     8021ee <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021d1:	c1 ea 0c             	shr    $0xc,%edx
  8021d4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021db:	f6 c2 01             	test   $0x1,%dl
  8021de:	74 0e                	je     8021ee <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021e0:	c1 ea 0c             	shr    $0xc,%edx
  8021e3:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021ea:	ef 
  8021eb:	0f b7 c0             	movzwl %ax,%eax
}
  8021ee:	5d                   	pop    %ebp
  8021ef:	c3                   	ret    

008021f0 <__udivdi3>:
  8021f0:	55                   	push   %ebp
  8021f1:	57                   	push   %edi
  8021f2:	56                   	push   %esi
  8021f3:	53                   	push   %ebx
  8021f4:	83 ec 1c             	sub    $0x1c,%esp
  8021f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8021fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8021ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802207:	85 f6                	test   %esi,%esi
  802209:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80220d:	89 ca                	mov    %ecx,%edx
  80220f:	89 f8                	mov    %edi,%eax
  802211:	75 3d                	jne    802250 <__udivdi3+0x60>
  802213:	39 cf                	cmp    %ecx,%edi
  802215:	0f 87 c5 00 00 00    	ja     8022e0 <__udivdi3+0xf0>
  80221b:	85 ff                	test   %edi,%edi
  80221d:	89 fd                	mov    %edi,%ebp
  80221f:	75 0b                	jne    80222c <__udivdi3+0x3c>
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	31 d2                	xor    %edx,%edx
  802228:	f7 f7                	div    %edi
  80222a:	89 c5                	mov    %eax,%ebp
  80222c:	89 c8                	mov    %ecx,%eax
  80222e:	31 d2                	xor    %edx,%edx
  802230:	f7 f5                	div    %ebp
  802232:	89 c1                	mov    %eax,%ecx
  802234:	89 d8                	mov    %ebx,%eax
  802236:	89 cf                	mov    %ecx,%edi
  802238:	f7 f5                	div    %ebp
  80223a:	89 c3                	mov    %eax,%ebx
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
  802250:	39 ce                	cmp    %ecx,%esi
  802252:	77 74                	ja     8022c8 <__udivdi3+0xd8>
  802254:	0f bd fe             	bsr    %esi,%edi
  802257:	83 f7 1f             	xor    $0x1f,%edi
  80225a:	0f 84 98 00 00 00    	je     8022f8 <__udivdi3+0x108>
  802260:	bb 20 00 00 00       	mov    $0x20,%ebx
  802265:	89 f9                	mov    %edi,%ecx
  802267:	89 c5                	mov    %eax,%ebp
  802269:	29 fb                	sub    %edi,%ebx
  80226b:	d3 e6                	shl    %cl,%esi
  80226d:	89 d9                	mov    %ebx,%ecx
  80226f:	d3 ed                	shr    %cl,%ebp
  802271:	89 f9                	mov    %edi,%ecx
  802273:	d3 e0                	shl    %cl,%eax
  802275:	09 ee                	or     %ebp,%esi
  802277:	89 d9                	mov    %ebx,%ecx
  802279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227d:	89 d5                	mov    %edx,%ebp
  80227f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802283:	d3 ed                	shr    %cl,%ebp
  802285:	89 f9                	mov    %edi,%ecx
  802287:	d3 e2                	shl    %cl,%edx
  802289:	89 d9                	mov    %ebx,%ecx
  80228b:	d3 e8                	shr    %cl,%eax
  80228d:	09 c2                	or     %eax,%edx
  80228f:	89 d0                	mov    %edx,%eax
  802291:	89 ea                	mov    %ebp,%edx
  802293:	f7 f6                	div    %esi
  802295:	89 d5                	mov    %edx,%ebp
  802297:	89 c3                	mov    %eax,%ebx
  802299:	f7 64 24 0c          	mull   0xc(%esp)
  80229d:	39 d5                	cmp    %edx,%ebp
  80229f:	72 10                	jb     8022b1 <__udivdi3+0xc1>
  8022a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8022a5:	89 f9                	mov    %edi,%ecx
  8022a7:	d3 e6                	shl    %cl,%esi
  8022a9:	39 c6                	cmp    %eax,%esi
  8022ab:	73 07                	jae    8022b4 <__udivdi3+0xc4>
  8022ad:	39 d5                	cmp    %edx,%ebp
  8022af:	75 03                	jne    8022b4 <__udivdi3+0xc4>
  8022b1:	83 eb 01             	sub    $0x1,%ebx
  8022b4:	31 ff                	xor    %edi,%edi
  8022b6:	89 d8                	mov    %ebx,%eax
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	83 c4 1c             	add    $0x1c,%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    
  8022c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c8:	31 ff                	xor    %edi,%edi
  8022ca:	31 db                	xor    %ebx,%ebx
  8022cc:	89 d8                	mov    %ebx,%eax
  8022ce:	89 fa                	mov    %edi,%edx
  8022d0:	83 c4 1c             	add    $0x1c,%esp
  8022d3:	5b                   	pop    %ebx
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	90                   	nop
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	89 d8                	mov    %ebx,%eax
  8022e2:	f7 f7                	div    %edi
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	89 c3                	mov    %eax,%ebx
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	89 fa                	mov    %edi,%edx
  8022ec:	83 c4 1c             	add    $0x1c,%esp
  8022ef:	5b                   	pop    %ebx
  8022f0:	5e                   	pop    %esi
  8022f1:	5f                   	pop    %edi
  8022f2:	5d                   	pop    %ebp
  8022f3:	c3                   	ret    
  8022f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	39 ce                	cmp    %ecx,%esi
  8022fa:	72 0c                	jb     802308 <__udivdi3+0x118>
  8022fc:	31 db                	xor    %ebx,%ebx
  8022fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802302:	0f 87 34 ff ff ff    	ja     80223c <__udivdi3+0x4c>
  802308:	bb 01 00 00 00       	mov    $0x1,%ebx
  80230d:	e9 2a ff ff ff       	jmp    80223c <__udivdi3+0x4c>
  802312:	66 90                	xchg   %ax,%ax
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__umoddi3>:
  802320:	55                   	push   %ebp
  802321:	57                   	push   %edi
  802322:	56                   	push   %esi
  802323:	53                   	push   %ebx
  802324:	83 ec 1c             	sub    $0x1c,%esp
  802327:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80232b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80232f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802333:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802337:	85 d2                	test   %edx,%edx
  802339:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80233d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802341:	89 f3                	mov    %esi,%ebx
  802343:	89 3c 24             	mov    %edi,(%esp)
  802346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80234a:	75 1c                	jne    802368 <__umoddi3+0x48>
  80234c:	39 f7                	cmp    %esi,%edi
  80234e:	76 50                	jbe    8023a0 <__umoddi3+0x80>
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	f7 f7                	div    %edi
  802356:	89 d0                	mov    %edx,%eax
  802358:	31 d2                	xor    %edx,%edx
  80235a:	83 c4 1c             	add    $0x1c,%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5f                   	pop    %edi
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    
  802362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802368:	39 f2                	cmp    %esi,%edx
  80236a:	89 d0                	mov    %edx,%eax
  80236c:	77 52                	ja     8023c0 <__umoddi3+0xa0>
  80236e:	0f bd ea             	bsr    %edx,%ebp
  802371:	83 f5 1f             	xor    $0x1f,%ebp
  802374:	75 5a                	jne    8023d0 <__umoddi3+0xb0>
  802376:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80237a:	0f 82 e0 00 00 00    	jb     802460 <__umoddi3+0x140>
  802380:	39 0c 24             	cmp    %ecx,(%esp)
  802383:	0f 86 d7 00 00 00    	jbe    802460 <__umoddi3+0x140>
  802389:	8b 44 24 08          	mov    0x8(%esp),%eax
  80238d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802391:	83 c4 1c             	add    $0x1c,%esp
  802394:	5b                   	pop    %ebx
  802395:	5e                   	pop    %esi
  802396:	5f                   	pop    %edi
  802397:	5d                   	pop    %ebp
  802398:	c3                   	ret    
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	85 ff                	test   %edi,%edi
  8023a2:	89 fd                	mov    %edi,%ebp
  8023a4:	75 0b                	jne    8023b1 <__umoddi3+0x91>
  8023a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	f7 f7                	div    %edi
  8023af:	89 c5                	mov    %eax,%ebp
  8023b1:	89 f0                	mov    %esi,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f5                	div    %ebp
  8023b7:	89 c8                	mov    %ecx,%eax
  8023b9:	f7 f5                	div    %ebp
  8023bb:	89 d0                	mov    %edx,%eax
  8023bd:	eb 99                	jmp    802358 <__umoddi3+0x38>
  8023bf:	90                   	nop
  8023c0:	89 c8                	mov    %ecx,%eax
  8023c2:	89 f2                	mov    %esi,%edx
  8023c4:	83 c4 1c             	add    $0x1c,%esp
  8023c7:	5b                   	pop    %ebx
  8023c8:	5e                   	pop    %esi
  8023c9:	5f                   	pop    %edi
  8023ca:	5d                   	pop    %ebp
  8023cb:	c3                   	ret    
  8023cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	8b 34 24             	mov    (%esp),%esi
  8023d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8023d8:	89 e9                	mov    %ebp,%ecx
  8023da:	29 ef                	sub    %ebp,%edi
  8023dc:	d3 e0                	shl    %cl,%eax
  8023de:	89 f9                	mov    %edi,%ecx
  8023e0:	89 f2                	mov    %esi,%edx
  8023e2:	d3 ea                	shr    %cl,%edx
  8023e4:	89 e9                	mov    %ebp,%ecx
  8023e6:	09 c2                	or     %eax,%edx
  8023e8:	89 d8                	mov    %ebx,%eax
  8023ea:	89 14 24             	mov    %edx,(%esp)
  8023ed:	89 f2                	mov    %esi,%edx
  8023ef:	d3 e2                	shl    %cl,%edx
  8023f1:	89 f9                	mov    %edi,%ecx
  8023f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8023fb:	d3 e8                	shr    %cl,%eax
  8023fd:	89 e9                	mov    %ebp,%ecx
  8023ff:	89 c6                	mov    %eax,%esi
  802401:	d3 e3                	shl    %cl,%ebx
  802403:	89 f9                	mov    %edi,%ecx
  802405:	89 d0                	mov    %edx,%eax
  802407:	d3 e8                	shr    %cl,%eax
  802409:	89 e9                	mov    %ebp,%ecx
  80240b:	09 d8                	or     %ebx,%eax
  80240d:	89 d3                	mov    %edx,%ebx
  80240f:	89 f2                	mov    %esi,%edx
  802411:	f7 34 24             	divl   (%esp)
  802414:	89 d6                	mov    %edx,%esi
  802416:	d3 e3                	shl    %cl,%ebx
  802418:	f7 64 24 04          	mull   0x4(%esp)
  80241c:	39 d6                	cmp    %edx,%esi
  80241e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802422:	89 d1                	mov    %edx,%ecx
  802424:	89 c3                	mov    %eax,%ebx
  802426:	72 08                	jb     802430 <__umoddi3+0x110>
  802428:	75 11                	jne    80243b <__umoddi3+0x11b>
  80242a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80242e:	73 0b                	jae    80243b <__umoddi3+0x11b>
  802430:	2b 44 24 04          	sub    0x4(%esp),%eax
  802434:	1b 14 24             	sbb    (%esp),%edx
  802437:	89 d1                	mov    %edx,%ecx
  802439:	89 c3                	mov    %eax,%ebx
  80243b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80243f:	29 da                	sub    %ebx,%edx
  802441:	19 ce                	sbb    %ecx,%esi
  802443:	89 f9                	mov    %edi,%ecx
  802445:	89 f0                	mov    %esi,%eax
  802447:	d3 e0                	shl    %cl,%eax
  802449:	89 e9                	mov    %ebp,%ecx
  80244b:	d3 ea                	shr    %cl,%edx
  80244d:	89 e9                	mov    %ebp,%ecx
  80244f:	d3 ee                	shr    %cl,%esi
  802451:	09 d0                	or     %edx,%eax
  802453:	89 f2                	mov    %esi,%edx
  802455:	83 c4 1c             	add    $0x1c,%esp
  802458:	5b                   	pop    %ebx
  802459:	5e                   	pop    %esi
  80245a:	5f                   	pop    %edi
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    
  80245d:	8d 76 00             	lea    0x0(%esi),%esi
  802460:	29 f9                	sub    %edi,%ecx
  802462:	19 d6                	sbb    %edx,%esi
  802464:	89 74 24 04          	mov    %esi,0x4(%esp)
  802468:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80246c:	e9 18 ff ff ff       	jmp    802389 <__umoddi3+0x69>
