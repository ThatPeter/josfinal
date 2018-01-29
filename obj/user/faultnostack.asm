
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
  8000c3:	e8 28 08 00 00       	call   8008f0 <close_all>
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
  80013c:	68 2a 22 80 00       	push   $0x80222a
  800141:	6a 23                	push   $0x23
  800143:	68 47 22 80 00       	push   $0x802247
  800148:	e8 d4 12 00 00       	call   801421 <_panic>

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
  8001bd:	68 2a 22 80 00       	push   $0x80222a
  8001c2:	6a 23                	push   $0x23
  8001c4:	68 47 22 80 00       	push   $0x802247
  8001c9:	e8 53 12 00 00       	call   801421 <_panic>

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
  8001ff:	68 2a 22 80 00       	push   $0x80222a
  800204:	6a 23                	push   $0x23
  800206:	68 47 22 80 00       	push   $0x802247
  80020b:	e8 11 12 00 00       	call   801421 <_panic>

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
  800241:	68 2a 22 80 00       	push   $0x80222a
  800246:	6a 23                	push   $0x23
  800248:	68 47 22 80 00       	push   $0x802247
  80024d:	e8 cf 11 00 00       	call   801421 <_panic>

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
  800283:	68 2a 22 80 00       	push   $0x80222a
  800288:	6a 23                	push   $0x23
  80028a:	68 47 22 80 00       	push   $0x802247
  80028f:	e8 8d 11 00 00       	call   801421 <_panic>

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
  8002c5:	68 2a 22 80 00       	push   $0x80222a
  8002ca:	6a 23                	push   $0x23
  8002cc:	68 47 22 80 00       	push   $0x802247
  8002d1:	e8 4b 11 00 00       	call   801421 <_panic>
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
  800307:	68 2a 22 80 00       	push   $0x80222a
  80030c:	6a 23                	push   $0x23
  80030e:	68 47 22 80 00       	push   $0x802247
  800313:	e8 09 11 00 00       	call   801421 <_panic>

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
  80036b:	68 2a 22 80 00       	push   $0x80222a
  800370:	6a 23                	push   $0x23
  800372:	68 47 22 80 00       	push   $0x802247
  800377:	e8 a5 10 00 00       	call   801421 <_panic>

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
  80042e:	68 55 22 80 00       	push   $0x802255
  800433:	6a 1e                	push   $0x1e
  800435:	68 65 22 80 00       	push   $0x802265
  80043a:	e8 e2 0f 00 00       	call   801421 <_panic>
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
  800458:	68 70 22 80 00       	push   $0x802270
  80045d:	6a 2c                	push   $0x2c
  80045f:	68 65 22 80 00       	push   $0x802265
  800464:	e8 b8 0f 00 00       	call   801421 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800469:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy(PFTEMP, addr, PGSIZE);
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	68 00 10 00 00       	push   $0x1000
  800477:	53                   	push   %ebx
  800478:	68 00 f0 7f 00       	push   $0x7ff000
  80047d:	e8 f7 17 00 00       	call   801c79 <memcpy>

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
  8004a0:	68 70 22 80 00       	push   $0x802270
  8004a5:	6a 33                	push   $0x33
  8004a7:	68 65 22 80 00       	push   $0x802265
  8004ac:	e8 70 0f 00 00       	call   801421 <_panic>
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
  8004c8:	68 70 22 80 00       	push   $0x802270
  8004cd:	6a 37                	push   $0x37
  8004cf:	68 65 22 80 00       	push   $0x802265
  8004d4:	e8 48 0f 00 00       	call   801421 <_panic>
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
  8004ec:	e8 d5 18 00 00       	call   801dc6 <set_pgfault_handler>
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
  800505:	68 89 22 80 00       	push   $0x802289
  80050a:	68 84 00 00 00       	push   $0x84
  80050f:	68 65 22 80 00       	push   $0x802265
  800514:	e8 08 0f 00 00       	call   801421 <_panic>
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
  8005c1:	68 97 22 80 00       	push   $0x802297
  8005c6:	6a 54                	push   $0x54
  8005c8:	68 65 22 80 00       	push   $0x802265
  8005cd:	e8 4f 0e 00 00       	call   801421 <_panic>
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
  800606:	68 97 22 80 00       	push   $0x802297
  80060b:	6a 5b                	push   $0x5b
  80060d:	68 65 22 80 00       	push   $0x802265
  800612:	e8 0a 0e 00 00       	call   801421 <_panic>
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
  800634:	68 97 22 80 00       	push   $0x802297
  800639:	6a 5f                	push   $0x5f
  80063b:	68 65 22 80 00       	push   $0x802265
  800640:	e8 dc 0d 00 00       	call   801421 <_panic>
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
  80065e:	68 97 22 80 00       	push   $0x802297
  800663:	6a 64                	push   $0x64
  800665:	68 65 22 80 00       	push   $0x802265
  80066a:	e8 b2 0d 00 00       	call   801421 <_panic>
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
  8006cd:	68 b0 22 80 00       	push   $0x8022b0
  8006d2:	e8 23 0e 00 00       	call   8014fa <cprintf>
	
	envid_t id = sys_thread_create((uintptr_t)thread_main);
  8006d7:	c7 04 24 9d 00 80 00 	movl   $0x80009d,(%esp)
  8006de:	e8 a1 fc ff ff       	call   800384 <sys_thread_create>
  8006e3:	89 c6                	mov    %eax,%esi
	cprintf("in fork.c thread create. func: %x\n", func);
  8006e5:	83 c4 08             	add    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	68 b0 22 80 00       	push   $0x8022b0
  8006ee:	e8 07 0e 00 00       	call   8014fa <cprintf>
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

00800722 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	05 00 00 00 30       	add    $0x30000000,%eax
  80072d:	c1 e8 0c             	shr    $0xc,%eax
}
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	05 00 00 00 30       	add    $0x30000000,%eax
  80073d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800742:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800754:	89 c2                	mov    %eax,%edx
  800756:	c1 ea 16             	shr    $0x16,%edx
  800759:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800760:	f6 c2 01             	test   $0x1,%dl
  800763:	74 11                	je     800776 <fd_alloc+0x2d>
  800765:	89 c2                	mov    %eax,%edx
  800767:	c1 ea 0c             	shr    $0xc,%edx
  80076a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800771:	f6 c2 01             	test   $0x1,%dl
  800774:	75 09                	jne    80077f <fd_alloc+0x36>
			*fd_store = fd;
  800776:	89 01                	mov    %eax,(%ecx)
			return 0;
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	eb 17                	jmp    800796 <fd_alloc+0x4d>
  80077f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800784:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800789:	75 c9                	jne    800754 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80078b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800791:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80079e:	83 f8 1f             	cmp    $0x1f,%eax
  8007a1:	77 36                	ja     8007d9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007a3:	c1 e0 0c             	shl    $0xc,%eax
  8007a6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007ab:	89 c2                	mov    %eax,%edx
  8007ad:	c1 ea 16             	shr    $0x16,%edx
  8007b0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007b7:	f6 c2 01             	test   $0x1,%dl
  8007ba:	74 24                	je     8007e0 <fd_lookup+0x48>
  8007bc:	89 c2                	mov    %eax,%edx
  8007be:	c1 ea 0c             	shr    $0xc,%edx
  8007c1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007c8:	f6 c2 01             	test   $0x1,%dl
  8007cb:	74 1a                	je     8007e7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8007cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d0:	89 02                	mov    %eax,(%edx)
	return 0;
  8007d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d7:	eb 13                	jmp    8007ec <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007de:	eb 0c                	jmp    8007ec <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8007e0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e5:	eb 05                	jmp    8007ec <fd_lookup+0x54>
  8007e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f7:	ba 50 23 80 00       	mov    $0x802350,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8007fc:	eb 13                	jmp    800811 <dev_lookup+0x23>
  8007fe:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800801:	39 08                	cmp    %ecx,(%eax)
  800803:	75 0c                	jne    800811 <dev_lookup+0x23>
			*dev = devtab[i];
  800805:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800808:	89 01                	mov    %eax,(%ecx)
			return 0;
  80080a:	b8 00 00 00 00       	mov    $0x0,%eax
  80080f:	eb 31                	jmp    800842 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800811:	8b 02                	mov    (%edx),%eax
  800813:	85 c0                	test   %eax,%eax
  800815:	75 e7                	jne    8007fe <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800817:	a1 04 40 80 00       	mov    0x804004,%eax
  80081c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800822:	83 ec 04             	sub    $0x4,%esp
  800825:	51                   	push   %ecx
  800826:	50                   	push   %eax
  800827:	68 d4 22 80 00       	push   $0x8022d4
  80082c:	e8 c9 0c 00 00       	call   8014fa <cprintf>
	*dev = 0;
  800831:	8b 45 0c             	mov    0xc(%ebp),%eax
  800834:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	83 ec 10             	sub    $0x10,%esp
  80084c:	8b 75 08             	mov    0x8(%ebp),%esi
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800852:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80085c:	c1 e8 0c             	shr    $0xc,%eax
  80085f:	50                   	push   %eax
  800860:	e8 33 ff ff ff       	call   800798 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	85 c0                	test   %eax,%eax
  80086a:	78 05                	js     800871 <fd_close+0x2d>
	    || fd != fd2)
  80086c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80086f:	74 0c                	je     80087d <fd_close+0x39>
		return (must_exist ? r : 0);
  800871:	84 db                	test   %bl,%bl
  800873:	ba 00 00 00 00       	mov    $0x0,%edx
  800878:	0f 44 c2             	cmove  %edx,%eax
  80087b:	eb 41                	jmp    8008be <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800883:	50                   	push   %eax
  800884:	ff 36                	pushl  (%esi)
  800886:	e8 63 ff ff ff       	call   8007ee <dev_lookup>
  80088b:	89 c3                	mov    %eax,%ebx
  80088d:	83 c4 10             	add    $0x10,%esp
  800890:	85 c0                	test   %eax,%eax
  800892:	78 1a                	js     8008ae <fd_close+0x6a>
		if (dev->dev_close)
  800894:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800897:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80089a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	74 0b                	je     8008ae <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8008a3:	83 ec 0c             	sub    $0xc,%esp
  8008a6:	56                   	push   %esi
  8008a7:	ff d0                	call   *%eax
  8008a9:	89 c3                	mov    %eax,%ebx
  8008ab:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	56                   	push   %esi
  8008b2:	6a 00                	push   $0x0
  8008b4:	e8 5f f9 ff ff       	call   800218 <sys_page_unmap>
	return r;
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	89 d8                	mov    %ebx,%eax
}
  8008be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c1:	5b                   	pop    %ebx
  8008c2:	5e                   	pop    %esi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ce:	50                   	push   %eax
  8008cf:	ff 75 08             	pushl  0x8(%ebp)
  8008d2:	e8 c1 fe ff ff       	call   800798 <fd_lookup>
  8008d7:	83 c4 08             	add    $0x8,%esp
  8008da:	85 c0                	test   %eax,%eax
  8008dc:	78 10                	js     8008ee <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8008de:	83 ec 08             	sub    $0x8,%esp
  8008e1:	6a 01                	push   $0x1
  8008e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8008e6:	e8 59 ff ff ff       	call   800844 <fd_close>
  8008eb:	83 c4 10             	add    $0x10,%esp
}
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    

008008f0 <close_all>:

void
close_all(void)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8008f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8008fc:	83 ec 0c             	sub    $0xc,%esp
  8008ff:	53                   	push   %ebx
  800900:	e8 c0 ff ff ff       	call   8008c5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800905:	83 c3 01             	add    $0x1,%ebx
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	83 fb 20             	cmp    $0x20,%ebx
  80090e:	75 ec                	jne    8008fc <close_all+0xc>
		close(i);
}
  800910:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	57                   	push   %edi
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	83 ec 2c             	sub    $0x2c,%esp
  80091e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800921:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800924:	50                   	push   %eax
  800925:	ff 75 08             	pushl  0x8(%ebp)
  800928:	e8 6b fe ff ff       	call   800798 <fd_lookup>
  80092d:	83 c4 08             	add    $0x8,%esp
  800930:	85 c0                	test   %eax,%eax
  800932:	0f 88 c1 00 00 00    	js     8009f9 <dup+0xe4>
		return r;
	close(newfdnum);
  800938:	83 ec 0c             	sub    $0xc,%esp
  80093b:	56                   	push   %esi
  80093c:	e8 84 ff ff ff       	call   8008c5 <close>

	newfd = INDEX2FD(newfdnum);
  800941:	89 f3                	mov    %esi,%ebx
  800943:	c1 e3 0c             	shl    $0xc,%ebx
  800946:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80094c:	83 c4 04             	add    $0x4,%esp
  80094f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800952:	e8 db fd ff ff       	call   800732 <fd2data>
  800957:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800959:	89 1c 24             	mov    %ebx,(%esp)
  80095c:	e8 d1 fd ff ff       	call   800732 <fd2data>
  800961:	83 c4 10             	add    $0x10,%esp
  800964:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800967:	89 f8                	mov    %edi,%eax
  800969:	c1 e8 16             	shr    $0x16,%eax
  80096c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800973:	a8 01                	test   $0x1,%al
  800975:	74 37                	je     8009ae <dup+0x99>
  800977:	89 f8                	mov    %edi,%eax
  800979:	c1 e8 0c             	shr    $0xc,%eax
  80097c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800983:	f6 c2 01             	test   $0x1,%dl
  800986:	74 26                	je     8009ae <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800988:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80098f:	83 ec 0c             	sub    $0xc,%esp
  800992:	25 07 0e 00 00       	and    $0xe07,%eax
  800997:	50                   	push   %eax
  800998:	ff 75 d4             	pushl  -0x2c(%ebp)
  80099b:	6a 00                	push   $0x0
  80099d:	57                   	push   %edi
  80099e:	6a 00                	push   $0x0
  8009a0:	e8 31 f8 ff ff       	call   8001d6 <sys_page_map>
  8009a5:	89 c7                	mov    %eax,%edi
  8009a7:	83 c4 20             	add    $0x20,%esp
  8009aa:	85 c0                	test   %eax,%eax
  8009ac:	78 2e                	js     8009dc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009b1:	89 d0                	mov    %edx,%eax
  8009b3:	c1 e8 0c             	shr    $0xc,%eax
  8009b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009bd:	83 ec 0c             	sub    $0xc,%esp
  8009c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8009c5:	50                   	push   %eax
  8009c6:	53                   	push   %ebx
  8009c7:	6a 00                	push   $0x0
  8009c9:	52                   	push   %edx
  8009ca:	6a 00                	push   $0x0
  8009cc:	e8 05 f8 ff ff       	call   8001d6 <sys_page_map>
  8009d1:	89 c7                	mov    %eax,%edi
  8009d3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8009d6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009d8:	85 ff                	test   %edi,%edi
  8009da:	79 1d                	jns    8009f9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8009dc:	83 ec 08             	sub    $0x8,%esp
  8009df:	53                   	push   %ebx
  8009e0:	6a 00                	push   $0x0
  8009e2:	e8 31 f8 ff ff       	call   800218 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8009e7:	83 c4 08             	add    $0x8,%esp
  8009ea:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009ed:	6a 00                	push   $0x0
  8009ef:	e8 24 f8 ff ff       	call   800218 <sys_page_unmap>
	return r;
  8009f4:	83 c4 10             	add    $0x10,%esp
  8009f7:	89 f8                	mov    %edi,%eax
}
  8009f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009fc:	5b                   	pop    %ebx
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	53                   	push   %ebx
  800a05:	83 ec 14             	sub    $0x14,%esp
  800a08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a0b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a0e:	50                   	push   %eax
  800a0f:	53                   	push   %ebx
  800a10:	e8 83 fd ff ff       	call   800798 <fd_lookup>
  800a15:	83 c4 08             	add    $0x8,%esp
  800a18:	89 c2                	mov    %eax,%edx
  800a1a:	85 c0                	test   %eax,%eax
  800a1c:	78 70                	js     800a8e <read+0x8d>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a1e:	83 ec 08             	sub    $0x8,%esp
  800a21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a24:	50                   	push   %eax
  800a25:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a28:	ff 30                	pushl  (%eax)
  800a2a:	e8 bf fd ff ff       	call   8007ee <dev_lookup>
  800a2f:	83 c4 10             	add    $0x10,%esp
  800a32:	85 c0                	test   %eax,%eax
  800a34:	78 4f                	js     800a85 <read+0x84>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a36:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a39:	8b 42 08             	mov    0x8(%edx),%eax
  800a3c:	83 e0 03             	and    $0x3,%eax
  800a3f:	83 f8 01             	cmp    $0x1,%eax
  800a42:	75 24                	jne    800a68 <read+0x67>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800a44:	a1 04 40 80 00       	mov    0x804004,%eax
  800a49:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800a4f:	83 ec 04             	sub    $0x4,%esp
  800a52:	53                   	push   %ebx
  800a53:	50                   	push   %eax
  800a54:	68 15 23 80 00       	push   $0x802315
  800a59:	e8 9c 0a 00 00       	call   8014fa <cprintf>
		return -E_INVAL;
  800a5e:	83 c4 10             	add    $0x10,%esp
  800a61:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800a66:	eb 26                	jmp    800a8e <read+0x8d>
	}
	if (!dev->dev_read)
  800a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a6b:	8b 40 08             	mov    0x8(%eax),%eax
  800a6e:	85 c0                	test   %eax,%eax
  800a70:	74 17                	je     800a89 <read+0x88>
		return -E_NOT_SUPP;

	return (*dev->dev_read)(fd, buf, n);
  800a72:	83 ec 04             	sub    $0x4,%esp
  800a75:	ff 75 10             	pushl  0x10(%ebp)
  800a78:	ff 75 0c             	pushl  0xc(%ebp)
  800a7b:	52                   	push   %edx
  800a7c:	ff d0                	call   *%eax
  800a7e:	89 c2                	mov    %eax,%edx
  800a80:	83 c4 10             	add    $0x10,%esp
  800a83:	eb 09                	jmp    800a8e <read+0x8d>
	int r;
	struct Dev *dev;
	struct Fd *fd;
		// DEV LOOKUP MI VRACIA -3 HALP
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a85:	89 c2                	mov    %eax,%edx
  800a87:	eb 05                	jmp    800a8e <read+0x8d>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800a89:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx

	return (*dev->dev_read)(fd, buf, n);
}
  800a8e:	89 d0                	mov    %edx,%eax
  800a90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a93:	c9                   	leave  
  800a94:	c3                   	ret    

00800a95 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	83 ec 0c             	sub    $0xc,%esp
  800a9e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800aa4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aa9:	eb 21                	jmp    800acc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800aab:	83 ec 04             	sub    $0x4,%esp
  800aae:	89 f0                	mov    %esi,%eax
  800ab0:	29 d8                	sub    %ebx,%eax
  800ab2:	50                   	push   %eax
  800ab3:	89 d8                	mov    %ebx,%eax
  800ab5:	03 45 0c             	add    0xc(%ebp),%eax
  800ab8:	50                   	push   %eax
  800ab9:	57                   	push   %edi
  800aba:	e8 42 ff ff ff       	call   800a01 <read>
		if (m < 0)
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	78 10                	js     800ad6 <readn+0x41>
			return m;
		if (m == 0)
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	74 0a                	je     800ad4 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800aca:	01 c3                	add    %eax,%ebx
  800acc:	39 f3                	cmp    %esi,%ebx
  800ace:	72 db                	jb     800aab <readn+0x16>
  800ad0:	89 d8                	mov    %ebx,%eax
  800ad2:	eb 02                	jmp    800ad6 <readn+0x41>
  800ad4:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	53                   	push   %ebx
  800ae2:	83 ec 14             	sub    $0x14,%esp
  800ae5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ae8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800aeb:	50                   	push   %eax
  800aec:	53                   	push   %ebx
  800aed:	e8 a6 fc ff ff       	call   800798 <fd_lookup>
  800af2:	83 c4 08             	add    $0x8,%esp
  800af5:	89 c2                	mov    %eax,%edx
  800af7:	85 c0                	test   %eax,%eax
  800af9:	78 6b                	js     800b66 <write+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800afb:	83 ec 08             	sub    $0x8,%esp
  800afe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b01:	50                   	push   %eax
  800b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b05:	ff 30                	pushl  (%eax)
  800b07:	e8 e2 fc ff ff       	call   8007ee <dev_lookup>
  800b0c:	83 c4 10             	add    $0x10,%esp
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	78 4a                	js     800b5d <write+0x7f>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b16:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b1a:	75 24                	jne    800b40 <write+0x62>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b1c:	a1 04 40 80 00       	mov    0x804004,%eax
  800b21:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800b27:	83 ec 04             	sub    $0x4,%esp
  800b2a:	53                   	push   %ebx
  800b2b:	50                   	push   %eax
  800b2c:	68 31 23 80 00       	push   $0x802331
  800b31:	e8 c4 09 00 00       	call   8014fa <cprintf>
		return -E_INVAL;
  800b36:	83 c4 10             	add    $0x10,%esp
  800b39:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800b3e:	eb 26                	jmp    800b66 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b43:	8b 52 0c             	mov    0xc(%edx),%edx
  800b46:	85 d2                	test   %edx,%edx
  800b48:	74 17                	je     800b61 <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b4a:	83 ec 04             	sub    $0x4,%esp
  800b4d:	ff 75 10             	pushl  0x10(%ebp)
  800b50:	ff 75 0c             	pushl  0xc(%ebp)
  800b53:	50                   	push   %eax
  800b54:	ff d2                	call   *%edx
  800b56:	89 c2                	mov    %eax,%edx
  800b58:	83 c4 10             	add    $0x10,%esp
  800b5b:	eb 09                	jmp    800b66 <write+0x88>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b5d:	89 c2                	mov    %eax,%edx
  800b5f:	eb 05                	jmp    800b66 <write+0x88>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800b61:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800b66:	89 d0                	mov    %edx,%eax
  800b68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <seek>:

int
seek(int fdnum, off_t offset)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800b73:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800b76:	50                   	push   %eax
  800b77:	ff 75 08             	pushl  0x8(%ebp)
  800b7a:	e8 19 fc ff ff       	call   800798 <fd_lookup>
  800b7f:	83 c4 08             	add    $0x8,%esp
  800b82:	85 c0                	test   %eax,%eax
  800b84:	78 0e                	js     800b94 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800b86:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    

00800b96 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	53                   	push   %ebx
  800b9a:	83 ec 14             	sub    $0x14,%esp
  800b9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800ba0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ba3:	50                   	push   %eax
  800ba4:	53                   	push   %ebx
  800ba5:	e8 ee fb ff ff       	call   800798 <fd_lookup>
  800baa:	83 c4 08             	add    $0x8,%esp
  800bad:	89 c2                	mov    %eax,%edx
  800baf:	85 c0                	test   %eax,%eax
  800bb1:	78 68                	js     800c1b <ftruncate+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bb3:	83 ec 08             	sub    $0x8,%esp
  800bb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800bb9:	50                   	push   %eax
  800bba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bbd:	ff 30                	pushl  (%eax)
  800bbf:	e8 2a fc ff ff       	call   8007ee <dev_lookup>
  800bc4:	83 c4 10             	add    $0x10,%esp
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	78 47                	js     800c12 <ftruncate+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800bd2:	75 24                	jne    800bf8 <ftruncate+0x62>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800bd4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800bd9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  800bdf:	83 ec 04             	sub    $0x4,%esp
  800be2:	53                   	push   %ebx
  800be3:	50                   	push   %eax
  800be4:	68 f4 22 80 00       	push   $0x8022f4
  800be9:	e8 0c 09 00 00       	call   8014fa <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800bee:	83 c4 10             	add    $0x10,%esp
  800bf1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800bf6:	eb 23                	jmp    800c1b <ftruncate+0x85>
	}
	if (!dev->dev_trunc)
  800bf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bfb:	8b 52 18             	mov    0x18(%edx),%edx
  800bfe:	85 d2                	test   %edx,%edx
  800c00:	74 14                	je     800c16 <ftruncate+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c02:	83 ec 08             	sub    $0x8,%esp
  800c05:	ff 75 0c             	pushl  0xc(%ebp)
  800c08:	50                   	push   %eax
  800c09:	ff d2                	call   *%edx
  800c0b:	89 c2                	mov    %eax,%edx
  800c0d:	83 c4 10             	add    $0x10,%esp
  800c10:	eb 09                	jmp    800c1b <ftruncate+0x85>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c12:	89 c2                	mov    %eax,%edx
  800c14:	eb 05                	jmp    800c1b <ftruncate+0x85>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c16:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800c1b:	89 d0                	mov    %edx,%eax
  800c1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	53                   	push   %ebx
  800c26:	83 ec 14             	sub    $0x14,%esp
  800c29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c2c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c2f:	50                   	push   %eax
  800c30:	ff 75 08             	pushl  0x8(%ebp)
  800c33:	e8 60 fb ff ff       	call   800798 <fd_lookup>
  800c38:	83 c4 08             	add    $0x8,%esp
  800c3b:	89 c2                	mov    %eax,%edx
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	78 58                	js     800c99 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c41:	83 ec 08             	sub    $0x8,%esp
  800c44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c47:	50                   	push   %eax
  800c48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c4b:	ff 30                	pushl  (%eax)
  800c4d:	e8 9c fb ff ff       	call   8007ee <dev_lookup>
  800c52:	83 c4 10             	add    $0x10,%esp
  800c55:	85 c0                	test   %eax,%eax
  800c57:	78 37                	js     800c90 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c60:	74 32                	je     800c94 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c62:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c65:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c6c:	00 00 00 
	stat->st_isdir = 0;
  800c6f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c76:	00 00 00 
	stat->st_dev = dev;
  800c79:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c7f:	83 ec 08             	sub    $0x8,%esp
  800c82:	53                   	push   %ebx
  800c83:	ff 75 f0             	pushl  -0x10(%ebp)
  800c86:	ff 50 14             	call   *0x14(%eax)
  800c89:	89 c2                	mov    %eax,%edx
  800c8b:	83 c4 10             	add    $0x10,%esp
  800c8e:	eb 09                	jmp    800c99 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c90:	89 c2                	mov    %eax,%edx
  800c92:	eb 05                	jmp    800c99 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800c94:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800c99:	89 d0                	mov    %edx,%eax
  800c9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800ca5:	83 ec 08             	sub    $0x8,%esp
  800ca8:	6a 00                	push   $0x0
  800caa:	ff 75 08             	pushl  0x8(%ebp)
  800cad:	e8 e3 01 00 00       	call   800e95 <open>
  800cb2:	89 c3                	mov    %eax,%ebx
  800cb4:	83 c4 10             	add    $0x10,%esp
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	78 1b                	js     800cd6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800cbb:	83 ec 08             	sub    $0x8,%esp
  800cbe:	ff 75 0c             	pushl  0xc(%ebp)
  800cc1:	50                   	push   %eax
  800cc2:	e8 5b ff ff ff       	call   800c22 <fstat>
  800cc7:	89 c6                	mov    %eax,%esi
	close(fd);
  800cc9:	89 1c 24             	mov    %ebx,(%esp)
  800ccc:	e8 f4 fb ff ff       	call   8008c5 <close>
	return r;
  800cd1:	83 c4 10             	add    $0x10,%esp
  800cd4:	89 f0                	mov    %esi,%eax
}
  800cd6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	89 c6                	mov    %eax,%esi
  800ce4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800ce6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800ced:	75 12                	jne    800d01 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	6a 01                	push   $0x1
  800cf4:	e8 15 12 00 00       	call   801f0e <ipc_find_env>
  800cf9:	a3 00 40 80 00       	mov    %eax,0x804000
  800cfe:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d01:	6a 07                	push   $0x7
  800d03:	68 00 50 80 00       	push   $0x805000
  800d08:	56                   	push   %esi
  800d09:	ff 35 00 40 80 00    	pushl  0x804000
  800d0f:	e8 98 11 00 00       	call   801eac <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d14:	83 c4 0c             	add    $0xc,%esp
  800d17:	6a 00                	push   $0x0
  800d19:	53                   	push   %ebx
  800d1a:	6a 00                	push   $0x0
  800d1c:	e8 10 11 00 00       	call   801e31 <ipc_recv>
}
  800d21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	8b 40 0c             	mov    0xc(%eax),%eax
  800d34:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d41:	ba 00 00 00 00       	mov    $0x0,%edx
  800d46:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4b:	e8 8d ff ff ff       	call   800cdd <fsipc>
}
  800d50:	c9                   	leave  
  800d51:	c3                   	ret    

00800d52 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	8b 40 0c             	mov    0xc(%eax),%eax
  800d5e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d63:	ba 00 00 00 00       	mov    $0x0,%edx
  800d68:	b8 06 00 00 00       	mov    $0x6,%eax
  800d6d:	e8 6b ff ff ff       	call   800cdd <fsipc>
}
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <devfile_stat>:
	return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	53                   	push   %ebx
  800d78:	83 ec 04             	sub    $0x4,%esp
  800d7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	8b 40 0c             	mov    0xc(%eax),%eax
  800d84:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800d89:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d93:	e8 45 ff ff ff       	call   800cdd <fsipc>
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	78 2c                	js     800dc8 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800d9c:	83 ec 08             	sub    $0x8,%esp
  800d9f:	68 00 50 80 00       	push   $0x805000
  800da4:	53                   	push   %ebx
  800da5:	e8 d5 0c 00 00       	call   801a7f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800daa:	a1 80 50 80 00       	mov    0x805080,%eax
  800daf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800db5:	a1 84 50 80 00       	mov    0x805084,%eax
  800dba:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800dc0:	83 c4 10             	add    $0x10,%esp
  800dc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    

00800dcd <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	83 ec 0c             	sub    $0xc,%esp
  800dd3:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	8b 52 0c             	mov    0xc(%edx),%edx
  800ddc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  800de2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800de7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800dec:	0f 47 c2             	cmova  %edx,%eax
  800def:	a3 04 50 80 00       	mov    %eax,0x805004
	
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800df4:	50                   	push   %eax
  800df5:	ff 75 0c             	pushl  0xc(%ebp)
  800df8:	68 08 50 80 00       	push   $0x805008
  800dfd:	e8 0f 0e 00 00       	call   801c11 <memmove>

	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0) {
  800e02:	ba 00 00 00 00       	mov    $0x0,%edx
  800e07:	b8 04 00 00 00       	mov    $0x4,%eax
  800e0c:	e8 cc fe ff ff       	call   800cdd <fsipc>
		return r;
	}
	
	//panic("devfile_write not implemented");
	return r;
}
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1e:	8b 40 0c             	mov    0xc(%eax),%eax
  800e21:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e26:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e31:	b8 03 00 00 00       	mov    $0x3,%eax
  800e36:	e8 a2 fe ff ff       	call   800cdd <fsipc>
  800e3b:	89 c3                	mov    %eax,%ebx
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	78 4b                	js     800e8c <devfile_read+0x79>
		return r;
	assert(r <= n);
  800e41:	39 c6                	cmp    %eax,%esi
  800e43:	73 16                	jae    800e5b <devfile_read+0x48>
  800e45:	68 60 23 80 00       	push   $0x802360
  800e4a:	68 67 23 80 00       	push   $0x802367
  800e4f:	6a 7c                	push   $0x7c
  800e51:	68 7c 23 80 00       	push   $0x80237c
  800e56:	e8 c6 05 00 00       	call   801421 <_panic>
	assert(r <= PGSIZE);
  800e5b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e60:	7e 16                	jle    800e78 <devfile_read+0x65>
  800e62:	68 87 23 80 00       	push   $0x802387
  800e67:	68 67 23 80 00       	push   $0x802367
  800e6c:	6a 7d                	push   $0x7d
  800e6e:	68 7c 23 80 00       	push   $0x80237c
  800e73:	e8 a9 05 00 00       	call   801421 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e78:	83 ec 04             	sub    $0x4,%esp
  800e7b:	50                   	push   %eax
  800e7c:	68 00 50 80 00       	push   $0x805000
  800e81:	ff 75 0c             	pushl  0xc(%ebp)
  800e84:	e8 88 0d 00 00       	call   801c11 <memmove>
	return r;
  800e89:	83 c4 10             	add    $0x10,%esp
}
  800e8c:	89 d8                	mov    %ebx,%eax
  800e8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	53                   	push   %ebx
  800e99:	83 ec 20             	sub    $0x20,%esp
  800e9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800e9f:	53                   	push   %ebx
  800ea0:	e8 a1 0b 00 00       	call   801a46 <strlen>
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ead:	7f 67                	jg     800f16 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800eaf:	83 ec 0c             	sub    $0xc,%esp
  800eb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb5:	50                   	push   %eax
  800eb6:	e8 8e f8 ff ff       	call   800749 <fd_alloc>
  800ebb:	83 c4 10             	add    $0x10,%esp
		return r;
  800ebe:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	78 57                	js     800f1b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ec4:	83 ec 08             	sub    $0x8,%esp
  800ec7:	53                   	push   %ebx
  800ec8:	68 00 50 80 00       	push   $0x805000
  800ecd:	e8 ad 0b 00 00       	call   801a7f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ed2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed5:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800eda:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800edd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee2:	e8 f6 fd ff ff       	call   800cdd <fsipc>
  800ee7:	89 c3                	mov    %eax,%ebx
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	85 c0                	test   %eax,%eax
  800eee:	79 14                	jns    800f04 <open+0x6f>
		fd_close(fd, 0);
  800ef0:	83 ec 08             	sub    $0x8,%esp
  800ef3:	6a 00                	push   $0x0
  800ef5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef8:	e8 47 f9 ff ff       	call   800844 <fd_close>
		return r;
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	89 da                	mov    %ebx,%edx
  800f02:	eb 17                	jmp    800f1b <open+0x86>
	}

	return fd2num(fd);
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0a:	e8 13 f8 ff ff       	call   800722 <fd2num>
  800f0f:	89 c2                	mov    %eax,%edx
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	eb 05                	jmp    800f1b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f16:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f1b:	89 d0                	mov    %edx,%eax
  800f1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f28:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f32:	e8 a6 fd ff ff       	call   800cdd <fsipc>
}
  800f37:	c9                   	leave  
  800f38:	c3                   	ret    

00800f39 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f41:	83 ec 0c             	sub    $0xc,%esp
  800f44:	ff 75 08             	pushl  0x8(%ebp)
  800f47:	e8 e6 f7 ff ff       	call   800732 <fd2data>
  800f4c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f4e:	83 c4 08             	add    $0x8,%esp
  800f51:	68 93 23 80 00       	push   $0x802393
  800f56:	53                   	push   %ebx
  800f57:	e8 23 0b 00 00       	call   801a7f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f5c:	8b 46 04             	mov    0x4(%esi),%eax
  800f5f:	2b 06                	sub    (%esi),%eax
  800f61:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f67:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f6e:	00 00 00 
	stat->st_dev = &devpipe;
  800f71:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f78:	30 80 00 
	return 0;
}
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5e                   	pop    %esi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	53                   	push   %ebx
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800f91:	53                   	push   %ebx
  800f92:	6a 00                	push   $0x0
  800f94:	e8 7f f2 ff ff       	call   800218 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800f99:	89 1c 24             	mov    %ebx,(%esp)
  800f9c:	e8 91 f7 ff ff       	call   800732 <fd2data>
  800fa1:	83 c4 08             	add    $0x8,%esp
  800fa4:	50                   	push   %eax
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 6c f2 ff ff       	call   800218 <sys_page_unmap>
}
  800fac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	57                   	push   %edi
  800fb5:	56                   	push   %esi
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 1c             	sub    $0x1c,%esp
  800fba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fbd:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800fbf:	a1 04 40 80 00       	mov    0x804004,%eax
  800fc4:	8b b0 b4 00 00 00    	mov    0xb4(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800fca:	83 ec 0c             	sub    $0xc,%esp
  800fcd:	ff 75 e0             	pushl  -0x20(%ebp)
  800fd0:	e8 7e 0f 00 00       	call   801f53 <pageref>
  800fd5:	89 c3                	mov    %eax,%ebx
  800fd7:	89 3c 24             	mov    %edi,(%esp)
  800fda:	e8 74 0f 00 00       	call   801f53 <pageref>
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	39 c3                	cmp    %eax,%ebx
  800fe4:	0f 94 c1             	sete   %cl
  800fe7:	0f b6 c9             	movzbl %cl,%ecx
  800fea:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800fed:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800ff3:	8b 8a b4 00 00 00    	mov    0xb4(%edx),%ecx
		if (n == nn)
  800ff9:	39 ce                	cmp    %ecx,%esi
  800ffb:	74 1e                	je     80101b <_pipeisclosed+0x6a>
			return ret;
		if (n != nn && ret == 1)
  800ffd:	39 c3                	cmp    %eax,%ebx
  800fff:	75 be                	jne    800fbf <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801001:	8b 82 b4 00 00 00    	mov    0xb4(%edx),%eax
  801007:	ff 75 e4             	pushl  -0x1c(%ebp)
  80100a:	50                   	push   %eax
  80100b:	56                   	push   %esi
  80100c:	68 9a 23 80 00       	push   $0x80239a
  801011:	e8 e4 04 00 00       	call   8014fa <cprintf>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	eb a4                	jmp    800fbf <_pipeisclosed+0xe>
	}
}
  80101b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80101e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	57                   	push   %edi
  80102a:	56                   	push   %esi
  80102b:	53                   	push   %ebx
  80102c:	83 ec 28             	sub    $0x28,%esp
  80102f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801032:	56                   	push   %esi
  801033:	e8 fa f6 ff ff       	call   800732 <fd2data>
  801038:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	bf 00 00 00 00       	mov    $0x0,%edi
  801042:	eb 4b                	jmp    80108f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801044:	89 da                	mov    %ebx,%edx
  801046:	89 f0                	mov    %esi,%eax
  801048:	e8 64 ff ff ff       	call   800fb1 <_pipeisclosed>
  80104d:	85 c0                	test   %eax,%eax
  80104f:	75 48                	jne    801099 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801051:	e8 1e f1 ff ff       	call   800174 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801056:	8b 43 04             	mov    0x4(%ebx),%eax
  801059:	8b 0b                	mov    (%ebx),%ecx
  80105b:	8d 51 20             	lea    0x20(%ecx),%edx
  80105e:	39 d0                	cmp    %edx,%eax
  801060:	73 e2                	jae    801044 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801062:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801065:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801069:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80106c:	89 c2                	mov    %eax,%edx
  80106e:	c1 fa 1f             	sar    $0x1f,%edx
  801071:	89 d1                	mov    %edx,%ecx
  801073:	c1 e9 1b             	shr    $0x1b,%ecx
  801076:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801079:	83 e2 1f             	and    $0x1f,%edx
  80107c:	29 ca                	sub    %ecx,%edx
  80107e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801082:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801086:	83 c0 01             	add    $0x1,%eax
  801089:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80108c:	83 c7 01             	add    $0x1,%edi
  80108f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801092:	75 c2                	jne    801056 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801094:	8b 45 10             	mov    0x10(%ebp),%eax
  801097:	eb 05                	jmp    80109e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801099:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80109e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 18             	sub    $0x18,%esp
  8010af:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8010b2:	57                   	push   %edi
  8010b3:	e8 7a f6 ff ff       	call   800732 <fd2data>
  8010b8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010c2:	eb 3d                	jmp    801101 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8010c4:	85 db                	test   %ebx,%ebx
  8010c6:	74 04                	je     8010cc <devpipe_read+0x26>
				return i;
  8010c8:	89 d8                	mov    %ebx,%eax
  8010ca:	eb 44                	jmp    801110 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8010cc:	89 f2                	mov    %esi,%edx
  8010ce:	89 f8                	mov    %edi,%eax
  8010d0:	e8 dc fe ff ff       	call   800fb1 <_pipeisclosed>
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	75 32                	jne    80110b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8010d9:	e8 96 f0 ff ff       	call   800174 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8010de:	8b 06                	mov    (%esi),%eax
  8010e0:	3b 46 04             	cmp    0x4(%esi),%eax
  8010e3:	74 df                	je     8010c4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010e5:	99                   	cltd   
  8010e6:	c1 ea 1b             	shr    $0x1b,%edx
  8010e9:	01 d0                	add    %edx,%eax
  8010eb:	83 e0 1f             	and    $0x1f,%eax
  8010ee:	29 d0                	sub    %edx,%eax
  8010f0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8010f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8010fb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010fe:	83 c3 01             	add    $0x1,%ebx
  801101:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801104:	75 d8                	jne    8010de <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801106:	8b 45 10             	mov    0x10(%ebp),%eax
  801109:	eb 05                	jmp    801110 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80110b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801120:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	e8 20 f6 ff ff       	call   800749 <fd_alloc>
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	85 c0                	test   %eax,%eax
  801130:	0f 88 2c 01 00 00    	js     801262 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801136:	83 ec 04             	sub    $0x4,%esp
  801139:	68 07 04 00 00       	push   $0x407
  80113e:	ff 75 f4             	pushl  -0xc(%ebp)
  801141:	6a 00                	push   $0x0
  801143:	e8 4b f0 ff ff       	call   800193 <sys_page_alloc>
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	89 c2                	mov    %eax,%edx
  80114d:	85 c0                	test   %eax,%eax
  80114f:	0f 88 0d 01 00 00    	js     801262 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80115b:	50                   	push   %eax
  80115c:	e8 e8 f5 ff ff       	call   800749 <fd_alloc>
  801161:	89 c3                	mov    %eax,%ebx
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	85 c0                	test   %eax,%eax
  801168:	0f 88 e2 00 00 00    	js     801250 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	68 07 04 00 00       	push   $0x407
  801176:	ff 75 f0             	pushl  -0x10(%ebp)
  801179:	6a 00                	push   $0x0
  80117b:	e8 13 f0 ff ff       	call   800193 <sys_page_alloc>
  801180:	89 c3                	mov    %eax,%ebx
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	85 c0                	test   %eax,%eax
  801187:	0f 88 c3 00 00 00    	js     801250 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80118d:	83 ec 0c             	sub    $0xc,%esp
  801190:	ff 75 f4             	pushl  -0xc(%ebp)
  801193:	e8 9a f5 ff ff       	call   800732 <fd2data>
  801198:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80119a:	83 c4 0c             	add    $0xc,%esp
  80119d:	68 07 04 00 00       	push   $0x407
  8011a2:	50                   	push   %eax
  8011a3:	6a 00                	push   $0x0
  8011a5:	e8 e9 ef ff ff       	call   800193 <sys_page_alloc>
  8011aa:	89 c3                	mov    %eax,%ebx
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	0f 88 89 00 00 00    	js     801240 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8011bd:	e8 70 f5 ff ff       	call   800732 <fd2data>
  8011c2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8011c9:	50                   	push   %eax
  8011ca:	6a 00                	push   $0x0
  8011cc:	56                   	push   %esi
  8011cd:	6a 00                	push   $0x0
  8011cf:	e8 02 f0 ff ff       	call   8001d6 <sys_page_map>
  8011d4:	89 c3                	mov    %eax,%ebx
  8011d6:	83 c4 20             	add    $0x20,%esp
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 55                	js     801232 <pipe+0x11a>
		goto err3;
	

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8011dd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011eb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8011f2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8011fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801200:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	ff 75 f4             	pushl  -0xc(%ebp)
  80120d:	e8 10 f5 ff ff       	call   800722 <fd2num>
  801212:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801215:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801217:	83 c4 04             	add    $0x4,%esp
  80121a:	ff 75 f0             	pushl  -0x10(%ebp)
  80121d:	e8 00 f5 ff ff       	call   800722 <fd2num>
  801222:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801225:	89 41 04             	mov    %eax,0x4(%ecx)

	return 0;
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	ba 00 00 00 00       	mov    $0x0,%edx
  801230:	eb 30                	jmp    801262 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801232:	83 ec 08             	sub    $0x8,%esp
  801235:	56                   	push   %esi
  801236:	6a 00                	push   $0x0
  801238:	e8 db ef ff ff       	call   800218 <sys_page_unmap>
  80123d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	ff 75 f0             	pushl  -0x10(%ebp)
  801246:	6a 00                	push   $0x0
  801248:	e8 cb ef ff ff       	call   800218 <sys_page_unmap>
  80124d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801250:	83 ec 08             	sub    $0x8,%esp
  801253:	ff 75 f4             	pushl  -0xc(%ebp)
  801256:	6a 00                	push   $0x0
  801258:	e8 bb ef ff ff       	call   800218 <sys_page_unmap>
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801262:	89 d0                	mov    %edx,%eax
  801264:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    

0080126b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	ff 75 08             	pushl  0x8(%ebp)
  801278:	e8 1b f5 ff ff       	call   800798 <fd_lookup>
  80127d:	83 c4 10             	add    $0x10,%esp
  801280:	85 c0                	test   %eax,%eax
  801282:	78 18                	js     80129c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801284:	83 ec 0c             	sub    $0xc,%esp
  801287:	ff 75 f4             	pushl  -0xc(%ebp)
  80128a:	e8 a3 f4 ff ff       	call   800732 <fd2data>
	return _pipeisclosed(fd, p);
  80128f:	89 c2                	mov    %eax,%edx
  801291:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801294:	e8 18 fd ff ff       	call   800fb1 <_pipeisclosed>
  801299:	83 c4 10             	add    $0x10,%esp
}
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    

0080129e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8012a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8012ae:	68 b2 23 80 00       	push   $0x8023b2
  8012b3:	ff 75 0c             	pushl  0xc(%ebp)
  8012b6:	e8 c4 07 00 00       	call   801a7f <strcpy>
	return 0;
}
  8012bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c0:	c9                   	leave  
  8012c1:	c3                   	ret    

008012c2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	57                   	push   %edi
  8012c6:	56                   	push   %esi
  8012c7:	53                   	push   %ebx
  8012c8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012ce:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012d3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8012d9:	eb 2d                	jmp    801308 <devcons_write+0x46>
		m = n - tot;
  8012db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012de:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8012e0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8012e3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8012e8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8012eb:	83 ec 04             	sub    $0x4,%esp
  8012ee:	53                   	push   %ebx
  8012ef:	03 45 0c             	add    0xc(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	57                   	push   %edi
  8012f4:	e8 18 09 00 00       	call   801c11 <memmove>
		sys_cputs(buf, m);
  8012f9:	83 c4 08             	add    $0x8,%esp
  8012fc:	53                   	push   %ebx
  8012fd:	57                   	push   %edi
  8012fe:	e8 d4 ed ff ff       	call   8000d7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801303:	01 de                	add    %ebx,%esi
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	89 f0                	mov    %esi,%eax
  80130a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80130d:	72 cc                	jb     8012db <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80130f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801312:	5b                   	pop    %ebx
  801313:	5e                   	pop    %esi
  801314:	5f                   	pop    %edi
  801315:	5d                   	pop    %ebp
  801316:	c3                   	ret    

00801317 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801317:	55                   	push   %ebp
  801318:	89 e5                	mov    %esp,%ebp
  80131a:	83 ec 08             	sub    $0x8,%esp
  80131d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801322:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801326:	74 2a                	je     801352 <devcons_read+0x3b>
  801328:	eb 05                	jmp    80132f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80132a:	e8 45 ee ff ff       	call   800174 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80132f:	e8 c1 ed ff ff       	call   8000f5 <sys_cgetc>
  801334:	85 c0                	test   %eax,%eax
  801336:	74 f2                	je     80132a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 16                	js     801352 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80133c:	83 f8 04             	cmp    $0x4,%eax
  80133f:	74 0c                	je     80134d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801341:	8b 55 0c             	mov    0xc(%ebp),%edx
  801344:	88 02                	mov    %al,(%edx)
	return 1;
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	eb 05                	jmp    801352 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80134d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80135a:	8b 45 08             	mov    0x8(%ebp),%eax
  80135d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801360:	6a 01                	push   $0x1
  801362:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801365:	50                   	push   %eax
  801366:	e8 6c ed ff ff       	call   8000d7 <sys_cputs>
}
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <getchar>:

int
getchar(void)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801376:	6a 01                	push   $0x1
  801378:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80137b:	50                   	push   %eax
  80137c:	6a 00                	push   $0x0
  80137e:	e8 7e f6 ff ff       	call   800a01 <read>
	if (r < 0)
  801383:	83 c4 10             	add    $0x10,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 0f                	js     801399 <getchar+0x29>
		return r;
	if (r < 1)
  80138a:	85 c0                	test   %eax,%eax
  80138c:	7e 06                	jle    801394 <getchar+0x24>
		return -E_EOF;
	return c;
  80138e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801392:	eb 05                	jmp    801399 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801394:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801399:	c9                   	leave  
  80139a:	c3                   	ret    

0080139b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80139b:	55                   	push   %ebp
  80139c:	89 e5                	mov    %esp,%ebp
  80139e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a4:	50                   	push   %eax
  8013a5:	ff 75 08             	pushl  0x8(%ebp)
  8013a8:	e8 eb f3 ff ff       	call   800798 <fd_lookup>
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	78 11                	js     8013c5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8013b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013bd:	39 10                	cmp    %edx,(%eax)
  8013bf:	0f 94 c0             	sete   %al
  8013c2:	0f b6 c0             	movzbl %al,%eax
}
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <opencons>:

int
opencons(void)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	e8 73 f3 ff ff       	call   800749 <fd_alloc>
  8013d6:	83 c4 10             	add    $0x10,%esp
		return r;
  8013d9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 3e                	js     80141d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013df:	83 ec 04             	sub    $0x4,%esp
  8013e2:	68 07 04 00 00       	push   $0x407
  8013e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013ea:	6a 00                	push   $0x0
  8013ec:	e8 a2 ed ff ff       	call   800193 <sys_page_alloc>
  8013f1:	83 c4 10             	add    $0x10,%esp
		return r;
  8013f4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 23                	js     80141d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8013fa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801400:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801403:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801405:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801408:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80140f:	83 ec 0c             	sub    $0xc,%esp
  801412:	50                   	push   %eax
  801413:	e8 0a f3 ff ff       	call   800722 <fd2num>
  801418:	89 c2                	mov    %eax,%edx
  80141a:	83 c4 10             	add    $0x10,%esp
}
  80141d:	89 d0                	mov    %edx,%eax
  80141f:	c9                   	leave  
  801420:	c3                   	ret    

00801421 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	56                   	push   %esi
  801425:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801426:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801429:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80142f:	e8 21 ed ff ff       	call   800155 <sys_getenvid>
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	ff 75 0c             	pushl  0xc(%ebp)
  80143a:	ff 75 08             	pushl  0x8(%ebp)
  80143d:	56                   	push   %esi
  80143e:	50                   	push   %eax
  80143f:	68 c0 23 80 00       	push   $0x8023c0
  801444:	e8 b1 00 00 00       	call   8014fa <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801449:	83 c4 18             	add    $0x18,%esp
  80144c:	53                   	push   %ebx
  80144d:	ff 75 10             	pushl  0x10(%ebp)
  801450:	e8 54 00 00 00       	call   8014a9 <vcprintf>
	cprintf("\n");
  801455:	c7 04 24 ab 23 80 00 	movl   $0x8023ab,(%esp)
  80145c:	e8 99 00 00 00       	call   8014fa <cprintf>
  801461:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801464:	cc                   	int3   
  801465:	eb fd                	jmp    801464 <_panic+0x43>

00801467 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	53                   	push   %ebx
  80146b:	83 ec 04             	sub    $0x4,%esp
  80146e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801471:	8b 13                	mov    (%ebx),%edx
  801473:	8d 42 01             	lea    0x1(%edx),%eax
  801476:	89 03                	mov    %eax,(%ebx)
  801478:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80147f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801484:	75 1a                	jne    8014a0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	68 ff 00 00 00       	push   $0xff
  80148e:	8d 43 08             	lea    0x8(%ebx),%eax
  801491:	50                   	push   %eax
  801492:	e8 40 ec ff ff       	call   8000d7 <sys_cputs>
		b->idx = 0;
  801497:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80149d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8014a0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8014a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8014b2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8014b9:	00 00 00 
	b.cnt = 0;
  8014bc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8014c3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8014c6:	ff 75 0c             	pushl  0xc(%ebp)
  8014c9:	ff 75 08             	pushl  0x8(%ebp)
  8014cc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	68 67 14 80 00       	push   $0x801467
  8014d8:	e8 54 01 00 00       	call   801631 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014dd:	83 c4 08             	add    $0x8,%esp
  8014e0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014e6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014ec:	50                   	push   %eax
  8014ed:	e8 e5 eb ff ff       	call   8000d7 <sys_cputs>

	return b.cnt;
}
  8014f2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014f8:	c9                   	leave  
  8014f9:	c3                   	ret    

008014fa <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801500:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801503:	50                   	push   %eax
  801504:	ff 75 08             	pushl  0x8(%ebp)
  801507:	e8 9d ff ff ff       	call   8014a9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	57                   	push   %edi
  801512:	56                   	push   %esi
  801513:	53                   	push   %ebx
  801514:	83 ec 1c             	sub    $0x1c,%esp
  801517:	89 c7                	mov    %eax,%edi
  801519:	89 d6                	mov    %edx,%esi
  80151b:	8b 45 08             	mov    0x8(%ebp),%eax
  80151e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801521:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801524:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801527:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80152a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801532:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801535:	39 d3                	cmp    %edx,%ebx
  801537:	72 05                	jb     80153e <printnum+0x30>
  801539:	39 45 10             	cmp    %eax,0x10(%ebp)
  80153c:	77 45                	ja     801583 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80153e:	83 ec 0c             	sub    $0xc,%esp
  801541:	ff 75 18             	pushl  0x18(%ebp)
  801544:	8b 45 14             	mov    0x14(%ebp),%eax
  801547:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80154a:	53                   	push   %ebx
  80154b:	ff 75 10             	pushl  0x10(%ebp)
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	ff 75 e4             	pushl  -0x1c(%ebp)
  801554:	ff 75 e0             	pushl  -0x20(%ebp)
  801557:	ff 75 dc             	pushl  -0x24(%ebp)
  80155a:	ff 75 d8             	pushl  -0x28(%ebp)
  80155d:	e8 2e 0a 00 00       	call   801f90 <__udivdi3>
  801562:	83 c4 18             	add    $0x18,%esp
  801565:	52                   	push   %edx
  801566:	50                   	push   %eax
  801567:	89 f2                	mov    %esi,%edx
  801569:	89 f8                	mov    %edi,%eax
  80156b:	e8 9e ff ff ff       	call   80150e <printnum>
  801570:	83 c4 20             	add    $0x20,%esp
  801573:	eb 18                	jmp    80158d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	56                   	push   %esi
  801579:	ff 75 18             	pushl  0x18(%ebp)
  80157c:	ff d7                	call   *%edi
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	eb 03                	jmp    801586 <printnum+0x78>
  801583:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801586:	83 eb 01             	sub    $0x1,%ebx
  801589:	85 db                	test   %ebx,%ebx
  80158b:	7f e8                	jg     801575 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	56                   	push   %esi
  801591:	83 ec 04             	sub    $0x4,%esp
  801594:	ff 75 e4             	pushl  -0x1c(%ebp)
  801597:	ff 75 e0             	pushl  -0x20(%ebp)
  80159a:	ff 75 dc             	pushl  -0x24(%ebp)
  80159d:	ff 75 d8             	pushl  -0x28(%ebp)
  8015a0:	e8 1b 0b 00 00       	call   8020c0 <__umoddi3>
  8015a5:	83 c4 14             	add    $0x14,%esp
  8015a8:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  8015af:	50                   	push   %eax
  8015b0:	ff d7                	call   *%edi
}
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b8:	5b                   	pop    %ebx
  8015b9:	5e                   	pop    %esi
  8015ba:	5f                   	pop    %edi
  8015bb:	5d                   	pop    %ebp
  8015bc:	c3                   	ret    

008015bd <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8015c0:	83 fa 01             	cmp    $0x1,%edx
  8015c3:	7e 0e                	jle    8015d3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8015c5:	8b 10                	mov    (%eax),%edx
  8015c7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8015ca:	89 08                	mov    %ecx,(%eax)
  8015cc:	8b 02                	mov    (%edx),%eax
  8015ce:	8b 52 04             	mov    0x4(%edx),%edx
  8015d1:	eb 22                	jmp    8015f5 <getuint+0x38>
	else if (lflag)
  8015d3:	85 d2                	test   %edx,%edx
  8015d5:	74 10                	je     8015e7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8015d7:	8b 10                	mov    (%eax),%edx
  8015d9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015dc:	89 08                	mov    %ecx,(%eax)
  8015de:	8b 02                	mov    (%edx),%eax
  8015e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e5:	eb 0e                	jmp    8015f5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015e7:	8b 10                	mov    (%eax),%edx
  8015e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015ec:	89 08                	mov    %ecx,(%eax)
  8015ee:	8b 02                	mov    (%edx),%eax
  8015f0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015f5:	5d                   	pop    %ebp
  8015f6:	c3                   	ret    

008015f7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015fd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801601:	8b 10                	mov    (%eax),%edx
  801603:	3b 50 04             	cmp    0x4(%eax),%edx
  801606:	73 0a                	jae    801612 <sprintputch+0x1b>
		*b->buf++ = ch;
  801608:	8d 4a 01             	lea    0x1(%edx),%ecx
  80160b:	89 08                	mov    %ecx,(%eax)
  80160d:	8b 45 08             	mov    0x8(%ebp),%eax
  801610:	88 02                	mov    %al,(%edx)
}
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80161a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80161d:	50                   	push   %eax
  80161e:	ff 75 10             	pushl  0x10(%ebp)
  801621:	ff 75 0c             	pushl  0xc(%ebp)
  801624:	ff 75 08             	pushl  0x8(%ebp)
  801627:	e8 05 00 00 00       	call   801631 <vprintfmt>
	va_end(ap);
}
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	57                   	push   %edi
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
  801637:	83 ec 2c             	sub    $0x2c,%esp
  80163a:	8b 75 08             	mov    0x8(%ebp),%esi
  80163d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801640:	8b 7d 10             	mov    0x10(%ebp),%edi
  801643:	eb 12                	jmp    801657 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801645:	85 c0                	test   %eax,%eax
  801647:	0f 84 89 03 00 00    	je     8019d6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	53                   	push   %ebx
  801651:	50                   	push   %eax
  801652:	ff d6                	call   *%esi
  801654:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801657:	83 c7 01             	add    $0x1,%edi
  80165a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80165e:	83 f8 25             	cmp    $0x25,%eax
  801661:	75 e2                	jne    801645 <vprintfmt+0x14>
  801663:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801667:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80166e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801675:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80167c:	ba 00 00 00 00       	mov    $0x0,%edx
  801681:	eb 07                	jmp    80168a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801683:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801686:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80168a:	8d 47 01             	lea    0x1(%edi),%eax
  80168d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801690:	0f b6 07             	movzbl (%edi),%eax
  801693:	0f b6 c8             	movzbl %al,%ecx
  801696:	83 e8 23             	sub    $0x23,%eax
  801699:	3c 55                	cmp    $0x55,%al
  80169b:	0f 87 1a 03 00 00    	ja     8019bb <vprintfmt+0x38a>
  8016a1:	0f b6 c0             	movzbl %al,%eax
  8016a4:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  8016ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8016ae:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8016b2:	eb d6                	jmp    80168a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8016bf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8016c2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8016c6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8016c9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8016cc:	83 fa 09             	cmp    $0x9,%edx
  8016cf:	77 39                	ja     80170a <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8016d1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8016d4:	eb e9                	jmp    8016bf <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8016d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d9:	8d 48 04             	lea    0x4(%eax),%ecx
  8016dc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8016df:	8b 00                	mov    (%eax),%eax
  8016e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8016e7:	eb 27                	jmp    801710 <vprintfmt+0xdf>
  8016e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016f3:	0f 49 c8             	cmovns %eax,%ecx
  8016f6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016fc:	eb 8c                	jmp    80168a <vprintfmt+0x59>
  8016fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801701:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801708:	eb 80                	jmp    80168a <vprintfmt+0x59>
  80170a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80170d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801710:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801714:	0f 89 70 ff ff ff    	jns    80168a <vprintfmt+0x59>
				width = precision, precision = -1;
  80171a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80171d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801720:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801727:	e9 5e ff ff ff       	jmp    80168a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80172c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80172f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801732:	e9 53 ff ff ff       	jmp    80168a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801737:	8b 45 14             	mov    0x14(%ebp),%eax
  80173a:	8d 50 04             	lea    0x4(%eax),%edx
  80173d:	89 55 14             	mov    %edx,0x14(%ebp)
  801740:	83 ec 08             	sub    $0x8,%esp
  801743:	53                   	push   %ebx
  801744:	ff 30                	pushl  (%eax)
  801746:	ff d6                	call   *%esi
			break;
  801748:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80174b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80174e:	e9 04 ff ff ff       	jmp    801657 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801753:	8b 45 14             	mov    0x14(%ebp),%eax
  801756:	8d 50 04             	lea    0x4(%eax),%edx
  801759:	89 55 14             	mov    %edx,0x14(%ebp)
  80175c:	8b 00                	mov    (%eax),%eax
  80175e:	99                   	cltd   
  80175f:	31 d0                	xor    %edx,%eax
  801761:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801763:	83 f8 0f             	cmp    $0xf,%eax
  801766:	7f 0b                	jg     801773 <vprintfmt+0x142>
  801768:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80176f:	85 d2                	test   %edx,%edx
  801771:	75 18                	jne    80178b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801773:	50                   	push   %eax
  801774:	68 fb 23 80 00       	push   $0x8023fb
  801779:	53                   	push   %ebx
  80177a:	56                   	push   %esi
  80177b:	e8 94 fe ff ff       	call   801614 <printfmt>
  801780:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801783:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801786:	e9 cc fe ff ff       	jmp    801657 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80178b:	52                   	push   %edx
  80178c:	68 79 23 80 00       	push   $0x802379
  801791:	53                   	push   %ebx
  801792:	56                   	push   %esi
  801793:	e8 7c fe ff ff       	call   801614 <printfmt>
  801798:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80179e:	e9 b4 fe ff ff       	jmp    801657 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8017a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a6:	8d 50 04             	lea    0x4(%eax),%edx
  8017a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8017ac:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8017ae:	85 ff                	test   %edi,%edi
  8017b0:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  8017b5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8017b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017bc:	0f 8e 94 00 00 00    	jle    801856 <vprintfmt+0x225>
  8017c2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8017c6:	0f 84 98 00 00 00    	je     801864 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	ff 75 d0             	pushl  -0x30(%ebp)
  8017d2:	57                   	push   %edi
  8017d3:	e8 86 02 00 00       	call   801a5e <strnlen>
  8017d8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017db:	29 c1                	sub    %eax,%ecx
  8017dd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8017e0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8017e3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8017e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017ea:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017ed:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017ef:	eb 0f                	jmp    801800 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	53                   	push   %ebx
  8017f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8017f8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017fa:	83 ef 01             	sub    $0x1,%edi
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	85 ff                	test   %edi,%edi
  801802:	7f ed                	jg     8017f1 <vprintfmt+0x1c0>
  801804:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801807:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80180a:	85 c9                	test   %ecx,%ecx
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
  801811:	0f 49 c1             	cmovns %ecx,%eax
  801814:	29 c1                	sub    %eax,%ecx
  801816:	89 75 08             	mov    %esi,0x8(%ebp)
  801819:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80181c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80181f:	89 cb                	mov    %ecx,%ebx
  801821:	eb 4d                	jmp    801870 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801823:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801827:	74 1b                	je     801844 <vprintfmt+0x213>
  801829:	0f be c0             	movsbl %al,%eax
  80182c:	83 e8 20             	sub    $0x20,%eax
  80182f:	83 f8 5e             	cmp    $0x5e,%eax
  801832:	76 10                	jbe    801844 <vprintfmt+0x213>
					putch('?', putdat);
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	ff 75 0c             	pushl  0xc(%ebp)
  80183a:	6a 3f                	push   $0x3f
  80183c:	ff 55 08             	call   *0x8(%ebp)
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	eb 0d                	jmp    801851 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	ff 75 0c             	pushl  0xc(%ebp)
  80184a:	52                   	push   %edx
  80184b:	ff 55 08             	call   *0x8(%ebp)
  80184e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801851:	83 eb 01             	sub    $0x1,%ebx
  801854:	eb 1a                	jmp    801870 <vprintfmt+0x23f>
  801856:	89 75 08             	mov    %esi,0x8(%ebp)
  801859:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80185c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80185f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801862:	eb 0c                	jmp    801870 <vprintfmt+0x23f>
  801864:	89 75 08             	mov    %esi,0x8(%ebp)
  801867:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80186a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80186d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801870:	83 c7 01             	add    $0x1,%edi
  801873:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801877:	0f be d0             	movsbl %al,%edx
  80187a:	85 d2                	test   %edx,%edx
  80187c:	74 23                	je     8018a1 <vprintfmt+0x270>
  80187e:	85 f6                	test   %esi,%esi
  801880:	78 a1                	js     801823 <vprintfmt+0x1f2>
  801882:	83 ee 01             	sub    $0x1,%esi
  801885:	79 9c                	jns    801823 <vprintfmt+0x1f2>
  801887:	89 df                	mov    %ebx,%edi
  801889:	8b 75 08             	mov    0x8(%ebp),%esi
  80188c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80188f:	eb 18                	jmp    8018a9 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801891:	83 ec 08             	sub    $0x8,%esp
  801894:	53                   	push   %ebx
  801895:	6a 20                	push   $0x20
  801897:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801899:	83 ef 01             	sub    $0x1,%edi
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	eb 08                	jmp    8018a9 <vprintfmt+0x278>
  8018a1:	89 df                	mov    %ebx,%edi
  8018a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8018a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018a9:	85 ff                	test   %edi,%edi
  8018ab:	7f e4                	jg     801891 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018b0:	e9 a2 fd ff ff       	jmp    801657 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8018b5:	83 fa 01             	cmp    $0x1,%edx
  8018b8:	7e 16                	jle    8018d0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8018ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8018bd:	8d 50 08             	lea    0x8(%eax),%edx
  8018c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c3:	8b 50 04             	mov    0x4(%eax),%edx
  8018c6:	8b 00                	mov    (%eax),%eax
  8018c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018cb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018ce:	eb 32                	jmp    801902 <vprintfmt+0x2d1>
	else if (lflag)
  8018d0:	85 d2                	test   %edx,%edx
  8018d2:	74 18                	je     8018ec <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8018d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8018d7:	8d 50 04             	lea    0x4(%eax),%edx
  8018da:	89 55 14             	mov    %edx,0x14(%ebp)
  8018dd:	8b 00                	mov    (%eax),%eax
  8018df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018e2:	89 c1                	mov    %eax,%ecx
  8018e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8018e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018ea:	eb 16                	jmp    801902 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8018ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ef:	8d 50 04             	lea    0x4(%eax),%edx
  8018f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f5:	8b 00                	mov    (%eax),%eax
  8018f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018fa:	89 c1                	mov    %eax,%ecx
  8018fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8018ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801902:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801905:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801908:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80190d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801911:	79 74                	jns    801987 <vprintfmt+0x356>
				putch('-', putdat);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	53                   	push   %ebx
  801917:	6a 2d                	push   $0x2d
  801919:	ff d6                	call   *%esi
				num = -(long long) num;
  80191b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80191e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801921:	f7 d8                	neg    %eax
  801923:	83 d2 00             	adc    $0x0,%edx
  801926:	f7 da                	neg    %edx
  801928:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80192b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801930:	eb 55                	jmp    801987 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801932:	8d 45 14             	lea    0x14(%ebp),%eax
  801935:	e8 83 fc ff ff       	call   8015bd <getuint>
			base = 10;
  80193a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80193f:	eb 46                	jmp    801987 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801941:	8d 45 14             	lea    0x14(%ebp),%eax
  801944:	e8 74 fc ff ff       	call   8015bd <getuint>
			base = 8;
  801949:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80194e:	eb 37                	jmp    801987 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  801950:	83 ec 08             	sub    $0x8,%esp
  801953:	53                   	push   %ebx
  801954:	6a 30                	push   $0x30
  801956:	ff d6                	call   *%esi
			putch('x', putdat);
  801958:	83 c4 08             	add    $0x8,%esp
  80195b:	53                   	push   %ebx
  80195c:	6a 78                	push   $0x78
  80195e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801960:	8b 45 14             	mov    0x14(%ebp),%eax
  801963:	8d 50 04             	lea    0x4(%eax),%edx
  801966:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801969:	8b 00                	mov    (%eax),%eax
  80196b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801970:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801973:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801978:	eb 0d                	jmp    801987 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80197a:	8d 45 14             	lea    0x14(%ebp),%eax
  80197d:	e8 3b fc ff ff       	call   8015bd <getuint>
			base = 16;
  801982:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801987:	83 ec 0c             	sub    $0xc,%esp
  80198a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80198e:	57                   	push   %edi
  80198f:	ff 75 e0             	pushl  -0x20(%ebp)
  801992:	51                   	push   %ecx
  801993:	52                   	push   %edx
  801994:	50                   	push   %eax
  801995:	89 da                	mov    %ebx,%edx
  801997:	89 f0                	mov    %esi,%eax
  801999:	e8 70 fb ff ff       	call   80150e <printnum>
			break;
  80199e:	83 c4 20             	add    $0x20,%esp
  8019a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019a4:	e9 ae fc ff ff       	jmp    801657 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	53                   	push   %ebx
  8019ad:	51                   	push   %ecx
  8019ae:	ff d6                	call   *%esi
			break;
  8019b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8019b6:	e9 9c fc ff ff       	jmp    801657 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	53                   	push   %ebx
  8019bf:	6a 25                	push   $0x25
  8019c1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	eb 03                	jmp    8019cb <vprintfmt+0x39a>
  8019c8:	83 ef 01             	sub    $0x1,%edi
  8019cb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8019cf:	75 f7                	jne    8019c8 <vprintfmt+0x397>
  8019d1:	e9 81 fc ff ff       	jmp    801657 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8019d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d9:	5b                   	pop    %ebx
  8019da:	5e                   	pop    %esi
  8019db:	5f                   	pop    %edi
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	83 ec 18             	sub    $0x18,%esp
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019ed:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8019f1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8019f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	74 26                	je     801a25 <vsnprintf+0x47>
  8019ff:	85 d2                	test   %edx,%edx
  801a01:	7e 22                	jle    801a25 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a03:	ff 75 14             	pushl  0x14(%ebp)
  801a06:	ff 75 10             	pushl  0x10(%ebp)
  801a09:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a0c:	50                   	push   %eax
  801a0d:	68 f7 15 80 00       	push   $0x8015f7
  801a12:	e8 1a fc ff ff       	call   801631 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a1a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	eb 05                	jmp    801a2a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a25:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a32:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a35:	50                   	push   %eax
  801a36:	ff 75 10             	pushl  0x10(%ebp)
  801a39:	ff 75 0c             	pushl  0xc(%ebp)
  801a3c:	ff 75 08             	pushl  0x8(%ebp)
  801a3f:	e8 9a ff ff ff       	call   8019de <vsnprintf>
	va_end(ap);

	return rc;
}
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    

00801a46 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a51:	eb 03                	jmp    801a56 <strlen+0x10>
		n++;
  801a53:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a56:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a5a:	75 f7                	jne    801a53 <strlen+0xd>
		n++;
	return n;
}
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a64:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a67:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6c:	eb 03                	jmp    801a71 <strnlen+0x13>
		n++;
  801a6e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a71:	39 c2                	cmp    %eax,%edx
  801a73:	74 08                	je     801a7d <strnlen+0x1f>
  801a75:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801a79:	75 f3                	jne    801a6e <strnlen+0x10>
  801a7b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801a7d:	5d                   	pop    %ebp
  801a7e:	c3                   	ret    

00801a7f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	53                   	push   %ebx
  801a83:	8b 45 08             	mov    0x8(%ebp),%eax
  801a86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801a89:	89 c2                	mov    %eax,%edx
  801a8b:	83 c2 01             	add    $0x1,%edx
  801a8e:	83 c1 01             	add    $0x1,%ecx
  801a91:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801a95:	88 5a ff             	mov    %bl,-0x1(%edx)
  801a98:	84 db                	test   %bl,%bl
  801a9a:	75 ef                	jne    801a8b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801a9c:	5b                   	pop    %ebx
  801a9d:	5d                   	pop    %ebp
  801a9e:	c3                   	ret    

00801a9f <strcat>:

char *
strcat(char *dst, const char *src)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	53                   	push   %ebx
  801aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801aa6:	53                   	push   %ebx
  801aa7:	e8 9a ff ff ff       	call   801a46 <strlen>
  801aac:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801aaf:	ff 75 0c             	pushl  0xc(%ebp)
  801ab2:	01 d8                	add    %ebx,%eax
  801ab4:	50                   	push   %eax
  801ab5:	e8 c5 ff ff ff       	call   801a7f <strcpy>
	return dst;
}
  801aba:	89 d8                	mov    %ebx,%eax
  801abc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abf:	c9                   	leave  
  801ac0:	c3                   	ret    

00801ac1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	56                   	push   %esi
  801ac5:	53                   	push   %ebx
  801ac6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801acc:	89 f3                	mov    %esi,%ebx
  801ace:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ad1:	89 f2                	mov    %esi,%edx
  801ad3:	eb 0f                	jmp    801ae4 <strncpy+0x23>
		*dst++ = *src;
  801ad5:	83 c2 01             	add    $0x1,%edx
  801ad8:	0f b6 01             	movzbl (%ecx),%eax
  801adb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ade:	80 39 01             	cmpb   $0x1,(%ecx)
  801ae1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ae4:	39 da                	cmp    %ebx,%edx
  801ae6:	75 ed                	jne    801ad5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ae8:	89 f0                	mov    %esi,%eax
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5d                   	pop    %ebp
  801aed:	c3                   	ret    

00801aee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801aee:	55                   	push   %ebp
  801aef:	89 e5                	mov    %esp,%ebp
  801af1:	56                   	push   %esi
  801af2:	53                   	push   %ebx
  801af3:	8b 75 08             	mov    0x8(%ebp),%esi
  801af6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af9:	8b 55 10             	mov    0x10(%ebp),%edx
  801afc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801afe:	85 d2                	test   %edx,%edx
  801b00:	74 21                	je     801b23 <strlcpy+0x35>
  801b02:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801b06:	89 f2                	mov    %esi,%edx
  801b08:	eb 09                	jmp    801b13 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801b0a:	83 c2 01             	add    $0x1,%edx
  801b0d:	83 c1 01             	add    $0x1,%ecx
  801b10:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b13:	39 c2                	cmp    %eax,%edx
  801b15:	74 09                	je     801b20 <strlcpy+0x32>
  801b17:	0f b6 19             	movzbl (%ecx),%ebx
  801b1a:	84 db                	test   %bl,%bl
  801b1c:	75 ec                	jne    801b0a <strlcpy+0x1c>
  801b1e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801b20:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801b23:	29 f0                	sub    %esi,%eax
}
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801b32:	eb 06                	jmp    801b3a <strcmp+0x11>
		p++, q++;
  801b34:	83 c1 01             	add    $0x1,%ecx
  801b37:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b3a:	0f b6 01             	movzbl (%ecx),%eax
  801b3d:	84 c0                	test   %al,%al
  801b3f:	74 04                	je     801b45 <strcmp+0x1c>
  801b41:	3a 02                	cmp    (%edx),%al
  801b43:	74 ef                	je     801b34 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801b45:	0f b6 c0             	movzbl %al,%eax
  801b48:	0f b6 12             	movzbl (%edx),%edx
  801b4b:	29 d0                	sub    %edx,%eax
}
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	53                   	push   %ebx
  801b53:	8b 45 08             	mov    0x8(%ebp),%eax
  801b56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b59:	89 c3                	mov    %eax,%ebx
  801b5b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801b5e:	eb 06                	jmp    801b66 <strncmp+0x17>
		n--, p++, q++;
  801b60:	83 c0 01             	add    $0x1,%eax
  801b63:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801b66:	39 d8                	cmp    %ebx,%eax
  801b68:	74 15                	je     801b7f <strncmp+0x30>
  801b6a:	0f b6 08             	movzbl (%eax),%ecx
  801b6d:	84 c9                	test   %cl,%cl
  801b6f:	74 04                	je     801b75 <strncmp+0x26>
  801b71:	3a 0a                	cmp    (%edx),%cl
  801b73:	74 eb                	je     801b60 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801b75:	0f b6 00             	movzbl (%eax),%eax
  801b78:	0f b6 12             	movzbl (%edx),%edx
  801b7b:	29 d0                	sub    %edx,%eax
  801b7d:	eb 05                	jmp    801b84 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b84:	5b                   	pop    %ebx
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801b91:	eb 07                	jmp    801b9a <strchr+0x13>
		if (*s == c)
  801b93:	38 ca                	cmp    %cl,%dl
  801b95:	74 0f                	je     801ba6 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801b97:	83 c0 01             	add    $0x1,%eax
  801b9a:	0f b6 10             	movzbl (%eax),%edx
  801b9d:	84 d2                	test   %dl,%dl
  801b9f:	75 f2                	jne    801b93 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801bb2:	eb 03                	jmp    801bb7 <strfind+0xf>
  801bb4:	83 c0 01             	add    $0x1,%eax
  801bb7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801bba:	38 ca                	cmp    %cl,%dl
  801bbc:	74 04                	je     801bc2 <strfind+0x1a>
  801bbe:	84 d2                	test   %dl,%dl
  801bc0:	75 f2                	jne    801bb4 <strfind+0xc>
			break;
	return (char *) s;
}
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	57                   	push   %edi
  801bc8:	56                   	push   %esi
  801bc9:	53                   	push   %ebx
  801bca:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bcd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801bd0:	85 c9                	test   %ecx,%ecx
  801bd2:	74 36                	je     801c0a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801bd4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801bda:	75 28                	jne    801c04 <memset+0x40>
  801bdc:	f6 c1 03             	test   $0x3,%cl
  801bdf:	75 23                	jne    801c04 <memset+0x40>
		c &= 0xFF;
  801be1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801be5:	89 d3                	mov    %edx,%ebx
  801be7:	c1 e3 08             	shl    $0x8,%ebx
  801bea:	89 d6                	mov    %edx,%esi
  801bec:	c1 e6 18             	shl    $0x18,%esi
  801bef:	89 d0                	mov    %edx,%eax
  801bf1:	c1 e0 10             	shl    $0x10,%eax
  801bf4:	09 f0                	or     %esi,%eax
  801bf6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801bf8:	89 d8                	mov    %ebx,%eax
  801bfa:	09 d0                	or     %edx,%eax
  801bfc:	c1 e9 02             	shr    $0x2,%ecx
  801bff:	fc                   	cld    
  801c00:	f3 ab                	rep stos %eax,%es:(%edi)
  801c02:	eb 06                	jmp    801c0a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c07:	fc                   	cld    
  801c08:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c0a:	89 f8                	mov    %edi,%eax
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5f                   	pop    %edi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	57                   	push   %edi
  801c15:	56                   	push   %esi
  801c16:	8b 45 08             	mov    0x8(%ebp),%eax
  801c19:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801c1f:	39 c6                	cmp    %eax,%esi
  801c21:	73 35                	jae    801c58 <memmove+0x47>
  801c23:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801c26:	39 d0                	cmp    %edx,%eax
  801c28:	73 2e                	jae    801c58 <memmove+0x47>
		s += n;
		d += n;
  801c2a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c2d:	89 d6                	mov    %edx,%esi
  801c2f:	09 fe                	or     %edi,%esi
  801c31:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801c37:	75 13                	jne    801c4c <memmove+0x3b>
  801c39:	f6 c1 03             	test   $0x3,%cl
  801c3c:	75 0e                	jne    801c4c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801c3e:	83 ef 04             	sub    $0x4,%edi
  801c41:	8d 72 fc             	lea    -0x4(%edx),%esi
  801c44:	c1 e9 02             	shr    $0x2,%ecx
  801c47:	fd                   	std    
  801c48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c4a:	eb 09                	jmp    801c55 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801c4c:	83 ef 01             	sub    $0x1,%edi
  801c4f:	8d 72 ff             	lea    -0x1(%edx),%esi
  801c52:	fd                   	std    
  801c53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801c55:	fc                   	cld    
  801c56:	eb 1d                	jmp    801c75 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801c58:	89 f2                	mov    %esi,%edx
  801c5a:	09 c2                	or     %eax,%edx
  801c5c:	f6 c2 03             	test   $0x3,%dl
  801c5f:	75 0f                	jne    801c70 <memmove+0x5f>
  801c61:	f6 c1 03             	test   $0x3,%cl
  801c64:	75 0a                	jne    801c70 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801c66:	c1 e9 02             	shr    $0x2,%ecx
  801c69:	89 c7                	mov    %eax,%edi
  801c6b:	fc                   	cld    
  801c6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801c6e:	eb 05                	jmp    801c75 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801c70:	89 c7                	mov    %eax,%edi
  801c72:	fc                   	cld    
  801c73:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801c75:	5e                   	pop    %esi
  801c76:	5f                   	pop    %edi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801c7c:	ff 75 10             	pushl  0x10(%ebp)
  801c7f:	ff 75 0c             	pushl  0xc(%ebp)
  801c82:	ff 75 08             	pushl  0x8(%ebp)
  801c85:	e8 87 ff ff ff       	call   801c11 <memmove>
}
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	56                   	push   %esi
  801c90:	53                   	push   %ebx
  801c91:	8b 45 08             	mov    0x8(%ebp),%eax
  801c94:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c97:	89 c6                	mov    %eax,%esi
  801c99:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801c9c:	eb 1a                	jmp    801cb8 <memcmp+0x2c>
		if (*s1 != *s2)
  801c9e:	0f b6 08             	movzbl (%eax),%ecx
  801ca1:	0f b6 1a             	movzbl (%edx),%ebx
  801ca4:	38 d9                	cmp    %bl,%cl
  801ca6:	74 0a                	je     801cb2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ca8:	0f b6 c1             	movzbl %cl,%eax
  801cab:	0f b6 db             	movzbl %bl,%ebx
  801cae:	29 d8                	sub    %ebx,%eax
  801cb0:	eb 0f                	jmp    801cc1 <memcmp+0x35>
		s1++, s2++;
  801cb2:	83 c0 01             	add    $0x1,%eax
  801cb5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801cb8:	39 f0                	cmp    %esi,%eax
  801cba:	75 e2                	jne    801c9e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cc1:	5b                   	pop    %ebx
  801cc2:	5e                   	pop    %esi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	53                   	push   %ebx
  801cc9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801ccc:	89 c1                	mov    %eax,%ecx
  801cce:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801cd1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801cd5:	eb 0a                	jmp    801ce1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801cd7:	0f b6 10             	movzbl (%eax),%edx
  801cda:	39 da                	cmp    %ebx,%edx
  801cdc:	74 07                	je     801ce5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801cde:	83 c0 01             	add    $0x1,%eax
  801ce1:	39 c8                	cmp    %ecx,%eax
  801ce3:	72 f2                	jb     801cd7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801ce5:	5b                   	pop    %ebx
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    

00801ce8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	57                   	push   %edi
  801cec:	56                   	push   %esi
  801ced:	53                   	push   %ebx
  801cee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cf4:	eb 03                	jmp    801cf9 <strtol+0x11>
		s++;
  801cf6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801cf9:	0f b6 01             	movzbl (%ecx),%eax
  801cfc:	3c 20                	cmp    $0x20,%al
  801cfe:	74 f6                	je     801cf6 <strtol+0xe>
  801d00:	3c 09                	cmp    $0x9,%al
  801d02:	74 f2                	je     801cf6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801d04:	3c 2b                	cmp    $0x2b,%al
  801d06:	75 0a                	jne    801d12 <strtol+0x2a>
		s++;
  801d08:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801d0b:	bf 00 00 00 00       	mov    $0x0,%edi
  801d10:	eb 11                	jmp    801d23 <strtol+0x3b>
  801d12:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801d17:	3c 2d                	cmp    $0x2d,%al
  801d19:	75 08                	jne    801d23 <strtol+0x3b>
		s++, neg = 1;
  801d1b:	83 c1 01             	add    $0x1,%ecx
  801d1e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801d23:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801d29:	75 15                	jne    801d40 <strtol+0x58>
  801d2b:	80 39 30             	cmpb   $0x30,(%ecx)
  801d2e:	75 10                	jne    801d40 <strtol+0x58>
  801d30:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801d34:	75 7c                	jne    801db2 <strtol+0xca>
		s += 2, base = 16;
  801d36:	83 c1 02             	add    $0x2,%ecx
  801d39:	bb 10 00 00 00       	mov    $0x10,%ebx
  801d3e:	eb 16                	jmp    801d56 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801d40:	85 db                	test   %ebx,%ebx
  801d42:	75 12                	jne    801d56 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801d44:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801d49:	80 39 30             	cmpb   $0x30,(%ecx)
  801d4c:	75 08                	jne    801d56 <strtol+0x6e>
		s++, base = 8;
  801d4e:	83 c1 01             	add    $0x1,%ecx
  801d51:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801d56:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801d5e:	0f b6 11             	movzbl (%ecx),%edx
  801d61:	8d 72 d0             	lea    -0x30(%edx),%esi
  801d64:	89 f3                	mov    %esi,%ebx
  801d66:	80 fb 09             	cmp    $0x9,%bl
  801d69:	77 08                	ja     801d73 <strtol+0x8b>
			dig = *s - '0';
  801d6b:	0f be d2             	movsbl %dl,%edx
  801d6e:	83 ea 30             	sub    $0x30,%edx
  801d71:	eb 22                	jmp    801d95 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801d73:	8d 72 9f             	lea    -0x61(%edx),%esi
  801d76:	89 f3                	mov    %esi,%ebx
  801d78:	80 fb 19             	cmp    $0x19,%bl
  801d7b:	77 08                	ja     801d85 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801d7d:	0f be d2             	movsbl %dl,%edx
  801d80:	83 ea 57             	sub    $0x57,%edx
  801d83:	eb 10                	jmp    801d95 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801d85:	8d 72 bf             	lea    -0x41(%edx),%esi
  801d88:	89 f3                	mov    %esi,%ebx
  801d8a:	80 fb 19             	cmp    $0x19,%bl
  801d8d:	77 16                	ja     801da5 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801d8f:	0f be d2             	movsbl %dl,%edx
  801d92:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801d95:	3b 55 10             	cmp    0x10(%ebp),%edx
  801d98:	7d 0b                	jge    801da5 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801d9a:	83 c1 01             	add    $0x1,%ecx
  801d9d:	0f af 45 10          	imul   0x10(%ebp),%eax
  801da1:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801da3:	eb b9                	jmp    801d5e <strtol+0x76>

	if (endptr)
  801da5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801da9:	74 0d                	je     801db8 <strtol+0xd0>
		*endptr = (char *) s;
  801dab:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dae:	89 0e                	mov    %ecx,(%esi)
  801db0:	eb 06                	jmp    801db8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801db2:	85 db                	test   %ebx,%ebx
  801db4:	74 98                	je     801d4e <strtol+0x66>
  801db6:	eb 9e                	jmp    801d56 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801db8:	89 c2                	mov    %eax,%edx
  801dba:	f7 da                	neg    %edx
  801dbc:	85 ff                	test   %edi,%edi
  801dbe:	0f 45 c2             	cmovne %edx,%eax
}
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5f                   	pop    %edi
  801dc4:	5d                   	pop    %ebp
  801dc5:	c3                   	ret    

00801dc6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801dcc:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dd3:	75 2a                	jne    801dff <set_pgfault_handler+0x39>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), 
  801dd5:	83 ec 04             	sub    $0x4,%esp
  801dd8:	6a 07                	push   $0x7
  801dda:	68 00 f0 bf ee       	push   $0xeebff000
  801ddf:	6a 00                	push   $0x0
  801de1:	e8 ad e3 ff ff       	call   800193 <sys_page_alloc>
				   PTE_W | PTE_U | PTE_P);
		if (r < 0) {
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	85 c0                	test   %eax,%eax
  801deb:	79 12                	jns    801dff <set_pgfault_handler+0x39>
			panic("%e\n", r);
  801ded:	50                   	push   %eax
  801dee:	68 e0 26 80 00       	push   $0x8026e0
  801df3:	6a 23                	push   $0x23
  801df5:	68 e4 26 80 00       	push   $0x8026e4
  801dfa:	e8 22 f6 ff ff       	call   801421 <_panic>
		}
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dff:	8b 45 08             	mov    0x8(%ebp),%eax
  801e02:	a3 00 60 80 00       	mov    %eax,0x806000
	r = sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801e07:	83 ec 08             	sub    $0x8,%esp
  801e0a:	68 e4 03 80 00       	push   $0x8003e4
  801e0f:	6a 00                	push   $0x0
  801e11:	e8 c8 e4 ff ff       	call   8002de <sys_env_set_pgfault_upcall>
	if (r < 0) {
  801e16:	83 c4 10             	add    $0x10,%esp
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	79 12                	jns    801e2f <set_pgfault_handler+0x69>
		panic("%e\n", r);
  801e1d:	50                   	push   %eax
  801e1e:	68 e0 26 80 00       	push   $0x8026e0
  801e23:	6a 2c                	push   $0x2c
  801e25:	68 e4 26 80 00       	push   $0x8026e4
  801e2a:	e8 f2 f5 ff ff       	call   801421 <_panic>
	}
}
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	56                   	push   %esi
  801e35:	53                   	push   %ebx
  801e36:	8b 75 08             	mov    0x8(%ebp),%esi
  801e39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r;
	if (!pg) {
  801e3f:	85 c0                	test   %eax,%eax
  801e41:	75 12                	jne    801e55 <ipc_recv+0x24>
		r = sys_ipc_recv((void*)UTOP);
  801e43:	83 ec 0c             	sub    $0xc,%esp
  801e46:	68 00 00 c0 ee       	push   $0xeec00000
  801e4b:	e8 f3 e4 ff ff       	call   800343 <sys_ipc_recv>
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	eb 0c                	jmp    801e61 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv(pg);
  801e55:	83 ec 0c             	sub    $0xc,%esp
  801e58:	50                   	push   %eax
  801e59:	e8 e5 e4 ff ff       	call   800343 <sys_ipc_recv>
  801e5e:	83 c4 10             	add    $0x10,%esp
	}

	if ((r < 0) && (from_env_store != 0) && (perm_store != 0)) {
  801e61:	85 f6                	test   %esi,%esi
  801e63:	0f 95 c1             	setne  %cl
  801e66:	85 db                	test   %ebx,%ebx
  801e68:	0f 95 c2             	setne  %dl
  801e6b:	84 d1                	test   %dl,%cl
  801e6d:	74 09                	je     801e78 <ipc_recv+0x47>
  801e6f:	89 c2                	mov    %eax,%edx
  801e71:	c1 ea 1f             	shr    $0x1f,%edx
  801e74:	84 d2                	test   %dl,%dl
  801e76:	75 2d                	jne    801ea5 <ipc_recv+0x74>
		from_env_store = 0;
		perm_store = 0;
		return r;
	}
	
	if (from_env_store) {
  801e78:	85 f6                	test   %esi,%esi
  801e7a:	74 0d                	je     801e89 <ipc_recv+0x58>
		*from_env_store = thisenv->env_ipc_from;
  801e7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e81:	8b 80 d0 00 00 00    	mov    0xd0(%eax),%eax
  801e87:	89 06                	mov    %eax,(%esi)
	}

	if (perm_store) {
  801e89:	85 db                	test   %ebx,%ebx
  801e8b:	74 0d                	je     801e9a <ipc_recv+0x69>
		*perm_store = thisenv->env_ipc_perm;
  801e8d:	a1 04 40 80 00       	mov    0x804004,%eax
  801e92:	8b 80 d4 00 00 00    	mov    0xd4(%eax),%eax
  801e98:	89 03                	mov    %eax,(%ebx)
	}
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801e9a:	a1 04 40 80 00       	mov    0x804004,%eax
  801e9f:	8b 80 cc 00 00 00    	mov    0xcc(%eax),%eax
}
  801ea5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5d                   	pop    %ebp
  801eab:	c3                   	ret    

00801eac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	57                   	push   %edi
  801eb0:	56                   	push   %esi
  801eb1:	53                   	push   %ebx
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eb8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ebb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
  801ebe:	85 db                	test   %ebx,%ebx
  801ec0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ec5:	0f 44 d8             	cmove  %eax,%ebx
	}
	while (r != 0){
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801ec8:	ff 75 14             	pushl  0x14(%ebp)
  801ecb:	53                   	push   %ebx
  801ecc:	56                   	push   %esi
  801ecd:	57                   	push   %edi
  801ece:	e8 4d e4 ff ff       	call   800320 <sys_ipc_try_send>
		if ((r < 0) && (r != -E_IPC_NOT_RECV)) {
  801ed3:	89 c2                	mov    %eax,%edx
  801ed5:	c1 ea 1f             	shr    $0x1f,%edx
  801ed8:	83 c4 10             	add    $0x10,%esp
  801edb:	84 d2                	test   %dl,%dl
  801edd:	74 17                	je     801ef6 <ipc_send+0x4a>
  801edf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ee2:	74 12                	je     801ef6 <ipc_send+0x4a>
			panic("failed ipc %e", r);
  801ee4:	50                   	push   %eax
  801ee5:	68 f2 26 80 00       	push   $0x8026f2
  801eea:	6a 47                	push   $0x47
  801eec:	68 00 27 80 00       	push   $0x802700
  801ef1:	e8 2b f5 ff ff       	call   801421 <_panic>
		}
		if (r == -E_IPC_NOT_RECV) {
  801ef6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ef9:	75 07                	jne    801f02 <ipc_send+0x56>
			sys_yield();
  801efb:	e8 74 e2 ff ff       	call   800174 <sys_yield>
  801f00:	eb c6                	jmp    801ec8 <ipc_send+0x1c>

	int r = 1;
	if (!pg) {
		pg = (void*)UTOP;
	}
	while (r != 0){
  801f02:	85 c0                	test   %eax,%eax
  801f04:	75 c2                	jne    801ec8 <ipc_send+0x1c>
		}
		if (r == -E_IPC_NOT_RECV) {
			sys_yield();
		}
	}
}
  801f06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f09:	5b                   	pop    %ebx
  801f0a:	5e                   	pop    %esi
  801f0b:	5f                   	pop    %edi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    

00801f0e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f19:	69 d0 d8 00 00 00    	imul   $0xd8,%eax,%edx
  801f1f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f25:	8b 92 ac 00 00 00    	mov    0xac(%edx),%edx
  801f2b:	39 ca                	cmp    %ecx,%edx
  801f2d:	75 13                	jne    801f42 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f2f:	69 c0 d8 00 00 00    	imul   $0xd8,%eax,%eax
  801f35:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f3a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
  801f40:	eb 0f                	jmp    801f51 <ipc_find_env+0x43>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f42:	83 c0 01             	add    $0x1,%eax
  801f45:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f4a:	75 cd                	jne    801f19 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f59:	89 d0                	mov    %edx,%eax
  801f5b:	c1 e8 16             	shr    $0x16,%eax
  801f5e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f65:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f6a:	f6 c1 01             	test   $0x1,%cl
  801f6d:	74 1d                	je     801f8c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f6f:	c1 ea 0c             	shr    $0xc,%edx
  801f72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f79:	f6 c2 01             	test   $0x1,%dl
  801f7c:	74 0e                	je     801f8c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f7e:	c1 ea 0c             	shr    $0xc,%edx
  801f81:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f88:	ef 
  801f89:	0f b7 c0             	movzwl %ax,%eax
}
  801f8c:	5d                   	pop    %ebp
  801f8d:	c3                   	ret    
  801f8e:	66 90                	xchg   %ax,%ax

00801f90 <__udivdi3>:
  801f90:	55                   	push   %ebp
  801f91:	57                   	push   %edi
  801f92:	56                   	push   %esi
  801f93:	53                   	push   %ebx
  801f94:	83 ec 1c             	sub    $0x1c,%esp
  801f97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fa3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fa7:	85 f6                	test   %esi,%esi
  801fa9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fad:	89 ca                	mov    %ecx,%edx
  801faf:	89 f8                	mov    %edi,%eax
  801fb1:	75 3d                	jne    801ff0 <__udivdi3+0x60>
  801fb3:	39 cf                	cmp    %ecx,%edi
  801fb5:	0f 87 c5 00 00 00    	ja     802080 <__udivdi3+0xf0>
  801fbb:	85 ff                	test   %edi,%edi
  801fbd:	89 fd                	mov    %edi,%ebp
  801fbf:	75 0b                	jne    801fcc <__udivdi3+0x3c>
  801fc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc6:	31 d2                	xor    %edx,%edx
  801fc8:	f7 f7                	div    %edi
  801fca:	89 c5                	mov    %eax,%ebp
  801fcc:	89 c8                	mov    %ecx,%eax
  801fce:	31 d2                	xor    %edx,%edx
  801fd0:	f7 f5                	div    %ebp
  801fd2:	89 c1                	mov    %eax,%ecx
  801fd4:	89 d8                	mov    %ebx,%eax
  801fd6:	89 cf                	mov    %ecx,%edi
  801fd8:	f7 f5                	div    %ebp
  801fda:	89 c3                	mov    %eax,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	39 ce                	cmp    %ecx,%esi
  801ff2:	77 74                	ja     802068 <__udivdi3+0xd8>
  801ff4:	0f bd fe             	bsr    %esi,%edi
  801ff7:	83 f7 1f             	xor    $0x1f,%edi
  801ffa:	0f 84 98 00 00 00    	je     802098 <__udivdi3+0x108>
  802000:	bb 20 00 00 00       	mov    $0x20,%ebx
  802005:	89 f9                	mov    %edi,%ecx
  802007:	89 c5                	mov    %eax,%ebp
  802009:	29 fb                	sub    %edi,%ebx
  80200b:	d3 e6                	shl    %cl,%esi
  80200d:	89 d9                	mov    %ebx,%ecx
  80200f:	d3 ed                	shr    %cl,%ebp
  802011:	89 f9                	mov    %edi,%ecx
  802013:	d3 e0                	shl    %cl,%eax
  802015:	09 ee                	or     %ebp,%esi
  802017:	89 d9                	mov    %ebx,%ecx
  802019:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201d:	89 d5                	mov    %edx,%ebp
  80201f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802023:	d3 ed                	shr    %cl,%ebp
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e2                	shl    %cl,%edx
  802029:	89 d9                	mov    %ebx,%ecx
  80202b:	d3 e8                	shr    %cl,%eax
  80202d:	09 c2                	or     %eax,%edx
  80202f:	89 d0                	mov    %edx,%eax
  802031:	89 ea                	mov    %ebp,%edx
  802033:	f7 f6                	div    %esi
  802035:	89 d5                	mov    %edx,%ebp
  802037:	89 c3                	mov    %eax,%ebx
  802039:	f7 64 24 0c          	mull   0xc(%esp)
  80203d:	39 d5                	cmp    %edx,%ebp
  80203f:	72 10                	jb     802051 <__udivdi3+0xc1>
  802041:	8b 74 24 08          	mov    0x8(%esp),%esi
  802045:	89 f9                	mov    %edi,%ecx
  802047:	d3 e6                	shl    %cl,%esi
  802049:	39 c6                	cmp    %eax,%esi
  80204b:	73 07                	jae    802054 <__udivdi3+0xc4>
  80204d:	39 d5                	cmp    %edx,%ebp
  80204f:	75 03                	jne    802054 <__udivdi3+0xc4>
  802051:	83 eb 01             	sub    $0x1,%ebx
  802054:	31 ff                	xor    %edi,%edi
  802056:	89 d8                	mov    %ebx,%eax
  802058:	89 fa                	mov    %edi,%edx
  80205a:	83 c4 1c             	add    $0x1c,%esp
  80205d:	5b                   	pop    %ebx
  80205e:	5e                   	pop    %esi
  80205f:	5f                   	pop    %edi
  802060:	5d                   	pop    %ebp
  802061:	c3                   	ret    
  802062:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802068:	31 ff                	xor    %edi,%edi
  80206a:	31 db                	xor    %ebx,%ebx
  80206c:	89 d8                	mov    %ebx,%eax
  80206e:	89 fa                	mov    %edi,%edx
  802070:	83 c4 1c             	add    $0x1c,%esp
  802073:	5b                   	pop    %ebx
  802074:	5e                   	pop    %esi
  802075:	5f                   	pop    %edi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    
  802078:	90                   	nop
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d8                	mov    %ebx,%eax
  802082:	f7 f7                	div    %edi
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 c3                	mov    %eax,%ebx
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	89 fa                	mov    %edi,%edx
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	39 ce                	cmp    %ecx,%esi
  80209a:	72 0c                	jb     8020a8 <__udivdi3+0x118>
  80209c:	31 db                	xor    %ebx,%ebx
  80209e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020a2:	0f 87 34 ff ff ff    	ja     801fdc <__udivdi3+0x4c>
  8020a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020ad:	e9 2a ff ff ff       	jmp    801fdc <__udivdi3+0x4c>
  8020b2:	66 90                	xchg   %ax,%ax
  8020b4:	66 90                	xchg   %ax,%ax
  8020b6:	66 90                	xchg   %ax,%ax
  8020b8:	66 90                	xchg   %ax,%ax
  8020ba:	66 90                	xchg   %ax,%ax
  8020bc:	66 90                	xchg   %ax,%ax
  8020be:	66 90                	xchg   %ax,%ax

008020c0 <__umoddi3>:
  8020c0:	55                   	push   %ebp
  8020c1:	57                   	push   %edi
  8020c2:	56                   	push   %esi
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 1c             	sub    $0x1c,%esp
  8020c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020d7:	85 d2                	test   %edx,%edx
  8020d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f3                	mov    %esi,%ebx
  8020e3:	89 3c 24             	mov    %edi,(%esp)
  8020e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ea:	75 1c                	jne    802108 <__umoddi3+0x48>
  8020ec:	39 f7                	cmp    %esi,%edi
  8020ee:	76 50                	jbe    802140 <__umoddi3+0x80>
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	f7 f7                	div    %edi
  8020f6:	89 d0                	mov    %edx,%eax
  8020f8:	31 d2                	xor    %edx,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	39 f2                	cmp    %esi,%edx
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	77 52                	ja     802160 <__umoddi3+0xa0>
  80210e:	0f bd ea             	bsr    %edx,%ebp
  802111:	83 f5 1f             	xor    $0x1f,%ebp
  802114:	75 5a                	jne    802170 <__umoddi3+0xb0>
  802116:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80211a:	0f 82 e0 00 00 00    	jb     802200 <__umoddi3+0x140>
  802120:	39 0c 24             	cmp    %ecx,(%esp)
  802123:	0f 86 d7 00 00 00    	jbe    802200 <__umoddi3+0x140>
  802129:	8b 44 24 08          	mov    0x8(%esp),%eax
  80212d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	85 ff                	test   %edi,%edi
  802142:	89 fd                	mov    %edi,%ebp
  802144:	75 0b                	jne    802151 <__umoddi3+0x91>
  802146:	b8 01 00 00 00       	mov    $0x1,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	f7 f7                	div    %edi
  80214f:	89 c5                	mov    %eax,%ebp
  802151:	89 f0                	mov    %esi,%eax
  802153:	31 d2                	xor    %edx,%edx
  802155:	f7 f5                	div    %ebp
  802157:	89 c8                	mov    %ecx,%eax
  802159:	f7 f5                	div    %ebp
  80215b:	89 d0                	mov    %edx,%eax
  80215d:	eb 99                	jmp    8020f8 <__umoddi3+0x38>
  80215f:	90                   	nop
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	83 c4 1c             	add    $0x1c,%esp
  802167:	5b                   	pop    %ebx
  802168:	5e                   	pop    %esi
  802169:	5f                   	pop    %edi
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802170:	8b 34 24             	mov    (%esp),%esi
  802173:	bf 20 00 00 00       	mov    $0x20,%edi
  802178:	89 e9                	mov    %ebp,%ecx
  80217a:	29 ef                	sub    %ebp,%edi
  80217c:	d3 e0                	shl    %cl,%eax
  80217e:	89 f9                	mov    %edi,%ecx
  802180:	89 f2                	mov    %esi,%edx
  802182:	d3 ea                	shr    %cl,%edx
  802184:	89 e9                	mov    %ebp,%ecx
  802186:	09 c2                	or     %eax,%edx
  802188:	89 d8                	mov    %ebx,%eax
  80218a:	89 14 24             	mov    %edx,(%esp)
  80218d:	89 f2                	mov    %esi,%edx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	89 f9                	mov    %edi,%ecx
  802193:	89 54 24 04          	mov    %edx,0x4(%esp)
  802197:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	89 c6                	mov    %eax,%esi
  8021a1:	d3 e3                	shl    %cl,%ebx
  8021a3:	89 f9                	mov    %edi,%ecx
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	d3 e8                	shr    %cl,%eax
  8021a9:	89 e9                	mov    %ebp,%ecx
  8021ab:	09 d8                	or     %ebx,%eax
  8021ad:	89 d3                	mov    %edx,%ebx
  8021af:	89 f2                	mov    %esi,%edx
  8021b1:	f7 34 24             	divl   (%esp)
  8021b4:	89 d6                	mov    %edx,%esi
  8021b6:	d3 e3                	shl    %cl,%ebx
  8021b8:	f7 64 24 04          	mull   0x4(%esp)
  8021bc:	39 d6                	cmp    %edx,%esi
  8021be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021c2:	89 d1                	mov    %edx,%ecx
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	72 08                	jb     8021d0 <__umoddi3+0x110>
  8021c8:	75 11                	jne    8021db <__umoddi3+0x11b>
  8021ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ce:	73 0b                	jae    8021db <__umoddi3+0x11b>
  8021d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021d4:	1b 14 24             	sbb    (%esp),%edx
  8021d7:	89 d1                	mov    %edx,%ecx
  8021d9:	89 c3                	mov    %eax,%ebx
  8021db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021df:	29 da                	sub    %ebx,%edx
  8021e1:	19 ce                	sbb    %ecx,%esi
  8021e3:	89 f9                	mov    %edi,%ecx
  8021e5:	89 f0                	mov    %esi,%eax
  8021e7:	d3 e0                	shl    %cl,%eax
  8021e9:	89 e9                	mov    %ebp,%ecx
  8021eb:	d3 ea                	shr    %cl,%edx
  8021ed:	89 e9                	mov    %ebp,%ecx
  8021ef:	d3 ee                	shr    %cl,%esi
  8021f1:	09 d0                	or     %edx,%eax
  8021f3:	89 f2                	mov    %esi,%edx
  8021f5:	83 c4 1c             	add    $0x1c,%esp
  8021f8:	5b                   	pop    %ebx
  8021f9:	5e                   	pop    %esi
  8021fa:	5f                   	pop    %edi
  8021fb:	5d                   	pop    %ebp
  8021fc:	c3                   	ret    
  8021fd:	8d 76 00             	lea    0x0(%esi),%esi
  802200:	29 f9                	sub    %edi,%ecx
  802202:	19 d6                	sbb    %edx,%esi
  802204:	89 74 24 04          	mov    %esi,0x4(%esp)
  802208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80220c:	e9 18 ff ff ff       	jmp    802129 <__umoddi3+0x69>
